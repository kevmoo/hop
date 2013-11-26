part of hop.core;

class _TaskFailError extends Error {
  final String message;

  _TaskFailError(this.message);

  String toString() => "TaskFailError: $message";
}
