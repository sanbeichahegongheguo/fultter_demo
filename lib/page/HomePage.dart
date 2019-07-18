import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/widget/gsy_tabbar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_start/page/AdminPage.dart';
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
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    List<int> bytes = await image.readAsBytes();
    var base64encode = base64Encode(bytes);
    print("base64 $base64encode");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
//      onWillPop: () {
//        return _dialogExitApp(context);
//      },
      child: new GSYTabBarWidget(
        tabViews: [
          GestureDetector(
            onTap: () async {
              NavigatorUtil.goWebView(context, "https://www.k12china.com/h5/cardGame/index.html");
//              NavigatorUtil.goWebView(context, "http://192.168.20.38:8099");
            },
            child: Stack(
              alignment: const FractionalOffset(0.5, 0.5), //方法一
              children: <Widget>[
                Container(),
                new Stack(
                  alignment: const FractionalOffset(0.5, 0.5), //方法一
                  children: <Widget>[
                    new Opacity(
                      opacity: 1,
                      child: new Image(
                        image: new AssetImage("images/home/select.png"),
                        width: ScreenUtil.getInstance().getWidthPx(260),
                        height: ScreenUtil.getInstance().getHeightPx(175),
                        fit: BoxFit.cover,
                      ),
                    ),
                    new Tab(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Image.asset(
                            "images/home/icon_study_select.png",
                            fit: BoxFit.scaleDown,
                            height: 20,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          new Text(
                            "个人中心",
                            style: TextStyle(fontSize: 12, color: Color(0xFF606a81)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          new Center(
            child: Text("2222"),
          ),
          new Center(
            child: Text("3333"),
          ),
          new Admin(),
        ],
        backgroundColor: Colors.lightBlueAccent,
        indicatorColor: Colors.lightBlueAccent,
      ),
    );
  }
}
