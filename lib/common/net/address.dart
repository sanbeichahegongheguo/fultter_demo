///地址数据
class Address {
  //static const String studentWebHost = "http://192.168.6.31:30915/student:";

  static const String studentWebHost = "https://www.k12china.com/student/student:";
  static const String k12apiHost = "https://www.k12china.com/k12-api/";
  //static const String k12apiHost = "http://192.168.6.30:31191/k12-api/";
  static const String registerHost = "http://api.k12china.com/k12-api/search/getSchool";
  static const String regHost = "http://192.168.6.31:31528/studentweb/reg/getclass";

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

  ///更换头像
  static uploadHeadUrl() {
    return "${studentWebHost}uploadHeadUrl";
  }


  ///获取图形验证码
  static getImgCode() {
    return "${k12apiHost}base/getValidateCode?toBase64=T";
  }

  ///获取认证码
  static getValidateCode() {
    return "${k12apiHost}base/getValidateCodeV2";
  }

  ///更换教程
  static resetTextbookId() {
    return "${studentWebHost}resetTextbookId";
  }

  ///发送短信
  static sendMobileCodeWithValiCode() {
    return "${k12apiHost}base/sendMobileCodeWithValiCodeV3";
  }
  ///发送短信
  static resetMobile () {
    return "${studentWebHost}resetMobile";
  }

  ///检测是否拥有账号
  static checkParentsUser() {
    return "${k12apiHost}base/checkParentsUser";
  }

  ///退出账号
  static logout() {
    return "${studentWebHost}logout";
  }
  ///通过老师手机查询班级列表
  static getTeacherClassList() {
    return "${studentWebHost}getTeacherClassList";
  }
  ///检查该班级是否有同名
  static checkSameRealName() {
    return "${studentWebHost}checkSameRealName";
  }


  ///检测验证码
  static checkCode(){
    return "${studentWebHost}checkCode";
  }

  ///搜索学校
  static searchSchool(){
    return registerHost;
  }

  ///选择学校
  static chooseSchool(){
    return "${k12apiHost}base/getClassNumDataV2";
  }

  ///选择班级
  static chooseClass(){
    return regHost;
  }
  static joinClass(){
    return "${studentWebHost}joinClass";
  }
}
