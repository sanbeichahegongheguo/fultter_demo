import 'dart:async';
import 'package:flustars/flustars.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/event/http_error_event.dart';
import 'package:flutter_start/common/event/index.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/widget/CodeWidget.dart';
import 'package:oktoast/oktoast.dart';

class PhoneLoginPage extends StatefulWidget {
  static final String sName = "login";

  final String account;
  final String password;
  PhoneLoginPage({this.account, this.password});
  @override
  State<StatefulWidget> createState() {
    return PhoneLoginState();
  }
}

class PhoneLoginState extends State<PhoneLoginPage> with SingleTickerProviderStateMixin {
  TextEditingController userNameController = new TextEditingController();
  bool loginBtn = false;
  GlobalKey _globalKey = new GlobalKey();
  bool _expand = false;
  bool _hasdeleteIcon = false;
  StreamSubscription _stream;
  bool _AgreementCheck = true;
  int _exitTime = 0;
  @override
  initState() {
    super.initState();
    _initListener();
    userNameController.addListener(() {
      if (userNameController.text == "") {
        setState(() {
          _hasdeleteIcon = false;
        });
      } else {
        setState(() {
          _hasdeleteIcon = true;
        });
      }
      if (userNameController.text.length > 6) {
        if (this.loginBtn == false) {
          setState(() {
            this.loginBtn = true;
          });
        }
      } else {
        if (this.loginBtn == true) {
          setState(() {
            this.loginBtn = false;
          });
        }
      }
    });
    SpUtil.getInstance().then((_) {
      userNameController.text = SpUtil.getString(Config.USER_PHONE);
    });

    if ((null != widget.account && widget.account != "") && (null != widget.password && widget.password != "")) {
      _login();
    }
  }

  @override
  void dispose() {
    super.dispose();
    print("PhoneLoginPage dispose");
    userNameController?.dispose();
    _stream?.cancel();
    _stream = null;
  }

