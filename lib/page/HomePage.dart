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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[new Icon(icon, size: 16.0), new Text(text)],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _renderTab(Icons.book, "学习"),
      _renderTab(Icons.android, "挑战"),
      _renderTab(Icons.person, "个人中心"),
      _renderTab(Icons.people, "家长专区"),
    ];
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: new GSYTabBarWidget(
        drawer: new Center(
          child:Text("0000"),
        ),
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