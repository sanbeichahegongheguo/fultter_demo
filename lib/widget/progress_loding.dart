import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:orientation/orientation.dart';
import 'package:provider/provider.dart';

class ProgressLoading extends StatefulWidget {
  @override
  _ProgressLoadingState createState() => _ProgressLoadingState();
}

class _ProgressLoadingState extends State<ProgressLoading> {
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      OrientationPlugin.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    }
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(builder: (context, model, child) {
      return Material(
          color: Colors.white,
          child: WillPopScope(
            onWillPop: () => new Future.value(false),
            child: Center(
              child: new Container(
                width: 400,
                height: 200.0,
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
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      borderRadius: 12.0,
                      center: Text(
                        model.percentage >= 100 ? "正在加入房间" : model.percentage == 0 ? "" : "${model.percentage.toStringAsFixed(0)}%",
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
          ));
    });
  }
}
