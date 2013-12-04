library hop_tasks.shared;

import 'dart:io';

String getPlatformBin(String binName) {
  if(Platform.operatingSystem == 'windows') {
    return '${binName}.bat';
  } else {
    return binName;
  }
}
