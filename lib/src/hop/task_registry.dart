part of hop;

class TaskRegistry {
  static final RegExp _validNameRegExp = new RegExp(r'^[a-z]([a-z0-9_\-]*[a-z0-9])?$');
  static const _RESERVED_TASKS = const[COMPLETION_COMMAND_NAME];

  final SplayTreeMap<String, Task> _tasks;
  final Map<String, Task> tasks;

  factory TaskRegistry() =>
      new TaskRegistry._(new SplayTreeMap<String, Task>());

  TaskRegistry._(SplayTreeMap<String, Task> map) :
    this._tasks = map,
    this.tasks = new UnmodifiableMapView(map);

  String _helpTaskName;
  bool _frozen = false;

  /**
   * **DEPRECATED** Use [tasks.keys] instead.
   */
  List<String> get taskNames {
    _requireFrozen();
    return _tasks.keys.toList();
  }

  /**
   * **DEPRECATED** Use [tasks.containsKey] instead.
   */
  @deprecated
  bool hasTask(String taskName) {
    _requireFrozen();
    return _tasks.containsKey(taskName);
  }

  /**
   * **DEPRECATED** Use [addTask] instead.
   */
  @deprecated
  Task addSync(String name, dynamic func(TaskContext ctx), {String description}) {
    return addTask(name, new Task(func, description: description));
  }

  /**
   * **DEPRECATED** Use [addTask] instead.
   */
  @deprecated
  Task addAsync(String name, Future execFuture(TaskContext ctx), {String description}) {
    return addTask(name, new Task(execFuture, description: description));
  }

  /**
   * [task] can be either an instance of [Task] or a [Function].
   *
   * If [task] is a [Function], it must take one argument: [TaskContext].
   *
   * If a [Future] is returned from the [task] [Function], the runner will wait
   * for the [Future] to complete.
   *
   * If [description] is provided and [task] is an instance of [Task], then
   * [task] will be cloned and given the provided [description].
   */
  Task addTask(String name, dynamic task, {String description} ) {
    require(!isFrozen, "Cannot add a task. Frozen.");
    _validateTaskName(name);
    requireArgument(!_tasks.containsKey(name), 'task',
        'A task with name ${name} already exists');

    requireArgumentNotNull(task, 'task');

    if(task is Task) {
      if(description != null) {
        task = task.clone(description: description);
      }
    } else {
      // wrap it?
      task = new Task(task, description: description);
    }

    _tasks[name] = task;
    return task;
  }

  ChainedTask addChainedTask(String name, Iterable<String> existingTaskNames,
                             {String description}) {
    final list = $(existingTaskNames)
        .map((String subName) {
          var task = _tasks[subName];
          require(task != null, 'The task "$subName" has not be registered');
          return new _NamedTask(subName, task);
        })
        .toReadOnlyCollection();

    if(description == null) {
      description = 'Chained Task: ' + list.map((t) => t.name).join(', ');
    }

    return addTask(name, new ChainedTask._impl(list, description: description));
  }

  void _requireFrozen() {
    if(!isFrozen) {
      throw new StateError("Operation not allowed unless frozen.");
    }
  }

  void _freeze() {
    if(!isFrozen) {
      _frozen = true;
    }
  }

  bool get isFrozen => _frozen;

  static void _validateTaskName(String name) {
    requireArgumentNotNullOrEmpty(name, 'name');
    requireArgumentContainsPattern(_validNameRegExp, name, 'name');
    requireArgument(!_RESERVED_TASKS.contains(name), 'task',
        'The provided task has a reserved name');
  }
}
