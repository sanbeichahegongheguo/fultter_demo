import 'package:flutter/services.dart';

///
/// 远大通道类
///
class YondorChannel {
  static const MethodChannel _channel = const MethodChannel('yondor');

  ///detectxy 手写识别
  static Future<String> detectxy(String pos,int thickness,bool isSave) async{
    Map<String, dynamic> params = new Map();
    params["pos"] = pos;
    params["thickness"] = thickness;
    params["isSave"] = isSave??false;
    var result = await _channel.invokeMethod("detectxy",params);
    return result;
  }
}
