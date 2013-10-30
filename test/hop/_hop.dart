library test_hop;

import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import 'package:hop/hop.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

import 'simple_add_task_tests.dart' as add_task;
import 'logging_tests.dart' as logging;

part 'arg_tests.dart';
part 'async_tests.dart';
part 'chain_tasks_tests.dart';
part 'integration_tests.dart';
part 'sync_tests.dart';
part 'task_list_tests.dart';

void main() {
  group('hop', () {
    group('add task', add_task.main);
    group('async tasks', AsyncTests.run);
    group('sync tasks', SyncTests.run);
    group('task list', TaskListTests.run);
    group('integration', IntegrationTests.run);
    group('chain tasks', ChainTasksTests.register);
    group('logging', logging.main);

    registerArgTests();

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
