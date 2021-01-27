import 'dart:io';

import 'package:flutter/services.dart';

enum PlayerPhase {
  waitingFirstFrame, //等待第一帧
  playing, //播放状态
  pause, //暂停状态
  stopped, //停止
  ended, //播放结束
  buffering,
}

enum Appliance {
  pencil, //铅笔
  selector, //选择工具
  rectangle, //矩形绘制工具
  ellipse, //圆、椭圆绘制工具
  eraser, //橡皮，用于擦除其他教具绘制的笔迹
  text, //文字工具
  straight, //直线绘制工具
  arrow, //	箭头绘制工具
  hand, //抓手工具
  laserPointer, //激光笔工具
}

class WhiteboardController {
  Function(bool data) onCreated;
  Function(bool data) replayPlay;
  Function(String data) onPhaseChanged;
  Function(String data) onRoomPhaseChanged; //房间连接状态变化
  Function(String data) onApplianceChanged; //房间连接状态变化
  Function(int time) onScheduleTimeChanged;
  MethodChannel _channel;

  setChannel(MethodChannel c) {
    _channel = c;
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future updateRoom({int isBoardLock}) {
    var param = {};
    if (null != isBoardLock) {
      param["isBoardLock"] = isBoardLock;
    }
    return _channel.invokeMethod("updateRoom", param);
  }

  Future setWritable(bool isWritable) {
    var param = {};
    if (null != isWritable) {
      param["isWritable"] = isWritable ? 1 : 0;
    }
    return _channel.invokeMethod("setWritable", param);
  }

  Future startReplay({int beginTimestamp, int duration, String mediaURL}) {
    if (Platform.isIOS) {
      beginTimestamp = (beginTimestamp.toDouble() / 1000).round();
      duration = (duration.toDouble() / 1000.0).round();
    }
    return _channel.invokeMethod("start", {"beginTimestamp": beginTimestamp.toString(), "duration": duration.toString(), "mediaURL": mediaURL});
  }

  Future play() {
    return _channel.invokeMethod("play", null);
  }

  Future pause() {
    return _channel.invokeMethod("pause", null);
  }

  Future replay() {
    return _channel.invokeMethod("replay", null);
  }

  Future undo() {
    return _channel.invokeMethod("undo", null);
  }

  Future setAppliance(Appliance appliance) {
    String data = appliance.toString().replaceAll("Appliance.", "");
    return _channel.invokeMethod("setAppliance", {"data": data});
  }

  Future seekToScheduleTime(int time) {
    if (Platform.isIOS) {
      time = (time.toDouble() / 1000.0).round();
    }
    return _channel.invokeMethod("seekToScheduleTime", {"data": time.toString()});
  }

  Future<bool> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCreated':
        if (onCreated != null) {
          print("_onMethodCall onCreated ${call.arguments}");
          onCreated(call.arguments["created"]);
        }
        return true;
      case 'onPhaseChanged':
        if (onPhaseChanged != null) {
          print("_onMethodCall onPhaseChanged ${call.arguments}");
          onPhaseChanged(call.arguments["data"]);
        }
        return true;
      case 'onPlay':
        if (replayPlay != null) {
          print("_onMethodCall replayPlay ${call.arguments}");
          replayPlay(call.arguments["data"]);
        }
        return true;
      case 'onScheduleTimeChanged':
        if (onScheduleTimeChanged != null) {
          var data = call.arguments["data"];
          if (Platform.isIOS) {
            data = data.toDouble() * 1000;
          }
//          print("_onMethodCall onScheduleTimeChanged ${call.arguments}  data $data round ${data.round()}");
          onScheduleTimeChanged(data.round());
        }
        return true;
      case 'onRoomPhaseChanged':
        if (onRoomPhaseChanged != null) {
          print("_onMethodCall onRoomPhaseChanged ${call.arguments}");
          onRoomPhaseChanged(call.arguments["data"]);
        }
        return true;
      case 'onApplianceChanged':
        if (onApplianceChanged != null) {
          print("_onMethodCall onApplianceChanged ${call.arguments}");
          onApplianceChanged(call.arguments["data"]);
        }
        return true;
    }
    throw MissingPluginException(
      '${call.method} was invoked but has no handler',
    );
  }
}
