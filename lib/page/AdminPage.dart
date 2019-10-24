import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';


///管理页面
class Admin extends StatefulWidget {
  static const String sName = "admin";

  @override
  State<Admin> createState() {
    return _Admin();
  }
}

class _Admin extends State<Admin> with AutomaticKeepAliveClientMixin<Admin>, SingleTickerProviderStateMixin{
  @override
  initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final heightScreen = MediaQuery.of(context).size.height;
    final widthSrcreen = MediaQuery.of(context).size.width;
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Container(
        decoration: BoxDecoration(
          color: Color(0xFFf0f4f7),

        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom:ScreenUtil.getInstance().getHeightPx(13) ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: new DecorationImage(
                        image: new AssetImage("images/admin/userInfo_bg.png"),
                          alignment:Alignment.bottomRight
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: widthSrcreen,
                          height: ScreenUtil.getInstance().getHeightPx(291),
                          padding: EdgeInsets.symmetric(horizontal: ScreenUtil.getInstance().getWidthPx(81)),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  _getHeadSculpture(store);
                                },
                                child: ClipOval(
                                  child: Stack(children: <Widget>[
                                    isNetwork(store.state.userInfo.headUrl),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: Opacity(
                                          opacity: 0.5,
                                          child: Container(
                                            color: Color(0xFF000000),
                                            width: ScreenUtil.getInstance().getWidthPx(200),
                                            height: ScreenUtil.getInstance().getHeightPx(50),
                                            child: Align(
                                              child: Text("更换头像", style: TextStyle(color: Color(0xFFffffff), fontSize: ScreenUtil.getInstance().getSp(24 / 3)), textAlign: TextAlign.center),
                                              alignment: Alignment.center,
                                            ),
                                          )),
                                    )
                                  ]),
                                ),
                              ),
                              SizedBox(
                                width: ScreenUtil.getInstance().getWidthPx(20),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding:EdgeInsets.symmetric(horizontal:ScreenUtil.getInstance().getWidthPx(52) ),
                                    child: Text(
                                      store.state.userInfo.realName,
                                      style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(64 / 3),fontWeight:FontWeight.w800 ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil.getInstance().getHeightPx(20),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal:ScreenUtil.getInstance().getWidthPx(31),vertical:ScreenUtil.getInstance().getHeightPx(14)  ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFf7f9fb),
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular((10.0))),
                                        ),
                                        child: Text(
                                          store.state.userInfo.schoolName,
                                          style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48 / 3), color: Color(0xFF999999)),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil.getInstance().getWidthPx(25)),
                                        padding: EdgeInsets.symmetric(horizontal:ScreenUtil.getInstance().getWidthPx(31),vertical:ScreenUtil.getInstance().getHeightPx(14)  ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFf7f9fb),
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular((10.0))),
                                        ),
                                        child: Text(
                                          store.state.userInfo.className,
                                          style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48 / 3), color: Color(0xFF999999)),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                      ],
                    )
                ),
                Column(
                  children: <Widget>[
                    _getBt("个人资料与设置", "images/admin/icon_set.png", _goSetUserInfo),
                    _getBt("护眼设置", "images/admin/icon_eye_protection.png", _goSetEye),
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeightPx(20),
                    ),
                    _getBt("退出账号", "images/admin/icon_out.png", (){_goOut(store);}),
                  ],
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  //判断用户是否有头像
  isNetwork(imgUrl) {
    if (imgUrl != null) {
      return CachedNetworkImage(
        imageUrl: imgUrl.toString().replaceAll("fs.k12china-local.com", "192.168.6.30:30781"),
        fit: BoxFit.cover,
        width: ScreenUtil.getInstance().getWidthPx(200),
        height: ScreenUtil.getInstance().getWidthPx(200),
      );
    } else {
      return Image(
        image: AssetImage("images/admin/tx.png"),
        fit: BoxFit.cover,
        width: ScreenUtil.getInstance().getWidthPx(200),
        height: ScreenUtil.getInstance().getWidthPx(200),
      );
    }
  }

