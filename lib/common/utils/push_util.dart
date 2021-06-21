import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:flutter_start/models/user.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tpns_flutter_plugin/android/xg_android_api.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';
import 'package:uni_links/uni_links.dart';
import 'CommonUtils.dart';

class PushUtil {
  PushUtil._internal();
  static PushUtil instance = PushUtil._internal();
  XgAndroidApi get api => XgFlutterPlugin.xgApi;
  factory PushUtil() => instance;
  XgFlutterPlugin xgFlutterPlugin = XgFlutterPlugin();
  StreamSubscription _sub;
  bool isRegistered = false;
  Map param;
  Function(Map<String, dynamic> param) _clickAction;
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    /// 开启DEBUG
    xgFlutterPlugin.setEnableDebug(true);

    /// 添加回调事件
    xgFlutterPlugin.addEventHandler(
      onRegisteredDeviceToken: (String msg) async {
        print("flutter onRegisteredDeviceToken: $msg");
      },
      onRegisteredDone: (String msg) async {
        Log.i("flutter onRegisteredDone: $msg", tag: "PushUtil");
        isRegistered = true;
        // _showAlert("注册成功");
      },
      unRegistered: (String msg) async {
        print("flutter unRegistered: $msg");
        // _showAlert(msg);
      },
      onReceiveNotificationResponse: (Map<String, dynamic> msg) async {
        print("flutter onReceiveNotificationResponse $msg");
      },
      onReceiveMessage: (Map<String, dynamic> msg) async {
        print("flutter onReceiveMessage $msg");
      },
      xgPushDidSetBadge: (String msg) async {
        print("flutter xgPushDidSetBadge: $msg");

        /// 在此可设置应用角标
        /// XgFlutterPlugin().setAppBadge(0);
        // _showAlert(msg);
      },
      xgPushDidBindWithIdentifier: (String msg) async {
        print("flutter xgPushDidBindWithIdentifier: $msg");
        // _showAlert(msg);
      },
      xgPushDidUnbindWithIdentifier: (String msg) async {
        print("flutter xgPushDidUnbindWithIdentifier: $msg");
        // _showAlert(msg);
      },
      xgPushDidUpdatedBindedIdentifier: (String msg) async {
        print("flutter xgPushDidUpdatedBindedIdentifier: $msg");
        // _showAlert(msg);
      },
      xgPushDidClearAllIdentifiers: (String msg) async {
        print("flutter xgPushDidClearAllIdentifiers: $msg");
        // _showAlert(msg);
      },
      xgPushClickAction: (Map<String, dynamic> msg) async {
        print("flutter xgPushClickAction 111 $msg");
        // _showAlert("flutter xgPushClickAction $msg");
        param = _getParam(msg["activityName"]);
        if (param.length == 0) {
          param = msg["customMessage"] ?? {};
        }
        print("flutter xgPushClickAction param $param");
        _clickAction?.call(param);
      },
    );

    /// 如果您的应用非广州集群则需要在startXG之前调用此函数
    /// 香港：tpns.hk.tencent.com
    /// 新加坡：tpns.sgp.tencent.com
    /// 上海：tpns.sh.tencent.com
    // XgFlutterPlugin().configureClusterDomainName("tpns.hk.tencent.com");

    /// 开启厂商推送
    if (Platform.isAndroid) {
      // 设置小米 AppID 和 AppKey。
      api.setMiPushAppId(appId: "2882303761517564639");
      api.setMiPushAppKey(appKey: "5561756412639");
    }
    api.enableOtherPush();
    api.regPush();

    if (Platform.isIOS) {
      xgFlutterPlugin.startXg("1600019943", "IU5KVCRKMH1M");
    } else {
      xgFlutterPlugin.startXg("1500019944", "AYNOFZQ80TLB");
    }
  }

  registerAction(Function(Map<String, dynamic> param) action) {
    this._clickAction = action;
  }

  disposeAction(Function(Map<String, dynamic> param) action) {
    this._clickAction = null;
  }

  void setAccount({String account, String uid}) {
    xgFlutterPlugin.setAccount(account, AccountType.UNKNOWN);
    xgFlutterPlugin.setAccount(uid, AccountType.CUSTOM);
  }

  void setUserParam({User user}) {
    Map param = {"school": user.schoolId, "grade": user.grade, "classId": user.classId};
    List<String> tags = [];
    param.forEach((key, value) {
      tags.add("$key:$value");
    });
    xgFlutterPlugin.addTags(tags);
  }

  void _showAlert(String title) {
    showToast(title);
    // Alert(context: context, title: title, buttons: [
    //   DialogButton(
    //     onPressed: () {
    //       Navigator.pop(context);
    //     },
    //     child: Text(
    //       "确认",
    //       style: TextStyle(color: Colors.white, fontSize: 20),
    //     ),
    //   )
    // ]).show();
  }

  Future<void> initPlatformStateForStringUniLinks() async {
    String initialLink;
    // App未打开的状态在这个地方捕获scheme
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
      if (initialLink != null) {
        print('initialLink--$initialLink');
      }
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
    }
    // App打开的状态监听scheme
    _sub = getLinksStream().listen((String link) {
      print('link--$link');
    }, onError: (Object err) {
      print('link--err--$err');
    });
  }

  _getParam(String schemeUrl) {
    final _jumpUri = Uri.parse(schemeUrl.replaceFirst(
      'yondorstudent://',
      'http://path/',
    ));
    switch (_jumpUri.path) {
      case '/detail':
        return _jumpUri.queryParameters;
        break;
      default:
        break;
    }
  }
}
