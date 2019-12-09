import 'package:flutter/services.dart';

class Camera {
  static const MethodChannel _channel = const MethodChannel('plugins.yondor/camera');


  ///openCamera 打开相机
  static Future<String> openCamera({Map param}) async{
    var result = await _channel.invokeMethod("open",param);
    return result;
  }
}