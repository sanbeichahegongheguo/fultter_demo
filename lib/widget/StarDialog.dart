import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';

class StarDialog extends StatefulWidget {
  final int starNum;

  const StarDialog({Key key, this.starNum = 0 }) : super(key: key);
  @override
  _StarDialogState createState() => _StarDialogState();
}

class _StarDialogState extends State<StarDialog> with TickerProviderStateMixin {
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
    var _maxContentHeight = ( ScreenUtil.getInstance().screenWidth * 0.8 ) - MediaQuery.of(context).padding.left;
    return Container(
      height: screenSize.height,
      width: screenSize.width,
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _controller,
          child: Center(
            child:  Stack(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: _maxContentHeight),
                  child: Container(
                      height:ScreenUtil.getInstance().getHeightPx(1350),
                      alignment:Alignment.topCenter,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/live/starBg.png"),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.getInstance().getHeightPx(800),
                          ),
                          Text("恭喜你,"),
                          Text("共获得颗${widget.starNum}星星!"),
                          SizedBox(
                            height: ScreenUtil.getInstance().getHeightPx(50),
                          ),
                          Container(
                            child:
                            CommonUtils.buildBtn("开心收下", width: ScreenUtil.getInstance().getWidthPx(200), height: ScreenUtil.getInstance().getHeightPx(170), onTap: () {
                              print("12312312321");
                              Navigator.pop(context);
                            },
                                splashColor:  Colors.amber ,
                                decorationColor:Color(0xFFfbd951) ,
                                textColor: Colors.white,
                                textSize: ScreenUtil.getInstance().getSp(8),
                                elevation: 2),
                          ),
                        ],
                      )
                  ),
                ),
                Container()
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

