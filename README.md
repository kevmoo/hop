# HOP
## An object-oriented framework creating and reusing scripts in Dart.

[![Build Status](https://drone.io/github.com/kevmoo/hop.dart/status.png)](https://drone.io/github.com/kevmoo/hop.dart/latest)

# Projects using HOP

* [chrome.dart](https://github.com/dart-gde/chrome.dart) - Dart interop with chrome.* APIs for Chrome Packaged Apps
* [Pop, Pop, Win!](https://github.com/dart-lang/pop-pop-win) - Minesweeper with balloons
* [qr.dart](https://github.com/kevmoo/qr.dart) - Generate QR codes
* [vote.dart](https://github.com/kevmoo/vote.dart) - Simulate, run, and calculate elections with different election methods
* [Dart Widgets](https://github.com/kevmoo/widget.dart) - Reusable Web Components

# Try It Now

The __The HOP task management system for Dart__ is hosted on [pub.dartlang.org](http://pub.dartlang.org/packages/hop). Add the __HOP__ package to your `pubspec.yaml` file, selecting a version range that works with your version of the SDK. _Always check the [HOP page](http://pub.dartlang.org/packages/hop) on pub to find the latest release._

See the [changelog](https://github.com/kevmoo/hop.dart/blob/master/changelog.md) to find the version that works best for you.

If you'd like to track bleeding edge developments, you can reference the the [GitHub repository](https://github.com/kevmoo/hop.dart) directly:
```yaml
dependencies:
  hop:
    git: https://github.com/kevmoo/hop.dart.git
```

# Versioning

* We follow [Semantic Versioning](http://semver.org/).
* We are not planning a V1 for __HOP__ until Dart releases V1.
	* In the mean time, the version will remain `0.Y.Z`.
	* Changes to the _minor_ version - Y - will indicate breaking changes.
	* Changes to the _patch_ version - Z - indicate non-breaking changes.

# Dart SDK dependency

* We're going to try to keep __HOP__ in line with the [latest integration build](https://gsdview.appspot.com/dart-editor-archive-integration/latest/) of the Dart SDK and Editor.
* At this point, each SDK release tends to introduce breaking changes, which usually require breaking changes in __HOP__.
* Keep an eye on the [changelog](https://github.com/kevmoo/hop.dart/blob/master/changelog.md) to see how __HOP__ aligns with each SDK release. 

# The libraries

## hop - core task runtime
  * An object-oriented framework creating and reusing scripts in Dart.
  * Easy to create command-line scripts.
  * Define functionality in libraries. Add and update them with `pub`.
  * Nice touches for free: bash command completion, help, helpful exit codes

## hop_tasks
  * A collection of tasks and task helpers.
  * Unit tests
  * dart2js
  * dartdoc
  * git

# Authors
 * [Kevin Moore](https://github.com/kevmoo) ([+Kevin Moore](https://plus.google.com/110066012384188006594/), [@kevmoo](http://twitter.com/kevmoo))
 * [Adam Singer](https://github.com/financeCoding) ([+Adam Singer](https://plus.google.com/104569492481999771226))
 * [Damon Douglas](https://github.com/damondouglas) ([+Damon Douglas](https://plus.google.com/u/0/108940381045821372455/))
 * _You? File bugs. Fork and Fix bugs. Let's build this community._
