library test.hop.sync;

import 'dart:async';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {
  test('true result is cool', _testTrueIsCool);
  test('false result cool', _testFalseIsFail);
  test('null result is cool', _testNullIsFine);
  test('exception is sad', _testExceptionIsSad);
  test('bad task name', _testBadParam);
  test('no task name', _testNoParam);
  test('no tasks defined', _testNoTasks);
  test('ctx.fail', _testCtxFail);

  test('using context after task completes', () {
    TaskContext ctx;

    return runTaskInTestRunner((val) {
      ctx = val;
    })
    .then((RunResult rr) {
      expect(rr, RunResult.SUCCESS);
      expect(() => ctx.config('this should not work'), throwsStateError);
    });
  });
}

Future _testCtxFail() =>
    runTaskInTestRunner((ctx) => ctx.fail('fail!'))
    .then((value) {
      expect(value, RunResult.FAIL);
    });

Future _testTrueIsCool() =>
    runTaskInTestRunner((ctx) => true)
    .then((value) {
      expect(value, RunResult.SUCCESS);
    });

Future _testFalseIsFail() =>
    runTaskInTestRunner((ctx) => false)
    .then((value) {
      expect(value, RunResult.SUCCESS);
    });

Future _testNullIsFine() =>
    runTaskInTestRunner((ctx) => null)
    .then((value) {
      expect(value, RunResult.SUCCESS);
    });

Future _testExceptionIsSad() =>
    runTaskInTestRunner((ctx) {
      throw 'sorry';
    })
    .then((value) {
      expect(value, RunResult.EXCEPTION);
    });

Future _testBadParam() {
  final taskReg = new TaskRegistry();
  taskReg.addTask('good', (ctx) => true);

  return runRegistry(taskReg, ['bad'])
      .then((value) {
        expect(value, RunResult.BAD_USAGE);
        // TODO: test that proper error message is printed
      });
}

Future _testNoParam() {
  final taskReg = new TaskRegistry();
  taskReg.addTask('good', (ctx) {}, description: 'Just a nice task');

  return runRegistryShell(taskReg, ['--no-color'])
      .then((RunShellOutput value) {
        expect(value.runResult, RunResult.SUCCESS);
        expect(value.printOutput, _GOOD_TASK_NO_PARAMS_OUTPUT);
      });
}

Future _testNoTasks() {
  final taskReg = new TaskRegistry();

  return runRegistryShell(taskReg, ['--no-color'])
      .then((RunShellOutput value) {
        expect(value.runResult, RunResult.SUCCESS);
        expect(value.printOutput, _NO_TASK_NO_PARAMS_OUTPUT);
      });
}

const _NO_TASK_NO_PARAMS_OUTPUT = '''usage: hop [<hop-options>] <task> [<task-options>] [--] [<task-args>]

Tasks:
  help   Print help information about available tasks

Hop options:
  --[no-]color     Specifies if shell output can have color.
                   (defaults to on)

  --[no-]prefix    Specifies if shell output is prefixed by the task name.
                   (defaults to on)

  --log-level      The log level at which task output is printed to the shell
                   [all, finest, finer, fine, config, info (default), severe, shout, off]

See 'hop help <task>' for more information on a specific command.
''';

const _GOOD_TASK_NO_PARAMS_OUTPUT = '''usage: hop [<hop-options>] <task> [<task-options>] [--] [<task-args>]

Tasks:
  good   Just a nice task
  help   Print help information about available tasks

Hop options:
  --[no-]color     Specifies if shell output can have color.
                   (defaults to on)

  --[no-]prefix    Specifies if shell output is prefixed by the task name.
                   (defaults to on)

  --log-level      The log level at which task output is printed to the shell
                   [all, finest, finer, fine, config, info (default), severe, shout, off]

See 'hop help <task>' for more information on a specific command.
''';
