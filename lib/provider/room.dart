import 'package:flutter/material.dart';
import 'package:flutter_start/models/ChatMessage.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/models/RoomUser.dart';

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
  setIsComposing(bool isComposing) {
    _isComposing = isComposing;
    notifyListeners();
  }

  insertChatMessageList(ChatMessage msg) {
    _chatMessageList.insert(0, msg);
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
  int _val = 0;
  int get val => _val;
  DateTime _dateTime;
  DateTime get dateTime => _dateTime;
  var _op;
  get op => _op;
  bool _isShow = false;
  bool get isShow => _isShow;
  Res _ques;
  Res get ques => _ques;

  var _quesAn;
  get quesAn => _quesAn;

  switchVal(int val) {
    _val = val;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }

  setIsShow(bool isShow, {ques, op, quesAn, dateTime}) {
    _isShow = isShow;
    if (!isShow) {
      _val = 0;
    }
    if (ques != null) {
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

  setProgress(double percentage) {
    _percentage = percentage;
    notifyListeners();
  }
}

class BoardProvider with ChangeNotifier {
  int _enableBoard = 1;
  int get enableBoard => _enableBoard;

  setEnableBoard(int enableBoard) {
    _enableBoard = enableBoard;
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
    _star = star;
    notifyListeners();
  }

  increment() {
    _star++;
    notifyListeners();
  }
}

class CourseProvider with ChangeNotifier {
  RoomData _roomData;
  int _status = 0;
  int get status => _status;
  RoomData get roomData => _roomData;
  CourseProvider(int status, {RoomData roomData}) {
    _status = status;
    this._roomData = roomData;
  }
  setStatus(int status) {
    _status = status;
    notifyListeners();
  }
}
