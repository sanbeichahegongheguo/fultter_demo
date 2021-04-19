import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'package:flutter_start/models/ChatMessage.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/models/RoomUser.dart';
import 'package:oktoast/oktoast.dart';
import 'package:yondor_whiteboard/whiteboard.dart';

class RoomTabProvider with ChangeNotifier {
  int _index = 1;

  int get index => _index;

  switchIndex(int index) {
    _index = index;
    notifyListeners();
  }
}

class RoomType with ChangeNotifier {
  int _type = 2;

  int get type => _type;

  switchType(int type) {
    _type = type;
    notifyListeners();
  }
}

class TeacherProvider with ChangeNotifier {
  RoomUser _user;

  RoomUser get user => _user;

  notifier(RoomUser user) {
    _user = user;
    notifyListeners();
  }
}

class StudentProvider with ChangeNotifier {
  RoomUser _user;

  RoomUser get user => _user;

  notifier(RoomUser user) {
    _user = user;
    notifyListeners();
  }
}

class HandTypeProvider with ChangeNotifier {
  int _type = 1;

  int get type => _type;

  switchType(int type) {
    _type = type;
    notifyListeners();
  }
}

class ChatProvider with ChangeNotifier {
  bool _isComposing = false;

  bool get isComposing => _isComposing;

  bool _muteAllChat = false;

  bool get muteAllChat => _muteAllChat;

  List<ChatMessage> _chatMessageList = new List();
  List<ChatMessage> get chatMessageList => _chatMessageList;
  final Completer<int> _msgListSetup = Completer();
  setIsComposing(bool isComposing) {
    _isComposing = isComposing;
    notifyListeners();
  }

  insertChatMessageList(ChatMessage msg) async {
    await _msgListSetup.future;
    _chatMessageList.insert(0, msg);
    notifyListeners();
  }

  setChatMessageList(List<ChatMessage> msg) {
    _chatMessageList = msg;
    _msgListSetup.complete(1);
    notifyListeners();
  }

  setMuteAllChat(bool muteAllChat) {
    _muteAllChat = muteAllChat;
    notifyListeners();
  }
}

class RoomShowTopProvider with ChangeNotifier {
  bool _isShow = true;
  bool get isShow => _isShow;

  setIsShow(bool isShow) {
    _isShow = isShow;
    notifyListeners();
  }
}

class RoomSelProvider with ChangeNotifier {
  List _groupValueList = List.generate(7, (index) => 0);
  List get groupValueList => _groupValueList;
  DateTime _dateTime;
  DateTime get dateTime => _dateTime;
  var _op;
  get op => _op;
  bool _isShow = false;
  bool get isShow => _isShow;
  Res _ques;
  Res get ques => _ques;
  int _times = 0;
  int get times => _times;
  var _quesAn;
  get quesAn => _quesAn;

  notify() {
    notifyListeners();
  }

  setIsShow(bool isShow, {ques, op, quesAn, dateTime}) {
    _isShow = isShow;
    if (!isShow) {
      _groupValueList = List.generate(6, (index) => 0);
    }
    if (ques != null) {
      //重新设置题目，次数清0
      _times = 0;
      _ques = ques;
    }
    if (op != null) {
      _op = op;
    }
    if (quesAn != null) {
      _quesAn = quesAn;
    }
    if (dateTime != null) {
      _dateTime = dateTime;
    }
    notifyListeners();
  }

  addTimes() {
    _times++;
  }
}

class ResProvider with ChangeNotifier {
  Res _res;
  Res get res => _res;
  bool _isShow = true;
  bool get isShow => _isShow;

  setIsShow(bool isShow) {
    _isShow = isShow;
    notifyListeners();
  }

  setRes(Res res, {isShow}) {
    _res = res;
    _isShow = isShow;
    notifyListeners();
  }

  setScreen(int screenId) {
    if (screenId > 0) {
      if (_res == null) {
        _res = Res(screenId: screenId);
      } else {
        _res.screenId = screenId;
      }
    } else {
      if (_res == null || _res.qid == null || _res.qid <= 0) {
        _res = null;
      } else {
        res.screenId = 0;
      }
    }
    notifyListeners();
  }
}

class ProgressProvider with ChangeNotifier {
  double _percentage = 0;
  double get percentage => _percentage;

  bool _isError = false;
  bool get isError => _isError;
  Function loadCoursePack;
  double _t = 0;
  int _second = 0;

  setProgress(double percentage) {
    _percentage = percentage;
    notifyListeners();
  }

  setIsError(bool isError) {
    _isError = isError;
    notifyListeners();
  }

  reLoad() {
    _second = 0;
    _isError = false;
    _t = 0;
    notifyListeners();
  }

  timer() {
    if (percentage == _t) {
      _second++;
    } else {
      _second = 0;
    }
    _t = _percentage;
    if (!_isError && _second >= 60) {
      setIsError(true);
    }
  }
}

class BoardProvider with ChangeNotifier {
  int _enableBoard = 1;
  int get enableBoard => _enableBoard;
  int _testBoard = 1;
  int get testBoard => _testBoard;
  int _grantBoard = 0;
  int get grantBoard => _grantBoard;
  Appliance _appliance = Appliance.pencil;
  Appliance get appliance => _appliance;

  Color _pencilColor;
  Color get pencilColor => _pencilColor;

  setEnableBoard(int enableBoard) {
    _enableBoard = enableBoard;
    notifyListeners();
  }

