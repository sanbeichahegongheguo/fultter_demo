import 'package:dio/dio.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:flutter_start/common/dao/daoResult.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/net/api.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/models/replayData.dart';

class RoomDao {
  static roomEntry(params) async {
    Map<String, dynamic> header = {"Authorization": "Basic ${Config.AGORA_AUTH}"};
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomEntry(Config.APP_ID), params, header, Options(method: "POST"),
        contentType: HttpManager.CONTENT_TYPE_JSON);
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  static room(String roomId, String token) async {
    Map<String, dynamic> header = {"Authorization": "Basic ${Config.AGORA_AUTH}", "token": token};
    var res = await httpManager.netFetch(AddressUtil.getInstance().room(Config.APP_ID, roomId), null, header, Options(method: "GET"));
    var result;
    if (res != null && res.result) {
      if (res.data["msg"] == "Success") {
        result = RoomData.fromJson(res.data["data"]);
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  static roomBoard(String roomId, String token) async {
    Map<String, dynamic> header = {"Authorization": "Basic ${Config.AGORA_AUTH}", "token": token};
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomBoard(Config.APP_ID, roomId), null, header, Options(method: "GET"));
    var result;
    if (res != null && res.result) {
      if (res.data["msg"] == "Success") {
        result = res.data;
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  static getCourseRecordBy(String recordId, String roomId, String token) async {
    Map<String, dynamic> header = {"Authorization": "Basic ${Config.AGORA_AUTH}", "token": token};
    var res = await httpManager.netFetch(AddressUtil.getInstance().getCourseRecordBy(Config.APP_ID, recordId, roomId), null, header, Options(method: "GET"));
    var result;
    if (res != null && res.result) {
      if (res.data["msg"] == "Success") {
        result = res.data;
        var recordStatus = ['recording', 'finished', 'finished_recording_to_be_download', 'finished_download_to_be_convert', 'finished_convert_to_be_upload'];
        var teacherRecord;
        if (res.data["data"]["recordDetails"] != null) {
          teacherRecord = (res.data["data"]["recordDetails"] as List).firstWhere((element) {
            return element["role"] == 1;
          });
        }
        CourseRecordData courseRecordData = CourseRecordData(
          startTime: res.data["data"]["startTime"],
          endTime: res.data["data"]["endTime"],
          url: teacherRecord != null ? teacherRecord["url"] : "",
          status: res.data["data"]["status"],
          statusText: recordStatus[res.data["data"]["status"]],
        );
        result = courseRecordData;
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  static roomChat(String roomId, String token, String msg) async {
    var params = {
      "message": msg,
      "type": 1,
    };
    Map<String, dynamic> header = {"Authorization": "Basic ${Config.AGORA_AUTH}", "token": token};
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomChat(Config.APP_ID, roomId), params, header, Options(method: "POST"),
        contentType: HttpManager.CONTENT_TYPE_JSON);
    var result;
    if (res != null && res.result) {
      if (res.data["msg"] == "Success") {
        result = res.data;
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  static appCheck() async {
    var res = await httpManager.netFetch("https://www.yondor.cn/stu_app/v1/admin/application", null, null, Options(method: "post"),
        contentType: HttpManager.CONTENT_TYPE_FORM, noTip: true);
    var result;
    if (res != null && res.result) {
      var json = res.data;
      if (null != json) {
        result = json;
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, result != null);
  }

  ///举手
  static roomCoVideo(String roomId, String token, CoVideoType type) async {
    print("roomCoVideo ==$roomId==$token===$type==>");
    Map<String, dynamic> params = {
      "type": type.index + 1,
    };
    Map<String, dynamic> header = {"Authorization": "Basic ${Config.AGORA_AUTH}", "token": token};
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomCoVideo(Config.APP_ID, roomId), params, header, Options(method: "POST"),
        contentType: HttpManager.CONTENT_TYPE_JSON);
    var result;
    if (res != null && res.result) {
      if (res.data["msg"] == "Success") {
        result = res.data;
      } else {
        res.result = false;
      }
    }
    return new DataResult(result, res.result);
  }

  ///领取星星
  static rewardStar(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomRewardStar(), params, null, new Options(method: "post"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  static isRewardStar(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomRewardStar(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  static getUserStar(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().getUserStar(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  static isDoQues(params) async {
    var res =
        await httpManager.netFetch(AddressUtil.getInstance().isDoQues(), params, null, new Options(method: "get"), contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///题目前三答题
  static quesTop(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomQuesTop(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///排行榜
  static roomRankList(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomRankList(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///星星排行榜
  static roomStarRankList(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomStarRankList(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///排行榜
  static roomRankUser(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomRankUser(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///星星排行榜
  static roomStarRankUser(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomStarRankUser(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///保存题目
  static saveQues(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().roomSaveQues(), params, null, new Options(method: "post"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///保存题目
  static saveQuesToQlib(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().saveQuesToQlib(), params, null, new Options(method: "post"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      result = res.data;
    }
    return new DataResult(result, res.result);
  }

  ///保存题目
  static getReplayInfo(params) async {
    var res = await httpManager.netFetch(AddressUtil.getInstance().getReplayInfo(), params, null, new Options(method: "get"),
        contentType: HttpManager.CONTENT_TYPE_FORM);
    print("res==>$res");
    var result;
    if (res != null && res.result) {
      if (res.data["code"] == 200) {
        if (res.data["data"] != null) {
          ReplayData replayData = ReplayData.fromJson(res.data["data"]);
          result = replayData;
        }
      }
    }
    return new DataResult(result, res.result);
  }
}

enum CoVideoType {
  APPLY, // student apply co-video
  REJECT, //teacher reject apply
  CANCEL, //student cancel apply
  ACCEPT, //teacher accept apply
  ABORT, //teacher abort co-video
  EXIT //student exit co-video
}
