part of test_hop;

class AsyncTests {
  static void run() {
    test('null result is fine' , _testNullResult);
    test('exception outside future' , _testException);
  }

  static Future _testNullResult() {
    return _testSimpleAsyncTask((ctx) => null)
        .then((value) {
          expect(value, RunResult.SUCCESS);
        });
  }

  static Future _testException() {
    return _testSimpleAsyncTask((ctx) {
        throw 'not impld';
      }).then((value) {
        expect(value, RunResult.EXCEPTION);
      });
  }

  static Future<RunResult> _testSimpleAsyncTask(Future taskFuture(TaskContext ctx)) {
    return runTaskInTestRunner(new Task(taskFuture));
  }
}
