part of hop_tasks;

// TODO(adam): document methods and class
// TODO(adam?): optional out directory param. Used so that repeat runs
//              are faster

const _formatMachine = 'machine';

/**
 * [delayedFileList] a [List<String>] mapping to paths to dart files or some
 * combinations of [Future] or [Function] values that return a [List<String>].
 */
Task createAnalyzerTask(dynamic delayedFileList) {
  return new Task.async((context) {
    final parseResult = context.arguments;

    final bool verbose = parseResult[_verboseArgName];
    final bool formatMachine = parseResult[_formatMachine];

    return getDelayedResult(delayedFileList)
        .then((List<String> files) {
          final fileList = files.map((f) => new Path(f)).toList();
          return _processDartAnalyzerFile(context, fileList, verbose,
              formatMachine);
        });
  },
  description: 'Run "dartanalyzer" for the provided dart files.',
  config: _parserConfig);
}

void _parserConfig(ArgParser parser) {
  parser
    ..addFlag(_verboseArgName, abbr: 'v', defaultsTo: false,
        help: 'verbose output of all errors')
    ..addFlag(_formatMachine, abbr: 'm', defaultsTo: false,
        help: 'Print errors in a format suitable for parsing');
}

Future<bool> _processDartAnalyzerFile(TaskContext context,
    List<Path> analyzerFilePaths, bool verbose, bool formatMachine) {

  int errorsCount = 0;
  int passedCount = 0;
  int warningCount = 0;

  return Future.forEach(analyzerFilePaths, (Path path) {
    final logger = context.getSubLogger(path.toString());
    return _dartAnalyzer(logger, path, verbose, formatMachine)
        .then((int exitCode) {

          String prefix;

          switch(exitCode) {
            case 0:
              prefix = "PASSED";
              passedCount++;
              break;
            case 1:
              prefix = "WARNING";
              warningCount++;
              break;
            case 2:
              prefix =  "ERROR";
              errorsCount++;
              break;
            default:
              prefix = "Unknown exit code $exitCode";
              errorsCount++;
              break;
          }

          context.info("$prefix - $path");
        });
    })
    .then((_) {
      context.info("PASSED: ${passedCount}, WARNING: ${warningCount}, ERROR: ${errorsCount}");
      return errorsCount == 0;
    });
}

Future<int> _dartAnalyzer(TaskLogger logger, Path filePath, bool verbose,
    bool formatMachine) {
  TempDir tmpDir;

  return TempDir.create()
      .then((TempDir td) {
        tmpDir = td;

        var processArgs = [];

        if(formatMachine) {
          processArgs.add('--machine');
        }

        processArgs.addAll([filePath.toNativePath()]);

        return Process.start(_getPlatformBin('dartanalyzer'), processArgs);
      })
      .then((process) {
        if(verbose) {
          return pipeProcess(process,
              stdOutWriter: logger.fine,
              stdErrWriter: logger.severe);
        } else {
          return pipeProcess(process);
        }
      })
      .whenComplete(() {
        if(tmpDir != null) {
          tmpDir.dispose();
        }
      });
}
