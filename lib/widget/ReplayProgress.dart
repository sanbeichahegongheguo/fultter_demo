import 'dart:convert';
import 'dart:io';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/const/LiveRoom.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/models/replayData.dart';
import 'package:flutter_start/page/RoomReplayPage.dart';
import 'package:flutter_start/provider/provider.dart';
import 'package:flutter_start/widget/seekbar/progress_value.dart';
import 'package:flutter_start/widget/seekbar/seekbar.dart';
import 'package:provider/provider.dart';
import 'package:yondor_whiteboard/whiteboard.dart';

class ReplayProgress extends StatefulWidget {
  final WhiteboardController whiteboardController;
  final FijkPlayer teacherPlayer;
  final Function handleSocketMsg;
  final Function showTopAndBottom;
  const ReplayProgress({Key key, this.whiteboardController, this.teacherPlayer, this.handleSocketMsg, this.showTopAndBottom}) : super(key: key);
  @override
  _ReplayProgressState createState() => _ReplayProgressState(whiteboardController, teacherPlayer);
}

class _ReplayProgressState extends State<ReplayProgress> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  FijkPlayer _teacherPlayer;
  bool isPlay = false;
  String _textDuration = "";
  _ReplayProgressState(WhiteboardController whiteboardController, FijkPlayer flickManager) {
    _whiteboardController = whiteboardController;
    _teacherPlayer = flickManager;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: Offset(0.0, 1.0), end: Offset.zero).animate(_controller);
    _controller.forward();
    _teacherPlayer.addListener(() {
      print("_teacherPlayer state ${_teacherPlayer.state}");
    });
    _initWhiteboardController();
//    _flickManager.flickVideoManager.addListener(() {
//      print("videoPlayerController ${_flickManager.flickVideoManager.isPlaying}");
//    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //前台展示
        if (isPlay) {
          _play();
          isPlay = false;
        }
        break;
      case AppLifecycleState.inactive:
