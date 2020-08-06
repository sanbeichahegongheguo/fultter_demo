import 'dart:convert' show json;

class RoomUser {
  int uid;
  int role;
  int enableChat;
  int enableVideo;
  int enableAudio;
  int screenId;
  int grantBoard;
  String rtcToken;
  String rtmToken;
  String screenToken;
  int coVideo;
  String userId;
  String userName;
  String userUuid;

  RoomUser({
    this.uid,
    this.role,
    this.enableChat,
    this.enableVideo,
    this.enableAudio,
    this.screenId,
    this.grantBoard,
    this.rtcToken,
    this.rtmToken,
    this.screenToken,
    this.coVideo,
    this.userId,
    this.userName,
    this.userUuid,
  });

  factory RoomUser.fromJson(jsonRes) => jsonRes == null
      ? null
      : RoomUser(
          uid: jsonRes['uid'],
          role: jsonRes['role'],
          enableChat: jsonRes['enableChat'],
          enableVideo: jsonRes['enableVideo'],
          enableAudio: jsonRes['enableAudio'],
          screenId: jsonRes['screenId'],
          grantBoard: jsonRes['grantBoard'],
          rtcToken: jsonRes['rtcToken'],
          rtmToken: jsonRes['rtmToken'],
          screenToken: jsonRes['screenToken'],
          coVideo: jsonRes['coVideo'],
          userId: jsonRes['userId'],
          userName: jsonRes['userName'],
          userUuid: jsonRes['userUuid'],
        );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role,
        'enableChat': enableChat,
        'enableVideo': enableVideo,
        'enableAudio': enableAudio,
        'screenId': screenId,
        'grantBoard': grantBoard,
        'rtcToken': rtcToken,
        'rtmToken': rtmToken,
        'screenToken': screenToken,
        'coVideo': coVideo,
        'userId': userId,
        'userName': userName,
        'userUuid': userUuid,
      };
  @override
  String toString() {
    return json.encode(this);
  }
  bool isTeacher() {
    return role == 1;
  }

}
