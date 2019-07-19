import 'dart:convert';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';


class UserInfo extends StatefulWidget{
  @override
  State<UserInfo> createState() {
    return _UserInfo();
  }

}
class _UserInfo extends State<UserInfo>{
  User _user = new User();
  @override
  initState() {
    super.initState();
    _getUserInfo();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle:true,
        title: Text("个人中心"),
        backgroundColor: Color(0xFFffffff),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left), //自定义图标
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(

        child: Column(
          children: <Widget>[
            SizedBox(
              height: ScreenUtil.getInstance().getHeightPx(54),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                          child:ClipOval(
                            child: Stack(
                                children:<Widget>[
                                  Image.network(_user.headUrl??"images/admin/tx.png",fit: BoxFit.cover,width:ScreenUtil.getInstance().getWidthPx(200),height: ScreenUtil.getInstance().getWidthPx(200),),
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
                            Text("${_user.realName} 家长"??"",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48/3)),),
                            Text("账号 ${_user.tUserName}",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF999999)))
                          ],
                        )
                      ],
                    ),
                    decoration:BoxDecoration(
//                      color:Color(0xFFfffff),
                      color:Colors.white,
//                      border: new Border.all(color: Color(0xFFa6a6a6)),
                      borderRadius: new BorderRadius.all(Radius.circular((10.0))),
                    ),
                  )
                ],
              ),
          ],
        ),
        decoration:BoxDecoration(
          color:Color(0xFFf0f4f7),
        ),
      ),
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
      }else{
        showToast("更换失败");
      }
    }else{
      showToast("数据错误");
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
}