import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/fragment/WebViewExample.dart';

class WelcomePage extends StatefulWidget {
  static final String sName = "home";
  @override
  State<StatefulWidget> createState() {
    return _WelcomeState();
  }
}

class _WelcomeState extends State<WelcomePage> {
  bool isOnLogin = false;
  File _image;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: GestureDetector(
            onTap: () {
//          FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 15, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            print("点击操作指南");
                            NavigatorUtil.goWebView(context, "https://api.k12china.com/share/u/operation.html?from=stulogin");
                          },
                          child: Text(
                            "操作指南",
                            style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Image.asset(
                        "images/login/studenthomepage_logp.png",
                        width: widthSrcreen * 0.75,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            print("点击登录");
                            NavigatorUtil.goLogin(context);
                          },
                          onHighlightChanged: (e) {
                            setState(() {
                              isOnLogin = e;
                            });
                          },
                          child: Image.asset(this.isOnLogin ? "images/login/studenthomepage_btn_hover.png" : "images/login/studenthomepage_btn.png",
                              width: widthSrcreen * 0.6, fit: BoxFit.cover),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: InkWell(
                      onTap: () {
                        print("点击注册");
                        NavigatorUtil.NavigatorRouter(context, WebViewExample("https://www.k12china.com/h5/app-reg-new/true_index.html?from=studentApp"));
                        //NavigatorUtil.goRegisterPage(context);
//                    NavigatorUtil.goWebView(context, "https://www.k12china.com/h5/app-reg-new/true_index.html?from=studentApp");
//                    Navigator.push(context,PageRouteBuilderHelper(pageBuilder: (BuildContext context, _, __) {
//                      return WebViewPage("https://www.k12china.com/h5/app-reg-new/true_index.html?from=studentApp");
//                    }));
                      },
                      child: Text(
                        "我没有账号",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,

                      ),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: const FractionalOffset(0.5, 0.0),
                  end: const FractionalOffset(0.5, 1.0),
                  colors: <Color>[Colors.lightBlueAccent, Colors.lightBlueAccent],
                ),
              ),
            ),
          )),
    );
  }

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
}
