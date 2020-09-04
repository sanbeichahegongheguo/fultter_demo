import 'dart:convert' show json;

T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }

  return null;
}

class ReplayData {
  ReplayData({
    this.lid,
    this.rid,
    this.tid,
    this.list,
  });

  factory ReplayData.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<ReplayItem> list = jsonRes['list'] is List ? <ReplayItem>[] : null;
    if (list != null) {
      for (final dynamic item in jsonRes['list']) {
        if (item != null) {
          list.add(ReplayItem.fromJson(asT<Map<String, dynamic>>(item)));
        }
      }
    }
    return ReplayData(
      lid: asT<int>(jsonRes['lid']),
      rid: asT<String>(jsonRes['rid']),
      tid: asT<int>(jsonRes['tid']),
      list: list,
    );
  }

  int lid;
  String rid;
  int tid;
  List<ReplayItem> list;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'lid': lid,
        'rid': rid,
        'tid': tid,
        'list': list,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class ReplayItem {
  ReplayItem({
    this.ty,
    this.op,
    this.t,
    this.playTime,
  });

  factory ReplayItem.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : ReplayItem(
          ty: asT<String>(jsonRes['ty']),
          op: asT<String>(jsonRes['op']),
          t: asT<int>(jsonRes['t']),
          playTime: asT<int>(jsonRes['playTime']),
        );

  String ty;
  String op;
  int t;
  int playTime;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'ty': ty,
        'op': op,
        't': t,
        'playTime': playTime,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}
