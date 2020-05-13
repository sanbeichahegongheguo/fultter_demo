import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
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
      var res = await httpManager.netFetch(AddressUtil.getInstance().getAppStoreVersionInfo(), null, null, Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
      var result;
      if (res != null && res.result) {
        res.data = jsonDecode(res.data);
         if(res.data!=null && res.data["results"]!=null && res.data["results"].length>0 && res.data["results"][0] != null){
           String version = res.data["results"][0]["version"];
           result = AppVersionInfo();
           result.maxVersion = version;
           result.ok = 0;
           var compareVersion = CommonUtils.compareVersion((await PackageInfo.fromPlatform()).version,version);
           if (compareVersion == -1){
             result.isUp = 1;
           }else{
             result.isUp = 2;
           }
         }else{
           res.result = false;
         }
      }
      return new DataResult(result, res.result);
    }else{
      params= {"userId": userId, "platform": 1, "device":  deviceInfo["model"],  "systemNum": deviceInfo["version.release"]};
      var res = await httpManager.netFetch(AddressUtil.getInstance().getAppVersionInfo(), params, null, Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
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
    next() async {
      var res = await httpManager.netFetch(AddressUtil.getInstance().getAppApplication(), null, null, Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
      var result;
      if (res != null && res.result) {
        var json = res.data;
        if (null!=json) {
          result = json;
          await SpUtil.putObject(Config.APPAPPLICATION_KEY, result);
        } else {
          res.result = false;
        }
      }
    }

    var object = SpUtil.getObject(Config.APPAPPLICATION_KEY);
    if(object==null){
     await next();
     object = SpUtil.getObject(Config.APPAPPLICATION_KEY);
    }else{
      next();
    }
    return new DataResult(object, object!=null);
  }
  ///流量统计
  static trafficStatistic(eventId) async {
    var pf = 'PARENT_APP';
    var did = await DeviceInfo.instance.getYondorDeviceId();
    var user = SpUtil.getObject(Config.LOGIN_USER);
    var uid;
    var cb ;
    //启动事件只统计一次
    if (eventId==287&&(SpUtil.getBool(Config.EVENT_287)||user==null)){
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().statistics(), params, null, new Options(method: "post"),noTip: true);
    print('返回值');
    print(res.data);
  }

  ///对象统计
  static sendObjTotal(data) async {
    var pf = 'PARENT_APP';
    var did = await DeviceInfo.instance.getYondorDeviceId();
    var user = SpUtil.getObject(Config.LOGIN_USER);
    var uid;
    var cb ;
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
    var dataJson = {"pf": pf,"did": did, "uid": uid,"cb": cb, "cd": cd,"vn": vn, "df": df, "dj": data,"tid":2};
    var params = {"dataJson": jsonEncode(dataJson)};
    var res = await httpManager.netFetch(AddressUtil.getInstance().sendObj(), params, null, new Options(method: "post"));
    print(res.data);
  }

  ///设备信息统计
  static sendDeviceInfo() async {
    print("sendDeviceInfo");
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().sendDeviceInfo(), params, null, new Options(method: "post"),noTip: true);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().getAppNotice(), params, null, new Options(method: "post"),noTip: true);
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

  static appCheck(String address) async {
    var res = await httpManager.netFetch(address, null, null, Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (null!=json) {
        result = json;
        await SpUtil.putObject(Config.APPAPPLICATION_KEY, result);
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, result!=null);
  }

}