part of test_hop_tasks;

// TODO: test error cases w/ bad input names or mappers
// TODO: test mappers

class CompilerTests {
  static void register() {
    group('compiler', () {
      [CompilerTargetType.DART, CompilerTargetType.JS].forEach((targetType) {

        group(targetType.toString(), (){

          test('good input', () {
            return _testCompiler(_goodTestFile, targetType, RunResult.SUCCESS);
          });

          test('bad input', () {
            return _testCompiler(_badTestFile, targetType, RunResult.FAIL);
          });
        });

      });
    });
  }

  static Future _testCompiler(String contents, CompilerTargetType target,
                              RunResult expectedResult) {
    TempDir tmpDir;
    Task task;

    final sourceDirMap = {
      'main.dart' : contents
    };

    List<String> sources;

    return TempDir.create()
        .then((TempDir value) {
          tmpDir = value;

          final populater = new MapDirectoryPopulater(sourceDirMap);
          return tmpDir.populate(populater);
        })
        .then((TempDir value) {
          assert(value == tmpDir);

          sources = [pathos.join(tmpDir.path, 'main.dart')];

          task = createDartCompilerTask(sources, outputType: target);

          return runTaskInTestRunner(task);

        })
        .then((RunResult result) {
          expect(result, expectedResult);

          return tmpDir.dir.list().toList();
        })
        .then((list) {
          var entityNames = list.map((e) => e.path).toList();

          var outFiles = _getOutputFiles(sources, target,
              expectedResult.success);

          expect(entityNames, unorderedEquals(outFiles));
        })
        .whenComplete(() {
          if(tmpDir != null) {
            tmpDir.dispose();
          }
        });
  }
}

List<String> _getOutputFiles(List<String> inputFiles, CompilerTargetType type,
    bool expectSuccess) {
  var outputFiles = new List<String>();

  inputFiles.forEach((inFile) {
    outputFiles.add(inFile);

    if(expectSuccess) {
      if(type == CompilerTargetType.JS) {
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

const _goodTestFile = 'main() { print("hello, world!"); }';
const _badTestFile = 'ain() { print("hello, world!"); }';
