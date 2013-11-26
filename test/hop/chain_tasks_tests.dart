library test.hop.chain;

import 'package:hop/hop_core.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {
    test('chain tasks - success', () {

    var log = [];

    var t1 = _getTask('t1', log);
    var t2 = _getTask('t2', log);
    var t3 = _getTask('t3', log);

    var task = t1.chain("t1").
        and("t2", t2).
        and("t3", t3);

    expect(task is Task, isTrue);

    return runTaskInTestRunner(task)
        .then((RunResult result) {
          expect(result.success, isTrue);
          expect(log, ['t1', 't2', 't3']);
        });
  });

  test('chain tasks - fail', () {

    var log = [];

    var t1 = _getTask('t1', log, false);
    var t2 = _getTask('t2', log);
    var t3 = _getTask('t3', log);

    var task = t1.chain("t1").
        and("t2", t2).
        and("t3", t3);

    expect(task is Task, isTrue);

    return runTaskInTestRunner(task)
        .then((RunResult result) {
          expect(result.exitCode, RunResult.FAIL.exitCode);
          expect(log, []);
        });
  });

  test('chain tasks - error', () {

    var log = [];

    var t1 = _getTask('t1', log);
    var t2 = _getTask('t2', log, null);
    var t3 = _getTask('t3', log);

    var task = t1.chain("t1").
        and("t2", t2).
        and("t3", t3);

    expect(task is Task, isTrue);

    return runTaskInTestRunner(task)
        .then((RunResult result) {
          expect(result.exitCode, RunResult.EXCEPTION.exitCode);
          expect(log, ['t1']);
        });
  });
}

Task _getTask(String str, List<String> log, [bool shouldSucceed = true]) {
  return new Task((TaskContext ctx) {
    if(shouldSucceed == null) throw 'foo!';
    if(shouldSucceed == false) ctx.fail("fail!");
    log.add(str);
  });
}
