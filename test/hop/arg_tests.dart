library test.hop.args;

import 'dart:async';
import 'package:args/args.dart';
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

  // providing an arg populator is fine, but deprecated

  test('provide a "config" for ArgParser', () {

    var task = new Task((TaskContext ctx) {
      expect(ctx.arguments['foo'], true);
    }, config: (ArgParser parser) {
      parser.addFlag('foo', defaultsTo: false);
    });

    return runTaskInTestRunner(task, extraArgs: ['--foo'])
        .then((RunResult rr) {
          expect(rr, RunResult.SUCCESS);
        });
  });

  test('provide a parser for ArgParser', () {
    var parser = new ArgParser()
      ..addFlag('foo', defaultsTo: false);

    var task = new Task((TaskContext ctx) {
      expect(ctx.arguments['foo'], true);
    }, argParser: parser);

    return runTaskInTestRunner(task, extraArgs: ['--foo'])
        .then((RunResult rr) {
          expect(rr, RunResult.SUCCESS);
        });
  });

  test('provide a parser and parser config - throws', () {
    expect(() => new Task(noopTaskRunner, argParser: new ArgParser(),
        config: (ArgParser parser) {}), throwsArgumentError);
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
