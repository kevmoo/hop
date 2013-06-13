# Changelog - Dart Hop Task Management Framework

## 0.23.0-dev *pre-release* (SDK 0.5.17.0 r23893)

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
