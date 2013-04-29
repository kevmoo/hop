part of hop;

class TaskRegistry {
  static final RegExp _validNameRegExp = new RegExp(r'^[a-z]([a-z0-9_\-]*[a-z0-9])?$');
  static const _reservedTasks = const[COMPLETION_COMMAND_NAME];
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

  Task addSync(String name, Func1<TaskContext, bool> func, {String description}) {
    return addTask(name, new Task.sync(func, description: description));
  }

  Task addAsync(String name, TaskDefinition execFuture, {String description}) {
    return addTask(name, new Task.async(execFuture, description: description));
  }

  Task addTask(String name, Task task) {
    require(!isFrozen, "Cannot add a task. Frozen.");
    _validateTaskName(name);
    requireArgument(!_tasks.containsKey(name), 'task',
        'A task with name ${name} already exists');

    requireArgumentNotNull(task, 'task');
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
    requireArgument(!_reservedTasks.contains(name), 'task',
        'The provided task has a reserved name');
  }
}
