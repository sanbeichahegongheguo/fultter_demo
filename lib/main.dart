import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/page/SplashPage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/user.dart';

main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
  //隐藏状态栏
//  SystemChrome.setEnabledSystemUIOverlays([]);
//  //  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); //还原状态栏
  if (Platform.isIOS) {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }
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
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                locale:Locale('zh', 'CH'),
                supportedLocales:[Locale('zh', 'CH')],
                title: '远大小状元',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(primaryColor: Colors.lightBlueAccent),
                home: SplashPage(),
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
