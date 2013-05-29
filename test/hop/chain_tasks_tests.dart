part of test_hop;

class ChainTasksTests {
  static void register() {
    test('chain tasks - success', () {

      var t1 = _getTask('t1');
      var t2 = _getTask('t2');
      var t3 = _getTask('t3');

      var task = t1.chain("t1").
          and("t2", t2).
          and("t3", t3);

      expect(task is Task, isTrue);

      return runTaskInTestRunner(task)
          .then((RunResult result) {
            expect(result.success, isTrue);
          });
    });

    test('chain tasks - fail', () {

      var t1 = _getTask('t1', false);
      var t2 = _getTask('t2');
      var t3 = _getTask('t3');

      var task = t1.chain("t1").
          and("t2", t2).
          and("t3", t3);

      expect(task is Task, isTrue);

      return runTaskInTestRunner(task)
          .then((RunResult result) {
            expect(result.exitCode, RunResult.FAIL.exitCode);
          });
    });

    test('chain tasks - error', () {

      var t1 = _getTask('t1');
      var t2 = _getTask('t2', null);
      var t3 = _getTask('t3');

      var task = t1.chain("t1").
          and("t2", t2).
          and("t3", t3);

      expect(task is Task, isTrue);

      return runTaskInTestRunner(task)
          .then((RunResult result) {
            expect(result.exitCode, RunResult.ERROR.exitCode);
          });
    });
  }

  static Task _getTask(String str, [bool shouldSucceed = true]) {
    return new Task.async((ctx) {
      ctx.info(str);
      return shouldSucceed;
    });
  }
}
