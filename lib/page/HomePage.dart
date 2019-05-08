import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 1125, height: 2001)..init(context);
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: new GSYTabBarWidget(
        tabViews: [
          new Stack(
            alignment: const FractionalOffset(0.5, 0.5),//方法一
            children: <Widget>[
              Container(),
              new Stack(
                alignment: const FractionalOffset(0.5, 0.5),//方法一
                children: <Widget>[
                  new Opacity(
                    opacity: 1,
                    child: new Image(
                      image: new AssetImage("images/home/select.png"),
                      width: ScreenUtil.getInstance().setWidth(193),
                      height: ScreenUtil.getInstance().setHeight(175),
                      fit: BoxFit.cover,
                    ),
                  ),
                  new Tab(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Image.asset("images/home/icon_study_select.png",fit: BoxFit.scaleDown,height: 20,), SizedBox(height: 2,),new Text("个人中心",style: TextStyle(fontSize: 12,color: Color(0xFF606a81)),)],
                    ),
                  ),
                ],
              ),
            ],
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