import 'dart:convert';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RoomEduSocket {
  String key;
  String roomId;
  bool isLogin = false;
  void Function(AgoraRtmMessage message, AgoraRtmMember fromMember) onMessageReceived;
  void Function(AgoraRtmMessage message, String peerId) onMessageReceivedUser;
  void Function(AgoraRtmMember member) onMemberJoined;
  void Function(AgoraRtmMember member) onMemberLeft;
  void Function(int count) onMemberCountUpdated;
  void Function(dynamic error) onError;
  IO.Socket socket;
  bool init(String userId) {
    print("@RoomEduSocket init");
    socket = IO.io("http://192.168.20.63:8080/", {
      "path": "/app_live/socket.io",
      'transports': ['websocket'],
    });
    socket.on("connect", (data) {
      if (isLogin) {
        join(this.key, this.roomId);
      }
    });

    socket.on("messageReceived", messageReceived);
    socket.on("messageReceived/$userId", messageReceivedUser);
    socket.on("memberLeft", memberLeft);
    socket.on("memberJoined", memberJoined);
    socket.on("memberCountUpdated", memberCountUpdated);
    socket.on('error', error);
    return socket.connected;
  }

  join(String key, String roomId) {
//    key = "d02add7042d24e698b95a08f63228bcc";
//    roomId = "a0705be237454eeaa8ee28480d974257";
    print("join : key=>$key  roomId=>$roomId");
    this.key = key;
    this.roomId = roomId;
    socket.emitWithAck("join", {"key": key, "roomId": roomId}, ack: (data) {
      print("join : $data");
      if (data["code"] != null && data["code"] == 200) {
        isLogin = true;
      }
    });
  }

  getCurrentUser() {
    socket.emitWithAck("cUser", "", ack: (data) {
      print("@RoomEduSocket getCurrentUser : $data");
    });
  }

  messageReceived(data) {
    print("@RoomEduSocket messageReceived: $data");
    if (onMessageReceived != null) {
      AgoraRtmMessage agoraRtmMessage = AgoraRtmMessage(jsonEncode(data["message"]["text"]), data["message"]["ts"], data["message"]["offline"]);
      AgoraRtmMember agoraRtmMember = AgoraRtmMember.fromJson(data["member"]);
      onMessageReceived(agoraRtmMessage, agoraRtmMember);
    }
  }

  messageReceivedUser(data) {
    print("@RoomEduSocket messageReceivedUser: $data");
    if (onMessageReceivedUser != null) {
      AgoraRtmMessage agoraRtmMessage = AgoraRtmMessage(jsonEncode(data["message"]["text"]), data["message"]["ts"], data["message"]["offline"]);
      String peerId = data["peerId"];
      onMessageReceivedUser(agoraRtmMessage, peerId);
    }
  }

  memberLeft(data) {
    print("@RoomEduSocket memberLeft:  $data");
    if (onMemberLeft != null) {
      AgoraRtmMember agoraRtmMember = AgoraRtmMember.fromJson(data);
      onMemberLeft(agoraRtmMember);
    }
  }

  memberJoined(data) {
    print("@RoomEduSocket memberJoined: $data");
    if (onMemberJoined != null) {
      AgoraRtmMember agoraRtmMember = AgoraRtmMember.fromJson(data);
      onMemberJoined(agoraRtmMember);
    }
  }

  memberCountUpdated(data) {
    print("@RoomEduSocket memberCountUpdated: $data");
    if (onMemberCountUpdated != null) {
      onMemberCountUpdated(data);
    }
  }

  error(data) {
    print('@RoomEduSocket error $data');
    if (onError != null) {
      onError(data);
    }
  }

  close() {
    socket?.dispose();
    socket = null;
  }
}
