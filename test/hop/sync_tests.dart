library test.hop.sync;

import 'dart:async';
import 'package:hop/hop_core.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

// TODO: test output using new TestRunner

void main() {
  test('true result is cool', _testTrueIsCool);
  test('false result cool', _testFalseIsFail);
  test('null result is cool', _testNullIsSad);
  test('exception is sad', _testExceptionIsSad);
  test('bad task name', _testBadParam);
  test('no task name', _testNoParam);
  test('no tasks defined', _testNoTasks);
  test('ctx.fail', _testCtxFail);
}

Future _testCtxFail() {
  return _testSimpleSyncTask((ctx) => ctx.fail('fail!'))
    .then((value) {
      expect(value, RunResult.FAIL);
    });
}

Future _testTrueIsCool() {
  return _testSimpleSyncTask((ctx) => true).then((value) {
    expect(value, RunResult.SUCCESS);
  });
}

Future _testFalseIsFail() {
  return _testSimpleSyncTask((ctx) => false).then((value) {
    expect(value, RunResult.SUCCESS);
  });
}

Future _testNullIsSad() {
  return _testSimpleSyncTask((ctx) => null).then((value) {
    expect(value, RunResult.SUCCESS);
  });
}

Future _testExceptionIsSad() {
  return _testSimpleSyncTask((ctx) {
      throw 'sorry';
    })
    .then((value) {
      expect(value, RunResult.EXCEPTION);
    });
}

Future _testBadParam() {
  final taskConfig = new TaskRegistry();
  taskConfig.addSync('good', (ctx) => true);

  return runRegistry(taskConfig, ['bad'])
      .then((value) {
        expect(value, RunResult.BAD_USAGE);
        // TODO: test that proper error message is printed
      });
}

Future _testNoParam() {
  final taskConfig = new TaskRegistry();
  taskConfig.addSync('good', (ctx) => true);

  return runRegistry(taskConfig, [])
      .then((value) {
        expect(value, RunResult.SUCCESS);
        // TODO: test that task list is printed
      });
}

Future _testNoTasks() {
  final taskConfig = new TaskRegistry();

  return runRegistry(taskConfig, [])
      .then((value) {
        expect(value, RunResult.SUCCESS);
      });
}

Future<RunResult> _testSimpleSyncTask(dynamic taskFunc(TaskContext ctx)) {
  return runTaskInTestRunner(new Task(taskFunc));
}
