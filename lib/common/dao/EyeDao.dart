import 'package:dio/dio.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/net/api.dart';

class EyeDao {
  //  获取学生已设置护眼时间
  static getEyeshiieldTime() async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key , "from": 'parent'};
    var res = await httpManager.netFetch(AddressUtil.getInstance().getEyeshiieldTime(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var result;
    var data;
    if (res != null && res.result) {
      var json = res.data;
      data = json;
    }
    return data;
  }

  static getStudyTime() async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key , "from": 'parent'};
    var res = await httpManager.netFetch(AddressUtil.getInstance().getStudyTime(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var data;
    if (res != null && res.result) {
      data = res.data;
    }
    return data;
  }

  // 每一分钟存储时间
  static saveStudyTotalTime() async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key , "from": 'parent'};
    var res = await httpManager.netFetch(AddressUtil.getInstance().saveStudyTotalTime(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var data;
    if (res != null && res.result) {
      data = res.data;
    }
    return data;
  }

  // 禁止学习
  static saveForbidTime() async{
    String key = await httpManager.getAuthorization();
    var forbidTime =  (new DateTime.now().millisecondsSinceEpoch / 1000).round();
    print('禁锢的时间为：' + forbidTime.toString());
    var params = {"key": key , "from": 'parent', "forbidTime": forbidTime};
    print(Address.saveForbidTime());
    print(params);
    var res = await httpManager.netFetch(AddressUtil.getInstance().saveForbidTime(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var data;
    if (res != null && res.result) {
      data = res.data;
    }
    return data;
  }

  // 加时时间
  static saveDelayTime(time) async{
    String key = await httpManager.getAuthorization();
    var params = {"key": key , "from": 'parent', "delayTime": time};
    var res = await httpManager.netFetch(AddressUtil.getInstance().saveDelayTime(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var data;
    if (res != null && res.result) {
      data = res.data;
    }
    return data;
  }
}