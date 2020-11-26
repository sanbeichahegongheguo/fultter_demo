import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:just_audio/just_audio.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class GamePayleWidget extends StatefulWidget {
  @override
  _GamePayleWidgetState createState() => _GamePayleWidgetState();
}

enum AniProps { width, color, alpha }

class _GamePayleWidgetState extends State<GamePayleWidget> with SingleTickerProviderStateMixin {
  final player = AudioPlayer(); //音频播放
  bool _isIos13 = DeviceInfo.instance.ios13();
  @override
  void initState() {
    super.initState();
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
            child: _isIos13
                ? PlayAnimation<MultiTweenValues<AniProps>>(
                    tween: _tween, // Pass in tween
                    duration: _tween.duration,
                    builder: (context, child, value) {
                      return Opacity(
                        opacity: value.get(AniProps.alpha) == null ? 1 : value.get(AniProps.alpha),
                        child: _buildBody(value.get(AniProps.width)),
                      );
                    },
                  )
                : _buildBody(350.0)),
      ),
    );
  }

  Widget _buildBody(width) {
    return Center(
      child: Image.asset(
        "images/live/chat/game_ready.png",
        height: width,
        width: width,
        alignment: Alignment.center,
      ),
    );
  }

  _back() {
    if (_isBack) {
      return;
    }
    _isBack = true;
    Navigator.pop(context);
  }
}
