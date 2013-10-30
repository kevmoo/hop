library test.hop.add_task;

import 'dart:async';
import 'package:hop/hop.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {

  test('old addAsync', () {
    var reg = new TaskRegistry();

    bool ran = false;

    reg.addAsync('foo', (ctx) {
      return new Future(() => ran = true);
    }, description: 'async foo');

    return runRegistry(reg, ['foo'])
        .then((RunResult rr) {
          expect(rr, RunResult.SUCCESS);
          expect(ran, isTrue);
        });
  });

  test('old addSsync', () {
    var reg = new TaskRegistry();

    bool ran = false;

    reg.addSync('foo', (ctx) {
      ran = true;
    }, description: 'sync foo');

    return runRegistry(reg, ['foo'])
        .then((RunResult rr) {
          expect(rr, RunResult.SUCCESS);
          expect(ran, isTrue);
        });
  });

  test('addTask', () {
    var reg = new TaskRegistry();

    bool ran = false;

    reg.addTask('foo', new Task((ctx) => ran = true));

    return runRegistry(reg, ['foo'])
        .then((RunResult rr) {
          expect(rr, RunResult.SUCCESS);
          expect(ran, isTrue);
        });
  });

  test('addTask with sync closure', () {
    var reg = new TaskRegistry();

    bool ran = false;

    reg.addTask('foo', (TaskContext ctx) => ran = true);

    return runRegistry(reg, ['foo'])
        .then((RunResult rr) {
          expect(rr, RunResult.SUCCESS);
          expect(ran, isTrue);
        });
  });

  test('addTask with async closure', () {
    var reg = new TaskRegistry();

    bool ran = false;

    reg.addTask('foo', (TaskContext ctx) =>
        new Future(() => ran = true));

    return runRegistry(reg, ['foo'])
        .then((RunResult rr) {
          expect(rr, RunResult.SUCCESS);
          expect(ran, isTrue);
        });
  });
}
