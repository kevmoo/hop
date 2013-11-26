part of hop.runner;

class HopConfig {
  final TaskRegistry taskRegistry;
  final ArgParser parser;
  final ArgResults args;
  final Printer _printer;

  /**
   * This constructor exists for testing Hop.
   *
   * If you're using it in another context, you might be doing something wrong.
   */
  factory HopConfig(TaskRegistry registry, List<String> args, Printer printer,
      {Level defaultLogLevel: Level.INFO} ) {
    registry._freeze();

    if(defaultLogLevel == null) defaultLogLevel = Level.INFO;

    final parser = _getParser(registry, defaultLogLevel);
    final argResults = parser.parse(args);

    return new HopConfig._internal(registry, parser, argResults, printer);
  }

  HopConfig._internal(this.taskRegistry, this.parser, this.args, this._printer) {
    taskRegistry._freeze();
    requireArgumentNotNull(args, 'args');
    requireArgumentNotNull(parser, 'parser');
    requireArgumentNotNull(_printer, '_printer');
  }

  void doPrint(Object value) => _printer(value);
}
