///地址数据
class Address {
  static const String studentHost = "http://192.168.6.31:30915/student:";
  static const String k12apiHost = "http://192.168.6.30:31191/k12-api/";
  static const String studentWebHost = "http://192.168.6.31:31528/studentweb/";
  static const String stu_app = "http://192.168.6.30:31255/stu_app/v1/home/";
  static const String h5Host = "http://192.168.6.30/";



  static const String getSchoolUrl = "http://api.k12china.com/k12-api/search/getSchool";
//  static const String stu_app = "https://www.k12china.com/stu_app/v1/home/";
//  static const String stu_app = "https://www.k12china.com/h5/";
//  static const String studentWebHost = "https://api.k12china.com/studentweb/";
//   static const String studentHost = "https://www.k12china.com/student/student:";
//    static const String k12apiHost = "https://www.k12china.com/k12-api/";

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
  ///更改班级
  static joinClass(){
    return "${studentHost}joinClass";
  }

  ///注册
  static register() {
    return "${k12apiHost}base/register";
  }

  ///获取学生已设置护眼时间
  static getEyeshiieldTime(){
    return "${stu_app}get_eyeshiield_time";
  }
  ///保存学生学习时间
  static saveEyeshiieldTime(){
    return "${stu_app}save_eyeshiield_time";
  }
  ///更改密码
  static resetPassword() {
    return "${studentHost}resetPassword";
  }
  ///获取学生本学期做题数和错题数及当天学习时间
  static getStudyData() {
    return "${stu_app}get_study_data";
  }
  ///最新同步作业/口算作业/笔头作业
  static getNewHomeWork() {
    return "${studentHost}getNewHomeWork";
  }

  ///获取热门兑换礼物
  static getHotGoodsList(){
    return "${studentHost}getHotConvertMallGoodsList";
  }

  ///获取星星总数
  static getTotalStar(){
    return "${studentHost}getTotalStar";
  }

  static GameH5Address(){
    return "${Address.h5Host}cardGame/index.html";
  }
  ///查询签到信息
  static signReward() {
    return "${Address.studentWebHost}sign/signReward";
  }
  ///跳转签到h5外链
  static goH5Sign(){
    return "${Address.h5Host}signIn/index.html";
  }
  ///获取未读取消息总数
  static getUnReadNotice() {
    return "${studentHost}getUnReadNotice";
  }
  ///核对答案
  static getExerciseBookNew() {
    return "${Address.h5Host}exerciseBookNew/index.html";
  }
  ///消息页面
  static getInfoPage() {
    return "${Address.h5Host}infoPage/index.html";
  }
}
