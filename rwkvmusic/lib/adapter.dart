import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Adapter {
  static const _channel = MethodChannel('universal');

  static Future<T?> call<T>(ToNative toNative, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(toNative.name, arguments);
    } catch (e) {
      if (kDebugMode) print("😡 $e");
      return null;
    }
  }
}

enum FromNative {
  none,
}

enum ToNative {
  getAssetPath,
  listAllAssets,
}
