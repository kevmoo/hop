part of hop.core;

typedef void Printer(Object value);

class RootTaskContext implements _LoggerParent{
  static final _childNameChainExpando =
      new Expando<List<String>>('child names');

  final Printer _printer;
  final bool _prefixEnabled;
  final Level _minLogLevel;

  RootTaskContext(Printer printer,
      {bool prefixEnabled: true,
    Level minLogLevel: Level.ALL}) :
    _printer = printer,
    _prefixEnabled = prefixEnabled,
    _minLogLevel = minLogLevel {
      requireArgumentNotNull(printer, 'printer');
      requireArgumentNotNull(prefixEnabled, 'prefixEnabled');
      requireArgumentNotNull(minLogLevel, 'minLogLevel');
    }

  TaskContext getSubContext(String name, ArgResults arguments) =>
    new _TaskContext(this, name, arguments);

  void log(Object message) {
    _printer(message);
  }

  // NOTE: just a throw-away to implement _LoggerParent correctly
  bool get isDisposed => false;

  @override
  void _childLog(_LoggerChild subTask, Level logLevel, String message) {
    List<String> names = _childNameChainExpando[subTask];

    if(names == null) {
      final chain = _getParentChain(subTask);

      _childNameChainExpando[subTask] = names =
          chain.map((i) => i._name).toList();
    }

    _logCore(names, logLevel, message);
  }

  void _logCore(List<String> titleSections, Level logLevel, String message) {
    requireArgumentNotNull(message, 'message');
    assert(!titleSections.isEmpty);
    assert(titleSections.every((s) => s != null && !s.isEmpty));

    final title = titleSections.join(' - ') + ': ';

    if(logLevel >= _minLogLevel) {
      if(_prefixEnabled) {
        final color = getLogColor(logLevel);
        final coloredTitle = new ShellString.withColor(title, color);

        var indent = '';

        while(indent.length < title.length) {
          indent =  indent + ' ';
        }

        final lines = Util.splitLines(message);
        var first = true;
        for(final line in lines) {
          if(first) {
            first = false;
            _printer(coloredTitle.concat(line));
          } else {
            _printer(indent + line);
          }
        }
      } else {
        _printer(message);
      }
    }

    _libLogger.log(logLevel, "$title $message");
  }

  List<_LoggerChild> _getParentChain(_LoggerChild child) {
    final list = new List<_LoggerChild>();

    _LoggerParent parent;

    do {
      list.insert(0, child);
      parent = child._parent;
      if(parent is _LoggerChild) {
        child = parent as _LoggerChild;
      } else {
        // once we find something in the chain that's not a child
        // it should be 'this' -- the root task context
        assert(parent == this);
        child = null;
      }
    } while(child != null);

    return list;
  }

  static AnsiColor getLogColor(Level logLevel) {
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
  bool get isDisposed => _isDisposed || _parent.isDisposed;

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
