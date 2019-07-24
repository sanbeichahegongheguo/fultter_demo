import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/page/EyeProtectionPage.dart';
import 'package:flutter_start/page/HomePage.dart';
import 'package:flutter_start/page/JoinClassPage.dart';
import 'package:flutter_start/page/LoginPage.dart';
import 'package:flutter_start/page/PhoneLoginPage.dart';
import 'package:flutter_start/page/RegisterPage.dart';
import 'package:flutter_start/page/ResetMobilePage.dart';
import 'package:flutter_start/page/ResetPasswordPage.dart';
import 'package:flutter_start/page/UserInfoPage.dart';
import 'package:flutter_start/page/WebViewPage.dart';

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
  static goRegester(BuildContext context,{String from,bool isLogin = false,int index = 0,String userPhone}) {
    NavigatorRouter(context, RegisterPage(from:from,index: index,userPhone:userPhone,isLogin:isLogin));
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

  ///去往webview
  static goWebView(BuildContext context, String url) async {
    String key = await httpManager.getAuthorization();
    print("@key:  $key ");
    if (null != key && "" != key) {
      if (url.contains("?")) {
        url = "$url&t=${DateTime.now().millisecondsSinceEpoch}&key=$key&from=study_parent";
      } else {
        url = "$url?t=${DateTime.now().millisecondsSinceEpoch}&key=$key&from=study_parent";
      }
    }
    print("@跳转链接:$url");
    NavigatorRouter(context, WebViewPage(url));
//    NavigatorRouter(context,WebViewExample(url));
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
