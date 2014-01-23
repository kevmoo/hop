library hop_tasks.shared;

import 'dart:io';

/**
 * Used by scripts which invoke the build-in Dart commands.
 *
 * On windows, some commands end with '.bat'.
 *
 * This handles things transparently.
 */
String getPlatformBin(String binName) {
  if (Platform.operatingSystem == 'windows') {
    return '${binName}.bat';
  } else {
    return binName;
  }
}
