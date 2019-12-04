import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/common/redux/gsy_state.dart';
import 'package:flutter_start/models/UnitData.dart';
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
  ///获取所有单元
  static getSynerrData() async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key": key};
      var res = await httpManager.netFetch(Address.getSynerrData(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
      List<UnitData> list = new List<UnitData>();
      if (res != null && res.result) {
        var data = res.data;
        if(data["code"] == 200){
          if (null!=data["data"]["outData"] ){
            data["data"]["outData"].forEach((value){
              list.add(UnitData.fromJson(value));
            });
          }
          SpUtil.putObjectList(Config.All_UNIT,list);
          return DataResult(list, true);
        }else{
          return DataResult(data["message"], false);
        }
      }else{
        return DataResult(null, false);
      }
    }
    List<UnitData> list = new List<UnitData>();
    var object = SpUtil.getObjectList(Config.All_UNIT);
    print("object $object");
    if(null==object){
      return await next();
    }
    object.forEach((value){
      list.add(UnitData.fromJson(value)) ;
    });
    DataResult dataResult = new DataResult(list, true, next: next());
    return dataResult;
  }

  ///获取高频易错题做到第几题
  static getStudymsgQues() async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key": key,"Type":2};
      var res = await httpManager.netFetch(Address.getStudymsgQues(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);

      if (res != null && res.result) {
        var data = res.data;
        if(data["code"] == 200){
          var isHigthErrorShow = false;
          if (null!=data["data"] ){
//            print("quesAmount++++++++++++++++++==>${data["data"]["quesAmount"]}");
//            print("quesTota++++++++++++++++++l==>${data["data"]["quesTotal"]}");
//            print("rightAmount+++++++++++++==>${data["data"]["rightAmount"]}");
            if(data["data"]["quesAmount"] == data["data"]["quesTotal"] && data["data"]["quesTotal"] == data["data"]["rightAmount"]){
              isHigthErrorShow = true;
            }
          }
          SpUtil.putBool(Config.STUDY_QUES,isHigthErrorShow);
          return DataResult(isHigthErrorShow, true);
        }else{
          return DataResult(data["message"], false);
        }
      }else{
        return DataResult(null, false);
      }
    }
    var bool = SpUtil.getBool(Config.STUDY_QUES);
    print("object bool");
    if(null==bool){
      return await next();
    }
    DataResult dataResult = new DataResult(bool, true, next: next());
    return dataResult;
  }

  ///获取本学期未完成作业数量
  static getParentHomeWorkDataTotal() async{
    next() async {
      String key = await httpManager.getAuthorization();
      var params = {"key": key,"curVersion":"1.3.300"};
      var res = await httpManager.netFetch(Address.getParentHomeWorkDataTotal(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
      if (res != null && res.result) {
        var data = res.data;
        print("获取本学期未完成作业数量===》${data.toString()}");
        if(data["ok"] == 0){
          var _homeNum = 0;
          if(data["data"] != null){
            _homeNum =  data["data"];
          }
          SpUtil.putInt(Config.HOME_NUM,_homeNum);
          return DataResult(_homeNum, true);
        }else{
          return DataResult(data["message"], false);
        }
      }else{
        return DataResult(null, false);
      }
    }
    var homeNum = SpUtil.getInt(Config.HOME_NUM);
    print("object homeNum");
    if(null==homeNum){
      return await next();
    }
    DataResult dataResult = new DataResult(homeNum, true, next: next());
    return dataResult;
  }
}