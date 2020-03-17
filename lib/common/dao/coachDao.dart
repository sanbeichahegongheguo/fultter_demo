import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/CoachNotice.dart';

class CoachDao {
  static getNotice() async {
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"type": "6"};
      print(Address.indexNotice());
      var res = await httpManager.netFetch(Address.indexNotice(), params, null, new Options(method: "get"));
      var result;
      print('嘻嘻嘻');
      print(res.data);
      if (res != null && res.result) {
        var json = res.data;
        if (!json["success"]) {
          result = json["message"];
          res.result = false;
        }else{
          List<CoachNotice> list = new List();
          result = json["data"];
          await SpUtil.putObjectList(Config.indexNotice, result);
          result.forEach((value){
            list.add(CoachNotice.fromJson(value)) ;
          });
          result = list;
          res.result = true;
        }
      }
      return new DataResult(result, res.result);
    }
    List<CoachNotice> list = new List();
    var object = SpUtil.getObjectList(Config.indexNotice);
    if(null==object){
      return await next();
    }
    object.forEach((value){
      list.add(CoachNotice.fromJson(value)) ;
    });
    DataResult dataResult = new DataResult(list, true, next: next());
    return dataResult;
  }
  ///获取可查看课程
  static getMainLastCourse() async {
      next() async {
        String key = await httpManager.getAuthorization();
        var params = {key:key};
        var res = await httpManager.netFetch(Address.getMainLastCourse(), params, null, new Options(method: "get"));
        print(res.data);
        var result;
        var json = res.data;
        if (!json["success"]) {
          result = json["message"];
          res.result = false;
        }else{
          result = jsonEncode(json["data"]);
          await SpUtil.putString(Config.mainLastCourse, result);
          result = result;
          res.result = true;
        }
        return new DataResult(result, res.result);
      }
      var str = SpUtil.getString(Config.mainLastCourse);
      if(null==str){
        return await next();
      }
      DataResult dataResult = new DataResult(str, true, next: next());
      return dataResult;
    }
}