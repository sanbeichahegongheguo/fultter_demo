import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class LiveTimerWidget extends StatefulWidget {
  @override
  _LiveTimerWidgetState createState() => _LiveTimerWidgetState();
  int time = 0;
  LiveTimerWidget({Key key, this.time}) : super(key: key);
}

class _LiveTimerWidgetState extends State<LiveTimerWidget> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> animation;

  var timeArr = ["0", "0", "0", "0"];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: Offset(0.0, -1.0), end: Offset.zero).animate(_controller);
    _controller.forward();
    var minute = (widget.time ~/ 60) % 60;
    var second = widget.time % 60;

    timeArr[0] = minute > 10 ? minute.toString()[0] : "0";
    timeArr[1] = minute > 10 ? minute.toString()[1] : minute.toString();
    timeArr[2] = second > 10 ? second.toString()[0] : "0";
    timeArr[3] = second > 10 ? second.toString()[1] : second.toString();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.reset();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      //将要执行动画的子view
      child: Opacity(
        opacity: 0.8,
        child: Container(
          width: 120,
          padding: EdgeInsets.only(
            bottom: 6,
          ),
          decoration: new BoxDecoration(
            color: Color(0xFF484e65),
          ),
          child: new Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 6),
                padding: EdgeInsets.symmetric(vertical: 4),
                width: 120,
                color: Color(0xFF3c425a),
                child: Text(
                  "定时器",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil.getInstance().getSp(18 / 4),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _getText(timeArr[0].toString()),
                  _getText(timeArr[1].toString()),
                  Text(
                    ":",
                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getInstance().getSp(36 / 4)),
                  ),
                  _getText(timeArr[2].toString()),
                  _getText(timeArr[3].toString()),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _getText(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      decoration: new BoxDecoration(
          border: Border.all(
        color: Color(0xFF434960),
        width: 1,
      )),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil.getInstance().getSp(36 / 4),
        ),
      ),
    );
  }
}
