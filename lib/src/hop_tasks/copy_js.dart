library hop_tasks.copy_js;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_experimental.dart' as hop_ex;
import 'package:logging/logging.dart' as log;
import 'package:path/path.dart' as pathos;

final _logger = new log.Logger('hop.hop_tasks.copy_js');

Task createCopyJSTask(String targetDir, {bool includePackagePath: false,
  bool unittestTestController: false,
  bool browserDart: false,
  bool browserInterop: false,
  bool jsDartInterop: false,
  bool shadowDomDebug: false,
  bool shadowDomMin: false}) {

  return new Task((ctx) => copyJs(targetDir,
   unittestTestController: unittestTestController,
   browserDart: browserDart,
   browserInterop: browserInterop,
   jsDartInterop: jsDartInterop,
   shadowDomDebug: shadowDomDebug,
   shadowDomMin: shadowDomMin));
}

Future copyJs(String targetDir, {bool includePackagePath: false,
   bool unittestTestController: false, bool browserDart: false,
   bool browserInterop: false, bool jsDartInterop: false,
   bool shadowDomDebug: false, bool shadowDomMin: false}) {

  return FileSystemEntity.isDirectory(targetDir)
      .then((bool isDir) {
        if(!isDir) {
          throw new ArgumentError('"targetPath" does not exist or is not a directory: $targetDir');
        }

        var sources = [];
        if(unittestTestController) sources.add(UNITTEST_TEST_CONTROLLER);
        if(browserDart) sources.add(BROWSER_DART);
        if(browserInterop) sources.add(BROWSER_INTEROP);
        if(jsDartInterop) sources.add(JS_DART_INTEROP);
        if(shadowDomDebug) sources.add(SHADOW_DOM_DEBUG);
        if(shadowDomMin) sources.add(SHADOW_DOM_MIN);

        if(sources.isEmpty) {
          throw new ArgumentError('No source files were provided. NOOP.');
        }

        return Future.forEach(sources, (String source) {
          return _copyDependency(targetDir, source, includePackagePath);
        });
      });
}

const UNITTEST_TEST_CONTROLLER = 'unittest/test_controller.js';

const BROWSER_DART = 'browser/dart.js';

const BROWSER_INTEROP = 'browser/interop.js';

const JS_DART_INTEROP = 'js/dart_interop.js';

const SHADOW_DOM_DEBUG = 'shadow_dom/shadow_dom.debug.js';

const SHADOW_DOM_MIN = 'shadow_dom/shadow_dom.min.js';

Future _copyDependency(String targetDir, String source, bool includePackagePath) {
  var sourcePath = pathos.join('packages', source);
  assert(pathos.isRelative(sourcePath));
  var fileName = includePackagePath ? sourcePath : pathos.basename(source);
  assert(source.endsWith('.js'));
  var destPath = pathos.join(targetDir, fileName);

  return FileSystemEntity.isFile(sourcePath)
      .then((bool sourceExists) {
        if(!sourceExists) {
          throw new ArgumentError('Source does not exist. Are you missing an import?'
              ' Forgot `pub install`?  $sourcePath');
        }

        _logger.config('Checking $destPath with $sourcePath');

        return _copyFile(sourcePath, destPath, includePackagePath)
            .then((bool success) {
              if(success) {
                _logger.info('$destPath updated with content from $sourcePath');
              } else {
                _logger.info('$destPath is the same as $sourcePath');
              }
            });
      });
}

Future _copyFile(String sourcePath, String destinationPath, bool ensureDir) {
  return hop_ex.transformFile(destinationPath, (String original) {
    var source = new File(sourcePath);
    return source.readAsString();
  }, ensureDirectory: ensureDir);
}
