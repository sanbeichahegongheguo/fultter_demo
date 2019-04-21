import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/page/WebViewPage.dart';
import 'package:flutter_start/utils/PageRouteHelper.dart';
import 'package:flutter_start/page/LogoPage.dart';
import 'package:flutter_start/page/LoginPage.dart';
class NavigatorUtil {

  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///主页
  static goLogo(BuildContext context) {
//    NavigatorRouter(context,LogoPage());
    Navigator.push(context, PageRouteBuilderHelper(
        pageBuilder: (BuildContext context, _, __) {
          return LogoPage();
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
  static goLogin(BuildContext context) {
    NavigatorRouter(context,LoginPage());
  }

  ///去往webview
  static goWebView(BuildContext context,String url) {
    NavigatorRouter(context,WebViewPage(url));
  }

  static NavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context, PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
      return widget;
    }));
  }

  static NavigatorRouterReplacement(BuildContext context, Widget widget) {
    return Navigator.pushReplacement(context, PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
      return widget;
    }));
  }

}