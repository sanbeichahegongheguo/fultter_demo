import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/local/local_storage.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/index.dart';

class UserDao{
  ///登录
  static login(userName, password) async {
    httpManager.clearAuthorization();
    var params = {"mobile":userName,"password":password,"datafrom":"studentApp"};
    var res = await httpManager.netFetch(Address.login(), params, null, new Options(method: "post"),contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    if (res != null && res.result) {
      if (Config.DEBUG){
        print("user result " + res.result.toString());
        print("user data  " +res.data);
      }
      var json  = jsonDecode(res.data);
      if (json["success"]["ok"]==0){
        result =  User.fromJson(jsonDecode(json["success"]["data"]));
        print("user result  ${result.realName}");
//        await LocalStorage.save(Config.TOKEN_KEY,result["key"]);
      }else{
        result = json["success"]["message"];
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }
}