//调用相机或本机相册
  Future _getImage(type, store) async {
    File image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera);
    image = await ImageCropper.cropImage(
      sourcePath: image.path,
      androidUiSettings:  AndroidUiSettings(toolbarTitle:"选择图片"),
      aspectRatio:CropAspectRatio(ratioX:1.0,ratioY:1.0),
      maxHeight: 350,
      maxWidth: 350,
    );
    List<int> bytes = await image.readAsBytes();
    var base64encode = base64Encode(bytes);
    print("base64 $base64encode");
    if (base64encode != "" && base64encode != null) {
      String key = await httpManager.getAuthorization();
      String imgtype = "png";
      var dataResult = await UserDao.uploadHeadUrl(base64encode, imgtype);
      if (dataResult.result) {
        UserDao.getUser(isNew: true, store: store);
      } else {}
    }
  }

  //更换头像
  void _getHeadSculpture(store) {
    print("更换头像");
    var widgetMsg = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CommonUtils.buildBtn("拍照", width: ScreenUtil.getInstance().getWidthPx(638), height: ScreenUtil.getInstance().getHeightPx(114), onTap: () {
          ApplicationDao.trafficStatistic(314);
          _photograph(store);
        }),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(54),
        ),
        CommonUtils.buildBtn("从相机获取", width: ScreenUtil.getInstance().getWidthPx(638), height: ScreenUtil.getInstance().getHeightPx(114), onTap: () {
          ApplicationDao.trafficStatistic(314);
          _album(store);
        }),
      ],
    );
    CommonUtils.showEditDialog(context, widgetMsg, height: ScreenUtil.getInstance().getHeightPx(502), width: ScreenUtil.getInstance().getWidthPx(906));
  }

  //拍照
  void _photograph(store) {
    Navigator.pop(context);
    print("拍照");
    _getImage(0, store);
  }

  //相册
  void _album(store) {
    Navigator.pop(context);
    print("相册");
    _getImage(1, store);
  }

  //去个人资料与设置
  void _goSetUserInfo() {
    print("去个人资料与设置");
    ApplicationDao.trafficStatistic(315);
    NavigatorUtil.goUserInfo(context);
  }

  //去护眼
  void _goSetEye() {
    print("去护眼");
    ApplicationDao.trafficStatistic(316);
    NavigatorUtil.goEyeProtectionPage(context);
  }

  //退出賬號
  Future _goOut(store) async {
    print("退出賬號");

    var outMsg= Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text("是否退出当前账号",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(54 / 3)),),
        Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: <Widget>[
            CommonUtils.buildBtn("确定",width:ScreenUtil.getInstance().getWidthPx(300),height:ScreenUtil.getInstance().getHeightPx(114), decorationColor:  Colors.blueAccent,textColor: Colors.white,onTap: (){_sureOnTap(store);}),
            SizedBox(
              width: ScreenUtil.getInstance().getWidthPx(36),
            ),
            CommonUtils.buildBtn("取消",width:ScreenUtil.getInstance().getWidthPx(300),height:ScreenUtil.getInstance().getHeightPx(114),onTap: _cancelOnTap, ),
          ],
        )
      ],
    );
    var isOut = await CommonUtils.showEditDialog(context,outMsg,height: ScreenUtil.getInstance().getHeightPx(400),width: ScreenUtil.getInstance().getWidthPx(906));
    if (isOut!=null&&isOut){
      NavigatorUtil.goWelcome(context);
      showToast("退出成功");
      Future.delayed(Duration(milliseconds:500)).then((_){
        UserDao.logout(store,context);
      });
    }
  }
  //确定
   _sureOnTap(store) async{
     ApplicationDao.trafficStatistic(90);
     Navigator.pop(context,true);
  }

  //取消选择
  void _cancelOnTap(){
    Navigator.pop(context,false);
  }
  _getBt(btName, btImg, btPressed) {
    return MaterialButton(
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Image.asset(
                  btImg,
                  height: ScreenUtil.getInstance().getHeightPx(64),
                  width: ScreenUtil.getInstance().getWidthPx(64),
                ),
                SizedBox(
                  width: ScreenUtil.getInstance().getWidthPx(44),
                ),
                Text(
                  btName,
                  style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(48 / 3), color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.navigate_next,
                  color: Color(0xFFcccccc),
                ),
              ],
            ),
          ),
        ],
      ),
      minWidth: ScreenUtil.getInstance().getWidthPx(963),
      color: Color(0xFFffffff),
      height: ScreenUtil.getInstance().getHeightPx(162),
      onPressed: btPressed,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
