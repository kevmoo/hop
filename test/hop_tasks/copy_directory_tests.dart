part of test_hop_tasks;

/**
 * Test class for [copyDirectory] [Task].
 */
class CopyDirectoryTests {

  /**
   * Copy files from source directory to destination directory without errors.
   */
  static _copyDirectorySuccess() {
    final inputs = {"src/main1.dart": "void main() => print('hello bot');",
                    "src/main2.dart": "void main() { String i = 42; }"};
    final outputs = ["dest/main1.dart", "dest/main2.dart"];

    TempDir tempDirSrc;
    Path sourcePath, destinationPath;
    Directory sourceDir;
    return TempDir.create()
        .then((TempDir value) {
          tempDirSrc = value;
          sourcePath = new Path(tempDirSrc.path).join(new Path("src"));
          destinationPath = new Path(tempDirSrc.path).join(new Path("dest"));
          sourceDir = new Directory.fromPath(sourcePath);
          sourceDir.createSync();

          final populater = new MapDirectoryPopulater(inputs);
          return tempDirSrc.populate(populater);
        })
        .then((TempDir value) {
          assert(value == tempDirSrc);

          final task = copyDirectory(sourcePath.toNativePath(), destinationPath.toNativePath());
          return runTaskInTestRunner(task);
        })
        .then((RunResult runResult) {
          expect(runResult, RunResult.SUCCESS);

          List<FileSystemEntity> destinationFiles = new Directory.fromPath(destinationPath).listSync(recursive: true, followLinks: true);

          destinationFiles.forEach((FileSystemEntity fileSystemEntity) {
            var filePath = new Path(fileSystemEntity.path);
            var relFilePath = filePath.relativeTo(new Path(tempDirSrc.path));

            expect(outputs.contains(relFilePath.toString()), isTrue);

            File destFile = new File.fromPath(filePath);
            var relSrcFilePath = filePath.relativeTo(new Path(destinationPath.toNativePath()));
            var srcFilePath = sourcePath.join(relSrcFilePath);

            File srcFile = new File.fromPath(srcFilePath);

            return fileContentsMatch(srcFile, destFile)
                .then((bool match) {
                  expect(match, isTrue);
                });
          });
        })
        .whenComplete(() {
          if(tempDirSrc != null) {
            tempDirSrc.dispose();
          }
        });
  }

  /**
   * Copy directory with bad source directory.
   */
  static _copyDirectoryWithBadSource() {
    TempDir tempDirSrc;
    return TempDir.create()
        .then((TempDir value) {
          tempDirSrc = value;
          final destinationPath = new Path(tempDirSrc.path).join(new Path("dest"));
          final sourcePath = new Path(tempDirSrc.path).join(new Path("bad_src"));
          final task = copyDirectory(sourcePath.toNativePath(), destinationPath.toNativePath());
          return runTaskInTestRunner(task);
        })
        .then((RunResult runResult) {
          expect(runResult, RunResult.FAIL);
        })
        .whenComplete(() {
          if(tempDirSrc != null) {
            tempDirSrc.dispose();
          }
        });
  }

  /**
   * Copy directory with bad destination directory. Destination directory
   * already exists.
   */
  static _copyDirectoryWithBadDestination() {
    final inputs = {"src/main1.dart": "void main() => print('hello bot');",
                    "src/main2.dart": "void main() { String i = 42; }"};

    TempDir tempDirSrc;
    Path sourcePath, destinationPath;
    return TempDir.create()
        .then((TempDir value) {
          tempDirSrc = value;
          sourcePath = new Path(tempDirSrc.path).join(new Path("src"));
          destinationPath = new Path(tempDirSrc.path).join(new Path("dest"));

          Directory sourceDir = new Directory.fromPath(sourcePath);
          Directory destDir = new Directory.fromPath(destinationPath);

          sourceDir.createSync();
          destDir.createSync();

          final populater = new MapDirectoryPopulater(inputs);
          return tempDirSrc.populate(populater);
        })
        .then((TempDir value) {
          assert(value == tempDirSrc);
          final task = copyDirectory(sourcePath.toNativePath(), destinationPath.toNativePath());
          return runTaskInTestRunner(task);
        })
        .then((RunResult runResult) {
          expect(runResult, RunResult.FAIL);
        })
        .whenComplete(() {
          if(tempDirSrc != null) {
            tempDirSrc.dispose();
          }
        });
  }

