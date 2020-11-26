import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:provider/provider.dart';

class StarDialog extends StatefulWidget {
  final int starNum;

  const StarDialog({Key key, this.starNum = 0}) : super(key: key);
  @override
  _StarDialogState createState() => _StarDialogState();
}

class _StarDialogState extends State<StarDialog> with TickerProviderStateMixin {
  var isBack = 0;
  Timer _timer;
  @override
  void initState() {
    super.initState();
    if (widget.starNum != null && widget.starNum > 0) {
      final starWidgetProvider = Provider.of<StarWidgetProvider>(context, listen: false);
      starWidgetProvider.addStar(widget.starNum);
    }
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer(Duration(seconds: 3), () {
      back();
    });
    final screenSize = MediaQuery.of(context).size;
    var _maxContentHeight = (ScreenUtil.getInstance().screenWidth * 0.8) - MediaQuery.of(context).padding.left;
    return Container(
      height: screenSize.height,
      width: screenSize.width,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: _maxContentHeight),
            child: Container(
                height: ScreenUtil.getInstance().getHeightPx(1350),
                alignment: Alignment.topCenter,
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
                      child: CommonUtils.buildBtn("开心收下", width: ScreenUtil.getInstance().getWidthPx(200), height: ScreenUtil.getInstance().getHeightPx(170),
                          onTap: () {
                        back();
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
        ),
      ),
    );
  }

  back() {
    if (isBack == 0) {
      isBack = 1;
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    isBack = 1;
    _timer?.cancel();
    super.dispose();
  }
}
