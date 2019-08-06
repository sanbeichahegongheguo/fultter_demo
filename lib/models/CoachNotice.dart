
import 'dart:convert' show json;

class CoachNotice {
  int moAdvertiseId;
  int appid;
  String description;
  String gradeIds;
  String isDefault;
  String isDownload;
  String ishttp;
  String name;
  String picUrl;
  String schoolIds;
  int seq;
  int stayedTime;
  String target;
  String title;
  int type;

  CoachNotice({
    this.moAdvertiseId,
    this.appid,
    this.description,
    this.gradeIds,
    this.isDefault,
    this.isDownload,
    this.ishttp,
    this.name,
    this.picUrl,
    this.schoolIds,
    this.seq,
    this.stayedTime,
    this.target,
    this.title,
    this.type,
  });

  factory CoachNotice.fromJson(jsonRes)=>jsonRes == null? null:CoachNotice(
    moAdvertiseId : jsonRes['moAdvertiseId'],
    appid : jsonRes['appid'],
    description : jsonRes['description'],
    gradeIds : jsonRes['gradeIds'],
    isDefault : jsonRes['isDefault'],
    isDownload : jsonRes['isDownload'],
    ishttp : jsonRes['ishttp'],
    name : jsonRes['name'],
    picUrl : jsonRes['picUrl'],
    schoolIds : jsonRes['schoolIds'],
    seq : jsonRes['seq'],
    stayedTime : jsonRes['stayedTime'],
    target : jsonRes['target'],
    title : jsonRes['title'],
    type : jsonRes['type'],
  );

  Map<String, dynamic> toJson() => {
    'moAdvertiseId': moAdvertiseId,
    'appid': appid,
    'description': description,
    'gradeIds': gradeIds,
    'isDefault': isDefault,
    'isDownload': isDownload,
    'ishttp': ishttp,
    'name': name,
    'picUrl': picUrl,
    'schoolIds': schoolIds,
    'seq': seq,
    'stayedTime': stayedTime,
    'target': target,
    'title': title,
    'type': type,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}
