library hop_tasks.bench;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:args/args.dart';
import 'package:bot/bot.dart';
import 'package:bot_io/bot_io.dart';
import 'package:hop/hop.dart';
import 'package:hop/src/hop_tasks/process.dart';

const _DEFAULT_RUN_COUNT = 20;

// TODO: options for handling failed processes?
// TODO: move some of the stat-related code to NumebrEnumerable?
// TODO: print out all of the summary values
// TODO: tests?

const String _RUN_COUNT_ARE_NAME = 'run-count';

Task createBenchTask() {
  return new Task((ctx) {
    final parseResult = ctx.arguments;

    final count = int.parse(parseResult[_RUN_COUNT_ARE_NAME],
        onError: (s) => _DEFAULT_RUN_COUNT);

    if(parseResult.rest.isEmpty) {
      ctx.fail('No command provided.');
    }

    final processName = parseResult.rest.first;
    final args = parseResult.rest.sublist(1);

    return _runMany(ctx, count, processName, args)
        .then((list) {
          final values = list.map((brr) => brr.executionDurationMilliseconds);
          final stats = new _Stats(values);
          print(stats.toString());
        });

  },
  config: _benchParserConfig,
  description: 'Run a benchmark against the provided task',
  extendedArgs: [new TaskArgument('command', required: true)]);
}

void _benchParserConfig(ArgParser parser) {
  parser.addOption(_RUN_COUNT_ARE_NAME, abbr: 'r',
      defaultsTo: _DEFAULT_RUN_COUNT.toString(),
      help: 'Specify the number times the specified command should be run');
}

Future<List<_BenchRunResult>> _runMany(TaskLogger logger, int count,
    String processName, List<String> args) {

  assert(count > 1);
  final countStrLength = count.toString().length;

  final range = new Iterable.generate(count, (i) => i);
  final results = new List<_BenchRunResult>();

  return Future.forEach(range, (i) {
    return _runOnce(i+1, processName, args)
        .then((result) {
          final paddedNumber = Util.padLeft(result.runNumber.toString(), countStrLength);
          logger.fine("Test $paddedNumber of $count - ${result.executionDuration}");
          results.add(result);
        });
    })
    .then((_) {
      return results;
    });
}

Future<_BenchRunResult> _runOnce(int runNumber, String processName, List<String> args) {
  var watch = new Stopwatch()
    ..start();

  int postStartMicros;

  return Process.start(processName, args)
      .then((process) {
        postStartMicros = watch.elapsedMicroseconds;
        return pipeProcess(process);
      })
      .then((int exitCode) {
        return new _BenchRunResult(runNumber, exitCode == 0, postStartMicros, watch.elapsedMicroseconds);
      });
}

class _BenchRunResult {
  final int runNumber;
  final int postStartMicroseconds;
  final int postEndMicroseconds;
  final bool completed;

  _BenchRunResult(this.runNumber, this.completed, this.postStartMicroseconds, this.postEndMicroseconds);

  int get executionDurationMilliseconds => postEndMicroseconds - postStartMicroseconds;

  Duration get executionDuration => new Duration(microseconds: executionDurationMilliseconds);

  @override
  String toString() => '''
$runNumber
$executionDurationMilliseconds
$completed''';
}

class _Stats {
  final int count;
  final num mean;
  final num median;
  final num max;
  final num min;
  final num standardDeviation;
  final num standardError;

  _Stats.raw(int count, this.mean, this.median, this.max, this.min, num standardDeviation) :
    this.count = count,
    this.standardDeviation = standardDeviation,
    standardError = standardDeviation / math.sqrt(count);

  factory _Stats(Iterable<int> source) {
    assert(source != null);

    final list = source.toList()
        ..sort();

    assert(!list.isEmpty);

    final int count = list.length;

    final max = list.last;
    final min = list.first;

    int sum = 0;

    list.forEach((num value) {
      sum += value;
    });

    final mean = sum / count;

    // variance
    // The average of the squared difference from the Mean

    num sumOfSquaredDiffFromMean = 0;
    list.forEach((num value) {
      final squareDiffFromMean = math.pow(value - mean, 2);
      sumOfSquaredDiffFromMean += squareDiffFromMean;
    });

    final variance = sumOfSquaredDiffFromMean / count;

    // standardDeviation: sqrt of the variance
    final standardDeviation = math.sqrt(variance);

    num median = null;
    // if length is odd, take middle value
    if(count % 2 == 1) {
      final middleIndex = (count / 2 - 0.5).toInt();
      median = list[middleIndex];
    } else {
      final secondMiddle = count ~/ 2;
      final firstMiddle = secondMiddle - 1;
      median = (list[firstMiddle] + list[secondMiddle]) / 2.0;
    }

    return new _Stats.raw(count, mean, median, max, min, standardDeviation);
  }

  String toString() {
    var rows = [
                  ['Min', min],
                  ['Max', max],
                  ['Media', median],
                  ['Mean', mean],
                  ['StdDev', standardDeviation],
                  ['StdErr', standardError],
                  ];

    final cols = [
                  new ColumnDefinition('Name', (a) => a[0]),
                  new ColumnDefinition('Value', (a) {
                    final num val = a[1];
                    return new Duration(microseconds: val.toInt()).toString();
                  })
                  ];

    return Console.getTable(rows, cols).join('\n');
  }
}
