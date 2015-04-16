library harness_console;

import 'package:unittest/unittest.dart';
import 'hop/_hop.dart' as hop;
import 'hop_tasks/_hop_tasks.dart' as hop_tasks;
import 'stats_test.dart' as stats;

void main() {
  groupSep = ' - ';

  group('hop', hop.main);
  group('hop_tasks', hop_tasks.main);
  group('stats', stats.main);
}
