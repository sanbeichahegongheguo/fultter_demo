
import 'dart:convert' show json;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LogData {
  int id;
  int t;
  int l;
  String g;
  String c;

  LogData({
    this.id,
    this.t,
    this.l,
    this.g,
    this.c,
  });

  factory LogData.fromJson(jsonRes)=>jsonRes == null? null:LogData(
    id : jsonRes['id'],
    t : jsonRes['t'],
    l : jsonRes['l'],
    g : jsonRes['g'],
    c : jsonRes['c'],);

  Map<String, dynamic> toJson() => {
    'id':id,
    't': t,
    'l': l,
    'g': g,
    'c': c,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}


class LogConfig {

  int code;
  bool enable;
  int level;
  int t;

  LogConfig({
    this.code,
    this.enable,
    this.level,
    this.t,
  });

  factory LogConfig.fromJson(jsonRes)=>jsonRes == null? null:LogConfig(
    code : jsonRes['code'],
    enable : jsonRes['enable'],
    level : jsonRes['level'],
    t : jsonRes['t'],);

  Map<String, dynamic> toJson() => {
    'code': code,
    'enable': enable,
    'level': level,
    't': t,
  };
  @override
  String  toString() {
    return json.encode(this);
  }
}

class LogDataDb{

  static var _name = "logs";
  static Database database;

  static init() async {
    database = await openDatabase(
        join(await getDatabasesPath(), 'log_database.db'),
        onCreate:(db, version){
            return db.execute("CREATE TABLE $_name(id INTEGER PRIMARY KEY, t INTEGER, l INTEGER,g TEXT,c TEXT)");
        },
        version: 1
    );
  }

  static Future<int> insertLogData(LogData logData) async{
    return database.insert("$_name", logData.toJson());
  }

  static Future<List<LogData>> getLogs() async {
    final List<Map<String, dynamic>> maps = await database.query("$_name",limit: 1000);
    return List.generate(maps.length, (index) => LogData(
      id: maps[index]["id"],
      t: maps[index]["t"],
      l: maps[index]["l"],
      g: maps[index]["g"],
      c: maps[index]["c"],
    ));
  }

  static Future<int> deleteLogs(List<int> ids) async{
    return database.delete("$_name",where: "id in (${buildInSql(ids.length)})",whereArgs: ids);
  }
  static String buildInSql(int len){
    String insql = "";
    for(int i=0 ;i < len ;i++){
      insql +="?,";
    }
    if (insql.endsWith(",")){
      insql = insql.substring(0,insql.length-1);
    }
    return insql;
  }
}