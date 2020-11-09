import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:flutter_start/widget/IndexNoticeWidget.dart';
import 'package:flutter_start/widget/ProtocolDialog.dart';
import 'package:flutter_start/widget/VideoWidget.dart';
import 'package:flutter_start/widget/update_version.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'NavigatorUtil.dart';

class CommonUtils {
  static Future<Null> showLoadingDialog(BuildContext context, {String text = "Loading···", Widget widget}) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
                onWillPop: () => new Future.value(false),
                child: Center(
                  child: new Container(
                    width: 200.0,
                    height: 200.0,
                    padding: new EdgeInsets.all(4.0),
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      //用一个BoxDecoration装饰器提供背景图片
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(child: widget ?? SpinKitRing(color: Color(0xFFFFFFFF))),
                        new Container(height: 10.0),
                        new Container(
                            child: new Text(text,
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 18.0,
                                ))),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  static Future<dynamic> showEditDialog(BuildContext context, Widget widget, {double width, double height}) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
//                onWillPop: () => new Future.value(false),
                child: Center(
                  child: Stack(
                    alignment: const FractionalOffset(0.98, 0),
                    children: <Widget>[
                      new Container(
                        width: width ?? ScreenUtil.getInstance().getWidthPx(908),
                        height: height ?? ScreenUtil.getInstance().getHeightPx(807),
                        padding: new EdgeInsets.all(4.0),
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          //用一个BoxDecoration装饰器提供背景图片
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: new GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          child: widget,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          icon: Icon(
                            Icons.close,
                            size: 30,
                            color: const Color(0xFF666666),
                          )),
                    ],
                  ),
                ),
              ));
        });
  }

  ///构建按钮
  static Widget buildBtn(String text,
      {double width, double height, GestureTapCallback onTap, Color splashColor, Color decorationColor, Color textColor, double textSize, double elevation}) {
    return Material(
      //带给我们Material的美丽风格美滋滋。你也多看看这个布局
      elevation: elevation ?? 1,
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        onTap: onTap,
        //来个飞溅美滋滋。
        splashColor: splashColor ?? Colors.amber,
        child: Ink(
          width: width,
          height: height ?? ScreenUtil.getInstance().getHeightPx(133),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            color: decorationColor ?? Color(0xFFfbd951),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColor ?? const Color(0xFFa83530), fontWeight: FontWeight.normal, fontSize: textSize ?? ScreenUtil.getInstance().getSp(18)),
            ),
          ),
        ),
      ),
    );
  }

  static Future<dynamic> showGuide(BuildContext context, Widget widget, {double width, double height}) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: new Material(color: Colors.black12, child: widget),
          );
        });
  }

  ///版本更新
  static Future<Null> showUpdateDialog(BuildContext context, AppVersionInfo versionInfo, {int mustUpdate = 0}) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => new Future.value(mustUpdate == 1 ? false : true),
            child: UpdateVersionDialog(data: versionInfo, mustUpdate: mustUpdate),
          );
        });
  }

  ///版本更新
  static Future<Null> showProtocolDialog(BuildContext context) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => new Future.value(false),
            child: ProtocolDialog(),
          );
        });
  }

  ///APP公告
  static Future<dynamic> showAPPNotice(BuildContext context, notice, message) {
    print(notice);
    print(message);
    return NavigatorUtil.showGSYDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            child: IndexNoticeWidget(data: notice, message: message),
          );
        });
  }

  ///视频播放
  static Future<dynamic> showVideo(BuildContext context, String url) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        builder: (BuildContext context) {
          return VideoWidget(url);
        });
  }

  ///对比版本号
  static int compareVersion(String localVersion, String serverVersion) {
    if (localVersion == serverVersion) {
      return 0;
    }
    List<String> version1Array = localVersion.split(".");
    List<String> version2Array = serverVersion.split(".");
    int index = 0;
    // 获取最小长度值
    int minLen = min(version1Array.length, version2Array.length);
    int diff = 0;
    // 循环判断每位的大小
    while (index < minLen && (diff = int.parse(version1Array[index]) - int.parse(version2Array[index])) == 0) {
      index++;
    }
    if (diff == 0) {
      // 如果位数不一致，比较多余位数
      for (int i = index; i < version1Array.length; i++) {
        if (int.parse(version1Array[i]) > 0) {
          return 1;
        }
      }

      for (int i = index; i < version2Array.length; i++) {
        if (int.parse(version2Array[i]) > 0) {
          return -1;
        }
      }
      return 0;
    } else {
      return diff > 0 ? 1 : -1;
    }
  }

  static bool ios13() {
    var i = compareVersion(DeviceInfo.instance.osVersion, "13.0");
    print("ios13  $i  osVersion ${DeviceInfo.instance.osVersion}");
    if (i == -1) {
      return false;
    }
    return true;
  }

  static Future openStudentApp() async {
    print("打開 學生端");
    if (await canLaunch(Config.STUDENT_SCHEME)) {
      await launch(Config.STUDENT_SCHEME, forceSafariVC: false, forceWebView: false);
    } else {
      if (Platform.isIOS) {
        await launch(Config.STUDENT_IOS_URL, forceSafariVC: false, forceWebView: false);
      } else if (Platform.isAndroid) {
        var deviceInfo = await DeviceInfo.instance.getDeviceInfo();
        var url = Config.STUDENT_TEN_URL;
        if (null != deviceInfo["manufacturer"] && deviceInfo["manufacturer"] is String && "" != deviceInfo["manufacturer"]) {
          String s = deviceInfo["manufacturer"];
          if (s.toUpperCase().indexOf("HUAWEI") != -1) {
            url = Config.STUDENT_HUAWEI_URL;
          }
        }
        await launch(url, forceSafariVC: false, forceWebView: false);
      }
    }
  }

  static urlJoinUser(String url, {String router = ""}) async {
    if (url.indexOf("#") != -1 && router == "") {
      var split = url.split("#/");
      if (split.length > 1) {
        url = split[0];
        router = split[1];
      }
    }
    String key = await httpManager.getAuthorization();
    print("@key:  $key ");
    String from = "study_parent";
    String toFrom = "study_parent_router";
    var version = (await PackageInfo.fromPlatform()).version;
    var deviceId = await DeviceInfo.instance.getYondorDeviceId();
    if (null != key && "" != key) {
      String param = "t=${DateTime.now().millisecondsSinceEpoch}&key=$key&from=$from&curVersion=$version&deviceId=$deviceId";
      if (url.contains("?")) {
        url = "$url&$param";
      } else {
        url = "$url?$param";
      }
    } else {
      String param = "t=${DateTime.now().millisecondsSinceEpoch}&from=$from&curVersion=$version&deviceId=$deviceId";
      if (url.contains("?")) {
        url = "$url&$param";
      } else {
        url = "$url?$param";
      }
    }
    if (router != "") {
      url += "&toFrom=$toFrom#/" + router;
    }
    return url;
  }

  static getHeaderImg(imgUrl, {width, height}) {
    if (imgUrl != null && imgUrl != "") {
      return CachedNetworkImage(
        imageUrl: imgUrl.toString().replaceAll("fs.k12china-local.com", "192.168.6.30:30781"),
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorWidget: (BuildContext context, String url, dynamic error) {
          return Image(
            image: AssetImage("images/admin/tx.png"),
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
        },
      );
    } else {
      return Image(
        image: AssetImage("images/admin/tx.png"),
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    }
  }
}
