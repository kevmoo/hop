library hop_tasks.bench;

import 'dart:async';
import 'dart:io' hide Console;

import 'package:args/args.dart';
import 'package:hop/hop_core.dart';
import 'package:hop/src/stats.dart';

// TODO: options for handling failed processes?
// TODO: move some of the stat-related code to NumebrEnumerable?
// TODO: print out all of the summary values
// TODO: tests?

const DEFAULT_BENCHMARK_COUNT = 20;
const _COMMAND_ARG = 'command';
const String _RUN_COUNT_ARE_NAME = 'run-count';

/// Creates a benchmarking task.
///
/// This task will run a command a number of times (the default is 20) and
/// print statistics about the execution time of the command.
///
/// If the Hop task "bench" is this task, running:
///     dart tool/hop_runner.dart bench ls
///
/// Will print:
///     bench: Min       0:00:00.002491
///            Max       0:00:00.010142
///            Media     0:00:00.002720
///            Mean      0:00:00.003241
///            StdDev    0:00:00.001687
///            StdDev%   52.05938%
///            StdErr    0:00:00.000377
///            StdErr%   11.64083%
Task createBenchTask() => new Task((TaskContext ctx) async {
      var parseResult = ctx.arguments;

      var count = int.parse(parseResult[_RUN_COUNT_ARE_NAME],
          onError: (s) => DEFAULT_BENCHMARK_COUNT);

      List<String> commandParams = ctx.extendedArgs[_COMMAND_ARG];

      String processName = commandParams.first;
      var args = commandParams.sublist(1);

      var stats = await benchmarkProcess(processName, args,
          count: count, itemLog: ctx.fine);
      print(stats.toString());
    },
        argParser: _benchParserConfig(),
        description: 'Run a benchmark against the provided task',
        extendedArgs: [
          new TaskArgument('command', required: true, multiple: true)
        ]);

/// If [count] is not provided, [DEFAULT_BENCHMARK_COUNT] is used.
Future<Stats> benchmarkProcess(String processName, List<String> args,
    {int count, void itemLog(String input)}) async {
  if (count == null) {
    count = DEFAULT_BENCHMARK_COUNT;
  }

  if (itemLog == null) {
    itemLog = _emptyLogger;
  }

  var countStrLength = count.toString().length;

  var list = new List<_BenchRunResult>();

  assert(count > 1);

  for (var i = 0; i < count; i++) {
    var result = await _runOnce(i + 1, processName, args);
    var paddedNumber = result.runNumber.toString().padLeft(countStrLength);
    itemLog("Test $paddedNumber of $count - ${result.executionDuration}");
    list.add(result);
  }

  var values = list.map((brr) => brr.executionDuration.inMicroseconds);
  return new Stats(values);
}

void _emptyLogger(String input) {}

ArgParser _benchParserConfig() => new ArgParser()
  ..addOption(_RUN_COUNT_ARE_NAME,
      abbr: 'r',
      defaultsTo: DEFAULT_BENCHMARK_COUNT.toString(),
      help: 'Specify the number times the specified command should be run');

Future<_BenchRunResult> _runOnce(
    int runNumber, String processName, List<String> args) async {
  var watch = new Stopwatch()..start();
  var process = await Process.run(processName, args);

  return new _BenchRunResult(runNumber, process.exitCode == 0, watch.elapsed,
      process.stdout, process.stderr);
}

class _BenchRunResult {
  final int runNumber;
  final Duration executionDuration;
  final String stdout;
  final String stderr;
  final bool completed;

  _BenchRunResult(this.runNumber, this.completed, this.executionDuration,
      this.stdout, this.stderr);

  @override
  String toString() => '''
$runNumber
$executionDuration
$completed''';
}
