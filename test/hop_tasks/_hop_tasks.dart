library test_hop_tasks;

import 'package:unittest/unittest.dart';

import 'compiler_tests.dart' as compiler;
import 'dartanalyzer_tests.dart' as dart_analyzer;
import 'git_tests.dart' as git;
import 'process_tests.dart' as process;

void main() {
  group('compiler', compiler.main);
  group('dart analyzer', dart_analyzer.main);
  group('git', git.main);
  group('process', process.main);
}
