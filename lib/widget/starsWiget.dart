import 'package:bessel_tween/bessel_tween.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:provider/provider.dart';

enum AniProps { offset }

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
  Start({Key key, this.frequency}) : super(key: key);
  int frequency = 10;
}

class _StartState extends State<Start> with TickerProviderStateMixin {
  List<AnimationController> controlerList;
  List<Animation<Offset>> animationList;

  Animation<double> animation;
  AnimationController controller;
  int completedNum = 0;
  int _num = 0;
  bool iscompleted = false;
  List<Widget> _widgetList = [];
  void initState() {
    super.initState();
    setTweenList();
    controller = new AnimationController(duration: const Duration(milliseconds: 200), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    //图片宽高从0变到300
    animation = new Tween(begin: 100.0, end: 130.0).animate(controller);
    //启动动画
    controller.forward();
  }

  /// 设置TweenList
  List<AnimationController> setTweenList() {
    List<AnimationController> _controlerList = [];
    List<Animation<Offset>> _animation = [];
    var pointList = [Offset.zero, Offset(-2.5, 1.5), Offset(-2.1, -1.6)];
    int _time = 300;
    for (int i = 0; i < widget.frequency; i++) {
      AnimationController _controller = AnimationController(duration: Duration(milliseconds: _time), vsync: this);
      _animation.add(BesselTween(pointList).animate(_controller));
      _controlerList.add(_controller);
    }
    animationList = _animation;
    controlerList = _controlerList;
  }

  List<Widget> getSlideTransition() {
    if (_widgetList.length == 0) {
      for (int i = 0; i < animationList.length; i++) {
        _widgetList.add(AnimatedBuilder(
          animation: animation,
          builder: (BuildContext ctx, Widget child) {
            return new SlideTransition(
              position: animationList[i],
              child: Image.asset(
                "images/live/chat/rainStar.png",
                width: animation.value,
                height: animation.value,
              ),
            );
          },
        ));
        Future.delayed(Duration(milliseconds: _widgetList.length > 5 ? 100 * i : 200 * i), () {
          controlerList[i].forward();
          setState(() {
            _num += 1;
          });
        });
        controlerList[i].addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            final starWidgetProvider = Provider.of<StarWidgetProvider>(context, listen: false);
            completedNum += 1;
            starWidgetProvider.increment();
            if (completedNum == widget.frequency - 3) {
              setState(() {});
            }
            if (widget.frequency == completedNum) {
              setState(() {
                iscompleted = true;
              });
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.pop(context);
              });
            }
            controlerList[i]?.stop();
          } else if (status == AnimationStatus.dismissed) {
            // controlerList[controlerList.length - 1].forward();
          }
        });
      }
    }

    return _widgetList;
  }

  @override
  void dispose() {
    for (int i = 0; i < controlerList.length; i++) {
      controlerList[i]?.dispose();
    }
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return iscompleted
        ? Container()
        : Stack(
            alignment: AlignmentDirectional.center,
            children: [
              ...getSlideTransition(),
              _num != widget.frequency
                  ? Text(
                      "${(widget.frequency - _num).toString()}",
                      style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.none,
                        fontSize: 36,
                      ),
                    )
                  : Container()
            ],
          );
  }
}
