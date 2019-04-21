import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


class HttpUtils {

  static Future<dynamic> get(String url,params) async {
   var result ;
    print('url : $url');
    await http.get(url).then((http.Response response) {
      var data = json.decode(response.body);
      result = data["data"]["datas"];
      print('result : $result');
    });
    return result;
  }

  Future<dynamic> post(String url,params) async {
    var result ;
    await http.post(url).then((http.Response response) {
      var data = json.decode(response.body);
      result =data["data"]["datas"];
      print('result$result');
    });
    return result;
  }
}
