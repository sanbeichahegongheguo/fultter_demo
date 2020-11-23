import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';

class AddressUtil {
  String common_dc_client = "https://www.k12china.com/common_dc_client/";
  String stu_app = "https://www.k12china.com/stu_app/v1/";
  String h5Host = "https://www.k12china.com/h5/";
  String studentWebHost = "https://api.k12china.com/studentweb/";
  String studentHost = "https://www.k12china.com/student/student:";
  String k12apiHost = "https://www.k12china.com/k12-api/";
  String sw_api_ = "https://api.k12china.com/sw/api/v1/";
  String stu_upload = "https://www.k12china.com/stu_upload/";
  String agora_base_url = "https://api.agora.io";
  String ws_url = "wss://www.k12china.com";
  String apiHost = "https://api.k12china.com/";
  String qresHost = "https://qres.k12china.com/";
  String stu_h5 = "https://www.k12china.com/stu_h5/web/";
  String liveApp = "https://www.k12china.com/app_live/";
//  String studentHost = "http://192.168.6.31:30915/student:";
//  String k12apiHost = "http://192.168.6.30:31191/k12-api/";
//  String studentWebHost = "http://192.168.6.31:31528/studentweb/";
//  String stu_app = "http://192.168.6.30:31255/stu_app/v1/";
//  String h5Host = "http://192.168.6.30:30593/";
//  String common_dc_client = "http://192.168.6.30:31221/common_dc_client/";
//  String sw_api_ = "http://192.168.6.30:30309/sw/api/v1/";
//  String stu_upload = "http://192.168.6.30:31921/stu_upload/";
//  String ws_url = "ws://192.168.6.30:30531";
//  String apiHost = "http://192.168.6.30:31456/";
//  String qresHost = "https://qres.k12china.com/";
//  String agora_base_url = "https://api.agora.io";
//  String stu_h5 = "http://192.168.6.30:31842/stu_h5/web/";

  String getSchoolUrl = "https://www.k12china.com/k12-api/search/getSchool";

  _domain1() {
    common_dc_client = "https://www.k12china.com/common_dc_client/";
    stu_app = "https://www.k12china.com/stu_app/v1/";
    h5Host = "https://www.k12china.com/h5/";
    studentWebHost = "https://api.k12china.com/studentweb/";
    studentHost = "https://www.k12china.com/student/student:";
    k12apiHost = "https://www.k12china.com/k12-api/";
    sw_api_ = "https://api.k12china.com/sw/api/v1/";
    stu_upload = "https://www.k12china.com/stu_upload/";
    getSchoolUrl = "https://www.k12china.com/k12-api/search/getSchool";

    ws_url = "wss://www.k12china.com";
    apiHost = "https://api.k12china.com/";
    qresHost = "https://qres.k12china.com/";
    stu_h5 = "https://www.k12china.com/stu_h5/web/";
    liveApp = "https://www.k12china.com/app_live/";

//    studentHost = "http://192.168.6.31:30915/student:";
//    k12apiHost = "http://192.168.6.30:31191/k12-api/";
//    studentWebHost = "http://192.168.6.31:31528/studentweb/";
//    stu_app = "http://192.168.6.30:31255/stu_app/v1/";
//    h5Host = "http://192.168.6.30:30593/";
//    common_dc_client = "http://192.168.6.30:31221/common_dc_client/";
//    sw_api_ = "http://192.168.6.30:30309/sw/api/v1/";
//    stu_upload = "http://192.168.6.30:31921/stu_upload/";
//    ws_url = "ws://192.168.6.30:30531";
//    apiHost = "http://192.168.6.30:31456/";
//    qresHost = "https://qres.k12china.com/";
//    stu_h5 = "http://192.168.6.30:31842/stu_h5/web/";
//    liveApp = "http://192.168.6.30:32442/app_live/";
  }

  _domain2() {
    common_dc_client = "https://www.yondor.cn/common_dc_client/";
    stu_app = "https://www.yondor.cn/stu_app/v1/";
    h5Host = "https://www.yondor.cn/h5/";
    studentWebHost = "https://api.yondor.cn/studentweb/";
    studentHost = "https://www.yondor.cn/student/student:";
    k12apiHost = "https://www.yondor.cn/k12-api/";
    sw_api_ = "https://api.yondor.cn/sw/api/v1/";
    getSchoolUrl = "https://www.yondor.cn/k12-api/search/getSchool";
    stu_upload = "https://www.yondor.cn/stu_upload/";
    stu_h5 = "https://www.yondor.cn/stu_h5/web/";
    liveApp = "https://www.yondor.com/app_live/";
  }

  static AddressUtil _singleton = AddressUtil();

  static AddressUtil getInstance() {
    return _singleton;
  }

