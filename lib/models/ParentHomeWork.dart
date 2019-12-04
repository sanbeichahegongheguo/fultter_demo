
import 'dart:convert' show json;

class ParentHomeWork {

  String hwId;
  int hwType;
  String content;
  String time;
  int state;
  String headUrl;
  String title;
  String extJson;

  ParentHomeWork({
    this.hwId,
    this.hwType,
    this.content,
    this.time,
    this.state,
    this.headUrl,
    this.title,
    this.extJson,
  });

  factory ParentHomeWork.fromJson(jsonRes)=>jsonRes == null? null:ParentHomeWork(
    hwId : jsonRes['hwId'],
    hwType : jsonRes['hwType'],
    content : jsonRes['content'],
    time : jsonRes['time'],
    state : jsonRes['state'],
    headUrl : jsonRes['headUrl'],
    title : jsonRes['title'],
    extJson : jsonRes['extJson']
  );

  Map<String, dynamic> toJson() => {
    'hwId': hwId,
    'hwType': hwType,
    'content': content,
    'time': time,
    'state': state,
    'headUrl': headUrl,
    'title': title,
    'extJson': extJson,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}