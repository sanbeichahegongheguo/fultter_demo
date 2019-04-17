import 'package:flutter/material.dart';
import 'package:flutter_start/fragment/WebViewExample.dart';
class LoginWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginWidget> with SingleTickerProviderStateMixin {
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
                      Navigator.of(context).push(new PageRouteBuilder(
                        pageBuilder: (BuildContext context, _, __) {
                          return new WebViewExample("https://api.k12china.com/share/u/operation.html?from=stulogin",color:Colors.black);
                        },
                      ));
                    },
                    child: Text("操作指南",style: TextStyle(color: Colors.blue, fontSize: 20.0,fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                  ),
                ],
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
    );
  }
}