  static String CheckIndexKey = "checkList_index";
  List<String> checkList = [
    "https://www.yondor.cn/stu_app/v1/admin/application",
  ];
  init() async {
    var index = SpUtil.getInt(CheckIndexKey, defValue: 0);
    for (var i = 0; i < checkList.length; i++) {
      var res = await ApplicationDao.appCheck(checkList[i]);
      if (res != null && res.result) {
        var data = res.data;
        index = data["hostType"];
        SpUtil.putInt(CheckIndexKey, i);
      }
    }
    switch (index) {
      case 0:
        _domain1();
        break;
      case 1:
        _domain1();
        break;
      case 2:
        _domain2();
        break;
    }
  }

  login() {
    return "${studentHost}login";
  }

  ///获取用户登录信息
  getUserLoginInfo() {
    return "${studentHost}getUserLoginInfo";
  }

  ///发送手机验证码
  sendMobileCode() {
    return "${studentHost}sendMobileCode";
  }

  ///更换头像
  uploadHeadUrl() {
    return "${studentHost}uploadHeadUrl";
  }

  ///获取图形验证码
  getImgCode() {
    return "${k12apiHost}base/getValidateCode?toBase64=T";
  }

  ///获取认证码
  getValidateCode() {
    return "${k12apiHost}base/getValidateCodeV2";
  }

  ///更换教程
  resetTextbookId() {
    return "${studentHost}resetTextbookId";
  }

  ///发送短信
  sendMobileCodeWithValiCode() {
    return "${k12apiHost}base/sendMobileCodeWithValiCodeV3";
  }

  ///发送短信
  resetMobile() {
    return "${studentHost}resetMobile";
  }

  ///检测是否拥有账号
  checkParentsUser() {
    return "${k12apiHost}base/checkParentsUser";
  }

  ///已有学生账号，检测学生账号和密码和家长账号
  checkStudent() {
    return "${k12apiHost}base/checkStudent";
  }

  ///更改家长：136家长改为135家长
  updateParentMobile() {
    return "${k12apiHost}base/updateParentMobile";
  }

  ///注册：验证手机号
  checkMobile() {
    return "${k12apiHost}base/checkMobile";
  }

  ///退出账号
  logout() {
    return "${studentHost}logout";
  }

  ///通过老师手机查询班级列表
  getTeacherClassList() {
    return "${studentWebHost}getTeacherClassList";
  }

  ///检查该班级是否有同名
  checkSameRealName() {
    return "${studentHost}checkSameRealName";
  }

  ///检测验证码
  checkCode() {
    return "${studentHost}checkCode";
  }

  ///搜索学校
  searchSchool() {
    return getSchoolUrl;
  }

  ///选择学校
  chooseSchool() {
    return "${k12apiHost}base/getClassNumDataV2";
  }

  ///检查该班级是否有同名,返回手机号
  checkSameRealNamePhone() {
    return "${studentWebHost}reg/checkClassSameName";
  }

  ///选择班级
  chooseClass() {
    return "${studentWebHost}reg/getclass";
  }

  ///验证姓氏是否合法
  checkname() {
    return "${k12apiHost}name/checkname";
  }

  ///是否同名
  checkClassSameName() {
    return "${k12apiHost}reg/checkClassSameName";
  }

  ///更改班级
  joinClass() {
    return "${studentHost}joinClass";
  }

  ///注册
  register() {
    return "${k12apiHost}base/register";
  }

  ///获取学生已设置护眼时间
  getEyeshiieldTime() {
    return "${stu_app}home/get_eyeshiield_time";
  }

  ///保存学生学习时间
  saveEyeshiieldTime() {
    return "${stu_app}home/save_eyeshiield_time";
  }

  ///更改密码
  resetPassword() {
    return "${studentHost}resetPassword";
  }

  ///获取学生本学期做题数和错题数及当天学习时间
  getStudyData() {
    return "${stu_app}home/get_study_data";
  }

  ///最新同步作业/口算作业/笔头作业
  getNewHomeWork() {
    return "${studentHost}getNewHomeWork";
  }

  ///获取所有单元
  getSynerrData() {
    return "${stu_app}home/get_synerr_data";
  }

  ///获取高频易错题做到第几题
  getStudymsgQues() {
    return "${stu_app}home/get_studymsg_ques";
  }

  ///获取本学期未完成作业数量【剔除】
//  getParentHomeWorkDataTotal() {
//    return "${studentWebHost}getParentHomeWorkDataTotal";
//  }

  ///获取本学期未完成作业数量【更换接口-有作业就跳去练习本】
  getParentHomeWorkDataTotal() {
    return "${sw_api_}course/getParentHomeWorkDataTotal";
  }

  ///获取热门兑换礼物
  getHotGoodsList() {
    return "${studentHost}getHotConvertMallGoodsList";
  }

