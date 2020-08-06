import 'dart:convert' show json;

import 'Courseware.dart';
import 'RoomUser.dart';

class RoomData {
  Room room;
  RoomUser user;
  Courseware courseware;
  int liveCourseallotId;
  RoomData({
    this.room,
    this.user,
    this.courseware,
    this.liveCourseallotId,
  });

  factory RoomData.fromJson(jsonRes) => jsonRes == null
      ? null
      : RoomData(
          room: Room.fromJson(jsonRes['room']),
          user: RoomUser.fromJson(jsonRes['user']),
        );

  Map<String, dynamic> toJson() => {
        'room': room,
        'user': user,
        'courseware': courseware,
        'liveCourseallotId': liveCourseallotId,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Room {
  String channelName;
  int type;
  int courseState;
  String studentPassword;
  String teacherPassword;
  int muteAllChat;
  int isRecording;
  String recordId;
  int lockBoard;
  String remark;
  List<RoomUser> coVideoUsers;
  int onlineUsers;
  String appId;
  String roomId;
  String roomName;
  String roomUuid;

  Room({
    this.channelName,
    this.type,
    this.courseState,
    this.studentPassword,
    this.teacherPassword,
    this.muteAllChat,
    this.isRecording,
    this.recordId,
    this.lockBoard,
    this.remark,
    this.coVideoUsers,
    this.onlineUsers,
    this.appId,
    this.roomId,
    this.roomName,
    this.roomUuid,
  });

  factory Room.fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<RoomUser> coVideoUsers = jsonRes['coVideoUsers'] is List ? [] : null;
    if (coVideoUsers != null) {
      for (var item in jsonRes['coVideoUsers']) {
        if (item != null) {
          coVideoUsers.add(RoomUser.fromJson(item));
        }
      }
    }
    return Room(
      channelName: jsonRes['channelName'],
      type: jsonRes['type'],
      courseState: jsonRes['courseState'],
      studentPassword: jsonRes['studentPassword'],
      teacherPassword: jsonRes['teacherPassword'],
      muteAllChat: jsonRes['muteAllChat'],
      isRecording: jsonRes['isRecording'],
      recordId: jsonRes['recordId'],
      lockBoard: jsonRes['lockBoard'],
      remark: jsonRes['remark'],
      coVideoUsers: coVideoUsers,
      onlineUsers: jsonRes['onlineUsers'],
      appId: jsonRes['appId'],
      roomId: jsonRes['roomId'],
      roomName: jsonRes['roomName'],
      roomUuid: jsonRes['roomUuid'],
    );
  }

  Map<String, dynamic> toJson() => {
        'channelName': channelName,
        'type': type,
        'courseState': courseState,
        'studentPassword': studentPassword,
        'teacherPassword': teacherPassword,
        'muteAllChat': muteAllChat,
        'isRecording': isRecording,
        'recordId': recordId,
        'lockBoard': lockBoard,
        'remark': remark,
        'coVideoUsers': coVideoUsers,
        'onlineUsers': onlineUsers,
        'appId': appId,
        'roomId': roomId,
        'roomName': roomName,
        'roomUuid': roomUuid,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}



class SocketMsg {

  String type;
  MsgUser user;
  int timestamp;
  String text;
  int userCount;

  SocketMsg({
    this.type,
    this.user,
    this.timestamp,
    this.text,
    this.userCount,
  });

  factory SocketMsg.fromJson(jsonRes)=>jsonRes == null? null:SocketMsg(
    type : jsonRes['type'],
    user : MsgUser.fromJson(jsonRes['user']),
    timestamp : jsonRes['timestamp'],
    text : jsonRes['text'],
    userCount : jsonRes['userCount'],);

  Map<String, dynamic> toJson() => {
    'type': type,
    'user': user,
    'timestamp': timestamp,
    'text': text,
    'userCount': userCount,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}

class MsgUser {

  int uid;
  String username;
  String account;
  String type;

  MsgUser({
    this.uid,
    this.username,
    this.account,
    this.type,
  });

  factory MsgUser.fromJson(jsonRes)=>jsonRes == null? null:MsgUser(
    uid : jsonRes['uid'],
    username : jsonRes['username'],
    account : jsonRes['account'],
    type : jsonRes['type'],);

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'username': username,
    'account': account,
    'type': type,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}