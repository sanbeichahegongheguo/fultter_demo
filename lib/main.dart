import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/page/PhoneLoginPage.dart';
import 'package:flutter_start/page/SplashPage.dart';
import 'package:flutter_start/page/WelcomePage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

import 'models/user.dart';

main() {
  runApp(MyApp());
  //隐藏状态栏
  SystemChrome.setEnabledSystemUIOverlays([]);
//  //  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); //还原状态栏
//  if (Platform.isAndroid) {
//    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
//    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
//    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
//  }
}

class MyApp extends StatelessWidget {
  final store = new Store<GSYState>(appReducer,
      middleware: middleware,

      ///初始化数据
      initialState: new GSYState(
        userInfo: User(),
      ));

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: new StoreBuilder<GSYState>(
        builder: (context, store) {
          return OKToast(
              textPadding: EdgeInsets.all(11),
              textStyle: TextStyle(fontSize: 16),
              dismissOtherOnShow: true,
              child: MaterialApp(
                title: '远大小状元',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(primaryColor: Colors.lightBlueAccent),
                home: SplashPage(),
                routes: {
                  "logo": (context) => WelcomePage(),
                },
              ));
        },
      ),
    );
  }

  void _initAsync() async {
    await SpUtil.getInstance();
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.phone]);
//      if (permissions[PermissionGroup.phone] != PermissionStatus.granted) {
//        return null;
//      }
    }
  }
}
