part of hop.runner;

abstract class _ContextLogger {
  /**
   * [value] must be either [String] or [ShellString].
   */
  void contextPrint(dynamic value);

  void hopEventListen(HopEvent event);
}

class HopConfig implements _LoggerParent, _ContextLogger {
  static final _childNameChainExpando =
      new Expando<List<String>>('child names');

  final TaskRegistry taskRegistry;
  final ArgParser parser;
  final ArgResults args;
  final _ContextLogger _printer;
  final StreamController<HopEvent> _eventController =
      new StreamController<HopEvent>.broadcast(sync:true);

  /**
   * This constructor exists for testing Hop.
   *
   * If you're using it in another context, you might be doing something wrong.
   *
   * [printer] needs to handle values of type [String] and [ShellString], other
   * values should cause an [ArgumentError];
   */
  factory HopConfig(TaskRegistry registry, List<String> args) {

    requireArgumentNotNull(registry, 'registry');
    requireArgumentNotNull(args, 'args');

    registry._freeze();

    final parser = _getParser(registry, Level.INFO);
    final argResults = parser.parse(args);

    return new HopConfig._internal(registry, parser, argResults);
  }

  HopConfig._internal(this.taskRegistry, this.parser, ArgResults args,
      [this._printer]) :
    this.args = args {
    taskRegistry._freeze();
    assert(args != null);
    assert(parser != null);
  }

  // NOTE: just a throw-away to implement _LoggerParent correctly
  bool get isDisposed => false;

  Stream<HopEvent> get onEvent => _eventController.stream;

  void contextPrint(dynamic value) {
    if(_printer != null) _printer.contextPrint(value);

    if(_eventController.hasListener) {
      String val = (value is ShellString) ? value.format(false) : value;
      _eventController.add(new HopEvent.print(val));
    }
  }

  void hopEventListen(HopEvent event) {
    if(_printer != null) _printer.hopEventListen(event);

    if(_eventController.hasListener) _eventController.add(event);
  }

  void _childLog(_LoggerChild subTask, Level logLevel, String message) {
    List<String> names = _childNameChainExpando[subTask];

    if(names == null) {
      final chain = _getParentChain(subTask);

      _childNameChainExpando[subTask] = names =
          chain.map((i) => i._name).toList();
    }

    hopEventListen(new HopEvent(logLevel, message, names));
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
}
