library hop.console_context;

import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:bot_io/completion.dart';
import 'package:logging/logging.dart';
import 'package:hop/hop_core.dart';
import 'hop_runner.dart';

class ConsoleContext extends TaskLogger with TaskContext {
  final Task task;
  final ArgResults arguments;
  final Map<String, dynamic> extendedArgs;

  ConsoleContext.raw(this.arguments, this.task, this.extendedArgs);

  @override
  void log(Level logLevel, String message) {
    requireNotDisposed();
    if(logLevel >= Level.FINE) {
      print(message);
    }
  }

  /**
   * **NOTE** Not implemented yet.
   */
  // TODO: Implement this? (BUG #???)
  @override
  TaskLogger getSubLogger(String name) {
    throw new UnimplementedError('A Hop to-do');
  }

  /**
   * **DEPRECATED** Use [getSubLogger] instead.
   */
  @deprecated
  TaskLogger getSubContext(String name) => getSubLogger(name);

  static void runTaskAsProcess(List<String> mainArgs, Task task) {
    assert(task != null);

    final parser = new ArgParser();
    task.configureArgParser(parser);

    ArgResults args;
    Map<String, dynamic> extendedArgs;
    try {
      args = tryArgsCompletion(mainArgs, parser);
      extendedArgs = task.parseExtendedArgs(args.rest);
    } on FormatException catch (ex, stack) {
      print('There was a problem parsing the provided arguments.');
      print(ex.message);
      print(parser.getUsage());
      io.exit(RunResult.BAD_USAGE.exitCode);
    }
    final ctx = new ConsoleContext.raw(args, task, extendedArgs);

    Runner.runTask(ctx, task)
      .then((RunResult rr) {
        ctx.dispose();
        io.exit(rr.exitCode);
      });
  }
}
