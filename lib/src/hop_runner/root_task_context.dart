part of hop.runner;

AnsiColor _getLogColor(Level logLevel) {
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

// TODO: test dispose case - should bubble up an RunResult.ERROR
class _TaskContext extends _LoggerChild with TaskContext {
  final ArgResults arguments;

  _TaskContext(_LoggerParent parent, String name, [this.arguments]) :
    super(parent, name);
}

class _LoggerChild extends TaskLogger implements _LoggerParent {
  final _LoggerParent _parent;
  final String _name;

  _LoggerChild(this._parent, this._name) {
    assert(_name != null);
  }

  @override
  bool get isDisposed => super.isDisposed || _parent.isDisposed;

  @override
  void log(Level logLevel, String message) {
    requireNotDisposed();
    _parent._childLog(this, logLevel, message);
  }

  @override
  TaskLogger getSubLogger(String name) {
    requireNotDisposed();
    return new _LoggerChild(this, name);
  }

  /**
   * **DEPRECATED** Use [getSubLogger] instead.
   */
  @deprecated
  TaskContext getSubContext(String name) =>
      new _DeprecatedSubTaskContext(this, name);

  void _childLog(_LoggerChild logger, Level logLevel, String message) {
    requireNotDisposed();
    // logger should be a descendant
    _parent._childLog(logger, logLevel, message);
  }
}

class _DeprecatedSubTaskContext extends _TaskContext {
  _DeprecatedSubTaskContext(_LoggerParent parent, String name) :
    super(parent, name);
}

abstract class _LoggerParent {
  void _childLog(_LoggerChild child, Level level, String msg);
  bool get isDisposed;
}
