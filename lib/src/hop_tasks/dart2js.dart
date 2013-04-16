part of hop_tasks;

// TODO: output does not work if there is more than one file provided, moron!

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
      output: output,
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
Task createDartCompilerTask(dynamic delayedRootList, {String output: null,
  String packageRoot: null, bool minify: false, bool allowUnsafeEval: true,
  bool liveTypeAnalysis: true, bool rejectDeprecatedFeatures: false,
  CompilerTargetType outputType: CompilerTargetType.JS}) {

  requireArgument(outputType == CompilerTargetType.JS || outputType == CompilerTargetType.DART, 'outputType');

  final friendlyName = (outputType == CompilerTargetType.JS) ? 'Javascript' : 'Dart';

  return new Task.async((context) {
    bool errors = false;

    return getDelayedResult(delayedRootList)
        .then((List<String> inputs) {

          return Future.forEach(inputs, (path) {
            if(errors) {
              context.warning('Compile errors. Skipping $path');
              return new Future.value(null);
            }

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

Future<bool> _dart2js(TaskContext ctx, String file,
    String output, String packageRoot, bool minify, bool allowUnsafeEval,
    bool liveTypeAnalysis, bool rejectDeprecatedFeatures, CompilerTargetType outputType) {

  if(output == null) {
    output = file;

    if(!output.endsWith(outputType.fileExt)) {
      output = '$output.${outputType.fileExt}';
    }
  }

  if(output == file) {
    throw 'The provided or derived output value "$output" is the same an input'
      ' file.';
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
