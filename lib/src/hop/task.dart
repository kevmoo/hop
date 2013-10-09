part of hop;

typedef void ArgParserConfigure(ArgParser);

abstract class Task {
  static const _nullFutureResultEx = 'null-future-result-silly';

  final String description;

  Task._impl(String description) :
    this.description = (description == null) ? '' : description;

  factory Task.sync(Func1<TaskContext, dynamic> exec, {String description,
    ArgParserConfigure config, List<TaskArgument> extendedArgs}) {
    final futureExec = (TaskContext ctx) => new Future.sync(() => exec(ctx));

    return new Task.async(futureExec,
        description: description, config: config, extendedArgs: extendedArgs);
  }

  factory Task.async(TaskDefinition exec, {String description,
    ArgParserConfigure config, List<TaskArgument> extendedArgs}) {

    return new _SimpleTask(exec, description: description, config: config,
        extendedArgs: extendedArgs);
  }

  Future run(TaskContext ctx);

  ChainedTask chain(String name) {
    return new ChainedTask._internal(name, this);
  }

  void configureArgParser(ArgParser parser);

  String getExtendedArgsUsage();

  String getUsage();
}

class _SimpleTask extends Task {
  final TaskDefinition _exec;
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
  Future run(TaskContext ctx) {
    requireArgumentNotNull(ctx, 'ctx');

    return new Future.sync(() => _exec(ctx));
  }

  @override
  String toString() => "Task: $description";
}

class _NamedTask {
  final Task task;
  final String name;
  _NamedTask(this.name, this.task) {
    assert(task != null);
    TaskRegistry._validateTaskName(name);
  }
}

class ChainedTask extends Task {
  final ReadOnlyCollection<_NamedTask> _tasks;

  factory ChainedTask._internal(String name, Task task, [ChainedTask previous]) {
    final nt = new _NamedTask(name, task);

    var roc = $(_expand(previous, nt)).toReadOnlyCollection();
    return new ChainedTask._impl(roc);
  }

  ChainedTask._impl(this._tasks, {String description: 'Chained Task'}) : super._impl(description);

  @override
  void configureArgParser(ArgParser parser) {
    // for now, nothing
  }

  // TODO: how to approach this...
  @override
  String getExtendedArgsUsage() => '';

  // TODO: how to approach this...
  @override
  String getUsage() => '';

  @override
  Future run(TaskContext ctx) {
    requireArgumentNotNull(ctx, 'ctx');

    return _run(ctx);
  }

  ChainedTask and(String name, Task task) {
    return new ChainedTask._internal(name, task, this);
  }

  static Iterable<_NamedTask> _expand(ChainedTask previous, _NamedTask task) {
    if(previous == null) {
      return [task];
    }
    return $(previous._tasks).concat([task]);
  }

  Future _run(TaskContext ctx, [int index = 0]) {
    assert(index >= 0);
    assert(index <= _tasks.length);

    if(index == _tasks.length) {
      return new Future.value();
    }

    final namedTask = _tasks[index];

    // TODO: passing in args?
    var subCtx = ctx.getSubContext(namedTask.name);

    return namedTask.task.run(subCtx)
        .then((_) => _run(ctx, index + 1));
  }
}
