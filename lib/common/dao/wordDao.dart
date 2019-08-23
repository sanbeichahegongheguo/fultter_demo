import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/index.dart';

class WordDao{
  ///获取作业列表
  static getParentHomeWorkDataList(int pageNum)async{
    String key = await httpManager.getAuthorization();
    var params = {"key":key,"pageNum":pageNum,"curVersion":"1.4.300"};
    var res = await httpManager.netFetch(Address.getParentHomeWorkDataList(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
    var data = res.data;
    return data;
  }
  ///获取学生本学期做题数和错题数及当天学习时间
  static getStudyData() async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key": key};
      var res = await httpManager.netFetch(Address.getStudyData(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
      var data;
      if (res != null && res.result) {
        var json = res.data;
        if(json["success"]){
          data= StudyData.fromJson(jsonDecode(json["data"])["data"][0]);
          SpUtil.putObject(Config.STUDY_MSG,data);
        }
        return new DataResult(data, true);
      }else{
        return new DataResult(null, false);
      }
    }

    var object = SpUtil.getObject(Config.STUDY_MSG);
    if(null==object){
      return await next();
    }
    StudyData data =  StudyData.fromJson(object);
    DataResult dataResult = new DataResult(data, true, next: next());
    return dataResult;
  }

  ///最新同步作业/口算作业/笔头作业
  static getNewHomeWork() async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key": key,"curVersion":"1.4.10"};
      var res = await httpManager.netFetch(Address.getNewHomeWork(), params, null, new Options(method: "post"), contentType: HttpManager.CONTENT_TYPE_FORM);
      List<ParentHomeWork> list = new List<ParentHomeWork>();
      if (res != null && res.result) {
        var data = res.data;
        if(data["success"]["ok"] == 0){
          if (null!=data["success"]["parentHomeWorkList"] &&data["success"]["parentHomeWorkList"].length > 0){
            print("parentHomeWorkList");
            data["success"]["parentHomeWorkList"].forEach((value){
              list.add(ParentHomeWork.fromJson(value));
            });
          }
          SpUtil.putObjectList(Config.PARENT_HOME,list);
          return DataResult(list, true);
        }else{
          return DataResult(data["message"], false);
        }
      }else{
        return DataResult(null, false);
      }
    }
    List<ParentHomeWork> list = new List<ParentHomeWork>();
    var object = SpUtil.getObjectList(Config.PARENT_HOME);
    print("object $object");
    if(null==object){
      return await next();
    }
    object.forEach((value){
      list.add(ParentHomeWork.fromJson(value)) ;
    });
    DataResult dataResult = new DataResult(list, true, next: next());
    return dataResult;
  }
}