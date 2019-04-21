import 'package:flutter/material.dart';
import 'package:flutter_start/utils/HttpUtils.dart';
import 'package:flutter_start/utils/NavigatorUtil.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

class LoginPage extends StatefulWidget{

  static final String sName = "login";
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> with SingleTickerProviderStateMixin {
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool loginBtn = false ;

  @override
  void initState() {
    super.initState();
    userNameController.addListener((){
       if (userNameController.text.length>=11&&passwordController.text.length>=6){
         setState(() {
           this.loginBtn=true;
         });
       }
    });
    passwordController.addListener((){
       if (userNameController.text.length>=11&&passwordController.text.length>=6){
         setState(() {
           this.loginBtn=true;
         });
       }
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding:false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          alignment: Alignment.center,
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 15,top: 10),
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon:Icon(Icons.arrow_back_ios,color: Colors.blue,),
                        onPressed:(){
                          print("返回logo!");
                          NavigatorUtil.goLogo(context);
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("登录",style: TextStyle(color: Colors.grey,fontSize: 24),)
                ],
              ),
              Container(
                  padding: EdgeInsets.only(left: widthSrcreen*0.1,right:widthSrcreen*0.1,top:widthSrcreen*0.05 ),
                  child: getTextField("您的账号/手机号", userNameController)
              ),
              Container(
                padding: EdgeInsets.only(left: widthSrcreen*0.1,right:widthSrcreen*0.1,top:widthSrcreen*0.05 ),
                child: getTextField("您的密码",passwordController,obscureText: true),
              ),
              Container(
                padding: EdgeInsets.only(left: widthSrcreen*0.1,right:widthSrcreen*0.1,top:widthSrcreen*0.05 ),
                child:
                Material(
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
  TextField getTextField(String hintText,TextEditingController controller,{bool obscureText}){
    return TextField(
      keyboardType:TextInputType.number,
      obscureText:obscureText??false,
      controller: controller,
      textAlign: TextAlign.center,
      style: new TextStyle(fontSize: 17.0, color: Colors.black),
      decoration: new InputDecoration(
        contentPadding: EdgeInsets.all(12),
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

  void Login(){
    if (loginBtn){

    }else{
      if(userNameController.text.length==0){
        showToast("账号不能为空");
      }else if(passwordController.text.length<6){
        showToast("密码必须大于6位");
        print("密码必须大于6位");
      }
    }
  }
}