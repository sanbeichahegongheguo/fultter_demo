import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/page/WebViewPage.dart';
import 'package:flutter_start/utils/PageRouteHelper.dart';
import 'package:flutter_start/page/HomePage.dart';
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
  static goHome(BuildContext context) {
    Navigator.pushReplacement(context, PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
        return new HomePage();
      }));
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

}