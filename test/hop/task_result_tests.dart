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
  taskReg.addTask('good', (ctx) => true);

  return runRegistry(taskReg, [])
      .then((value) {
        expect(value, RunResult.SUCCESS);
        // TODO: test that task list is printed
      });
}

Future _testNoTasks() {
  final taskReg = new TaskRegistry();

  return runRegistry(taskReg, [])
      .then((value) {
        expect(value, RunResult.SUCCESS);

        // TODO: show help value?
      });
}
