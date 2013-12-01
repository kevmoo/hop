part of hop.runner;

class Runner {
  /**
   * Runs a [Task] with the specificed [TaskContext].
   *
   * [runTask] handles a number of error cases, logs appropriate messages
   * to [context] and returns a corresponding [RunResult] when completed.
   */
  static Future<RunResult> runTask(TaskContext context, Task task,
      {Level printAtLogLevel}) {

    requireArgumentNotNull(context, 'context');
    requireArgumentNotNull(task, 'task');
    requireArgument(!context.isDisposed, 'context', 'cannot be disposed');

    final start = new DateTime.now();
    context.finest('Started at $start');

    return task.run(context, printAtLogLevel: printAtLogLevel)
        .then((value) {
          // TODO: remove these checks at some future version
          if(value == true) {
            context.severe('`true` was returned from the task.\n'
                "It's possible that the task was trying to signal success using"
                "an old behavior.\nThis is no longer nessesary.");
          } else if(value == false) {
            context.severe("`false` was returned from the task.\n"
                "It's possible that the task was trying to signal failure using"
                "an old behavior.\nTasks should signal failure using "
                "`TaskContext.fail`.");
          }

          return RunResult.SUCCESS;
        })
        .catchError((Object error, StackTrace stack) {
          if(error is TaskFailError) {
            final TaskFailError e = error;
            context.severe(e.message);
            return RunResult.FAIL;
          } else {
            // has as exception, need to test this
            context.severe('Exception thrown by task');
            context.severe(error.toString());

            if(error is Error && stack == null) {
              // TODO: should this ever be the case? Weird...
              stack = error.stackTrace;
            }

            if(stack != null) {
              context.severe(stack.toString());
            }
            return RunResult.EXCEPTION;
          }
        })
        .whenComplete(() {
          final end = new DateTime.now();
          context.finest('Finished at $end');
          final duration = end.difference(start);
          context.finer('Run time: $duration');
        });
  }

  /**
   * [run] exists primarily for testing [Task] implementations.
   *
   * If you want to use Hop in an app, see [runHop].
   *
   * If you want to run a specific [Task] in isolation, see [runTask].
   */
  static Future<RunResult> run(HopConfig config, {Level printAtLogLevel}) {
    requireArgumentNotNull(config, 'config');

    if(config.args.command != null) {
      // we're executing a command
      final subCommandArgResults = config.args.command;
      final taskName = subCommandArgResults.name;

      var tasks = config.taskRegistry.getTaskWithDependencies(taskName);
      assert(tasks.isNotEmpty);

      RunResult finalResult;

      return Future.forEach(tasks.keys, (String subTaskName) {
        if(finalResult != null && finalResult != RunResult.SUCCESS) {
          config.contextPrint('Skipping $subTaskName');
          return null;
        }

        var task = tasks[subTaskName];

        ArgResults args;
        if(subTaskName == taskName) {
          args = subCommandArgResults;
        } else {
          var parser = new ArgParser();
          var subParser = parser.addCommand(subTaskName);
          task.configureArgParser(subParser);
          args = subParser.parse([]);
        }

        return _runNamedTask(subTaskName, task, args, printAtLogLevel, config)
            .then((RunResult rr) {
              finalResult = rr;
            });
      })
      .then((_) {
        assert(finalResult != null);
        return finalResult;
      });

    } else if(config.args.rest.length == 0) {
      _printHelp(config.contextPrint, config.taskRegistry, config.parser);
      return new Future.value(RunResult.SUCCESS);
    } else {
      final taskName = config.args.rest[0];
      config.contextPrint('No task named "$taskName".');
      return new Future.value(RunResult.BAD_USAGE);
    }
  }

  static Future<RunResult> _runNamedTask(String name, Task task,
      ArgResults argResults, Level printAtLogLevel, HopConfig ctx) {

    var subCtx = ctx._getTaskContext(name, argResults);

    return runTask(subCtx, task, printAtLogLevel: printAtLogLevel)
        .then((RunResult result) => _logExitCode(ctx, result))
          .whenComplete(() {
            subCtx.dispose();
          });
  }

