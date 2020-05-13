import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
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
    var deviceId = await DeviceInfo.instance.getYondorDeviceId();

    var params = {"mobile": userName, "password": password, "datafrom": Config.DATA_FROM, "deviceId": deviceId};
    if (code != null) {
      params["code"] = code;
    }
    var res = await httpManager.netFetch(AddressUtil.getInstance().login(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (json["success"]["ok"] == 0) {
        result = User.fromJson(jsonDecode(json["success"]["data"]));
        print("user key  ${result.key}");
        await SpUtil.putObject(Config.LOGIN_USER, result);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().sendMobileCode(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
      var res = await httpManager.netFetch(AddressUtil.getInstance().getUserLoginInfo(), params, null, new Options(method: "post"));
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
    var obj = SpUtil.getObject(Config.LOGIN_USER);
    if(obj==null){
      return null;
    }
    User user = User.fromJson(obj);
    return user;
  }

  ///更换头像
  static uploadHeadUrl(baseImg, imgtype) async {
    String key = await httpManager.getAuthorization();
    var params = {"key": key, "content": baseImg, "imgtype": imgtype};
    var res = await httpManager.netFetch(AddressUtil.getInstance().uploadHeadUrl(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    ResultData res = await httpManager.netFetch(AddressUtil.getInstance().getImgCode(), null, null, new Options(method: "get"));
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().getValidateCode(), {"mobile": mobile}, null, new Options(method: "post"));
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().sendMobileCodeWithValiCode(), params, null, new Options(method: "post"));
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().resetTextbookId(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().resetMobile(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    SpUtil.remove(Config.LOGIN_USER);
    store.dispatch(UpdateUserAction(User()));
    var params = {"key": key};
    await httpManager.netFetch(AddressUtil.getInstance().logout(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
  }

  ///通过老师手机查询班级
  static getTeacherClassList(mobile) async {
    var params = {"mobile": mobile};
    var res = await httpManager.netFetch(AddressUtil.getInstance().getTeacherClassList(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().checkSameRealName(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().checkParentsUser(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data["message"];
        res.result = false;
      } else {
        result = res.data;
      }
    }
    return new DataResult(result, res.result);
  }

  ///更改家长：136家长改为135家长
  static updateParentMobile(mobile, userId, code) async {
    var params = {"mobile": mobile, "userId": userId,"code":code};
    var res = await httpManager.netFetch(AddressUtil.getInstance().updateParentMobile(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data;
        res.result = false;
      } else {
        result = res.data;
      }
    }else{
      result = res;
    }
    return new DataResult(result, res.result);
  }

  ///已有学生账号，检测学生账号和密码和家长账号
  static checkStudent(stuMobile, stuPwd, parentsMobile) async {
    var params = {"studentMobile": stuMobile, "studentPassword": stuPwd,"parentsMobile":parentsMobile};
    var res = await httpManager.netFetch(AddressUtil.getInstance().checkStudent(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
    var result;
    print('已有学生账号，检测学生账号和密码和家长账号');
    print(res.result);
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data;
        res.result = false;
      } else {
        result = res.data;
      }
    }else{
      result = res;
    }
    return new DataResult(result, res.result);
  }

  ///判断学生手机账号是否存在
  static checkMobile(mobile, identity) async {
    var params = {"mobile": mobile, "identity":identity};
    var res = await httpManager.netFetch(AddressUtil.getInstance().checkMobile(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM,noTip:true);
    var result;
    if (res != null && res.result) {
      if (res.data["success"] == null) {
        result = res.data;
        res.result = false;
      } else {
        result = res.data;
      }
    }else{
      result = res;
    }
    return new DataResult(result, res.result);
  }

  ///更换班级
  static joinClass(classId) async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key, "classId": classId};
    var res = await httpManager.netFetch(AddressUtil.getInstance().joinClass(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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

  ///检测验证码
  static checkCode(mobile, code) async {
    var params = {"mobile": mobile, "code": code};
    var res = await httpManager.netFetch(AddressUtil.getInstance().checkCode(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().searchSchool(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().chooseSchool(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().checkname(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().chooseClass(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().checkSameRealNamePhone(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
  static register(dataFrom,mobile,password,realName,identity,classId,schoolId,className,grade,classNum,{parentPhone}) async{
    var params = {"dataFrom": dataFrom,"mobile": mobile,"password": password,"realName": realName,"identity": identity,"classId": classId,"schoolId": schoolId,"className": className,"grade": grade,"classNum": classNum};
    if(parentPhone!=null){
      params["parentMobile"] = parentPhone;
    }
    var res = await httpManager.netFetch(AddressUtil.getInstance().register(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().getEyeshiieldTime(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().saveEyeshiieldTime(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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
    var res = await httpManager.netFetch(AddressUtil.getInstance().resetPassword(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (res.data["success"]["ok"] != 0) {
        result = res.data["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }
  
  ///忘记密码更改密码
  static forgetRePwd(mobile, code ,newPassword) async {
    var params = {"identity":'P',"mobile":mobile,"code": code, "newPassword": newPassword};
    var res = await httpManager.netFetch(AddressUtil.getInstance().resetPwd(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    print(res.data);
    print(res.result);
    if (res != null && res.result) {
      if (!res.data["success"]) {
        result = res.data["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///获取热门兑换礼物列表
  static getHotGoodsList() async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key":key};
      var res = await httpManager.netFetch(AddressUtil.getInstance().getHotGoodsList(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
      var result;
      if (res != null && res.result) {
        var json = res.data;
        if(json["success"]["ok"]==0){
          List<ConvertGoods> list = new List();
          result = res.data["success"]["convertMallGoodsList"][0]["convertGoodsList"];
          await SpUtil.putObjectList(Config.hotGiftList, result);
          result.forEach((value){
            list.add(ConvertGoods.fromJson(value)) ;
          });
          result = list;
          res.result = true;
        }else{
          result = res.data["success"]["message"];
          res.result = false;
        }
      }
      return new DataResult(result, res.result);
    }
    List<ConvertGoods> list = new List();
    var object = SpUtil.getObjectList(Config.hotGiftList);
      if(null==object){
        return await next();
      }
    object.forEach((value){
      list.add(ConvertGoods.fromJson(value)) ;
    });
    DataResult dataResult = new DataResult(list, true, next: next());
    return dataResult;
  }

  ///获取星星总数
  static getTotalStar() async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key":key};
      var res = await httpManager.netFetch(AddressUtil.getInstance().getTotalStar(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
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

    var object = SpUtil.getString(Config.starNum);
    if(ObjectUtil.isEmptyString(object)){
      return await next();
    }
    DataResult dataResult = new DataResult(object, true, next: next());
    return dataResult;
  }
  ///获取作业列表
  static getParentHomeWorkDataList(int pageNum)async{
    String key = await httpManager.getAuthorization();
    var params = {"key":key,"pageNum":pageNum,"curVersion":"1.4.300"};
    var res = await httpManager.netFetch(AddressUtil.getInstance().getParentHomeWorkDataList(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var data = res.data;
    return data;
  }
}
