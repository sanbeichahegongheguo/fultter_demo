import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
        showToast("登录失效,请重新登录");
        NavigatorUtil.goWelcome(context);
        try{
          httpManager.clearAuthorization();
          Store<GSYState> store = StoreProvider.of(context);
          store.dispatch(UpdateUserAction(User()));
        }catch(e){
          print(e);
        }
        break;
      case 403:
        showToast("403权限错误");
        break;
      case 404:
        showToast("找不到该链接");
        break;
      case Code.NETWORK_TIMEOUT:
        //超时
        showToast("网络异常,请稍后重试");
        break;
      default:
        showToast("异常" + " " + message);
        break;
    }
    return message;
  }
}
