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
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/models/index.dart';
import 'package:redux/redux.dart';

class UserDao {
  ///登录
  static login(userName, password, Store store, {String code}) async {
    await httpManager.clearAuthorization();
    var deviceId = await DeviceInfo.instance.getDeviceId();
    var params = {"mobile": userName, "password": password, "datafrom": Config.DATA_FROM, "deviceId": deviceId};
    if (code != null) {
      params["code"] = code;
    }
    var res = await httpManager.netFetch(Address.login(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
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
      var json = res.data;
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
      if (ObjectUtil.isEmptyString(key)){
        return null;
      }
      var params = {"key": key};
      var res = await httpManager.netFetch(Address.getUserLoginInfo(), params, null, new Options(method: "post"));
      var json = res.data;
      var result;
      if (res != null && res.result) {
        if (json["success"]["ok"] == 0) {
          result = User.fromJson(jsonDecode(json["success"]["data"]));
          print("user key  ${result.key}");
          store.dispatch(UpdateUserAction(result));
          await SpUtil.putObject(Config.LOGIN_USER, result);
        } else {
          result = json["success"]["message"];
          res.result = false;
          return null;
        }
      }else{
        return null;
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
      var json = res.data;
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
  static resetTextbookId(textbookId) async {
    String key = await httpManager.getAuthorization();
    var params = {"key": key, "textbookId": textbookId};
    var res = await httpManager.netFetch(Address.resetTextbookId(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
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
    var params = {"key": key, "oldMobile": oldMobile, "newMobile": newMobile, "code": code};
    var res = await httpManager.netFetch(Address.resetMobile(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (json["success"]["ok"] != 0) {
        result = json["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///退出账号
  static logout(store, context) async {
    String key = await httpManager.getAuthorization();
    await httpManager.clearAuthorization();
    store.dispatch(UpdateUserAction(User()));
    var params = {"key": key};
    await httpManager.netFetch(Address.logout(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
  }

  ///通过老师手机查询班级
  static getTeacherClassList(mobile) async {
    var params = {"mobile": mobile};
    var res = await httpManager.netFetch(Address.getTeacherClassList(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res  ${res.data["success"]["ok"]}");
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (json["success"]["ok"] != 0) {
        result = json["success"]["message"];
        res.result = false;
      }
      res.data = res.data;
    }
    return res.data;
  }

  ///检查该班级是否有同名
  static checkSameRealName(classId, realName) async {
    var params = {"classId": classId, "realName": realName};
    var res = await httpManager.netFetch(Address.checkSameRealName(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (json["success"]["ok"] != 0 || json["success"]["data"] != "0") {
        result = "班级里已有相同姓名的学生";
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }


  ///检测是否拥有账号
  static checkHaveAccount(mobile, identity) async {
    var params = {"mobile": mobile, "identity": identity};
    var res = await httpManager.netFetch(Address.checkParentsUser(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data["message"];
        res.result = false;
      } else {
        result = res.data["success"];
      }
    }
    return new DataResult(result, res.result);
  }
  ///更换班级
  static joinClass(classId) async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key, "classId": classId};
    var res = await httpManager.netFetch(Address.joinClass(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (json["success"]["ok"] != 0) {
        result = res.data["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///检测验证码
  static checkCode(mobile, code) async {
    var params = {"mobile": mobile, "code": code};
    var res = await httpManager.netFetch(Address.checkCode(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (json["success"]["ok"] != 0) {
        result = json["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///搜索学校
  static searchSchool(index, type, key, from) async {
    var params = {"index": index, "type": type, "key": key, "from": from};
    var res = await httpManager.netFetch(Address.searchSchool(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data;
        res.result = false;
      } else {
        result = res.data;
      }
    }
    return new DataResult(result, res.result);
  }

  ///选择学校
  static chooseSchool(schoolId, grade) async {
    var params = {"schoolId": schoolId, "grade": grade};
    var res = await httpManager.netFetch(Address.chooseSchool(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data;
        res.result = false;
      } else {
        result = res.data;
      }
    }
    return new DataResult(result, res.result);
  }

  ///检测姓名是否合法
  static checkname(name) async{
    var params = {"name": name};
    var res = await httpManager.netFetch(Address.checkname(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"]==null) {
        result = res.data;
        res.result = false;
      }else{
        result = res.data;
      }
    }
    return new DataResult(result, res.result);
  }

  ///选择班级
  static chooseClass(classId) async {
    var params = {"classId": classId};
    var res = await httpManager.netFetch(Address.chooseClass(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data;
        res.result = false;
      } else {
        result = res.data;
      }
    }
    return new DataResult(result, res.result);
  }

  ///检查该班级是否有同名
  static checkSameRealNamePhone(classId,realName,mobile) async{
    var params = { "classId": classId,"name": realName, "mobile": mobile};
    var res = await httpManager.netFetch(Address.checkSameRealNamePhone(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
//      var json = jsonDecode(res.data);
      if (res.data["err"]!=0) {
        result = res.data;
        res.result = true;
      }else{
        result = res.data;
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///注册
  static register(dataFrom,mobile,password,realName,identity,classId,schoolId,className,grade,classNum) async{
    var params = {"dataFrom": dataFrom,"mobile": mobile,"password": password,"realName": realName,"identity": identity,"classId": classId,"schoolId": schoolId,"className": className,"grade": grade,"classNum": classNum};
    var res = await httpManager.netFetch(Address.register(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"]==null) {
        result = res.data;
        res.result = false;
      }else{
        result = res.data;
      }
    }
    return new DataResult(result, res.result);
  }

  ///获取学生已设置护眼时间
  static getEyeshiieldTime() async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key};
    var res = await httpManager.netFetch(Address.getEyeshiieldTime(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    var data;
    if (res != null && res.result) {
      var json = res.data;
      data = json;
    }
    return data;
  }
  ///设置学生学习时间
  static saveEyeshiieldTime(eyeshieldId) async{
    String key = await httpManager.getAuthorization();
    var params = {"key":key,"eyeshieldId": eyeshieldId};
    var res = await httpManager.netFetch(Address.saveEyeshiieldTime(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (!json["success"]) {
        result = res.data["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///更改密码
  static resetPassword(oldPassword, newPassword) async {
    String key = await httpManager.getAuthorization();
    var params = {"key":key,"oldPassword": oldPassword, "newPassword": newPassword};
    var res = await httpManager.netFetch(Address.resetPassword(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"]["ok"] != 0) {
        result = res.data["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///获取热门兑换礼物列表
  static getHotGoodsList() async{
    String key = await httpManager.getAuthorization();
    var params = {"key":key};
    var res = await httpManager.netFetch(Address.getHotGoodsList(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if(json["success"]["ok"]==0){
        result = res.data["success"]["convertMallGoodsList"][0]["convertGoodsList"];
        await SpUtil.putObjectList(Config.hotGiftList, result);
        res.result = true;
      }else{
        result = res.data["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///获取星星总数
  static getTotalStar() async{
    String key = await httpManager.getAuthorization();
    var params = {"key":key};
    var res = await httpManager.netFetch(Address.getTotalStar(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if(json["success"]["ok"]==0){
        result = res.data["success"]["data"];
        await SpUtil.putString(Config.starNum, result);
        res.result = true;
      }else{
        result = res.data["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }
}
