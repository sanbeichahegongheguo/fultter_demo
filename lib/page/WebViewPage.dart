import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/channel/YondorChannel.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class WebViewPageState extends State<WebViewPage> {
  // 标记是否是加载中
  bool _isLoading = true;
  WebViewController _webViewController;
  Size _deviceSize;

  /// 使用javascriptChannels发送消息
  /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toast',
        onMessageReceived: (JavascriptMessage message) {
          showToast(message.message);
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
          body: GestureDetector(
              onTap: () {
                print("onTap");
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Stack(
                children: <Widget>[
                  Container(
                      height: _deviceSize.height,
                      child: WebView(
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
                        javascriptChannels: <JavascriptChannel>[_alertJavascriptChannel(context), _detectxy(context)].toSet(),
                        navigationDelegate: _navigationDelegate,
                        onPageFinished: (String url) {
                          print('@跳转链接: $url');
                          setState(
                                () => _isLoading = false,
                          );
                        },
                      )),
                  _isLoading
                      ? Container(
                    width: _deviceSize.width,
                    height: _deviceSize.height,
                    color: Colors.white,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : Container()
                ],
              )),
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
      }else{
        Navigator.of(context).pop();
      }
      //阻止路由替换；
      return NavigationDecision.prevent;
    }
    //允许路由替换
    print('allowing navigation to $request');
    setState(
      () => _isLoading = true,
    );
    return NavigationDecision.navigate;
  }
  /*
  * 唤醒手机软件
  * @param weixin:// 唤醒微信
  * */
  static goLaunch(BuildContext context,String url) async{
    if(await canLaunch(url)){
      await launch(url);
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

  @override
  void dispose() {
    // 回收相关资源
    super.dispose();
  }
}


