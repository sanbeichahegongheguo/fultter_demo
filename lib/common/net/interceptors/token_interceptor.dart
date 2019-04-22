import 'package:dio/dio.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/local/local_storage.dart';

///
///Token拦截器
///
class TokenInterceptors extends InterceptorsWrapper {

  String _token;

  @override
  onRequest(RequestOptions options) async {
    //授权码
    if (_token == null) {
      var authorizationCode = await getAuthorization();
      if (authorizationCode != null) {
        _token = authorizationCode;
      }
    }
    if (_token != null){
      options.headers["Authorization"] = "${Config.TOKEN_KEY} $_token";
    }
    return options;
  }


  @override
  onResponse(Response response) async{
    try {
      var responseJson = response.data;
      if (response.statusCode == 201 && responseJson["token"] != null) {
        _token = 'token ' + responseJson["token"];
        await LocalStorage.save(Config.TOKEN_KEY, _token);
      }
    } catch (e) {
      print(e);
    }
    return response;
  }

  ///清除授权
  clearAuthorization() {
    this._token = null;
    LocalStorage.remove(Config.TOKEN_KEY);
  }

  ///获取授权token
  getAuthorization() async {
    String token = await LocalStorage.get(Config.TOKEN_KEY);
    if (token == null) {
      //token 不存在未登录状态
    } else {
      this._token = token;
      return token;
    }
  }
}