import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/local/local_storage.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/Log.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/LogData.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';
import 'package:flutter_start/common/config/config.dart';

class LoginPage extends StatefulWidget {
  static final String sName = "login";

  final String account;
  final String password;
  LoginPage({this.account, this.password});
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> with SingleTickerProviderStateMixin ,LogBase{
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool loginBtn = false;
  GlobalKey _globalKey = new GlobalKey();
  bool _expand = false;
  List<LoginUser> _users = new List();
  bool _hasdeleteIcon = false;
  String _version = "2.0.000";
  @override
  void dispose() {
    userNameController?.dispose();
    passwordController?.dispose();
    super.dispose();
  }

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

      if (userNameController.text.length >= 6 && passwordController.text.length >= 6) {
        if (this.loginBtn == false) {
          setState(() {
            this.loginBtn = true;
          });
        }
      } else {
        if (this.loginBtn == true) {
          print("else");
          setState(() {
            this.loginBtn = false;
          });
        }
      }
    });
    passwordController.addListener(() {
      if (userNameController.text.length >= 6 && passwordController.text.length >= 6) {
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
    passwordController.text = widget.password;
    if ((null != widget.account && widget.account != "") && (null != widget.password && widget.password != "")) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _login();
      });
    }
    if ((null == widget.account || widget.account == "") && (null == widget.password || widget.password == "")) {
      _gainUsers();
    }
  }

  Widget build(BuildContext context) {
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0xFFf1f2f6),
        appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            //居中显示
            centerTitle: true,
            leading: new IconButton(
                icon: new Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF333333),
                ),
                onPressed: () {
                  NavigatorUtil.goWelcome(context);
                }),
            title: Text(
              '手机密码登录',
              style: TextStyle(color: Color(0xFF333333), fontSize: ScreenUtil.getInstance().getSp(19)),
            )),
        body: GestureDetector(
          onTap: () {
            print("onTap11111");
            FocusScope.of(context).requestFocus(new FocusNode());
            setState(() {
              _expand = false;
            });
          },
          child: Container(
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: 500,
                    child: Flex(direction: Axis.vertical, children: <Widget>[
                      SizedBox(
                        height: ScreenUtil.getInstance().getHeightPx(150),
                      ),
                      Container(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: ScreenUtil.getInstance().getHeightPx(500), maxWidth: ScreenUtil.getInstance().getWidthPx(1000)),
                            child: _getTextField("请输入您的手机号", userNameController, key: _globalKey,obscureText:false),
                          )),
//                      Container(
//                        padding: EdgeInsets.only(left: ScreenUtil.getInstance().getWidthPx(50), right: ScreenUtil.getInstance().getWidthPx(50)),
//                        child: _getTextField("您的手机号", userNameController, key: _globalKey,obscureText: false),
//                      ),
                      Container(
                        padding: EdgeInsets.only(top: ScreenUtil.getInstance().getHeightPx(60)),
                        child: Container(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: ScreenUtil.getInstance().getHeightPx(500), maxWidth: ScreenUtil.getInstance().getWidthPx(1000)),
                              child: _getTextField("您的密码", passwordController, obscureText: true),
                            ))
                      ),
                      SizedBox(
                        height: ScreenUtil.getInstance().getHeightPx(170),
                      ),
                      Container(
                        child: CommonUtils.buildBtn("登录", width: ScreenUtil.getInstance().getWidthPx(846), height: ScreenUtil.getInstance().getHeightPx(135), onTap: () {
                          _login();
                        },
                            splashColor: loginBtn ? Colors.amber : Color(0xFFdfdfeb),
                            decorationColor: loginBtn ? Color(0xFFfbd951) : Colors.grey,
                            textColor: Colors.white,
                            textSize: ScreenUtil.getInstance().getSp(54 / 3),
                            elevation: 2),
                      ),
                      SizedBox(
                        height: ScreenUtil.getInstance().getHeightPx(70),
                      ),
                      GestureDetector(
                        onTap: () {
                          NavigatorUtil.goRePassword(context);
                        },
                        child: Text(
                          "找回密码",
                          style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(54 / 3), decoration: TextDecoration.underline, color: Color(0xFFff6464)),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil.getInstance().getHeightPx(70),
                      ),
