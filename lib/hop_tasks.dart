library hop_tasks;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as pathos;

import 'package:bot/bot.dart';
import 'package:bot/bot_async.dart';
import 'package:bot_io/bot_git.dart';
import 'package:bot_io/bot_io.dart';
import 'package:hop/hop_core.dart';
import 'src/hop_tasks/process.dart';

export 'src/hop_tasks/copy_js.dart' show createCopyJSTask;
export 'src/hop_tasks/bench_task.dart';
export 'src/hop_tasks/git_tasks.dart';
export 'src/hop_tasks/process.dart';
export 'src/hop_tasks/unit_test.dart';

part 'src/hop_tasks/dartanalyzer.dart';
part 'src/hop_tasks/compiler_task.dart';
part 'src/hop_tasks/dartdoc.dart';

ArgResults _helpfulParseArgs(TaskContext ctx, ArgParser parser, List<String> args) {
  try {
    return parser.parse(args);
  } on FormatException catch(ex, stack) {
    ctx.severe('There was a problem parsing the provided arguments');
    ctx.info('Usage:');
    ctx.info(parser.getUsage());
    ctx.fail(ex.message);
  }
}

String _getPlatformBin(String binName) {
  if(Platform.operatingSystem == 'windows') {
    return '${binName}.bat';
  } else {
    return binName;
  }
}
