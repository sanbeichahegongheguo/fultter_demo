import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/channel/YondorChannel.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/widget/ShareToWeChat.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:redux/redux.dart';

///**
/// *WebView
///*/
class WebViewPage extends StatefulWidget {
  final String url;
  final Color color;
  final AppBar appBar;
  WebViewPage(this.url, {this.color,this.appBar});

  @override
  State<StatefulWidget> createState() => new WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> with SingleTickerProviderStateMixin{
  //状态 0加载  1加载完成
  int _status = 0;
  WebViewController _webViewController;
  Size _deviceSize;
  bool _showAd = false;
  Map  _oneUrl = new Map();
  /// 使用javascriptChannels发送消息
  /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toast',
        onMessageReceived: (JavascriptMessage message) {
          showToast(message.message);
        });
  }
  JavascriptChannel _loadAd() {
    return JavascriptChannel(
        name: 'LoadAd',
        onMessageReceived: (JavascriptMessage message) {
          setState((){
            _showAd = true;
          } );
        });
  }

  /// 使用手写功能
  JavascriptChannel _detectxy(BuildContext context) {
    return JavascriptChannel(
        name: 'Detectxy',
        onMessageReceived: (JavascriptMessage message) async {
          var msg = jsonDecode(message.message);
          print(msg["pos"]);
          var result = await YondorChannel.detectxy(msg["pos"], msg["thickness"], msg["isSave"]);
          _webViewController.evaluateJavascript("window.dx('$result')");
        });
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    Store<GSYState> store = StoreProvider.of(context);
    return WillPopScope(
        onWillPop: () async {
          bool can = await _webViewController.canGoBack();
          if (can) {
            _webViewController.evaluateJavascript("window.backFunc()");
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: widget.appBar??null,
          body: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  Container(
                      height: _deviceSize.height,
                      child: WebView(
                        initialMediaPlaybackPolicy:AutoMediaPlaybackPolicy.always_allow,
                        initialUrl: widget.url,
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (WebViewController webViewController) {
                          print("打开Webview!");
                          _webViewController = webViewController;
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        gestureRecognizers: Set()
                          ..add(
                            Factory<VerticalDragGestureRecognizer>(
                                  () => VerticalDragGestureRecognizer(),
                            ),
                          ),
                        javascriptChannels: <JavascriptChannel>[_alertJavascriptChannel(context), _detectxy(context),_loadAd()].toSet(),
                        navigationDelegate: _navigationDelegate,
                        onPageFinished: (String url) {
                          print('@跳转链接: $url');
                            if( _status != 1 ||_showAd != false ){
                              setState((){
                                _status = 1;
                                if(!url.startsWith(widget.url) &&_showAd!=false){
                                  print("false");
                                  _showAd =false;
                                }
                              },
                              );
                            }
                        },
                      )),
                  _getStatusWidget(store)
                ],
              )
        ));
  }
  /*
  * 控制路由跳转
  * @param request.url signed 签到
  * @param request.url infoPage 消息 infoPage:studentApp 打开小状元学生
  * @param request.url open_weixin 打开微信
  * */
  NavigationDecision _navigationDelegate(NavigationRequest request){
    if (request.url.startsWith('haxecallback')) {
      print('@ 回调参数 $request}');
      if(request.url.indexOf("signed")>-1){
        print("签到");
        Navigator.of(context).pop("signed");
      }else if(request.url.indexOf("infoPage")>-1){
        print("消息");
        if(request.url.indexOf("studentApp") > -1){
          NavigatorUtil.goStudentAppPage(context);
        }else{
          Navigator.of(context).pop("infoPage");
        }
      }else if(request.url.indexOf("open_weixin")>-1){
        print("打开微信");
        goLaunch(context,"weixin://");
      }else if(request.url.indexOf("haxecallback:tencentAd")>-1){
        if (request.url != "haxecallback:tencentAd:0"){
          print("tencentAd");
          setState(() =>_showAd = true);
        }else{
          setState(() =>_showAd = false);
        }
      }else if (request.url.indexOf("webOpenCammera")>-1){
        _getImage(0).then((v){
          var data = {"result":"success","path":""};
          if (ObjectUtil.isEmptyString(v)){
            data["result"] = "fail";
          }else{
            data["data"] = v;
          }
          print(jsonEncode(data));
          _webViewController.evaluateJavascript("callPoto("+jsonEncode(data)+")");
        });
      }else if(request.url.indexOf("share")>-1){
        print("分享");
        var _urlMsg = request.url.split(":?")[1];
        _urlMsg = Uri.decodeComponent(_urlMsg);
        var _urlList = jsonDecode(_urlMsg);
        String _imagePath =  _urlList["webPage"];//分享地址
        String _thumbnail = _urlList["thumbnail"];//缩略图
        String _title =  _urlList["title"];
        String _description =  _urlList["description"];
        var _shareToWeChat =  new ShareToWeChat(webPage:_imagePath,thumbnail:_thumbnail,transaction:"",title: _title,description:_description);
        CommonUtils.showGuide(context, _shareToWeChat);
      } else{
        Navigator.of(context).pop();
      }
      //阻止路由替换；
      return NavigationDecision.prevent;
    }else if (request.url.startsWith("weixin://") || request.url.startsWith("alipays://")){
      print("11212");
      goLaunch(context,request.url);
      //阻止路由替换；
      return NavigationDecision.prevent;
    }else{
      //允许路由替换
      print('允许路由替换 $request');
      setState((){
        _showAd = false;
        _status = 0;
      }
      );
      return NavigationDecision.navigate;
    }
  }
  /*
  * 唤醒手机软件
  * @param weixin:// 唤醒微信
  * */
  static goLaunch(BuildContext context,String url) async{
    await launch(url, forceSafariVC: false, forceWebView: false);
//    if(await canLaunch(url)){
//      await launch(url, forceSafariVC: false, forceWebView: false);
//    }else {
//      String msg = "程序";
//      switch(url){
//        case "weixin://":
//          msg = "微信";
//          break;
//      }
//      showToast('$msg打开失败',position:ToastPosition.bottom);
//    }
  }
  ///使用flutter 调用js案例
  Widget jsButton() {
    return FutureBuilder<WebViewController>(builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
      if (controller.hasData) {
        return FloatingActionButton(
          onPressed: () async {
            _webViewController.evaluateJavascript('''
                    inputs = document.querySelectorAll("input[type=text]");
                    inputs.forEach(function(inp) {
                        let finalInput = inp;
                        finalInput.addEventListener("focus", function() {
                            Focus.postMessage('focus');
                            input = finalInput;
                            InputValue.postMessage('');
                       });
                       finalInput.addEventListener("focusout", function() {
                           Focus.postMessage('focusout');
                       });
                  });
            ''');
          },
          child: Text('call JS'),
        );
      }
      return Container();
    });
  }
  Widget _getStatusWidget(store){
    Widget widget ;
    if (_status ==0 ){
      //loading
      widget = Container(
          width: _deviceSize.width,
          height: _deviceSize.height,
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()));
    }else if (_showAd && (store.state.application.showBanner==1&&store.state.application.showH5Banner==1)){
      //广告
      widget = Container(
        height: ScreenUtil.getInstance().screenWidth/6.4,
        width: _deviceSize.width,
        child: CommonUtils.buildBanner(null,null),
      );
    }else{
      widget = Container();
    }
    return widget;
  }


  //调用相机或本机相册
  Future _getImage(type) async {
    File image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera);
    if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
      return "";
    }
    //压缩
    image = await ImageCropper.cropImage(
      maxHeight: 800,
      maxWidth: 800,
      sourcePath: image.path,
      toolbarTitle: "选择图片",
    );

    List<int> bytes = await image.readAsBytes();
    var base64encode = base64Encode(bytes);
    return base64encode;
  }

  @override
  void dispose() {
    // 回收相关资源
    super.dispose();
  }
}


