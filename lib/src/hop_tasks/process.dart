library hop_tasks.process;

import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import 'package:hop/hop.dart';

Task createProcessTask(String command, {List<String> args: null, String description}) {
  return new Task((ctx) => startProcess(ctx, command, args), description: description);
}

// TODO: document that start does an 'interactive' process
//       stderr and stdout are piped to context, etc
//       This aligns with io.Process.start
Future startProcess(TaskContext ctx, String command,
    [List<String> args = null]) {

  requireArgumentNotNull(ctx, 'ctx');
  requireArgumentNotNull(command, 'command');
  if(args == null) {
    args = [];
  }

  ctx.fine("Starting process:");
  ctx.fine("$command ${args.join(' ')}");
  return Process.start(command, args)
      .then((process) {
        return pipeProcess(process,
            stdOutWriter: ctx.info,
            stdErrWriter: ctx.severe);
      })
      .then((int exitCode) {
        if(exitCode != 0) ctx.fail('Process exit code: $exitCode');
      });
}

Future<int> pipeProcess(Process process,
    {Action1<String> stdOutWriter, Action1<String> stdErrWriter}) {

  var futures = [process.exitCode];

  futures.add(process.stdout.forEach((data)
      => _stdListen(data, stdOutWriter)));

  futures.add(process.stderr.forEach((data)
      => _stdListen(data, stdErrWriter)));

  return Future.wait(futures)
      .then((List values) {
        assert(values.length == futures.length);
        assert(values[0] != null);
        return values[0] as int;
      });
}

void _stdListen(List<int> data, void writer(String input)) {
  if(writer != null) {
    final str = SYSTEM_ENCODING.decode(data).trim();
    writer(str);
  }
}
