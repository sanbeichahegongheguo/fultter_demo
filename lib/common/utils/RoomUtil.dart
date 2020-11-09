import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_start/common/net/address_util.dart';
import 'package:flutter_start/common/utils/ping.dart';
import 'package:flutter_start/models/Courseware.dart';
import 'package:flutter_start/models/Room.dart';
import 'package:flutter_start/provider/room.dart';
import 'package:flutter_start/widget/progress_loding.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_start/common/dao/RoomDao.dart';
import 'Log.dart';
import 'NavigatorUtil.dart';
import 'package:archive/archive.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class RoomUtil {
  static String tag = "RoomUtil";
  static String mp4Url = "https://qrescdn.k12china.com/qlib/mp4/2020/10/13/17/1317135054.mp4";
  static String mp4Path = "qlib/mp4/2020/10/13/17/1317135054.mp4";
  static String qresCdnHost = "qrescdn.k12china.com";
  static String qresHost = "qres.k12china.com";
  static goRoomPage(BuildContext context,
      {String url,
      int userId,
      String userName,
      String roomName,
      String roomUuid,
      int peLiveCourseallotId,
      Function callFunc,
      String recordId,
      String yondorRecordId,
      DateTime startTime,
      DateTime endTime}) async {
    var bool = await _handleCameraAndMic();
    if (!bool) {
      showToast("权限不足无法进入房间!");
      await openAppSettings();
      if (callFunc != null) {
        callFunc();
      }
      return;
    }
    ProgressProvider progressProvider = ProgressProvider();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChangeNotifierProvider<ProgressProvider>.value(value: progressProvider, child: ProgressLoading());
        });
    joinAgoraRoom(Courseware courseware) async {
      print("room_page@initState loadCoursePack finsh load course");
      LogUtil.v("courseware data == ${courseware.toString()}");

      var params = {
        "roomName": roomName,
        "roomUuid": roomUuid,
        "userName": userName,
        "userUuid": userId,
        "role": 2,
        "type": 2,
      };
      //进入房间
      var res = await RoomDao.roomEntry(params);
      if (!res.result) {
        showToast("网络异常,请稍后重试");
        Navigator.pop(context);
        return;
      }
      if (res.data["msg"] != "Success") {
        showToast("网络异常,请稍后重试");
        Navigator.pop(context);
        return;
      }
      print('请求接口数据成功');
      print(res);
      //获取房间信息
      var userToken = res.data["data"]["userToken"];
      var roomId = res.data["data"]["roomId"];
      res = await RoomDao.room(roomId, userToken);
      if (!res.result) {
        showToast("网络异常,请稍后重试");
        Navigator.pop(context);
        return;
      }
      RoomData roomData = res.data;
      roomData.startTime = startTime;
      roomData.endTime = endTime;
      roomData.courseware = courseware;
      roomData.liveCourseallotId = peLiveCourseallotId;
      //判断是否回放
      if (recordId != null && recordId != "") {
        //获取回放信息
        print("getCourseRecordBy param $recordId $roomId $userToken");
        var courseRecorReuslt = await RoomDao.getCourseRecordBy(recordId, roomId, userToken);
        roomData.courseRecordData = courseRecorReuslt.data;
      } else if (yondorRecordId != null && yondorRecordId != "") {
        //获取远大回放
        print("getCourseRecordBy param $recordId $roomId $userToken");
        var courseRecorReuslt = await RoomDao.getYondorCourseRecordBy(yondorRecordId, roomId, userToken);
        roomData.courseRecordData = courseRecorReuslt.data;
      }
      //获取房间白板信息
      var roomBoard = await RoomDao.roomBoard(roomId, userToken);
      roomData.boardId = roomBoard.data["data"]["boardId"];
      roomData.boardToken = roomBoard.data["data"]["boardToken"];
      Navigator.pop(context);
      print("roomboard $roomBoard");
      NavigatorUtil.goRoomPage(context, data: roomData, userToken: userToken, isReplay: roomData.courseRecordData != null).then((_) {
        if (callFunc != null) {
          callFunc();
        }
      });
    }

    joinYondorRoom(Courseware courseware) async {
      print("room_page@initState loadCoursePack finsh load course");
      LogUtil.v("courseware data == ${courseware.toString()}");

      var params = {
        "roomName": roomName,
        "roomUuid": roomUuid,
        "userName": userName,
        "userUuid": userId,
        "role": 2,
        "type": 2,
      };
      //进入房间
      var res = await RoomDao.yondorRoomEntry(params);
      if (!res.result) {
        showToast("网络异常,请稍后重试");
        Navigator.pop(context);
        return;
      }
      if (res.data["code"] != 200) {
        showToast("网络异常,请稍后重试");
        Navigator.pop(context);
        return;
      }
      print('请求接口数据成功');
      print(res);
      //获取房间信息
      var userToken = res.data["data"]["userToken"];
      var roomId = res.data["data"]["roomId"];
      res = await RoomDao.yondorRoom(roomId);
      if (!res.result) {
        showToast("网络异常,请稍后重试");
        Navigator.pop(context);
        return;
      }
      RoomData roomData = res.data;
      roomData.startTime = startTime;
      roomData.endTime = endTime;
      roomData.courseware = courseware;
      roomData.liveCourseallotId = peLiveCourseallotId;
      //判断是否回放
      if (recordId != null && recordId != "") {
        //获取回放信息
        print("getCourseRecordBy param $recordId $roomId $userToken");
        var courseRecorReuslt = await RoomDao.getCourseRecordBy(recordId, roomId, userToken);
        roomData.courseRecordData = courseRecorReuslt.data;
      } else if (yondorRecordId != null && yondorRecordId != "") {
        //获取远大回放
        print("getCourseRecordBy param $recordId $roomId $userToken");
        var courseRecorReuslt = await RoomDao.getYondorCourseRecordBy(yondorRecordId, roomId, userToken);
        roomData.courseRecordData = courseRecorReuslt.data;
      }
      //获取房间白板信息
      var roomBoard = await RoomDao.yondorRoomBoard(roomId);
      roomData.boardId = roomBoard.data["data"]["boardId"];
      roomData.boardToken = roomBoard.data["data"]["boardToken"];
      Navigator.pop(context);
      print("roomboard $roomBoard");
      NavigatorUtil.goRoomPage(context, data: roomData, userToken: userToken, isReplay: roomData.courseRecordData != null).then((_) {
        if (callFunc != null) {
          callFunc();
        }
      });
    }

    loadCoursePack(url, joinAgoraRoom, (msg) {
      print(msg);
      showToast("加载资源失败,请重试!!");
      if (callFunc != null) {
        callFunc();
      }
    }, progress: (val) {
      progressProvider.setProgress(val);
    });
  }

  static Future<bool> _handleCameraAndMic() async {
    var can = true;
    var list = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ];
    if (Platform.isAndroid) {
      list.add(Permission.phone);
    }
    Map<Permission, PermissionStatus> statuses = await list.request();
    statuses.forEach((permission, status) {
      print("$permission     status $status");
      if (!status.isGranted) {
        can = false;
      }
    });
    return can;
  }

  static loadCoursePack(String url, Function success, Function fail, {progress: Function}) async {
    // print("GlobalConfig@loadCoursePack  ${uri.scheme}://${uri.host}:${uri.port}${uri.path} ");
    var resUrl = url;
    Log.f("url=$resUrl", tag: tag);
    var name = url.substring(url.lastIndexOf("/") + 1, url.length);
    Log.f("name=$name", tag: tag);
    var path = "";
    if (url.contains(".com/")) {
      path = url.substring(url.indexOf(".com/") + 5, url.lastIndexOf("/"));
    } else if (url.contains(".cn/")) {
      path = url.substring(url.indexOf(".cn/") + 4, url.lastIndexOf("/"));
    }
    Log.f("path=$path", tag: tag);

    // await getTemporaryDirectory(); //pc
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    Log.f("tempPath=$tempPath", tag: tag);
    var directory = "$tempPath/$path";
    var filePath = "$tempPath/$path/$name";
    var mp4FilePath = "$tempPath/$mp4Path";

    Log.f("savePath=$filePath", tag: tag);
    Log.f("mp4FilePath=$mp4FilePath", tag: tag);
    var contentLength = -1;
    var offline = false;
    var mp4ContentLength = -1;
    var mp4Offline = false;
    await Dio(BaseOptions(sendTimeout: 5)).head(resUrl).then((value) {
      value.headers.forEach((name, values) {
        if (name.toLowerCase() == "content-length") {
          print(" content-length=$values");
          contentLength = int.parse(values[0]);
        }
      });
    }).catchError((error) {
      //offline
      offline = true;
      fail("@loadCoursePack error:$error use offline mode.");
      return;
    });

    await Dio(BaseOptions(sendTimeout: 5)).head(mp4Url).then((value) {
      value.headers.forEach((name, values) {
        if (name.toLowerCase() == "content-length") {
          print("mp4 content-length=$values");
          mp4ContentLength = int.parse(values[0]);
        }
      });
    }).catchError((error) {
      //offline
      mp4Offline = true;
      fail("@loadCoursePack error:$error use offline mode. mp4");
      return;
    });

    bool match = false;
    bool mp4Match = false;
    //not exist file.
    if (File(filePath).existsSync()) {
      print("exist files");
      var size = await File(filePath).length();
      // print("size=$size");
      if (size == contentLength) {
        match = true;
      } else {
        print("@loadCoursePack Error: file size not match contentLength($contentLength) != $size ");
      }
    }

    if (File(mp4FilePath).existsSync()) {
      print("exist files");
      var size = await File(mp4FilePath).length();
      // print("size=$size");
      if (size == mp4ContentLength) {
        mp4Match = true;
      } else {
        print("@loadCoursePack Error: file size not match contentLength($contentLength) != $size  mp4");
      }
    }

    // print("match=$match");
    var progressNum = 0.0;
    if (!offline && !match) {
      //网络检测
      try {
        final command = PingCommand.create();
        print("11111k12china.com  ");
        var pingSettings = PingSettings(timeout: 2, packetSize: 1024);
        final now = DateTime.now();
        double qres = await command.execute(qresHost, pingSettings);
        double qrescdn = await command.execute(qresCdnHost, pingSettings);
        print(" qrescdn $qrescdn ms  qres $qres ms  runtime ${DateTime.now().difference(now).inMilliseconds}");
        if (qres < qrescdn) {
          resUrl = resUrl.replaceFirst(qresCdnHost, qresHost);
        }
      } catch (e) {
        Log.e(e, tag: "RoomUtil");
      }

      await Dio().download(resUrl, filePath, onReceiveProgress: (int loaded, int total) {
        print("下载进度：" + NumUtil.getNumByValueDouble(loaded / total * 100, 2).toStringAsFixed(2) + "%"); //取精度，如：56.45%
        if (progress != null) {
          progressNum = NumUtil.getNumByValueDouble(loaded / total * 100, 2) * 0.8;
          progress(progressNum);
        }
      }).catchError((error) {
        fail("@downloadCoursePack error:$error .");
        return;
      });
      print("download files ok");
    } else {
      progressNum = 80;
      if (progress != null) {
        progress(progressNum);
      }
    }

    if (!mp4Offline && !mp4Match) {
      await Dio().download(mp4Url, mp4FilePath, onReceiveProgress: (int loaded, int total) {
        print("下载进度：" + NumUtil.getNumByValueDouble(loaded / total * 100, 2).toStringAsFixed(2) + "%"); //取精度，如：56.45%
        if (progress != null) {
          progress(NumUtil.getNumByValueDouble(loaded / total * 100, 2) * 0.2 + progressNum);
        }
      }).catchError((error) {
        fail("@downloadCoursePack error:$error .");
        return;
      });
    } else {
      if (progress != null) {
        progress(100.0);
      }
    }

    if (!File(filePath).existsSync()) {
      fail("error do not exists:$filePath ");
      return;
    }
    var pathName = filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
    pathName = pathName.substring(0, pathName.lastIndexOf("."));
    print("substring   $pathName");
    if (!(!offline && !match)) {
      var af = File("$directory/$pathName/courseware.json");
      if (af.existsSync()) {
        readCoursewareJson("$directory/$pathName", success, fail, mp4FilePath);
        return;
      }
    }
//    var directory = Directory(directory+"/"+file.name)

    var bytes = File(filePath).readAsBytesSync();
    print("data finish!");

    var archive = ZipDecoder().decodeBytes(bytes);
    parseCourse(archive, "$directory/$pathName", success, fail, mp4FilePath);
  }

  static parseCourse(Archive archive, String savePath, Function success, Function fail, String mp4FilePath) async {
    // 将Zip存档的内容解压缩到磁盘。
//    var directory = Directory(savePath);
//    print("directory finish! ${directory.existsSync()}");
//    if (!directory.existsSync()){
//      directory.createSync(recursive:true);
//    }
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        List<int> data = file.content;
        var f = File(savePath + "/" + file.name)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        print("path file=== ${f.path}");
      } else {
        var directory = Directory(savePath + "/" + file.name)..create(recursive: true);
        print("path directory === ${directory.path}");
      }
    }
    print("解压成功");
    readCoursewareJson(savePath, success, fail, mp4FilePath);
  }

  static readCoursewareJson(String savePath, Function success, Function fail, String mp4FilePath) {
    String coursewarePath = "$savePath/courseware.json";
    print("coursewarePath == > $coursewarePath");
    var af = File(coursewarePath);
//    var af=archive.findFile("course.json");
    if (af.existsSync()) {
      //加载课件成功
      var content = af.readAsBytesSync();
//       print("content=$content");
      var jsondata = utf8.decode(content);
      var retJSON = json.decode(jsondata);
      Courseware courseware = Courseware.fromJson(retJSON);
      courseware.localPath = savePath;
      courseware.eyeMp4Path = mp4FilePath;
      //下载视频资源
      success(courseware);
    } else {
      //加载课件失败
      fail("error : load courseware");
    }
  }
}
