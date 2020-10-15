import 'dart:convert';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:provider/provider.dart';

class EyerestWidget extends StatefulWidget {
  final FijkPlayer flickManager;
  const EyerestWidget({Key key, this.flickManager}) : super(key: key);
  @override
  _EyerestWidgetState createState() => _EyerestWidgetState();
}

class _EyerestWidgetState extends State<EyerestWidget> {
  EyerestProvider _eyerestProvider;
  CourseProvider _courseProvider;
  RoomShowTopProvider _roomShowTopProvider;
  @override
  initState() {
    _eyerestProvider = Provider.of<EyerestProvider>(context, listen: false);
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _roomShowTopProvider = Provider.of<RoomShowTopProvider>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _eyerestProvider?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: _courseProvider.coursewareWidth,
          child: FijkView(
            player: widget.flickManager,
            color: Colors.black,
          ),
        ),
        Container(
          width: _courseProvider.coursewareWidth,
          height: double.infinity,
          child: GestureDetector(
            onTap: () => _roomShowTopProvider.setIsShow(true),
          ),
        )
      ],
    );
  }
}

class EyerestProvider with ChangeNotifier {
  FijkPlayer flickManager; //音频播放
  String filePath;
  int startTime;
  bool isPlay;
  bool isShow = false;

  setFlickManager(flickManager) => this.flickManager = flickManager;

  init(FijkPlayer flickManager, {String filePath, int startTime, bool isPlay, bool isShow = false}) {
    this.flickManager = flickManager;
    this.filePath = filePath;
    this.startTime = startTime;
    this.isPlay = isPlay;
    this.isShow = isShow;
  }

  handle(Courseware courseware, SocketMsg socketMsg) async {
    var msg = jsonDecode(socketMsg.text);
    var qid = msg["qid"];
    var _qShow = msg["isShow"];
    print("Eyerest play : ${courseware.eyeMp4Path}");
    if (!isShow) {
      if (_qShow != null && _qShow == 1) {
        init(FijkPlayer(), filePath: "${courseware.eyeMp4Path}", startTime: socketMsg.timestamp);
        await flickManager.setOption(FijkOption.playerCategory, "enable-accurate-seek", 1);
        await flickManager.setOption(FijkOption.hostCategory, "request-audio-focus", 1);
        await flickManager.setOption(FijkOption.formatCategory, "fflags", "fastseek");
        final startDate = DateUtil.getDateTimeByMs(startTime);
        await flickManager.setDataSource(filePath, showCover: true).catchError((e) {
          print("setDataSource error: $e");
        });
        await flickManager.start();
        if (DateTime.now().difference(startDate).inMilliseconds > 1000) {
          Future.delayed(Duration(seconds: 1), () {
            flickManager.seekTo(DateTime.now().difference(startDate).inMilliseconds + 1000);
          });
        }
        isShow = true;
        notifyListeners();
      }
    } else if (_qShow != null && _qShow == 0) {
      close();
    }
  }

  close() async {
    flickManager?.stop();
    flickManager?.release();
    flickManager = null;
    filePath = null;
    startTime = null;
    isPlay = null;
    isShow = false;
    notifyListeners();
  }
}
