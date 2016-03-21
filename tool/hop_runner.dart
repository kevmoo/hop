library hop_runner;

import 'dart:async';
import 'dart:io';

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart' hide createUnitTestTask;

void main(List<String> args) {
  //
  // Analyzer
  //
  addTask('analyze_libs', createAnalyzerTask(_getLibs));

  addTask(
      'analyze_test_libs', createAnalyzerTask(['test/harness_console.dart']));

  addChainedTask('analyze_all', ['analyze_libs', 'analyze_test_libs']);

  addTask('bench', createBenchTask());

  runHop(args);
}

Future<List<String>> _getLibs() {
  return new Directory('lib')
      .list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
