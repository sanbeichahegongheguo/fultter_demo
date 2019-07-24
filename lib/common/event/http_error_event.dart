import 'package:flutter/material.dart';
import 'package:flutter_start/common/net/code.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:oktoast/oktoast.dart';

class HttpErrorEvent {
  final int code;

  final String message;

  HttpErrorEvent(this.code, this.message);

  @override
  String toString() {
    return 'HttpErrorEvent{code: $code, message: $message}';
  }

  static errorHandleFunction(code, message, BuildContext context) {
    switch (code) {
      case Code.NETWORK_ERROR:
        showToast("网络异常,请稍后重试");
        break;
      case 401:
        NavigatorUtil.goWelcome(context);
        showToast("登录失效,请重新登录");
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
