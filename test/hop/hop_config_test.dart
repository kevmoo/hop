import 'package:hop/src/hop_runner.dart';
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  test('HopConfig: registry cannot be null', () {
    expect(() => runRegistry(null, []), throwsArgumentError);
  });

  test('HopConfig: args cannot be null', () {
    var reg = new TaskRegistry();
    expect(() => runRegistry(reg, null), throwsArgumentError);
  });
}
