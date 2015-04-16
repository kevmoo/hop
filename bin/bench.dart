#!/usr/bin/env dart
import 'package:hop/src/console_context.dart';
import 'package:hop/hop_tasks.dart';

void main(List<String> args) {
  final benchTask = createBenchTask();
  ConsoleContext.runTaskAsProcess(args, benchTask);
}
