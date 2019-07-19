import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/index.dart';

class UserDao {
  ///登录
  static login(userName, password) async {
    await httpManager.clearAuthorization();
    var params = {"mobile": userName, "password": password, "datafrom": "studentApp"};
    var res = await httpManager.netFetch(Address.login(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (Config.DEBUG) {
        print("user result " + res.result.toString());
        print("user data  " + res.data);
      }
      var json = jsonDecode(res.data);
      if (json["success"]["ok"] == 0) {
        result = User.fromJson(jsonDecode(json["success"]["data"]));
        print("user key  ${result.key}");
        SpUtil.putObject(Config.LOGIN_USER, result);
        await httpManager.setAuthorization(result.key);
      } else {
        result = json["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///发送手机验证码
  static sendMobileCode(mobile) async {
    await httpManager.clearAuthorization();
    var params = {"mobile": mobile};
    var res = await httpManager.netFetch(Address.sendMobileCode(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = jsonDecode(res.data);
      if (json["success"]["ok"] != 0) {
        result = json["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///获取登录用户
  static Future<User> getUser({isNew = false}) async {
    if (isNew) {
      String key = await httpManager.getAuthorization();
      var params = {"key": key};
      var res = await httpManager.netFetch(Address.getUserLoginInfo(), params, null, new Options(method: "post"));
      var json = jsonDecode(res.data);
      var result;
      if (json["success"]["ok"] == 0) {
        result = User.fromJson(jsonDecode(json["success"]["data"]));
        print("user key  ${result.key}");
        await SpUtil.putObject(Config.LOGIN_USER, result);
      } else {
        result = json["success"]["message"];
        res.result = false;
      }
    }
    User user = User.fromJson(SpUtil.getObject(Config.LOGIN_USER));
    return user;
  }

  //更换头像
  static uploadHeadUrl(baseImg, imgtype) async {
    String key = await httpManager.getAuthorization();
    var params = {"key": key, "content": baseImg, "imgtype": imgtype};
    var res = await httpManager.netFetch(Address.uploadHeadUrl(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      var json = jsonDecode(res.data);
      if (json["success"]["ok"] != 0) {
        result = json["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///获取图形验证码
  static getImgCode() async {
    var res = await httpManager.netFetch(Address.getImgCode(), {}, null, new Options(method: "get"));
    print("res==>$res");
    return new DataResult(res, res.result);
  }

  ///获取认证码
  static getValidateCode() async {
    var res = await httpManager.netFetch(Address.getValidateCode(), {}, null, new Options(method: "get"));
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      var json = jsonDecode(res.data);
      if (json["success"]) {
        result = json;
      } else {
        result = json["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }
}