  static void runShell(List<String> mainArgs, TaskRegistry registry,
                        String helpTaskName, Level printAtLogLevel) {

    // a bit ugly
    // the help task needs the parser and a print method
    // we can't get those until the help task is created
    // so we use this dummy object which the help task closure holds onto
    // then we update the values before the help task could ever be called
    // sorry. Weird, I know
    final helpArgs = new _HelpArgs(registry);

    // wire up help task
    if(helpTaskName != null) {
      assert(registry._helpTaskName == null);
      registry._helpTaskName = helpTaskName;
      registry.addTask(helpTaskName, _getHelpTask(helpArgs));
    }

    registry._freeze();

    final parser = _getParser(registry, Level.INFO);
    helpArgs.parser = parser;

    ArgResults args;
    try {
      args = tryArgsCompletion(mainArgs, parser);
    } on FormatException catch(ex, stack) {
      // TODO: try to guess if --no-color was passed in here?
      print("There was an error parsing the provided arguments");
      print(ex.message);
      print('');
      _printHelp(print, registry, parser);

      io.exit(RunResult.BAD_USAGE.exitCode);
    }

    final bool useColor = args[_COLOR_FLAG];
    var prefixEnabled = args[_PREFIX_FLAG];
    var minLogLevel = _getLevel(args[_LOG_LEVEL_OPTION]);
    final _ConsolePrinter printer = new _ConsolePrinter(Zone.current.print,
        useColor, minLogLevel, prefixEnabled);

    final config = new HopConfig._internal(registry, parser, args, printer);
    helpArgs.printer = config.contextPrint;

    final future = Runner.run(config, printAtLogLevel: printAtLogLevel);

    future.then((RunResult rr) {
      io.exit(rr.exitCode);
    });
  }

  static RunResult _logExitCode(HopConfig ctx, RunResult result) {
    if(!result.success) {
      final msg = 'Task did not complete - ${result.name} (${result.exitCode})';
      ctx.contextPrint(new ShellString.withColor(msg, AnsiColor.RED));
    }
    return result;
  }


  static Level _getLevel(String logLevelOption) => _sortedLogLevels
      .singleWhere((Level l) => l.name.toLowerCase() == logLevelOption);
}

class _ConsolePrinter extends _ContextLogger {
  final Action1<String> _linePrinter;
  final bool _useColor;
  final Level _minLogLevel;
  final bool _prefixEnabled;

  _ConsolePrinter(this._linePrinter, this._useColor, this._minLogLevel,
      this._prefixEnabled);

  void _print(dynamic value) {
    String line = (value is ShellString) ?
        value.format(_useColor) : value;

    _linePrinter(line);
  }

  void contextPrint(/*String|ShellString*/dynamic value) => _print(value);

  void hopEventListen(HopEvent event) {

    final title = event.logger.join(' - ') + ': ';

    if(event.level >= _minLogLevel) {
      if(_prefixEnabled) {
        final color = _getLogColor(event.level);
        final coloredTitle = new ShellString.withColor(title, color);

        var indent = '';

        while(indent.length < title.length) {
          indent =  indent + ' ';
        }

        final lines = Util.splitLines(event.message);
        var first = true;
        for(final line in lines) {
          if(first) {
            first = false;
            _print(coloredTitle.concat(line));
          } else {
            _print(indent + line);
          }
        }
      } else {
        _print(event.message);
      }
    }
  }

  static AnsiColor _getLogColor(Level logLevel) {
    requireArgumentNotNull(logLevel, 'logLevel');
    if(logLevel.value > Level.WARNING.value) {
      return AnsiColor.RED;
    } else if(logLevel.value > Level.INFO.value) {
      return AnsiColor.LIGHT_RED;
    } else if(logLevel.value >= Level.INFO.value) {
      return AnsiColor.BLUE;
    } else {
      return AnsiColor.GRAY;
    }
  }
}
