import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/models/LogData.dart';

/**
 * @Author: Sky24n
 * @GitHub: https://github.com/Sky24n
 * @Description: Widget Util.
 * @Date: 2018/9/29
 */

/// Log Util.
class Log {
  static const String tag = "log";
  static const String _defTag = "student_parent";
  static bool _debugMode = false; //是否是debug模式,true: log v 不输出.
  static int _maxLen = 256;
  static const int fine = 0;
  static const int info = 1;
  static const int warn = 2;
  static const int error = 3;
  static const int debug = 4;
  static List<LogData> logDataList = [];
  static String _tagValue = _defTag;
  static int _seconds = 30;
  //       l 日志级别 0=fine,1=info,2=warn,3=error

  static  init({String tag = _defTag, bool isDebug = false, int maxLen = 128,}) async {
    _tagValue = tag;
    _debugMode = isDebug;
    _maxLen = maxLen;
    await LogDataDb.init();
    execute();
  }


  static execute() async{
    //定时发送普通日志
    Timer.periodic(Duration(seconds: _seconds), (timer) async {
      d("execute running ",tag:tag);
      List<LogData> logs = await LogDataDb.getLogs();
      if (logs ==null && logs.length<=0){
        d("execute no msg",tag:tag);
        return;
      }
      d("logs len ${logs.length}",tag:tag);
      var res  = await ApplicationDao.sendLogcat(logs);
      if (res != null && res.result) {
        List<int> ids =[];
        logs.forEach((element) {
          ids.add(element.id);
        });
        await LogDataDb.deleteLogs(ids);
      }
      d("execute ok",tag:tag);
    });
  }

  static void e(Object object, {String tag}) {
    ApplicationDao.sendLogcat([LogData(t: DateUtil.getNowDateMs(),l: error,g: tag??_tagValue,c: object.toString())]);
    _printLog(tag, ' e ', object);
  }

  static void i(Object object, {String tag}) {
    LogDataDb.insertLogData(LogData(t: DateUtil.getNowDateMs(),l: info,g: tag??_tagValue,c: object.toString()));
    _printLog(tag, ' i ', object);
  }

  static void w(Object object, {String tag}) {
    LogDataDb.insertLogData(LogData(t: DateUtil.getNowDateMs(),l: warn,g: tag??_tagValue,c: object.toString()));
    _printLog(tag, ' w ', object);
  }

  static void f(Object object, {String tag}) {
    LogDataDb.insertLogData(LogData(t: DateUtil.getNowDateMs(),l: fine,g: tag??_tagValue,c: object.toString()));
    _printLog(tag, ' f ', object);
  }

  static void d(Object object, {String tag}) {
    if (_debugMode) {
      _printLog(tag, ' d ', object);
    }
  }

  static void _printLog(String tag, String stag, Object object) async{
    String da = object.toString();
    tag = tag ?? _tagValue;
    if (da.length <= _maxLen) {
      print("$tag$stag $da");
      return;
    }
    print(
        '$tag$stag — — — — — — — — — — — — — — — — st — — — — — — — — — — — — — — — —');
    while (da.isNotEmpty) {
      if (da.length > _maxLen) {
        print("$tag$stag| ${da.substring(0, _maxLen)}");
        da = da.substring(_maxLen, da.length);
      } else {
        print("$tag$stag| $da");
        da = "";
      }
    }
    print(
        '$tag$stag — — — — — — — — — — — — — — — — ed — — — — — — — — — — — — — — — —');
  }
}
abstract class LogBase {
  Map<int,Function> funMap ={
    Log.fine:Log.f,
    Log.info:Log.i,
    Log.warn:Log.w,
    Log.error:Log.e,
    Log.debug:Log.d,
  };

  String tagName();

  void print(msg ,{int level= Log.fine}){
    funMap[level](msg,tag:tagName());
  }
}
