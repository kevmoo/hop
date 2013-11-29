library test.hop.sync;

import 'package:hop/src/hop_runner.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {

  // TODO: move this to a different test file
  test('HopConfig: registry cannot be null', () {
    expect(() => runRegistry(null, []), throwsArgumentError);
  });

  // TODO: move this to a different test file
  test('HopConfig: args cannot be null', () {
    var reg = new TaskRegistry();
    expect(() => runRegistry(reg, null), throwsArgumentError);
  });
}
