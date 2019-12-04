
import 'dart:convert' show json;

class StudyData {

  String cttotal;
  String questotal;
  String studyTotaltime;
  String isOneMonth;

  StudyData({
    this.cttotal,
    this.questotal,
    this.studyTotaltime,
    this.isOneMonth,
  });

  factory StudyData.fromJson(jsonRes)=>jsonRes == null? null:StudyData(
    cttotal : jsonRes['cttotal'],
    questotal : jsonRes['questotal'],
    studyTotaltime : jsonRes['studyTotaltime'],
    isOneMonth: jsonRes['isOneMonth']
  );


  Map<String, dynamic> toJson() => {
    'cttotal': cttotal,
    'questotal': questotal,
    'studyTotaltime': studyTotaltime,
    'isOneMonth':isOneMonth,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}