//                      GestureDetector(
//                        onTap: () {
//                          NavigatorUtil.goRegester(context);
////                          NavigatorUtil.goBuildArchives(context);
//                        },
//                        child: Text(
//                          "我没有账号",
//                          style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(54 / 3), decoration: TextDecoration.underline, color: Color(0xFF999999)),
//                        ),
//                      ),
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
                                  Text("  ${Config.TITLE}", style: TextStyle(color: Colors.black, fontSize: ScreenUtil.getInstance().getSp(14)))
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
                  child: Material(
                      color:Colors.transparent,
                    child: _buildListView(),
                  ),
                  offstage: !_expand,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  ///getTextField 构建输入框
  TextField _getTextField(String hintText, TextEditingController controller, {bool obscureText, GlobalKey key}) {
    return TextField(
      key: key,
      keyboardType: !obscureText?TextInputType.number:TextInputType.text,
      obscureText: obscureText ?? false,
      controller: controller,
      style: new TextStyle(fontSize: ScreenUtil.getInstance().getSp(20), color: Colors.black,textBaseline:TextBaseline.alphabetic),
      inputFormatters: !obscureText?[WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]:[],
      cursorColor: Color(0xFF333333),
      onTap: () {
        setState(() {
          if (key != null) {
            _expand = !_expand;
          } else {
            _expand = false;
          }
        });
      },
      onChanged: key != null
          ? (input) async {
              _users.clear();
              _users.addAll(await LocalStorage.getUsers());
              setState(() {
                if (input==null || input==""){
                  _users.clear();
                }else{
                  _users.retainWhere((item) => item.username.startsWith(input));
                  if (_users.length==0){
                    _expand = false;
                  }else{
                    _expand = true;
                  }
                }
              });
            }
          : (input) {},
      decoration: new InputDecoration(
        suffixIcon: !obscureText? _hasdeleteIcon
            ? IconButton(
          onPressed: () {
            setState(() {
              userNameController.text = "";
            });
          },
          icon: Icon(
            Icons.cancel,
            color: Color(0xFFcccccc),
          ),
        ) : Text(""):null,
        contentPadding: EdgeInsets.all(13),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: ScreenUtil.getInstance().getSp(16)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        filled: true,
        fillColor: Color(0xFFFFFFFF),
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
              userNameController.text = _users[i].username;
              passwordController.text = _users[i].password;
              _expand = false;
              FocusScope.of(context).requestFocus(new FocusNode());
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
      if (children.length > 0) {
        RenderBox renderObject = _globalKey.currentContext.findRenderObject();
        final position = renderObject.localToGlobal(Offset.zero);
        double screenW = MediaQuery.of(context).size.width;
        double currentW = renderObject.paintBounds.size.width;
        double currentH = renderObject.paintBounds.size.height;
        double margin = (screenW - currentW) / 2;
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
          width: currentW,
          height: (children.length * itemHeight + (children.length - 1) * dividerHeight),
          margin: EdgeInsets.fromLTRB(margin,  currentH + currentH, margin, 0),
        );
      }
    }
    return Container();
  }

  void _gainUsers() async {
    print("_gainUsers");
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

    if (loginBtn) {
      print("用户登录==>_login",level: Log.info);
      CommonUtils.showLoadingDialog(context, text: "登陆中···");
      Store<GSYState> store = StoreProvider.of(context);
      DataResult data = await UserDao.login(userNameController.text, passwordController.text, store);
      Navigator.pop(context);
      if (data.result) {
        showToast("登录成功 ${data.data.realName}");
        LocalStorage.saveUser(LoginUser(userNameController.text, passwordController.text));
        LocalStorage.addNoRepeat(_users, LoginUser(userNameController.text, passwordController.text));
        NavigatorUtil.goHome(context);
      } else {
        setState(() {
          _expand = false;
        });
        if (null != data.data) {
          showToast(data?.data ?? "");
        }
      }
    } else {
      if (userNameController.text.length == 0) {
        showToast("账号不能为空");
      } else if (passwordController.text.length < 6) {
        showToast("密码必须大于6位");
        print("密码必须大于6位");
      }
    }
  }

  @override
  String tagName() {
    return LoginPage.sName;
  }

  void print(msg ,{int level= Log.fine}){
    super.print(msg,level: level);
  }
}
