import 'package:event_bus/event_bus.dart';
import 'package:flutter_start/common/net/http_error_event.dart';
import 'package:fluttertoast/fluttertoast.dart';
///错误编码
class Code {
  ///网络错误
  static const NETWORK_ERROR = -1;

  ///网络超时
  static const NETWORK_TIMEOUT = -2;

  ///网络返回数据格式化一次
  static const NETWORK_JSON_EXCEPTION = -3;

  static const SUCCESS = 200;

  static final EventBus eventBus = new EventBus();

  static errorHandleFunction(code, message, noTip) {
    if(noTip) {
      return message;
    }
    switch (code) {
      case Code.NETWORK_ERROR:
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "网络错误");
        break;
      case 401:
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "[401错误可能: 未授权 \\ 授权登录失败 \\ 登录过期]");
        break;
      case 403:
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "403权限错误");
        break;
      case 404:
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "404错误");
        break;
      case Code.NETWORK_TIMEOUT:
      //超时
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "请求超时");
        break;
      default:
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "其他异常" + " " + message);
        break;
    }
    return message;
  }

}
