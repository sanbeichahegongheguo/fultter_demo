import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/WebviewBloc.dart';
import 'package:flutter_start/common/channel/CameraChannel.dart';
import 'package:flutter_start/common/channel/YondorChannel.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/common/utils/BannerUtil.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/common/utils/ShareWx.dart';
import 'package:flutter_start/models/user.dart';
import 'package:flutter_start/widget/ShareToWeChat.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker_saver/image_picker_saver.dart' as picker;
import 'package:oktoast/oktoast.dart';
import 'package:tencent_cos/tencent_cos.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:video_compress/video_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:redux/redux.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:orientation/orientation.dart';

///**
/// *WebView
///*/
class WebViewPage extends StatefulWidget {
  final String url;
  final Color color;
  final AppBar appBar;
  WebViewPage(this.url, {this.color,this.appBar});

  @override
  State<StatefulWidget> createState() => null;
}

//class WebViewPageState extends State<WebViewPage> with SingleTickerProviderStateMixin{
//  //状态 0加载  1加载完成
//  int _status = 0;
//  WebViewController _webViewController;
//  Size _deviceSize;
//  bool _showAd = false;
//  FocusNode _focusNode1 = FocusNode();
//  TextEditingController textController1 = TextEditingController();
//  FocusNode _focusNode2 = FocusNode();
//  TextEditingController textController2 = TextEditingController();
//  WebviewBloc _webviewBloc  =  WebviewBloc();
//  Timer _timer;
//  int _MAX_SIZE = 512000;
//  //旋转方向
//  int orientation;
//  //加载超时时间
//  Duration _timeoutSeconds = const Duration(seconds: 25);
//  @override
//  Widget build(BuildContext context) {
//    _timer = Timer(_timeoutSeconds,_unload);
//    _deviceSize = MediaQuery.of(context).size;
//    Store<GSYState> store = StoreProvider.of(context);
//    return WillPopScope(
//        onWillPop: () async {
//          bool can = await _webViewController.canGoBack();
//          if (can) {
//            _webViewController.evaluateJavascript("window.backFunc()");
//            return Future.value(false);
//          } else {
//            return Future.value(true);
//          }
//        },
//        child: Scaffold(
////          backgroundColor: Colors.transparent,
//          appBar: widget.appBar??null,
//          body: SafeArea(
//            child: Stack(
//              alignment: AlignmentDirectional.bottomCenter,
//              children: <Widget>[
//                Platform.isAndroid?Offstage(
//                  offstage:true,
//                  child:Row(children: <Widget>[
//                    SizedBox(
//                      width:10,
//                      child: TextField(
//                         autofocus: false,
//                        focusNode: _focusNode1,
//                        controller: textController1,
//                        onChanged: (text) {
//                          _webViewController.evaluateJavascript('''
//                             if(current != null){
//                              current.value = '${textController1.text}';
//                              current.selectionStart = ${textController1.selection.start};
//                              current.selectionEnd = ${textController1.selection.end};
//                              current.dispatchEvent(new Event('input'));
//                             }
//                            ''');
//                        },
//                        onSubmitted: (text) {
//                          _webViewController.evaluateJavascript('''
//                            if(current != null)
//                              current.submit();
//                            ''');
//                          _focusNode1.unfocus();
//                        },
//                      ),
//                    ),
//                    SizedBox(
//                      width:10,
//                      child:  TextField(
//                        autofocus: false,
//                        focusNode: _focusNode2,
//                        controller: textController2,
//                        onChanged: (text) {
//                          _webViewController.evaluateJavascript('''
//                                   if(current != null){
//                                    current.value = '${textController2.text}';
//                                    current.selectionStart = ${textController2.selection.start};
//                                    current.selectionEnd = ${textController2.selection.end};
//                                    current.dispatchEvent(new Event('input'));
//                                   }
//                                  ''');
//                        },
//                        onSubmitted: (text) {
//                          _webViewController.evaluateJavascript('''
//                                  if(current != null)
//                                    current.submit();
//                                  ''');
//                          _focusNode2.unfocus();
//                        },
//                      ),
//                    ),
//                  ],
//                  ),
//                ):Container(),
//                Container(
//                    height: _deviceSize.height,
//                    child: WebView(
//                      initialMediaPlaybackPolicy:AutoMediaPlaybackPolicy.always_allow,
//                      initialUrl: widget.url,
//                      javascriptMode: JavascriptMode.unrestricted,
//                      onWebViewCreated: (WebViewController webViewController) {
//                        print("打开Webview!");
//                        _webViewController = webViewController;
//
//                        FocusScope.of(context).requestFocus(new FocusNode());
//                      },
//                      gestureRecognizers: Set()
//                        ..add(
//                          Factory<VerticalDragGestureRecognizer>(
//                                () => VerticalDragGestureRecognizer(),
//                          ),
//                        ),
//                      javascriptChannels: <JavascriptChannel>[_alertJavascriptChannel(context), _detectxy(context,store),_loadAd(),_openStudent(),_openVideo(),_userState(),_saveImage(),_openOther(),_openWebView()].toSet(),
//                      navigationDelegate: _navigationDelegate,
//                      onPageFinished: (String url) {
//                        print('@跳转链接: $url');
//                        print("回调链接: "  + url);
//                        if(url.indexOf(':ROTATE')>-1){
//                          //是否包含横屏，如果包含，则强制横屏
//                          print('包含横屏');
//                          OrientationPlugin.setPreferredOrientations([DeviceOrientation.landscapeRight]);
//                          OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
//                          orientation = 1;
//                        }else{
//                          print('返回横屏');
//                          //当前的旋转状态是横屏才进行矫正
//                          if(orientation == 1){
//                            OrientationPlugin.setPreferredOrientations([DeviceOrientation.portraitUp]);
//                            OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
//                          }
//                        }
//                        if( _status != 1 ||_showAd != false ){
//                          setState((){
//                            _timer?.cancel();
//                            _status = 1;
//                            if(!url.startsWith(widget.url) &&_showAd!=false){
//                              print("false");
//                              _showAd =false;
//                            }
//                          },
//                          );
//                        }
//                        _input();
//                        _hideAndroidKeyboard();
//                      },
//                    )),
//                _getStatusWidget(store)
//              ],
//            ),
//          )
//        ));
//  }
//  /*
//  * 控制路由跳转
//  * @param request.url signed 签到
//  * @param request.url infoPage 消息 infoPage:studentApp 打开小状元学生
//  * @param request.url open_weixin 打开微信
//  * */
//  NavigationDecision _navigationDelegate(NavigationRequest request){
//    print('_navigationDelegate $request');
//    if (request.url.startsWith('haxecallback')) {
//      print('@ 回调参数 $request}');
//      if(request.url.indexOf("signed")>-1){
//        print("签到");
//        Navigator.of(context).pop("signed");
//      }else if(request.url.indexOf("infoPage")>-1){
//        print("消息");
//        if(request.url.indexOf("studentApp") > -1){
//          NavigatorUtil.goStudentAppPage(context);
//        }else{
//          Navigator.of(context).pop("infoPage");
//        }
//      }else if(request.url.indexOf("open_weixin")>-1){
//        print("打开微信");
//        goLaunch(context,"weixin://");
//      }else if(request.url.indexOf("haxecallback:tencentAd")>-1){
//        if (request.url != "haxecallback:tencentAd:0"){
//          print("tencentAd");
//          setState((){
//            _showAd = true;
//            _webviewBloc.showBanner(_showAd);
//          });
//        }else{
//          setState(() =>_showAd = false);
//        }
//      }else if (request.url.indexOf("webOpenCammera")>-1){
//        var _urlMsg = request.url.split(":?");
//        var type = 0;
//        if(_urlMsg.length>1){
//          var msg = Uri.decodeComponent(_urlMsg.last);
//          var _urlList = jsonDecode(msg);
//          if (_urlList["type"]!=null){
//            type = _urlList["type"];
//          }
//        }
//        _getImage(type,request.url).then((data){
////          print("-----!!!!!!------$data");
//          if (ObjectUtil.isEmpty(data) || data["result"] == "fail"){
//            _webViewController.evaluateJavascript("window.closeCamera()");
//          }else{
//            _webViewController.evaluateJavascript("window.getBackPhoto("+jsonEncode(data)+")");
//          }
//        });
//      }else if(request.url.indexOf("webOpenVideo")>-1){
//        print('打开相机-拍摄视频');
//        var _urlMsg = request.url.split(":");
//        // type: 0 : 录制视频 1：打开相册视频
//        var type = 0;
//        if(_urlMsg.length>1){
//          var msg = Uri.decodeComponent(_urlMsg.last);
//          // 打开相册的视频
//          if(msg == 'album'){
//            type = 1;
//          }
//        }
//        _getVideo(type).then((data){
//          print('暂不执行回调');
//        });
//      }else if(request.url.indexOf("share_TIMELINE")>-1){
//        print("微信朋友圈分享");
//        var _urlMsg = request.url.split(":?")[1];
//        _urlMsg = Uri.decodeComponent(_urlMsg);
//        var _urlList = jsonDecode(_urlMsg);
//        String webPage =  _urlList["webPage"];//分享地址
//        String thumbnail = _urlList["thumbnail"];//缩略图
//        String title =  _urlList["title"];
//        String description =  _urlList["description"];
//        var share = new ShareWx();
//        ShareWx.wxshare(1,webPage,thumbnail,"",title,description);
//      }else if(request.url.indexOf("share_OpenMiniProgramModel")>-1){
//        print("打开微信小程序");
//        var _urlMsg = request.url.split(":?")[1];
//        _urlMsg = Uri.decodeComponent(_urlMsg);
//        var _urlList = jsonDecode(_urlMsg);
//        String username =  _urlList["username"];//小程序原始ID
//        final type =  _urlList["type"];//小程序原始ID
//        String path = _urlList["path"] != null ? _urlList["path"] : "";
//        ///0  [WXMiniProgramType.RELEASE]正式版
//        ///1  [WXMiniProgramType.TEST]测试版
//        ///2  [WXMiniProgramType.PREVIEW]预览版
//        ShareWx.launchMiniProgram(username,type,path);
//      }else if(request.url.indexOf("share_MiniProgramModel")>-1){
//        print("微信小程序分享");
//        var _urlMsg = request.url.split(":?")[1];
//        _urlMsg = Uri.decodeComponent(_urlMsg);
//        var _urlList = jsonDecode(_urlMsg);
//        String webPage =  _urlList["webPage"];//分享地址
//        String thumbnail = _urlList["thumbnail"];//缩略图
//        String title =  _urlList["title"];
//        String description =  _urlList["description"];
//        String userName =  _urlList["userName"];
//        String path =  _urlList["path"];
//
//        String _webPageUrl = webPage;
//        String _thumbnail = thumbnail;
//        String _title = title;
//        String _userName = userName;
//        String _path = path;
//        String _description = description;
//        ShareWx.chatShareMiniProgramModel(_webPageUrl,_thumbnail,_title,_userName,_path,_description);
//
//      }else if(request.url.indexOf("share_SESSION")>-1){
//        print("微信会话分享");
//        var _urlMsg = request.url.split(":?")[1];
//        _urlMsg = Uri.decodeComponent(_urlMsg);
//        var _urlList = jsonDecode(_urlMsg);
//        String webPage =  _urlList["webPage"];//分享地址
//        String thumbnail = _urlList["thumbnail"];//缩略图
//        String title =  _urlList["title"];
//        String description =  _urlList["description"];
//        ShareWx.wxshare(0,webPage,thumbnail,"",title,description);
//      }else if(request.url.indexOf("share")>-1){
//        print("分享");
//        var _urlMsg = request.url.split(":?")[1];
//        _urlMsg = Uri.decodeComponent(_urlMsg);
//        var _urlList = jsonDecode(_urlMsg);
//        String _imagePath =  _urlList["webPage"];//分享地址
//        String _thumbnail = _urlList["thumbnail"];//缩略图
//        String _title =  _urlList["title"];
//        String _description =  _urlList["description"];
//        var _shareToWeChat =  new ShareToWeChat(webPage:_imagePath,thumbnail:_thumbnail,transaction:"",title: _title,description:_description);
//        CommonUtils.showGuide(context, _shareToWeChat);
//      }else if(request.url=="haxecallback:logout"){
//        print("登录失效 返回登录页面");
//        showToast("登录失效,请重新登录");
//        NavigatorUtil.goWelcome(context);
//        try{
//          httpManager.clearAuthorization();
//          Store<GSYState> store = StoreProvider.of(context);
//          store.dispatch(UpdateUserAction(User()));
//          SpUtil.remove(Config.LOGIN_USER);
//        }catch(e){
//          print(e);
//        }
//      }else{
//        Navigator.of(context).pop();
//      }
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if(request.url.startsWith('appcallback')){
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if (request.url.startsWith("weixin://")){
//      goLaunch(context,request.url);
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if (request.url == "about:blank"){
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if (request.url.startsWith("http://")||request.url.startsWith("https://")){
//      //允许路由替换
//      print('允许路由替换');
//      setState((){
//        _showAd = false;
//        _status = 0;
//        _timer?.cancel();
//        _timer = Timer(_timeoutSeconds, _unload);
//      }
//class WebViewPageState extends State<WebViewPage> with SingleTickerProviderStateMixin{
//  //状态 0加载  1加载完成
//  int _status = 0;
//  WebViewController _webViewController;
//  Size _deviceSize;
//  bool _showAd = false;
//  FocusNode _focusNode1 = FocusNode();
//  TextEditingController textController1 = TextEditingController();
//  FocusNode _focusNode2 = FocusNode();
//  TextEditingController textController2 = TextEditingController();
//  WebviewBloc _webviewBloc  =  WebviewBloc();
//  Timer _timer;
//  int _MAX_SIZE = 512000;
//  //加载超时时间
//  Duration _timeoutSeconds = const Duration(seconds: 7);
//  @override
//  Widget build(BuildContext context) {
//    _timer = Timer(_timeoutSeconds,_unload);
//    _deviceSize = MediaQuery.of(context).size;
//    Store<GSYState> store = StoreProvider.of(context);
//    return WillPopScope(
//        onWillPop: () async {
//          bool can = await _webViewController.canGoBack();
//          if (can) {
//            _webViewController.evaluateJavascript("window.backFunc()");
//            return Future.value(false);
//          } else {
//            return Future.value(true);
//          }
//        },
//        child: Scaffold(
////          backgroundColor: Colors.transparent,
//          appBar: widget.appBar??null,
//          body: SafeArea(
//            child: Stack(
//              alignment: AlignmentDirectional.bottomCenter,
//              children: <Widget>[
//                Platform.isAndroid?Offstage(
//                  offstage:true,
//                  child:Row(children: <Widget>[
//                    SizedBox(
//                      width:10,
//                      child: TextField(
//                         autofocus: false,
//                        focusNode: _focusNode1,
//                        controller: textController1,
//                        onChanged: (text) {
//                          _webViewController.evaluateJavascript('''
//                             if(current != null){
//                              current.value = '${textController1.text}';
//                              current.selectionStart = ${textController1.selection.start};
//                              current.selectionEnd = ${textController1.selection.end};
//                              current.dispatchEvent(new Event('input'));
//                             }
//                            ''');
//                        },
//                        onSubmitted: (text) {
//                          _webViewController.evaluateJavascript('''
//                            if(current != null)
//                              current.submit();
//                            ''');
//                          _focusNode1.unfocus();
//                        },
//                      ),
//                    ),
//                    SizedBox(
//                      width:10,
//                      child:  TextField(
//                        autofocus: false,
//                        focusNode: _focusNode2,
//                        controller: textController2,
//                        onChanged: (text) {
//                          _webViewController.evaluateJavascript('''
//                                   if(current != null){
//                                    current.value = '${textController2.text}';
//                                    current.selectionStart = ${textController2.selection.start};
//                                    current.selectionEnd = ${textController2.selection.end};
//                                    current.dispatchEvent(new Event('input'));
//                                   }
//                                  ''');
//                        },
//                        onSubmitted: (text) {
//                          _webViewController.evaluateJavascript('''
//                                  if(current != null)
//                                    current.submit();
//                                  ''');
//                          _focusNode2.unfocus();
//                        },
//                      ),
//                    ),
//                  ],
//                  ),
//                ):Container(),
//                Container(
//                    height: _deviceSize.height,
//                    child: WebView(
//                      initialMediaPlaybackPolicy:AutoMediaPlaybackPolicy.always_allow,
//                      initialUrl: widget.url,
//                      javascriptMode: JavascriptMode.unrestricted,
//                      onWebViewCreated: (WebViewController webViewController) {
//                        print("打开Webview!");
//                        _webViewController = webViewController;
//
//                        FocusScope.of(context).requestFocus(new FocusNode());
//                      },
//                      gestureRecognizers: Set()
//                        ..add(
//                          Factory<VerticalDragGestureRecognizer>(
//                                () => VerticalDragGestureRecognizer(),
//                          ),
//                        ),
//                      javascriptChannels: <JavascriptChannel>[_alertJavascriptChannel(context), _detectxy(context,store),_loadAd(),_openStudent(),_openVideo(),_userState(),_saveImage(),_openOther(),_openWebView()].toSet(),
//                      navigationDelegate: _navigationDelegate,
//                      onPageFinished: (String url) {
//                        print('@跳转链接: $url');
//                        if( _status != 1 ||_showAd != false ){
//                          setState((){
//                            _timer?.cancel();
//                            _status = 1;
//                            if(!url.startsWith(widget.url) &&_showAd!=false){
//                              print("false");
//                              _showAd =false;
//                            }
//                          },
//                          );
//                        }
//                        _input();
//                        _hideAndroidKeyboard();
//                      },
//                    )),
//                _getStatusWidget(store)
//              ],
//            ),
//          )
//        ));
//  }
//  /*
//  * 控制路由跳转
//  * @param request.url signed 签到
//  * @param request.url infoPage 消息 infoPage:studentApp 打开小状元学生
//  * @param request.url open_weixin 打开微信
//  * */
//  NavigationDecision _navigationDelegate(NavigationRequest request){
//    print('_navigationDelegate $request');
//    if (request.url.startsWith('haxecallback')) {
//      print('@ 回调参数 $request}');
//      if(request.url.indexOf("signed")>-1){
//        print("签到");
//        Navigator.of(context).pop("signed");
//      }else if(request.url.indexOf("infoPage")>-1){
//        print("消息");
//        if(request.url.indexOf("studentApp") > -1){
//          NavigatorUtil.goStudentAppPage(context);
//        }else{
//          Navigator.of(context).pop("infoPage");
//        }
//      }else if(request.url.indexOf("open_weixin")>-1){
//        print("打开微信");
//        goLaunch(context,"weixin://");
//      }else if(request.url.indexOf("haxecallback:tencentAd")>-1){
//        if (request.url != "haxecallback:tencentAd:0"){
//          print("tencentAd");
//          setState((){
//            _showAd = true;
//            _webviewBloc.showBanner(_showAd);
//          });
//        }else{
//          setState(() =>_showAd = false);
//        }
//      }else if (request.url.indexOf("webOpenCammera")>-1){
//        var _urlMsg = request.url.split(":?");
//        var type = 0;
//        if(_urlMsg.length>1){
//          var msg = Uri.decodeComponent(_urlMsg.last);
//          var _urlList = jsonDecode(msg);
//          if (_urlList["type"]!=null){
//            type = _urlList["type"];
//          }
//        }
//        _getImage(type,request.url).then((data){
////          print("-----!!!!!!------$data");
//          if (ObjectUtil.isEmpty(data) || data["result"] == "fail"){
//            _webViewController.evaluateJavascript("window.closeCamera()");
//          }else{
//            _webViewController.evaluateJavascript("window.getBackPhoto("+jsonEncode(data)+")");
//          }
//        });
//      }else if(request.url.indexOf("webOpenVideo")>-1){
//        print('打开相机-拍摄视频');
//        var _urlMsg = request.url.split(":");
//        // type: 0 : 录制视频 1：打开相册视频
//        var type = 0;
//        if(_urlMsg.length>1){
//          var msg = Uri.decodeComponent(_urlMsg.last);
//          // 打开相册的视频
//          if(msg == 'album'){
//            type = 1;
//          }
//        }
//        _getVideo(type).then((data){
//          print('暂不执行回调');
//        });
//      } else if(request.url.indexOf("share")>-1){
//        print("分享");
//        var _urlMsg = request.url.split(":?")[1];
//        _urlMsg = Uri.decodeComponent(_urlMsg);
//        var _urlList = jsonDecode(_urlMsg);
//        String _imagePath =  _urlList["webPage"];//分享地址
//        String _thumbnail = _urlList["thumbnail"];//缩略图
//        String _title =  _urlList["title"];
//        String _description =  _urlList["description"];
//        var _shareToWeChat =  new ShareToWeChat(webPage:_imagePath,thumbnail:_thumbnail,transaction:"",title: _title,description:_description);
//        CommonUtils.showGuide(context, _shareToWeChat);
//      }else if(request.url=="haxecallback:logout"){
//        print("登录失效 返回登录页面");
//        showToast("登录失效,请重新登录");
//        NavigatorUtil.goWelcome(context);
//        try{
//          httpManager.clearAuthorization();
//          Store<GSYState> store = StoreProvider.of(context);
//          store.dispatch(UpdateUserAction(User()));
//          SpUtil.remove(Config.LOGIN_USER);
//        }catch(e){
//          print(e);
//        }
//      }else{
//        Navigator.of(context).pop();
//      }
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if(request.url.startsWith('appcallback')){
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if (request.url.startsWith("weixin://") || request.url.startsWith("alipays://")){
//      print("11212");
//      goLaunch(context,request.url);
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if (request.url == "about:blank"){
//      //阻止路由替换；
//      return NavigationDecision.prevent;
//    }else if (request.url.startsWith("http://")||request.url.startsWith("https://")){
//      //允许路由替换
//      print('允许路由替换');
//      setState((){
//        _showAd = false;
//        _status = 0;
//        _timer?.cancel();
//        _timer = Timer(_timeoutSeconds, _unload);
//      }
//      );
//      return NavigationDecision.navigate;
//    }else{
//      return NavigationDecision.prevent;
//    }
//  }
//  //加载失败
//  _unload(){
//    if ( _status == 0 ){
//      setState(() {
//        _status =2;
//      });
//    }
//  }
//  Future _getVideo(type) async{
//    Map data = {"result":"success","path":""};
//    Uint8List _image;
//
//    File file = type == 1
//        ? await ImagePicker.pickVideo(source: ImageSource.gallery)
//        : await ImagePicker.pickVideo(source: ImageSource.camera);
//    if (ObjectUtil.isEmpty(file)||ObjectUtil.isEmptyString(file.path)){
//      // 拍摄失败
//      data["result"] = "fail";
//      return data;
//    }
//    // 压缩
//    if(file!=null){
//      // 进行压缩，发送给h5响应压缩的进度
//      _webViewController.evaluateJavascript("window.showLoading('视频压缩中...')");
////      final _flutterVideoCompress = FlutterVideoCompress();
////      final compressedVideoInfo = await _flutterVideoCompress.compressVideo(
////        file.path,
////        quality: VideoQuality.DefaultQuality,
////        deleteOrigin: false,
////      );
//      final compressedVideoInfo = await VideoCompress.compressVideo(
//        file.path,
//        quality: VideoQuality.DefaultQuality,
//        deleteOrigin: false,
//      );
//      int size = (await file.length());
//      print('压缩前的视频长度为：'+ size.toString());
//      print('[Compressing Video] done!' );
//      print('压缩视频后的长度为:'+ compressedVideoInfo.filesize.toString());
//      print(compressedVideoInfo.file);
//      print(compressedVideoInfo.path);
//      _webViewController.evaluateJavascript("window.hideLoading()");
//      // 开始上传视频
//      //获取md5
//      var filemd5 = md5.convert(compressedVideoInfo.file.readAsBytesSync());
//      var md5NAme = hex.encode(filemd5.bytes);
//      upload(compressedVideoInfo.path,md5NAme);
//    }
//    print('拍摄视频：' + file.toString());
//    return data;
//  }
//
//  void upload(path,name) async {
//    _webViewController.evaluateJavascript("window.showLoading('正在处理上传...')");
//    var res = await ApplicationDao.uploadSign();
//    if (res!=null &&res.result){
//      var data = res.data;
//      var token =  data["data"]["data"]["credentials"]["sessionToken"];
//      var tmpSecretId =  data["data"]["data"]["credentials"]["tmpSecretId"];
//      var tmpSecretKey =  data["data"]["data"]["credentials"]["tmpSecretKey"];
//      var expiredTime = data["data"]["data"]["expiredTime"];
//      var dateStrByDateTime = DateUtil.formatDate( DateTime.now(),format:DateFormats.y_mo);
//      dateStrByDateTime =  dateStrByDateTime.replaceAll("-", "");
//      String cosPath ="video/$dateStrByDateTime/$name.mp4";
//      TencentCos.uploadByFile(
//          "ap-guangzhou",
//          "1253703184",
//          "qlib-1253703184",
//          tmpSecretId,
//          tmpSecretKey,
//          token,
//          expiredTime,
//          cosPath,
//          path);
//      TencentCos.setMethodCallHandler(_handleMessages);
//    }
//  }
//
//  Future<Null> _handleMessages(MethodCall call) async {
//    _webViewController.evaluateJavascript("window.hideLoading()");
//    print(call.method);
//    print(call.arguments);
//    var result = call.arguments;
//    //call.method == "onSuccess" || call.method == "onFailed"
//    if(call.method == "onProgress"){
//      _webViewController.evaluateJavascript("window.drawProgress( " + jsonEncode(result) +")");
//    }else{
//      _webViewController.evaluateJavascript("window.uploadResult( " + jsonEncode(result) +")");
//    }
//  }
//  /*
//  * 唤醒手机软件
//  * @param weixin:// 唤醒微信
//  * */
//  static goLaunch(BuildContext context,String url) async{
////    await launch(url, forceSafariVC: false, forceWebView: false);
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
//  }
//  ///使用flutter 调用js案例
//  Widget jsButton() {
//    return FutureBuilder<WebViewController>(builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
//      if (controller.hasData) {
//        return FloatingActionButton(
//          onPressed: () async {
//            _webViewController.evaluateJavascript('''
//                    inputs = document.querySelectorAll("input[type=text]");
//                    inputs.forEach(function(inp) {
//                        let finalInput = inp;
//                        finalInput.addEventListener("focus", function() {
//                            Focus.postMessage('focus');
//                            input = finalInput;
//                            InputValue.postMessage('');
//                       });
//                       finalInput.addEventListener("focusout", function() {
//                           Focus.postMessage('focusout');
//                       });
//                  });
//            ''');
//          },
//          child: Text('call JS'),
//        );
//      }
//      return Container();
//    });
//  }
//  Widget _getStatusWidget(store){
//    Widget widget ;
//    if (_status ==0 ){
//      //loading
//      widget = Container(
//          width: _deviceSize.width,
//          height: _deviceSize.height,
//          color: Colors.white,
//          child: Center(child: CircularProgressIndicator()));
//    }else if(_status ==2){
//      //加载失败
//      widget = Container(
//          width: _deviceSize.width,
//          height: _deviceSize.height,
//          color: Colors.white,
//          child: Center(
//            child: Column(
//                mainAxisAlignment:MainAxisAlignment.center,
//              children: <Widget>[
//                Container(
//                  margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(90),bottom: ScreenUtil.getInstance().getHeightPx(33)),
//                  child: Image.asset("images/study/img-q.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(332) ,),
//                ),
//                Text("正在努力加载中···",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF999999)),),
//                Container(
//                  margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(58)),
//                  child:MaterialButton(
//                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                    minWidth: ScreenUtil.getInstance().getWidthPx(515),
//                    color: Color(0xFF6ed699),
//                    height:ScreenUtil.getInstance().getHeightPx(139) ,
//                    onPressed: (){Navigator.of(context).pop();},
//                    child: Text("返回首页",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFffffff))),
//                  ),
//                ),
//              ],
//            ),
//          ));
//    }else if (_showAd && (store.state.application.showBanner==1&&store.state.application.showH5Banner==1)){
//      //广告
//      widget = StreamBuilder<bool>(
//          stream: _webviewBloc.showAdStream,
//          initialData: true,
//          builder: (context, AsyncSnapshot<bool> snapshot) {
//            return snapshot.data?Container(
//              height: ScreenUtil.getInstance().screenWidth/6.4,
//              width: _deviceSize.width,
//              child: BannerUtil.buildBanner(null,null,bloc: _webviewBloc),
//            ):Container();
//          });
//    }else{
//      widget = Container();
//    }
//    return widget;
//  }
//
//
//  //调用相机或本机相册
//  Future _getImage(type,url) async {
//    File image;
//    String path;
//    Map data = {"result":"success","path":"","isSingle":false};
//    var param = {};
//    param["type"] = 0;
//    var result;
//    if (true){
//      url = Uri.decodeComponent(url);
//      List<String> split = url.split(":");
//      if (split.length>=5){
//        if (split[3] !=""){
//          param["msg"] = split[3];
//        }
//        if (split[4] =="single"){
//          param["isSingle"] = true;
//          data["isSingle"] = true;
//        }else if(split[4] =="staySingle") {
//          param["type"] = 1;
//        }
//      }
//      path =  await Camera.openCamera(param: param);
//      if(ObjectUtil.isEmptyString(path)){
//        data["result"] = "fail";
//        return data;
//      }
//      result = jsonDecode(path);
//      data["type"] = result["type"];
//    }else{
//      //ios 选择图片
//      image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera,imageQuality:50);
//      if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
//        data["result"] = "fail";
//        return data;
//      }
//    }
//    if (Platform.isAndroid){
//      image = await ImageCropper.cropImage(
//        sourcePath: image?.path ?? result["path"],
////      toolbarTitle: "选择图片",
//        androidUiSettings:  AndroidUiSettings(toolbarTitle:"选择图片",lockAspectRatio:false,initAspectRatio: CropAspectRatioPreset.original),
//      );
//    }else{
//      image = new File(image?.path ?? result["path"]);
//    }
//
//    //压缩
//    if  (image!=null){
//      int size = (await image.length());
//      while(size > _MAX_SIZE){
//        image = await FlutterNativeImage.compressImage(image.path,percentage:70,quality:70);
//        size = (await image.length());
//      }
//    }
//
//
//    if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
//      data["result"] = "fail";
//      return data;
//    }
//    List<int> bytes = await image.readAsBytes();
//    var base64encode = base64Encode(bytes);
//    data["data"] = base64encode;
//    return data;
//  }
//
//  /// 使用javascriptChannels发送消息
//  /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
//  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
//    return JavascriptChannel(
//        name: 'Toast',
//        onMessageReceived: (JavascriptMessage message) {
//          showToast(message.message);
//        });
//  }
//
//  //打开视频
//  JavascriptChannel _openVideo() {
//    return JavascriptChannel(
//        name: 'OpenVideo',
//        onMessageReceived: (JavascriptMessage message) {
//          var msg = jsonDecode(message.message);
//          if (msg!=null){
//            CommonUtils.showVideo(context, msg["url"]);
////            //是否能播放视频
////            X5Sdk.canUseTbsPlayer().then((can){
////              _webViewController.evaluateJavascript("window.backVideo('$can')");
////              if(can){
////                X5Sdk.openVideo(msg["url"],screenMode:msg["screenMode"]);
////              }
////            });
//          }
//        });
//  }
//  ///加载广告
//  JavascriptChannel _loadAd() {
//    return JavascriptChannel(
//        name: 'LoadAd',
//        onMessageReceived: (JavascriptMessage message) {
//          setState((){
//            _showAd = true;
//            _webviewBloc.showBanner(_showAd);
//          } );
//        });
//  }
//
//  ///加载广告
//  JavascriptChannel _saveImage() {
//    return JavascriptChannel(
//        name: 'SaveImage',
//        onMessageReceived: (JavascriptMessage message) {
//          if(ObjectUtil.isEmptyString(message.message)){
//            return;
//          }
//          picker.ImagePickerSaver.saveFile(fileData: base64Decode(message.message)).then((data){
//            if(!ObjectUtil.isEmptyString(data)){
//                print(data);
//                showToast("保存成功");
//            }
//          });
//
//        });
//  }
//  ///打开学生端
//  JavascriptChannel _openStudent() {
//    return JavascriptChannel(
//        name: 'OpenStudent',
//        onMessageReceived: (JavascriptMessage message) {
//          CommonUtils.openStudentApp();
//        });
//  }
//  ///新建WebView
//  JavascriptChannel _openWebView() {
//    return JavascriptChannel(
//    name: 'OpenWebView',
//    onMessageReceived: (JavascriptMessage message) {
//      if(ObjectUtil.isEmptyString(message.message)){
//        return;
//      }
//      var msg = jsonDecode(message.message);
//      NavigatorUtil.goWebView(context,msg["url"],openType:msg["type"]);
//    });
//  }
//
//  ///打开外部流浪器
//  JavascriptChannel _openOther() {
//    return JavascriptChannel(
//        name: 'OpenOther',
//        onMessageReceived: (JavascriptMessage message) async {
//          if(await canLaunch(message.message)){
//          await launch(message.message, forceSafariVC: false, forceWebView: false);
//          }else {
//          showToast('${message.message}打开失败',position:ToastPosition.bottom);
//          }
//        });
//  }
//
//  /// 使用手写功能
//  JavascriptChannel _detectxy(BuildContext context,Store<GSYState> store) {
//    return JavascriptChannel(
//        name: 'Detectxy',
//        onMessageReceived: (JavascriptMessage message) async {
//          var msg = jsonDecode(message.message);
//          print(msg["pos"]);
//          var result = await YondorChannel.detectxy(msg["pos"], msg["thickness"], msg["isSave"]??store.state.application.detectxySave==1);
//          _webViewController.evaluateJavascript("window.dx('$result')");
//        });
//  }
//
//
//  /// 键盘监听
//  JavascriptChannel _userState() {
//    return JavascriptChannel(
//        name: 'UserState',
//        onMessageReceived: (JavascriptMessage message) async {
//          var msg = jsonDecode(message.message);
//          print(msg);
//          if (msg["funcName"]=="focusout"){
//            _hideAndroidKeyboard();
//            return;
//          }
//          var data = msg["data"];
//          bool refocus = data['refocus'] as bool;
//          if (_focusNode2.hasFocus) {
//            if (!refocus) FocusScope.of(context).requestFocus(_focusNode1);
//            //FocusScope.of(context).requestFocus(_focusNode);
//            if (!_focusNode1.hasFocus) {
//              //hideAndroidKeyboard();
//              _showAndroidKeyboard();
//            }
//            //把初始文本设置给隐藏TextField
//            String initText = data['initText'];
//            var selectionStart = data['selectionStart'];
//            var selectionEnd = data['selectionEnd'];
//
//            int end = initText.length;
//            int start = initText.length;
//            if (selectionEnd is int) {
//              end = selectionEnd;
//            }
//            if (selectionStart is int) {
//              start = selectionEnd;
//            }
//            print(selectionEnd);
//            textController1.value = TextEditingValue(
//              text: initText,
//              selection: TextSelection(baseOffset: start, extentOffset: end),
//            );
//            //TextField请求显示键盘
//            FocusScope.of(context).requestFocus(_focusNode1);
//          } else {
//            if (!refocus) FocusScope.of(context).requestFocus(_focusNode2);
//            //FocusScope.of(context).requestFocus(_focusNode);
//            if (!_focusNode2.hasFocus) {
//              //hideAndroidKeyboard();
//              _showAndroidKeyboard();
//            }
//            //把初始文本设置给隐藏TextField
//            String initText = data['initText'];
//            var selectionStart = data['selectionStart'];
//            var selectionEnd = data['selectionEnd'];
//
//            int end = initText.length;
//            int start = initText.length;
//            if (selectionEnd is int) {
//              end = selectionEnd;
//            }
//            if (selectionStart is int) {
//              start = selectionEnd;
//            }
//            print(selectionEnd);
//            textController2.value = TextEditingValue(
//              text: initText,
//              selection: TextSelection(baseOffset: start, extentOffset: end),
//            );
//            //TextField请求显示键盘
//            FocusScope.of(context).requestFocus(_focusNode2);
//          }
//        });
//  }
//  void _showAndroidKeyboard(){
//    if(!Platform.isAndroid){
//      return;
//    }
//    if (!_focusNode1.hasFocus) {
//      FocusScope.of(context).requestFocus(_focusNode1);
//    }
//    if (!_focusNode2.hasFocus) {
//      FocusScope.of(context).requestFocus(_focusNode2);
//    }
//  }
//  void _hideAndroidKeyboard(){
//    if(!Platform.isAndroid){
//      return;
//    }
//    if (_focusNode1.hasFocus) {
//      _focusNode1.unfocus();
//    }
//    if (_focusNode2.hasFocus) {
//      _focusNode2.unfocus();
//    }
//  }
//  @override
//  void dispose() {
//    // 回收相关资源
//    if (_focusNode1.hasFocus) {
//      _focusNode1.unfocus();
//    }
//    if (_focusNode2.hasFocus) {
//      _focusNode2.unfocus();
//    }
//    _focusNode1.dispose();
//    _focusNode2.dispose();
//    textController1.dispose();
//    textController2.dispose();
//    super.dispose();
//  }
//
//  @override
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    switch (state) {
//      case AppLifecycleState.resumed:
//      //前台展示
////        print('应用程序可见并响应用户输入。');
//        _webViewController.evaluateJavascript("window.resumed()");
//        break;
//      case AppLifecycleState.inactive:
////        print('应用程序处于非活动状态，并且未接收用户输入');
//        break;
//      case AppLifecycleState.paused:
//      //后台展示
////        print('用户当前看不到应用程序，没有响应');
//        _webViewController.evaluateJavascript("window.paused()");
//        break;
//      default:
//        break;
//    }
//  }
//
//  void _input(){
//    if(!Platform.isAndroid){
//      return;
//    }
//    print("_webViewController _input");
//    _webViewController.evaluateJavascript('''
//              var inputs = document.getElementsByTagName('input');
//              var keyboards = document.getElementsByClassName('get_keyboard');
//              var current;
//              for (var i = 0; i < inputs.length; i++) {
//                console.log(i);
//                inputs[i].addEventListener('click', (e) => {
//                  var json = {
//                    "funcName": "requestFocus",
//                    "data": {
//                      "initText": e.target.value,
//                      "selectionStart":e.target.selectionStart,
//                      "selectionEnd":e.target.selectionEnd
//                    }
//                  };
//                  json.data.refocus = (document.activeElement == current);
//                  current = e.target;
//                  var param = JSON.stringify(json);
//                  console.log(param);
//                  UserState.postMessage(param);
//                });
//                //inputs[i].addEventListener('focusout', (e) => {
//                //  var json = {
//                //    "funcName": "focusout",
//                //  };
//                //  var param = JSON.stringify(json);
//                //  console.log(param);
//                //  UserState.postMessage(param);
//                //})
//              };
//               for (var i = 0; i < keyboards.length; i++) {
//                console.log(i);
//                keyboards[i].addEventListener('click', (e) => {
//                  var json = {
//                    "funcName": "requestFocus",
//                    "data": {
//                      "initText": e.target.value,
//                      "selectionStart":e.target.selectionStart,
//                      "selectionEnd":e.target.selectionEnd
//                    }
//                  };
//                  json.data.refocus = (document.activeElement == current);
//                  current = e.target;
//                  var param = JSON.stringify(json);
//                  console.log(param);
//                  UserState.postMessage(param);
//                });
//                //keyboards[i].addEventListener('focusout', (e) => {
//                //  var json = {
//                //    "funcName": "focusout",
//                // };
//                //  var param = JSON.stringify(json);
//                //  console.log(param);
//                //  UserState.postMessage(param);
//                //})
//              };
//            ''');
//  }
//}
//      return NavigationDecision.navigate;
//    }else{
//      return NavigationDecision.prevent;
//    }
//  }
//  //加载失败
//  _unload(){
//    if ( _status == 0 ){
//      setState(() {
//        _status =2;
//      });
//    }
//  }
//  Future _getVideo(type) async{
//    Map data = {"result":"success","path":""};
//    Uint8List _image;
//
//    File file = type == 1
//        ? await ImagePicker.pickVideo(source: ImageSource.gallery)
//        : await ImagePicker.pickVideo(source: ImageSource.camera);
//    if (ObjectUtil.isEmpty(file)||ObjectUtil.isEmptyString(file.path)){
//      // 拍摄失败
//      data["result"] = "fail";
//      return data;
//    }
//    // 压缩
//    if(file!=null){
//      // 进行压缩，发送给h5响应压缩的进度
//      _webViewController.evaluateJavascript("window.showLoading('视频压缩中...')");
////      final _flutterVideoCompress = FlutterVideoCompress();
////      final compressedVideoInfo = await _flutterVideoCompress.compressVideo(
////        file.path,
////        quality: VideoQuality.DefaultQuality,
////        deleteOrigin: false,
////      );
////      final compressedVideoInfo = await VideoCompress.compressVideo(
////        file.path,
////        quality: VideoQuality.DefaultQuality,
////        deleteOrigin: false,
////      );
////      int size = (await file.length());
////      print('压缩前的视频长度为：'+ size.toString());
////      print('[Compressing Video] done!' );
////      print('压缩视频后的长度为:'+ compressedVideoInfo.filesize.toString());
////      print(compressedVideoInfo.file);
////      print(compressedVideoInfo.path);
//      _webViewController.evaluateJavascript("window.hideLoading()");
//      // 开始上传视频
//      //获取md5
//      var filemd5 = md5.convert(file.readAsBytesSync());
//      var md5NAme = hex.encode(filemd5.bytes);
//      upload(file.path,md5NAme);
//    }
//    print('拍摄视频：' + file.toString());
//    return data;
//  }
//
//  void upload(path,name) async {
//    _webViewController.evaluateJavascript("window.showLoading('正在处理上传...')");
//    var res = await ApplicationDao.uploadSign();
//    if (res!=null &&res.result){
//      var data = res.data;
//      var token =  data["data"]["data"]["credentials"]["sessionToken"];
//      var tmpSecretId =  data["data"]["data"]["credentials"]["tmpSecretId"];
//      var tmpSecretKey =  data["data"]["data"]["credentials"]["tmpSecretKey"];
//      var expiredTime = data["data"]["data"]["expiredTime"];
//      var dateStrByDateTime = DateUtil.getDateStrByDateTime( DateTime.now(),format:DateFormat.YEAR_MONTH);
//      dateStrByDateTime =  dateStrByDateTime.replaceAll("-", "");
//      String cosPath ="video/$dateStrByDateTime/$name.mp4";
//      TencentCos.uploadByFile(
//          "ap-guangzhou",
//          "1253703184",
//          "qlib-1253703184",
//          tmpSecretId,
//          tmpSecretKey,
//          token,
//          expiredTime,
//          cosPath,
//          path);
//      TencentCos.setMethodCallHandler(_handleMessages);
//    }
//  }
//
//  Future<Null> _handleMessages(MethodCall call) async {
//    _webViewController.evaluateJavascript("window.hideLoading()");
//    print(call.method);
//    print(call.arguments);
//    var result = call.arguments;
//    //call.method == "onSuccess" || call.method == "onFailed"
//    if(call.method == "onProgress"){
//      _webViewController.evaluateJavascript("window.drawProgress( " + jsonEncode(result) +")");
//    }else{
//      _webViewController.evaluateJavascript("window.uploadResult( " + jsonEncode(result) +")");
//    }
//  }
//  /*
//  * 唤醒手机软件
//  * @param weixin:// 唤醒微信
//  * */
//  static goLaunch(BuildContext context,String url) async{
////    await launch(url, forceSafariVC: false, forceWebView: false);
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
//  }
//  ///使用flutter 调用js案例
//  Widget jsButton() {
//    return FutureBuilder<WebViewController>(builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
//      if (controller.hasData) {
//        return FloatingActionButton(
//          onPressed: () async {
//            _webViewController.evaluateJavascript('''
//                    inputs = document.querySelectorAll("input[type=text]");
//                    inputs.forEach(function(inp) {
//                        let finalInput = inp;
//                        finalInput.addEventListener("focus", function() {
//                            Focus.postMessage('focus');
//                            input = finalInput;
//                            InputValue.postMessage('');
//                       });
//                       finalInput.addEventListener("focusout", function() {
//                           Focus.postMessage('focusout');
//                       });
//                  });
//            ''');
//          },
//          child: Text('call JS'),
//        );
//      }
//      return Container();
//    });
//  }
//  Widget _getStatusWidget(store){
//    Widget widget ;
//    if (_status ==0 ){
//      //loading
//      widget = Container(
//          width: _deviceSize.width,
//          height: _deviceSize.height,
//          color: Colors.white,
//          child: Center(child: CircularProgressIndicator()));
//    }else if(_status ==2){
//      //加载失败
//      widget = Container(
//          width: _deviceSize.width,
//          height: _deviceSize.height,
//          color: Colors.white,
//          child: Center(
//            child: Column(
//                mainAxisAlignment:MainAxisAlignment.center,
//              children: <Widget>[
//                Container(
//                  margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(90),bottom: ScreenUtil.getInstance().getHeightPx(33)),
//                  child: Image.asset("images/study/img-q.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(332) ,),
//                ),
//                Text("正在努力加载中···",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF999999)),),
//                Container(
//                  margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(58)),
//                  child:MaterialButton(
//                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                    minWidth: ScreenUtil.getInstance().getWidthPx(515),
//                    color: Color(0xFF6ed699),
//                    height:ScreenUtil.getInstance().getHeightPx(139) ,
//                    onPressed: (){Navigator.of(context).pop();},
//                    child: Text("返回首页",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFffffff))),
//                  ),
//                ),
//              ],
//            ),
//          ));
//    }else if (_showAd && (store.state.application.showBanner==1&&store.state.application.showH5Banner==1)){
//      //广告
//      widget = StreamBuilder<bool>(
//          stream: _webviewBloc.showAdStream,
//          initialData: true,
//          builder: (context, AsyncSnapshot<bool> snapshot) {
//            return snapshot.data?Container(
//              height: ScreenUtil.getInstance().screenWidth/6.4,
//              width: _deviceSize.width,
//              child: BannerUtil.buildBanner(null,null,bloc: _webviewBloc),
//            ):Container();
//          });
//    }else{
//      widget = Container();
//    }
//    return widget;
//  }
//
//
//  //调用相机或本机相册
//  Future _getImage(type,url) async {
//    File image;
//    String path;
//    Map data = {"result":"success","path":"","isSingle":false};
//    var param = {};
//    param["type"] = 0;
//    var result;
//    if (true){
//      url = Uri.decodeComponent(url);
//      List<String> split = url.split(":");
//      if (split.length>=5){
//        if (split[3] !=""){
//          param["msg"] = split[3];
//        }
//        if (split[4] =="single"){
//          param["isSingle"] = true;
//          data["isSingle"] = true;
//        }else if(split[4] =="staySingle") {
//          param["type"] = 1;
//        }
//      }
//      path =  await Camera.openCamera(param: param);
//      if(ObjectUtil.isEmptyString(path)){
//        data["result"] = "fail";
//        return data;
//      }
//      result = jsonDecode(path);
//      data["type"] = result["type"];
//    }else{
//      //ios 选择图片
//      image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera,imageQuality:50);
//      if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
//        data["result"] = "fail";
//        return data;
//      }
//    }
//    if (Platform.isAndroid){
//      image = await ImageCropper.cropImage(
//        sourcePath: image?.path ?? result["path"],
////      toolbarTitle: "选择图片",
//        androidUiSettings:  AndroidUiSettings(toolbarTitle:"选择图片",lockAspectRatio:false,initAspectRatio: CropAspectRatioPreset.original),
//      );
//    }else{
//      image = new File(image?.path ?? result["path"]);
//    }
//
//    //压缩
//    if  (image!=null){
//      int size = (await image.length());
//      while(size > _MAX_SIZE){
//        image = await FlutterNativeImage.compressImage(image.path,percentage:70,quality:70);
//        size = (await image.length());
//      }
//    }
//
//
//    if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
//      data["result"] = "fail";
//      return data;
//    }
//    List<int> bytes = await image.readAsBytes();
//    var base64encode = base64Encode(bytes);
//    data["data"] = base64encode;
//    return data;
//  }
//
//  /// 使用javascriptChannels发送消息
//  /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
//  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
//    return JavascriptChannel(
//        name: 'Toast',
//        onMessageReceived: (JavascriptMessage message) {
//          showToast(message.message);
//        });
//  }
//
//  //打开视频
//  JavascriptChannel _openVideo() {
//    return JavascriptChannel(
//        name: 'OpenVideo',
//        onMessageReceived: (JavascriptMessage message) {
//          var msg = jsonDecode(message.message);
//          if (msg!=null){
//            CommonUtils.showVideo(context, msg["url"]);
////            //是否能播放视频
////            X5Sdk.canUseTbsPlayer().then((can){
////              _webViewController.evaluateJavascript("window.backVideo('$can')");
////              if(can){
////                X5Sdk.openVideo(msg["url"],screenMode:msg["screenMode"]);
////              }
////            });
//          }
//        });
//  }
//  ///加载广告
//  JavascriptChannel _loadAd() {
//    return JavascriptChannel(
//        name: 'LoadAd',
//        onMessageReceived: (JavascriptMessage message) {
//          setState((){
//            _showAd = true;
//            _webviewBloc.showBanner(_showAd);
//          } );
//        });
//  }
//
//  ///加载广告
//  JavascriptChannel _saveImage() {
//    return JavascriptChannel(
//        name: 'SaveImage',
//        onMessageReceived: (JavascriptMessage message) {
//          if(ObjectUtil.isEmptyString(message.message)){
//            return;
//          }
//          picker.ImagePickerSaver.saveFile(fileData: base64Decode(message.message)).then((data){
//            if(!ObjectUtil.isEmptyString(data)){
//                print(data);
//                showToast("保存成功");
//            }
//          });
//
//        });
//  }
//  ///打开学生端
//  JavascriptChannel _openStudent() {
//    return JavascriptChannel(
//        name: 'OpenStudent',
//        onMessageReceived: (JavascriptMessage message) {
//          CommonUtils.openStudentApp();
//        });
//  }
//  ///新建WebView
//  JavascriptChannel _openWebView() {
//    return JavascriptChannel(
//    name: 'OpenWebView',
//    onMessageReceived: (JavascriptMessage message) {
//      if(ObjectUtil.isEmptyString(message.message)){
//        return;
//      }
//      var msg = jsonDecode(message.message);
//      NavigatorUtil.goWebView(context,msg["url"],openType:msg["type"]);
//    });
//  }
//
//  ///打开外部流浪器
//  JavascriptChannel _openOther() {
//    return JavascriptChannel(
//        name: 'OpenOther',
//        onMessageReceived: (JavascriptMessage message) async {
//          if(await canLaunch(message.message)){
//          await launch(message.message, forceSafariVC: false, forceWebView: false);
//          }else {
//          showToast('${message.message}打开失败',position:ToastPosition.bottom);
//          }
//        });
//  }
//
//  /// 使用手写功能
//  JavascriptChannel _detectxy(BuildContext context,Store<GSYState> store) {
//    return JavascriptChannel(
//        name: 'Detectxy',
//        onMessageReceived: (JavascriptMessage message) async {
//          var msg = jsonDecode(message.message);
//          print(msg["pos"]);
//          var result = await YondorChannel.detectxy(msg["pos"], msg["thickness"], msg["isSave"]??store.state.application.detectxySave==1);
//          _webViewController.evaluateJavascript("window.dx('$result')");
//        });
//  }
//
//
//  /// 键盘监听
//  JavascriptChannel _userState() {
//    return JavascriptChannel(
//        name: 'UserState',
//        onMessageReceived: (JavascriptMessage message) async {
//          var msg = jsonDecode(message.message);
//          print(msg);
//          if (msg["funcName"]=="focusout"){
//            _hideAndroidKeyboard();
//            return;
//          }
//          var data = msg["data"];
//          bool refocus = data['refocus'] as bool;
//          if (_focusNode2.hasFocus) {
//            if (!refocus) FocusScope.of(context).requestFocus(_focusNode1);
//            //FocusScope.of(context).requestFocus(_focusNode);
//            if (!_focusNode1.hasFocus) {
//              //hideAndroidKeyboard();
//              _showAndroidKeyboard();
//            }
//            //把初始文本设置给隐藏TextField
//            String initText = data['initText'];
//            var selectionStart = data['selectionStart'];
//            var selectionEnd = data['selectionEnd'];
//
//            int end = initText.length;
//            int start = initText.length;
//            if (selectionEnd is int) {
//              end = selectionEnd;
//            }
//            if (selectionStart is int) {
//              start = selectionEnd;
//            }
//            print(selectionEnd);
//            textController1.value = TextEditingValue(
//              text: initText,
//              selection: TextSelection(baseOffset: start, extentOffset: end),
//            );
//            //TextField请求显示键盘
//            FocusScope.of(context).requestFocus(_focusNode1);
//          } else {
//            if (!refocus) FocusScope.of(context).requestFocus(_focusNode2);
//            //FocusScope.of(context).requestFocus(_focusNode);
//            if (!_focusNode2.hasFocus) {
//              //hideAndroidKeyboard();
//              _showAndroidKeyboard();
//            }
//            //把初始文本设置给隐藏TextField
//            String initText = data['initText'];
//            var selectionStart = data['selectionStart'];
//            var selectionEnd = data['selectionEnd'];
//
//            int end = initText.length;
//            int start = initText.length;
//            if (selectionEnd is int) {
//              end = selectionEnd;
//            }
//            if (selectionStart is int) {
//              start = selectionEnd;
//            }
//            print(selectionEnd);
//            textController2.value = TextEditingValue(
//              text: initText,
//              selection: TextSelection(baseOffset: start, extentOffset: end),
//            );
//            //TextField请求显示键盘
//            FocusScope.of(context).requestFocus(_focusNode2);
//          }
//        });
//  }
//  void _showAndroidKeyboard(){
//    if(!Platform.isAndroid){
//      return;
//    }
//    if (!_focusNode1.hasFocus) {
//      FocusScope.of(context).requestFocus(_focusNode1);
//    }
//    if (!_focusNode2.hasFocus) {
//      FocusScope.of(context).requestFocus(_focusNode2);
//    }
//  }
//  void _hideAndroidKeyboard(){
//    if(!Platform.isAndroid){
//      return;
//    }
//    if (_focusNode1.hasFocus) {
//      _focusNode1.unfocus();
//    }
//    if (_focusNode2.hasFocus) {
//      _focusNode2.unfocus();
//    }
//  }
//  @override
//  void dispose() {
//    // 回收相关资源
//    if (_focusNode1.hasFocus) {
//      _focusNode1.unfocus();
//    }
//    if (_focusNode2.hasFocus) {
//      _focusNode2.unfocus();
//    }
//    _focusNode1.dispose();
//    _focusNode2.dispose();
//    textController1.dispose();
//    textController2.dispose();
//    super.dispose();
//  }
//
//  @override
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    switch (state) {
//      case AppLifecycleState.resumed:
//      //前台展示
////        print('应用程序可见并响应用户输入。');
//        _webViewController.evaluateJavascript("window.resumed()");
//        break;
//      case AppLifecycleState.inactive:
////        print('应用程序处于非活动状态，并且未接收用户输入');
//        break;
//      case AppLifecycleState.paused:
//      //后台展示
////        print('用户当前看不到应用程序，没有响应');
//        _webViewController.evaluateJavascript("window.paused()");
//        break;
//      case AppLifecycleState.suspending:
////        print('应用程序将暂停。');
//        break;
//      default:
//        break;
//    }
//  }
//
//  void _input(){
//    if(!Platform.isAndroid){
//      return;
//    }
//    print("_webViewController _input");
//    _webViewController.evaluateJavascript('''
//              var inputs = document.getElementsByTagName('input');
//              var keyboards = document.getElementsByClassName('get_keyboard');
//              var current;
//              for (var i = 0; i < inputs.length; i++) {
//                console.log(i);
//                inputs[i].addEventListener('click', (e) => {
//                  var json = {
//                    "funcName": "requestFocus",
//                    "data": {
//                      "initText": e.target.value,
//                      "selectionStart":e.target.selectionStart,
//                      "selectionEnd":e.target.selectionEnd
//                    }
//                  };
//                  json.data.refocus = (document.activeElement == current);
//                  current = e.target;
//                  var param = JSON.stringify(json);
//                  console.log(param);
//                  UserState.postMessage(param);
//                });
//                //inputs[i].addEventListener('focusout', (e) => {
//                //  var json = {
//                //    "funcName": "focusout",
//                //  };
//                //  var param = JSON.stringify(json);
//                //  console.log(param);
//                //  UserState.postMessage(param);
//                //})
//              };
//               for (var i = 0; i < keyboards.length; i++) {
//                console.log(i);
//                keyboards[i].addEventListener('click', (e) => {
//                  var json = {
//                    "funcName": "requestFocus",
//                    "data": {
//                      "initText": e.target.value,
//                      "selectionStart":e.target.selectionStart,
//                      "selectionEnd":e.target.selectionEnd
//                    }
//                  };
//                  json.data.refocus = (document.activeElement == current);
//                  current = e.target;
//                  var param = JSON.stringify(json);
//                  console.log(param);
//                  UserState.postMessage(param);
//                });
//                //keyboards[i].addEventListener('focusout', (e) => {
//                //  var json = {
//                //    "funcName": "focusout",
//                // };
//                //  var param = JSON.stringify(json);
//                //  console.log(param);
//                //  UserState.postMessage(param);
//                //})
//              };
//            ''');
//  }
//}


