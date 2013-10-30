part of hop;

class TaskRegistry {
  static final RegExp _validNameRegExp = new RegExp(r'^[a-z]([a-z0-9_\-]*[a-z0-9])?$');
  static const _RESERVED_TASKS = const[COMPLETION_COMMAND_NAME];
  final Map<String, Task> _tasks = new Map<String, Task>();

  String _helpTaskName;
  ReadOnlyCollection<String> _sortedTaskNames;

  /**
   * Can only be accessed when frozen
   * Always sorted
   */
  Sequence<String> get taskNames {
    _requireFrozen();
    return _sortedTaskNames;
  }

  bool hasTask(String taskName) {
    _requireFrozen();
    return _tasks.containsKey(taskName);
  }

  @deprecated
  Task addSync(String name, dynamic func(TaskContext ctx), {String description}) {
    return addTask(name, new Task(func, description: description));
  }

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
   */
  Task addTask(String name, dynamic task) {
    require(!isFrozen, "Cannot add a task. Frozen.");
    _validateTaskName(name);
    requireArgument(!_tasks.containsKey(name), 'task',
        'A task with name ${name} already exists');

    requireArgumentNotNull(task, 'task');

    if(task is! Task) {
      // wrap it?
      task = new Task(task);
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
      throw "not frozen!";
    }
  }

  void _freeze() {
    if(!isFrozen) {
      final list = _tasks.keys
          .toList()
          ..sort();
      _sortedTaskNames = new ReadOnlyCollection<String>.wrap(list);
    }
  }

  bool get isFrozen => _sortedTaskNames != null;

  Task _getTask(String taskName) {
    return _tasks[taskName];
  }

  static void _validateTaskName(String name) {
    requireArgumentNotNullOrEmpty(name, 'name');
    requireArgumentContainsPattern(_validNameRegExp, name, 'name');
    requireArgument(!_RESERVED_TASKS.contains(name), 'task',
        'The provided task has a reserved name');
  }
}
