import 'package:flutter/material.dart';

class ReplayProgressProvider with ChangeNotifier {
  double _val = 0;
  double get val => _val;
  double _before = 0;
  double get before => _before;
  bool _isShow = true;
  bool get isShow => _isShow;
  Duration _duration;
  Duration get duration => _duration;
  String _playerPhase = "buffering";
  String get playerPhase => _playerPhase;
  List<double> _gameDotList = [];
  List<double> get gameDotList => _gameDotList;

  init({double val, bool isShow, Duration duration}) {
    _val = val ?? _val;
    _isShow = isShow ?? _isShow;
    _duration = duration ?? _duration;
  }

  setVal(double val) {
    _val = val;
    notifyListeners();
  }

  setBefore(double before) {
    _before = before;
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

  setGameDotList(List<double> gameDotList) {
    _gameDotList = gameDotList;
    notifyListeners();
  }
}
