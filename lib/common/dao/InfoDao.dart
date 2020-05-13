import 'package:dio/dio.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/net/api.dart';

class InfoDao{
  ///更换教程
  static signReward() async {
    String key = await httpManager.getAuthorization();
    var params = {"key": key};
    var res = await httpManager.netFetch(AddressUtil.getInstance().signReward(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    return res.data;
  }

  ///获取未读取消息总数
  static getUnReadNotice() async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key};
    var res = await httpManager.netFetch(AddressUtil.getInstance().getUnReadNotice(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    return res.data;
  }
}