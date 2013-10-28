library test.hop.logging;

import 'dart:async';
import 'package:hop/hop.dart';
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

  test('foo', () {

    var task = new Task.async((ctx) {
      ctx.info('info');
      print('print');
    });

    return runTaskInTestRunner(task)
        .then((RunResult result) {
          expect(result, same(RunResult.SUCCESS));

          expect(records, hasLength(2));

          expect(records[0].level, Level.INFO);
          expect(records[0].message, 'test-task: info');

          expect(records[1].level, Level.INFO);
          expect(records[1].message, 'test-task: print');
        });
  });

}
