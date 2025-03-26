// We found that on Linux (Ubuntu x86_64)
// the messages received for webview_cef are like: ""message""
// but the expected message is "message"
// So I create this function

import 'dart:io';

extension ToLinuxMessage on String {
  String get toLinux {
    if (!Platform.isLinux) return this;
    if (startsWith("\"") && endsWith("\"")) return substring(1, length - 1);
    return this;
  }
}
