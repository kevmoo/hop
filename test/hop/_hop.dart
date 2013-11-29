library test_hop;

import 'package:unittest/unittest.dart';
import 'package:hop/src/hop_runner.dart';
import '../test_util.dart';

import 'arg_tests.dart' as args;
import 'chain_tasks_tests.dart' as chain;
import 'dependency_tests.dart' as dependency;
import 'integration_tests.dart' as integration;
import 'logging_tests.dart' as logging;
import 'simple_add_task_tests.dart' as simple_add_task;
import 'task_list_tests.dart' as task_list;
import 'task_result_tests.dart' as task_result;
import 'util_tests.dart' as util;
import 'extended_args_test.dart' as extended_args;

void main() {
  group('hop', () {
    group('args', args.main);
    group('chain tasks', chain.main);
    group('dependency', dependency.main);
    group('extended args', extended_args.main);
    group('integration', integration.main);
    group('logging', logging.main);
    group('add task', simple_add_task.main);
    group('task list', task_list.main);
    group('task result', task_result.main);
    group('util', util.main);

    group('HopConfig', () {
      test('HopConfig: registry cannot be null', () {
        expect(() => runRegistry(null, []), throwsArgumentError);
      });

      test('HopConfig: args cannot be null', () {
        var reg = new TaskRegistry();
        expect(() => runRegistry(reg, null), throwsArgumentError);
      });
    });
  });
}
