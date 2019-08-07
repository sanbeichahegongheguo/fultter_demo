

import 'dart:convert' show json;

class AppVersionInfo {

  int ok;
  String message;
  String platform;
  String title;
  String maxUrl;
  String minUrl;
  String content;
  String maxVersion;
  String minVersion;
  String date;
  int isUp;
  String upTip;
  String extJson;

  AppVersionInfo({
    this.ok,
    this.message,
    this.platform,
    this.title,
    this.maxUrl,
    this.minUrl,
    this.content,
    this.maxVersion,
    this.minVersion,
    this.date,
    this.isUp,
    this.upTip,
    this.extJson,
  });

  factory AppVersionInfo.fromJson(jsonRes)=>jsonRes == null? null:AppVersionInfo(
    ok : jsonRes['ok'],
    message : jsonRes['message'],
    platform : jsonRes['platform'],
    title : jsonRes['title'],
    maxUrl : jsonRes['maxUrl'],
    minUrl : jsonRes['minUrl'],
    content : jsonRes['content'],
    maxVersion : jsonRes['maxVersion'],
    minVersion : jsonRes['minVersion'],
    date : jsonRes['date'],
    isUp : jsonRes['isUp'],
    upTip : jsonRes['upTip'],
    extJson : jsonRes['extJson'],);

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'message': message,
    'platform': platform,
    'title': title,
    'maxUrl': maxUrl,
    'minUrl': minUrl,
    'content': content,
    'maxVersion': maxVersion,
    'minVersion': minVersion,
    'date': date,
    'isUp': isUp,
    'upTip': upTip,
    'extJson': extJson,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}