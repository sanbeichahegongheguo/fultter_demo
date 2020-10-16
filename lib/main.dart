import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/page/SplashPage.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:oktoast/oktoast.dart';
import 'package:redux/redux.dart';
import 'package:screen/screen.dart';

import 'common/config/config.dart';
import 'models/Application.dart';
import 'models/user.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runZoned(() async {
      runApp(MyApp());
      await Log.init(isDebug: Config.DEBUG);
      if (Platform.isAndroid) {
        SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
        SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      }
      Screen.keepOn(true);
    }, onError: (Object obj, StackTrace stack) {
      Log.e(obj, tag: "main");
      Log.e(stack, tag: "main");
    });
  });
}

class MyApp extends StatelessWidget {
  final store = new Store<GSYState>(appReducer,
      middleware: middleware,

      ///初始化数据
      initialState: new GSYState(
        userInfo: User(),
        application: Application.initial(),
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
                builder: (context, widget) {
                  return MediaQuery(
                    //设置文字大小不随系统设置改变
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: widget,
                  );
                },
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                locale: Config.LANGUAGE,
                supportedLocales: [Config.LANGUAGE],
                title: Config.TITLE,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(primaryColor: Colors.lightBlueAccent),
                home: SplashPage(),
              ));
        },
      ),
    );
  }
}
