import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/net/result_data.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/models/index.dart';
import 'package:redux/redux.dart';

class UserDao {
  ///登录
  static login(userName, password, Store store) async {
    await httpManager.clearAuthorization();
    var params = {"mobile": userName, "password": password, "datafrom": Config.DATA_FROM};
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
        store.dispatch(UpdateUserAction(result));
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
  static Future<User> getUser({isNew = false, Store store}) async {
    if (isNew) {
      String key = await httpManager.getAuthorization();
      var params = {"key": key};
      var res = await httpManager.netFetch(Address.getUserLoginInfo(), params, null, new Options(method: "post"));
      var json = jsonDecode(res.data);
      var result;
      if (json["success"]["ok"] == 0) {
        result = User.fromJson(jsonDecode(json["success"]["data"]));
        print("user key  ${result.key}");
        store.dispatch(UpdateUserAction(result));
        await SpUtil.putObject(Config.LOGIN_USER, result);
      } else {
        result = json["success"]["message"];
        res.result = false;
      }
    }
    User user = User.fromJson(SpUtil.getObject(Config.LOGIN_USER));
    return user;
  }

  ///更换头像
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
    ResultData res = await httpManager.netFetch(Address.getImgCode(), {}, null, new Options(method: "get"));
    HttpHeaders headers = res.headers;
    String userSign = "";
    String cookieCode = "";
    Map<String, dynamic> result = new Map();
    if (res != null && res.result) {
      //在cookie拿到检验码
      headers.forEach((String name, List<String> values) {
        if (name == "set-cookie") {
          values.forEach((v) {
            if (v.startsWith("USER_SIGN")) {
              var split = v.split(";");
              if (split.length > 0) {
                userSign = split[0].replaceFirst("USER_SIGN=", "");
              }
            } else if (v.startsWith("validateCode")) {
              var split = v.split(";");
              if (split.length > 0) {
                cookieCode = split[0].replaceFirst("validateCode=", "");
              }
            }
          });
        }
      });
      result["data"] = res.data;
      result["userSign"] = userSign;
      result["cookieCode"] = cookieCode;
    }
    return new DataResult(result, res.result);
  }

  ///获取认证码
  static getValidateCode(String mobile) async {
    var res = await httpManager.netFetch(Address.getValidateCode(), {"mobile": mobile}, null, new Options(method: "post"));
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == false) {
        result = res.data["message"];
        res.result = false;
      } else {
        result = res.data;
      }
    }
    return new DataResult(result, res.result);
  }

  ///发送短信
  static sendMobileCodeWithValiCode(String mobile, String vcode, var codeDataJson) async {
    var params = {"mobile": mobile, "datafrom": "parent_reg", "vcode": vcode, "codeDataJson": codeDataJson};
    var res = await httpManager.netFetch(Address.sendMobileCodeWithValiCode(), params, null, new Options(method: "post"));
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      if (res.data["success"]) {
        result = res.data;
      } else {
        result = res.data["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }
  ///更换教程
  static resetTextbookId(textbookId) async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key, "textbookId": textbookId};
    var res = await httpManager.netFetch(Address.resetTextbookId(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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

  ///更改手机号码
  static resetMobile(oldMobile, newMobile, code) async {
    String key = await httpManager.getAuthorization();
    print("key====${key}");
    var params = {"key": key, "oldMobile": oldMobile, "newMobile": newMobile, "code": code};
    var res = await httpManager.netFetch(Address.resetMobile(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
}
