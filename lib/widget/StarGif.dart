import 'dart:math';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:fsuper/fsuper.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class StarGif extends StatefulWidget {
  final int starNum;
  const StarGif({Key key, this.starNum}) : super(key: key);
  @override
  _StarGifState createState() => _StarGifState();
}

class _StarGifState extends State<StarGif> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  _ImageProvider _provider = _ImageProvider();
  Timer _timer;
  Duration _timeoutSeconds = const Duration(milliseconds: 250);
  Duration _backTime = const Duration(milliseconds: 3000);
  List<String> _image = ["images/live/01.png", "images/live/02.png", "images/live/04.png", "images/live/star.png"];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    var tweenSequence = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -pi / 20), weight: 0.3),
      TweenSequenceItem(tween: Tween(begin: -pi / 20, end: pi / 20), weight: 0.3),
      TweenSequenceItem(tween: Tween(begin: pi / 20, end: 0.0), weight: 0.3)
    ]);
    _animation = tweenSequence.animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
    Future.delayed(Duration(milliseconds: 200)).then((e) {
      _controller.repeat().timeout(Duration(milliseconds: 600), onTimeout: () {
        _controller.stop(canceled: true);
        _provider.setIndex(1);
        _timer = Timer(_timeoutSeconds, () {
          _provider.setIndex(2);
          _timer.cancel();
          _timer = Timer(_timeoutSeconds, () {
            _provider.setIndex(3);
            _timer.cancel();
            _timer = Timer(_backTime, () {
              back();
              _timer.cancel();
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        back();
        return Future.value(false);
      },
      child: Material(
        color: Colors.transparent,
        child: FSuper(
//        backgroundColor: Colors.white,
          width: widthSrcreen,
          height: heightScreen,
          child1Alignment: Alignment.center,
          child1: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Transform.rotate(
                  alignment: Alignment.topCenter,
                  angle: _animation.value,
                  child: ChangeNotifierProvider.value(
                    value: _provider,
                    child: Consumer<_ImageProvider>(builder: (context, model, child) {
                      return Column(
                        children: <Widget>[
                          Image.asset(_image[model.index], width: ScreenUtil.getInstance().getWidthPx(300), height: ScreenUtil.getInstance().getWidthPx(300)),
                          model.index == 3
                              ? Text(
                                  "提前进入课堂奖励${widget.starNum}颗星星",
                                  style: TextStyle(color: Colors.yellowAccent),
                                )
                              : Container()
                        ],
                      );
                    }),
                  ),
                );
              }),
          onChild1Click: () {
            _controller.repeat().timeout(Duration(milliseconds: 600), onTimeout: () {
              _controller.stop(canceled: true);
            });
          },
          onClick: back,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  back() {
    if (_provider.index == 3) {
      Navigator.pop(context, num);
    }
  }
}

class _ImageProvider with ChangeNotifier {
  int _index = 0;
  int get index => _index;
  setIndex(int index) {
    _index = index;
    notifyListeners();
  }
}
