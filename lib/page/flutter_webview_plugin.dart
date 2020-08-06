import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewExample extends StatefulWidget{
  String  url;
  Color color;
  final AppBar appBar;
  WebViewExample(this.url,{this.color,this.appBar});

  @override
  State<StatefulWidget> createState()=>new _WebViewExample();

}
class _WebViewExample extends State<WebViewExample>{

  // 标记是否是加载中
  bool loading = true;
  //颜色
  Color color;
  // 标记当前页面是否是我们自定义的回调页面
  bool isLoadingCallbackPage = false;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  // URL变化监听器
  StreamSubscription<String> onUrlChanged;
  // WebView加载状态变化监听器
  StreamSubscription<WebViewStateChanged> onStateChanged;
  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
     super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
          await flutterWebViewPlugin.goBack();
          return Future.value(false);
      },
      child: Scaffold(
          appBar: widget.appBar??null,
          body:SafeArea(
            child: WebviewScaffold(
              key: scaffoldKey,
              url:widget.url, // 登录的URL
              withZoom: true,  // 允许网页缩放
              withLocalStorage: true, // 允许LocalStorage
              withJavascript: true, // 允许执行js代码
              hidden: true,
            ),
          )
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // 回收相关资源
    // Every listener should be canceled, the same should be done with this stream.
    onUrlChanged?.cancel();
    onStateChanged?.cancel();
    flutterWebViewPlugin?.dispose();
  }

  StreamSubscription<WebViewStateChanged> setOnStateChanged(){
    return flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state){
      print("加载类型 "  + state.type.toString());
      // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
      switch (state.type) {
        case WebViewState.stopLoad:
          //拦截加载

          break;
        case WebViewState.abortLoad:
          break;
        case WebViewState.shouldStart:
        // 准备加载
//          setState(() {
//            loading = true;
//          });
//          if ("haxecallback:back" == state.url){
//            flutterWebViewPlugin.hide();
//            Navigator.of(context).pop();
//          }
          break;
        case WebViewState.startLoad:
        // 开始加载
//          setState(() {
//            loading = true;
//          });
          break;
        case WebViewState.finishLoad:
        // 加载完成
//          setState(() {
//            loading = false;
//          });
          if (isLoadingCallbackPage) {
            // 当前是回调页面，则调用js方法获取数据
          }
          break;
      }
    });
  }

  StreamSubscription<String> setOnUrlChanged() {
    return flutterWebViewPlugin.onUrlChanged.listen((String url) {
      print("跳转连接 : "+url);
    });
  }
}