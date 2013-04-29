part of hop_tasks;

class CompilerTargetType {
  final String _value;
  const CompilerTargetType._internal(this._value);
  String toString() => 'CompilerTargetType.$_value';
  String get fileExt => _value;

  static const JS = const CompilerTargetType._internal('js');
  static const DART = const CompilerTargetType._internal('dart');
}

@deprecated
Task createDart2JsTask(dynamic delayedRootList, {String output: null,
  String packageRoot: null, bool minify: false, bool allowUnsafeEval: true,
  bool liveTypeAnalysis: true, bool rejectDeprecatedFeatures: false}) {

  return createDartCompilerTask(delayedRootList,
      singleOutput: output,
      packageRoot: packageRoot,
      minify: minify,
      allowUnsafeEval: allowUnsafeEval,
      liveTypeAnalysis: liveTypeAnalysis,
      rejectDeprecatedFeatures: rejectDeprecatedFeatures,
      outputType: CompilerTargetType.JS);
}

/**
 * [delayedRootList] a [List<String>] mapping to paths to libraries or some
 * combinations of [Future] or [Function] values that return a [List<String>].
 *
 * [outputType] must be one of type [CompilerTargetType].
 */
Task createDartCompilerTask(dynamic delayedRootList, {String singleOutput,
  String packageRoot, bool minify: false, bool allowUnsafeEval: true,
  bool liveTypeAnalysis: true, bool rejectDeprecatedFeatures: false,
  CompilerTargetType outputType: CompilerTargetType.JS,
  String outputMapper(String source)}) {

  requireArgument(outputType == CompilerTargetType.JS || outputType == CompilerTargetType.DART, 'outputType');

  final friendlyName = (outputType == CompilerTargetType.JS) ? 'Javascript' : 'Dart';

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
                output, packageRoot, minify, allowUnsafeEval,
                liveTypeAnalysis, rejectDeprecatedFeatures, outputType)
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
  }, description: 'Run Dart-to-$friendlyName compiler');
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
    bool liveTypeAnalysis, bool rejectDeprecatedFeatures, CompilerTargetType outputType) {

  requireArgumentNotNullOrEmpty(output, 'output');

  if(output == file) {
    ctx.fail('The provided or derived output value "$output" is the same as the'
        ' input file.');
  }

  final packageDir = new Directory('packages');
  assert(packageDir.existsSync());

  final args = ["--package-root=${packageDir.path}",
                '--throw-on-error',
                '-v',
                "--output-type=${outputType.fileExt}",
                "--out=$output",
                file];

  if(liveTypeAnalysis == false) {
    args.add('--disable-native-live-type-analysis');
  }

  if(rejectDeprecatedFeatures) {
    args.add('--reject-deprecated-language-features');
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
