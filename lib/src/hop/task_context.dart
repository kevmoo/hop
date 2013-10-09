part of hop;

abstract class TaskContext extends TaskLogger implements Disposable {
  ArgResults get arguments;

  @deprecated
  TaskLogger getSubLogger(String name) => getSubContext(name);

  TaskContext getSubContext(String name);

  /**
   * Terminates the current [Task] with a failure, explained by [message].
   */
  void fail(String message) {
    throw new _TaskFailError(message);
  }
}
