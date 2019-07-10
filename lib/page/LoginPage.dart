import 'package:device_id/device_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getuuid/flutter_getuuid.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/local/local_storage.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/common/utils/packageInfo.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget{
  static final String sName = "login";

  final String  account;
  final String password;
  LoginPage({this.account,this.password});
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> with SingleTickerProviderStateMixin {
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool loginBtn = false ;
  String _version = "1.4.100";
  GlobalKey _globalKey = new GlobalKey();
  bool _expand = false;
  List<LoginUser> _users = new List();
  @override
  void initState() {
    super.initState();

    userNameController.addListener((){
       if (userNameController.text.length>=6&&passwordController.text.length>=6){
         if (this.loginBtn==false) {
           setState(() {
             this.loginBtn = true;
           });
         }
       }else{
         if (this.loginBtn==true){
           print("else");
           setState(() {
             this.loginBtn=false;
           });
         }
       }
    });
    passwordController.addListener((){
       if (userNameController.text.length>=6&&passwordController.text.length>=6){
         if (this.loginBtn==false) {
           setState(() {
             this.loginBtn = true;
           });
         }
       }else{
         if (this.loginBtn==true){
           setState(() {
             this.loginBtn=false;
           });
         }
       }
    });
    userNameController.text = widget.account;
    passwordController.text = widget.password;
    if ((null!=widget.account&& widget.account!="")&& (null!=widget.password&&widget.password!="")){
      Login();
    }
    if ((null==widget.account||widget.account=="") &&(null==widget.password||widget.password=="")){
      _gainUsers();
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
            if (_expand==true){
              _expand = false;
            }
          });
          FocusScope.of(context).requestFocus(new FocusNode());
        },
      child: Container(
        child: Stack(
          overflow:Overflow.visible,
            children: <Widget>[
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: 500,
                  child: Flex(direction: Axis.vertical, children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                              icon:Icon(Icons.arrow_back_ios,color: Colors.blue,),
                              onPressed:(){
                                print("返回logo!");
                                NavigatorUtil.goWelcome(context);
                              }
                          ),
                          InkWell(
                            onTap: (){
                              print("点击操作指南");
                              NavigatorUtil.goWebView(context, "https://api.k12china.com/share/u/operation.html?from=stulogin");
                            },
                            child: Text("操作指南",style: TextStyle(color: Colors.blue, fontSize: 20.0,fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(right: 15,top: 10),
                    ),
                    Container(
                        margin: EdgeInsets.all(25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("登录",style: TextStyle(color: Colors.grey,fontSize: 24),)
                          ],)
                    ),
                    Container(
                      padding: EdgeInsets.only(left: widthSrcreen*0.1,right:widthSrcreen*0.1,top:widthSrcreen*0.05 ),
                      child: getTextField("您的账号/手机号", userNameController,key: _globalKey),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: widthSrcreen*0.1,right:widthSrcreen*0.1,top:widthSrcreen*0.05 ),
                      child: getTextField("您的密码",passwordController,obscureText: true),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: widthSrcreen*0.1,right:widthSrcreen*0.1,top:widthSrcreen*0.05 ),
                      child:Material(
                        //带给我们Material的美丽风格美滋滋。你也多看看这个布局
                        elevation: 10.0,
                        color: Colors.transparent,
                        shape:  const StadiumBorder(),
                        child: InkWell(
                          borderRadius:BorderRadius.all(Radius.circular(50)),
                          onTap: () {
                            Login();
                          },
                          //来个飞溅美滋滋。
                          splashColor: loginBtn?Colors.blueAccent:Colors.grey,
                          child: Ink(
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius:BorderRadius.all(Radius.circular(50)),
                              color: loginBtn?Colors.lightBlueAccent:Colors.grey,
                            ),
                            child: Center(
                              child: Text(
                                '登录',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 20),
                        alignment: AlignmentDirectional.bottomCenter,
                        // ignore: static_access_to_instance_member
                        child: Text("版本号:${Package.instance.version}"),
                      ),
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
              image: DecorationImage(
                  image:AssetImage("images/login/joinclass_bg_bgimg.png"),
                  fit: BoxFit.cover
              )
          ),
        ),
      ),
    );
  }


  ///getTextField 构建输入框
  TextField getTextField(String hintText,TextEditingController controller,{bool obscureText,GlobalKey key}){
    return TextField(
      key: key,
      keyboardType:TextInputType.number,
      obscureText:obscureText??false,
      controller: controller,
      textAlign: TextAlign.center,
      style: new TextStyle(fontSize: 17.0, color: Colors.black),
      onTap:(){
        setState(() {
          if(key!=null) {
            _expand = !_expand;
          }else{
            _expand = false;
          }
        });
      },
      onChanged:key!=null?(input) async {
        _users.clear();
        _users.addAll(await LocalStorage.getUsers());
        setState(() {
          _users.retainWhere((item)=>item.username.startsWith(input));
        });
      }:(input){},
      decoration: new InputDecoration(
        contentPadding: EdgeInsets.all(13),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 15.0),
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        enabledBorder:OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  ///构建历史记录items
  List<Widget> _buildItems() {
    List<Widget> list = new List();
    for (int i = 0; i < _users.length; i++) {
        //增加账号记录
      if (_users[i] != LoginUser(userNameController.text, passwordController.text)) {
        list.add(
            GestureDetector(
              child: Container(
                alignment: AlignmentDirectional.center,
                child: Text(_users[i].username,style:TextStyle(fontSize: 17.0)),
                decoration: BoxDecoration(
                    border:i<(_users.length-1)?Border(bottom: BorderSide(color: Colors.lightBlueAccent,width: 1)):Border()
                ),
              ),
              onTap: () {
                setState(() {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  userNameController.text = _users[i].username;
                  passwordController.text = _users[i].password;
                  _expand = false;
                });
              },
            )
        );
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
        double margin = (screenW - currentW*0.65) / 2;
        double offsetY = position.dy;
        double itemHeight = currentH*0.7;
        double dividerHeight = 1;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.lightBlueAccent, width: 1),left:BorderSide(color: Colors.lightBlueAccent, width: 1),right: BorderSide(color:Colors.lightBlueAccent, width: 1) ),
          ),
          child: ListView(
            itemExtent: itemHeight,
            padding: EdgeInsets.all(0),
            children: children,
          ),
          width: currentW*0.65,
          height: (children.length * itemHeight + (children.length - 1) * dividerHeight),
          margin: EdgeInsets.fromLTRB(margin, offsetY + currentH, margin, 0),
        );
      }
    }
    return Container();
  }
  void _gainUsers() async {
    print(await DeviceInfo.instance.getDeviceId());
    print("platformUid:"+await FlutterGetuuid.platformUid);
    print("DeviceId:"+await DeviceId.getID);
    print("getIMEI:"+await DeviceId.getIMEI);
    print("getMEID:"+await DeviceId.getMEID);
    print("_gainUsers");
    _users.clear();
    _users.addAll(await LocalStorage.getUsers());
    //默认加载第一个账号
    if (_users.length > 0) {
      userNameController.text = _users[0].username;
      passwordController.text = _users[0].password;
    }
  }
  void Login() async{
    if (loginBtn){
      DataResult data = await UserDao.login(userNameController.text,passwordController.text);
        if (data.result){
          Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg:"登录成功 ${data.data.realName}");
          LocalStorage.saveUser(LoginUser(userNameController.text, passwordController.text));
          LocalStorage.addNoRepeat(_users, LoginUser(userNameController.text, passwordController.text));
          NavigatorUtil.goHome(context);
        }else{
          setState(() {
            _expand = false;
          });
          if (null!=data.data){
            Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg:data?.data??"");
          }
        }
    }else{
      if(userNameController.text.length==0){
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "账号不能为空");
      }else if(passwordController.text.length<6){
        Fluttertoast.showToast(gravity:ToastGravity.CENTER,msg: "密码必须大于6位");
        print("密码必须大于6位");
      }
    }
  }

}