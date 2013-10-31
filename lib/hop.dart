library hop;

import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:bot/bot.dart';
import 'package:bot_io/bot_io.dart';
import 'package:bot_io/completion.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:unmodifiable_collection/unmodifiable_collection.dart';

export 'src/hop/console_context.dart';

part 'src/hop/help.dart';
part 'src/hop/task_registry.dart';
part 'src/hop/root_task_context.dart';
part 'src/hop/run_result.dart';
part 'src/hop/runner.dart';
part 'src/hop/task.dart';
part 'src/hop/task_argument.dart';
part 'src/hop/task_context.dart';
part 'src/hop/task_fail_error.dart';
part 'src/hop/task_logger.dart';

final _sharedConfig = new TaskRegistry();

final _libLogger = new Logger('hop');

@deprecated
typedef Future TaskDefinition(TaskContext ctx);

typedef dynamic _TaskDefinition(TaskContext ctx);

/**
 * Designed to enable features in __Hop__. Should be the last method called in
 * `tool/hop_runner.dart`.
 *
 * [runHop] calls [io.exit] which terminates the application.
 *
 * If [paranoid] is `true`, [runHop] will verify the running script is
 * `tool/hop_runner.dart` relative to the working directory. If not, an
 * exception is thrown.
 *
 * If [helpTaskName], defines (surprise!) the name of the help task. If `null`
 * no help task is added. If [helpTaskName] conflicts with an already defined
 * task, an exception is thrown.
 */
void runHop(List<String> args, {
    bool paranoid: true,
    String helpTaskName: 'help',
    Level printAtLogLevel: Level.INFO
  }) {
  if(paranoid) {
    _paranoidHopCheck();
  }
  Runner._runShell(args, _sharedConfig, helpTaskName, printAtLogLevel);
}

Task addTask(String name, Task task) {
  return _sharedConfig.addTask(name, task);
}

Task addSyncTask(String name, Func1<TaskContext, bool> execFunc, {String description}) {
  return _sharedConfig.addSync(name, execFunc, description: description);
}

Task addAsyncTask(String name, Future execFuture(TaskContext ctx), {String description}) {
  return _sharedConfig.addAsync(name, execFuture, description: description);
}

ChainedTask addChainedTask(String name, Iterable<String> existingTaskNames,
                           {String description}) {
  return _sharedConfig.addChainedTask(name, existingTaskNames,
      description: description);
}

void _paranoidHopCheck() {
  var runningScript = io.Platform.script.toFilePath();
  runningScript = path.absolute(runningScript);
  runningScript = path.normalize(runningScript);

  final expectedPath = path.join(path.current, 'tool', 'hop_runner.dart');
  require(runningScript == expectedPath,
      'Running script should be at "$expectedPath" but was at "$runningScript"');
}

const String _COLOR_FLAG = 'color';
const String _PREFIX_FLAG = 'prefix';
const String _LOG_LEVEL_OPTION = 'log-level';

ArgParser _getParser(TaskRegistry config, Level defaultLogLevel) {
  assert(config.isFrozen);

  final parser = new ArgParser();

  config.tasks.forEach((taskName, task) {
    _initParserForTask(parser, taskName, task);
  });

  parser.addFlag(_COLOR_FLAG, defaultsTo: Console.supportsColor,
      help: 'Specifies if shell output can have color.');

  parser.addFlag(_PREFIX_FLAG, defaultsTo: true,
      help: 'Specifies if shell output is prefixed by the task name.');

  final logLevelAllowed = _sortedLogLevels
      .map((Level l) => l.name.toLowerCase())
      .toList();

  assert(logLevelAllowed.contains(defaultLogLevel.name.toLowerCase()));

  parser.addOption(_LOG_LEVEL_OPTION, allowed: logLevelAllowed,
      defaultsTo: defaultLogLevel.name.toLowerCase(),
      help: 'The log level at which task output is printed to the shell');

  return parser;
}

final List<Level> _sortedLogLevels =
  [Level.ALL, Level.CONFIG, Level.FINE, Level.FINER, Level.FINEST,
          Level.INFO, Level.OFF, Level.SEVERE, Level.SHOUT]
    ..sort();

void _initParserForTask(ArgParser parser, String taskName, Task task) {
  final subParser = parser.addCommand(taskName);
  task.configureArgParser(subParser);
}
