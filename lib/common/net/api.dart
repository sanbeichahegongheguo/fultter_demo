import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_start/common/net/code.dart';
import 'package:flutter_start/common/net/interceptors/error_interceptor.dart';
import 'package:flutter_start/common/net/interceptors/header_interceptor.dart';
import 'package:flutter_start/common/net/interceptors/log_interceptor.dart';
import 'package:flutter_start/common/net/interceptors/response_interceptor.dart';
import 'package:flutter_start/common/net/interceptors/token_interceptor.dart';
import 'package:flutter_start/common/net/result_data.dart';

///http请求
class HttpManager {
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  Dio dio = new Dio(); // 使用默认配置

  final TokenInterceptors _tokenInterceptors = new TokenInterceptors();

  HttpManager() {
    dio.interceptors.add(new HeaderInterceptors());

    dio.interceptors.add(_tokenInterceptors);

    dio.interceptors.add(new LogsInterceptors());

    dio.interceptors.add(new ErrorInterceptors(dio));

    dio.interceptors.add(new ResponseInterceptors());
  }

  ///发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置
  netFetch(url, params, Map<String, dynamic> header, Options option, {noTip = false, contentType = CONTENT_TYPE_FORM}) async {
    Map<String, dynamic> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = new Options(method: "get");
      option.headers = headers;
    }
    option.contentType = ContentType.parse(contentType);

    Response response;
    try {
      response = await dio.request(url, data: params, options: option);
      if (response.data.data is String) {
        String str = response.data.data;
        if (str.startsWith("{")) {
          response.data.data = jsonDecode(response.data.data);
        }
      }
    } on DioError catch (e) {
      print(e);
      Response errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = Code.NETWORK_TIMEOUT;
      }
      return new ResultData(Code.errorHandleFunction(errorResponse.statusCode, e.message, noTip), false, errorResponse.statusCode);
    }
    return response.data;
  }

  ///发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置
  netFetchImg(url, params, Map<String, dynamic> header, Options option, {noTip = false, contentType = CONTENT_TYPE_FORM}) async {
    Map<String, dynamic> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = new Options(method: "get");
      option.headers = headers;
    }
    option.contentType = ContentType.parse(contentType);

    Response response;
    try {
      response = await dio.request(url, data: params, options: option);
      if(null!=response.data["success"] && (response.data["success"]["ok"]==201)){
        //这个工程的201状态码为登录过期
        return new ResultData(Code.errorHandleFunction(401, "登录过期", noTip), false, 401);
      }
    } on DioError catch (e) {
      print(e);
      Response errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = Code.NETWORK_TIMEOUT;
      }
      return new ResultData(Code.errorHandleFunction(errorResponse.statusCode, e.message, noTip), false, errorResponse.statusCode);
    }
    return response.data;
  }

  Future<Uint8List> consolidateHttpClientResponseBytes(HttpClientResponse response) {
    // response.contentLength is not trustworthy when GZIP is involved
    // or other cases where an intermediate transformer has been applied
    // to the stream.
    final Completer<Uint8List> completer = Completer<Uint8List>.sync();
    final List<List<int>> chunks = <List<int>>[];
    int contentLength = 0;
    response.listen((List<int> chunk) {
      chunks.add(chunk);
      contentLength += chunk.length;
    }, onDone: () {
      final Uint8List bytes = Uint8List(contentLength);
      int offset = 0;
      for (List<int> chunk in chunks) {
        bytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      completer.complete(bytes);
    }, onError: completer.completeError, cancelOnError: true);
    return completer.future;
  }

  ///清除授权
  clearAuthorization() {
    _tokenInterceptors.clearAuthorization();
  }

  ///授权
  setAuthorization(String token) {
    _tokenInterceptors.setAuthorization(token);
  }

  ///获取授权token
  getAuthorization() {
    return _tokenInterceptors.getAuthorization();
  }
}

final HttpManager httpManager = new HttpManager();
