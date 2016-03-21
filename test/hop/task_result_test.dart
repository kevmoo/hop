library test.hop.sync;

import 'dart:async';

import 'package:args/args.dart';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
import 'package:test/test.dart';

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

  test('help for a task', () {
    var task = _getGoodTask();

    var taskReg = new TaskRegistry();
    taskReg.addTask('good', task);

    return runRegistryShell(taskReg, ['--no-color', 'help', 'good'])
        .then((RunShellOutput value) {
      expect(value.runResult, RunResult.SUCCESS);
      expect(value.printOutput, startsWith(_GOOD_HELP_OUTPUT));
    });
  });

  test('using context after task completes', () {
    TaskContext ctx;

    return runTaskInTestRunner((val) {
      ctx = val;
    }).then((RunResult rr) {
      expect(rr, RunResult.SUCCESS);
      expect(() => ctx.config('this should not work'), throwsStateError);
    });
  });
}

Future _testCtxFail() =>
    runTaskInTestRunner((ctx) => ctx.fail('fail!')).then((value) {
      expect(value, RunResult.FAIL);
    });

Future _testTrueIsCool() => runTaskInTestRunner((ctx) => true).then((value) {
      expect(value, RunResult.SUCCESS);
    });

Future _testFalseIsFail() => runTaskInTestRunner((ctx) => false).then((value) {
      expect(value, RunResult.SUCCESS);
    });

Future _testNullIsFine() => runTaskInTestRunner((ctx) => null).then((value) {
      expect(value, RunResult.SUCCESS);
    });

Future _testExceptionIsSad() => runTaskInTestRunner((ctx) {
      throw 'sorry';
    }).then((value) {
      expect(value, RunResult.EXCEPTION);
    });

Future _testBadParam() {
  final taskReg = new TaskRegistry();
  taskReg.addTask('good', _getGoodTask());

  return runRegistry(taskReg, ['bad']).then((value) {
    expect(value, RunResult.BAD_USAGE);
    // TODO: test that proper error message is printed
  });
}

Future _testNoParam() {
  final taskReg = new TaskRegistry();
  taskReg.addTask('good', _getGoodTask());

  return runRegistryShell(taskReg, ['--no-color']).then((RunShellOutput value) {
    expect(value.runResult, RunResult.SUCCESS);
    expect(value.printOutput, startsWith(_GOOD_TASK_NO_PARAMS_OUTPUT));
  });
}

Future _testNoTasks() {
  final taskReg = new TaskRegistry();

  return runRegistryShell(taskReg, ['--no-color']).then((RunShellOutput value) {
    expect(value.runResult, RunResult.SUCCESS);
    expect(value.printOutput, startsWith(_NO_TASK_NO_PARAMS_OUTPUT));
  });
}

Task _getGoodTask() => new Task(noopTaskRunner,
        description: 'Just a nice task',
        argParser: new ArgParser()
          ..addFlag('foo',
              abbr: 'f',
              help: 'The foo flag',
              defaultsTo: true,
              negatable: true)
          ..addOption('bar',
              abbr: 'b',
              help: 'the bar flag',
              allowed: ['a', 'b', 'c'],
              defaultsTo: 'b',
              allowMultiple: true),
        extendedArgs: [
          new TaskArgument('ta-first', required: true),
          new TaskArgument('ta-second'),
          new TaskArgument('ta-third', multiple: true)
        ]);

const _GOOD_HELP_OUTPUT =
    '''usage: hop [<hop-options>] good [<good-options>] <ta-first> [<ta-second>] [<ta-third>...]

  Just a nice task

good options:
  -f, --[no-]foo    The foo flag
                    (defaults to on)

  -b, --bar         the bar flag
                    [a, b (default), c]

Hop options:
''';

const _NO_TASK_NO_PARAMS_OUTPUT =
    '''usage: hop [<hop-options>] <task> [<task-options>] [--] [<task-args>]

Tasks:
  help   Print help information about available tasks

Hop options:
''';

const _GOOD_TASK_NO_PARAMS_OUTPUT =
    '''usage: hop [<hop-options>] <task> [<task-options>] [--] [<task-args>]

Tasks:
  good   Just a nice task
  help   Print help information about available tasks

Hop options:
''';
