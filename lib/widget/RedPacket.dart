import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:provider/provider.dart';

class RedPacketDialog extends StatefulWidget {
  final int starNum;

  const RedPacketDialog({Key key, this.starNum = 0}) : super(key: key);
  @override
  _RedPacketDialogState createState() => _RedPacketDialogState();
}

class _RedPacketDialogState extends State<RedPacketDialog> with TickerProviderStateMixin {
  AnimationController _controller;
  @override
  void initState() {
//    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var _maxContentHeight = screenSize.height * 0.8;
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    return Container(
      height: screenSize.height,
      width: courseProvider.coursewareWidth,
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _controller,
          child: Center(
            child: Stack(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screenSize.height),
                  child: Container(
                      height: ScreenUtil.getInstance().getHeightPx(1350),
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/live/redPacket.png"),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.getInstance().getHeightPx(800),
                          ),
//                          Text("恭喜你,"),
//                          Text("共获得颗${widget.starNum}星星!"),
                          SizedBox(
                            height: ScreenUtil.getInstance().getHeightPx(175),
                          ),
                          Container(
                            child: CommonUtils.buildBtn("领取",
                                width: ScreenUtil.getInstance().getWidthPx(200), height: ScreenUtil.getInstance().getHeightPx(170), onTap: () {
                              var s = Random().nextInt(15) + 10;
                              Navigator.pop(context, s);
                            },
                                splashColor: Colors.amber,
                                decorationColor: Color(0xFFfbd951),
                                textColor: Colors.white,
                                textSize: ScreenUtil.getInstance().getSp(8),
                                elevation: 2),
                          ),
                        ],
                      )),
                ),
//              IconButton(
//                icon: Image.asset("images/btn-close.png",fit: BoxFit.cover,width: ScreenUtil.getInstance().getWidthPx(100),),
//                color: Colors.transparent,
//                onPressed: () {
//                  print("12312312321");
//                  Navigator.pop(context);
//                },
//              )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
