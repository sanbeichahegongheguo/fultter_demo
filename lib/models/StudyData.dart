
import 'dart:convert' show json;

class StudyData {

  String cttotal;
  String questotal;
  String studyTotaltime;

  StudyData({
    this.cttotal,
    this.questotal,
    this.studyTotaltime,
  });

  factory StudyData.fromJson(jsonRes)=>jsonRes == null? null:StudyData(
    cttotal : jsonRes['cttotal'],
    questotal : jsonRes['questotal'],
    studyTotaltime : jsonRes['studyTotaltime'],);

  Map<String, dynamic> toJson() => {
    'cttotal': cttotal,
    'questotal': questotal,
    'studyTotaltime': studyTotaltime,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}