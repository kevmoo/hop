library hop.core;

import 'dart:async';
import 'dart:collection';
import 'package:args/args.dart';
import 'package:bot/bot.dart';
import 'package:bot_io/bot_io.dart';
import 'package:logging/logging.dart';

import 'package:hop/src/util.dart';

part 'src/hop_core/root_task_context.dart';
part 'src/hop_core/run_result.dart';
part 'src/hop_core/task.dart';
part 'src/hop_core/task_argument.dart';
part 'src/hop_core/task_context.dart';
part 'src/hop_core/task_logger.dart';

final _libLogger = new Logger('hop');

typedef dynamic _TaskDefinition(TaskContext ctx);
