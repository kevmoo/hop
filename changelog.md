# Changelog - Dart Hop Task Management Framework

## 0.28.1+1 2013-12-02 (SDK 1.0.1+3 r30657)

* Fixed task code that was still using [TaskContext] instead of [TaskLogger].

## 0.28.1 2013-12-02 (SDK 1.0.1+3 r30657)

* Fixed `addTask` to support dependencies.
* Fixed tests for Drone.

## 0.28.0 2013-12-02 (SDK 1.0.1+3 r30657)

**BREAKING** If you did anything other than create tasks and use `runHop`, you're probably broken.

## 0.27.1 2013-11-08 (SDK 0.8.10+10 r30107)

* Lastest SDK
* Aligned with [Dart V1 Pubspec Recommendations](https://plus.google.com/+SethLadd/posts/9JQJVz78R97).

### hop

* **DEPRECATED** top-level `addSyncTask` and `addAsyncTask`
* Top-level `addTask` now accepts instances of `Task` or `Function`, like `TaskRegistry.addTask`
* Both `addTask` methods support an named `String description` argument.

### hop_tasks

* Added some % output to `bench` task

## 0.27.0 2013-10-31 (SDK 0.8.9 r29656)

* Updates for latest SDK.
* **BREAKING** `runHop` now takes in `List<String> args` to align with changes to `dart:io`.
* **BREAKING** `ConsoleContext` has a similar breaking change.
* `TaskRegistry`
    * **NEW!** `tasks` property exposes a `Map<String, Task>` - this replaces a number of things
    * **NEW!** `addTask` now supports adding tasks by function, replacing `addSync` and `addAsync`.
    * **DEPRECATED** `hasTask`, `addSync`, `addAsync`, `tasks`, `taskNames`
* A bunch of the individual tasks were thrown into their own libraries. Can make use and testing easier.

## 0.26.0 2013-10-29 (SDK 0.8.7 r29341)

* Updates for latest SDK.
* **BEHAVIOR CHANGE** You no longer need to return `true`/`false` to flag success/failure.
    * Return normaling is success.
    * Otherwise, throw an error or call `TaskContext.fail`.
* **DEPRECATED** `TaskDefinition` You probably weren't using it.
* **NEW!** Print within tasks is now logged as `INFO`. You can change this behavior by setting `printAtLogLevel` to `null` in `runHop`
* **DEPRECATED** `Task.async` and `Task.sync` constructors. Just use `new Task` for both cases.

## 0.25.1 2013-09-25 (SDK 0.7.5+3 r27776)

* Tiny updates to `lib/src/hop_tasks/copy_js.dart`
* I'm guessing noone is using this directly yet, so not flagging a breaking change.

## 0.25.0 2013-09-23 (SDK 0.7.5+3 r27776)

* Lastest SDK
* **BREAKING** - Removed optional `allowUnsafeEval` arg from `createDartCompilerTask`

## 0.24.6 2013-09-22 (SDK 0.7.5 r27701)

* Updated min SDK to 0.7.5
* new task `createCopyJSTask`

## 0.24.5 2013-09-17 (SDK 0.7.3 r27487)

* Updated min SDK to 0.7.3
* Tiny tweaks, fixes, etc

## 0.24.4 2013-09-05 (SDK 0.7.1 r27025)

* Updated min SDK to 0.7.1
* Added optional `timeout` option to `createUnitTestTask`

## 0.24.3+2 2013-08-27 (SDK 0.6.21.3 r26639)

* Updated `bot_io` min dependency.

## 0.24.3+1 2013-08-27 (SDK 0.6.21.3 r26639)

* Latest SDK
* New `dart2js` feature for Devon.

## 0.24.3 2013-08-26 (SDK 0.6.21.2 r26619)

* Latest SDK

## 0.24.2 2013-08-10 (SDK 0.6.17.0 r25990)

* Latest SDK

## 0.24.1 2013-07-24 (SDK 0.6.9.2 r25388)

* Latest SDK

# hop_tasks

* `createDartCompilerTask` added optional args
    * `throwOnError: false`
    * `verbose: true`

## 0.24.0 2013-07-19 (SDK 0.6.5.0 r25017)

* **BREAKING** Removed deprecated dart2js method
* Updated SDK dependency to 0.6.5
* Moved to renamed `path` package from `pathos`

## 0.23.0 2013-07-11 (SDK 0.6.3.3 r24898)

* Updated pub dependencies
* Removed reference to deprecated `dart_analyzer`

## 0.22.2 2013-05-28 (SDK 0.5.11.1 r23200)

# Fixes for latest SDK

# hop_tasks

# Deprecated `createDartAnalyzerTask` which uses the old Analyzer
# Added `createAnalyzerTask` which uses the new Analyzer

## 0.22.1+1 2013-05-02 (SDK 0.5.3.0 r22223)

Oops..

## 0.22.1 2013-05-02 (SDK 0.5.3.0 r22223)

Updates for latest SDK

## 0.22.0 2013-04-29 (SDK 0.5.1.0 r22072)

### hop

* Top-level task methods (`addTask`, `addSyncTask`, `addAsyncTask`) return the `Task`
* Analogous methods on `TaskRegistry` also return `Task`

### hop_tasks

* **DEPRECATED** `createDart2JsTask`
* **NEW!** `createDartCompilerTask`
* **BREAKING** Removed unsupported `enable-type-checks` option from `createDartAnalyzerTask`

## 0.21.0 2013-04-17 (SDK 0.4.7+3 r21604)

* Updated to latest SDK
* Removed deprecations. (TODO: provide details)

## 0.20.0 2013-04-10 (SDK 0.4.5+1 r21094)

* The grand split from [BOT](https://github.com/kevmoo/bot.dart) begins.
* See the [BOT Changelog](https://github.com/kevmoo/bot.dart/blob/master/changelog.md) for work leading up to the split.
