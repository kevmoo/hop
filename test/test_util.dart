library test.hop.shared;

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';

const String TEST_TASK_NAME = 'test-task-name';

Future<RunResult> runTaskInTestRunner(dynamic task, {List<String> extraArgs,
  List<HopEvent> eventLog, Level printAtLogLevel: Level.INFO}) {

  final taskRegistry = new TaskRegistry();
  taskRegistry.addTask(TEST_TASK_NAME, task);

  final args = [TEST_TASK_NAME];
  if(extraArgs != null) {
    args.addAll(extraArgs);
  }

  return runRegistry(taskRegistry, args, eventLog: eventLog,
      printAtLogLevel: printAtLogLevel);
}

Future<RunResult> runRegistry(TaskRegistry taskRegistry, List<String> args,
    {List<HopEvent> eventLog, Level printAtLogLevel: Level.INFO}) {

  var config = new HopConfig(taskRegistry, args);

  if(eventLog != null) {
    // should probably be empty here, right?
    assert(eventLog.isEmpty);
    config.onEvent.listen(eventLog.add);
  }

  return Runner.run(config, printAtLogLevel: printAtLogLevel);
}
