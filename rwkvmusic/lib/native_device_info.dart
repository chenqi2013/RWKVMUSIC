import 'dart:async';
import 'package:flutter/services.dart';

class DeviceInfo {
  static const MethodChannel _channel = MethodChannel('com.example.cpu_info');

  // 获取 CPU 型号
  static Future<String?> getProcessorModel() async {
    try {
      final String? model = await _channel.invokeMethod('getProcessorModel');
      return model;
    } on PlatformException catch (e) {
      print("Failed to get CPU model: '${e.message}'.");
      return null;
    }
  }
}
