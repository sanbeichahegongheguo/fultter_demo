import 'package:flustars/flustars.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_start/common/local/local_storage.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/widget/CodeWidget.dart';
import 'package:package_info/package_info.dart';

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
  TextEditingController passwordController = new TextEditingController();
  bool loginBtn = false;
  GlobalKey _globalKey = new GlobalKey();
  bool _expand = false;
  List<LoginUser> _users = new List();
  String _version = "2.0.000";
  bool _hasdeleteIcon = false;
  @override
  void initState() {
    super.initState();

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
    userNameController.text = widget.account;
    passwordController.text = "123456";
    if ((null != widget.account && widget.account != "") && (null != widget.password && widget.password != "")) {
      _login();
    }
    if ((null == widget.account || widget.account == "") && (null == widget.password || widget.password == "")) {
//      _gainUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return Scaffold(
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
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Center(
                child: Container(
                  alignment: Alignment.center,
                  child: Flex(direction: Axis.vertical, children: <Widget>[
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(136),
                    ),
                    Container(
                      child: Image.asset(
                        "images/phone_login/logo.png",
                        width: ScreenUtil.getInstance().getWidthPx(555),
                        height: ScreenUtil.getInstance().getHeightPx(136),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(70),
                    ),
                    Container(
                      child: Image.asset(
                        "images/phone_login/center.png",
                        width: ScreenUtil.getInstance().getWidthPx(542),
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
                      alignment: Alignment.centerLeft,
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
                        "使用帐号密码登录",
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[Text("Copyright © Yondor.All Rights Reserved.", style: TextStyle(color: Color(0xFF666666), fontSize: ScreenUtil.getInstance().getSp(11)))],
                            )
                          ])),
                      flex: 2,
                    ),
                  ]),
                ),
              ),
              Offstage(
                child: _buildListView(),
                offstage: !_expand,
              ),
            ],
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
    );
  }

  ///getTextField 构建输入框
  TextFormField _getTextField(String hintText, TextEditingController controller, {bool obscureText, GlobalKey key}) {
    return TextFormField(
      key: key,
      keyboardType: TextInputType.phone,
      obscureText: obscureText ?? false,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black),
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

  ///构建历史记录items
  List<Widget> _buildItems() {
    List<Widget> list = new List();
    for (int i = 0; i < _users.length; i++) {
      //增加账号记录
      if (_users[i] != LoginUser(userNameController.text, passwordController.text)) {
        list.add(GestureDetector(
          child: Container(
            alignment: AlignmentDirectional.center,
            child: Text(_users[i].username, style: TextStyle(fontSize: 17.0)),
            decoration: BoxDecoration(border: i < (_users.length - 1) ? Border(bottom: BorderSide(color: Colors.lightBlueAccent, width: 1)) : Border()),
          ),
          onTap: () {
            setState(() {
              FocusScope.of(context).requestFocus(new FocusNode());
              userNameController.text = _users[i].username;
              passwordController.text = _users[i].password;
              _expand = false;
            });
          },
        ));
      }
    }
    return list;
  }

  ///构建历史账号ListView
  Widget _buildListView() {
    if (_expand) {
      List<Widget> children = _buildItems();
      if (children.length > 0 && _globalKey != null && _globalKey.currentContext != null) {
        RenderBox renderObject = _globalKey.currentContext.findRenderObject();
        final position = renderObject.localToGlobal(Offset.zero);
        double screenW = MediaQuery.of(context).size.width;
        double currentW = renderObject.paintBounds.size.width;
        double currentH = renderObject.paintBounds.size.height;
        double margin = (screenW - currentW * 0.65) / 2;
        double offsetY = position.dy;
        double itemHeight = currentH * 0.7;
        double dividerHeight = 1;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(color: Colors.lightBlueAccent, width: 1), left: BorderSide(color: Colors.lightBlueAccent, width: 1), right: BorderSide(color: Colors.lightBlueAccent, width: 1)),
          ),
          child: ListView(
            itemExtent: itemHeight,
            padding: EdgeInsets.all(0),
            children: children,
          ),
          width: currentW * 0.65,
          height: (children.length * itemHeight + (children.length - 1) * dividerHeight),
          margin: EdgeInsets.fromLTRB(margin, offsetY + currentH, margin, 0),
        );
      }
    }
    return Container();
  }

  void _gainUsers() async {
    print("_gainUsers");
    var deviceId = await DeviceInfo.instance.getDeviceId();
    print("deviceId $deviceId");
    PackageInfo info = await PackageInfo.fromPlatform();
    _version = info.version;
    _users.clear();
    _users.addAll(await LocalStorage.getUsers());
    //默认加载第一个账号
    if (_users.length > 0) {
      userNameController.text = _users[0].username;
      passwordController.text = _users[0].password;
    }
  }

  void _login() async {
    CommonUtils.showEditDialog(
      context,
      CodeWidget(phone: userNameController.text),
    );

//    if(!RegexUtil.isMobileSimple(userNameController.text)){
//      showToast("请输入正确的手机号",position: ToastPosition.bottom);
//      return;
//    }
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
}
