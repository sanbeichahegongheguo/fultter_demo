import 'package:flutter_start/common/event/http_error_event.dart';
import 'package:flutter_start/common/event/index.dart';

///错误编码
class Code {
  ///网络错误
  static const NETWORK_ERROR = -1;

  ///网络超时
  static const NETWORK_TIMEOUT = -2;

  ///网络返回数据格式化一次
  static const NETWORK_JSON_EXCEPTION = -3;

  static const SUCCESS = 200;

  static errorHandleFunction(code, message, noTip) {
    if (noTip) {
      return message;
    }
    eventBus.fire(new HttpErrorEvent(code, message));
    return message;
  }
//  static errorHandleFunction(code, message, noTip) {
//    if (noTip) {
//      return message;
//    }
//    switch (code) {
//      case Code.NETWORK_ERROR:
////        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "网络错误");
//        showToast("网络异常,请稍后重试");
//        break;
//      case 401:
//        showToast("登录失效,请重新登录");
////        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "[401错误可能: 未授权 \\ 授权登录失败 \\ 登录过期]");
//        break;
//      case 403:
//        showToast("403权限错误");
////        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "403权限错误");
//        break;
//      case 404:
//        showToast("404错误");
////        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "404错误");
//        break;
//      case Code.NETWORK_TIMEOUT:
//        //超时
////        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "请求超时");
//        showToast("网络异常,请稍后重试");
//        break;
//      default:
//        showToast("异常" + " " + message);
////        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "其他异常" + " " + message);
//        break;
//    }
//    return message;
//  }
}
