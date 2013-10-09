part of hop;

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

class _TaskContext extends TaskContext implements _LoggerParent, _LoggerChild {
  final String _name;
  final _LoggerParent _parent;
  final ArgResults arguments;

  bool _isDisposed = false;

  _TaskContext(this._parent, this._name, this.arguments);

  @override
  _TaskContext getSubContext(String name) {
    return new _TaskContext(this, name, null);
  }

  @override
  bool get isDisposed => _isDisposed;

  @override
  void log(Level logLevel, String message) {
    _assertNotDisposed();
    _parent._childLog(this, logLevel, message);
  }

  @override
  void dispose() {
    _assertNotDisposed();
    _isDisposed = true;
  }

  void _childLog(_LoggerChild logger, Level logLevel, String message) {
    _assertNotDisposed();
    // logger should be a descendant
    _parent._childLog(logger, logLevel, message);
  }

  void _assertNotDisposed() {
    if(_isDisposed) {
      throw new DisposedError();
    }
  }
}

abstract class _LoggerChild {
  String get _name;
  _LoggerParent get _parent;
}

abstract class _LoggerParent {
  void _childLog(_LoggerChild child, Level level, String msg);
}
