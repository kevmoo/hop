library hop.unittest_test;

import 'dart:io';

import 'package:hop/src/hop_tasks/process.dart';

import 'package:unittest/unittest.dart';

void main() {
  test('test method with config param', () {

    var stdout = new StringBuffer();
    var stderr = new StringBuffer();

    return Process.start('dart', [_TEST_RUNNER_PATH, 'test_with_arg'])
        .then((process) {
      return pipeProcess(process,stdOutWriter: stdout.writeln,
          stdErrWriter: stderr.writeln);
    }).then((status) {

      expect(status, 0);
      expect(stderr.isEmpty, isTrue);

      var out = stdout.toString();

      expect(out, contains('sample -- PASS'));
      expect(out, contains('1 PASSED, 0 FAILED, 0 ERRORS'));
    });
  });

}

const _TEST_RUNNER_PATH = 'test/hop_tasks/test_runners/'
  'test_unittest_runner.dart';
