import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

///**
/// *WebView
///*/
class WebViewPage extends StatefulWidget {
  final String url;
  final Color color;

  WebViewPage(this.url, {this.color});

  @override
  State<StatefulWidget> createState() => new WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  // 标记是否是加载中
  bool _isLoading = true;
  FocusNode _focusNode = FocusNode();
  TextEditingController _textController;
  WebViewController _webViewController;
  Size _deviceSize;

  /// 使用javascriptChannels发送消息
  /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toast',
        onMessageReceived: (JavascriptMessage message) {
          Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: message.message);
        });
  }

  JavascriptChannel _focus(BuildContext context) {
    return JavascriptChannel(
      name: 'Focus',
      // get notified of focus changes on the input field and open/close the Keyboard.
      onMessageReceived: (JavascriptMessage focus) {
        print(focus.message);
        if (focus.message == 'focus') {
          FocusScope.of(context).requestFocus(_focusNode);
        } else if (focus.message == 'focusout') {
          _focusNode.unfocus();
        }
      },
    );
  }

  JavascriptChannel _inputValue(BuildContext context) {
    return JavascriptChannel(
      name: 'InputValue',
      // get notified of focus changes on the input field and open/close the Keyboard.
      onMessageReceived: (JavascriptMessage value) {
        print("InputValue:"+value.message);
        _textController.value = TextEditingValue(text: value.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return  Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          width: _deviceSize.width,
          height: _deviceSize.height,
          child: Center(
            child: Stack(
              children: <Widget>[
                Container(
                  height: 50,
                  width: _deviceSize.width,
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _textController,
                    onSubmitted: (_) {
//                      _webViewController.evaluateJavascript('''
//                            if (input != null) {
//                              input.submit();
//                            }''');
                      _focusNode.unfocus();
                      _textController.value = TextEditingValue(text: "");
                    },
                    onChanged: (input) {
                      print("onChanged $input");
                      _webViewController.evaluateJavascript('''
                            if (input != null) {
                              input.value = '$input';
                            }''');
                    },
                  ),
                ),
                Container(
                    height: _deviceSize.height,
                    child: WebView(
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        print("打开Webview!");
                        _webViewController = webViewController;
                      },
                      gestureRecognizers: Set()
                        ..add(
                          Factory<VerticalDragGestureRecognizer>(
                                () => VerticalDragGestureRecognizer(),
                          ),
                        ),
                      javascriptChannels: <JavascriptChannel>[
                        _alertJavascriptChannel(context),
                        _focus(context),
                        _inputValue(context)
                      ].toSet(),
                      navigationDelegate: (NavigationRequest request) {
                        if (request.url.startsWith('haxecallback')) {
                          //              showToast('JS调用了Flutter By navigationDelegate');
                          print('@ 回调参数 $request}');
                          Navigator.of(context).pop();
                          //阻止路由替换；
                          return NavigationDecision.prevent;
                        }
                        //允许路由替换
                        print('allowing navigation to $request');
                        _focusNode.unfocus();
                        _textController.value = TextEditingValue(text: "");
                        setState(
                              () => _isLoading = true,
                        );
                        return NavigationDecision.navigate;
                      },
                      onPageFinished: (String url) {
                        print('@跳转链接: $url');
                        _webViewController.evaluateJavascript('''
                                            inputs = document.querySelectorAll("input[type=text]");
                                            inputs.forEach(function(inp) {
                                                let finalInput = inp;
                                                finalInput.addEventListener("focus", function() {
                                                    Focus.postMessage('focus');
                                                    input = finalInput;
                                                    InputValue.postMessage(input.value);
                                               });
                                               finalInput.addEventListener("focusout", function() {
                                                   Focus.postMessage('focusout');
                                                   InputValue.postMessage('');
                                               });
                                          });
                            ''');
                        setState(
                              () => _isLoading = false,
                        );
                      },
                    )
                ),
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
            ),
          ),
        ),

      )),
    );
  }

  ///使用flutter 调用js案例
  Widget jsButton() {
    return FutureBuilder<WebViewController>(builder:
        (BuildContext context, AsyncSnapshot<WebViewController> controller) {
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
