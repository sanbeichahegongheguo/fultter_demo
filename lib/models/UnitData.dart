import 'dart:convert' show json;
class UnitData {
  int count;
  int notIdsCount;
  int racSyntestId;
  String racSyntestName;
  UnitData({
    this.count,
    this.notIdsCount,
    this.racSyntestId,
    this.racSyntestName,
  });

  factory UnitData.fromJson(jsonRes)=>jsonRes == null? null:UnitData(
      count : jsonRes['count'],
      notIdsCount : jsonRes['notIdsCount'],
      racSyntestId : jsonRes['racSyntestId'],
      racSyntestName : jsonRes['racSyntestName']
  );
  Map<String, dynamic> toJson() => {
    'count': count,
    'notIdsCount': notIdsCount,
    'racSyntestId': racSyntestId,
    'racSyntestName': racSyntestName
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}