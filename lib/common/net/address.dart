///地址数据
class Address {
//  static const String studentWebHost = "http://192.168.6.31:30915/student:";
  static const String studentWebHost = "https://www.k12china.com/student/student:";
  static const String k12apiHost = "https://www.k12china.com/k12-api/";

  ///登录  post
  static login() {
    return "${studentWebHost}login";
  }

  ///获取用户登录信息
  static getUserLoginInfo() {
    return "${studentWebHost}getUserLoginInfo";
  }

  ///发送手机验证码
  static sendMobileCode() {
    return "${studentWebHost}sendMobileCode";
  }

  //更换头像
  static uploadHeadUrl() {
    return "${studentWebHost}uploadHeadUrl";
  }

  ///获取图形验证码
  static getImgCode() {
    return "${k12apiHost}base/getValidateCode";
  }

  ///获取认证码
  static getValidateCode() {
    return "${k12apiHost}base/getValidateCodeV2";
  }
}
