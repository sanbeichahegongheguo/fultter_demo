import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/common/channel/Download.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/models/Adver.dart';
import 'package:url_launcher/url_launcher.dart';

import 'NavigatorUtil.dart';

class BannerUtil{

  static const int BANNER_CLICK_ADVERT = 1; //点击banner广告
  static const int BANNER_SKIP_ADVERT = 2;//关闭banner广告
  static const int BANNER_SHOWNED_ADVERT = 3; //曝光

  //发送广告事件
  static Future sendData(Adver data,int type,{context}) async {
    var advertObj;
    switch (type){
      case BANNER_CLICK_ADVERT:
        //点击banner广告
        advertObj="{'advert_id':"+data.advertId.toString()+",'advert_name':'banner','type': 'click'}";
        if(data !=null &&data.isHttp =="T"){
          //打开外链地址 ,需要在webView后前往家长专区
          NavigatorUtil.goAdWebView(context, data);
        }else if(data !=null &&data.isdownload =="T"){
          //下载
          if (Platform.isAndroid){
            Download.startDownload(data.target);
          }else{
            final url = "https://apps.apple.com/cn/app/id${data.appid}";
            if (await canLaunch(url)) {
            await launch(url, forceSafariVC: false, forceWebView: false);
            } else {
            throw 'Could not launch $url';
            }
          }
        }
        break;
      case BANNER_SKIP_ADVERT:
      //关闭banner广告
        advertObj="{'advert_id':"+data.advertId.toString()+",'advert_name':'banner','type': 'skip'}";
        break;
      case BANNER_SHOWNED_ADVERT:
        advertObj="{'advert_id':"+data.advertId.toString()+",'advert_name':'banner','type': 'none'}";
        break;
      //曝光
    }
    if (advertObj!=null){
      ApplicationDao.sendObjTotal(advertObj);
    }
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
        sendData(ad,BANNER_CLICK_ADVERT,context:context);
      },
    );
  }

  ///腾讯banner
  static Widget buildBanner(Map<String,MethodChannel> map,String page,{bloc}){
    print("banner  buildBanner");
    return Platform.isIOS?UiKitView(
          viewType: "banner",
          creationParams: <String, dynamic>{"appId": Config.IOS_AD_APP_ID, "bannerId": Config.IOS_BANNER_ID},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated:(id){
            if (map !=null){
              print("id  $page  $id");
              map[page] = MethodChannel("banner_$id");
              if (bloc!=null){
                closeBannerMethod(map[page],bloc);
              }
            }else if (bloc !=null){
              closeBannerMethod(MethodChannel("banner_$id"),bloc);
            }
          }
      ):AndroidView(
          viewType: "banner",
          creationParams: {"appId":Config.ANDROID_AD_APP_ID,"bannerId":Config.ANDROID_BANNER_ID,"page":page},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated:(id){
            if (map !=null){
              print("id  $page");
              map[page] = MethodChannel("banner_$id");
              if (bloc!=null){
                closeBannerMethod(map[page],bloc);
              }
            }else if (bloc !=null){
              closeBannerMethod(MethodChannel("banner_$id"),bloc);
            }
          }
      );
  }

  static closeBannerMethod(method,bloc){
    method.setMethodCallHandler((MethodCall call){
      if(call.method=="closeBanner"){
        bloc.showBanner(false);
      }
      return null;
     }
    );
  }
}