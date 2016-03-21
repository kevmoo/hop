library test.hop.extended_args;

import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  group('parseExtendedArgs', () {
    Task task;

    group('no extended args, no problem', () {
      setUp(() {
        task = new Task(noopTaskRunner);
      });

      test('none, fine', () {
        var map = task.parseExtendedArgs([]);
        expect(map, isEmpty);
      });

      test('some is fine', () {
        var map = task.parseExtendedArgs(['a', 'b', 'c']);
        expect(map, isEmpty);
      });

      test('empty is fine', () {
        expect(() => task.parseExtendedArgs([]), returnsNormally);
      });

      test('null is bad', () {
        expect(() => task.parseExtendedArgs(null), throwsArgumentError);
      });

      test('null item is bad', () {
        expect(() => task.parseExtendedArgs([null]), throwsArgumentError);
      });
    });

    group('optional, with multiple', () {
      setUp(() {
        task = new Task(noopTaskRunner, extendedArgs: [
          new TaskArgument('first'),
          new TaskArgument('second'),
          new TaskArgument('thirds', multiple: true)
        ]);
      });

      test('success', () {
        var map = task.parseExtendedArgs(['1st', '2nd', '3rd-a', '3rd-b']);

        expect(map.keys, orderedEquals(['first', 'second', 'thirds']));
        expect(map['first'], '1st');
        expect(map['second'], '2nd');
        expect(map['thirds'], orderedEquals(['3rd-a', '3rd-b']));
      });

      test('too few is fine', () {
        var map = task.parseExtendedArgs(['1st']);

        expect(map.keys, orderedEquals(['first', 'second', 'thirds']));
        expect(map['first'], '1st');
        expect(map['second'], isNull);
        expect(map['thirds'], isEmpty);
      });
    });

    group('optional, no multiple', () {
      setUp(() {
        task = new Task(noopTaskRunner, extendedArgs: [
          new TaskArgument('first'),
          new TaskArgument('second'),
          new TaskArgument('thirds')
        ]);
      });

      test('success', () {
        var map = task.parseExtendedArgs(['1st', '2nd', '3rd']);

        expect(map.keys, orderedEquals(['first', 'second', 'thirds']));
        expect(map['first'], '1st');
        expect(map['second'], '2nd');
        expect(map['thirds'], '3rd');
      });

      test('too few is fine', () {
        var map = task.parseExtendedArgs(['1st']);

        expect(map.keys, orderedEquals(['first', 'second', 'thirds']));
        expect(map['first'], '1st');
        expect(map['second'], isNull);
        expect(map['thirds'], isNull);
      });

      test('too many is bad', () {
        try {
          task.parseExtendedArgs(['1st', '2rd', '3rd', '4th']);
          fail("should throw");
        } catch (ex) {
          if (ex is! FormatException) rethrow;
          expect(ex.message, 'Expected 3 argument(s); received 4');
        }
      });
    });

    group('required, with multiple', () {
      setUp(() {
        task = new Task(noopTaskRunner, extendedArgs: [
          new TaskArgument('first', required: true),
          new TaskArgument('second', required: true),
          new TaskArgument('thirds', required: true, multiple: true)
        ]);
      });

      test('success', () {
        var map = task.parseExtendedArgs(['1st', '2nd', '3rd-a', '3rd-b']);

        expect(map.keys, orderedEquals(['first', 'second', 'thirds']));
        expect(map['first'], '1st');
        expect(map['second'], '2nd');
        expect(map['thirds'], orderedEquals(['3rd-a', '3rd-b']));
      });

      test('too few is bad', () {
        try {
          task.parseExtendedArgs(['1st', '2rd']);
          fail("should throw");
        } catch (ex) {
          if (ex is! FormatException) rethrow;
          expect(ex.message, 'Expected 3 argument(s); received 2');
        }
      });
    });

    group('required, without multiple', () {
      setUp(() {
        task = new Task(noopTaskRunner, extendedArgs: [
          new TaskArgument('first', required: true),
          new TaskArgument('second', required: true),
          new TaskArgument('thirds')
        ]);
      });

      test('success', () {
        var map = task.parseExtendedArgs(['1st', '2nd', '3rd-a']);

        expect(map.keys, orderedEquals(['first', 'second', 'thirds']));
        expect(map['first'], '1st');
        expect(map['second'], '2nd');
        expect(map['thirds'], '3rd-a');
      });

      test('too few is bad', () {
        try {
          task.parseExtendedArgs(['1st']);
          fail("should throw");
        } catch (ex) {
          if (ex is! FormatException) rethrow;
          expect(ex.message, 'Expected 2 argument(s); received 1');
        }
      });

      test('too many is bad', () {
        try {
          task.parseExtendedArgs(['1st', '2rd', '3rd', '4th']);
          fail("should throw");
        } catch (ex) {
          if (ex is! FormatException) rethrow;
          expect(ex.message, 'Expected 3 argument(s); received 4');
        }
      });
    });
  });

  test('extended arg values in TaskContext', () {
    var task = new Task((TaskContext ctx) {
      expect(
          ctx.extendedArgs.keys, orderedEquals(['first', 'second', 'thirds']));
      expect(ctx.extendedArgs['first'], '1st');
      expect(ctx.extendedArgs['second'], '2nd');
      expect(ctx.extendedArgs['thirds'], ['3rd-a', '3rd-b']);
    }, extendedArgs: [
      new TaskArgument('first'),
      new TaskArgument('second'),
      new TaskArgument('thirds', multiple: true)
    ]);

    return runTaskInTestRunner(task,
        extraArgs: ['1st', '2nd', '3rd-a', '3rd-b'],
        throwTaskExceptions: true).then((RunResult rr) {
      expect(rr, RunResult.SUCCESS);
    });
  });

  test("missing an extended arg", () {
    var log = <HopEvent>[];

    var task = new Task(noopTaskRunner,
        extendedArgs: [new TaskArgument('first', required: true)]);

    return runTaskInTestRunner(task, eventLog: log).then((RunResult rr) {
      // TODO: check for helpful error message, too
      expect(rr, RunResult.BAD_USAGE);
    });
  });

  test('valid ctor args', () {
    final valid = ['a', 'a-b', 'a-cool-name', 'a7', 'b2b', 'a_b'];
    for (final v in valid) {
      expect(() => new TaskArgument(v), returnsNormally);
    }

    final invalid = [
      '',
      null,
      ' ',
      '-',
      'A',
      'a-',
      'a-B',
      'a ',
      'a b',
      '7',
      '7a'
    ];
    for (final v in invalid) {
      expect(() => new TaskArgument(v), throwsArgumentError);
    }

    expect(() => new TaskArgument('cool', required: null), throwsArgumentError);
    expect(() => new TaskArgument('cool', multiple: null), throwsArgumentError);
  });

  test('validate arg list', () {
    // empty is fine
    _validateExtendedArgs([], true);

    _validateExtendedArgs(null, false);

    // null arg is bad
    _validateExtendedArgs([null], false);

    // first required is fine
    _validateExtendedArgs([new TaskArgument('a', required: true)], true);

    // first required and mult is fine
    _validateExtendedArgs(
        [new TaskArgument('a', required: true, multiple: true)], true);

    // first required, second not required is fine
    _validateExtendedArgs([
      new TaskArgument('a', required: true),
      new TaskArgument('b', required: false)
    ], true);

    // first not required, second required is bad
    _validateExtendedArgs([
      new TaskArgument('a', required: false),
      new TaskArgument('b', required: true)
    ], false);

    // last multiple is fine
    _validateExtendedArgs([
      new TaskArgument('a', multiple: false),
      new TaskArgument('b', multiple: true)
    ], true);

    // 'N' multiple, 'N+1' non-multiple is not fine
    _validateExtendedArgs([
      new TaskArgument('a', multiple: true),
      new TaskArgument('b', multiple: false)
    ], false);

    // dupe names is not fine
    _validateExtendedArgs(
        [new TaskArgument('a'), new TaskArgument('a')], false);
  });
}

void _validateExtendedArgs(List<TaskArgument> args, bool isGood) {
  var matcher = isGood ? returnsNormally : throwsArgumentError;
  expect(() => TaskArgument.validateArgs(args), matcher);
}
