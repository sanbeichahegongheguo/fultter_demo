import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';
import 'daoResult.dart';

class ApplicationDao{
  ///获取升级信息
  static getAppVersionInfo(userId, Store store) async {
    var deviceInfo = await DeviceInfo.instance.getDeviceInfo();
    var params ={};
    if (Platform.isIOS) {
      var res = await httpManager.netFetch(Address.getAppStoreVersionInfo(), params, null, Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
      var result;
      if (res != null && res.result) {
         if(res.data!=null && res.data["results"]!=null && res.data["results"].leght>0 && res.data["results"][0] != null){
           String version = res.data["results"][0]["version"];
           result = AppVersionInfo();
           result.maxVersion = version;
           if (CommonUtils.compareVersion( (await PackageInfo.fromPlatform()).version,version)>0){
             result.isUp = 2;
           }else{
             result.isUp = 1;
           }
         }else{
           res.result = false;
         }
      }
      return new DataResult(result, res.result);
    }else{
      params= {"userId": userId, "platform": 1, "device":  deviceInfo["model"],  "systemNum": deviceInfo["version.release"]};
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

  ///流量统计
  static trafficStatistic(eventId) async {
    var pf = 'STUDENT_APP';
    var did = await DeviceInfo.instance.getDeviceId();
    var uid = SpUtil.getObject(Config.LOGIN_USER)["userId"];
    var cb = SpUtil.getObject(Config.LOGIN_USER)["userId"];
    var cd =  DateUtil.formatDate(new DateTime.now(),format:DataFormats.full);
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