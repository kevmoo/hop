library test.hop_tasks.process;

import 'dart:async';
import 'dart:io';

import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_tasks/process.dart';
import 'package:test/test.dart';

import '../test_util.dart';

// TODO: support windows?
// TODO: need to extend TestTaskContext to have logging events
//       needed to verify output of commands, right?

void main() {
  test('test command success', _testProcessSuccess);
  test('test command fail', _testProcessFail);
  test('test command does not exist', _testProcessMissing);
}

Future _testProcessSuccess() {
  final scriptPath = _getTestScriptPath('exit0');
  final task = createProcessTask('dart', args: [scriptPath]);

  return runTaskInTestRunner(task).then((RunResult result) {
    expect(result.success, isTrue);
  });
}

Future _testProcessFail() {
  final scriptPath = _getTestScriptPath('exit1');
  final task = createProcessTask('dart', args: [scriptPath]);

  return runTaskInTestRunner(task).then((RunResult rr) {
    expect(rr, RunResult.EXCEPTION);
  });
}

Future _testProcessMissing() {
  // NOTE: making the relatively safe assumption that this is not
  // a valid command on the test system. Could find out w/ 'which'..but...eh
  final scriptPath = 'does_not_exist_right';
  final task = createProcessTask(scriptPath);

  return runTaskInTestRunner(task).then((RunResult rr) {
    expect(rr, RunResult.EXCEPTION);
  });
}

String _getTestScriptPath(String name) {
  // Since there is no way to figure out where 'this' file is, we have to
  // assume that script was run from the root of the project
  // so...the file should be at...

  final filePath = 'test/hop_tasks/process_scripts/$name.dart';
  final file = new File(filePath);

  if (!file.existsSync()) {
    throw '''Could not find file "$filePath".
Are you running this script from the root of the project?''';
  }
  return filePath;
}
