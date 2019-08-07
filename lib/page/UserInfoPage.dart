import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_start/common/dao/ApplicationDao.dart';
import 'package:flutter_start/common/dao/userDao.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/application_redux.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/common/utils/CommonUtils.dart';
import 'package:flutter_start/common/utils/NavigatorUtil.dart';
import 'package:flutter_start/models/AppVersionInfo.dart';
import 'package:flutter_start/models/user.dart';
import 'package:flutter_start/widget/TextBookWiget.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';

class UserInfo extends StatefulWidget{
  @override
  State<UserInfo> createState() {
    return _UserInfo();
  }

}
class _UserInfo extends State<UserInfo>{
  User _user = new User();
  var textBook = "RJ版";
  AppVersionInfo _versionInfo;
  @override
  initState() {
    super.initState();
    _getUserInfo();
    loadCache();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Store<GSYState> store = StoreProvider.of(context);
      _getAppVersionInfo(store.state.userInfo.userId,store);
    });
  }
  @override
  Widget build(BuildContext context){
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("个人中心"),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xFF333333),//自定义图标
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
                              onTap: () {
                                _getHeadSculpture(store);
                              },
                              child: ClipOval(
                                child: Stack(
                                    children: <Widget>[
                                      isNetwork(store.state.userInfo.headUrl),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Opacity(opacity: 0.5,
                                            child: Container(
                                              color: Color(0xFF000000),
                                              width: ScreenUtil.getInstance()
                                                  .getWidthPx(200),
                                              height: ScreenUtil.getInstance()
                                                  .getHeightPx(50),
                                              child: Align(child: Text("更换头像",
                                                  style: TextStyle(
                                                      color: Color(0xFFffffff),
                                                      fontSize: ScreenUtil
                                                          .getInstance().getSp(
                                                          24 / 3)),
                                                  textAlign: TextAlign.center),
                                                alignment: Alignment
                                                    .center,),)),)
                                    ]),
                              ),
                            ),
                            SizedBox(
                              width: ScreenUtil.getInstance().getWidthPx(50),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: ScreenUtil.getInstance().getWidthPx(
                                        500),
                                    child: Text("${store.state.userInfo.realName} 家长" ?? "",
                                      style: TextStyle(
                                          fontSize: ScreenUtil.getInstance()
                                              .getSp(48 / 3)),),),
                                  SizedBox(
                                    height: ScreenUtil.getInstance()
                                        .getHeightPx(19),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.getInstance().getWidthPx(
                                        500),
                                    child: Text("账号 ${store.state.userInfo.tUserName}" ?? "",
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance()
                                                .getSp(42 / 3),
                                            color: Color(0xFF999999))),),
                                ],
                              ),
                            ),

                          ],
                        ),
                        decoration: BoxDecoration(
//                      color:Color(0xFFfffff),
                          color: Colors.white,
//                      border: new Border.all(color: Color(0xFFa6a6a6)),
                          borderRadius: new BorderRadius.all(
                              Radius.circular((10.0))),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().getHeightPx(31),
                  ),
                  Container(
                    width: ScreenUtil.getInstance().getWidthPx(963),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _getBt("所在学校", "images/admin/icon-school.png", null,
                            store.state.userInfo.schoolName ?? "", 2),
                        Container(
                          width: ScreenUtil.getInstance().getWidthPx(903),
                          height: ScreenUtil.getInstance().getHeightPx(3),
                          decoration: new BoxDecoration(
                            color: Color(0xFFf5f5f7),
                          ),
                        ),
                        _getBt("所在班级", "images/admin/icon-class.png",
                            _setUserClass, store.state.userInfo.className ?? "", 1),
                        Container(
                          width: ScreenUtil.getInstance().getWidthPx(903),
                          height: ScreenUtil.getInstance().getHeightPx(3),
                          decoration: new BoxDecoration(
                            color: Color(0xFFf5f5f7),
                          ),
                        ),
                        _getBt("我的老师", "images/admin/icon-teacher.png", null,
                            store.state.userInfo.tRealName ?? "", 2),
                        Container(
                          width: ScreenUtil.getInstance().getWidthPx(903),
                          height: ScreenUtil.getInstance().getHeightPx(3),
                          decoration: new BoxDecoration(
                            color: Color(0xFFf5f5f7),
                          ),
                        ),
                        _getBt("所选教程", "images/admin/icon-course.png",
                            (){_setTextBook(store);}, store.state.userInfo.textbookId==1?"RJ版":"BS版" ?? "", 1),
                        Container(
                          width: ScreenUtil.getInstance().getWidthPx(903),
                          height: ScreenUtil.getInstance().getHeightPx(3),
                          decoration: new BoxDecoration(
                            color: Color(0xFFf5f5f7),
                          ),
                        ),
                        _getBt(
                            "手机号码", "images/admin/icon-phone.png", (){_resetMobile(store);},
                            store.state.userInfo.mobile ?? "", 1),
                      ],
                    ),
                    decoration: BoxDecoration(
//                      color:Color(0xFFfffff),
                      color: Colors.white,
//                      border: new Border.all(color: Color(0xFFa6a6a6)),
                      borderRadius: new BorderRadius.all(
                          Radius.circular((10.0))),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().getHeightPx(54),
                  ),
                  Container(
                    width: ScreenUtil.getInstance().getWidthPx(963),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _getBt(
                            "当前版本", "images/admin/icon-edition.png", _downldApp,store.state.application.version, 3,store: store),
                        Container(
                          width: ScreenUtil.getInstance().getWidthPx(903),
                          height: ScreenUtil.getInstance().getHeightPx(3),
                          decoration: new BoxDecoration(
                            color: Color(0xFFf5f5f7),
                          ),
                        ),
                        _getBt(
                            "清除缓存", "images/admin/icon-dele.png", _cacheSizeStrOnput, _cacheSizeStr, 1),
                        Container(
                          width: ScreenUtil.getInstance().getWidthPx(903),
                          height: ScreenUtil.getInstance().getHeightPx(3),
                          decoration: new BoxDecoration(
                            color: Color(0xFFf5f5f7),
                          ),
                        ),
                        _getBt(
                            "更改密码", "images/admin/icon-password.png", _goResetPasswordPage, "", 1),
                      ],
                    ),
                    decoration: BoxDecoration(
//                      color:Color(0xFFfffff),
                      color: Colors.white,
//                      border: new Border.all(color: Color(0xFFa6a6a6)),
                      borderRadius: new BorderRadius.all(
                          Radius.circular((10.0))),
                    ),
                  ),
                ],
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Color(0xFFf0f4f7),
          ),
        ),
      );
    });
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
      return CachedNetworkImage(
        imageUrl: imgUrl.toString().replaceAll("fs.k12china-local.com", "192.168.6.30:30781"),
        fit: BoxFit.cover,
        width: ScreenUtil.getInstance().getWidthPx(200),
        height: ScreenUtil.getInstance().getWidthPx(200),
      );
    }else{
      return new Image(
        image:AssetImage("images/admin/tx.png") ,
        fit: BoxFit.cover,width:ScreenUtil.getInstance().getWidthPx(200),height: ScreenUtil.getInstance().getWidthPx(200),
      );
    }
  }
  //调用相机或本机相册
  Future _getImage(type,store) async {
    File image = type == 1 ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickImage(source: ImageSource.camera);
    image = await ImageCropper.cropImage(
      sourcePath: image.path,
      toolbarTitle: "选择图片",
      ratioX: 1.0,
      ratioY: 1.0,
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
      } else {

      }
    }
  }
  //更换手机号
  void _resetMobile(store){
    print("更换手机号");
    NavigatorUtil.goResetMobilePage(context);
  }
  //更改密码
  void _goResetPasswordPage(){
    NavigatorUtil.goResetPasswordPage(context);
  }
  //更换头像
  void _getHeadSculpture(store){
    print("更换头像");
    var widget = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CommonUtils.buildBtn("拍照",width:ScreenUtil.getInstance().getWidthPx(638),height:ScreenUtil.getInstance().getHeightPx(114),onTap: (){_photograph(store);}),
        SizedBox(
          height: ScreenUtil.getInstance().getHeightPx(54),
        ),
        CommonUtils.buildBtn("从相机获取",width:ScreenUtil.getInstance().getWidthPx(638),height:ScreenUtil.getInstance().getHeightPx(114),onTap:(){_album(store);} ),
      ],
    );
    CommonUtils.showEditDialog(context, widget,height: ScreenUtil.getInstance().getHeightPx(502),width: ScreenUtil.getInstance().getWidthPx(906));
  }
  //拍照
  void _photograph(store){
    Navigator.pop(context);
    print("拍照");
    _getImage(0,store);

  }
  //相册
  void _album(store){
    Navigator.pop(context);
    print("相册");
    _getImage(1,store);
  }
  //设置班级
  void _setUserClass(){
    print("设置班级");
    NavigatorUtil.goJoinClassPage(context);
  }
  final List<String> _list= ["RJ版","BS版"];
  //设置教程
  void _setTextBook(store){
    var widgetMsg = new TextBookWiget(textBook:store.state.userInfo.textbookId==1?_list[0]:_list[1]);
    CommonUtils.showEditDialog(context, widgetMsg,height: ScreenUtil.getInstance().getHeightPx(502),width: ScreenUtil.getInstance().getWidthPx(906));
  }
  String _cacheSizeStr = "";
  ///加载缓存
  Future<Null> loadCache() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      double value = await _getTotalSizeOfFilesInDir(tempDir);
      /*tempDir.list(followLinks: false,recursive: true).listen((file){
          //打印每个缓存文件的路径
        print(file.path);
      });*/

      setState(() {
        _cacheSizeStr = _renderSize(value);
        print('临时目录大小: $_cacheSizeStr' );
      });
    } catch (err) {
      print(err);
    }
  }
  ///格式化文件大小
  _renderSize(double value) {
    if (null == value) {
      return 0;
    }
    List<String> unitArr = List()
      ..add('B')
      ..add('K')
      ..add('M')
      ..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }
  /// 递归方式 计算文件的大小
  Future<double> _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    try {
      if (file is File) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        double total = 0;
        if (children != null)
          for (final FileSystemEntity child in children)
            total += await _getTotalSizeOfFilesInDir(child);
        return total;
      }
      return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }
  //清理缓存
  void _clearCache() async {
    //此处展示加载loading
    try {
      Directory tempDir = await getTemporaryDirectory();
      //删除缓存目录
      await delDir(tempDir);
      await loadCache();

      setState(() {
        showToast('清除缓存成功');
        _cacheSizeStr = "0.00B";
        Navigator.pop(context);
      });

    } catch (e) {
      print(e);
      print( '清除缓存失败');
    } finally {
      //此处隐藏加载loading
    }
  }
  ///递归方式删除目录
  Future<Null> delDir(FileSystemEntity file) async {
    try {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          await delDir(child);
        }
      }
      await file.delete();
    } catch (e) {
      print(e);
    }
  }
  _cacheSizeStrOnput(){
    print("清除缓存");
    var outMsg= Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text("确定清除缓存么？",style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(54 / 3)),),
        Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: <Widget>[
            CommonUtils.buildBtn("确定",width:ScreenUtil.getInstance().getWidthPx(300),height:ScreenUtil.getInstance().getHeightPx(114), decorationColor:  Colors.blueAccent,textColor: Colors.white,onTap: (){_clearCache();}),
            SizedBox(
              width: ScreenUtil.getInstance().getWidthPx(36),
            ),
            CommonUtils.buildBtn("取消",width:ScreenUtil.getInstance().getWidthPx(300),height:ScreenUtil.getInstance().getHeightPx(114),onTap:(){Navigator.pop(context);}, ),
          ],
        )
      ],
    );
    var isOut =  CommonUtils.showEditDialog(context,outMsg,height: ScreenUtil.getInstance().getHeightPx(400),width: ScreenUtil.getInstance().getWidthPx(906));
  }
  //type>图片是否显示
  _getBt(btName,btImg,btPressed,btMsg,type,{Store<GSYState> store}){
    var icon;
    switch (type){
      case 1:
        icon = Icon(Icons.navigate_next,color: Color(0xFFcccccc),);
        break;
      case 3:
        icon = store.state.application.canUpdate ? Container(
          height: ScreenUtil.getInstance().getHeightPx(49),
          width: ScreenUtil.getInstance().getWidthPx(80),
          margin:new EdgeInsets.fromLTRB(10.0,0,0,0),
          child:Align(
                alignment: Alignment.center,
                child:Text("更新",style: TextStyle(fontSize:ScreenUtil.getInstance().getSp(26/3),color: Color(0xFFe94049)),)
            ),
          decoration:BoxDecoration(
            color:Colors.white,
            border: new Border.all(color: Color(0xFFe94049)),
            borderRadius: new BorderRadius.all(Radius.circular((5.0))),
          ),
        ):Icon(Icons.navigate_next,color: Colors.white);
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
      minWidth: ScreenUtil.getInstance().getWidthPx(800),
      color: Color(0xFFffffff),
      height:ScreenUtil.getInstance().getHeightPx(131) ,
      onPressed: btPressed,
    );
  }

  _getAppVersionInfo(userId,Store<GSYState> store){
    ApplicationDao.getAppVersionInfo(userId, store).then((data){
      if (null!=data&&data.result){
        _versionInfo = data.data;
        if (_versionInfo.ok==0){
            store.dispatch(RefreshApplicationAction(store.state.application.copyWith(canUpdate:_versionInfo.isUp==1?true:false)));
        }
      }
    });
  }

  _downldApp(){
    if (null!=_versionInfo && _versionInfo.isUp!=1){
      showToast("当前已是最新版本");
    }else{
      CommonUtils.showUpdateDialog(context, _versionInfo);
    }
  }

}