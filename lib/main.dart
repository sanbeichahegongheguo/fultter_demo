import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/page/SplashPage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:redux/redux.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/config/config.dart';
import 'models/Application.dart';
import 'models/user.dart';

main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
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
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                locale: Config.LANGUAGE,
                supportedLocales:[Config.LANGUAGE],
                title:Config.TITLE,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(primaryColor: Colors.lightBlueAccent),
                home: SplashPage(),
              ));
        },
      ),
    );
  }

}
