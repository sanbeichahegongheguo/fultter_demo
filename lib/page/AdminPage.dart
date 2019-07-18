import 'dart:convert';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/local/local_storage.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/user.dart';
import 'package:image_picker/image_picker.dart';

class Admin extends StatefulWidget{
  @override
  State<Admin> createState() {
    return _Admin();
  }
}
class _Admin extends State<Admin>{
  User _user = new User();
  @override
  initState() {
    super.initState();
    _getUserInfo();
  }
  @override
  Widget build(BuildContext context){
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return  Column(
      children: <Widget>[
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(54),
        ),
        Container(
          width: ScreenUtil.getInstance().getWidthPx(963),
          height: ScreenUtil.getInstance().getHeightPx(357),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: ScreenUtil.getInstance().getWidthPx(44),
              ),
              GestureDetector(
                onTap: (){
                  _getHeadSculpture();
                },
                child:ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(80)),
                child:Stack(
                    children:<Widget>[
                      Image.network(_user.headUrl??"https://c-ssl.duitang.com/uploads/item/201508/28/20150828225753_jJ4Fc.jpeg",fit: BoxFit.cover,width:ScreenUtil.getInstance().getWidthPx(200),height: ScreenUtil.getInstance().getHeightPx(200),),
                      Positioned(
                        bottom:0,
                        left: 0,
                        child: Opacity(opacity: 0.5,child: Container(color: Color(0xFF000000),width:ScreenUtil.getInstance().getWidthPx(200) ,height:ScreenUtil.getInstance().getHeightPx(50), child: Align(child:Text("更换头像",style: TextStyle(color: Color(0xFFffffff),fontSize: ScreenUtil.getInstance().getSp(24/3)),textAlign: TextAlign.center),alignment:Alignment.center,),) ),)
                    ]),
              ),
              ),
              SizedBox(
                width: ScreenUtil.getInstance().getWidthPx(50),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_user.realName??"",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48/3)),),
                  Text(_user.schoolName??"",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(36/3),color: Color(0xFF999999)),),
                  Text(_user.className??"",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(36/3),color: Color(0xFF999999)),),
                ],
              )
            ],
          ),
          decoration:new BoxDecoration(
            color:Color(0xFFfffff),
            border: new Border.all(color: Color(0xFFa6a6a6)),
            borderRadius: new BorderRadius.all(Radius.circular((10.0))),
          ),
        ) ,
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(66),
        ),
        Column(
          children: <Widget>[
            _getBt("个人资料与设置","images/admin/icon_set.png",_goSetUserInfo),
            _getBt("护眼","images/admin/icon_eye_protection.png",_goSetEye),
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(20),
            ),
            _getBt("退出账号","images/admin/icon_out.png",_goOut),
          ],
        ),

      ],

    );

  }
  //获取用户信息
  void _getUserInfo({bool isNew = false}) async{
    String key = await httpManager.getAuthorization();
    var user = await UserDao.getUser(isNew:isNew);
    setState(() {
    _user = user;
      print("获取用户信息");
    });

  }
  //调用相机或本机相册
  Future _getImage(type) async {
    File image = type==1? await ImagePicker.pickImage(source: ImageSource.gallery):await ImagePicker.pickImage(source: ImageSource.camera);
    List<int> bytes = await image.readAsBytes();
    var base64encode = base64Encode(bytes);
    print("base64 $base64encode");
    if(base64encode != ""&& base64encode!=null){
      String key = await httpManager.getAuthorization();
      String imgtype = "png";
      var dataResult = await UserDao.uploadHeadUrl( base64encode, imgtype);
      if(dataResult.result){
        _getUserInfo(isNew:true);
      }
    }

  }

  //更换头像
  void _getHeadSculpture(){
    print("更换头像");
    var widget =  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CommonUtils.buildBtn("拍照",width:ScreenUtil.getInstance().getWidthPx(638),height:ScreenUtil.getInstance().getHeightPx(114),onTap: _photograph),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(54),
        ),
        CommonUtils.buildBtn("从相机获取",width:ScreenUtil.getInstance().getWidthPx(638),height:ScreenUtil.getInstance().getHeightPx(114),onTap: _album),
      ],
    );
    CommonUtils.showEditDialog(context, widget,height: ScreenUtil.getInstance().getHeightPx(502),width: ScreenUtil.getInstance().getWidthPx(906));
  }
  //拍照
  void _photograph(){
    Navigator.pop(context);
    print("拍照");
    _getImage(0);

  }
  //相册
  void _album(){
    Navigator.pop(context);
    print("相册");
    _getImage(1);
  }
  //去个人资料与设置
  void _goSetUserInfo(){
    print("去个人资料与设置");
    NavigatorUtil.goUserInfo(context);
  }
  //去护眼
  void _goSetEye(){
    print("去护眼");
  }
  //退出賬號
  void _goOut(){
    print("退出賬號");
  }
   _getBt(btName,btImg,btPressed){
    return  MaterialButton(
             elevation:0,
             child: Row(
             mainAxisAlignment:MainAxisAlignment.spaceBetween,
             children: <Widget>[
             Row(children: <Widget>[
             Image.asset(
               btImg,
              height: ScreenUtil.getInstance().getHeightPx(64),
              width: ScreenUtil.getInstance().getWidthPx(64),
             ),
             SizedBox(
              width: ScreenUtil.getInstance().getWidthPx(44),
             ),
              Text(btName,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFF333333)),),
             ],),
              Icon(Icons.navigate_next,color: Color(0xFFcccccc),),
             ],
             ),
               minWidth: double.infinity,
               color: Color(0xFFffffff),
               height:ScreenUtil.getInstance().getHeightPx(162) ,
               onPressed: btPressed,
             );
  }
}