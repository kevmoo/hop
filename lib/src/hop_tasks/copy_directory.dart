part of hop_tasks;

Task copyDirectory(String source, String destination) {
  
  return new Task.async((context) {
    var completer = new Completer();
    var sourcePath = new Path(source);
    var sourceDirectory = new Directory.fromPath(sourcePath);
    var destinationPath = new Path(destination);
    var destinationDirectory = new Directory.fromPath(destinationPath);
    
    // If destination exists blow up
    if (destinationDirectory.existsSync()) {
      throw "Destination path exists $destination";
    }
    
    // If source does not exist blow up
    if (!sourceDirectory.existsSync()) {
      throw "Source path does not exists $source";
    }
    
    List<FileSystemEntity> sourceFiles = sourceDirectory.listSync(recursive: true, followLinks: true);
    
    if (sourceFiles.isEmpty) {
      throw "Source path does not contain any files $source";
    }
    
    sourceFiles.forEach((FileSystemEntity fileSystemEntity) {
      var fileSystemEntityPath = new Path(fileSystemEntity.path);
      var relativePath = fileSystemEntityPath.relativeTo(sourcePath);

      File inFile = new File.fromPath(fileSystemEntityPath);
      var outFilePath = destinationPath.join(relativePath);
      var outFileParentDir = new Directory.fromPath(outFilePath.directoryPath);

      if (outFileParentDir.existsSync() == false) {
        outFileParentDir.createSync(recursive: true);
      }
      
      FileSystemEntityType type = FileSystemEntity.typeSync(fileSystemEntity.path);
      if (type == FileSystemEntityType.FILE) {
        File outFile = new File.fromPath(outFilePath);
        List<int> inBytes = inFile.readAsBytesSync();
        outFile.writeAsBytesSync(inBytes);
      }
    });
    
    completer.complete(true);
    return completer.future;
  }, description: 'Run copy directory.');
}