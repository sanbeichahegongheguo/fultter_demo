import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';



class UpdateVersionDialog extends StatefulWidget {
  final AppVersionInfo data;
  final int mustUpdate;
  UpdateVersionDialog({Key key, this.data,this.mustUpdate=0}):super(key: key);

  @override
  _UpdateVersionDialogState createState() => _UpdateVersionDialogState();
}

class _UpdateVersionDialogState extends State<UpdateVersionDialog> {
  static const channelName = 'plugins.iwubida.com/update_version';
  static const stream = const EventChannel(channelName);
  static const tenUrl = "https://android.myapp.com/myapp/detail.htm?apkName=com.yondor.student";
  static const iosUrl = "https://apps.apple.com/cn/app/id1155973972";
  // 进度订阅
  StreamSubscription downloadSubscription;

  int percent = 0;

  _updateButtonTap(BuildContext context) async {
    if (Platform.isIOS) {
      final url = iosUrl;
      if (await canLaunch(url)) {
        await launch(tenUrl, forceSafariVC: false, forceWebView: false);
      } else {
        throw 'Could not launch $url';
      }
    } else if (Platform.isAndroid) {
      androidDownloadHandle();
    }
  }

  // android 下载
  androidDownloadHandle() async {
    // 权限检查
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    print(permissions);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      // 开始下载
      _startDownload();
    } else {
      showSettingDialog();
    }
  }

  // 打开应用设置
  showSettingDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("需要打开存储权限"),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("取消"),
              ),
              new FlatButton(
                onPressed: () {
                  PermissionHandler().openAppSettings();
                  Navigator.of(context).pop();
                },
                child: new Text("确认"),
              ),
            ],
          );
        });
  }

  // 开始下载
  void _startDownload() {
    if (downloadSubscription == null) {
      downloadSubscription = stream
          .receiveBroadcastStream(widget.data.maxUrl)
          .listen(_updateDownload);
    }
  }

  // 停止监听进度
  void _stopDownload() {
    if (downloadSubscription != null) {
      downloadSubscription.cancel();
      downloadSubscription = null;
      percent = 0;
    }
  }

  // 进度下载
  void _updateDownload(data) {
    int progress = data["percent"];
    print(progress);
    if (progress != null) {
      setState(() {
        percent = progress;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopDownload();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var _maxContentHeight = min(screenSize.height - 300, 180.0);

    return Material(
        type: MaterialType.transparency,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: screenSize.height > screenSize.width ? 265 : 370,
                  decoration: ShapeDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      )),
                  child: Column(children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6.0),
                          topRight: Radius.circular(6.0),
                        ),
                        child: Image.asset(
                          "images/update/ic_update_bg.png",
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                        child: Center(
                            child: new Text('升级到新版本',
                                style: new TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500,
                                )))),
                    Container(
                      child: Text(
                        widget.data.maxVersion,
                        style: TextStyle(
                            color: Color(0xff3782e5),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: _maxContentHeight),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.data.content,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(33, 0, 33, 0),
                      child: Container(
                        height: 1.0 /
                            MediaQueryData.fromWindow(window).devicePixelRatio,
                        color: Color(0xffC0C0C0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: 170,
                        height: 40,
                        child: RaisedButton(
                            child: Text(
                              _getButtonText(),
                              style: TextStyle(color: Color(0xdfffffff)),
                            ),
                            color: const Color(0xff5f9afa),
                            onPressed: () {
                              _updateButtonTap(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0))),
                      ),
                    ),
                    Platform.isAndroid?Padding(
                      padding: widget.mustUpdate==0?EdgeInsets.only(top: 10):EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: SizedBox(
                        width: 170,
                        height: 40,
                        child: RaisedButton(
                            child: Text(
                              "应用宝下载",
                              style: TextStyle(color: Color(0xdfffffff)),
                            ),
                            color: const Color(0xff5f9afa),
                            onPressed:_goTen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0))),
                      ),
                    ):Container(),
                    widget.mustUpdate==0?Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                        child: SizedBox(
                          height: 30,
                          child: FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              textColor: Colors.black26,
                              color: Colors.transparent,
                              highlightColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Text(
                                "暂不升级",
                                style: TextStyle(fontSize: 13),
                              )),
                        )):Container()
                  ]))
            ]));
  }

  _getButtonText() {
    if (percent >= 100) {
      return "正在升级";
    }
    if (percent > 0) {
      return "升级中$percent%";
    }
    return "立即升级";
  }
  _goTen() async {
    if (await canLaunch(tenUrl)) {
      await launch(tenUrl, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $tenUrl';
    }
  }
}
