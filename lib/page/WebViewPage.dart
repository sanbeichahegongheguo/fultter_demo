import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

///**
/// *WebView
///*/
class WebViewPage extends StatefulWidget{
  final String  url;
  final Color color;
  WebViewPage(this.url,{this.color});

  @override
  State<StatefulWidget> createState()=>new WebViewPageState();

}
class WebViewPageState extends State<WebViewPage>{
  // 标记是否是加载中
  bool loading = true;

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  /// 使用javascriptChannels发送消息
  /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toast',
        onMessageReceived: (JavascriptMessage message) {
          showToast(message.message);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
//            _controller = webViewController;
            print("打开Webview!");
            _controller.complete(webViewController);
          },
          javascriptChannels: <JavascriptChannel>[_alertJavascriptChannel(context)].toSet(),
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('haxecallback:back')) {
//              showToast('JS调用了Flutter By navigationDelegate');
              print('@ 回调参数 $request}');
              Navigator.of(context).pop();
              //阻止路由替换；
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            //允许路由替换
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print('@跳转链接: $url');
          },
        );
      }),
//      floatingActionButton: jsButton(),
    );
  }

  ///使用flutter 调用js案例
  Widget jsButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                _controller.future.then((controller) {
                  controller.evaluateJavascript('callJS("visible")').then((result) {

                  });
                });
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