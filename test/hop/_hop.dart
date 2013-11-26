library test_hop;

// TODO: test extended args

import 'package:hop/hop_core.dart';
import 'package:unittest/unittest.dart';

import 'async_tests.dart' as async;
import 'arg_tests.dart' as args;
import 'chain_tasks_tests.dart' as chain;
import 'dependency_tests.dart' as dependency;
import 'integration_tests.dart' as integration;
import 'logging_tests.dart' as logging;
import 'simple_add_task_tests.dart' as simple_add_task;
import 'sync_tests.dart' as sync;
import 'task_list_tests.dart' as task_list;
import 'util_tests.dart' as util;

void main() {
  group('hop', () {
    group('args', args.main);
    group('async tasks', async.main);
    group('chain tasks', chain.main);
    group('dependency', dependency.main);
    group('integration', integration.main);
    group('logging', logging.main);
    group('add task', simple_add_task.main);
    group('sync tasks', sync.main);
    group('task list', task_list.main);
    group('util', util.main);

    group('TaskArgument', () {

      test('valid ctor args', () {
        final valid = ['a', 'a-b', 'a-cool-name'];
        for(final v in valid) {
          expect(() => new TaskArgument(v), returnsNormally);
        }

        final invalid = ['', null, ' ', '-', 'A', 'a-', 'a-B', 'a_b', 'a ', 'a b'];
        for(final v in invalid) {
          expect(() => new TaskArgument(v), throwsArgumentError);
        }

        expect(() => new TaskArgument('cool', required: null), throwsArgumentError);
        expect(() => new TaskArgument('cool', multiple: null), throwsArgumentError);
      });

      test('validate arg list', () {
        final validate = (List<TaskArgument> args, bool isGood) {
          final matcher = isGood ? returnsNormally : throwsArgumentError;
          expect(() => TaskArgument.validateArgs(args), matcher);
        };

        // empty is fine
        validate([], true);

        validate(null, false);

        // null arg is bad
        validate([null], false);

        // first required is fine
        validate([new TaskArgument('a', required: true)], true);

        // first required and mult is fine
        validate([new TaskArgument('a', required: true, multiple: true)], true);

        // first required, second not required is fine
        validate([new TaskArgument('a', required: true), new TaskArgument('b', required: false)], true);

        // first not required, second required is bad
        validate([new TaskArgument('a', required: false), new TaskArgument('b', required: true)], false);

        // last multiple is fine

        // 'N' multiple, 'N+1' non-multiple is not fine
        validate([new TaskArgument('a', multiple: true), new TaskArgument('b', multiple: false)], false);

        // dupe names is not fine
        validate([new TaskArgument('a'), new TaskArgument('a')], false);
      });

    });
  });
}
