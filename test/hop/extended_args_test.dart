library test.hop.extended_args;

import 'package:unittest/unittest.dart';
import 'package:hop/hop_core.dart';

void main() {

  test('valid ctor args', () {
    final valid = ['a', 'a-b', 'a-cool-name', 'a7', 'b2b'];
    for(final v in valid) {
      expect(() => new TaskArgument(v), returnsNormally);
    }

    final invalid = ['', null, ' ', '-', 'A', 'a-', 'a-B', 'a_b', 'a ', 'a b', '7', '7a'];
    for(final v in invalid) {
      expect(() => new TaskArgument(v), throwsArgumentError);
    }

    expect(() => new TaskArgument('cool', required: null), throwsArgumentError);
    expect(() => new TaskArgument('cool', multiple: null), throwsArgumentError);
  });

  test('validate arg list', () {

    // empty is fine
    _validateExtendedArgs([], true);

    _validateExtendedArgs(null, false);

    // null arg is bad
    _validateExtendedArgs([null], false);

    // first required is fine
    _validateExtendedArgs([new TaskArgument('a', required: true)], true);

    // first required and mult is fine
    _validateExtendedArgs([new TaskArgument('a', required: true, multiple: true)], true);

    // first required, second not required is fine
    _validateExtendedArgs([new TaskArgument('a', required: true), new TaskArgument('b', required: false)], true);

    // first not required, second required is bad
    _validateExtendedArgs([new TaskArgument('a', required: false), new TaskArgument('b', required: true)], false);

    // last multiple is fine
    _validateExtendedArgs([new TaskArgument('a', multiple: false), new TaskArgument('b', multiple: true)], true);

    // 'N' multiple, 'N+1' non-multiple is not fine
    _validateExtendedArgs([new TaskArgument('a', multiple: true), new TaskArgument('b', multiple: false)], false);

    // dupe names is not fine
    _validateExtendedArgs([new TaskArgument('a'), new TaskArgument('a')], false);
  });
}

void _validateExtendedArgs(List<TaskArgument> args, bool isGood) {
  var matcher = isGood ? returnsNormally : throwsArgumentError;
  expect(() => TaskArgument.validateArgs(args), matcher);
}

