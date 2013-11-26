library test.hop.async;

import 'dart:async';
import 'package:hop/hop_core.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {
    test('null result is fine' , _testNullResult);
    test('exception outside future' , _testException);
}

Future _testNullResult() {
    return _testSimpleAsyncTask((ctx) => null)
        .then((value) {
          expect(value, RunResult.SUCCESS);
        });
  }

Future _testException() {
    return _testSimpleAsyncTask((ctx) {
        throw 'not impld';
      }).then((value) {
        expect(value, RunResult.EXCEPTION);
      });
  }

Future<RunResult> _testSimpleAsyncTask(Future taskFuture(TaskContext ctx)) {
    return runTaskInTestRunner(new Task(taskFuture));
  }