  /// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    if ((DateTime.now().millisecondsSinceEpoch - _exitTime) > 2000) {
      showToast('远大小状元家长：再按一次退出',position:ToastPosition.bottom);
      _exitTime = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return StoreBuilder<GSYState>(builder: (context, store) {
      return WillPopScope(
        onWillPop: () {
          return _dialogExitApp(context);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: GestureDetector(
            onTap: () {
              setState(() {
                if (_expand == true) {
                  _expand = false;
                }
              });
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      child: Flex(direction: Axis.vertical, children: <Widget>[
                        SizedBox(
                          height: ScreenUtil.getInstance().getHeightPx(136),
                        ),
                        Stack(
                          overflow :Overflow.visible,
                          children: <Widget>[
                            Container(
                              child: Image.asset(
                                "images/phone_login/logo.png",
                                width: ScreenUtil.getInstance().getWidthPx(555),
                                height: ScreenUtil.getInstance().getHeightPx(136),
                              ),
                            ),
                        Positioned(
                          top: -37,
                          right:-50,
                          child: Image.asset(
                            "images/phone_login/parent.png",
                            width: ScreenUtil.getInstance().getWidthPx(224),
                          ),
                        )

                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().getHeightPx(70),
                        ),
                        Container(
                          child: Image.asset(
                            "images/phone_login/center.png",
//                            width: ScreenUtil.getInstance().getWidthPx(552),
                            height: ScreenUtil.getInstance().getHeightPx(447),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().getHeightPx(100),
                        ),
                        Container(
                            child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: ScreenUtil.getInstance().getHeightPx(500), maxWidth: ScreenUtil.getInstance().getWidthPx(1000)),
                          child: _getTextField("请输入您的手机号", userNameController, key: _globalKey),
                        )),
                        Container(
                          padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(166), top: ScreenUtil.getInstance().getHeightPx(25)),
                          child: Text("若该手机号未注册，我们会自动为您注册", style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(12), color: Color(0xFFff6464))),
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().getHeightPx(107),
                        ),
                        Container(
                          child: CommonUtils.buildBtn("下一步", width: ScreenUtil.getInstance().getHeightPx(846), height: ScreenUtil.getInstance().getHeightPx(135), onTap: () {
                            _login();
                          }, splashColor: loginBtn ? Colors.amber : Colors.grey, decorationColor: loginBtn ? Color(0xFFfbd951) : Colors.grey, textColor: Colors.white, textSize: 20.0, elevation: 5),
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().getHeightPx(70),
                        ),
                        InkWell(
                          onTap: () {
                            NavigatorUtil.goLogin(context);
                          },
                          child: Text(
                            "使用手机密码登录",
                            style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16), decoration: TextDecoration.underline),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.only(bottom: ScreenUtil.getInstance().getHeightPx(55)),
                              alignment: AlignmentDirectional.bottomCenter,
                              // ignore: static_access_to_instance_member
                              child: Flex(direction: Axis.vertical, mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      "images/phone_login/bottom.png",
                                      fit: BoxFit.scaleDown,
                                      height: ScreenUtil.getInstance().getHeightPx(77),
                                      width: ScreenUtil.getInstance().getWidthPx(77),
                                    ),
                                    Text("  远大小状元家长", style: TextStyle(color: Colors.black, fontSize: ScreenUtil.getInstance().getSp(14)))
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil.getInstance().getHeightPx(20),
                                ),
                                Container(
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: _AgreementCheck ? new Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF5fc589),
                                          size:16.0,
                                        ):new Icon(
                                          Icons.radio_button_unchecked,
                                          color: Color(0xFF5fc589),
                                          size:16.0,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _AgreementCheck = !_AgreementCheck;
                                          });
                                        },
                                      ),
                                      Text.rich(TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "已阅读并同意",
                                              style: TextStyle(
                                                color: Color(0xFF666666),
                                                fontSize: ScreenUtil.getInstance().getSp(11),
                                              ),
                                            ),
                                            TextSpan(
                                              text: "《远大教育用户服务协议》",
                                              style: TextStyle(
                                                color: Color(0xFF5fc589),
                                                fontSize: ScreenUtil.getInstance().getSp(11),
                                              ),
                                              recognizer: TapGestureRecognizer()..onTap = () {
                                                linkTo('education');
                                              },
                                            ),
                                            TextSpan(
                                              text: "与",
                                              style: TextStyle(
                                                color: Color(0xFF666666),
                                                fontSize: ScreenUtil.getInstance().getSp(11),
                                              ),
                                            ),
                                            TextSpan(
                                              text: "《远大教育隐私协议》",
                                              style: TextStyle(
                                                color: Color(0xFF5fc589),
                                                fontSize: ScreenUtil.getInstance().getSp(11),
                                              ),
                                              recognizer: TapGestureRecognizer()..onTap = () {
                                                linkTo('privacy');
                                              },
                                            ),
                                          ]
                                      )),
                                    ],
                                  ),
                                )
                              ])),
                          flex: 2,
                        ),
                      ]),
                    ),
                  ),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: const FractionalOffset(0.5, 0.0),
                  end: const FractionalOffset(0.5, 1.0),
                  colors: <Color>[Color(0xFFcdfdd3), Color(0xFFe2fff0)],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
  //跳转
  void linkTo(where){
    if(where == 'education'){
      NavigatorUtil.goWebView(context, Address.getEducation());
    }else if(where == 'privacy'){
      NavigatorUtil.goWebView(context, Address.getPrivacy());
    }else if(where == 'wxServer'){
      NavigatorUtil.goWebView(context, Address.getWxServer());
    }
  }
  ///getTextField 构建输入框
  TextFormField _getTextField(String hintText, TextEditingController controller, {bool obscureText, GlobalKey key}) {
    return TextFormField(
      key: key,
      keyboardType: TextInputType.phone,
      obscureText: obscureText ?? false,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black,textBaseline:TextBaseline.alphabetic),
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
      decoration: new InputDecoration(
        suffixIcon: _hasdeleteIcon
            ? IconButton(
                onPressed: () {
                  setState(() {
                    userNameController.text = "";
                    _hasdeleteIcon = (userNameController.text.isNotEmpty);
                  });
                },
                icon: Icon(
                  Icons.cancel,
                  color: Color(0xFFcccccc),
                ),
              )
            : Text(""),
        contentPadding: EdgeInsets.all(13),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Color(0xffffffff),
      ),
    );
  }

  void _login() async {
    if(!_AgreementCheck){
      showToast("请先同意协议！");
      return;
    }
    if (!RegexUtil.isMobileSimple(userNameController.text)) {
      showToast("请输入正确的手机号", position: ToastPosition.bottom);
      return;
    }
    CommonUtils.showLoadingDialog(context, text: "验证中···");
    SpUtil.putString(Config.USER_PHONE, userNameController.text);
    DataResult data = await UserDao.checkHaveAccount(userNameController.text, 'P');
    Navigator.pop(context);
    bool isLogin = false;
    int registerState = 2;
    String name = '';
    String head = '';
    int userId;
    if(data.result){
      print('登录状态');
      print(data.data["message"]);
      ///0：存在家长账号，2：已经有135的学生，没有135的家长
      if(data.data["error"]=="0"||data.data["error"]=="2"){
        isLogin = true;
        print('0：存在家长账号，2：已经有135的学生，没有135的家长');
        ///这个手机号没有注册过
      }else if(data.data["error"]=="1"){
        registerState = 1;
        print('这个手机号没有注册过');
        ///已经有135的学生，这个135的学生有136的家长了
      }else if(data.data["error"]=="3"){
        registerState = 3;
        print('已经有135的学生，这个135的学生有136的家长了');
        userId = data.data["ext1"];
        name = data.data["ext2"];
        head = data.data["ext3"];
        ///注册失败
      }else if(data.data["error"]=="4"){
        showToast(data.data["message"]);
      }
      if(data.data["error"]=="0"||data.data["error"]=="2"||data.data["error"]=="1"){
        var isSend = await CommonUtils.showEditDialog(
          context,
          CodeWidget(phone: userNameController.text),
        );
        if (null != isSend && isSend) {
          NavigatorUtil.goRegester(context,isLogin:isLogin,index: 1,userPhone:userNameController.text,registerState:registerState);
        }
      }else{
        NavigatorUtil.goBuildArchives(context,registerState:registerState,index: 2,userPhone:userNameController.text,head:head,name:name,userId:userId);
      }
    }else{
      showToast("网络异常请稍后重试！",position: ToastPosition.bottom);
    }



//    if (loginBtn) {
//      CommonUtils.showLoadingDialog(context, text: "登陆中");
//      DataResult data = await UserDao.login(userNameController.text, passwordController.text);
//      Navigator.pop(context);
//      if (data.result) {
//        showToast("登录成功 ${data.data.realName}");
////        LocalStorage.saveUser(LoginUser(userNameController.text, passwordController.text));
////        LocalStorage.addNoRepeat(_users, LoginUser(userNameController.text, passwordController.text));
//        NavigatorUtil.goHome(context);
//      } else {
////        setState(() {
////          _expand = false;
////        });
//        if (null != data.data) {
//           showToast(data?.data ?? "",position: ToastPosition.bottom);
//        }
//      }
//    }
  }

  void _initListener() {
    _stream = eventBus.on<HttpErrorEvent>().listen((event) {
      print("PhoneLogin eventBus " + event.toString());
      HttpErrorEvent.errorHandleFunction(event.code, event.message, context);
    });
  }
}
