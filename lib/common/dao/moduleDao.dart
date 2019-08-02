import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/Module.dart';

class ModuleDao {
  static getModule(mapId,config) async {
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"mapId": mapId};
      var res = await httpManager.netFetch(Address.getModule(), params, null, new Options(method: "get"));
      var result;
      if (res != null && res.result) {
        var json = res.data;
        if (!json["success"]) {
          result = json["message"];
          res.result = false;
        }else{
          List<Module> list = new List();
          result = json["data"];
          await SpUtil.putObjectList(config, result);
          result.forEach((value){
            list.add(Module.fromJson(value)) ;
          });
          result = list;
          res.result = true;
        }
      }
      return new DataResult(result, res.result);
    }
    List<Module> list = new List();
    var object = SpUtil.getObjectList(config);
    if(null==object){
      return await next();
    }
    object.forEach((value){
      list.add(Module.fromJson(value)) ;
    });
    DataResult dataResult = new DataResult(list, true, next: next());
    return dataResult;
  }
}