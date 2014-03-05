library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:unittest/unittest.dart';

void main(List<String> args) {
  addTask('test_with_arg', createUnitTestTask(_testWithConfigArg));
  addTask('test_without_arg', createUnitTestTask(_testWithoutConfig));

  runHop(args, paranoid: false);
}

void _testWithConfigArg(Configuration config) {
  unittestConfiguration = config;

  _testWithoutConfig();
}

void _testWithoutConfig() {
  test('sample', () {
    expect(true, isTrue);
  });
}
