library test.hop.shared;

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:hop/hop_core.dart';


Future<RunResult> runTaskInTestRunner(Task task, {List<String> extraArgs}) {
  const _testTaskName = 'test-task';

  final taskRegistry = new TaskRegistry();
  taskRegistry.addTask(_testTaskName, task);

  final args = [_testTaskName];
  if(extraArgs != null) {
    args.addAll(extraArgs);
  }

  return runRegistry(taskRegistry, args);
}

Future<RunResult> runRegistry(TaskRegistry taskRegistry, List<String> args,
    {void printer(Object obj), Level defalutLogLevel: Level.INFO}) {

  if(printer == null) printer = loggedPrint;

  var config = new HopConfig(taskRegistry, args, printer,
      defaultLogLevel: defalutLogLevel);

  return Runner.run(config, printAtLogLevel: Level.INFO);
}

void loggedPrint(Object value) {
  String msg;
  try {
    msg = value.toString();
  } catch (ex, stack) {
    msg = Error.safeToString(value);
  }
  testLogger.info(msg);
}

final testLogger = new Logger('hop_test_context');
