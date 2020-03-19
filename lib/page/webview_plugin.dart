import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/bloc/WebviewBloc.dart';
import 'package:flutter_start/common/channel/CameraChannel.dart';
import 'package:flutter_start/common/channel/YondorChannel.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/common/utils/BannerUtil.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/index.dart';
import 'package:flutter_start/widget/ShareToWeChat.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker_saver/image_picker_saver.dart' as picker;
import 'package:webview_flutter/X5Sdk.dart';
import 'package:webview_flutter/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:orientation/orientation.dart';

class WebViewPlugin extends StatefulWidget{
  String  url;
  Color color;
  final AppBar appBar;
  final int openType;


  WebViewPlugin(this.url,{this.color,this.appBar,this.openType=1});

  @override
  State<StatefulWidget> createState()=>new _WebViewPlugin();

}
class _WebViewPlugin extends State<WebViewPlugin> with  WidgetsBindingObserver{

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
  WebviewBloc _webviewBloc  =  WebviewBloc();
  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();
  bool isReturn = false;
  int _MAX_SIZE = 512000;
  Size _deviceSize;
  //状态 0加载  1加载完成
  int _status = 0;
  Timer _timer;
  //加载超时时间
  Duration _timeoutSeconds = const Duration(seconds: 7);
  //旋转方向
  int orientation;
  @override
  void initState() {
     super.initState();
     onStateChanged = setOnStateChanged();
     onUrlChanged = setOnUrlChanged();
     onBackChanged = setOnBackChanged();
     WidgetsBinding.instance.addObserver(this);
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
        break;
      case AppLifecycleState.paused:
        //后台展示
//        print('用户当前看不到应用程序，没有响应');
        flutterWebViewPlugin.evalJavascript("window.paused()");
        break;
      case AppLifecycleState.suspending:
//        print('应用程序将暂停。');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer(_timeoutSeconds,_unload);
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
    },child: Scaffold(
        body:SafeArea(
          child:WebviewScaffold(
            key: scaffoldKey,
            javascriptChannels:_jsChannels(store),
            url:widget.url, // 登录的URL
            withZoom: true,  // 允许网页缩放
            withLocalStorage: true, // 允许LocalStorage
            withJavascript: true, // 允许执行js代码
            bottomNavigationBar: _getStatusWidget(store),
            initialChild: Container(),
            openType: widget.openType,
          ),
    ),
    )
    );
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
    }else if(_status ==2){
      //加载失败
      widget = Container(
          width: _deviceSize.width,
          height: _deviceSize.height,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment:MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(90),bottom: ScreenUtil.getInstance().getHeightPx(33)),
                  child: Image.asset("images/study/img-q.png",fit: BoxFit.cover,height:ScreenUtil.getInstance().getHeightPx(332) ,),
                ),
                Text("正在努力加载中···",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF999999)),),
                Container(
                  margin: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().getHeightPx(58)),
                  child:MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    minWidth: ScreenUtil.getInstance().getWidthPx(515),
                    color: Color(0xFF6ed699),
                    height:ScreenUtil.getInstance().getHeightPx(139) ,
                    onPressed: (){Navigator.of(context).pop();},
                    child: Text("返回首页",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(54/3),color: Color(0xFFffffff))),
                  ),
                ),
              ],
            ),
          ));
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
            ):Container(width: 0,height: 0,);
          });
    }else{
      widget = null;
    }
    return widget;
  }

  //加载失败
  _unload(){
    if ( _status == 0 ){
      setState(() {
        _status =2;
      });
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // 回收相关资源
    // Every listener should be canceled, the same should be done with this stream.
    onUrlChanged?.cancel();
    onStateChanged?.cancel();
    onBackChanged?.cancel();
    flutterWebViewPlugin?.dispose();
  }




  StreamSubscription<Null>  setOnBackChanged(){
    return flutterWebViewPlugin.onBack.listen((n){
      print("OnBackChanged");
      if(!isReturn){
        isReturn = true;
        if (Navigator.of(context).canPop()){
          Navigator.of(context).pop();
        }
      }
    });
  }

  StreamSubscription<WebViewStateChanged> setOnStateChanged(){
    return flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state){
      print("加载类型 "  + state.type.toString());

      if(state.url.indexOf(':ROTATE') > - 1){
        //是否包含横屏，如果包含，则强制横屏
        print('包含横屏，选择');
        OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
        orientation = 1;
      }else{
        //当前的旋转状态是横屏才进行矫正
        print('不包含横屏，选择竖屏');
        if(orientation == 1){
          OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
        }
      }
      // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
      switch (state.type) {
        case WebViewState.stopLoad:
          //拦截加载
          print("回调链接: "  + state.url);
          if (state.url.startsWith("haxecallback" )) {
            if(state.url.indexOf("signed")>-1){
              print("签到");
              Navigator.of(context).pop("signed");
            }else if(state.url.indexOf("infoPage")>-1){
              print("消息");
              if(state.url.indexOf("studentApp") > -1){
                NavigatorUtil.goStudentAppPage(context);
              }else{
                Navigator.of(context).pop("infoPage");
              }
            }else if(state.url.indexOf("open_weixin")>-1){
              print("打开微信");
              goLaunch(context,"weixin://");
            }else if(state.url.indexOf("haxecallback:tencentAd")>-1){
              if (state.url != "haxecallback:tencentAd:0"){
                print("tencentAd");
                setState((){
                  _showAd = true;
                  _webviewBloc.showBanner(_showAd);
                });
              }else{
                setState(() =>_showAd = false);
              }
            }else if (state.url.indexOf("webOpenCammera")>-1){
              var _urlMsg = state.url.split(":?");
              var type = 0;
              if(_urlMsg.length>1){
                var msg = Uri.decodeComponent(_urlMsg.last);
                var _urlList = jsonDecode(msg);
                if (_urlList["type"]!=null){
                  type = _urlList["type"];
                }
              }
              _getImage(type,state.url).then((data){
                print("-----!!!!!!------$data");
                if (ObjectUtil.isEmpty(data) || data["result"] == "fail"){
                  flutterWebViewPlugin.evalJavascript("window.closeCamera()");
                }else{
                  flutterWebViewPlugin.evalJavascript("window.getBackPhoto("+jsonEncode(data)+")");
                }
              });
            }else if(state.url.indexOf("share")>-1){
              print("分享");
              var _urlMsg = state.url.split(":?")[1];
              _urlMsg = Uri.decodeComponent(_urlMsg);
              var _urlList = jsonDecode(_urlMsg);
              String _imagePath =  _urlList["webPage"];//分享地址
              String _thumbnail = _urlList["thumbnail"];//缩略图
              String _title =  _urlList["title"];
              String _description =  _urlList["description"];
              var _shareToWeChat =  new ShareToWeChat(webPage:_imagePath,thumbnail:_thumbnail,transaction:"",title: _title,description:_description);
              CommonUtils.showGuide(context, _shareToWeChat);
            }else if(state.url=="haxecallback:logout"){
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
              if(!isReturn){
                isReturn = true;
                if (Navigator.of(context).canPop()){
                  Navigator.of(context).pop();
                }
              }
            }
          }else if(state.url.startsWith('appcallback')){


          }
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
      print("跳转连接成功 : "+url);

      if( _status != 1 ||_showAd != false ){
        setState((){
          _timer?.cancel();
          _status = 1;
          if(!url.startsWith(widget.url) &&_showAd!=false){
            print("false");
            _showAd =false;
          }
        },
        );
      }

    });
  }

  //调用相机或本机相册
  Future _getImage(type,url) async {
    File image;
    String path;
    Map data = {"result":"success","path":"","isSingle":false};
    var param = {};
    param["type"] = 0;
    var result;
    if (Platform.isAndroid){
      url = Uri.decodeComponent(url);
      List<String> split = url.split(":");
      if (split.length>=5){
        if (split[3] !=""){
          param["msg"] = split[3];
        }
        if (split[4] =="single"){
          param["isSingle"] = true;
          data["isSingle"] = true;
        }else if(split[4] =="staySingle") {
          param["type"] = 1;
        }
      }
      path =  await Camera.openCamera(param: param);
      if(ObjectUtil.isEmptyString(path)){
        data["result"] = "fail";
        return data;
      }
      result = jsonDecode(path);
      data["type"] = result["type"];
    }else{
      //ios 选择图片
      image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera,imageQuality:50);
      if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
        data["result"] = "fail";
        return data;
      }
    }
    image = await ImageCropper.cropImage(
      sourcePath: image?.path ?? result["path"],
//      toolbarTitle: "选择图片",
      androidUiSettings:  AndroidUiSettings(toolbarTitle:"选择图片",lockAspectRatio:false,initAspectRatio: CropAspectRatioPreset.original),
    );
    //压缩
    if  (image!=null){
      int size = (await image.length());
      while(size > _MAX_SIZE){
        image = await FlutterNativeImage.compressImage(image.path,percentage:70,quality:70);
        size = (await image.length());
      }
    }


    if (ObjectUtil.isEmpty(image)||ObjectUtil.isEmptyString(image.path)){
      data["result"] = "fail";
      return data;
    }
    List<int> bytes = await image.readAsBytes();
    var base64encode = base64Encode(bytes);
    data["data"] = base64encode;
    return data;
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
  Set<JavascriptChannel> _jsChannels(Store<GSYState> store){
    return  [
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
            if (msg!=null){
//              CommonUtils.showVideo(context, msg["url"]);
              //是否能播放视频
              X5Sdk.canUseTbsPlayer().then((can){
                flutterWebViewPlugin.evalJavascript("window.backVideo('$can')");
                if(can){
                  X5Sdk.openVideo(msg["url"],screenMode:msg["screenMode"]);
                }
              });
            }
          }),
      ///加载广告
      JavascriptChannel(
          name: 'LoadAd',
          onMessageReceived: (JavascriptMessage message) {
            setState((){
              _showAd = true;
              _webviewBloc.showBanner(_showAd);
            } );
          }),
      ///保存图片
      JavascriptChannel(
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
          }),
      ///新建WebView
      JavascriptChannel(
          name: 'OpenWebView',
          onMessageReceived: (JavascriptMessage message) {
            if(ObjectUtil.isEmptyString(message.message)){
              return;
            }
            var msg = jsonDecode(message.message);
            NavigatorUtil.goWebView(context,msg["url"],openType:msg["type"]);
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
            if(await canLaunch(message.message)){
              await launch(message.message, forceSafariVC: false, forceWebView: false);
            }else {
              showToast('${message.message}打开失败',position:ToastPosition.bottom);
            }
          }),
      /// 使用手写功能
      JavascriptChannel(
          name: 'Detectxy',
          onMessageReceived: (JavascriptMessage message) async {
            var msg = jsonDecode(message.message);
            print(msg["pos"]);
            var result = await YondorChannel.detectxy(msg["pos"], msg["thickness"], msg["isSave"]??store.state.application.detectxySave==1);
            flutterWebViewPlugin.evalJavascript("window.dx('$result')");
          })
    ].toSet();
  }
}