import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/local/local_storage.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';

class UserDao{
  ///登录
  static login(userName, password) async {
    httpManager.clearAuthorization();
    String params ='[1,"student:login",1,0,{"1":{"str":"$userName"},"2":{"str":"$password"},"3":{"str":""},"4":{"str":""},"5":{"str":"studentApp"}}]';
    var res = await httpManager.netFetch(Address.login(), params, null, new Options(method: "post"),contentType: HttpManager.CONTENT_TYPE_JSON);
    var result;
    if (res != null && res.result) {
      if (Config.DEBUG){
        print("user result " + res.result.toString());
        print("user data  " +res.data);
      }
      var json  = jsonDecode(res.data);
      result = jsonDecode(json[4]["0"]["rec"]["3"]["str"]);
      await LocalStorage.save(Config.TOKEN_KEY,result["key"]);
    }
    return new DataResult(result, res.result);
  }
}