// TODO(adam): Add tests related to symlinks. 

part of test_hop_tasks;

class CopyDirectoryTests {
  
  /**
   * Check if two files are the same by md5sum
   */
  static bool _testFileSame(File file1, File file2) {
    List file1Bytes = file1.readAsBytesSync();
    List file2Bytes = file2.readAsBytesSync();
    if (file1Bytes.length != file2Bytes.length) {
      return false;
    }
    
    List<int> hashFile1 = (new MD5()..add(file1Bytes)).close();
    List<int> hashFile2 = (new MD5()..add(file2Bytes)).close();
    
    for (int i = 0; i < hashFile1.length; i++) {
      if (hashFile1[i] != hashFile2[i]) {
        return false;
      }
    }
    
    return true;
  }
  
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
            
            expect(_testFileSame(srcFile, destFile), isTrue);
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
          expect(runResult, RunResult.EXCEPTION);
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
          expect(runResult, RunResult.EXCEPTION);
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
    });
    
  }
}