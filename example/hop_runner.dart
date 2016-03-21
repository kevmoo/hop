/*
 * This file should exist in your project as `tool/hop_runner.dart`.
 */
library example.hop_runner;

import 'dart:io';

/*
 * This is all you need to import when you create your `hop_runner.dart` file.
 */
import 'package:hop/hop.dart';

void main(List<String> args) {
  /*
   * 1: Hello, World!
   *
   * A task is just a function with one argument: `TaskContext`.
   *
   * The `TaskContext` object allows reporting status to the user via log
   * methods that look similiar to those provided by the Logging package.
   */
  addTask('hello', (TaskContext ctx) {
    ctx.info('Hello, World!');
  }, description: 'Log "Hello, World!" at the info log level.');

  /*
   * 2: Async tasks
   *
   * Tasks can run asynchronously by returning a `Future` -- similar to how the
   * unittest package does async testing.
   *
   * The task is not completed until the returned `Future` completes.
   */
  addTask('file_stat', (TaskContext ctx) {
    var scriptPath = Platform.script.toFilePath();
    ctx.info('Currently running\n${scriptPath}');

    var file = new File(scriptPath);

    return file.stat().then((FileStat stat) {
      ctx.info(stat.toString());
    });
  }, description: 'Print the FileStat of the running script.');

  /*
   * By default, Hop checks to make sure that it's being run from the root of
   * the project in a file named `tool/hop_runner.dart`.
   *
   * Setting `paranoid` to `false` removes this check for this example file.
   */
  runHop(args, paranoid: false);
}
