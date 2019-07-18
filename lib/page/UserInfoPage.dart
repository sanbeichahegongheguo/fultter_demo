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
      body: Text("12"),
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
}