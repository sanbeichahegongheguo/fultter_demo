///地址数据
class Address {
  static const String studentWebHost = "https://www.k12china.com/student/student:";
//  static const String studentWebHost = "http://192.168.6.31:30915/student:";
  ///登录  post
  static login() {
    return "${studentWebHost}login";
  }

  ///获取用户登录信息
  static getUserLoginInfo() {
    return "${studentWebHost}getUserLoginInfo";
  }
  //更换头像
  static uploadHeadUrl(){
    return"${studentWebHost}uploadHeadUrl";
  }
}
