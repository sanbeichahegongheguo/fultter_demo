import 'dart:convert' show json;

class Courseware {
  int id;
  String name;
  String date;
  String domain;
  String localPath;
  String eyeMp4Path;
  List<Item> items;

  Courseware({
    this.id,
    this.name,
    this.date,
    this.domain,
    this.items,
    this.localPath,
  });

  factory Courseware.fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<Item> items = jsonRes['items'] is List ? [] : null;
    if (items != null) {
      for (var item in jsonRes['items']) {
        if (item != null) {
          items.add(Item.fromJson(item));
        }
      }
    }
    return Courseware(
      id: jsonRes['id'],
      name: jsonRes['name'],
      date: jsonRes['date'],
      domain: jsonRes['domain'],
      items: items,
      localPath: jsonRes['domain'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date,
        'domain': domain,
        'items': items,
        'localPath': localPath,
        'mp3Path': eyeMp4Path,
      };
  @override
  String toString() {
    return json.encode(this);
  }

  Res findQues(int qid) {
    if (this.items == null) {
      return null;
    }
    Res res;
    for (Item item in items) {
      if (item.res == null) {
        continue;
      }
      for (Res r in item.res) {
        if (r.qid == qid) {
          res = r;
          break;
        }
      }
    }
    return res;
  }

  Res findFirst() {
    if (this.items == null) {
      return null;
    }
    Res res;
    for (Item item in items) {
      if (item.res == null) {
        continue;
      }
      for (Res r in item.res) {
        print("RRRR$r");
        if (r.type == "PIC") {
          return r;
        }
      }
    }
    return res;
  }
}

class Item {
  int id;
  String name;
  List<Res> res;

  Item({
    this.id,
    this.name,
    this.res,
  });

  factory Item.fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<Res> res = jsonRes['res'] is List ? [] : null;
    if (res != null) {
      for (var item in jsonRes['res']) {
        if (item != null) {
          res.add(Res.fromJson(item));
        }
      }
    }
    return Item(
      id: jsonRes['id'],
      name: jsonRes['name'],
      res: res,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'res': res,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Res {
  int qid;
  int typeid;
  String type;
  Data data;
  int screenId;
  int ctatlogid;
  int page;
  Res({
    this.qid,
    this.typeid,
    this.type,
    this.data,
    this.screenId,
    this.ctatlogid,
    this.page,
  });

  factory Res.fromJson(jsonRes) => jsonRes == null
      ? null
      : Res(
          qid: jsonRes['qid'],
          typeid: jsonRes['typeid'],
          type: jsonRes['type'],
          screenId: jsonRes['screenId'],
          data: Data.fromJson(jsonRes['data']),
          ctatlogid: jsonRes['ctatlogid'],
          page: jsonRes['page'],
        );

  Map<String, dynamic> toJson() => {
        'qid': qid,
        'typeid': typeid,
        'type': type,
        'data': data,
        'screenId': screenId,
        'ctatlogid': ctatlogid,
        'page': page,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Data {
  Object an;
//  Ct ct;
  int id;
  Ps ps;
  int ty;

  Data({
    this.an,
//    this.ct,
    this.id,
    this.ps,
    this.ty,
  });

  factory Data.fromJson(jsonRes) => jsonRes == null
      ? null
      : Data(
          an: jsonRes['an'],
//    ct : Ct.fromJson(jsonRes['ct']),
          id: jsonRes['id'],
          ps: Ps.fromJson(jsonRes['ps']),
          ty: jsonRes['ty'],
        );

  Map<String, dynamic> toJson() => {
        'an': an,
//    'ct': ct,
        'id': id,
        'ps': ps,
        'ty': ty,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Ct {
  List<Object> pptwp;

  Ct({
    this.pptwp,
  });

  factory Ct.fromJson(jsonRes) {
    if (jsonRes == null) return null;

    List<Object> pptwp = jsonRes['pptwp'] is List ? [] : null;
    if (pptwp != null) {
      for (var item in jsonRes['pptwp']) {
        if (item != null) {
          pptwp.add(item);
        }
      }
    }
    return Ct(
      pptwp: pptwp,
    );
  }

  Map<String, dynamic> toJson() => {
        'pptwp': pptwp,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Ps {
  String pic;
  String name;
  String h5url;
  String h5zip;
  String showTime;
  String answerTime;
  String answer_pic;
  String description;
  String appid;
  String fileid;
  String mp4;
  String mp3;
  String password;
  String background;
  String pptHtml;
  String svgUrl;
  Ps({
    this.pic,
    this.name,
    this.h5url,
    this.h5zip,
    this.showTime,
    this.answerTime,
    this.answer_pic,
    this.description,
    this.appid,
    this.fileid,
    this.mp4,
    this.mp3,
    this.password,
    this.background,
    this.pptHtml,
    this.svgUrl,
  });

  factory Ps.fromJson(jsonRes) => jsonRes == null
      ? null
      : Ps(
          pic: jsonRes['pic'],
          name: jsonRes['name'],
          h5url: jsonRes['h5url'],
          h5zip: jsonRes['h5zip'],
          showTime: jsonRes['showTime'],
          answerTime: jsonRes['answerTime'],
          answer_pic: jsonRes['answer_pic'],
          description: jsonRes['description'],
          appid: jsonRes['appid'],
          fileid: jsonRes['fileid'],
          mp4: jsonRes['mp4'],
          mp3: jsonRes['mp3'],
          password: jsonRes['password'],
          background: jsonRes['background'],
          pptHtml: jsonRes['pptHtml'],
          svgUrl: jsonRes['svgUrl'],
        );

  Map<String, dynamic> toJson() => {
        'pic': pic,
        'name': name,
        'h5url': h5url,
        'h5zip': h5zip,
        'showTime': showTime,
        'answerTime': answerTime,
        'answer_pic': answer_pic,
        'description': description,
        'appid': appid,
        'fileid': fileid,
        'mp4': mp4,
        'mp3': mp3,
        'password': password,
        'background': background,
        'pptHtml': pptHtml,
        'svgUrl': svgUrl,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}
