part of test_hop;

class ChainTasksTests {
  static void register() {
    test('chain tasks', () {

      var t1 = _getTask('t1');
      var t2 = _getTask('t2');
      var t3 = _getTask('t3');

      var task = t1.chain("t1").
          and("t2", t2).
          and("t3", t3);

      expect(task is Task, isTrue);

      return runTaskInTestRunner(task)
          .then((RunResult result) {
            expect(result, isNotNull);
          });
    });

  }

  static Task _getTask(String str) {
    return new Task.async((ctx) {
      ctx.info(str);
      return true;
    });
  }
}
