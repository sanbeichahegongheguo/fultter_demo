import 'dart:convert';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/common/utils/formatDate.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart';
import 'package:redux/redux.dart';

import 'daoResult.dart';

class ApplicationDao{
  ///获取升级信息
  static getAppVersionInfo(userId, Store store) async {
    var deviceInfo = await DeviceInfo.instance.getDeviceInfo();
    var params ={};
    if (Platform.isIOS) {
      params= {"userId": userId, "device": deviceInfo["utsname.machine:"], "platform": 2, "systemNum": deviceInfo["systemVersion"]};
    }else{
      params= {"userId": userId, "platform": 1, "device":  deviceInfo["model"],  "systemNum": deviceInfo["version.release"]};
    }
    var res = await httpManager.netFetch(Address.getAppVersionInfo(), params, null, Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (null!=json["success"]) {
        result = AppVersionInfo.fromJson(json["success"]);
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///流量统计
  static trafficStatistic(eventId) async {
    var pf = 'STUDENT_APP';
    var did = await DeviceInfo.instance.getDeviceId();
    var uid = SpUtil.getObject(Config.LOGIN_USER)["userId"];
    var cb = SpUtil.getObject(Config.LOGIN_USER)["userId"];
    var cd = formatDate(new DateTime.now(), [yyyy, '-', mm, '-', dd," ",HH,":",nn,":",ss]);
    var vn = (await PackageInfo.fromPlatform()).version;
    var df = '';
    if(Platform.isAndroid){
      df = 'ANDROID';
    }else if(Platform.isIOS){
      df = 'IOS';
    }
    var dataJson = {"pf": pf,"did": did, "uid": uid,"cb": cb, "cd": cd,"vn": vn, "df": df, "eid": eventId};
    var params = {"dataJson": jsonEncode(dataJson)};
    print(params);
    var res = await httpManager.netFetch(Address.statistics(), params, null, new Options(method: "get"));
    print('返回值');
    print(res.data);
  }
}