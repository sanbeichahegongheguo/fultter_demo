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
import 'daoResult.dart';

class ApplicationDao{
  ///获取升级信息
  static getAppVersionInfo(userId) async {
    var deviceInfo = await DeviceInfo.instance.getDeviceInfo();
    var params ={};
    if (Platform.isIOS) {
      var res = await httpManager.netFetch(Address.getAppStoreVersionInfo(), null, null, Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
      var result;
      if (res != null && res.result) {
        res.data = jsonDecode(res.data);
         if(res.data!=null && res.data["results"]!=null && res.data["results"].length>0 && res.data["results"][0] != null){
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

  ///获取后台配置信息
  static getAppApplication() async {
    var res = await httpManager.netFetch(Address.getAppApplication(), null, null, Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (null!=json) {
        result = json;
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }
  ///流量统计
  static trafficStatistic(eventId) async {
    var pf = 'PARENT_APP';
    var did = await DeviceInfo.instance.getDeviceId();
    var user = SpUtil.getObject(Config.LOGIN_USER);
    var uid;
    var cb ;
    //启动事件只统计一次
    if (eventId==287&&(!SpUtil.getBool(Config.EVENT_287)||user==null)){
      return;
    }
    if(eventId==287){
      SpUtil.putBool(Config.EVENT_287, true);
    }
    if (user!=null){
      uid = user["userId"];
      cb = user["userId"];
    }
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

  ///设备信息统计
  static sendDeviceInfo() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    int uid = 0;
    await SpUtil.getInstance();
    var object = SpUtil.getObject(Config.LOGIN_USER);
    if (object!=null){
      uid = SpUtil.getObject(Config.LOGIN_USER)["userId"];
    }
    String key = "sendDeviceInfo_$uid";
    var before = SpUtil.getInt(key);
    if(before!=null && before!=0){
      //判断是否已经过了7天,每个用户7天发送一次
      num d = ((now-before)/ (1000 * 60 * 60 * 24)).ceil();
      if( d <= 7 ){
        print("设备信息统计已经发送 时间${now-before}");
        //7天内不发送
        return;
      }
    }
    var yondorInfo = await DeviceInfo.instance.deviceInfo.yondorInfo;
    print(jsonEncode(yondorInfo));
    String  did = await DeviceInfo.instance.getDeviceId();
    yondorInfo["did"] = did;
    if(Platform.isAndroid){
      yondorInfo["kid"] = did + yondorInfo["kid"];
    }
    yondorInfo["uid"] = uid;
    var params = {"dataJson": jsonEncode(yondorInfo)};
    var res = await httpManager.netFetch(Address.sendDeviceInfo(), params, null, new Options(method: "post"));
    if(res!=null && res.result){
      if (res.data!=null&&res.data["success"]){
        SpUtil.putInt(key, now);
      }
    }
  }

  ///获取APP公告
  static getAppNotice() async{
    String key = await httpManager.getAuthorization();
    var curVersion = (await PackageInfo.fromPlatform()).version;
    var params = {"key":key,"curVersion":curVersion};
    var res = await httpManager.netFetch(Address.getAppNotice(), params, null, new Options(method: "post"));
    var result;
    print('获取APP公告');
    print(res);
    print(res.data);
    if (res != null && res.result) {
      var json = res.data;
      if (null!=json) {
        result = json;
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

}