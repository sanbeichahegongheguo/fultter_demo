import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/WebviewBloc.dart';
import 'package:flutter_start/common/channel/YondorChannel.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/common/utils/BannerUtil.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/user.dart';
import 'package:flutter_start/widget/ShareToWeChat.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_saver/image_picker_saver.dart' as picker;
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
  FocusNode _focusNode1 = FocusNode();
  TextEditingController textController1 = TextEditingController();
  FocusNode _focusNode2 = FocusNode();
  TextEditingController textController2 = TextEditingController();
  WebviewBloc _webviewBloc  =  WebviewBloc();
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
                  Platform.isAndroid?Offstage(
                  offstage:true,
                    child:Row(children: <Widget>[
                      TextField(
                      autofocus: false,
                      focusNode: _focusNode1,
                      controller: textController1,
                      onChanged: (text) {
                        _webViewController.evaluateJavascript('''
                         if(current != null){
                          current.value = '${textController1.text}';
                          current.selectionStart = ${textController1.selection.start};
                          current.selectionEnd = ${textController1.selection.end};
                          current.dispatchEvent(new Event('input'));
                         }
                        ''');
                      },
                      onSubmitted: (text) {
                        _webViewController.evaluateJavascript('''
                        if(current != null)
                          current.submit();
                        ''');
                        _focusNode1.unfocus();
                      },
                    ),
                      TextField(
                        autofocus: false,
                        focusNode: _focusNode2,
                        controller: textController2,
                        onChanged: (text) {
                          _webViewController.evaluateJavascript('''
                                   if(current != null){
                                    current.value = '${textController2.text}';
                                    current.selectionStart = ${textController2.selection.start};
                                    current.selectionEnd = ${textController2.selection.end};
                                    current.dispatchEvent(new Event('input'));
                                   }
                                  ''');
                        },
                        onSubmitted: (text) {
                          _webViewController.evaluateJavascript('''
                                  if(current != null)
                                    current.submit();
                                  ''');
                          _focusNode2.unfocus();
                        },
                      ),
                    ],),
                  ):Container(),
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
                        javascriptChannels: <JavascriptChannel>[_alertJavascriptChannel(context), _detectxy(context),_loadAd(),_openStudent(),_openVideo(),_userState(),_saveImage()].toSet(),
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
                          _input();
                          _hideAndroidKeyboard();
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
          setState((){
            _showAd = true;
            _webviewBloc.showBanner(_showAd);
          });
        }else{
          setState(() =>_showAd = false);
        }
      }else if (request.url.indexOf("webOpenCammera")>-1){
        var _urlMsg = request.url.split(":?");
        var type = 0;
        if(_urlMsg.length>1){
          var msg = Uri.decodeComponent(_urlMsg.last);
          var _urlList = jsonDecode(msg);
          if (_urlList["type"]!=null){
            type = _urlList["type"];
          }
        }
        _getImage(type).then((v){
          var data = {"result":"success","path":""};
          if (ObjectUtil.isEmptyString(v)){
            data["result"] = "fail";
          }else{
            data["data"] = v;
            _webViewController.evaluateJavascript("window.getBackPhoto("+jsonEncode(data)+")");
          }
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
      }else if(request.url=="haxecallback:logout"){
        print("登录失效 返回登录页面");
        showToast("登录失效,请重新登录");
        NavigatorUtil.goWelcome(context);
        try{
          httpManager.clearAuthorization();
          Store<GSYState> store = StoreProvider.of(context);
          store.dispatch(UpdateUserAction(User()));
          SpUtil.remove(Config.LOGIN_USER);
        }catch(e){
          print(e);
        }
      }else{
        Navigator.of(context).pop();
      }
      //阻止路由替换；
      return NavigationDecision.prevent;
    }else if(request.url.startsWith('appcallback')){
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
//    await launch(url, forceSafariVC: false, forceWebView: false);
    if(await canLaunch(url)){
      await launch(url, forceSafariVC: false, forceWebView: false);
    }else {
      String msg = "程序";
      switch(url){
        case "weixin://":
          msg = "微信";
          break;
      }
      showToast('$msg打开失败',position:ToastPosition.bottom);
    }
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
      widget = StreamBuilder<bool>(
          stream: _webviewBloc.showAdStream,
          initialData: true,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            return snapshot.data?Container(
              height: ScreenUtil.getInstance().screenWidth/6.4,
              width: _deviceSize.width,
              child: BannerUtil.buildBanner(null,null,bloc: _webviewBloc),
            ):Container();
          });
    }else{
      widget = Container();
    }
    return widget;
  }


  //调用相机或本机相册
  Future _getImage(type) async {
    File image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera,imageQuality:50);
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
    if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
      return "";
    }
    List<int> bytes = await image.readAsBytes();
    var base64encode = base64Encode(bytes);
    return base64encode;
  }
  /// 使用javascriptChannels发送消息
  /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toast',
        onMessageReceived: (JavascriptMessage message) {
          showToast(message.message);
        });
  }

  //打开视频
  JavascriptChannel _openVideo() {
    return JavascriptChannel(
        name: 'OpenVideo',
        onMessageReceived: (JavascriptMessage message) {
          var msg = jsonDecode(message.message);
          if (msg!=null){
            CommonUtils.showVideo(context, msg["url"]);
//            //是否能播放视频
//            X5Sdk.canUseTbsPlayer().then((can){
//              _webViewController.evaluateJavascript("window.backVideo('$can')");
//              if(can){
//                X5Sdk.openVideo(msg["url"],screenMode:msg["screenMode"]);
//              }
//            });
          }
        });
  }
  ///加载广告
  JavascriptChannel _loadAd() {
    return JavascriptChannel(
        name: 'LoadAd',
        onMessageReceived: (JavascriptMessage message) {
          setState((){
            _showAd = true;
            _webviewBloc.showBanner(_showAd);
          } );
        });
  }

  ///加载广告
  JavascriptChannel _saveImage() {
    return JavascriptChannel(
        name: 'SaveImage',
        onMessageReceived: (JavascriptMessage message) {
          if(ObjectUtil.isEmptyString(message.message)){
            return;
          }
          picker.ImagePickerSaver.saveFile(fileData: base64Decode(message.message)).then((data){
            if(!ObjectUtil.isEmptyString(data)){
                print(data);
                showToast("保存成功");
            }
          });

        });
  }
  ///打开学生端
  JavascriptChannel _openStudent() {
    return JavascriptChannel(
        name: 'OpenStudent',
        onMessageReceived: (JavascriptMessage message) {
          CommonUtils.openStudentApp();
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


  /// 键盘监听
  JavascriptChannel _userState() {
    return JavascriptChannel(
        name: 'UserState',
        onMessageReceived: (JavascriptMessage message) async {
          var msg = jsonDecode(message.message);
          print(msg);
          if (msg["funcName"]=="focusout"){
            _hideAndroidKeyboard();
            return;
          }
          var data = msg["data"];
          bool refocus = data['refocus'] as bool;
          if (_focusNode2.hasFocus) {
            if (!refocus) FocusScope.of(context).requestFocus(_focusNode1);
            //FocusScope.of(context).requestFocus(_focusNode);
            if (!_focusNode1.hasFocus) {
              //hideAndroidKeyboard();
              _showAndroidKeyboard();
            }
            //把初始文本设置给隐藏TextField
            String initText = data['initText'];
            var selectionStart = data['selectionStart'];
            var selectionEnd = data['selectionEnd'];

            int end = initText.length;
            int start = initText.length;
            if (selectionEnd is int) {
              end = selectionEnd;
            }
            if (selectionStart is int) {
              start = selectionEnd;
            }
            print(selectionEnd);
            textController1.value = TextEditingValue(
              text: initText,
              selection: TextSelection(baseOffset: start, extentOffset: end),
            );
            //TextField请求显示键盘
            FocusScope.of(context).requestFocus(_focusNode1);
          } else {
            if (!refocus) FocusScope.of(context).requestFocus(_focusNode2);
            //FocusScope.of(context).requestFocus(_focusNode);
            if (!_focusNode2.hasFocus) {
              //hideAndroidKeyboard();
              _showAndroidKeyboard();
            }
            //把初始文本设置给隐藏TextField
            String initText = data['initText'];
            var selectionStart = data['selectionStart'];
            var selectionEnd = data['selectionEnd'];

            int end = initText.length;
            int start = initText.length;
            if (selectionEnd is int) {
              end = selectionEnd;
            }
            if (selectionStart is int) {
              start = selectionEnd;
            }
            print(selectionEnd);
            textController2.value = TextEditingValue(
              text: initText,
              selection: TextSelection(baseOffset: start, extentOffset: end),
            );
            //TextField请求显示键盘
            FocusScope.of(context).requestFocus(_focusNode2);
          }
        });
  }
  void _showAndroidKeyboard(){
    if(!Platform.isAndroid){
      return;
    }
    if (!_focusNode1.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode1);
    }
    if (!_focusNode2.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode2);
    }
  }
  void _hideAndroidKeyboard(){
    if(!Platform.isAndroid){
      return;
    }
    if (_focusNode1.hasFocus) {
      _focusNode1.unfocus();
    }
    if (_focusNode2.hasFocus) {
      _focusNode2.unfocus();
    }
  }
  @override
  void dispose() {
    // 回收相关资源
    if (_focusNode1.hasFocus) {
      _focusNode1.unfocus();
    }
    if (_focusNode2.hasFocus) {
      _focusNode2.unfocus();
    }
    _focusNode1.dispose();
    _focusNode2.dispose();
    textController1.dispose();
    textController2.dispose();
    super.dispose();
  }

  void _input(){
    if(!Platform.isAndroid){
      return;
    }
    print("_webViewController _input");
    _webViewController.evaluateJavascript('''
              var inputs = document.getElementsByTagName('input');
              var keyboards = document.getElementsByClassName('get_keyboard');
              var current;
              for (var i = 0; i < inputs.length; i++) {
                console.log(i);
                inputs[i].addEventListener('click', (e) => {
                  var json = {
                    "funcName": "requestFocus",
                    "data": {
                      "initText": e.target.value,
                      "selectionStart":e.target.selectionStart,
                      "selectionEnd":e.target.selectionEnd
                    }
                  };
                  json.data.refocus = (document.activeElement == current); 
                  current = e.target;
                  var param = JSON.stringify(json);
                  console.log(param);
                  UserState.postMessage(param);
                });
                inputs[i].addEventListener('focusout', (e) => {
                  var json = {
                    "funcName": "focusout",
                  };
                  var param = JSON.stringify(json);
                  console.log(param);
                  UserState.postMessage(param);
                })
              };
               for (var i = 0; i < keyboards.length; i++) {
                console.log(i);
                keyboards[i].addEventListener('click', (e) => {
                  var json = {
                    "funcName": "requestFocus",
                    "data": {
                      "initText": e.target.value,
                      "selectionStart":e.target.selectionStart,
                      "selectionEnd":e.target.selectionEnd
                    }
                  };
                  json.data.refocus = (document.activeElement == current); 
                  current = e.target;
                  var param = JSON.stringify(json);
                  console.log(param);
                  UserState.postMessage(param);
                });
                keyboards[i].addEventListener('focusout', (e) => {
                  var json = {
                    "funcName": "focusout",
                  };
                  var param = JSON.stringify(json);
                  console.log(param);
                  UserState.postMessage(param);
                })
              };
            ''');
  }
}


