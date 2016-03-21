library test.hop_tasks.compiler;

import 'dart:async';

import 'package:bot_io/bot_io.dart';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_tasks/compiler.dart';
import 'package:path/path.dart' as pathos;
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  [CompilerTargetType.DART, CompilerTargetType.JS].forEach((targetType) {
    group(targetType.toString(), () {
      test('good input', () {
        return _testCompiler(_GOOD_TEST_CONTENT, targetType, RunResult.SUCCESS);
      });

      test('bad input', () {
        return _testCompiler(
            _BAD_TEST_CONTENT, targetType, RunResult.EXCEPTION);
      });
    });
  });
}

Future _testCompiler(
    String contents, CompilerTargetType target, RunResult expectedResult) {
  TempDir tmpDir;
  Task task;

  final sourceDirMap = {'main.dart': contents};

  List<String> sources;

  return TempDir.create().then((TempDir value) {
    tmpDir = value;

    return tmpDir.populate(sourceDirMap);
  }).then((TempDir value) {
    assert(value == tmpDir);

    sources = [pathos.join(tmpDir.path, 'main.dart')];

    task = createDartCompilerTask(sources, outputType: target);

    return runTaskInTestRunner(task);
  }).then((RunResult result) {
    expect(result, expectedResult);

    return tmpDir.dir.list().toList();
  }).then((list) {
    var entityNames = list.map((e) => e.path).toList();

    var outFiles = _getOutputFiles(sources, target, expectedResult.success);

    expect(entityNames, unorderedEquals(outFiles));
  }).whenComplete(() {
    if (tmpDir != null) {
      tmpDir.dispose();
    }
  });
}

Set<String> _getOutputFiles(
    List<String> inputFiles, CompilerTargetType type, bool expectSuccess) {
  var outputFiles = new Set<String>();

  inputFiles.forEach((inFile) {
    outputFiles.add(inFile);

    if (expectSuccess) {
      if (type == CompilerTargetType.JS) {
        var newName = inFile + '.js';

        outputFiles.add(newName);
        outputFiles.add(newName + '.deps');
        outputFiles.add(newName + '.map');
      } else {
        assert(type == CompilerTargetType.DART);
        assert(inFile.endsWith('.dart'));
        var newName = inFile.substring(0, inFile.length - 5) + '.compiled.dart';
        outputFiles.add(newName);
        outputFiles.add(newName + '.deps');
      }
    }
  });

  return outputFiles;
}

const _GOOD_TEST_CONTENT = 'main() { print("hello, world!"); }';
const _BAD_TEST_CONTENT = 'main() { print("hello, world!") }';
