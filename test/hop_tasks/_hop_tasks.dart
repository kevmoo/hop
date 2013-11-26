library test_hop_tasks;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:unittest/unittest.dart';
import 'package:bot_io/bot_git.dart';
import 'package:bot_io/bot_io.dart';
import 'package:hop/hop_core.dart';
import 'package:hop/hop_tasks.dart';
import '../test_util.dart';

part 'process_tests.dart';
part 'git_tests.dart';
part 'dartanalyzer_tests.dart';
part 'compiler_tests.dart';

void main() {
  group('hop_tasks', () {
    ProcessTests.run();
    GitTests.register();
    DartAnalyzerTests.register();
    CompilerTests.register();
  });
}
