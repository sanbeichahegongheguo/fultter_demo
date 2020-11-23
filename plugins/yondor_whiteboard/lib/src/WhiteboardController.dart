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

class WhiteboardController {
  Function(bool data) onCreated;
  Function(bool data) replayPlay;
  Function(String data) onPhaseChanged;
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
    }
    throw MissingPluginException(
      '${call.method} was invoked but has no handler',
    );
  }
}
