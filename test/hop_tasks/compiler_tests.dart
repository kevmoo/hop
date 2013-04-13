part of test_hop_tasks;

class CompilerTests {
  static void register() {
    group('compiler', () {
      group('dart2js', () {
        test('good input', () {
          return _testCompiler(_goodTestFile, RunResult.SUCCESS);
        });

        test('bad input', () {
          return _testCompiler(_badTestFile, RunResult.FAIL);
        });

      });
    });
  }

  static Future _testCompiler(String contents, RunResult expectedResult) {
    TempDir tmpDir;
    Task task;

    final sourceDirMap = {
      'main.dart' : contents
    };

    return TempDir.create()
        .then((TempDir value) {
          tmpDir = value;

          final populater = new MapDirectoryPopulater(sourceDirMap);
          return tmpDir.populate(populater);
        })
        .then((TempDir value) {
          assert(value == tmpDir);

          final sources = [pathos.join(tmpDir.path, 'main.dart')];

          task = createDart2JsTask(sources);

          return runTaskInTestRunner(task);

        })
        .then((RunResult result) {
          expect(result, expectedResult);

          // TODO: actually verify the contents of the output directory, too
        })
        .whenComplete(() {
          if(tmpDir != null) {
            tmpDir.dispose();
          }
        });
  }
}

const _goodTestFile = 'main() { print("hello, world!"); }';
const _badTestFile = 'ain() { print("hello, world!"); }';