//        print('应用程序处于非活动状态，并且未接收用户输入');

        break;
      case AppLifecycleState.paused:
        //后台展示
        if (_teacherPlayer.state == FijkState.started) {
          isPlay = true;
          _pause();
        }
        break;
      default:
        break;
    }
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
//      print("playerPhase  $playerPhase");
      switch (playerPhase) {
        case PlayerPhase.waitingFirstFrame:
          break;
        case PlayerPhase.playing:
          _teacherPlayer?.start();
          currentIconWidget = pauseWidget;
          if (_courseProvider.status == 0) {
            _courseProvider.setStatus(1);
          }
          break;
        case PlayerPhase.pause:
          currentIconWidget = playWidget;
          break;
        case PlayerPhase.stopped:
          break;
        case PlayerPhase.ended:
          currentIconWidget = replayWidget;
          break;
        case PlayerPhase.buffering:
          currentIconWidget = pauseWidget;
          _teacherPlayer?.pause();
          print("正在缓冲！！！！");
          break;
      }
      _replayProgressProvider.setPlayerPhase(data);
    };
    _whiteboardController.onScheduleTimeChanged = (int data) {
      _replayProgressProvider.setVal(data.toDouble());
//      print("1111111111111111111w");
//      print("l  ${_courseProvider.roomData.courseRecordData}");

//      List<ReplayItem> l = _courseProvider.roomData.courseRecordData.coursewareOp.list;
      _courseProvider.roomData.courseRecordData.coursewareOp.list.forEach((ReplayItem element) {
//        print("$data > ${element.playTime} && !${element.isDo}");
        if (data > element.playTime && !element.isDo) {
          element.isDo = true;
          print("do elemet $element");
          SocketMsg socketMsg = SocketMsg(type: element.ty, timestamp: element.t, text: element.op);
          widget.handleSocketMsg(socketMsg);
        } else if (element.playTime > data) {
          return;
        }
      });
//      findBeforeAndAfter(l, data);
//      print("_whiteboardController  onScheduleTimeChanged $data");
    };
    currentIconWidget = playWidget;
  }

  ReplayItem findBefore(List<ReplayItem> l, int time) {
    ReplayItem before = l.lastWhere((ReplayItem element) => element.playTime < time, orElse: () {
      return null;
    });
    return before;
  }

  ReplayItem findBeforeShow(List<ReplayItem> l, int time) {
    ReplayItem before = l.lastWhere((ReplayItem element) => element.playTime < time && showMap.containsKey(element.ty), orElse: () {
      return null;
    });
    return before;
  }

  findBeforeAndAfter(List<ReplayItem> l, int time) {
    List<ReplayItem> where = l.where((ReplayItem element) => element.playTime < time);
//    ReplayItem after = l.firstWhere((ReplayItem element) => element.playTime > time, orElse: () {
//      return null;
//    });
//
//    ReplayItem before = l.lastWhere((ReplayItem element) => element.playTime < time, orElse: () {
//      return null;
//    });

//    print(" before : $before  now : $time  after : $after");
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

      return Stack(
        children: [
          "$PlayerPhase.${model.playerPhase}" == PlayerPhase.buffering.toString()
              ? GestureDetector(
                  onTap: () {
                    widget.showTopAndBottom();
                  },
                  child: Container(
                    width: ScreenUtil.getInstance().screenWidth,
                    child: Center(
                      child: Image.asset(
                        "images/live/loading_gif.gif",
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                )
              : Container(),
          Positioned(
              bottom: 0,
              child: SlideTransition(
                position: animation,
                child: Container(
                  color: Colors.black.withAlpha(80),
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                  child: Container(
//                      color: Colors.black.withAlpha(80),
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
                              padding: EdgeInsets.only(left: 8, right: 0),
                              icon: currentIconWidget,
                              onPressed: _iconFun,
                            ),
                          ),
                          Container(
                            width: ScreenUtil.getInstance().getWidth(20),
                            child: Center(
                                child: Text(
                              _nowDuration,
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: SeekBar(
                              backgroundColor: Colors.grey,
                              max: model.duration.inMilliseconds.toDouble(),
                              progresseight: 8,
                              indicatorColor: Colors.green,
                              indicatorRadius: 8,
                              value: model.val,
                              progressColor: Colors.greenAccent,
                              onValueChanged: (ProgressValue progressValue) {
                                model.setVal(progressValue.value);
                              },
                              upValueChanged: (ProgressValue progressValue) {
                                _seekTo(progressValue.value.round());
                              },
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 10, right: 8 + MediaQuery.of(context).padding.right),
                              child: Text(
                                _textDuration,
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      )),
                ),
              )),
        ],
      );
    });
  }

  _iconFun() {
    if (currentIconWidget == playWidget) {
      _play();
    } else if (currentIconWidget == pauseWidget) {
      _pause();
    } else if (currentIconWidget == replayWidget) {
      _replay();
    }
  }

  _play() {
    _whiteboardController.play();
  }

  _pause() {
    _whiteboardController.pause();
    _teacherPlayer?.pause();
  }

  _replay() {
    _replayProgressProvider.setVal(0);
    _courseProvider.roomData.courseRecordData.coursewareOp.list.forEach((ReplayItem element) {
      element.isDo = false;
    });
    _firstCourseware();
    _whiteboardController.replay();
    _teacherPlayer.seekTo(0);
    _teacherPlayer.start();
  }

  Map noShowMap = {
    LiveRoomConst.EVENT_HAND: Object(),
    LiveRoomConst.BOARD: Object(),
    LiveRoomConst.EVENT_BOARD: Object(),
  };
  Map showMap = {
    LiveRoomConst.mp4: Object(),
    LiveRoomConst.ppt: Object(),
    LiveRoomConst.h5: Object(),
    LiveRoomConst.SEL: Object(),
    LiveRoomConst.MULSEL: Object(),
    LiveRoomConst.JUD: Object(),
    LiveRoomConst.RANRED: Object(),
    LiveRoomConst.REDRAIN: Object(),
    LiveRoomConst.TIMER: Object(),
    LiveRoomConst.EVENT_JOIN_SUCCESS: Object(),
    LiveRoomConst.EVENT_CURRENT: Object(),
  };

  _firstCourseware() {
    final first = _courseProvider.roomData.courseware.findFirst();
    print("_courseProvider.roomData.courseware.findFirst(); $first");
    SocketMsg socketMsg = SocketMsg(type: first.type, timestamp: 0, text: '{"qid":${first.qid}}');
    widget.handleSocketMsg(socketMsg);
  }

  _seekTo(int value) async {
    await _teacherPlayer.pause();
    await _whiteboardController.pause();
    ReplayItem before;
    ReplayItem beforeShow;
    if (_courseProvider.roomData.courseRecordData.coursewareOp.list != null) {
      _courseProvider.roomData.courseRecordData.coursewareOp.list.forEach((ReplayItem element) {
//        print("$value > ${element.playTime} && !${element.isDo}");
        if (element.playTime < value) {
          before = element;
        }
        if (element.playTime < value && showMap.containsKey(element.ty)) {
          beforeShow = element;
        }
        if (element.playTime > value) {
          element.isDo = false;
        } else if (element.playTime < value) {
          element.isDo = true;
        }
      });

//      final before = findBefore(_courseProvider.roomData.courseRecordData.coursewareOp.list, value);
      if (before != null) {
        if (noShowMap.containsKey(before.ty)) {
//          final beforeShow = findBeforeShow(_courseProvider.roomData.courseRecordData.coursewareOp.list, value);
          if (beforeShow != null) {
            SocketMsg socketMsg = SocketMsg(type: beforeShow.ty, timestamp: beforeShow.t, text: beforeShow.op);
            widget.handleSocketMsg(socketMsg);
          } else {
            _firstCourseware();
          }
        }
        ReplayItem newBefore = ReplayItem.fromJson(before.toJson());
        print("do elemet before $newBefore");
        if (newBefore.ty == LiveRoomConst.mp4) {
          var decode = json.decode(newBefore.op);
          if (decode["time"] == null) {
            decode["time"] = 0;
          }
          double beforeTime = double.parse(decode["time"].toString());
          beforeTime = beforeTime + Duration(milliseconds: (value - newBefore.playTime).abs()).inSeconds;
          decode["time"] = beforeTime.toInt();
          newBefore.op = jsonEncode(decode);
        } else if (newBefore.ty == LiveRoomConst.SEL || newBefore.ty == LiveRoomConst.JUD || newBefore.ty == LiveRoomConst.MULSEL) {
          var decode = json.decode(newBefore.op);
          decode.remove('isShow');
          newBefore.op = jsonEncode(decode);
        } else if (newBefore.ty == LiveRoomConst.h5) {
          var decode = json.decode(newBefore.op);
          if (decode["isShow"] != null && decode["isShow"] == 1) {
            decode.remove('isShow');
            newBefore.op = jsonEncode(decode);
            widget.handleSocketMsg(SocketMsg(type: newBefore.ty, timestamp: newBefore.t, text: newBefore.op));
            decode["isShow"] = 1;
            newBefore.op = jsonEncode(decode);
          }
        } else if (newBefore.ty == LiveRoomConst.RANRED || newBefore.ty == LiveRoomConst.REDRAIN) {
          var decode = json.decode(newBefore.op);
          decode["ty"] = LiveRoomConst.ppt;
          newBefore.op = jsonEncode(decode);
        }
        print("do elemet after before $newBefore");
        SocketMsg socketMsg = SocketMsg(type: newBefore.ty, timestamp: newBefore.t, text: newBefore.op);
        widget.handleSocketMsg(socketMsg);
      } else {
        _firstCourseware();
      }
    }

    await _teacherPlayer?.seekTo(value);
    await _whiteboardController.seekToScheduleTime(value);
    _teacherPlayer.start();
    _whiteboardController.play();
  }
}