  ///获取星星总数
  getTotalStar() {
    return "${studentHost}getTotalStar";
  }

  ///天神之战地址
  GameH5Address() {
    return "${h5Host}cardGame/index.html";
  }

  ///查询签到信息
  signReward() {
    return "${studentWebHost}sign/signReward";
  }

  ///跳转签到h5外链
  goH5Sign() {
    return "${h5Host}signIn/index.html";
  }

  ///跳转学情h5外链
  goH5StudyInfo() {
    return "${h5Host}sturdyInfo/index.html";
  }

  ///跳转到课程中心
  goCourseCenter() {
    return "${h5Host}courseCenter/index.html";
  }

  ///跳转到课程中心
  goBroadcastHor() {
    return "${h5Host}broadcast-hor/index.html";
  }

  ///获取未读取消息总数
  getUnReadNotice() {
    return "${studentHost}getUnReadNotice";
  }

  ///核对答案
  getExerciseBookNew() {
    return "${h5Host}exerciseBookNew/index.html";
  }

  ///消息页面
  getInfoPage() {
    return "${h5Host}infoPage/index.html";
  }

  ///用户隐私保护协议
  getPrivacyProtocol() {
    return "${h5Host}app-reg/privacyProtocol.html";
  }

  ///用户保护协议
  getUserProtocol() {
    return "${h5Host}app-reg/userProtocol.html";
  }

  ///注销账号地址
  goLogout() {
    return "${h5Host}xx/wxServer.html?discontent=logout";
  }

  ///英语随身听
  getWxEnglish() {
    return "${h5Host}wxEnglish/English.html";
  }

  ///百万地址
  MillionH5Address() {
    return "${h5Host}millionsQandA/index.html";
  }

  ///核对答案
  getQuickKing() {
    return "${h5Host}quickKing/index.html";
  }

  ///客服h5
  getWxServer() {
    return "${h5Host}xx/wxServer.html";
  }

  ///承诺书h5
  getCommitment() {
    return "${h5Host}reg-app/commitment.html";
  }

  ///教师信息公示
  teacherInfo() {
    return "${h5Host}teacherInfo/index.html?fromUrl=haxecallback:teacherInfo#/index";
  }

  ///用户服务协议
  getEducation() {
    return "${h5Host}reg-app/userProtocol.html";
  }

  ///用户服务隐私协议
  getPrivacy() {
    return "${h5Host}app-reg/privacyProtocol.html";
  }

  ///更改密码
  resetPwd() {
    return "${k12apiHost}base/updatePasswordByCode";
  }

  ///获取作业列表
  getParentHomeWorkDataList() {
    return "${studentHost}getParentHomeWorkDataList";
  }

  ///去错题拍拍
  goCtpp() {
    return "${h5Host}ctpp/index.html";
  }

  ///去错题中心
  goWrongCenter() {
    return "${h5Host}wrongCenter/index.html";
  }

  ///获取Banner广告
  getAppRevScreenAdver() {
    return "${studentHost}getAppRevScreenAdver";
  }

  ///获取模块栏目
  getModule() {
    return "${stu_app}home/get_parent_module";
  }

  ///星星商城地址
  StarMallAddress() {
    return "${h5Host}starMall/index.html";
  }

  ///获取更新版本信息
  getAppVersionInfo() {
    return "${studentHost}getAppVersionInfo";
  }

  ///获取App Store版本信息
  getAppStoreVersionInfo() {
    return "https://itunes.apple.com/cn/lookup?id=${Config.IOS_APP_ID}";
  }

  ///获取App后台配置信息
  getAppApplication() {
    return "${stu_app}admin/application";
  }

  ///辅导页面公告
  indexNotice() {
    return "${stu_app}home/announcement";
  }

  ///获取可查看课程
  getMainLastCourse() {
    return "${sw_api_}course/get_main_last_course";
  }

  ///流量统计
  statistics() {
    return "${common_dc_client}dc/send.html";
  }

  ///对象统计
  sendObj() {
    return "${common_dc_client}dc/sendObj.html";
  }

  ///获取APP启动公告
  getAppNotice() {
    return "${studentHost}getAppNotice";
  }

  ///设备信息收集
  sendDeviceInfo() {
    if (Platform.isIOS) {
      return "${common_dc_client}dc/sendIPhoneInfo.html";
    } else {
      return "${common_dc_client}dc/sendPhoneInfo.html";
    }
  }

  ///用户隐私保护协议
  goAgreement() {
    return "${h5Host}app-reg/privacyProtocol.html";
  }

  // 获取用户学习的时间
  getStudyTime() {
    return "${stu_app}home/get_study_time";
  }

