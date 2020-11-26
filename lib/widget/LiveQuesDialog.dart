import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:fsuper/fsuper.dart';
import 'dart:ui';
import 'dart:async';

import 'package:provider/provider.dart';

class LiveQuesDialog extends StatefulWidget {
  final String ir;
  final String an;
  final int star;
  final int times;
  const LiveQuesDialog({Key key, this.ir, this.star = 0, this.an, this.times = 0}) : super(key: key);
  @override
  _StarDialogState createState() => _StarDialogState();
}

class _StarDialogState extends State<LiveQuesDialog> with TickerProviderStateMixin {
  AnimationController _controller;
  Timer _timer;
  Duration _timeoutSeconds;
  BuildContext myContext;
  bool _isIos13 = DeviceInfo.instance.ios13();
  @override
  void initState() {
//    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
    super.initState();
    if (_isIos13) {
      _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
      _controller?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;
    _timeoutSeconds = Duration(seconds: widget.ir == "T" ? 3 : 5);
    _timer = Timer(_timeoutSeconds, () {
      back();
    });
    final screenSize = MediaQuery.of(context).size;
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    var _maxContentHeight = screenSize.height * 0.8;
    return WillPopScope(
        onWillPop: () {
          back();
          return Future.value(false);
        },
        child: GestureDetector(
            onTap: back,
            child: FSuper(
              child1Alignment: Alignment.topCenter,
              width: courseProvider.coursewareWidth,
              height: screenSize.height,
              child1: Material(
                color: Colors.transparent,
                child: Container(
                  height: screenSize.height,
                  width: courseProvider.coursewareWidth,
                  child: _isIos13
                      ? ScaleTransition(
                          scale: _controller,
                          child: _buildBody(_maxContentHeight, screenSize),
                        )
                      : _buildBody(_maxContentHeight, screenSize),
                ),
              ),
            )));
  }

  Widget _buildBody(_maxContentHeight, screenSize) {
    return Center(
      child: Stack(
        alignment: Alignment(-0.25, -0.25),
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: _maxContentHeight, maxWidth: screenSize.height * 0.8),
            child: Container(
                height: ScreenUtil.getInstance().getHeightPx(widget.ir == "T" ? 800 : 950),
                width: ScreenUtil.getInstance().getWidthPx(350),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment(0.0, 0.4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget.ir == "T" ? "获取${widget.star}颗星星" : "认真思考后再答题哦！",
                            style: TextStyle(color: Colors.orange, fontSize: ScreenUtil.getInstance().getSp(8)),
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().getHeightPx(50),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(33, 0, 33, 0),
                            child: Container(
                              height: 1.0 / MediaQueryData.fromWindow(window).devicePixelRatio,
                              color: Color(0xffC0C0C0),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().getHeightPx(50),
                          ),
                          widget.ir == "T"
                              ? Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: "回答正确！",
                                    style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().getSp(8),
                                    ),
                                  ),
                                ]))
                              : Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: "我的答案：",
                                    style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().getSp(8),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${widget.an}",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: ScreenUtil.getInstance().getSp(8),
                                    ),
                                  ),
                                ])),
                          SizedBox(
                            height: ScreenUtil.getInstance().getHeightPx(80),
                          ),
                          widget.ir == "F" && widget.times == 1
                              ? CommonUtils.buildBtn("重新答题",
                                  width: ScreenUtil.getInstance().getWidthPx(120),
                                  height: ScreenUtil.getInstance().getWidthPx(58),
                                  onTap: () => _reAnswer(),
                                  splashColor: Colors.amber,
                                  decorationColor: Color(0xFF3cc969),
                                  textColor: Colors.white,
                                  textSize: ScreenUtil.getInstance().getSp(8),
                                  elevation: 2)
                              : Container()
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.0, -1.2),
                      child: Image.asset(widget.ir == "T" ? "images/live/amswerTrue.png" : "images/live/amswerError.png",
                          width: ScreenUtil.getInstance().getWidthPx(300)),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  _reAnswer() {
    back();
    final roomSelProvider = Provider.of<RoomSelProvider>(context, listen: false);
    roomSelProvider.setIsShow(true);
  }

  var isBack = 0;
  back() {
    if (isBack == 0) {
      isBack = 1;
      Navigator.pop(myContext);
    }
  }

  @override
  void dispose() {
    print("LiveQuesDialog dispose");
    super.dispose();
    _timer?.cancel();
    _controller?.dispose();
  }
}
