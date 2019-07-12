
import 'package:flutter_start/common/config/config.dart';

///地址数据
class Address {

  static const String studentWebHost = "https://www.k12china.com/student/student:";
//  static const String studentWebHost = "http://192.168.6.31:30915/student:";

  ///登录  post
  static login() {
    return "${studentWebHost}login";
  }


}
