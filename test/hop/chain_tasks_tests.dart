library test.hop.chain;

import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
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

  test('chain tasks, via registry', () {

    var reg = new TaskRegistry();

    var log = [];

    reg.addTask('t1', _getTask('t1', log));
    reg.addTask('t2', _getTask('t2', log));
    reg.addTask('t3', _getTask('t3', log));

    var chained = reg.addChainedTask('chained', ['t1', 't2', 't3']);

    expect(chained is Task, isTrue);

    return runRegistry(reg, ['chained'])
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

    expect(task.description, 'Chained Task');

    expect(task is Task, isTrue);

    return runTaskInTestRunner(task)
        .then((RunResult result) {
          expect(result.exitCode, RunResult.EXCEPTION.exitCode);
          expect(log, ['t1']);
        });
  });

  test('description', () {
    var reg = new TaskRegistry();

    reg.addTask('one', (ctx) {});
    reg.addTask('two', (ctx) {});
    reg.addTask('three', (ctx) {});

    var chained1 = reg.addChainedTask('chained1', ['one', 'two', 'three']);
    expect(chained1.description, 'Chained Task: one, two, three');

    var chained2 = reg.addChainedTask('chained2', ['one', 'two', 'three'],
        description: 'override');
    expect(chained2.description, 'override');
  });

  test('missing task', () {
    var reg = new TaskRegistry();

    expect(() {
      reg.addChainedTask('oops', ['nope']);
    }, throwsA((errorObj) {
      return errorObj.toString()
          .contains('The task "nope" has not be registered');
    }));
  });
}

Task _getTask(String str, List<String> log, [bool shouldSucceed = true]) {
  return new Task((TaskContext ctx) {
    if(shouldSucceed == null) throw 'foo!';
    if(shouldSucceed == false) ctx.fail("fail!");
    log.add(str);
  });
}
