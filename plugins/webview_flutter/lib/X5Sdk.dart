import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class X5Sdk {
  static const MethodChannel _channel = const MethodChannel('plugins.flutter.io/webview');

  ///加载内核，没有内核会自动下载,加载失败会自动调用系统内核
  static Future<bool> init() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool res = await _channel.invokeMethod("init");
      return res;
    } else {
      return false;
    }
  }

  ///是否能直接使用x5内核播放视频
  static Future<bool> canUseTbsPlayer() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool res = await _channel.invokeMethod("canUseTbsPlayer");
      return res;
    } else {
      return false;
    }
  }

  ///screenMode 播放参数，103横屏全屏，104竖屏全屏。默认103
  static Future<void> openVideo(String url, {int screenMode}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'screenMode': screenMode ?? 103,
        'url': url
      };
      return await _channel.invokeMethod("openVideo", params);
    } else {
      return;
    }
  }
}