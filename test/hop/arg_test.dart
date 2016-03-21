import 'package:args/args.dart';
import 'package:hop/hop_core.dart';
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  test('simple args', () {
    final task = _makeSimpleTask();
    return runTaskInTestRunner(task, extraArgs: ['hello', 'args'])
        .then((RunResult result) {
      expect(result, RunResult.SUCCESS);
    });
  });

  test('provide a parser for ArgParser', () {
    var parser = new ArgParser()..addFlag('foo', defaultsTo: false);

    var task = new Task((TaskContext ctx) {
      expect(ctx.arguments['foo'], true);
    }, argParser: parser);

    return runTaskInTestRunner(task, extraArgs: ['--foo']).then((RunResult rr) {
      expect(rr, RunResult.SUCCESS);
    });
  });
}

Task _makeSimpleTask() => new Task((ctx) {
      final args = ctx.arguments.rest;
      expect(args.length, 2);
      expect(args[0], 'hello');
      expect(args[1], 'args');
      return true;
    });
