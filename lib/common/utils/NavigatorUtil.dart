import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/PageRouteHelper.dart';
import 'package:flutter_start/fragment/WebViewExample.dart';
import 'package:flutter_start/page/HomePage.dart';
import 'package:flutter_start/page/LoginPage.dart';
import 'package:flutter_start/page/WelcomePage.dart';
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
//    NavigatorRouter(context,LogoPage());
    Navigator.push(context, PageRouteBuilderHelper(
        pageBuilder: (BuildContext context, _, __) {
          return WelcomePage();
        },
        transitionsBuilder:(context, animation, secondaryAnimation, child){
         return SlideTransition(
            position: new Tween<Offset>(
              begin: Offset(-1.0, 0.0),
              end: Offset(0.0, 0.0),
            ).animate(animation),
            child: child,
          );
        },
       ));
  }
  ///登录
  static goLogin(BuildContext context,{String account,String password}) {
    NavigatorRouter(context,LoginPage(account:account,password:password));
  }
  ///主页
  static goHome(BuildContext context) {
    NavigatorRouter(context,HomePage());
  }

  ///去往webview
  static goWebView(BuildContext context,String url) {
    NavigatorRouter(context,WebViewPage(url));
//    NavigatorRouter(context,WebViewExample(url));
  }

  static NavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context, new CupertinoPageRoute(builder: (context) => widget));
//    return Navigator.push(context, PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
//      return widget;
//    }));
  }

  static NavigatorRouterReplacement(BuildContext context, Widget widget) {
    return Navigator.push(context, new CupertinoPageRoute(builder: (context) => widget));
//    return Navigator.pushReplacement(context, PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
//      return widget;
//    }));
  }

}