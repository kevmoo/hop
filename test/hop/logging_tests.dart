library test.hop.logging;

import 'dart:async';
import 'package:hop/hop_core.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {

  List<LogRecord> records;
  StreamSubscription sub;

  setUp(() {
    assert(records == null);
    assert(sub == null);

    records = new List<LogRecord>();
    sub = Logger.root.onRecord
        .where((LogRecord lr) => lr.loggerName == testLogger.fullName)
        .listen(records.add);
  });

  tearDown(() {
    var cancelThing = sub.cancel();
    expect(cancelThing, isNull);
    sub = null;
    records = null;
  });

  test('basic logging test', () {

    var task = new Task((ctx) {
      ctx.info('info');
      print('print');
    });

    return runTaskInTestRunner(task)
        .then((RunResult result) {
          expect(result, same(RunResult.SUCCESS));
          expect(records, everyElement((e) => e.level == Level.INFO));
          expect(records.map((e) => e.message),
              ['test-task: info',
               'test-task: print']);
        });
  });


  void _testLogger(String name, TaskLogger getLogThing(String name, ctx)) {

    test(name, () {

      var task = new Task((TaskContext ctx) {
        ctx.info('info');

        var subLogger = getLogThing('sub', ctx);
        subLogger.warning('sub warn');

        var subsub = getLogThing('subsub', subLogger);
        subsub.severe('subsub severe');

        ctx.severe('info');
      });

      return runTaskInTestRunner(task)
          .then((RunResult result) {
            expect(result, same(RunResult.SUCCESS));

            expect(records, everyElement((e) => e.level == Level.INFO));
            expect(records.map((e) => e.message),
                ['test-task: info',
                 'test-task - sub: sub warn',
                 'test-task - sub - subsub: subsub severe',
                 'test-task: info']);
          });
    });

    test('$name - parent disposes child', () {

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

        ctx.severe('info');
      });

      return runTaskInTestRunner(task)
          .then((RunResult result) {
            expect(result, same(RunResult.SUCCESS));

            expect(records, everyElement((e) => e.level == Level.INFO));
            expect(records.map((e) => e.message),
                ['test-task: info',
                 'test-task - sub: sub warn',
                 'test-task - sub - subsub: subsub severe',
                 'test-task: info']);

            expect(ctx.isDisposed, isTrue);
            expect(subLogger.isDisposed, isTrue);
            expect(subsub.isDisposed, isTrue);
          });
      });
  }

  _testLogger('sub-logging', (name, ctx) => ctx.getSubLogger(name));
  _testLogger('sub-context', (name, ctx) => ctx.getSubContext(name));

}
