
import 'dart:convert' show json;

class ChatMessage {

  int timestamp;
  String userId;
  String userName;
  int type;
  String message;

  ChatMessage({
    this.timestamp,
    this.userId,
    this.userName,
    this.type,
    this.message,
  });

  factory ChatMessage.fromJson(jsonRes)=>jsonRes == null? null:ChatMessage(
    timestamp : jsonRes['timestamp'],
    userId : jsonRes['userId'],
    userName : jsonRes['userName'],
    type : jsonRes['type'],
    message : jsonRes['message'],);

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'userId': userId,
    'userName': userName,
    'type': type,
    'message': message,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}