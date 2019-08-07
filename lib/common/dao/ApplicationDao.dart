import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:redux/redux.dart';

import 'daoResult.dart';

class ApplicationDao{
  ///获取升级信息
  static getAppVersionInfo(userId, Store store) async {
    var deviceInfo = await DeviceInfo.instance.getDeviceInfo();
    var params ={};
    if (Platform.isIOS) {
      params= {"userId": userId, "device": deviceInfo["utsname.machine"], "platform": 2, "systemNum": deviceInfo["systemVersion"]};
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
}