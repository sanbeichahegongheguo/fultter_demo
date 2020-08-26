import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:orientation/orientation.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class RedRain extends StatefulWidget {
  @override
  _RedRainState createState() => _RedRainState();
}

enum AniProps { width, height, color }

class _RedRainState extends State<RedRain> with TickerProviderStateMixin {
  Animation _animation;
  Animation _rotateAnimation;
  final GlobalKey globalKey1 = GlobalKey();
  final player = AudioPlayer();
  int _starNum = 35;

  @override
  void initState() {
    super.initState();
    localUrl();
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);

//    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
//      ..addListener(() {
//        setState(() {});
//      });
//    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceOut);

    //   _rotatecontroller =
    //     AnimationController(duration: const Duration(seconds: 3), vsync: this);
    // _rotateAnimation =
    //     Tween(begin: 0.0, end: 0.25).animate(_rotatecontroller);
  }

  ///旋转动画
  List<AnimationController> _rotatecontrollerList;
  List<Animation> _rotateAnimationList;

  List<AnimationController> _controllerList;
  List<Animation> _animationList;
  List<_AnimationProvider> _prociderList;
  List<double> leftList;

  final _tween = MultiTween<AniProps>()
    ..add(
      AniProps.width,
      100.0.tweenTo(0.0),
      300.milliseconds,
      Curves.easeInBack,
    );

  List<int> secondList = [
    1000,
    2000,
    3000,
    3000,
    4100,
    4200,
    4300,
    5500,
    5800,
    5100,
    6100,
    7200,
    8000,
    9100,
    9300,
    10000,
    10100,
    11200,
    12000,
    13100,
    14100,
    14300,
    15000,
    16100,
    16200,
    17000,
    17500,
    18000,
    18100,
    19000,
    19000,
    20100,
    20200,
    20300,
    20010
  ];
  Map<int, Object> _starMap = Map();
  List<int> completed = List();
  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    if (_prociderList == null) {
      _prociderList = List.generate(_starNum, (index) {
        return _AnimationProvider();
      });
    }
    if (_controllerList == null) {
      _controllerList = List.generate(_starNum, (index) {
        return AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
          ..addListener(() {
            _prociderList[index].notify();
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              completed.add(index);
              if (completed.length == _starNum) {
                //播放完毕
                print("播放完毕");
                Navigator.pop(context, _starMap.length);
              }
            }
          });
      });
    }

    if (_rotatecontrollerList == null) {
      _rotatecontrollerList = List.generate(_starNum, (index) {
        return AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (status == AnimationStatus.completed) {
                //动画从 controller.forward() 正向执行 结束时会回调此方法
                print("status is completed");
                //重置起点
                _rotatecontrollerList[index].reset();
                //开启
                _rotatecontrollerList[index].forward();
              } else if (status == AnimationStatus.dismissed) {
                //动画从 controller.reverse() 反向执行 结束时会回调此方法
                print("status is dismissed");
              } else if (status == AnimationStatus.forward) {
                print("status is forward");
                //执行 controller.forward() 会回调此状态
              } else if (status == AnimationStatus.reverse) {
                //执行 controller.reverse() 会回调此状态
                print("status is reverse");
              }
            }
          });
      });
    }

    if (_animationList == null) {
      _animationList = List.generate(_starNum, (index) {
        return _animation = Tween(begin: -100.0, end: heightScreen).chain(CurveTween(curve: Curves.linear)).animate(_controllerList[index]);
      });
      _rotateAnimationList = List.generate(_starNum, (index) {
        return _rotateAnimation = new CurvedAnimation(parent: _rotatecontrollerList[index], curve: Curves.linear);
      });
    }
    if (leftList == null) {
      leftList = List.generate(_starNum, (index) {
        return Random().nextInt((widthSrcreen - 100).toInt()).toDouble();
      });
    }
    var list = List.generate(_starNum, (index) {
      return ChangeNotifierProvider.value(
        value: _prociderList[index],
        child: Consumer<_AnimationProvider>(builder: (context, model, child) {
          return Positioned(
            left: leftList[index],
            top: _animationList[index].value,
            child: GestureDetector(
              onTap: () async {
                print("$index ${_starMap[index]}");
                _controllerList[index].stop();
                _starMap[index] = 1;
                _prociderList[index].notify();
                _rotatecontrollerList[index].stop();
                await playLocal();
                // _zoomcontrollerList[index].forward();
                Future.delayed(Duration(milliseconds: 500), () {
                  _starMap[index] = 2;
                  _prociderList[index].notify();
                  _controllerList[index].forward();
                });
              },
              child: _starMap[index] == null
                  ? RotationTransition(
                      alignment: Alignment.center,
                      turns: _rotateAnimationList[index],
                      child: Image.asset(
                        "images/live/chat/icon_star.png",
                        height: 100,
                        width: 100,
                        alignment: Alignment.center,
                      ),
                    )
                  : _starMap[index] == 1
                      ? PlayAnimation<MultiTweenValues<AniProps>>(
                          tween: _tween, // Pass in tween
                          duration: _tween.duration,
                          builder: (context, child, value) {
                            return Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                new Center(
                                  child: Image.asset(
                                    "images/live/chat/star_boom.png",
                                    height: value.get(AniProps.width),
                                    width: value.get(AniProps.width),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Container(),
            ),
          );
        }),
      );
    });
    for (int i = 0; i < _controllerList.length; i++) {
      Future.delayed(Duration(milliseconds: secondList[i]), () {
        _rotatecontrollerList[i].forward();
        _controllerList[i].forward();
      });
    }
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: ChangeNotifierProvider(
        create: (_) => _StatusProvider(),
        child: Container(
          color: Colors.transparent.withAlpha(10),
          key: globalKey1,
          width: widthSrcreen,
          height: heightScreen,
          child: GestureDetector(
            child: Stack(
              children: list,
            ),
          ),
        ),
      ),
    );
  }

  Future localUrl() async {
    var duration = await player.setAsset('assets/sounds/star.mp3');
    print("duration====>${duration}");
  }

  // FIXME: This code is not working.
  Future playLocal() async {
    await player.seek(Duration(seconds: 0));
    await player.play();
  }

  @override
  void dispose() {
    player?.dispose();
    _controllerList?.forEach((element) {
      element?.dispose();
    });
    _rotatecontrollerList?.forEach((element) {
      element?.dispose();
    });
    super.dispose();
//    _prociderList.forEach((element) {
//      element?.dispose();
//    });
  }
}

class _AnimationProvider with ChangeNotifier {
  int _type = 2;

  int get type => _type;

  switchType(int type) {
    _type = type;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }
}

class _StatusProvider with ChangeNotifier {
  int _type = 0;

  int get type => _type;

  switchType(int type) {
    _type = type;
    notifyListeners();
  }
}
