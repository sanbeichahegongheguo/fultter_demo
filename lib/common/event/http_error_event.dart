import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/net/code.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/index.dart';
import 'package:oktoast/oktoast.dart';
import 'package:redux/redux.dart';

class HttpErrorEvent {
  final int code;

  final String message;

  HttpErrorEvent(this.code, this.message);

  @override
  String toString() {
    return 'HttpErrorEvent{code: $code, message: $message}';
  }

  static errorHandleFunction(code, message, BuildContext context) {
    print("code $code");
    switch (code) {
      case Code.NETWORK_ERROR:
        showToast("网络异常,请稍后重试");
        break;
      case 401:
        var user = SpUtil.getObject(Config.LOGIN_USER);
        if (user == null) {
          showToast("登录失效,请重新登录");
          NavigatorUtil.goWelcome(context);
          try {
            SpUtil.remove(Config.LOGIN_USER);
            httpManager.clearAuthorization();
            Store<GSYState> store = StoreProvider.of(context);
            store.dispatch(UpdateUserAction(User()));
          } catch (e) {
            print(e);
          }
        }

        break;
      case 403:
        showToast("权限不足");
        print("403权限错误:$message");
        break;
      case 404:
        showToast("网络异常,请稍后重试");
        print("找不到该链接:$message");
        break;
      case Code.NETWORK_TIMEOUT:
        //超时
        showToast("网络异常,请稍后重试");
        break;
      default:
        showToast("网络异常,请稍后重试");
        print("网络错误:$message");
        break;
    }
    return message;
  }
}
