
import 'dart:convert' show json;

class Module {

  int id;
  int eventId;
  int seq;
  String iconUrl;
  String isTest;
  String name;
  String targetUrl;
  String status;

  Module({
    this.id,
    this.eventId,
    this.seq,
    this.iconUrl,
    this.isTest,
    this.name,
    this.targetUrl,
    this.status,
  });

  factory Module.fromJson(jsonRes)=>jsonRes == null? null:Module(
    id : jsonRes['id'],
    eventId : jsonRes['eventId'],
    seq : jsonRes['seq'],
    iconUrl : jsonRes['iconUrl'],
    isTest : jsonRes['isTest'],
    name : jsonRes['name'],
    targetUrl : jsonRes['targetUrl'],
    status : jsonRes['status'],
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'seq': seq,
    'iconUrl': iconUrl,
    'isTest': isTest,
    'name': name,
    'targetUrl': targetUrl,
    'status': status,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}