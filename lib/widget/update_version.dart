import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/channel/Download.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateVersionDialog extends StatefulWidget {
  final AppVersionInfo data;
  final int mustUpdate;
  UpdateVersionDialog({Key key, this.data, this.mustUpdate = 0}) : super(key: key);

  @override
  _UpdateVersionDialogState createState() => _UpdateVersionDialogState();
}

class _UpdateVersionDialogState extends State<UpdateVersionDialog> {
  // 进度订阅
  StreamSubscription downloadSubscription;

  int percent = 0;

  _updateButtonTap(BuildContext context) async {
    if (Platform.isIOS) {
      final url = Config.iosUrl;
      if (await canLaunch(url)) {
        await launch(url, forceSafariVC: false, forceWebView: false);
      } else {
        throw 'Could not launch $url';
      }
    } else if (Platform.isAndroid) {
      androidDownloadHandle();
    }
  }

  // android 下载
  androidDownloadHandle() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
//    print(statuses[Permission.storage].isGranted);
//    print(statuses);
    if (statuses[Permission.storage].isGranted) {
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
                  openAppSettings();
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
      downloadSubscription = Download.startDownload(widget.data.maxUrl, downloadSubscription: downloadSubscription, updateDownload: _updateDownload);
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
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
                    style: TextStyle(color: Color(0xff3782e5), fontWeight: FontWeight.w500),
                  ),
                ),
                widget.data.content != null
                    ? ConstrainedBox(
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
                      )
                    : Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(33, 0, 33, 0),
                  child: Container(
                    height: 1.0 / MediaQueryData.fromWindow(window).devicePixelRatio,
                    color: Color(0xffC0C0C0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                  ),
                ),
                Platform.isAndroid
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: SizedBox(
                          height: 40,
                          width: 170,
                          child: FlatButton(
                              textColor: Colors.black26,
                              child: Text(
                                "手动升级",
                              ),
                              highlightColor: Colors.transparent,
                              color: Colors.transparent,
                              onPressed: _goTen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                        ),
                      )
                    : Container(),
              ])),
          widget.mustUpdate == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    child: IconButton(
                      icon: Image.asset(
                        "images/btn-close.png",
                        fit: BoxFit.cover,
                        width: ScreenUtil.getInstance().getWidthPx(100),
                      ),
                      color: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
              : Container()
        ]));
  }

  _getButtonText() {
    if (percent >= 100) {
      return "正在升级";
    }
    if (percent > 0) {
      return "升级中$percent%";
    }
    return Platform.isAndroid ? "自动升级" : "立即升级";
  }

  _goTen() async {
    if (await canLaunch(Config.tenUrl)) {
      await launch(Config.tenUrl, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $Config.tenUrl';
    }
  }
}
