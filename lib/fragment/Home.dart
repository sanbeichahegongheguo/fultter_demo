import 'package:flutter/material.dart';
import 'package:flutter_start/fragment/Login.dart';
import 'package:flutter_start/fragment/WebViewPage.dart';
import 'package:flutter_start/fragment/PageRouteHelper.dart';
import 'package:flutter_start/utils/NavigatorUtil.dart';
class HomeWidget extends StatefulWidget{
  static final String sName = "home";
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomeWidget> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 15,top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    InkWell(
                      onTap: (){
                        print("点击操作指南");
                        NavigatorUtil.goWebView(context, "https://api.k12china.com/share/u/operation.html?from=stulogin");
                      },
                      child: Text("操作指南",style: TextStyle(color: Colors.white, fontSize: 20.0,fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                    ),
                ],
              ),
            ),
            Container(
              child: Center(
                child: Image.asset("images/login/studenthomepage_logp.png",width: widthSrcreen*0.75,),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                 InkWell(
                   onTap: (){
                     print("点击登录");
                     NavigatorUtil.goLogin(context);
                   },
                   child: Image.asset("images/login/studenthomepage_btn.png",width: widthSrcreen*0.6,fit: BoxFit.cover,),
                 )
               ],
              ),
            )
          ],
        ),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: const FractionalOffset(0.5, 0.0),
          end: const FractionalOffset(0.5, 1.0),
          colors: <Color>[Colors.blue, Colors.blue],
        ),
      ),
      ),
    );
  }
}