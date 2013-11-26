library hop.core;

import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:bot/bot.dart';
import 'package:bot_io/bot_io.dart';
import 'package:bot_io/completion.dart';
import 'package:logging/logging.dart';
import 'package:unmodifiable_collection/unmodifiable_collection.dart';

import 'package:hop/src/hop_core/util.dart';

part 'src/hop_core/help.dart';
part 'src/hop_core/task_registry.dart';
part 'src/hop_core/root_task_context.dart';
part 'src/hop_core/run_result.dart';
part 'src/hop_core/runner.dart';
part 'src/hop_core/task.dart';
part 'src/hop_core/task_argument.dart';
part 'src/hop_core/task_context.dart';
part 'src/hop_core/task_fail_error.dart';
part 'src/hop_core/task_logger.dart';

final _libLogger = new Logger('hop');

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

const String _COLOR_FLAG = 'color';
const String _PREFIX_FLAG = 'prefix';
const String _LOG_LEVEL_OPTION = 'log-level';

final List<Level> _sortedLogLevels =
    [Level.ALL, Level.CONFIG, Level.FINE, Level.FINER, Level.FINEST,
     Level.INFO, Level.OFF, Level.SEVERE, Level.SHOUT]
    ..sort();

typedef dynamic _TaskDefinition(TaskContext ctx);

void _initParserForTask(ArgParser parser, String taskName, Task task) {
  final subParser = parser.addCommand(taskName);
  task.configureArgParser(subParser);
}
