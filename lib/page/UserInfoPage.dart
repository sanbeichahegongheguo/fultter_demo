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
  var textBook = "RJ版";
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

        child: ListView(
          children: <Widget>[
            Column(
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
                                    isNetwork(_user.headUrl),
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
                          Align(
                            alignment:Alignment.topLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width:ScreenUtil.getInstance().getWidthPx(500),child:Text("${_user.realName} 家长"??"",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48/3)),),),
                                SizedBox(
                                  height: ScreenUtil.getInstance().getHeightPx(19),
                                ),
                                SizedBox(width:ScreenUtil.getInstance().getWidthPx(500),child:Text("账号 ${_user.tUserName}"??"",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(42/3),color: Color(0xFF999999))),),
                              ],
                            ),
                          ),

                        ],
                      ),
                      decoration:BoxDecoration(
//                      color:Color(0xFFfffff),
                        color:Colors.white,
//                      border: new Border.all(color: Color(0xFFa6a6a6)),
                        borderRadius: new BorderRadius.all(Radius.circular((10.0))),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(31),
                ),
                Container(
                  width: ScreenUtil.getInstance().getWidthPx(963),
                  height: ScreenUtil.getInstance().getHeightPx(686),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _getBt("所在学校","images/admin/icon-school.png",null,_user.schoolName??"",2),
                      Container(
                        width:ScreenUtil.getInstance().getWidthPx(903),
                        height:ScreenUtil.getInstance().getHeightPx(3),
                        decoration:new BoxDecoration(
                          color:Color(0xFFf5f5f7),
                        ),
                      ),
                      _getBt("所在班级","images/admin/icon-class.png",_setUserClass,_user.className??"",1),
                      Container(
                        width:ScreenUtil.getInstance().getWidthPx(903),
                        height:ScreenUtil.getInstance().getHeightPx(3),
                        decoration:new BoxDecoration(
                          color:Color(0xFFf5f5f7),
                        ),
                      ),
                      _getBt("我的老师","images/admin/icon-teacher.png",null,_user.tRealName??"",2),
                      Container(
                        width:ScreenUtil.getInstance().getWidthPx(903),
                        height:ScreenUtil.getInstance().getHeightPx(3),
                        decoration:new BoxDecoration(
                          color:Color(0xFFf5f5f7),
                        ),
                      ),
                      _getBt("所选教程","images/admin/icon-course.png",_setTextBook,textBook??"",1),
                      Container(
                        width:ScreenUtil.getInstance().getWidthPx(903),
                        height:ScreenUtil.getInstance().getHeightPx(3),
                        decoration:new BoxDecoration(
                          color:Color(0xFFf5f5f7),
                        ),
                      ),
                      _getBt("跟换手机号码","images/admin/icon-phone.png",()=>{},_user.mobile??"",1),
                    ],
                  ),
                  decoration:BoxDecoration(
//                      color:Color(0xFFfffff),
                    color:Colors.white,
//                      border: new Border.all(color: Color(0xFFa6a6a6)),
                    borderRadius: new BorderRadius.all(Radius.circular((10.0))),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().getHeightPx(54),
                ),
                Container(
                  width: ScreenUtil.getInstance().getWidthPx(963),
                  height: ScreenUtil.getInstance().getHeightPx(438),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _getBt("当前版本","images/admin/icon-edition.png",()=>{},"1.4.100",3),
                      Container(
                        width:ScreenUtil.getInstance().getWidthPx(903),
                        height:ScreenUtil.getInstance().getHeightPx(3),
                        decoration:new BoxDecoration(
                          color:Color(0xFFf5f5f7),
                        ),
                      ),
                      _getBt("清除缓存","images/admin/icon-dele.png",()=>{},"",1),
                      Container(
                        width:ScreenUtil.getInstance().getWidthPx(903),
                        height:ScreenUtil.getInstance().getHeightPx(3),
                        decoration:new BoxDecoration(
                          color:Color(0xFFf5f5f7),
                        ),
                      ),
                      _getBt("更改密码","images/admin/icon-password.png",()=>{},"",1),
                    ],
                  ),
                  decoration:BoxDecoration(
//                      color:Color(0xFFfffff),
                    color:Colors.white,
//                      border: new Border.all(color: Color(0xFFa6a6a6)),
                    borderRadius: new BorderRadius.all(Radius.circular((10.0))),
                  ),
                ),
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
      if(_user.textbookId == 1){
        textBook = "RJ版";
      }else{
        textBook = "BS版";
      };
      print("获取用户信息");
    });
  }
  //判断用户是否有头像
  isNetwork(imgUrl){
    if(imgUrl != null){
      return new Image(
        image:NetworkImage(imgUrl) ,
        fit: BoxFit.cover,width:ScreenUtil.getInstance().getWidthPx(200),height: ScreenUtil.getInstance().getWidthPx(200),
      );
    }else{
      return new Image(
        image:AssetImage("images/admin/tx.png") ,
        fit: BoxFit.cover,width:ScreenUtil.getInstance().getWidthPx(200),height: ScreenUtil.getInstance().getWidthPx(200),
      );
    }
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
    var widget = new Column(
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
  //设置班级
  void _setUserClass(){
    List<Widget> tiles = [];
    for(var i = 0;i<10;i++){
      tiles.add(
        Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0),child:CommonUtils.buildBtn("${i+1}",width:ScreenUtil.getInstance().getWidthPx(638),height:ScreenUtil.getInstance().getHeightPx(114)),)
      );
    }
    var widgetMsg = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tiles,
    );
    var msg = SizedBox(
      width: ScreenUtil.getInstance().getWidthPx(906),
      height: ScreenUtil.getInstance().getHeightPx(600),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: widgetMsg,
      ),
    );
    CommonUtils.showEditDialog(context, msg,height: ScreenUtil.getInstance().getHeightPx(700),width: ScreenUtil.getInstance().getWidthPx(906));
  }
  int _textBookTpye = 1;
  //设置教程
  void _setTextBook(){
    var decorationColor;
    if(textBook == "RJ版"){
      _textBookTpye = 1;
    }else if(textBook == "北师大版"){
      _textBookTpye = 2;
    }
    print(_textBookTpye == 2);
    var widgetMsg =  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CommonUtils.buildBtn("RJ版",onTap: _setTextBookType,width:ScreenUtil.getInstance().getWidthPx(638),height:ScreenUtil.getInstance().getHeightPx(114),decorationColor:Color(_textBookTpye == 1?0xFF9fa5aa:0xFFfbd951),textColor:Color(_textBookTpye == 1?0xFFffffff:0xFFa83530)),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(54),
        ),
        CommonUtils.buildBtn("北师大版",onTap: _setTextBookType,width:ScreenUtil.getInstance().getWidthPx(638),height:ScreenUtil.getInstance().getHeightPx(114),decorationColor:Color(_textBookTpye == 2?0xFF9fa5aa:0xFFfbd951),textColor:Color(_textBookTpye == 2?0xFFffffff:0xFFa83530)),
      ],
    );
    CommonUtils.showEditDialog(context, widgetMsg,height: ScreenUtil.getInstance().getHeightPx(502),width: ScreenUtil.getInstance().getWidthPx(906));
  }
  _setTextBookType(){
    setState((){
    _textBookTpye = _textBookTpye==1?2:1;
    });
     //_textBookTpye = num;
  }
  //type>图片是否显示
  _getBt(btName,btImg,btPressed,btMsg,type){
    var icon;
    switch (type){
      case 1:
        icon = Icon(Icons.navigate_next,color: Color(0xFFcccccc),);
        break;
      case 3:
        icon = Container(
          height: ScreenUtil.getInstance().getHeightPx(49),
          width: ScreenUtil.getInstance().getWidthPx(80),
          margin:new EdgeInsets.fromLTRB(10.0,0,0,0),
          child:
            Align(
                alignment: Alignment.center,
                child:Text("更新",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(26/3),color: Color(0xFFe94049)),)
            ),
          decoration:BoxDecoration(
            color:Colors.white,
            border: new Border.all(color: Color(0xFFe94049)),
            borderRadius: new BorderRadius.all(Radius.circular((5.0))),
          ),
        );
        break;
      default:
        icon = Icon(Icons.navigate_next,color: Color(0xFFffffff),);
        break;
    }
    return  MaterialButton(
      elevation:0,
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
            Container(
              child:Row(
                children: <Widget>[
                  Image.asset(
                    btImg,
                    height: ScreenUtil.getInstance().getHeightPx(55),
                    width: ScreenUtil.getInstance().getWidthPx(55),
                  ) ,
                  SizedBox(
                  width: ScreenUtil.getInstance().getWidthPx(44),
                ),
                  Text(btName,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(48/3),color: Color(0xFF666666)),),
                ],
              ),
            ),
            Container(
              child:Row(
                children: <Widget>[
                  Text(btMsg,style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(38/3),color: Color(0xFFacb3be)),),
                  icon,
                ],
              ),
            ),
          ],
      ),
      minWidth: ScreenUtil.getInstance().getWidthPx(963),
      color: Color(0xFFffffff),
      height:ScreenUtil.getInstance().getHeightPx(131) ,
      onPressed: btPressed,
    );
  }
}