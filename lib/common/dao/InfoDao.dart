import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/net/result_data.dart';
import 'package:flutter_start/common/redux/user_redux.dart';
import 'package:flutter_start/common/utils/DeviceInfo.dart';
import 'package:flutter_start/models/index.dart';
import 'package:redux/redux.dart';

class InfoDao{
  ///更换教程
  static signReward() async {
    String key = await httpManager.getAuthorization();
    var params = {"key": key};
    var res = await httpManager.netFetch(Address.signReward(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    return res.data;
  }

  ///获取未读取消息总数
  static getUnReadNotice() async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key};
    var res = await httpManager.netFetch(Address.getUnReadNotice(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    return res.data;
  }
}