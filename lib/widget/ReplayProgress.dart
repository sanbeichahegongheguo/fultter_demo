import 'package:flick_video_player/flick_video_player.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/provider/provider.dart';
import 'package:flutter_start/widget/seekbar/progress_value.dart';
import 'package:flutter_start/widget/seekbar/seekbar.dart';
import 'package:provider/provider.dart';
import 'package:yondor_whiteboard/whiteboard.dart';

class ReplayProgress extends StatefulWidget {
  final WhiteboardController whiteboardController;
  final FlickManager flickManager;
  const ReplayProgress({Key key, this.whiteboardController, this.flickManager}) : super(key: key);
  @override
  _ReplayProgressState createState() => _ReplayProgressState(whiteboardController, flickManager);
}

class _ReplayProgressState extends State<ReplayProgress> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> animation;
  Widget playWidget = Icon(
    Icons.play_arrow,
    color: Colors.white,
  );
  Widget pauseWidget = Icon(
    Icons.pause,
    color: Colors.white,
  );
  Widget replayWidget = Icon(
    Icons.replay,
    color: Colors.white,
  );
  bool _isShow = true;
  Widget currentIconWidget;
  ReplayProgressProvider _replayProgressProvider;
  WhiteboardController _whiteboardController;
  CourseProvider _courseProvider;
  FlickManager _flickManager;
  String _textDuration = "";
  _ReplayProgressState(WhiteboardController whiteboardController, FlickManager flickManager) {
    _whiteboardController = whiteboardController;
    _flickManager = flickManager;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: Offset(0.0, 1.0), end: Offset.zero).animate(_controller);
    _controller.forward();
    _initWhiteboardController();
    _flickManager.flickVideoManager.addListener(() {
      print("videoPlayerController ${_flickManager.flickVideoManager.isPlaying}");
    });
  }

  _initWhiteboardController() {
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _replayProgressProvider = Provider.of<ReplayProgressProvider>(context, listen: false);
    final courseRecordData = _courseProvider.roomData.courseRecordData;
    //开始时间
    final beginTimestamp = courseRecordData.startTime;
    //时长
    final durationTime = (courseRecordData.endTime - courseRecordData.startTime).abs();
    _replayProgressProvider.init(duration: Duration(milliseconds: durationTime));
    final duration = Duration(milliseconds: durationTime);
    String durationInSeconds = duration != null ? (duration - Duration(minutes: duration.inMinutes)).inSeconds.toString().padLeft(2, '0') : null;

    _textDuration = duration != null ? '${duration.inMinutes}:$durationInSeconds' : '0:00';

    _whiteboardController.onPhaseChanged = (String data) {
      print("_whiteboardController 111111 onPhaseChanged $data");
      final playerPhase = PlayerPhase.values.firstWhere((PlayerPhase element) {
        return element.toString() == "$PlayerPhase.$data";
      });
      print("playerPhase  $playerPhase");
      switch (playerPhase) {
        case PlayerPhase.waitingFirstFrame:
          break;
        case PlayerPhase.playing:
          _flickManager?.flickControlManager?.play();
          currentIconWidget = pauseWidget;
          break;
        case PlayerPhase.pause:
          _flickManager?.flickControlManager?.pause();
          currentIconWidget = playWidget;
          break;
        case PlayerPhase.stopped:
          break;
        case PlayerPhase.ended:
          currentIconWidget = replayWidget;
          break;
        case PlayerPhase.buffering:
          currentIconWidget = pauseWidget;
          _flickManager?.flickControlManager?.pause();
          print("正在缓冲！！！！");
          break;
      }
      _replayProgressProvider.setPlayerPhase(data);
    };
    _whiteboardController.onScheduleTimeChanged = (data) {
      _replayProgressProvider.setVal(data.toDouble());
      print("_whiteboardController  onScheduleTimeChanged $data");
    };
    currentIconWidget = playWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplayProgressProvider>(builder: (context, model, child) {
      Duration duration = Duration(milliseconds: model.val.round());
      String durationInSeconds = duration != null ? (duration - Duration(minutes: duration.inMinutes)).inSeconds.toString().padLeft(2, '0') : null;
      String _nowDuration = duration != null ? '${duration.inMinutes}:$durationInSeconds' : '0:00';
      if (_isShow != model.isShow) {
        _isShow = model.isShow;
        if (model.isShow) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }

      return Positioned(
          bottom: 0,
          child: SlideTransition(
            position: animation,
            child: Container(
                color: Colors.black.withAlpha(80),
                height: 50,
                width: ScreenUtil.getInstance().screenWidth,
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      transitionBuilder: (child, anim) {
                        return ScaleTransition(child: child, scale: anim);
                      },
                      duration: Duration(milliseconds: 500),
                      child: IconButton(
                        key: ValueKey(model.playerPhase),
                        padding: EdgeInsets.only(left: 8, right: 8),
                        icon: currentIconWidget,
                        onPressed: _iconFun,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 8, right: 10),
                        child: Text(
                          _nowDuration,
                          style: TextStyle(color: Colors.white),
                        )),
                    Expanded(
                      child: SeekBar(
                        backgroundColor: Colors.grey,
                        max: model.duration.inMilliseconds.toDouble(),
                        progresseight: 7,
                        indicatorColor: Colors.green,
                        indicatorRadius: 6,
                        value: model.val,
                        progressColor: Colors.greenAccent,
                        onValueChanged: (ProgressValue progressValue) {
                          model.setVal(progressValue.value);
                        },
                        upValueChanged: (ProgressValue progressValue) {
                          _whiteboardController.seekToScheduleTime(progressValue.value.round());
                          _flickManager?.flickControlManager?.seekTo(Duration(milliseconds: progressValue.value.round()));
                        },
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 8),
                        child: Text(
                          _textDuration,
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                )),
          ));
    });
  }

  _iconFun() {
//    _controller.reverse();
//    _controller.forward();
    if (currentIconWidget == playWidget) {
      _whiteboardController.play();
    } else if (currentIconWidget == pauseWidget) {
      _whiteboardController.pause();
    } else if (currentIconWidget == replayWidget) {
      _whiteboardController.replay();
      _flickManager?.flickControlManager?.seekTo(Duration(milliseconds: 0));
    }
  }
}
