import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
class Whiteboard extends StatefulWidget {
  final String uuid;
  final String roomToken;
  final String appIdentifier;
  final WhiteboardController controller;
  const Whiteboard({Key key, this.uuid, this.roomToken, this.appIdentifier,this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Whiteboard();
  }
}
class _Whiteboard extends State<Whiteboard> with AutomaticKeepAliveClientMixin<Whiteboard>,SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Platform.isAndroid?AndroidView(
          viewType: "whiteboard_view",
          creationParams: {"appIdentifier":widget.appIdentifier,"uuid":widget.uuid,"roomToken":widget.roomToken},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated:(id){
            MethodChannel  _channel =  MethodChannel('com.yondor.live/whiteboard_$id');
            widget.controller.setChannel(_channel);
          }
      ):UiKitView(
        viewType: "whiteboard_view",
        creationParams: {"appIdentifier":widget.appIdentifier,"uuid":widget.uuid,"roomToken":widget.roomToken},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated:(id){
          MethodChannel  _channel =  MethodChannel('com.yondor.live/whiteboard_$id');
          widget.controller.setChannel(_channel);
        },
    );
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => Platform.isAndroid;
}
class WhiteboardController {
  MethodChannel _channel;
  setChannel(MethodChannel c){
    _channel = c;
  }
  Future updateRoom({int isBoardLock}){
    var param ={};
    if (null!=isBoardLock){
      param["isBoardLock"] = isBoardLock;
    }
    return _channel.invokeMethod("updateRoom",param);
  }
}