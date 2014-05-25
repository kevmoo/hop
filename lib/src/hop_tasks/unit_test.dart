@deprecated
library hop_tasks.unit_test;

import 'package:hop/hop_core.dart';
import 'package:hop_unittest/hop_unittest.dart' as hut;

/// **DEPRECATED**. Use `hop_unittest` package instead.
///
/// Creates a [Task] which runs the unit tests defined by [unitTestAction].
///
/// [unitTestAction] should be in the form `void function()`.
///
/// [unitTestAction] in the form `void function(Configuration config)` is
/// deprecated.
@deprecated
Task createUnitTestTask(Function unitTestAction,
                      {Duration timeout: const Duration(seconds: 20)}) {

  return hut.createUnitTestTask(unitTestAction, timeout: timeout);
}
