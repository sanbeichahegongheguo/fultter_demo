import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';

class WebViewExample extends StatefulWidget{
  String  url;
  Color color;
  WebViewExample(this.url,{this.color});

  @override
  State<StatefulWidget> createState()=>new NewsWebPageState();

}
class NewsWebPageState extends State<WebViewExample>{
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
  StreamSubscription<WebViewHttpError> _onHttpError;
  StreamSubscription<double> _onProgressChanged;
  StreamSubscription _onDestroy;
  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    onStateChanged = _setOnStateChanged();
    onUrlChanged = _setOnUrlChanged();
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      print('@onDestroy:');
    });
    _onHttpError = flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      print('@onHttpError:${error.code} ${error.url}');
      }
    );
  }
  // 解析WebView中的数据
  void parseResult() {
//    flutterWebViewPlugin.evalJavascript("get();").then((result) {
//      // result json字符串，包含token信息
//
//    });
  }

  @override
  Widget build(BuildContext context) {

    return new WebviewScaffold(
      key: scaffoldKey,
      url:widget.url, // 登录的URL
      withZoom: true,  // 允许网页缩放
      withLocalStorage: true, // 允许LocalStorage
      withJavascript: true, // 允许执行js代码
      hidden: true,
      initialChild: Container(
        child: Center(
          child: Image.asset("images/login/studenthomepage_logp.png",width: MediaQuery.of(context).size.width*0.75,),
        ),
          decoration: BoxDecoration(
            gradient: new LinearGradient(
              begin: const FractionalOffset(0.5, 0.0),
              end: const FractionalOffset(0.5, 1.0),
              colors: <Color>[Colors.lightBlueAccent, Colors.lightBlueAccent],
            ),
          )
      ),
    );
  }

  @override
  void dispose() {
    // 回收相关资源
    // Every listener should be canceled, the same should be done with this stream.
    onUrlChanged.cancel();
    onStateChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  StreamSubscription<WebViewStateChanged> _setOnStateChanged(){
    return flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state){
      print("加载类型 "  + state.type.toString());
      // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
      switch (state.type) {
        case WebViewState.abortLoad:
          break;
        case WebViewState.shouldStart:
        // 准备加载
//          setState(() {
//            loading = true;
//          });
          if ("haxecallback:back" == state.url){
            flutterWebViewPlugin.close();
            Navigator.of(context).pop();
          }else if ("haxecallback:go:h5RegistLogin"==state.url ){
            Navigator.of(context).pop();
          }
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
//          if (isLoadingCallbackPage) {
//            // 当前是回调页面，则调用js方法获取数据
//            parseResult();
//          }
          break;
      }
    });
  }

  StreamSubscription<String> _setOnUrlChanged() {
    return flutterWebViewPlugin.onUrlChanged.listen((String url) {
      print("跳转连接 : "+url);
    });
  }
}