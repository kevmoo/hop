library hop_tasks.unit_test;

import 'dart:async';
import 'package:args/args.dart';
import 'package:bot/bot.dart';
import 'package:hop/hop.dart';
import 'package:unittest/unittest.dart' as unittest;

const _LIST_FLAG = 'list';
const _SUMMARY_FLAG = 'summary';
const _SUMMARY_ALL = 'all';
const _SUMARY_FAIL = 'fail';
const _SUMMARY_PASS = 'pass';
const _SUMMARY_ERROR = 'error';

Task createUnitTestTask(Action1<unittest.Configuration> unitTestAction,
                        {Duration timeout: const Duration(seconds: 20)}) {
  return new Task((TaskContext ctx) {

    final summaryFlag = ctx.arguments[_SUMMARY_FLAG];

    final passSummary =
        (summaryFlag == _SUMMARY_ALL || summaryFlag == _SUMMARY_PASS);

    final failSummary =
        (summaryFlag == _SUMMARY_ALL || summaryFlag == _SUMARY_FAIL);

    final errorSummary =
        (summaryFlag == _SUMMARY_ALL || summaryFlag == _SUMMARY_ERROR);

    final config = new _HopTestConfiguration(ctx, failSummary, passSummary,
        errorSummary, timeout);

    // TODO: wrap this in a try/catch
    unitTestAction(config);

    if(!ctx.arguments.rest.isEmpty) {
      ctx.info('Filtering tests by: ${ctx.arguments.rest}');

      unittest.filterTests((unittest.TestCase tc) {
        return ctx.arguments.rest.every((arg) => tc.description.contains(arg));
      });
    }

    if(ctx.arguments[_LIST_FLAG]) {
      final list = unittest.testCases
          .map((tc) => tc.description)
          .toList();

      list.sort();

      list.insert(0, 'Test cases:');

      ctx.info(list.join('\n'));

      return new Future.value();
    }

    unittest.runTests();
    return config.future;
  },
  config: _unittestParserConfig,
  description: 'Run unit tests in the console',
  extendedArgs: [new TaskArgument('filter', multiple: true)]);
}

void _unittestParserConfig(ArgParser parser) {
  parser.addFlag(_LIST_FLAG, abbr: 'l', defaultsTo: false,
      help: "Just list the test case names. Don't run them. Any filter is still applied.");
  parser.addOption(_SUMMARY_FLAG, abbr: 's',
      help: 'Summarize the results of individual tests.',
      allowed: [_SUMMARY_ALL, _SUMARY_FAIL, _SUMMARY_PASS, _SUMMARY_ERROR],
      allowMultiple: false);
}

class _HopTestConfiguration extends unittest.Configuration {
  final Completer<bool> _completer = new Completer<bool>();
  final TaskContext _context;
  final bool failSummary;
  final bool passSummary;
  final bool errorSummary;
  final Duration timeout;

  _HopTestConfiguration(this._context, this.failSummary, this.passSummary,
      this.errorSummary, this.timeout) : super.blank();

  Future get future => _completer.future;

  bool get autoStart => false;

  @override
  void onInit() {
    _context.config('config: onInit');
  }

  @override
  void onStart() {
    _context.config('config: onStart');
  }

  @override
  void onTestStart(unittest.TestCase testCase) {
    _context.config('Starting ${testCase.description}');
  }

  @override
  void onLogMessage(unittest.TestCase testCase, String message) {
    String msg;
    if(testCase != null) {
      msg = '${testCase.description}\n$message';
    } else {
      msg = message;
    }
    _context.fine(msg);
  }

  @override
  void onTestResult(unittest.TestCase testCase) {
    // result should not be null here
    assert(testCase.result != null);

    if(testCase.result == unittest.PASS) {
      _context.info('${testCase.description} -- PASS');
    } else {
      var msg = '''[${testCase.result}] ${testCase.description}
${testCase.message}''';
      if(testCase.stackTrace != null) {
        msg = msg + '''
${testCase.stackTrace}''';
      }
      _context.severe(msg);
    }

    _context.fine('Duration: ${testCase.runningTime}');
  }

  @override
  void onTestResultChanged(unittest.TestCase testCase) {
    _context.severe('Result changed for ${testCase.description}');
    _context.severe(
'''[${testCase.result}] ${testCase.description}
${testCase.message}
${testCase.stackTrace}''');
  }

  @override
  void onSummary(int passed, int failed, int errors, List<unittest.TestCase> results,
              String uncaughtError) {
    final bool success = failed == 0 && errors == 0 && uncaughtError == null;
    final message = "$passed PASSED, $failed FAILED, $errors ERRORS";


    if(passSummary) {
      final summaryCtx = _context.getSubContext('PASS');
      results.where((tc) => tc.result == unittest.PASS).forEach((tc) {
        summaryCtx.info(tc.description);
      });
    }

    if(failSummary) {
      final summaryCtx = _context.getSubContext('FAIL');
      results.where((tc) => tc.result == unittest.FAIL).forEach((tc) {
        summaryCtx.severe(tc.description);
      });
    }

    if(errorSummary) {
      final summaryCtx = _context.getSubContext('ERROR');
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

  @override
  void onDone(bool success) {
    if(success) {
      _completer.complete();
    } else {
      _completer.completeError('The unittest system did not complete with success.');
    }
  }
}

/** Indent each line in [str] by two spaces. */
String _indent(String str) =>
  str.replaceAll(new RegExp("^", multiLine: true), "  ");
