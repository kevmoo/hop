part of hop_tasks;

const _listFlag = 'list';
const _summaryFlag = 'summary';
const _summaryAll = 'all';
const _summaryFail = 'fail';
const _summaryPass = 'pass';
const _summaryError = 'error';

Task createUnitTestTask(Action1<unittest.Configuration> unitTestAction) {
  return new Task.async((TaskContext ctx) {

    final summaryFlag = ctx.arguments[_summaryFlag];

    final passSummary =
        (summaryFlag == _summaryAll || summaryFlag == _summaryPass);

    final failSummary =
        (summaryFlag == _summaryAll || summaryFlag == _summaryFail);

    final errorSummary =
        (summaryFlag == _summaryAll || summaryFlag == _summaryError);

    final config = new _HopTestConfiguration(ctx, failSummary, passSummary, errorSummary);

    // TODO: wrap this in a try/catch
    unitTestAction(config);

    if(!ctx.arguments.rest.isEmpty) {
      ctx.info('Filtering tests by: ${ctx.arguments.rest}');

      unittest.filterTests((unittest.TestCase tc) {
        return ctx.arguments.rest.every((arg) => tc.description.contains(arg));
      });
    }

    if(ctx.arguments[_listFlag]) {
      final list = unittest.testCases
          .map((tc) => tc.description)
          .toList();

      list.sort();

      list.insert(0, 'Test cases:');

      ctx.info(list.join('\n'));

      return new Future.value(true);
    }

    unittest.runTests();
    return config.future;
  },
  config: _unittestParserConfig,
  description: 'Run unit tests in the console',
  extendedArgs: [new TaskArgument('filter', multiple: true)]);
}

void _unittestParserConfig(ArgParser parser) {
  parser.addFlag(_listFlag, abbr: 'l', defaultsTo: false,
      help: "Just list the test case names. Don't run them. Any filter is still applied.");
  parser.addOption(_summaryFlag, abbr: 's',
      help: 'Summarize the results of individual tests.',
      allowed: [_summaryAll, _summaryFail, _summaryPass, _summaryError],
      allowMultiple: false);
}

class _HopTestConfiguration implements unittest.Configuration {
  final Completer<bool> _completer = new Completer<bool>();
  final TaskContext _context;
  final bool failSummary;
  final bool passSummary;
  final bool errorSummary;

  _HopTestConfiguration(this._context, this.failSummary, this.passSummary, this.errorSummary);

  Future<bool> get future => _completer.future;

  String get name => 'hop_tasks.unittest';

  bool get autoStart => false;

  /**
   * If true (the default), throw an exception at the end if any tests failed.
   */
  bool throwOnTestFailures = true;

  /**
   * If true (the default), then tests will stop after the first failed
   * [expect]. If false, failed [expect]s will not cause the test
   * to stop (other exceptions will still terminate the test).
   */
  bool stopTestOnExpectFailure = true;

  void onInit() {
    _context.config('config: onInit');
  }

  void onStart() {
    _context.config('config: onStart');
  }

  void onTestStart(unittest.TestCase testCase) {
    _context.config('Starting ${testCase.description}');
  }

  void onLogMessage(unittest.TestCase testCase, String message) {
    final msg = '${testCase.description}\n$message';
    _context.fine(msg);
  }

  void onTestResult(unittest.TestCase testCase) {
    // result should not be null here
    assert(testCase.result != null);

    if(testCase.result == unittest.PASS) {
      _context.info('${testCase.description} -- PASS');
    }
    else {
      _context.severe(
'''[${testCase.result}] ${testCase.description}
${testCase.message}
${testCase.stackTrace}''');
    }

    _context.fine('Duration: ${testCase.runningTime}');
  }

  void onTestResultChanged(unittest.TestCase testCase) {
    _context.severe('Result changed for ${testCase.description}');
    _context.severe(
'''[${testCase.result}] ${testCase.description}
${testCase.message}
${testCase.stackTrace}''');
  }

  void onSummary(int passed, int failed, int errors, List<unittest.TestCase> results,
              String uncaughtError) {
    final bool success = failed == 0 && errors == 0 && uncaughtError == null;
    final message = "$passed PASSED, $failed FAILED, $errors ERRORS";


    if(passSummary) {
      final summaryCtx = _context.getSubLogger('PASS');
      results.where((tc) => tc.result == unittest.PASS).forEach((tc) {
        summaryCtx.info(tc.description);
      });
    }

    if(failSummary) {
      final summaryCtx = _context.getSubLogger('FAIL');
      results.where((tc) => tc.result == unittest.FAIL).forEach((tc) {
        summaryCtx.severe(tc.description);
      });
    }

    if(errorSummary) {
      final summaryCtx = _context.getSubLogger('ERROR');
      results.where((tc) => tc.result == unittest.ERROR).forEach((tc) {
        summaryCtx.severe(tc.description);
      });
    }

    if(success) {
      _context.info(message);
    } else {
      _context.severe(message);
    }
  }

  void onDone(bool success) {
    _completer.complete(success);
  }

  /**
   * Format a test result.
   */
  String formatResult(unittest.TestCase testCase) {
    var result = new StringBuffer();
    result.write(testCase.result.toUpperCase());
    result.write(": ");
    result.write(testCase.description);
    result.write("\n");

    if (testCase.message != '') {
      result.write(_indent(testCase.message));
      result.write("\n");
    }

    if (testCase.stackTrace != null) {
      result.write(_indent(testCase.stackTrace.toString()));
      result.write("\n");
    }
    return result.toString();
  }

  void onExpectFailure(String reason) {
    throw new unittest.TestFailure(reason);
  }

  @override
  @deprecated
  void handleExternalError(error, String message, [String stack = '']) {
    // should never occur in the context of hop runner
    if(unittest.currentTestCase == null) {
      _context.severe('$message\nCaught $error');
      _context.fail('An external error occured in the test suite outside of a Unit Test');
    } else {
      unittest.currentTestCase.error('An external error occured in the test suite during ${unittest.currentTestCase.description}\n$message\nCaught $error');
    }
  }
}

/** Indent each line in [str] by two spaces. */
String _indent(String str) =>
  str.replaceAll(new RegExp("^", multiLine: true), "  ");

