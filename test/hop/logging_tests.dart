library test.hop.logging;

import 'dart:async';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {

  test('hop event equality', () {
    var he1 = new HopEvent(Level.INFO, 'test', source: ['test', 'test']);
    var he1a = new HopEvent(Level.INFO, 'test', source: ['test', 'test']);

    expect(he1, equals(he1));
    expect(he1, same(he1));

    expect(he1a, equals(he1));
    expect(he1a, isNot(same(he1)));

    var he2 = new HopEvent(Level.INFO, 'test', source: ['test']);
    var he2a = new HopEvent(Level.INFO, 'test2', source: ['test', 'test']);
    var he2b = new HopEvent(Level.CONFIG, 'test', source: ['test', 'test']);
    var he2c = new HopEvent(Level.CONFIG, 'test3', source: ['another']);

    for(var he in [he2, he2a, he2b, he2c]) {
      expect(he, equals(he));
      expect(he, isNot(equals(he1)));
      expect(he, isNot(equals(he1a)));
    }
  });

  test('basic logging test', () {

    var records = <HopEvent>[];

    var task = new Task((ctx) {
      ctx.severe('info');
      print('print');
    });

    return runTaskInTestRunner(task, eventLog: records,
        printAtLogLevel: Level.SEVERE)
        .then((RunResult result) {
          expect(result, same(RunResult.SUCCESS));

          records.removeWhere((e) => e.level <= Level.FINE);

          expect(records, orderedEquals(
              [new HopEvent(Level.SEVERE, 'info', source: [TEST_TASK_NAME]),
               new HopEvent(Level.SEVERE, 'print', source: [TEST_TASK_NAME])]));
        });
  });


  void _testLogger(String name, TaskLogger getLogThing(String name, ctx)) {

    test(name, () {

      var records = <HopEvent>[];

      var task = new Task((TaskContext ctx) {
        ctx.info('info');

        var subLogger = getLogThing('sub', ctx);
        subLogger.warning('sub warn');

        var subsub = getLogThing('subsub', subLogger);
        subsub.severe('subsub severe');

        ctx.severe('severe');
      });

      return runTaskInTestRunner(task, eventLog: records, throwTaskExceptions: true)
          .then((RunResult result) {
            expect(result, same(RunResult.SUCCESS));

            records.removeWhere((e) => e.level <= Level.FINE);

            expect(records, orderedEquals(
                [new HopEvent(Level.INFO, 'info', source: [TEST_TASK_NAME]),
                 new HopEvent(Level.WARNING, 'sub warn', source: [TEST_TASK_NAME, 'sub']),
                 new HopEvent(Level.SEVERE, 'subsub severe', source: [TEST_TASK_NAME, 'sub', 'subsub']),
                 new HopEvent(Level.SEVERE, 'severe', source: [TEST_TASK_NAME])]));
          });
    });

    test('$name - parent disposes child', () {

      var records = <HopEvent>[];

      TaskContext ctx;
      TaskLogger subLogger;
      TaskLogger subsub;

      var task = new Task((TaskContext val) {
        ctx = val;
        ctx.info('info');

        subLogger = getLogThing('sub', ctx);
        subLogger.warning('sub warn');

        subsub = getLogThing('subsub', subLogger);
        subsub.severe('subsub severe');

        ctx.severe('severe');
      });

      return runTaskInTestRunner(task, eventLog: records, throwTaskExceptions: true)
          .then((RunResult result) {
            expect(result, same(RunResult.SUCCESS));

            expect(ctx.isDisposed, isTrue);
            expect(() => ctx.info('test'), throwsStateError);

            expect(subLogger.isDisposed, isTrue);
            expect(() => subLogger.info('test'), throwsStateError);

            expect(subsub.isDisposed, isTrue);
            expect(() => subsub.info('test'), throwsStateError);
          });
      });
  }

  _testLogger('sub-logging', (name, ctx) => ctx.getSubLogger(name));
  _testLogger('sub-context', (name, ctx) => ctx.getSubContext(name));

}
