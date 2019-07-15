import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';

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
      if (!ObjectUtil.isEmptyString(authorizationCode)) {
        _token = authorizationCode;
      }
    }
    if (!ObjectUtil.isEmptyString(_token)) {
      options.headers["Authorization"] = "${Config.TOKEN_KEY} $_token";
    }
    return options;
  }

  @override
  onResponse(Response response) async {
    try {
//      var responseJson = response.data;
//      if (response.statusCode == 201 && responseJson["token"] != null) {
//        _token = 'token ' + responseJson["token"];
//        await LocalStorage.save(Config.TOKEN_KEY, _token);
//      }
    } catch (e) {
      print(e);
    }
    return response;
  }

  ///清除授权
  clearAuthorization() async {
    this._token = null;
    await SpUtil.remove(Config.TOKEN_KEY);
  }

  ///设置授权
  setAuthorization(String token) async {
    this._token = token;
    await SpUtil.putString(Config.TOKEN_KEY, token);
  }

  ///获取授权token
  Future<String> getAuthorization() async {
    if (!ObjectUtil.isEmptyString(this._token)) {
      //token 不存在未登录状态
      return this._token;
    } else {
      String token = SpUtil.getString(Config.TOKEN_KEY);
      print("token $token");
      this._token = token;
      return token;
    }
  }
}
