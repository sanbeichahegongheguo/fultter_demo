import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/Adver.dart';

import 'daoResult.dart';


class AdDao{
  ///获取Banner广告
  static getAppRevScreenAdver(type) async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key":key,"type":type};
      var res = await httpManager.netFetch(Address.getAppRevScreenAdver(), params, null, Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
      var result;
      if (res != null && res.result) {
        var json = res.data;
        if(json["success"]["ok"]==0){
          result = Adver.fromJson(json["success"]);
          await SpUtil.putObject(Config.ADVER_KEY, result);
          res.result = true;
        }else if(json["success"]["ok"]==402){
          SpUtil.remove(Config.ADVER_KEY);
          result = null;
          res.result = true;
        }else{
          result = res.data["success"]["message"];
          res.result = false;
        }
      }
      return new DataResult(result, res.result);
    }
    var object = SpUtil.getObject(Config.ADVER_KEY);
    if(null==object){
      return await next();
    }
    var adver = Adver.fromJson(object);
    DataResult dataResult = new DataResult(adver, true, next: next());
    return dataResult;
  }
}
