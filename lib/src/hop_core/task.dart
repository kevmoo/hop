part of hop.core;

typedef void _ArgParserConfigure(ArgParser);

typedef dynamic _TaskDefinition(TaskContext ctx);

class Task {
  final String description;
  final _TaskDefinition _exec;
  final _ArgParserConfigure _argParserConfig;
  final List<TaskArgument> _extendedArgs;

  /**
   * **DEPRECATED** Use `new Task` instead.
   */
  @deprecated
  factory Task.sync(dynamic taskDefinition(TaskContext ctx),
      {String description, void config(ArgParser),
       List<TaskArgument> extendedArgs}) = Task;

  /**
   * **DEPRECATED** Use `new Task` instead.
   */
  @deprecated
  factory Task.async(Future taskDefinition(TaskContext ctx),
      {String description, void config(ArgParser),
       List<TaskArgument> extendedArgs}) = Task;

  Task(dynamic taskDefinition(TaskContext ctx), {String description,
    void config(ArgParser), List<TaskArgument> extendedArgs}) :
      this._exec = taskDefinition,
      this.description = (description == null) ? '' : description,
      this._argParserConfig = config,
      this._extendedArgs = (extendedArgs == null) ? const [] :
        new UnmodifiableListView(extendedArgs.toList(growable: false)) {
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
  String getExtendedArgsUsage() =>
    _extendedArgs.map((TaskArgument arg) {
      var value = '<${arg.name}>';
      if(arg.multiple) {
        value = value + '...';
      }
      if(!arg.required) {
        value = '[$value]';
      }
      return value;
    }).join(' ');

  @override
  Future run(TaskContext ctx, {Level printAtLogLevel}) {
    requireArgumentNotNull(ctx, 'ctx');

    return new Future.sync(() {
      return runZoned(() => _exec(ctx),
          zoneSpecification: _getZoneSpec(ctx, printAtLogLevel));
    });
  }

  @override
  Task clone({String description}) {
    if(description == null) description = this.description;

    return new Task(_exec, description: description,
        config: _argParserConfig, extendedArgs: _extendedArgs);
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
