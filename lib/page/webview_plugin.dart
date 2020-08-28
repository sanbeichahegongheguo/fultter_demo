import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
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
import 'package:flutter_start/common/utils/AudioRecorderUtils.dart';
import 'package:flutter_start/common/utils/BannerUtil.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/InappPurchase.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/common/utils/RoomUtil.dart';
import 'package:flutter_start/common/utils/ShareWx.dart';
import 'package:flutter_start/models/index.dart';
import 'package:flutter_start/widget/ShareToWeChat.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker_saver/image_picker_saver.dart' as picker;
import 'package:oktoast/oktoast.dart';
import 'package:orientation/orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';
import 'package:tencent_cos/tencent_cos.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class WebViewPlugin extends StatefulWidget {
  String url;
  Color color;
  final AppBar appBar;
  final int openType;

  WebViewPlugin(this.url, {this.color, this.appBar, this.openType = 1});

  @override
  State<StatefulWidget> createState() => new _WebViewPlugin();
}

class _WebViewPlugin extends State<WebViewPlugin> with WidgetsBindingObserver, LogBase {
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

  StreamSubscription<Null> onBackChanged;
  bool _showAd = false;
  bool _show = true;
  WebviewBloc _webviewBloc = WebviewBloc();
  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();
  bool isReturn = false;
  int _MAX_SIZE = 512000;
  Size _deviceSize;
  //状态 0加载  1加载完成
  int _status = 0;
  Timer _timer;
  //加载超时时间
  Duration _timeoutSeconds = const Duration(seconds: 15);
  //旋转方向
  int orientation;

  InappPurchase _inappPurchase;
  String _productId;
  String _orderId;
  bool paying = false;

  /// 录音插件
  AudioRecorderUtils _audioRecorderUtils = new AudioRecorderUtils();
  @override
  void initState() {
    super.initState();
    onStateChanged = setOnStateChanged();
    onUrlChanged = setOnUrlChanged();
    onBackChanged = setOnBackChanged();
    WidgetsBinding.instance.addObserver(this);
    _checkIosPay();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //前台展示
//        print('应用程序可见并响应用户输入。');
        flutterWebViewPlugin.evalJavascript("window.resumed()");
        break;
      case AppLifecycleState.inactive:
//        print('应用程序处于非活动状态，并且未接收用户输入');
        if (paying) {
          flutterWebViewPlugin.evalJavascript("window.hideLoading()");
        }
        break;
      case AppLifecycleState.paused:
        //后台展示
//        print('用户当前看不到应用程序，没有响应');
        flutterWebViewPlugin.evalJavascript("window.paused()");
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer(_timeoutSeconds, _unload);
    _deviceSize = MediaQuery.of(context).size;
    Store<GSYState> store = StoreProvider.of(context);

    return WillPopScope(
      onWillPop: () async {
        bool can = await flutterWebViewPlugin.canGoBack();
        if (can) {
          flutterWebViewPlugin.evalJavascript("window.backFunc()");
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: WebviewScaffold(
            key: scaffoldKey,
            javascriptChannels: _jsChannels(store),
            url: widget.url, // 登录的URL
            withZoom: true, // 允许网页缩放
            withLocalStorage: true, // 允许LocalStorage
            withJavascript: true, // 允许执行js代码
            bottomNavigationBar: _getStatusWidget(store),
            initialChild: Container(),
            openType: widget.openType,
          ),
        ),
      ),
    );
  }

