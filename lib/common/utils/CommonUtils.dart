import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:flutter_start/widget/update_version.dart';
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
  static Widget buildBtn(String text, {double width, double height, GestureTapCallback onTap, Color splashColor, Color decorationColor, Color textColor, double textSize, double elevation}) {
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
              style: TextStyle(color: textColor ?? const Color(0xFFa83530), fontWeight: FontWeight.normal, fontSize: textSize ?? ScreenUtil.getInstance().getSp(18)),
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
          return new Material(
              color: Colors.transparent,
              child: widget
          );
        });
  }
  ///腾讯banner
  static Widget buildBanner(Map<String,MethodChannel> map,String page){
    return Container(
      color: Colors.transparent,
      child: AndroidView(
        viewType: "banner",
        creationParams: {"appId":Config.ANDROID_AD_APP_ID,"bannerId":Config.ANDROID_BANNER_ID},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated:(id){
          if (map !=null){
            print("id  $page");
            map[page] = MethodChannel("banner_$id");
          }
        }
      ),
    );
  }

  ///创建后台banner
  static Widget buildMyBanner(context,ad){
   return GestureDetector(
      child: CachedNetworkImage(
        width: ScreenUtil.getInstance().screenWidth,
        imageUrl:ad.picUrl,
        fit: BoxFit.fill,
      ),
      onTap: (){
        NavigatorUtil.goAdWebView(context, ad);
      },
    );
  }

  ///版本更新
  static Future<Null> showUpdateDialog(BuildContext context,AppVersionInfo versionInfo,{int mustUpdate = 0}) {
    return NavigatorUtil.showGSYDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () => new Future.value(mustUpdate == 1 ? false:true),
            child: UpdateVersionDialog(data: versionInfo,mustUpdate: mustUpdate),
          );
        });
  }





}
