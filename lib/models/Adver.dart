
import 'dart:convert' show json;

class Adver {

  int ok;
  String message;
  String picUrl;
  String type;
  int advertId;
  String isHttp;
  String isdownload;
  String target;
  String appid;
  String adverName;

  Adver({
    this.ok,
    this.message,
    this.picUrl,
    this.type,
    this.advertId,
    this.isHttp,
    this.isdownload,
    this.target,
    this.appid,
    this.adverName,
  });

  factory Adver.fromJson(jsonRes)=>jsonRes == null? null:Adver(
    ok : jsonRes['ok'],
    message : jsonRes['message'],
    picUrl : jsonRes['picUrl'],
    type : jsonRes['type'],
    advertId : jsonRes['advertId'],
    isHttp : jsonRes['isHttp'],
    isdownload : jsonRes['isdownload'],
    target : jsonRes['target'],
    appid : jsonRes['appid'],
    adverName : jsonRes['adverName'],);

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'message': message,
    'picUrl': picUrl,
    'type': type,
    'advertId': advertId,
    'isHttp': isHttp,
    'isdownload': isdownload,
    'target': target,
    'appid': appid,
    'adverName': adverName,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}