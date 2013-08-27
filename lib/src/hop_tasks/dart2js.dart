part of hop_tasks;

class CompilerTargetType {

  static const JS = const CompilerTargetType._('js', 'Javascript');
  static const DART = const CompilerTargetType._('dart', 'Dart');

  final String fileExt;
  final String friendlyName;

  const CompilerTargetType._(this.fileExt, this.friendlyName);

  @override
  String toString() => 'CompilerTargetType.$fileExt';
}

/**
 * [delayedRootList] a [List<String>] mapping to paths to libraries or some
 * combinations of [Future] or [Function] values that return a [List<String>].
 *
 * [outputType] must be one of type [CompilerTargetType].
 */
Task createDartCompilerTask(dynamic delayedRootList, {String singleOutput,
  String packageRoot, bool minify: false, bool allowUnsafeEval: true,
  bool liveTypeAnalysis: true, bool throwOnError: false, bool verbose: true,
  bool suppressWarnings: false, CompilerTargetType outputType: CompilerTargetType.JS,
  String outputMapper(String source)}) {

  requireArgument(outputType == CompilerTargetType.JS || outputType == CompilerTargetType.DART, 'outputType');

  if(singleOutput != null && outputMapper != null) {
    throw new ArgumentError('Only one of "singleOutput" and "outputMapper" can be set.');
  }

  return new Task.async((context) {
    bool errors = false;

    return getDelayedResult(delayedRootList)
        .then((List<String> inputs) {

          if(inputs.length > 1 && singleOutput != null) {
            assert(outputMapper == null);
            context.fail('Cannot specify a single output when more than one '
                'input is provided.');
          }

          if(outputMapper == null) {
            if(singleOutput != null) {
              outputMapper = (String input) => singleOutput;
            } else if (outputType == CompilerTargetType.JS) {
              outputMapper = _dart2jsOutputMapper;
            } else {
              assert(outputType == CompilerTargetType.DART);
              outputMapper = _dart2DartOutputMapper;
            }
          }

          return Future.forEach(inputs, (path) {
            if(errors) {
              context.warning('Compile errors. Skipping $path');
              return new Future.value(null);
            }

            String output = outputMapper(path);

            return _dart2js(context, path,
                output, packageRoot, minify, allowUnsafeEval, liveTypeAnalysis,
                throwOnError, verbose, suppressWarnings, outputType)
                .then((bool success) {
                  // should not have been run if we had pending errors
                  assert(errors == false);
                  errors = !success;
                });
          });
        })
        .then((_) {
          return !errors;
        });
  }, description: 'Run Dart-to-${outputType.friendlyName} compiler');
}

String _dart2jsOutputMapper(String input) => input + '.js';

String _dart2DartOutputMapper(String input) {
  if(input.endsWith('.dart')) {
    return input.substring(0, input.length - 5) + '.compiled.dart';
  } else {
    return input + '.dart';
  }
}

Future<bool> _dart2js(TaskContext ctx, String file,
    String output, String packageRoot, bool minify, bool allowUnsafeEval,
    bool liveTypeAnalysis, bool throwOnError, bool verbose, bool suppressWarnings,
    CompilerTargetType outputType) {

  requireArgumentNotNullOrEmpty(output, 'output');

  if(output == file) {
    ctx.fail('The provided or derived output value "$output" is the same as the'
        ' input file.');
  }

  final packageDir = new Directory('packages');
  assert(packageDir.existsSync());

  final args = ["--package-root=${packageDir.path}",
                "--output-type=${outputType.fileExt}",
                "--out=$output",
                file];

  if (verbose) {
    args.add('--verbose');
  }

  if (suppressWarnings) {
    args.add('--suppress-warnings');
  }

  if(throwOnError) {
    args.add('--throw-on-error');
  }

  if(liveTypeAnalysis == false) {
    args.add('--disable-native-live-type-analysis');
  }

  if(minify) {
    args.add('--minify');
  }

  if(!allowUnsafeEval) {
    args.add('--disallow-unsafe-eval');
  }

  if(packageRoot != null) {
    args.add('--package-root=$packageRoot');
  }

  return startProcess(ctx, _getPlatformBin('dart2js'), args);
}