  // 每一分钟存储用户学习的时间
  saveStudyTotalTime() {
    return "${stu_app}home/save_study_totaltime";
  }

  // 设置用户延时的时间
  saveDelayTime() {
    return "${stu_app}home/save_delay_time";
  }

  // 传送用户禁止的时间
  saveForbidTime() {
    return "${stu_app}home/save_forbid_time";
  }

  // 获取上传密钥
  uploadSign() {
    return "${stu_upload}sts";
  }

  ///检查是否设置监护密码
  getCheckPassword() {
    return "${studentHost}getCheckPassword";
  }

  ///检查监护密码是否正确
  checkPassword() {
    return "${studentHost}checkPassword";
  }

  ///修改密码
  editCheckPassword() {
    return "${studentHost}editCheckPassword";
  }

  ///清除密码
  delCheckPassword() {
    return "${studentHost}delCheckPassword";
  }

  ///IOS支付检验
  validateApplePay() {
    return "${stu_app}home/validate_apple_pay";
  }

  ///加入房间
  roomEntry(String appId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/entry";
  }

  ///加入房间
  yondorRoomEntry() {
    return "${liveApp}edu/v1/apps/room/entry";
  }

  ///获取房间信息
  room(String appId, String roomId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/$roomId";
  }

  ///获取房间信息
  yondorRoom(String roomId) {
    return "${liveApp}edu/v1/apps/room/$roomId";
  }

  ///退出房间
  roomExit(String appId, String roomId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/$roomId/exit";
  }

  ///获取房间用户信息
  roomUser(String appId, String roomId, String userId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/$roomId/user/$userId";
  }

  ///聊天
  roomChat(String appId, String roomId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/$roomId/chat";
  }

  ///聊天
  liveChat() {
    return "${liveApp}v1/msg/edu/send";
  }

  ///获取房间白班信息
  roomBoard(String appId, String roomId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/$roomId/board";
  }

  ///获取房间白班信息
  yondorRoomBoard(String roomId) {
    return "${liveApp}edu/v1/apps/room/$roomId/board";
  }

  ///获取回放信息
  getCourseRecordBy(String appId, String recordId, String roomId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/$roomId/record/$recordId";
  }

  ///举手连麦
  roomCoVideo(String appId, String roomId) {
    return "$agora_base_url/edu/v1/apps/$appId/room/$roomId/covideo";
  }

  ///举手连麦
  yondorRoomCoVideo(String roomId) {
    return "${liveApp}edu/v1/apps/room/$roomId/covideo";
  }

  ///加入房间
  socketUrl(String key, String roomId) {
    return "$ws_url/stu_chat/live?key=$key&roomId=$roomId";
  }

  ///腾讯云日志
  logcat() {
    return "${apiHost}logcat/app";
  }

  ///腾讯云日志配置
  logcatConfig(appid, userId) {
    return "${apiHost}logcat/config/$appid/$userId";
  }

  ///领取红包
  roomRewardStar() {
    return "${stu_app}live_broadcast/star";
  }

  ///获取用户星星
  getUserStar() {
    return "${stu_app}live_broadcast/star/user";
  }

  ///是否提交题目
  isDoQues() {
    return "${stu_app}live_broadcast/is_save_ques";
  }

  ///题目答题前三
  roomQuesTop() {
    return "${stu_app}live_broadcast/ques_top";
  }

  ///排行榜
  roomRankList() {
    return "${stu_app}home/live/rank/list";
  }

  ///排行榜
  roomStarRankList() {
    return "${stu_app}live_broadcast/star/rank/list";
  }

  ///排行榜
  roomRankUser() {
    return "${stu_app}home/live/rank/user";
  }

  ///排行榜
  roomStarRankUser() {
    return "${stu_app}live_broadcast/star/rank/user";
  }

  ///提交题目
  roomSaveQues() {
    return "${stu_app}live_broadcast/save_ques";
  }

  ///保存题目到题库
  saveQuesToQlib() {
    return "${stu_app}admin/quest";
  }

  ///获取用户分享金可提现金额金额url
  totalGainedMoney() {
    return "${sw_api_}share_money/total_gained_money";
  }

  //跳转到分享金
  goShareMoney() {
    return "${h5Host}share_money/index.html";
  }

  ///判断是否订阅产品
  getPermissionUrl() {
    return "${sw_api_}pay/permission";
  }

  //跳转到会员包
  goVipPackage() {
    return "${stu_h5}july_package/";
  }

  //获取回放信息
  getReplayInfo() {
    return "${stu_app}live_broadcast/replay";
  }

  //获取课程状态
  getCourseState() {
    return "${sw_api_}course/get_course_state";
  }

  ///获取远大回放信息
  getYondorCourseRecordBy() {
    return "${liveApp}v1/live_broadcast/record/info";
  }
}
