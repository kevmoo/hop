library harness_console;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'hop/_hop.dart' as hop;
import 'hop_tasks/_hop_tasks.dart' as hop_tasks;

void main() {
  testCore(new VMConfiguration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;
  groupSep = ' - ';

  group('hop', hop.main);
  group('hop_tasks', hop_tasks.main);
}
