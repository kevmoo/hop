library test.hop.shared;

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:hop/hop.dart';


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

Future<RunResult> runRegistry(TaskRegistry taskRegistry, List<String> args) {
  var config = new HopConfig(taskRegistry, args, loggedPrint);
  return Runner.run(config);
}

void loggedPrint(Object value) {
  String msg;
  try {
    msg = value.toString();
  } catch (ex, stack) {
    msg = Error.safeToString(value);
  }
  _logger.info(msg);
}

final _logger = new Logger('hop_test_context');
