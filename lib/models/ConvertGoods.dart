
import 'dart:convert' show json;

class ConvertGoods {

  int id;
  String name;
  int xxNum;
  String picUrl;
  String minPicUrl;
  String convertUrl;
  int storeNum;

  ConvertGoods({
    this.id,
    this.name,
    this.xxNum,
    this.picUrl,
    this.minPicUrl,
    this.convertUrl,
    this.storeNum,
  });

  factory ConvertGoods.fromJson(jsonRes)=>jsonRes == null? null:ConvertGoods(
    id : jsonRes['id'],
    name : jsonRes['name'],
    xxNum : jsonRes['xxNum'],
    picUrl : jsonRes['picUrl'],
    minPicUrl : jsonRes['minPicUrl'],
    convertUrl : jsonRes['convertUrl'],
    storeNum : jsonRes['storeNum'],);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'xxNum': xxNum,
    'picUrl': picUrl,
    'minPicUrl': minPicUrl,
    'convertUrl': convertUrl,
    'storeNum': storeNum,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}