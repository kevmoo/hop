library test.hop_tasks.analyzer;

import 'dart:async';
import 'dart:io';

import 'package:bot_io/bot_io.dart';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_tasks/dartanalyzer.dart';
import 'package:path/path.dart' as pathos;
import 'package:test/test.dart';

import '../test_util.dart';

// TODO(kevmoo): figure out a way to validate output...

void main() {
  test('1 pass, 1 warn', () {
    final fileTexts = {
      "main1.dart": "void main() => print('hello bot');",
      "main2.dart": "void main() { String i = 42; }"
    };

    return _testAnalyzerTask(fileTexts, RunResult.SUCCESS);
  });

  test('failed file', () {
    final fileTexts = {"main.dart": "void main() => asdf { XXXX i = 42; }"};

    return _testAnalyzerTask(fileTexts, RunResult.FAIL);
  });

  test('1 pass, 1 warn, 1 error', () {
    final fileTexts = {
      "main1.dart": "void main() asdf { String i = 42; }",
      "main2.dart": "void main() asdf { String i = 42; }",
      "main3.dart": "void main() asdf { String i = 42; }"
    };

    return _testAnalyzerTask(fileTexts, RunResult.FAIL);
  });
}

Future _testAnalyzerTask(Map<String, String> inputs, RunResult expectedResult) {
  String path;
  return TempDir.then((Directory dir) {
    path = dir.path;
    return EntityPopulater
        .populate(path, inputs, leaveExistingDirs: true)
        .then((Directory value) {
      assert(value.path == path);

      var fullPaths = inputs.keys
          .map((e) => pathos.absolute(pathos.join(path, e)))
          .toList();

      final task = createAnalyzerTask(fullPaths);
      return runTaskInTestRunner(task);
    }).then((RunResult runResult) {
      expect(runResult, expectedResult);
    });
  });
}
