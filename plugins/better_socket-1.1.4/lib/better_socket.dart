import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class BetterSocket {
  static const MethodChannel _channel = const MethodChannel('better_socket');
  static const EventChannel eventChannel = const EventChannel("better_socket/event");
  static StreamSubscription<dynamic> _onMessageSubscription;
  static Stream<dynamic> _eventsMessage;
  static Function _onOpen;
  static Function _onMessage;
  static Function _onError;
  static Function _onClose;
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static connentSocket(String path,
      {Map<String, String> httpHeaders,
      bool trustAllHost,
      String keyStorePath,
      String keyPassword,
      String storePassword,
      String keyStoreType}) {
    _channel.invokeMethod('connentSocket', {
      'path': path,
      "httpHeaders": httpHeaders,
      "keyStorePath": keyStorePath,
      "trustAllHost": trustAllHost,
      "keyPassword": keyPassword,
      "storePassword": storePassword,
      "keyStoreType": keyStoreType
    });
  }

  static sendMsg(String msg) {
    _channel.invokeMethod('sendMsg', <String, String>{'msg': msg});
  }

  static sendByteMsg(Uint8List msg) {
    _channel.invokeMethod('sendByteMsg', <String, Uint8List>{'msg': msg});
  }

  static close() async{
    await _channel.invokeMethod('close');
    _eventsMessage = null;
    if (_onMessageSubscription != null) {
      _onMessageSubscription.cancel();
      _onMessageSubscription = null;
    }
  }

  static void addListener(
      {Function onOpen, Function onMessage, Function onError, Function onClose}) {
    _onOpen = onOpen;
    _onMessage = onMessage;
    _onError = onError;
    _onClose = onClose;
    if (_eventsMessage==null){
      _eventsMessage = eventChannel.receiveBroadcastStream().asBroadcastStream();
      _onMessageSubscription = _eventsMessage.listen((data) {
        var event = data["event"];
        if ("onOpen" == event) {
          if (_onOpen != null) {
            var httpStatus = data["httpStatus"];
            var httpStatusMessage = data["httpStatusMessage"];
            _onOpen(httpStatus, httpStatusMessage);
          }
        } else if ("onClose" == event) {
          if (_onClose != null) {
            var code = data["code"];
            var reason = data["reason"];
            var remote = data["remote"];
            _onClose(code, reason, remote);
          }
        } else if ("onMessage" == event) {
          if (_onMessage != null) {
            var message = data["message"];
            _onMessage(message);
          }
        } else if ("onError" == event) {
          if (_onError != null) {
            var message = data["message"];
            _onError(message);
          }
        }
      });
    }
  }
}