  /**
   * Copy directory with symlinks followed.
   */
  static _copyDirectoryWithSymlinksFollowed() {
    final inputs = {"src/real/main1.dart": "void main() => print('hello bot');",
                    "src/real/main2.dart": "void main() { String i = 42; }"};
    final outputs = ["dest/real/main1.dart", "dest/real/main2.dart",
                     "dest/link/main1.dart", "dest/link/main2.dart"];

    TempDir tempDirSrc;
    Path sourcePath, destinationPath;
    Directory sourceDir;
    return TempDir.create()
        .then((TempDir value) {
          tempDirSrc = value;
          sourcePath = new Path(tempDirSrc.path).join(new Path("src"));
          destinationPath = new Path(tempDirSrc.path).join(new Path("dest"));
          sourceDir = new Directory.fromPath(sourcePath.join(new Path("real")));
          sourceDir.createSync(recursive: true);

          var linkPath = new Path(tempDirSrc.path).join(new Path("src/link"));
          Link link = new Link.fromPath(linkPath);
          link.createSync("real");

          final populater = new MapDirectoryPopulater(inputs);
          return tempDirSrc.populate(populater);
        })
        .then((TempDir value) {
          assert(value == tempDirSrc);

          final task = copyDirectory(sourcePath.toNativePath(), destinationPath.toNativePath(), followLinks: true);
          return runTaskInTestRunner(task);
        })
        .then((RunResult runResult) {
          expect(runResult, RunResult.SUCCESS);

          List<FileSystemEntity> destinationFiles = new Directory.fromPath(destinationPath).listSync(recursive: true, followLinks: true);

          return Future.forEach(destinationFiles, (FileSystemEntity fileSystemEntity) {
            var filePath = new Path(fileSystemEntity.path);
            var relFilePath = filePath.relativeTo(new Path(tempDirSrc.path));

            FileSystemEntityType type = FileSystemEntity.typeSync(fileSystemEntity.path);
            if (type == FileSystemEntityType.FILE) {
              expect(outputs.contains(relFilePath.toString()), isTrue);
              outputs.remove(relFilePath.toString());

              File destFile = new File.fromPath(filePath);
              var relSrcFilePath = filePath.relativeTo(new Path(destinationPath.toNativePath()));
              var srcFilePath = sourcePath.join(relSrcFilePath);

              File srcFile = new File.fromPath(srcFilePath);

              return fileContentsMatch(srcFile, destFile)
                  .then((bool match) {
                    expect(match, isTrue);
                  });
            }
          })
          .then((_) {
            expect(outputs, hasLength(0));
          });
        })
        .whenComplete(() {
          if(tempDirSrc != null) {
            tempDirSrc.dispose();
          }
        });
  }

  /**
   * Copy directory with symlinks not followed.
   */
  static _copyDirectoryWithSymlinksNotFollowed() {
    final inputs = {"src/real/main1.dart": "void main() => print('hello bot');",
                    "src/real/main2.dart": "void main() { String i = 42; }"};
    final outputs = ["dest/real/main1.dart", "dest/real/main2.dart"];

    TempDir tempDirSrc;
    Path sourcePath, destinationPath;
    Directory sourceDir;
    return TempDir.create()
        .then((TempDir value) {
          tempDirSrc = value;
          sourcePath = new Path(tempDirSrc.path).join(new Path("src"));
          destinationPath = new Path(tempDirSrc.path).join(new Path("dest"));
          sourceDir = new Directory.fromPath(sourcePath.join(new Path("real")));
          sourceDir.createSync(recursive: true);

          var linkPath = new Path(tempDirSrc.path).join(new Path("src/link"));
          Link link = new Link.fromPath(linkPath);
          link.createSync("real");

          final populater = new MapDirectoryPopulater(inputs);
          return tempDirSrc.populate(populater);
        })
        .then((TempDir value) {
          assert(value == tempDirSrc);

          final task = copyDirectory(sourcePath.toNativePath(), destinationPath.toNativePath(), followLinks: false);
          return runTaskInTestRunner(task);
        })
        .then((RunResult runResult) {
          expect(runResult, RunResult.SUCCESS);

          List<FileSystemEntity> destinationFiles = new Directory.fromPath(destinationPath).listSync(recursive: true, followLinks: true);

          return Future.forEach(destinationFiles, (FileSystemEntity fileSystemEntity) {
            var filePath = new Path(fileSystemEntity.path);
            var relFilePath = filePath.relativeTo(new Path(tempDirSrc.path));

            FileSystemEntityType type = FileSystemEntity.typeSync(fileSystemEntity.path);
            if (type == FileSystemEntityType.FILE) {
              expect(outputs.contains(relFilePath.toString()), isTrue);
              outputs.remove(relFilePath.toString());

              File destFile = new File.fromPath(filePath);
              var relSrcFilePath = filePath.relativeTo(new Path(destinationPath.toNativePath()));
              var srcFilePath = sourcePath.join(relSrcFilePath);

              File srcFile = new File.fromPath(srcFilePath);

              return fileContentsMatch(srcFile, destFile)
                  .then((bool match) {
                    expect(match, isTrue);
                  });
            }
          })
          .then((_) {
            expect(outputs, hasLength(0));
          });
        })
        .whenComplete(() {
          if(tempDirSrc != null) {
            tempDirSrc.dispose();
          }
        });
  }

  static void register() {
    group('copyDirectory', () {
      test('copy directory', _copyDirectorySuccess);
      test('copy directory with bad source', _copyDirectoryWithBadSource);
      test('copy directory with bad destination', _copyDirectoryWithBadDestination);
      test('copy directory with symlinks followed', _copyDirectoryWithSymlinksFollowed);
      test('copy directory with symlinks not followed', _copyDirectoryWithSymlinksNotFollowed);
    });
  }
}