  setTestBoard(int testBoard) {
    _testBoard = testBoard;
    notifyListeners();
  }

  setGrantBoard(int grantBoard) {
    if (_grantBoard != grantBoard) {
      _grantBoard = grantBoard;
      notifyListeners();
    }
  }

  setAppliance(Appliance appliance, {Color color}) {
    _appliance = appliance;
    if (color != null) {
      print("set _pencilColor");
      _pencilColor = color;
    }
    notifyListeners();
  }
}

class HandProvider with ChangeNotifier {
  bool _enableHand = false;
  bool get enableHand => _enableHand;

  setEnableHand(bool enableBoard) {
    _enableHand = enableBoard;
    notifyListeners();
  }
}

class WhiteboardProvider with ChangeNotifier {
  String _roomPhase = "connecting";
  String get roomPhase => _roomPhase;

  setRoomPhase(String roomPhase) {
    _roomPhase = roomPhase;
    notifyListeners();
  }
}

class ScreenProvider with ChangeNotifier {
  int _screenId = 0;
  int get screenId => _screenId;

  setScreenId(int screenId) {
    _screenId = screenId;
    notifyListeners();
  }
}

class LiveTimerProvider with ChangeNotifier {
  int _time = 0;
  int get time => _time;
  bool _isShow = false;
  bool get isShow => _isShow;

  show(bool isShow, int time) {
    _isShow = isShow;
    _time = time;
    notifyListeners();
  }
}

class StarWidgetProvider with ChangeNotifier {
  int _star = 0;
  int get star => _star;

  setStar(int star) {
    this._star = star;
    notifyListeners();
  }

  addStar(int star) {
    this._star += star;
    notifyListeners();
  }

  increment() {
    this._star++;
    notifyListeners();
  }

  getUserStar(int liveCourseallotId, String roomUuid) async {
    var param = {"liveCourseallotId": liveCourseallotId, "roomId": roomUuid};
    print("getuserstar param $param");
    RoomDao.getUserStar(param).then((res) {
      if (res.result != null && res.data != null && res.data["code"] == 200) {
        print(res.data["code"]);
        final star = res.data["data"]["star"];
        if (star != null) {
          setStar(star);
        }
      } else {
        showToast("获取星星失败!!!");
      }
    });
  }
}

class CourseProvider with ChangeNotifier {
  RoomData _roomData;
  int _status = 0;
  int get status => _status;
  RoomData get roomData => _roomData;
  Function _closeDialog;
  Function get closeDialog => _closeDialog;
  Function _showStarDialog;
  Function get showStarDialog => _showStarDialog;
  double _coursewareWidth;
  double get coursewareWidth => _coursewareWidth;
  double _maxWidth;
  double get maxWidth => _maxWidth;
  bool _isInitBoardView = false;
  bool get isInitBoardView => _isInitBoardView;
  bool _showReplayProgress = false;
  bool get showReplayProgress => _showReplayProgress;
  CourseProvider(int status, {RoomData roomData, Function closeDialog, Function showStarDialog}) {
    _status = status;
    this._roomData = roomData;
    this._closeDialog = closeDialog;
    this._showStarDialog = showStarDialog;
  }
  setStatus(int status) {
    _status = status;
    notifyListeners();
  }

  setInitBoardView(bool isInit) {
    _isInitBoardView = isInit;
    notifyListeners();
  }

  setShowReplayProgress(bool showReplayProgress) {
    _showReplayProgress = showReplayProgress;
    notifyListeners();
  }

  setCoursewareWidth(double coursewareWidth, double maxWidth) {
    _coursewareWidth = coursewareWidth;
    _maxWidth = maxWidth;
  }
}

class NetworkQualityProvider with ChangeNotifier {
  List networkLevel = ['unknown', 'excellent', 'good', 'poor', 'bad', 'very bad', 'down'];
  Map networkQualityIcon = {
    'excellent': 'images/live/signal-good@2x.png',
    'good': 'images/live/signal-good@2x.png',
    'poor': 'images/live/signal-normal@2x.png',
    'bad': 'images/live/signal-normal@2x.png',
    'very bad': 'images/live/signal-bad@2x.png',
    'down': 'images/live/signal-bad@2x.png',
    'unknown': 'images/live/signal-bad@2x.png',
  };
  String networkQuality = 'good';
  String defaultQuality = 'good';

  String get images => networkQualityIcon[networkQuality];

  setNetworkQuality(int quality) {
    if (quality < networkLevel.length) {
      networkQuality = networkLevel[quality] ?? defaultQuality;
      notifyListeners();
    }
  }

  bool isBad() {
    return images.contains("signal-bad");
  }
}

class RoomToolbarProvider with ChangeNotifier {
  ///当前选择
  /// 0 未选择
  /// 1 画笔
  /// 2 举手
  /// 3 排行榜
  /// 4 聊天
  int _selectState = 0;

  get selectState => _selectState;

  int _toolIndex = 2;

  get toolIndex => _toolIndex;

  setSelectState(int num) {
    if (_selectState != num) {
      _selectState = num;
    } else {
      _selectState = 0;
    }
    notifyListeners();
  }

  setToolIndex(int i) {
    _toolIndex = i;
    notifyListeners();
  }
}

class Toolbar {
  String image;
  String imageSelect;
  int type;
  Toolbar({this.image, this.imageSelect, this.type});
}
