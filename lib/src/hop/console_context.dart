library hop.console_context;

import 'dart:async';
import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:bot/bot.dart';
import 'package:bot_io/completion.dart';
import 'package:logging/logging.dart';
import 'package:hop/hop.dart';

class ConsoleContext extends TaskContext {
  final Task task;
  final ArgResults arguments;
  bool _isDisposed = false;

  ConsoleContext.raw(this.arguments, this.task);

  @override
  void log(Level logLevel, String message) {
    _assertNotDisposed();
    if(logLevel >= Level.FINE) {
      print(message);
    }
  }

  @override
  TaskContext getSubContext(String name) {
    throw new UnimplementedError('sub contexts are not supported yet');
  }

  bool get isDisposed => _isDisposed;

  void dispose() {
    _assertNotDisposed();
    _isDisposed = true;
  }

  static void runTaskAsProcess(List<String> mainArgs, Task task) {
    assert(task != null);

    final parser = new ArgParser();
    task.configureArgParser(parser);

    ArgResults args;
    try {
      args = tryArgsCompletion(mainArgs, parser);
    } on FormatException catch (ex, stack) {
      print('There was a problem parsing the provided arguments.');
      print(ex.message);
      print(parser.getUsage());
      io.exit(RunResult.BAD_USAGE.exitCode);
    }
    final ctx = new ConsoleContext.raw(args, task);

    Runner.runTask(ctx, task)
      .then((RunResult rr) {
        ctx.dispose();
        io.exit(rr.exitCode);
      });
  }

  void _assertNotDisposed() {
    if(_isDisposed) {
      throw new DisposedError();
    }
  }
}
