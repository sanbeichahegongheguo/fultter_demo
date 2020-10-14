import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LiveTimerWidget extends StatefulWidget {
  final int time;
  final Function callback;
  LiveTimerWidget({Key key, this.time = 0, this.callback}) : super(key: key);
  @override
  _LiveTimerWidgetState createState() => _LiveTimerWidgetState(time: time);
}

class _LiveTimerWidgetState extends State<LiveTimerWidget> with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;
  Animation<Offset> animation;
  Timer _timer;
  int time;
  Duration _seconds = const Duration(milliseconds: 1000);
  _LiveTimerProvider _liveTimerProvider = _LiveTimerProvider();
  _LiveTimerWidgetState({this.time});
  DateTime pausedDate;
  DateTime resumedDate;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("LiveTimerWidget 切换" + state.toString());
    switch (state) {
      case AppLifecycleState.resumed:
        print('LiveTimerWidget 处于前台展示');
        resumedDate = DateTime.now();
        final d = resumedDate.difference(pausedDate);
        if (this.time >= 0) {
          this.time -= (d.inMilliseconds + 1000);
        }
        Future(countDown());
        break;
      case AppLifecycleState.inactive:
        print('LiveTimerWidget 处于非活动状态，并且未接收用户输入');
        break;
      case AppLifecycleState.paused:
        //后台展示
        pausedDate = DateTime.now();
        _timer?.cancel();
        _timer = null;

        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: Offset(0.0, -1.0), end: Offset.zero).animate(_controller);
    _controller.forward();
    Future(countDown());
  }

  countDown() {
    if (_timer == null) {
      _timer = Timer.periodic(_seconds, (timer) {
        this.time -= 1000;
        _liveTimerProvider.notify();
        if (time <= 0) {
          //关闭
          timer?.cancel();
          widget.callback();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _controller.reset();
    _controller.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _liveTimerProvider,
        child: Consumer<_LiveTimerProvider>(builder: (context, model, child) {
          var timeArr = ["0", "0", "0", "0"];
          var minute = (time ~/ 60 ~/ 1000) % 60;
          var second = time ~/ 1000 % 60;
          timeArr[0] = minute > 10 ? minute.toString()[0] : "0";
          timeArr[1] = minute > 10 ? minute.toString()[1] : minute.toString();
          timeArr[2] = second > 10 ? second.toString()[0] : "0";
          timeArr[3] = second > 10 ? second.toString()[1] : second.toString();
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
        }));
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

class _LiveTimerProvider with ChangeNotifier {
  notify() {
    notifyListeners();
  }
}
