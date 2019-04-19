import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/page/HomePage.dart';
import 'package:flutter_start/page/LoginPage.dart';

void main() {
  runApp(MyApp());
  //隐藏状态栏
  SystemChrome.setEnabledSystemUIOverlays([]);
//  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); //还原状态栏
//  if (Platform.isAndroid) {
// 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
//    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
//    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
//  }
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilibili',
      theme: ThemeData(
      primarySwatch: Colors.blue),
      home:HomePage(),
    );
  }
}