  Widget _getStatusWidget(store) {
    Widget widget;
    if (_status == 0) {
      //loading
      widget = Container(width: _deviceSize.width, height: _deviceSize.height, color: Colors.white, child: Center(child: CircularProgressIndicator()));
    } else if (_status == 2) {
      //加载失败
      widget = Container(
          width: _deviceSize.width,
          height: _deviceSize.height,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(90), bottom: ScreenUtil.getInstance().getHeightPx(33)),
                  child: Image.asset(
                    "images/study/img-q.png",
                    fit: BoxFit.cover,
                    height: ScreenUtil.getInstance().getHeightPx(332),
                  ),
                ),
                Text(
                  "正在努力加载中···",
                  style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(42 / 3), color: Color(0xFF999999)),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(58)),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    minWidth: ScreenUtil.getInstance().getWidthPx(515),
                    color: Color(0xFF6ed699),
                    height: ScreenUtil.getInstance().getHeightPx(139),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("返回首页", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(54 / 3), color: Color(0xFFffffff))),
                  ),
                ),
              ],
            ),
          ));
    } else if (_showAd && (store.state.application.showBanner == 1 && store.state.application.showH5Banner == 1)) {
      //广告
      widget = StreamBuilder<bool>(
          stream: _webviewBloc.showAdStream,
          initialData: true,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            return snapshot.data
                ? Container(
                    height: ScreenUtil.getInstance().screenWidth / 6.4,
                    width: _deviceSize.width,
                    child: BannerUtil.buildBanner(null, null, bloc: _webviewBloc),
                  )
                : Container(
                    width: 0,
                    height: 0,
                  );
          });
    } else {
      widget = null;
    }
    return widget;
  }

  //加载失败
  _unload() {
    if (_status == 0) {
      setState(() {
        _status = 2;
      });
    }
  }

  @override
  void dispose() {
    print("_WebViewPlugin  dispose   !!!!!");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // 回收相关资源
    // Every listener should be canceled, the same should be done with this stream.
    onUrlChanged?.cancel();
    _audioRecorderUtils?.dispose();
    onStateChanged?.cancel();
    onBackChanged?.cancel();
    flutterWebViewPlugin?.dispose();
    _timer?.cancel();
    if (!paying) {
      _inappPurchase?.close();
    }
  }

  StreamSubscription<Null> setOnBackChanged() {
    return flutterWebViewPlugin.onBack.listen((n) {
      print("OnBackChanged");
      if (!isReturn) {
        isReturn = true;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  StreamSubscription<WebViewStateChanged> setOnStateChanged() {
    return flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      print("加载类型 " + state.type.toString());
      if (Platform.isAndroid) {
        if (state.url.indexOf(':ROTATE') > -1) {
          orientation = 1;
          //是否包含横屏，如果包含，则强制横屏
          print('包含横屏，选择');
          OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
        } else {
          //当前的旋转状态是横屏才进行矫正
          print('不包含横屏，选择竖屏');
          if (orientation == 1) {
            OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
          }
        }
      }

      // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
      switch (state.type) {
        case WebViewState.stopLoad:
          //拦截加载
          print("回调链接: " + state.url);
          if (state.url.startsWith("haxecallback")) {
            if (state.url.indexOf("signed") > -1) {
              print("签到");
              Navigator.of(context).pop("signed");
            } else if (state.url.indexOf("infoPage") > -1) {
              print("消息");
              if (state.url.indexOf("studentApp") > -1) {
                NavigatorUtil.goStudentAppPage(context);
              } else {
                Navigator.of(context).pop("infoPage");
              }
            } else if (state.url.indexOf("open_weixin") > -1) {
              print("打开微信");
              goLaunch(context, "weixin://");
            } else if (state.url.indexOf("haxecallback:tencentAd") > -1) {
              if (state.url != "haxecallback:tencentAd:0") {
                print("tencentAd");
                setState(() {
                  _showAd = true;
                  _webviewBloc.showBanner(_showAd);
                });
              } else {
                setState(() => _showAd = false);
              }
            } else if (state.url.indexOf("webOpenCammera") > -1) {
              var _urlMsg = state.url.split(":?");
              var type = 0;
              if (_urlMsg.length > 1) {
                var msg = Uri.decodeComponent(_urlMsg.last);
                var _urlList = jsonDecode(msg);
                if (_urlList["type"] != null) {
                  type = _urlList["type"];
                }
              }
              _getImage(type, state.url).then((data) {
                print("-----!!!!!!------$data");
                if (ObjectUtil.isEmpty(data) || data["result"] == "fail") {
                  flutterWebViewPlugin.evalJavascript("window.closeCamera()");
                } else {
                  flutterWebViewPlugin.evalJavascript("window.getBackPhoto(" + jsonEncode(data) + ")");
                }
              });
            } else if (state.url.indexOf("webOpenVideo") > -1) {
              print('打开相机-拍摄视频');
              var _urlMsg = state.url.split(":");
              // type: 0 : 录制视频 1：打开相册视频
              var type = 0;
              if (_urlMsg.length > 1) {
                var msg = Uri.decodeComponent(_urlMsg.last);
                // 打开相册的视频
                if (msg == 'album') {
                  type = 1;
                }
              }
              _getVideo(type).then((data) {
                print('暂不执行回调');
              });
            } else if (state.url.indexOf("share_TIMELINE") > -1) {
              print("微信朋友圈分享");
              var _urlMsg = state.url.split(":?")[1];
              _urlMsg = Uri.decodeComponent(_urlMsg);
              var _urlList = jsonDecode(_urlMsg);
              String webPage = _urlList["webPage"]; //分享地址
              String thumbnail = _urlList["thumbnail"]; //缩略图
              String title = _urlList["title"];
              String description = _urlList["description"];
              var share = new ShareWx();
              ShareWx.wxshare(1, webPage, thumbnail, "", title, description);
            } else if (state.url.indexOf("share_OpenMiniProgramModel") > -1) {
              print("打开微信小程序");
              var _urlMsg = state.url.split(":?")[1];
              _urlMsg = Uri.decodeComponent(_urlMsg);
              var _urlList = jsonDecode(_urlMsg);
              String username = _urlList["username"]; //小程序原始ID
              final type = _urlList["type"]; //小程序原始ID
              String path = _urlList["path"] != null ? _urlList["path"] : "";

              ///0  [WXMiniProgramType.RELEASE]正式版
              ///1  [WXMiniProgramType.TEST]测试版
              ///2  [WXMiniProgramType.PREVIEW]预览版
              ShareWx.launchMiniProgram(username, type, path);
            } else if (state.url.indexOf("share_MiniProgramModel") > -1) {
              print("微信小程序分享");
              var _urlMsg = state.url.split(":?")[1];
              _urlMsg = Uri.decodeComponent(_urlMsg);
              var _urlList = jsonDecode(_urlMsg);
              String webPage = _urlList["webPage"]; //分享地址
              String thumbnail = _urlList["thumbnail"]; //缩略图
              String title = _urlList["title"];
              String description = _urlList["description"];
              String userName = _urlList["userName"];
              String path = _urlList["path"];

              String _webPageUrl = webPage;
              String _thumbnail = thumbnail;
              String _title = title;
              String _userName = userName;
              String _path = path;
              String _description = description;
              ShareWx.chatShareMiniProgramModel(_webPageUrl, _thumbnail, _title, _userName, _path, _description);
            } else if (state.url.indexOf("share_SESSION") > -1) {
              print("微信会话分享");
              var _urlMsg = state.url.split(":?")[1];
              _urlMsg = Uri.decodeComponent(_urlMsg);
              var _urlList = jsonDecode(_urlMsg);
              print("微信会话分享 msg: $_urlList");
              String webPage = _urlList["webPage"]; //分享地址
              String thumbnail = _urlList["thumbnail"]; //缩略图
              String title = _urlList["title"];
              String description = _urlList["description"];
              ShareWx.wxshare(0, webPage, thumbnail, "", title, description);
            } else if (state.url.indexOf("share") > -1) {
              print("分享");
              var _urlMsg = state.url.split(":?")[1];
              _urlMsg = Uri.decodeComponent(_urlMsg);
              var _urlList = jsonDecode(_urlMsg);
              String _imagePath = _urlList["webPage"]; //分享地址
              String _thumbnail = _urlList["thumbnail"]; //缩略图
              String _title = _urlList["title"];
              String _description = _urlList["description"];
              var _shareToWeChat = new ShareToWeChat(webPage: _imagePath, thumbnail: _thumbnail, transaction: "", title: _title, description: _description);
              CommonUtils.showGuide(context, _shareToWeChat);
            } else if (state.url.indexOf("ios_pay") > -1) {
              var params = state.url.split(":?")[1];
              var split = params.split("&");
              _productId = "com.yondor.${split[0]}";
              _orderId = split[1];
              _iosPay(_productId);
            } else if (state.url.startsWith("weixin://")) {
              goLaunch(context, state.url);
            } else if (state.url == "haxecallback:logout") {
              print("登录失效 返回登录页面");
              showToast("登录失效,请重新登录");
              NavigatorUtil.goWelcome(context);
              try {
                httpManager.clearAuthorization();
                Store<GSYState> store = StoreProvider.of(context);
                store.dispatch(UpdateUserAction(User()));
                SpUtil.remove(Config.LOGIN_USER);
              } catch (e) {
                print(e);
              }
            } else {
              if (!isReturn) {
                isReturn = true;
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            }
          } else if (state.url.startsWith('appcallback')) {}
          break;
        case WebViewState.abortLoad:
          break;
        case WebViewState.shouldStart:
          // 准备加载
          break;
        case WebViewState.startLoad:
          // 开始加载
          break;
        case WebViewState.finishLoad:
          // 加载完成
          break;
      }
    });
  }

  StreamSubscription<String> setOnUrlChanged() {
    return flutterWebViewPlugin.onUrlChanged.listen((String url) {
      print("跳转连接成功 : " + url);
      if (Platform.isIOS) {
        if (url.indexOf(':ROTATE') > -1) {
          orientation = 1;
          //是否包含横屏，如果包含，则强制横屏
          print('包含横屏，选择');
          OrientationPlugin.setPreferredOrientations([DeviceOrientation.landscapeRight]);
          OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
        } else {
          //当前的旋转状态是横屏才进行矫正
          print('不包含横屏，选择竖屏');
          if (orientation == 1) {
            OrientationPlugin.setPreferredOrientations([DeviceOrientation.portraitUp]);
            OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
          }
        }
      }

      if (_status != 1 || _showAd != false) {
        setState(
          () {
            _timer?.cancel();
            _status = 1;
            if (!url.startsWith(widget.url) && _showAd != false) {
              print("false");
              _showAd = false;
            }
          },
        );
      }
    });
  }

  //调用相机或本机相册
  Future _getImage(type, url) async {
    File image;
    String path;
    Map data = {"result": "success", "path": "", "isSingle": false};
    var param = {};
    param["type"] = 0;
    var result;
    if (true) {
      url = Uri.decodeComponent(url);
      List<String> split = url.split(":");
      if (split.length >= 5) {
        if (split[3] != "") {
          param["msg"] = split[3];
        }
        if (split[4] == "single") {
          param["isSingle"] = true;
          data["isSingle"] = true;
        } else if (split[4] == "staySingle") {
          param["type"] = 1;
        }
      }
      path = await Camera.openCamera(param: param);
      if (ObjectUtil.isEmptyString(path)) {
        data["result"] = "fail";
        return data;
      }
      result = jsonDecode(path);
      data["type"] = result["type"];
    } else {
      //ios 选择图片
      image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (ObjectUtil.isEmpty(image) || ObjectUtil.isEmptyString(image.path)) {
        data["result"] = "fail";
        return data;
      }
    }
    if (Platform.isAndroid) {
      image = await ImageCropper.cropImage(
        sourcePath: image?.path ?? result["path"],
//      toolbarTitle: "选择图片",
        androidUiSettings: AndroidUiSettings(toolbarTitle: "选择图片", lockAspectRatio: false, initAspectRatio: CropAspectRatioPreset.original),
      );
    } else {
      image = new File(image?.path ?? result["path"]);
    }

    //压缩
    if (image != null) {
      int size = (await image.length());
      while (size > _MAX_SIZE) {
        image = await FlutterNativeImage.compressImage(image.path, percentage: 70, quality: 70);
        size = (await image.length());
      }
    }

    if (ObjectUtil.isEmpty(image) || ObjectUtil.isEmptyString(image.path)) {
      data["result"] = "fail";
      return data;
    }
    List<int> bytes = await image.readAsBytes();
    var base64encode = base64Encode(bytes);
    data["data"] = base64encode;
    return data;
  }

  //调用视频或者本机视频
  Future _getVideo(type) async {
    Map data = {"result": "success", "path": ""};
    Uint8List _image;

    File file = type == 1 ? await ImagePicker.pickVideo(source: ImageSource.gallery) : await ImagePicker.pickVideo(source: ImageSource.camera);
    if (ObjectUtil.isEmpty(file) || ObjectUtil.isEmptyString(file.path)) {
      // 拍摄失败
      data["result"] = "fail";
      return data;
    }
    // 压缩
    if (file != null) {
      // 进行压缩，发送给h5响应压缩的进度
      flutterWebViewPlugin.evalJavascript("window.showLoading('视频压缩中...')");
//      final _flutterVideoCompress = FlutterVideoCompress();
//      final compressedVideoInfo = await _flutterVideoCompress.compressVideo(
//        file.path,
//        quality: VideoQuality.DefaultQuality,
//        deleteOrigin: false,
//      );
      final compressedVideoInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
      );
      int size = (await file.length());
      print('压缩前的视频长度为：' + size.toString());
      print('[Compressing Video] done!');
      print('压缩视频后的长度为:' + compressedVideoInfo.filesize.toString());
      print(compressedVideoInfo.file);
      print(compressedVideoInfo.path);
      flutterWebViewPlugin.evalJavascript("window.hideLoading()");
      // 开始上传视频
      //获取md5
      var filemd5 = md5.convert(compressedVideoInfo.file.readAsBytesSync());
      var md5NAme = hex.encode(filemd5.bytes);
      upload(compressedVideoInfo.path, md5NAme);
    }
    print('拍摄视频：' + file.toString());
    return data;
  }

  void upload(path, name) async {
    flutterWebViewPlugin.evalJavascript("window.showLoading('正在处理上传...')");
    var res = await ApplicationDao.uploadSign();
    if (res != null && res.result) {
      var data = res.data;
      var token = data["data"]["data"]["credentials"]["sessionToken"];
      var tmpSecretId = data["data"]["data"]["credentials"]["tmpSecretId"];
      var tmpSecretKey = data["data"]["data"]["credentials"]["tmpSecretKey"];
      var expiredTime = data["data"]["data"]["expiredTime"];
      var dateStrByDateTime = DateUtil.formatDate(DateTime.now(), format: DateFormats.y_mo);
      dateStrByDateTime = dateStrByDateTime.replaceAll("-", "");
      String cosPath = "video/$dateStrByDateTime/$name.mp4";
      TencentCos.uploadByFile("ap-guangzhou", "1253703184", "qlib-1253703184", tmpSecretId, tmpSecretKey, token, expiredTime, cosPath, path);
      TencentCos.setMethodCallHandler(_handleMessages);
    }
  }

  Future<Null> _handleMessages(MethodCall call) async {
    flutterWebViewPlugin.evalJavascript("window.hideLoading()");
    print(call.method);
    print(call.arguments);
    var result = call.arguments;
    //call.method == "onSuccess" || call.method == "onFailed"
    if (call.method == "onProgress") {
      flutterWebViewPlugin.evalJavascript("window.drawProgress( " + jsonEncode(result) + ")");
    } else {
      flutterWebViewPlugin.evalJavascript("window.uploadResult( " + jsonEncode(result) + ")");
    }
  }

  /*
  * 唤醒手机软件
  * @param weixin:// 唤醒微信
  * */
  static goLaunch(BuildContext context, String url) async {
//    await launch(url, forceSafariVC: false, forceWebView: false);
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      String msg = "程序";
      switch (url) {
        case "weixin://":
          msg = "微信";
          break;
      }
      showToast('$msg打开失败', position: ToastPosition.bottom);
    }
  }

  Set<JavascriptChannel> _jsChannels(Store<GSYState> store) {
    return [
      /// 使用javascriptChannels发送消息
      /// javascriptChannels参数可以传入一组Channels，我们可以定义一个_alertJavascriptChannel变量，这个channel用来控制JS调用Flutter的toast功能：
      JavascriptChannel(
          name: 'Toast',
          onMessageReceived: (JavascriptMessage message) {
            showToast(message.message);
          }),
      //打开视频
      JavascriptChannel(
          name: 'OpenVideo',
          onMessageReceived: (JavascriptMessage message) {
            var msg = jsonDecode(message.message);
            if (msg != null) {
//              CommonUtils.showVideo(context, msg["url"]);
              //是否能播放视频
              X5Sdk.canUseTbsPlayer().then((can) {
                flutterWebViewPlugin.evalJavascript("window.backVideo('$can')");
                if (can) {
                  X5Sdk.openVideo(msg["url"], screenMode: msg["screenMode"]);
                }
              });
            }
          }),

      ///加载广告
      JavascriptChannel(
          name: 'LoadAd',
          onMessageReceived: (JavascriptMessage message) {
            setState(() {
              _showAd = true;
              _webviewBloc.showBanner(_showAd);
            });
          }),

      ///保存图片
      JavascriptChannel(
          name: 'SaveImage',
          onMessageReceived: (JavascriptMessage message) async {
            if (ObjectUtil.isEmptyString(message.message)) {
              return;
            }
            final result = await ImageGallerySaver.saveImage(Uint8List.fromList(base64Decode(message.message)), quality: 60, name: Uuid().v4());
            print(result);
            if (!ObjectUtil.isEmptyString(result)) {
              print(result);
              showToast("保存成功");
            }
          }),

      ///新建WebView
      JavascriptChannel(
          name: 'OpenWebView',
          onMessageReceived: (JavascriptMessage message) {
            if (ObjectUtil.isEmptyString(message.message)) {
              return;
            }
            try {
              var msg = jsonDecode(message.message);
              NavigatorUtil.goWebView(context, msg["url"], openType: msg["type"]);
            } catch (e) {
              print(e);
            }
          }),
      JavascriptChannel(
          name: 'GetOpenType',
          onMessageReceived: (JavascriptMessage message) {
            flutterWebViewPlugin.evalJavascript("window.getOpenType('${widget.openType}')");
          }),

      ///打开学生端
      JavascriptChannel(
          name: 'OpenStudent',
          onMessageReceived: (JavascriptMessage message) {
            CommonUtils.openStudentApp();
          }),

      ///打开外部流浪器
      JavascriptChannel(
          name: 'OpenOther',
          onMessageReceived: (JavascriptMessage message) async {
            if (await canLaunch(message.message)) {
              await launch(message.message, forceSafariVC: false, forceWebView: false);
            } else {
              showToast('${message.message}打开失败', position: ToastPosition.bottom);
            }
          }),

      /// 使用手写功能
      JavascriptChannel(
          name: 'Detectxy',
          onMessageReceived: (JavascriptMessage message) async {
            var msg = jsonDecode(message.message);
            print(msg["pos"]);
            var result = await YondorChannel.detectxy(msg["pos"], msg["thickness"], msg["isSave"] ?? store.state.application.detectxySave == 1);
            flutterWebViewPlugin.evalJavascript("window.dx('$result')");
          }),
      JavascriptChannel(
          name: 'GetPlatform',
          onMessageReceived: (JavascriptMessage message) async {
            String platform = "ios";
            if (Platform.isIOS) {
              platform = "ios";
            } else if (Platform.isAndroid) {
              platform = "android";
            }
            flutterWebViewPlugin.evalJavascript("window.platformCall('$platform')");
          }),

      /// 使用手写功能
      JavascriptChannel(
          name: 'OpenCourseware',
          onMessageReceived: (JavascriptMessage message) async {
            var msg = jsonDecode(message.message);
            print("OpenCourseware msg $msg");
            if (ObjectUtil.isEmptyString(msg["catalogZipUrl"]) ||
                ObjectUtil.isEmptyString(msg["className"]) ||
                ObjectUtil.isEmptyString(msg["peTeacherPlanId"]) ||
                msg["peLiveCourseallotId"] == null) {
              print("window.showMsg('#1 参数错误加入房间失败！')", level: Log.info);
              flutterWebViewPlugin.evalJavascript("window.showMsg('#1 参数错误加入房间失败！')");
              return;
            }
            await flutterWebViewPlugin.hide();
            Store<GSYState> store = StoreProvider.of(context);
            _goRoom(store.state.userInfo, msg["catalogZipUrl"], msg["className"], msg["peTeacherPlanId"], msg["peLiveCourseallotId"]);
          }),

      ///结束录音 baizhenfneg2020/8/25
      JavascriptChannel(
          name: "StopAudio",
          onMessageReceived: (JavascriptMessage message) async {
            String audioBase64 = await _audioRecorderUtils.stop();
            print("====================结束录音");
            flutterWebViewPlugin.evalJavascript("window.stopAudio('${audioBase64}')");
          }),
      //开始录音
      JavascriptChannel(
          name: "StartAudio",
          onMessageReceived: (JavascriptMessage message) {
            _audioRecorderUtils.start(message);
            flutterWebViewPlugin.evalJavascript("window.StartRecording()");
          }),
    ].toSet();
  }

  _iosPay(String productId) async {
    print("开始购买！！", level: Log.info);
    flutterWebViewPlugin.evalJavascript("window.showLoading('加载中')");
    //检查是否有漏单
    await _checkIosPay();
    //初始化
    await _initInappPurchase();
    //获取是否有商品
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts([productId]);
    if (ObjectUtil.isEmptyList(items)) {
      print("没有找到商品！！", level: Log.info);
      flutterWebViewPlugin.evalJavascript("window.hideLoading()");
      return;
    }
    paying = true;
    _inappPurchase.pay(productId);
  }

  _initInappPurchase() async {
    if (_inappPurchase == null) {
      _inappPurchase = new InappPurchase();
      await _inappPurchase.init();

      // 更新购买订阅消息
      _inappPurchase.purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
        paying = false;
        print("purchaseUpdatedSubscription 订阅成功！！", level: Log.info);
        flutterWebViewPlugin.evalJavascript("window.hideLoading()");
        var transactionId = productItem.transactionId;
        var receipt = productItem.transactionReceipt;
        Map buyParam = new Map();
        buyParam["transactionId"] = transactionId;
        buyParam["receipt"] = receipt;
        buyParam["orderId"] = _orderId;
        SpUtil.putObject(Config.IOS_PAY_PARAM_KEY, buyParam);
        _validateApplePay(receipt, _orderId, transactionId);
        print("transactionId:$transactionId   receipt:$receipt");
        print('purchase-updated: $productItem');
      });
      // 购买报错订阅消息
      _inappPurchase.purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
        paying = false;
        print('purchase-error: $purchaseError', level: Log.error);
        flutterWebViewPlugin.evalJavascript("window.hideLoading()");
        String msg = "#3 ${purchaseError.code}  ${purchaseError.message}";
        if (purchaseError.code == "E_UNKNOWN") {
          msg = "#4 网络异常，请重试！";
        }
        if (purchaseError.code == "E_USER_CANCELLED") {
          msg = "您已取消！";
        }
        flutterWebViewPlugin.evalJavascript("window.showMsg('$msg')");
      });
      _inappPurchase.conectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
        //开始支付
        print('connected: $connected', level: Log.info);
        flutterWebViewPlugin.evalJavascript("window.hideLoading()");
        flutterWebViewPlugin.evalJavascript("window.showLoading('正在处理')");
      });
    }
  }

  _validateApplePay(String receiptData, String orderId, String transactionId) async {
    var res = await ApplicationDao.iosPay(receiptData, orderId, transactionId);
    if (res != null && !res.result) {
      //检验失败或者超时,重试
      _validateApplePay(receiptData, orderId, transactionId);
      return;
    }
    print("res====>$res");
    if (res != null && res.result) {
      var data = res.data;
      if (data["code"] == 200) {
        print("11111   ${jsonEncode(data["data"])}");
        flutterWebViewPlugin.evalJavascript("window.iosPayCall('${jsonEncode(data["data"])}')");
        if (data["data"]["status"] == 1 || data["data"]["status"] == 3) {
          //1 充值成功 3 已经充值
          print("data==>${data["data"]}");
          await SpUtil.remove(Config.IOS_PAY_PARAM_KEY);
        } else {
          flutterWebViewPlugin.evalJavascript("window.showMsg('#1 处理异常，如已付款请联系客服！')");
        }
      } else {
        flutterWebViewPlugin.evalJavascript("window.showMsg('#2 处理异常，如已付款请联系客服！')");
      }
    }
  }

  _checkIosPay() async {
    print("检查是否 漏单 ！！！！", level: Log.info);
    var param = await SpUtil.getObject(Config.IOS_PAY_PARAM_KEY);
    if (ObjectUtil.isNotEmpty(param)) {
      print(" 漏单了 ！！！！！orderId ${param["orderId"]}", level: Log.error);
      var transactionId = param["transactionId"];
      var receipt = param["receipt"];
      var orderId = param["orderId"];
      await _validateApplePay(receipt, orderId, transactionId);
    }
  }

  @override
  String tagName() {
    return "webview_plugin";
  }

  @override
  void print(msg, {int level = Log.fine}) {
    super.print(msg, level: Log.fine);
  }

  Future _goRoom(User userInfo, String url, var roomName, var roomUuid, var peLiveCourseallotId) async {
    return RoomUtil.goRoomPage(context, url, userInfo.userId, userInfo.realName, roomName, roomUuid, peLiveCourseallotId, callFunc: () {
      flutterWebViewPlugin.show();
    });
  }
}
