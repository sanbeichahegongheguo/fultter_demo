import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class GamePayleWidget extends StatefulWidget {
  @override
  _GamePayleWidgetState createState() => _GamePayleWidgetState();
}

enum AniProps { width, color, alpha }

class _GamePayleWidgetState extends State<GamePayleWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final player = AudioPlayer(); //音频播放
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    localUrl();
    Future.delayed(Duration(milliseconds: 2500), () {
      _back();
    });
  }

  bool _isBack = false;
  localUrl() async {
    await player.setAsset('assets/sounds/ready_go.mp3');
    await player.seek(Duration(seconds: 0));
    await player.play();
  }

  final _tween = MultiTween<AniProps>()
    ..add(
      AniProps.width,
      100.0.tweenTo(350.0),
      1000.milliseconds,
      Curves.easeInOutQuad,
    )
    ..add(
      AniProps.alpha,
      1.0.tweenTo(1),
      1500.milliseconds,
    );
  @override
  void dispose() {
    super.dispose();
    player?.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _back();
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          _back();
        },
        child: Container(
            color: Colors.black.withAlpha(40),
            child: PlayAnimation<MultiTweenValues<AniProps>>(
              tween: _tween, // Pass in tween
              duration: _tween.duration,
              builder: (context, child, value) {
                return Opacity(
                  opacity: value.get(AniProps.alpha) == null ? 1 : value.get(AniProps.alpha),
                  child: Center(
                    child: Image.asset(
                      "images/live/chat/game_ready.png",
                      height: value.get(AniProps.width),
                      width: value.get(AniProps.width),
                      alignment: Alignment.center,
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

  _back() {
    if (_isBack) {
      return;
    }
    Navigator.pop(context);
  }
}
