part of hop_tasks;

/**
 * Create a [Task] for copying [source] to [destination]. [followLinks] will
 * copy files from symlinks into [destination] with same directory structure.
 *
 * If [destination] folder exists an [Exception] is thrown. If the source
 * folder does not exist an [Exception] is thrown. If the source folder does
 * not contain any files then an [Exception] is thrown.
 */
Task copyDirectory(String source, String destination, {bool followLinks: false}) {

  return new Task.async((context) {
    var completer = new Completer();
    var sourcePath = new Path(source);
    var sourceDirectory = new Directory.fromPath(sourcePath);
    var destinationPath = new Path(destination);
    var destinationDirectory = new Directory.fromPath(destinationPath);

    // If destination exists blow up
    if (destinationDirectory.existsSync()) {
      context.fail("Destination path exists $destination");
    }

    // If source does not exist blow up
    if (!sourceDirectory.existsSync()) {
      context.fail("Source path does not exists $source");
    }

    List<FileSystemEntity> sourceFiles = sourceDirectory.listSync(recursive: true, followLinks: followLinks);

    if (sourceFiles.isEmpty) {
      context.fail("Source path does not contain any files $source");
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