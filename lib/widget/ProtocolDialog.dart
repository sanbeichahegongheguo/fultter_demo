import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:oktoast/oktoast.dart';



class ProtocolDialog extends StatefulWidget {
  ProtocolDialog({Key key}):super(key: key);

  @override
  _ProtocolDialogState createState() => _ProtocolDialogState();
}

class _ProtocolDialogState extends State<ProtocolDialog> {

  bool _AgreementCheck = false;

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var _maxContentHeight = min(screenSize.height - 300, 180.0);
    return Material(
        type: MaterialType.transparency,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: screenSize.height > screenSize.width ? 265 : 370,
                  decoration: ShapeDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      )),
                  child: Column(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                        child: Center(
                            child: new Text('温馨提示',
                                style: new TextStyle(
                                  color: Color(0xFF364b71),
                                  fontSize: ScreenUtil.getInstance().getSp(54/3),
                                  fontWeight: FontWeight.w600,
                                )))),
                   ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: _maxContentHeight),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                            RichText(text:TextSpan(
                                text: "感谢您下载并使用",
                                style: TextStyle(color: Color(0xFF9ba8b9),fontSize: ScreenUtil.getInstance().getSp(38/3)),
                                children: [
                                  TextSpan(
                                    text:  "远大小状元",
                                  ),
                                  TextSpan(
                                      text: "我们非常重视您的个人信息和隐私保护。"
                                  )
                                ]
                            ),),
                            Text("为了更好的保障您的权益，请您认真阅读《用户协议》和《隐私协议》的全部内容，同意并接受全部条款后开始使用我们的产品和服务。",style: TextStyle(color: Color(0xFF9ba8b9 ),fontSize: ScreenUtil.getInstance().getSp(38/3)),),
                          ],),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Container(
                        height: 1.0 /
                            MediaQueryData.fromWindow(window).devicePixelRatio,
                        color: Color(0xffC0C0C0),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: _maxContentHeight),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: SingleChildScrollView(
                          child: _bottom(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
                      child: SizedBox(
                        width: 170,
                        height: 40,
                        child: RaisedButton(
                            child: Text(
                              "继续",
                              style: TextStyle(color: Color(0xdfffffff)),
                            ),
                            color: _AgreementCheck?Color(0xff3cc1ff):Colors.grey,
                            onPressed: () {
                              _next();
                            },
                            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                      ),
                    ),
                  ])),
            ]));
  }

 Widget _bottom(){
   return Container(
   child: new Column(
     mainAxisAlignment: MainAxisAlignment.start,
     crossAxisAlignment: CrossAxisAlignment.start,
     children: <Widget>[
       Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[
           SizedBox(
           height:ScreenUtil.getInstance().getWidth(20),
           width: ScreenUtil.getInstance().getWidth(20),
           child:  IconButton(
             alignment :Alignment.centerLeft,
             padding:EdgeInsets.all(0),
             iconSize:16.0,
             icon: _AgreementCheck ? new Icon(
               Icons.check_circle,
               color: Color(0xFF3cc1ff),
               size:ScreenUtil.getInstance().getSp(38/3),
             ):new Icon(
               Icons.radio_button_unchecked,
               color: Color(0xFF3cc1ff),
               size:ScreenUtil.getInstance().getSp(38/3),
             ),
             onPressed: () {
               setState(() {
                 _AgreementCheck = !_AgreementCheck;
               });
             },
           ),
         ),
         Expanded(child: RichText(
             text:TextSpan(
                  style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(38/3), color: Color(0xFF9ba8b9),),
                 children: [
                   TextSpan(
                     text: "已阅读并同意",
                   ),
                   TextSpan(
                     text: "《用户协议》",
                     style: TextStyle(
                       color: Color(0xFF3cc1ff),
                     ),
                     recognizer: TapGestureRecognizer()..onTap = () {
                       linkTo('education');
                     },
                   ),
                   TextSpan(
                     text: "与",
                   ),
                   TextSpan(
                     text: "《隐私协议》",
                     style: TextStyle(
                       color: Color(0xFF3cc1ff),
                     ),
                     recognizer: TapGestureRecognizer()..onTap = () {
                       linkTo('privacy');
                     },
                   ),
                   TextSpan(
                     text: "条款内容。",
                   ),
                 ]
             )),),
       ],),
     ],
   ),);

  }
  void _next(){
    if(!_AgreementCheck){
      showToast("请先同意协议！");
      return;
    }
    Navigator.pop(context);
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
}
