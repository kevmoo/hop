part of hop.core;

typedef void ArgParserConfigure(ArgParser);

abstract class Task {

  final String description;

  Task._impl(String description) :
      this.description = (description == null) ? '' : description;

  /**
   * **DEPRECATED** Use `new Task` instead.
   */
  @deprecated
  factory Task.sync(Func1<TaskContext, dynamic> exec, {String description,
    ArgParserConfigure config, List<TaskArgument> extendedArgs}) = _SimpleTask;

  /**
   * **DEPRECATED** Use `new Task` instead.
   */
  @deprecated
  factory Task.async(Future exec(TaskContext ctx), {String description,
    ArgParserConfigure config, List<TaskArgument> extendedArgs}) = _SimpleTask;

  factory Task(dynamic exec(TaskContext ctx), {String description,
    ArgParserConfigure config, List<TaskArgument> extendedArgs}) = _SimpleTask;

  Future run(TaskContext ctx, {Level printAtLogLevel});

  Task clone({String description});

  void configureArgParser(ArgParser parser);

  String getExtendedArgsUsage();

  String getUsage();
}

class _SimpleTask extends Task {
  final _TaskDefinition _exec;
  final ArgParserConfigure _argParserConfig;
  final ReadOnlyCollection<TaskArgument> _extendedArgs;

  _SimpleTask(this._exec, {String description, ArgParserConfigure config,
    List<TaskArgument> extendedArgs}) :
    this._argParserConfig = config,
    this._extendedArgs = extendedArgs == null ?
        const ReadOnlyCollection<TaskArgument>.empty() :
          new ReadOnlyCollection<TaskArgument>(extendedArgs),
    super._impl(description) {
    requireArgumentNotNull(_exec, '_exec');
    TaskArgument.validateArgs(_extendedArgs);
  }

  @override
  void configureArgParser(ArgParser parser) {
    if(_argParserConfig != null) {
      _argParserConfig(parser);
    }
  }

  @override
  String getUsage() {
    final parser = new ArgParser();
    configureArgParser(parser);
    return parser.getUsage();
  }

  @override
  String getExtendedArgsUsage() {
    return _extendedArgs.map((TaskArgument arg) {
      var value = '<${arg.name}>';
      if(arg.multiple) {
        value = value + '...';
      }
      if(!arg.required) {
        value = '[$value]';
      }
      return value;
    }).join(' ');
  }

  @override
  Future run(TaskContext ctx, {Level printAtLogLevel}) {
    requireArgumentNotNull(ctx, 'ctx');

    return new Future.sync(() {
      return runZoned(() => _exec(ctx),
          zoneSpecification: _getZoneSpec(ctx, printAtLogLevel));
    });
  }

  @override
  _SimpleTask clone({String description}) {
    if(description == null) description = this.description;

    return new _SimpleTask(_exec, description: description,
        config: _argParserConfig);
  }

  @override
  String toString() => "Task: $description";
}

ZoneSpecification _getZoneSpec(TaskContext ctx, Level printAtLevel) {
  if(printAtLevel == null) return null;

  return new ZoneSpecification(print: (a,b,c,String line) {
    ctx.log(printAtLevel, line);
  });
}
