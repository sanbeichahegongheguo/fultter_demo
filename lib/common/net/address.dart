///地址数据
class Address {
  static const String studentHost = "http://192.168.6.31:30915/student:";
  static const String k12apiHost = "http://192.168.6.30:31191/k12-api/";
  static const String studentWebHost = "http://192.168.6.31:31528/studentweb/";

  static const String getSchoolUrl = "http://api.k12china.com/k12-api/search/getSchool";
 //static const String studentWebHost = "https://api.k12china.com/studentweb/";
  //  static const String studentWebHost = "https://www.k12china.com/student/student:";
//  static const String k12apiHost = "https://www.k12china.com/k12-api/";

  ///登录  post
  static login() {
    return "${studentHost}login";
  }

  ///获取用户登录信息
  static getUserLoginInfo() {
    return "${studentHost}getUserLoginInfo";
  }

  ///发送手机验证码
  static sendMobileCode() {
    return "${studentHost}sendMobileCode";
  }

  ///更换头像
  static uploadHeadUrl() {
    return "${studentHost}uploadHeadUrl";
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
    return "${studentHost}resetTextbookId";
  }

  ///发送短信
  static sendMobileCodeWithValiCode() {
    return "${k12apiHost}base/sendMobileCodeWithValiCodeV3";
  }
  ///发送短信
  static resetMobile () {
    return "${studentHost}resetMobile";
  }

  ///检测是否拥有账号
  static checkParentsUser() {
    return "${k12apiHost}base/checkParentsUser";
  }

  ///退出账号
  static logout() {
    return "${studentHost}logout";
  }
  ///通过老师手机查询班级列表
  static getTeacherClassList() {
    return "${studentHost}getTeacherClassList";
  }
  ///检查该班级是否有同名
  static checkSameRealName() {
    return "${studentHost}checkSameRealName";
  }


  ///检测验证码
  static checkCode(){
    return "${studentHost}checkCode";
  }

  ///搜索学校
  static searchSchool(){
    return getSchoolUrl;
  }

  ///选择学校
  static chooseSchool(){
    return "${k12apiHost}base/getClassNumDataV2";
  }

  ///检查该班级是否有同名,返回手机号
  static checkSameRealNamePhone() {
    return "${studentWebHost}reg/checkClassSameName";
  }

  ///选择班级
  static chooseClass(){
    return "${studentWebHost}reg/getclass";
  }

  ///验证姓氏是否合法
  static checkname(){
    return "${k12apiHost}name/checkname";
  }

  ///是否同名
  static checkClassSameName(){
    return "${k12apiHost}reg/checkClassSameName";
  }

  static joinClass(){
    return "${studentHost}joinClass";
  }

  ///注册
  static register() {
    return "${k12apiHost}base/register";
  }
}
