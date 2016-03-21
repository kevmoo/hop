import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  test('chain tasks - success', () {
    var log = [];

    var reg = new TaskRegistry();

    reg.addTask('t5', _getTask('t5', log));
    reg.addTask('t2', _getTask('t2', log));
    reg.addTask('t1', _getTask('t1', log));
    reg.addTask('t3', _getTask('t3', log));
    reg.addTask('t4', _getTask('t4', log));

    var runOrder = const ['t1', 't2', 't3', 't4', 't5'];

    var task = reg.addChainedTask('chained', runOrder);

    expect(task.description, 'Chained Task: ${runOrder.join(', ')}');

    expect(task is Task, isTrue);

    return runRegistry(reg, ['chained']).then((RunResult result) {
      expect(result.success, isTrue);
      expect(log, runOrder);
    });
  });

  test('chain tasks - fail', () {
    var log = [];

    var reg = new TaskRegistry();

    reg.addTask('t1', _getTask('t1', log, false));
    reg.addTask('t2', _getTask('t2', log));
    reg.addTask('t3', _getTask('t3', log));

    var task = reg.addChainedTask('chained', ['t1', 't2', 't3']);

    expect(task.description, 'Chained Task: t1, t2, t3');

    expect(task is Task, isTrue);

    return runRegistry(reg, ['chained']).then((RunResult result) {
      expect(result.exitCode, RunResult.FAIL.exitCode);
      expect(log, []);
    });
  });

  test('chain tasks - error', () {
    var log = [];

    var reg = new TaskRegistry();

    reg.addTask('t2', _getTask('t2', log, null));
    reg.addTask('t1', _getTask('t1', log));
    reg.addTask('t3', _getTask('t3', log));

    var task = reg.addChainedTask('chained', ['t1', 't2', 't3']);

    expect(task.description, 'Chained Task: t1, t2, t3');

    expect(task is Task, isTrue);

    return runRegistry(reg, ['chained']).then((RunResult result) {
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
      return errorObj
          .toString()
          .contains('The task "nope" has not be registered');
    }));
  });
}

Task _getTask(String str, List<String> log, [bool shouldSucceed = true]) {
  return new Task((TaskContext ctx) {
    if (shouldSucceed == null) throw 'foo!';
    if (shouldSucceed == false) ctx.fail("fail!");
    log.add(str);
  });
}
