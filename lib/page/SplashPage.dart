import 'dart:async';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/event/http_error_event.dart';
import 'package:flutter_start/common/event/index.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/redux/application_redux.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';
import 'package:webview_flutter/X5Sdk.dart';

import 'HomePage.dart';
import 'PhoneLoginPage.dart';

///过度页面
class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {
  bool hadInit = false;
  int _status = 0;
  int next = 0;
  StreamSubscription _stream;
  MethodChannel _methodChannel;
  String _adStatus = "";
  String _showAdKey = "SHOW_AD";
  //默认启动延迟
  int _milliseconds = 800;
  Widget _ad = Container();
  @override
  void initState() {
    super.initState();
    if (hadInit) {
      return;
    }
    hadInit = true;
    _initProtocol();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _stream?.cancel();
    _stream = null;
  }

  void _initAsync() async {
    if (Platform.isAndroid) {
      X5Sdk.init().then((isOK) {
        print(isOK ? "X5内核成功加载" : "X5内核加载失败");
      });
    }
    await SpUtil.getInstance();
    SpUtil.remove(Config.EVENT_287);
    Store<GSYState> store = StoreProvider.of(context);
    PackageInfo.fromPlatform().then((v) {
      store.dispatch(RefreshApplicationAction(store.state.application.copyWith(version: v.version)));
      ApplicationDao.getAppApplication().then((res) {
        if (res != null && res.result) {
          var data = res.data;
          SpUtil.putBool(_showAdKey, (data != null && data["showSplash"] != null && data["showSplash"] is num && data["showSplash"] == 1 && data["showBanner"] == 1));
          store.dispatch(RefreshApplicationAction(store.state.application.copyWith(
              showBanner: data["showBanner"],
              showCoachBanner: data["showCoachBanner"],
              showRewardBanner: data["showRewardBanner"],
              showH5Banner: data["showH5Banner"],
              minAndroidVersion: data["minAndroidVersion"],
              minIosVersion: data["minIosVersion"],
              webViewOpenType: data["openType"],
              detectxySave: data["detectxySave"])));
        }
      });
    });
    if (SpUtil.getBool(_showAdKey)) {
      if (Platform.isAndroid) {
        _milliseconds = 2000;
      }
      setState(() {
        _ad = Platform.isAndroid
            ? AndroidView(
                viewType: "splash",
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  _methodChannel = MethodChannel("splash_$id");
                  _methodChannel.setMethodCallHandler(call);
                })
            : UiKitView(
                viewType: "splash",
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  _methodChannel = MethodChannel("splash_$id");
                  _methodChannel.setMethodCallHandler(call);
                });
      });
    }
    //登录
    UserDao.getUser(store: store).then((res) {
      if (res != null) {
        store.dispatch(UpdateUserAction(res));
        next = 1;
      }
      Future.delayed(Duration(milliseconds: _milliseconds), () async {
        _next();
      });
    });
  }

  Future<void> _initProtocol() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SpUtil.getInstance();
      await AddressUtil.getInstance().init();

      if (SpUtil.getBool(Config.EVENT_PROTOCOL)) {
        _initListener();
        _initAsync();
        _initPermission();
        return;
      }

      CommonUtils.showProtocolDialog(context).then((data) {
        SpUtil.putBool(Config.EVENT_PROTOCOL, true);
        _initListener();
        _initAsync();
        _initPermission();
      });
    });
  }

  _next() {
    if (_adStatus != "show" || Platform.isIOS) {
      if (next == 1) {
        //家长启动事件
        ApplicationDao.trafficStatistic(287);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => PhoneLoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder<GSYState>(builder: (context, store) {
      return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Material(
            child: Stack(
              children: <Widget>[
                Offstage(
                  offstage: !(_status == 0),
                  child: _buildSplashBg(),
                ),
                Offstage(
                  offstage: !(_status == 1),
                  child: _ad,
                ),
              ],
            ),
          ));
    });
  }

  Future<bool> call(MethodCall call) async {
    print(call.method);
    await SpUtil.getInstance();
    if (SpUtil.getBool(_showAdKey) || _status == 1) {
      _adStatus = call.method;
      switch (call.method) {
        case "show":
          if (Platform.isAndroid) {
            setState(() {
              _status = 1;
            });
          }
          break;
        case "error":
          _next();
          break;
        case "close":
          _next();
          break;
      }
    }
    return null;
  }

  ///背景图
  Widget _buildSplashBg() {
    return Container(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          child: Flex(direction: Axis.vertical, children: <Widget>[
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(269),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(70),
            ),
            Container(
              child: Image.asset(
                "images/phone_login/center.png",
//                width: ScreenUtil.getInstance().getWidthPx(542),
                height: ScreenUtil.getInstance().getHeightPx(447),
              ),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(100),
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(bottom: ScreenUtil.getInstance().getHeightPx(55)),
                  alignment: AlignmentDirectional.bottomCenter,
                  // ignore: static_access_to_instance_member
                  child: Flex(direction: Axis.vertical, mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/phone_login/bottom.png",
                          fit: BoxFit.scaleDown,
                          height: ScreenUtil.getInstance().getHeightPx(77),
                          width: ScreenUtil.getInstance().getWidthPx(77),
                        ),
                        Text("  远大小状元家长", style: TextStyle(color: Colors.black, fontSize: ScreenUtil.getInstance().getSp(14)))
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text("Copyright © Yondor.All Rights Reserved.", style: TextStyle(color: Color(0xFF666666), fontSize: ScreenUtil.getInstance().getSp(11)))],
                    )
                  ])),
              flex: 2,
            ),
          ]),
        ),
      ),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: const FractionalOffset(0.5, 0.0),
          end: const FractionalOffset(0.5, 1.0),
          colors: <Color>[Color(0xFFcdfdd3), Color(0xFFe2fff0)],
        ),
      ),
    );
  }

  Future _initPermission() async {
    try {
      List<PermissionGroup> permissionsList = new List();
      if (Platform.isAndroid) {
        PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
        if (permission != PermissionStatus.granted) {
          permissionsList.add(PermissionGroup.location);
        }
        permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
        if (permission != PermissionStatus.granted) {
          permissionsList.add(PermissionGroup.phone);
        }
        permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
        if (permission != PermissionStatus.granted) {
          permissionsList.add(PermissionGroup.storage);
        }
      }
      if (permissionsList.length > 0) {
        Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions(permissionsList);
        if (permissions[PermissionGroup.phone] != null && permissions[PermissionGroup.phone] != PermissionStatus.granted) {
          showToast("请开启手机权限", position: ToastPosition.bottom);
        }
        if (permissions[PermissionGroup.storage] != null && permissions[PermissionGroup.storage] != PermissionStatus.granted) {
          showToast("请开启存储权限", position: ToastPosition.bottom);
        }
        if (permissions[PermissionGroup.location] != null && permissions[PermissionGroup.location] != PermissionStatus.granted) {
//        showToast("请开启位置权限", position: ToastPosition.bottom);
        }
      }
    } catch (err) {
      print("_initPermission $err");
    }
    ApplicationDao.sendDeviceInfo();
  }

  void _initListener() {
    _stream = eventBus.on<HttpErrorEvent>().listen((event) {
      print("SplashPageState eventBus " + event.toString());
      HttpErrorEvent.errorHandleFunction(event.code, event.message, context);
    });
  }
}
