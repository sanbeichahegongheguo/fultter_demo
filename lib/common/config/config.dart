import 'dart:ui';

class Config {
  static const PAGE_SIZE = 20;
  static const DEBUG = false;
  static const USE_NATIVE_WEBVIEW = true;

  /// //////////////////////////////////////常量////////////////////////////////////// ///
  static const TOKEN_KEY = "token";
  static const USER_NAME_KEY = "user-name";
  static const PW_KEY = "user-pw";
  static const USER_BASIC_CODE = "user-basic-code";
  static const USER_INFO = "user-info";
  static const LANGUAGE_SELECT = "language-select";
  static const LANGUAGE_SELECT_NAME = "language-select-name";
  static const REFRESH_LANGUAGE = "refreshLanguageApp";
  static const THEME_COLOR = "theme-color";
  static const LOCALE = "locale";
  static const LOGIN_USER = "login-user";
  static const DATA_FROM = "parentApp";
  static const USER_PHONE = "user-phone";
  static const DES_IV = "myyondor"; //加密偏移值
  static const PHONE_UID = "phone-uid"; //加密偏移值
  static const PARENT_HOME = "parentHomeWorkList";//最近作业集合
  static const STUDY_MSG = "studyMsg";//用户学习情况
  static const starNum = "star-num";
  static const hotGiftList = "hot-gift-list";
  static const ADVER_KEY = "adver";
  static const parentRewardModule = "parent-reward-module";   //家长奖励模块
  static const coachXZYModule = "coach-xzy-module";  //辅导页面小状元模块
  static const coachJZModule = "coach-jz-module";  //辅导页面精准教育模块
  static const lEmotionModule = "l-emotion-module";  //学情页面模块
  static const SIGN_TIMES = "sign-times";
  static const ANDROID_AD_APP_ID = "1106507482";  //安卓腾讯广告 appid
  static const ANDROID_BANNER_ID = "1060575419369196"; //安卓腾讯广告 bannerId
  static const IOS_AD_APP_ID = "1106430707";    //IOS  腾讯广告 appid
  static const IOS_BANNER_ID = "1060186030422542";//IOS  腾讯广告 bannerId
  static const LANGUAGE = Locale('zh', 'CH');
  static const TITLE ='远大小状元家长';
  static const CUR_VERSION ='2.0.000';
  static const indexNotice ='index-notice';   //辅导页面顶部公告
  static const APPAPPLICATION_KEY ='APPAPPLICATION_KEY';   //辅导页面顶部公告
  static const IOS_APP_ID ='1155973972';   //苹果商店appid
  static const EVENT_287 ='event_287';   //启动事件
  static const tenUrl = "https://android.myapp.com/myapp/detail.htm?apkName=com.yondor.student";
  static const iosUrl = "https://apps.apple.com/cn/app/id${Config.IOS_APP_ID}";
  static const STUDENT_SCHEME = "yondorstudenthwapp://"; //学生端路由
  static const STUDENT_TEN_URL = "https://android.myapp.com/myapp/detail.htm?apkName=com.yondor.yondorstudenthwapp"; //學生端應用寶
  static const STUDENT_IOS_URL = "https://apps.apple.com/cn/app/id1475045442"; //學生端苹果商店
}
