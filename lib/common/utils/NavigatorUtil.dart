import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:flutter_start/page/EyeProtectionPage.dart';
import 'package:flutter_start/page/HomePage.dart';
import 'package:flutter_start/page/HomeWorkDuePage.dart';
import 'package:flutter_start/page/JoinClassPage.dart';
import 'package:flutter_start/page/LoginPage.dart';
import 'package:flutter_start/page/PhoneLoginPage.dart';
import 'package:flutter_start/page/RegisterPage.dart';
import 'package:flutter_start/page/ResetMobilePage.dart';
import 'package:flutter_start/page/ResetPasswordPage.dart';
import 'package:flutter_start/page/StudentAppPage.dart';
import 'package:flutter_start/page/UserInfoPage.dart';
import 'package:flutter_start/page/WebViewPage.dart';
import 'package:flutter_start/page/retrievePasswordPage.dart';
import 'package:flutter_start/page/BuildArchivesPage.dart';
import 'package:package_info/package_info.dart';

import 'DeviceInfo.dart';

class NavigatorUtil {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///欢迎页
  static goWelcome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (BuildContext context) => PhoneLoginPage()),
      (Route<dynamic> route) => false,
    );
//    NavigatorRouter(context,LogoPage());
//    Navigator.push(context, PageRouteBuilderHelper(
//        pageBuilder: (BuildContext context, _, __) {
//          return WelcomePage();
//        },
//        transitionsBuilder:(context, animation, secondaryAnimation, child){
//         return SlideTransition(
//            position: new Tween<Offset>(
//              begin: Offset(-1.0, 0.0),
//              end: Offset(0.0, 0.0),
//            ).animate(animation),
//            child: child,
//          );
//        },
//       ));
  }

  ///登录
  static goLogin(BuildContext context, {String account, String password}) {
    NavigatorRouter(context, LoginPage(account: account, password: password));
  }

  ///注册
  static goRegester(BuildContext context,{String from,bool isLogin = false,int index = 0,String userPhone,int registerState, String head,String name, int userId, String stuPhone}) {
    NavigatorRouter(context, RegisterPage(from:from,index: index, userPhone:userPhone, isLogin:isLogin, registerState: registerState, head: head, name: name, userId: userId, stuPhone:stuPhone));
  }

  ///注册前夕-建立学习档案
  static goBuildArchives(BuildContext context,{int registerState,int index = 0, String userPhone, String head, String name, int userId}) {
    NavigatorRouter(context, BuildArchivesPage(registerState: registerState, index: index, userPhone: userPhone, head: head, name: name,userId: userId));
  }

  ///找回密码
  static goRePassword(BuildContext context) {
    NavigatorRouter(context,retrievePasswordPage());
  }

  ///去个人资料
  static goUserInfo(BuildContext context) {
    NavigatorRouter(context, UserInfo());
  }

  ///更改手机号
  static goResetMobilePage(BuildContext context) {
    NavigatorRouter(context, ResetMobilePage());
  }

  ///主页
  static goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (BuildContext context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }
  ///去手机号登陆
  static goPhoneLoginPage(BuildContext context) {
    NavigatorRouter(context, PhoneLoginPage());
  }
  ///更换班级
  static goJoinClassPage(BuildContext context) {
    NavigatorRouter(context, JoinClassPage());
  }
  ///护眼设置
  static goEyeProtectionPage(BuildContext context) {
    NavigatorRouter(context, EyeProtectionPage());
  }
  ///更改密码
  static goResetPasswordPage(BuildContext context) {
    NavigatorRouter(context, ResetPasswordPage());
  }
  ///远大小状元学生
  static goStudentAppPage(BuildContext context) {
    NavigatorRouter(context, StudentAppPage());
  }
  ///去往期作业
  static goHomeWorkDuePage(BuildContext context) {
    NavigatorRouter(context, HomeWorkDuePage());
  }
  ///去往webview
  static goWebView(BuildContext context, String url,{String router = ""}) async {
     if (url.indexOf("#")!=-1 && router ==""){
       var split = url.split("#/");
       if(split.length>1){
         url = split[0];
         router = split[1];
       }
     }
    String key = await httpManager.getAuthorization();
    print("@key:  $key ");
    String from = "study_parent";
    String toFrom = "study_parent_router";
    var version =  (await PackageInfo.fromPlatform()).version;
    var deviceId = await DeviceInfo.instance.getDeviceId();

    if (null != key && "" != key) {
      String param = "t=${DateTime.now().millisecondsSinceEpoch}&key=$key&from=$from&curVersion=$version&deviceId=$deviceId";
      if (url.contains("?")) {
        url = "$url&$param";
      } else {
        url = "$url?$param";
      }
    }else{
      String param = "t=${DateTime.now().millisecondsSinceEpoch}&from=$from&curVersion=$version&deviceId=$deviceId";
      if (url.contains("?")) {
        url = "$url&$param";
      } else {
        url = "$url?$param";
      }
    }
    if(router != ""){
      url += "&toFrom=$toFrom#/"+router;
    }

    print("NavigatorUtil @跳转链接:$url");
    return NavigatorRouter(context, WebViewPage(url));
//    NavigatorRouter(context,WebViewExample(url));
  }

  ///去往webview
  static goAdWebView(BuildContext context, Adver ad) async {
    AppBar appBar = AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.lightBlueAccent,
        //居中显示
        centerTitle: true,
        leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF333333),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }
        ),
        title: Text(
          ad.adverName,
          style: TextStyle(color: Color(0xFF333333)))
    );
    return NavigatorRouter(context, WebViewPage(ad.target,appBar:appBar));
  }

  static NavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context, new CupertinoPageRoute(builder: (context) => widget));
//    return Navigator.push(context, PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
//      return widget;
//    }));
  }

  static NavigatorRouterReplacement(BuildContext context, Widget widget) {
    return Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (context) => widget));
//    return Navigator.pushReplacement(context, PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
//      return widget;
//    }));
  }

  ///弹出 dialog
  static Future<T> showGSYDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {
    return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(
              ///不受系统字体缩放影响
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1),
              child: new SafeArea(child: builder(context)));
        });
  }
}
