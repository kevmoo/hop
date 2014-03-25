/**
 * The main Hop library.
 *
 * Import this when using hop.
 */
library hop;

import 'dart:async';
import 'dart:io' as io;

import 'package:bot/bot.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'hop_core.dart';
export 'hop_core.dart';

import 'src/hop_runner.dart';

final _sharedConfig = new TaskRegistry();

/**
 * Enables features in hop.
 *
 * Call this function after all the tasks are added.
 *
 * [runHop] calls [io.exit] which terminates the application.
 *
 * If [paranoid] is `true`, [runHop] will verify the running script is
 * `tool/hop_runner.dart` relative to the working directory. If the script does
 * not, match that requirement, an [Exception] is thrown.
 *
 * [helpTaskName] defines the name of the help task. If [helpTaskName]
 * conflicts with an already defined task, an error is thrown. Setting this
 * to `null` will disable help.
 */
void runHop(List<String> args, {
    bool paranoid: true,
    String helpTaskName: 'help',
    Level printAtLogLevel: Level.INFO
  }) {
  if (paranoid) {
    _paranoidHopCheck();
  }
  Runner.runShell(args, _sharedConfig, helpTaskName, printAtLogLevel)
    .then((RunResult rr) {
      io.exit(rr.exitCode);
    });
}

/**
 * Adds a task to hop.
 *
 * [task] can be either an instance of [Task] or a [Function]. 
 *
 * If [task] is a [Function], it must take one argument: [TaskContext]. If a
 * [Future] is returned from the [task] function, the runner will wait for the
 * [Future] to complete.
 *
 * If [description] is provided and [task] is a [Task], then [task] will be
 * cloned and given [description].
 */
Task addTask(String name, dynamic task, {String description,
  List<String> dependencies}) =>
      _sharedConfig.addTask(name, task, description: description,
          dependencies: dependencies);

/**
 * Creates a chained task, a task which runs multiple tasks.
 *
 * [name] is the name of the task. This is used to identify the task.
 *
 * [existingTaskNames] is an Iterable of existing task names. These tasks are
 * run when this task is run.
 *
 * [description] is the description of the task. This is displayed next to the
 * task's name in the default help task.
 */
Task addChainedTask(String name, Iterable<String> existingTaskNames, {
  String description}) => _sharedConfig.addChainedTask(name, existingTaskNames,
      description: description);

void _paranoidHopCheck() {
  var currentDir = path.current;

  var expectedPubspecFile = path.join(currentDir, 'pubspec.yaml');

  require(io.FileSystemEntity.isFileSync(expectedPubspecFile),
      'pubspec.yaml is not in the working directory "$currentDir". '
      'Hop expects to run from a project root directory. '
      'When running from the Editor, change the working directory in '
      'Run -> Manage Launches.'
      );

  var runningScript = io.Platform.script.toFilePath();

  final expectedPath = path.join(currentDir, 'tool', 'hop_runner.dart');

  require(runningScript == expectedPath, 'Running script should be at '
      '"$expectedPath", but it was at "$runningScript"');
}
