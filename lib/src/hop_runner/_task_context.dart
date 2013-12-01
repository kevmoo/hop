part of hop.runner;

// TODO: test dispose case - should bubble up an RunResult.ERROR
class _TaskContext extends _LoggerChild with TaskContext {
  final ArgResults arguments;
  final Map<String, dynamic> extendedArgs;

  _TaskContext(_LoggerParent parent, String name, this.arguments,
      this.extendedArgs) :
    super(parent, name) {
    assert(arguments != null);
    assert(extendedArgs != null);
  }

  // NOTE: arguments and extendedArgs are only allowed null here to support
  //       _DeprecatedSubTaskContext. Should be required when subclass is removed
  _TaskContext.deprecatedSubTaskCtor(_LoggerParent parent, String name) :
    this.arguments = null,
    this.extendedArgs = const {},
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
    super.deprecatedSubTaskCtor(parent, name);
}

abstract class _LoggerParent {
  void _childLog(_LoggerChild child, Level level, String msg);
  bool get isDisposed;
}
