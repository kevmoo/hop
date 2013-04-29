# Changelog - Dart Hop Task Management Framework

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
