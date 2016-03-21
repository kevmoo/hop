import 'package:hop/src/stats.dart';
import 'package:test/test.dart';

void main() {
  test('basics', () {
    var stats = new Stats([10, 20, 30, 40, 50]);

    expect(stats.min, 10);
    expect(stats.max, 50);
    expect(stats.count, 5);
    expect(stats.mean, 30);
    expect(stats.median, 30);

    expect(stats.standardDeviation, closeTo(14.1, 0.1));
    expect(stats.standardError, closeTo(6.3, 0.1));
  });
}
