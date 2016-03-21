library test.hop.integration;

import 'dart:async';
import 'dart:io';

import 'package:bot/bot.dart';
import 'package:hop/hop_core.dart';
import 'package:test/test.dart';

void main() {
  test('hop output is sorted', _testOutputSorted);
  test('bad hop command', _testBadHopCommand);
}

Future _testBadHopCommand() {
  return _runHop(['bad_command_name'], {}).then((ProcessResult pr) {
    expect(pr.exitCode, equals(RunResult.BAD_USAGE.exitCode));
  });
}

Future _testOutputSorted() {
  final env = {'COMP_LINE': 'hop', 'COMP_POINT': '4'};

  return _runHop(['completion', '--', 'hop'], env).then((ProcessResult pr) {
    expect(pr.exitCode, equals(RunResult.SUCCESS.exitCode));
    final lines = Util.splitLines(pr.stdout.trim()).toList();
    expect(
        lines,
        orderedEquals([
          'analyze_all',
          'analyze_libs',
          'analyze_test_libs',
          'bench',
          'help'
        ]));
  });
}

/*
 * TODO: feature for bot_test
 *       wrap Process.run (or Process.start?)
 *       log process name + args + options?
 *       log stdout/stderr via logMessage
 *       do the expect dance to ensure completion without error, etc
 */
Future<ProcessResult> _runHop(Iterable<String> args, Map<String, String> env) {
  final list = args.toList();

  final hopRunnerPath = 'tool/hop_runner.dart';
  list.insert(0, hopRunnerPath);

  // assuming `dart` is in system path
  env['PATH'] = Platform.environment['PATH'];

  return Process.run('dart', list, environment: env);
}
