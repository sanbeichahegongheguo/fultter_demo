import 'package:flutter/material.dart';

class ReplayProgressProvider with ChangeNotifier {
  double _val = 0;
  double get val => _val;
  bool _isShow = true;
  bool get isShow => _isShow;
  Duration _duration;
  Duration get duration => _duration;
  String _playerPhase = "buffering";
  String get playerPhase => _playerPhase;

  init({double val, bool isShow, Duration duration}) {
    _val = val ?? _val;
    _isShow = isShow ?? _isShow;
    _duration = duration ?? _duration;
  }

  setVal(double val) {
    _val = val;
    notifyListeners();
  }

  setPlayerPhase(String playerPhase) {
    print("setPlayerPhase $playerPhase");
    _playerPhase = playerPhase;
    notifyListeners();
  }

  setIsShow(bool isShow) {
    _isShow = isShow;
    notifyListeners();
  }
}
