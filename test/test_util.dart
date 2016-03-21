library test.hop.shared;

import 'dart:async';

import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
import 'package:logging/logging.dart';

const String TEST_TASK_NAME = 'test-task-name';

Future<RunResult> runTaskInTestRunner(dynamic task,
    {List<String> extraArgs,
    List<HopEvent> eventLog,
    Level printAtLogLevel: Level.INFO,
    bool throwTaskExceptions: false}) {
  final taskRegistry = new TaskRegistry();
  taskRegistry.addTask(TEST_TASK_NAME, task);

  final args = [TEST_TASK_NAME];
  if (extraArgs != null) {
    args.addAll(extraArgs);
  }

  return runRegistry(taskRegistry, args,
      eventLog: eventLog,
      printAtLogLevel: printAtLogLevel,
      throwTaskExceptions: throwTaskExceptions);
}

Future<RunResult> runRegistry(TaskRegistry taskRegistry, List<String> args,
    {List<HopEvent> eventLog,
    Level printAtLogLevel: Level.INFO,
    bool throwTaskExceptions: false}) {
  var config = new HopConfig(taskRegistry, args);

  if (eventLog != null) {
    // should probably be empty here, right?
    assert(eventLog.isEmpty);
    config.onEvent.listen(eventLog.add);
  }

  return Runner.run(config,
      printAtLogLevel: printAtLogLevel,
      throwTaskExceptions: throwTaskExceptions);
}

Future<RunShellOutput> runRegistryShell(
    TaskRegistry registry, List<String> args) {
  var buffer = new StringBuffer();
  var zoneSpec = new ZoneSpecification(print: (a, b, c, String line) {
    buffer.writeln(line);
  });

  return runZoned(() {
    return Runner.runShell(args, registry, 'help', null).then((RunResult rr) {
      return new RunShellOutput(rr, buffer.toString());
    });
  }, zoneSpecification: zoneSpec);
}

class RunShellOutput {
  final RunResult runResult;
  final String printOutput;

  RunShellOutput(this.runResult, this.printOutput) {
    assert(runResult != null);
    assert(printOutput != null);
  }
}

dynamic noopTaskRunner(TaskContext ctx) => null;
