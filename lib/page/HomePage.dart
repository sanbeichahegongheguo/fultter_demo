import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/page/AdminPage.dart';
import 'package:flutter_start/widget/gsy_tabbar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

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

  Future _getImage() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var res = await Tflite.loadModel(
        model: "assets/model.tflite");
    print("res $res");
    print("base64 $appDocDir");
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
    _getImage();
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
