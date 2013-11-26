library test.hop.args;

import 'dart:async';
import 'package:hop/hop_core.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {
  test('simple args', () {

    final task = _makeSimpleTask();
    return runTaskInTestRunner(task, extraArgs: ['hello', 'args'])
        .then((RunResult result) {
          expect(result, RunResult.SUCCESS);
        });
  });
}


Task _makeSimpleTask() =>
  new Task((ctx) {
    final args = ctx.arguments.rest;
    expect(args.length, 2);
    expect(args[0], 'hello');
    expect(args[1], 'args');
    return true;
  });
