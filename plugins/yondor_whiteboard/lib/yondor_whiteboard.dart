import 'dart:async';

import 'package:flutter/services.dart';

class YondorWhiteboard {
  static const MethodChannel _channel =
      const MethodChannel('yondor_whiteboard');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
