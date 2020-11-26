import 'package:flutter/material.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:just_audio/just_audio.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class Mp3PlayerWidget extends StatefulWidget {
  final String filePath;
  final int startTime;
  final bool isPlay;

  const Mp3PlayerWidget({Key key, this.filePath, this.startTime, this.isPlay = false}) : super(key: key);
  @override
  _Mp3PlayerWidgetState createState() => _Mp3PlayerWidgetState();
}

class _Mp3PlayerWidgetState extends State<Mp3PlayerWidget> {
  Mp3PlayerProvider _mp3playerProvider;
  @override
  void initState() {
    super.initState();
    _mp3playerProvider = Provider.of<Mp3PlayerProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Mp3PlayerProvider with ChangeNotifier {
  AudioPlayer player; //音频播放
  String filePath;
  int startTime;
  bool isPlay;
  bool isShow = false;

  init(AudioPlayer player, {String filePath, int startTime, bool isPlay, bool isShow = false}) {
    this.player = player;
    this.filePath = filePath;
    this.startTime = startTime;
    this.isPlay = isPlay;
    this.isShow = isShow;
  }

  local({bool isPlay = false}) async {
    await player.setFilePath(filePath);
    await player.seek(Duration(seconds: 0));
    if (isPlay) {
      this.play();
    }
    isShow = true;
  }

  play() async {
    player?.play();
    isPlay = true;
  }

  stop() async {
    player?.stop();
    isPlay = false;
  }

  seek(int seconds) async {
    player.seek(Duration(seconds: seconds));
  }

  close() async {
    await player?.stop();
    await player?.dispose();
    player = null;
    filePath = null;
    startTime = null;
    isPlay = null;
    isShow = false;
  }

  handle(Courseware courseware, SocketMsg socketMsg) async {
    var msg = jsonDecode(socketMsg.text);
    var qid = msg["qid"];
    var isPlay = msg["isPlay"];

    Res ques = courseware.findQues(qid);
    if (ques == null) {
      showToast("出错了!!!");
      return;
    }
    print("mp3 play : ${courseware.localPath}/${ques.data.ps.mp3}");
    if (!isShow) {
      init(AudioPlayer(), filePath: "${courseware.localPath}/${ques.data.ps.mp3}", startTime: socketMsg.timestamp, isPlay: isPlay == 1);
      await this.local();
    }
    var time = msg["time"];
    if (time != null && time > 0) {
      this.seek(time);
    }
    if (isPlay != null && isPlay == 1) {
      this.play();
    } else {
      this.stop();
    }
  }

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }
}
