import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_start/widget/gsy_tabbar_widget.dart';

class HomePage extends StatelessWidget{

  /// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: "android.intent.category.HOME",
      );
      await intent.launch();
    }

    return Future.value(false);
  }

  _renderTab(icon, text) {
    return new Tab(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[Image.asset(icon,fit: BoxFit.scaleDown,height: 20,), SizedBox(height: 2,),new Text(text,style: TextStyle(fontSize: 12,color: Color(0xFF606a81)),)],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _renderTab("images/home/icon_study.png", "学习"),
      _renderTab("images/home/icon_challenge.png", "挑战"),
      _renderTab("images/home/icon_user.png", "个人中心"),
      _renderTab("images/home/icon_parent.png", "家长专区"),
    ];
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: new GSYTabBarWidget(
        type: GSYTabBarWidget.BOTTOM_TAB,
        tabItems: tabs,
        tabViews: [
          new Center(
          child:Text("1111"),
            ),
          new Center(
            child:Text("2222"),
          ),
          new Center(
            child:Text("3333"),
          ),
          new Center(
            child:Text("44444"),
          ),
        ],
        backgroundColor: Colors.lightBlueAccent,
        indicatorColor: Colors.lightBlueAccent,
      ),
    );
  }

}