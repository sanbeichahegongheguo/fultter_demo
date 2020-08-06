import 'package:dio/dio.dart';
import 'package:flutter_start/common/net/code.dart';
import 'package:flutter_start/common/net/result_data.dart';

class ResponseInterceptors extends InterceptorsWrapper {

  @override
  onResponse(Response response) async{
    RequestOptions option = response.request;
    try {
      if (option.contentType != null && option.contentType == "text") {
        return new ResultData(response.data, true, Code.SUCCESS);
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return new ResultData(response.data, true, Code.SUCCESS, headers: response.headers);
      }
    } catch (e) {
      print("ResponseInterceptors err : " + e.toString() + option.path);
      return new ResultData(response.data, false, response.statusCode, headers: response.headers);
    }
  }
}