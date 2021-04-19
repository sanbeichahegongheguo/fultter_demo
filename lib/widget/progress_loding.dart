import 'dart:async';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:orientation/orientation.dart';
import 'package:provider/provider.dart';

class ProgressLoading extends StatefulWidget {
  final Function delFunc;

  const ProgressLoading({Key key, this.delFunc}) : super(key: key);
  @override
  _ProgressLoadingState createState() => _ProgressLoadingState();
}

class _ProgressLoadingState extends State<ProgressLoading> {
  Completer<int> completer = Completer<int>();
  Timer timer;
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      OrientationPlugin.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    }
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight).then((value) => completer.complete(1));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(builder: (context, model, child) {
      if (timer == null) {
        timer = new Timer.periodic(Duration(seconds: 1), (timer) {
          model.timer();
        });
      }
      return Material(
          color: Colors.white,
          child: WillPopScope(
            onWillPop: () => new Future.value(false),
            child: FutureBuilder(
              future: completer.future,
              builder: (BuildContext context, AsyncSnapshot<int> snap) {
                Size size = MediaQuery.of(context).size;
                return Stack(
                  children: [
                    SizedBox.expand(
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height / 3,
                          ),
                          Center(
                            child: new Container(
                              width: 500,
                              height: 100.0,
                              padding: new EdgeInsets.all(4.0),
                              decoration: new BoxDecoration(
                                color: Colors.transparent,
                                //用一个BoxDecoration装饰器提供背景图片
                                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              ),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  height: 75.0,
                                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                                  child: LiquidLinearProgressIndicator(
                                    value: model.percentage / 100,
                                    backgroundColor: Color(0xffE6E6E6),
                                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                                    borderRadius: 12.0,
                                    center: Text(
                                      model.percentage >= 100
                                          ? "正在加入房间"
                                          : model.percentage == 0
                                              ? "正在加载"
                                              : "${model.percentage.toStringAsFixed(0)}%",
                                      style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (model.isError)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "课件加载失败，请检查网络重新下载 ",
                                  style: TextStyle(
                                    color: Color(0xFFF6BFBF),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                CommonUtils.buildBtn('重新下载',
                                    width: 200,
                                    height: 50,
                                    decorationColor: Color(0xFF3568DF),
                                    splashColor: Color(0xFF3568DF),
                                    textColor: Colors.white,
                                    textSize: ScreenUtil.getInstance().getSp(30 / 3),
                                    elevation: 2, onTap: () {
                                  model.reLoad();
                                  model.loadCoursePack?.call(false);
                                })
                              ],
                            )
                        ],
                      ),
                    ),
                    Positioned(
                        top: 5,
                        right: 20,
                        child: IconButton(
                            onPressed: () {
                              _back();
                              widget.delFunc?.call();
                            },
                            icon: Icon(
                              Icons.cancel_outlined,
                              size: 45,
                              color: const Color(0xFFF6BFBF),
                            )))
                  ],
                );
              },
            ),
          ));
    });
  }

  _back() {
    if (Platform.isIOS) {
      OrientationPlugin.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    Future.delayed(Duration(milliseconds: 500), () async {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }
}
