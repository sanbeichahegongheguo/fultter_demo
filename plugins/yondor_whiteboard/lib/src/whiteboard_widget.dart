import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return AndroidView(
          viewType: "whiteboard_view",
          creationParams: {"appIdentifier":widget.appIdentifier,"uuid":widget.uuid,"roomToken":widget.roomToken},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated:(id){
            MethodChannel  _channel =  MethodChannel('com.yondor.live/whiteboard_$id');
            widget.controller.setChannel(_channel);
          }
      );
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
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