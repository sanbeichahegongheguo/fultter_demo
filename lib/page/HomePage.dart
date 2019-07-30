import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/page/AdminPage.dart';
import 'package:flutter_start/widget/gsy_tabbar_widget.dart';

import 'CoachPage.dart';
import 'LearningEmotionPage.dart';
import 'parentReward.dart';

class HomePage extends StatelessWidget {
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

  _bulletinWindow(context){
    print("公告弹窗");
    var windowWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

      ],
    );
    //CommonUtils.showGuide(context,Text("12"));
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bulletinWindow(context);
    });
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: new GSYTabBarWidget(
        tabViews: [
          new CoachPage(),
          new LearningEmotionPage(),
          new parentReward(),
          new Admin(),
        ],
        backgroundColor: Colors.lightBlueAccent,
        indicatorColor: Colors.lightBlueAccent,
      ),
    );
  }
}
