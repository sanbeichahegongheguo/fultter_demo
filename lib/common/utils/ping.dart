import 'dart:io';

import 'package:flutter/services.dart';
import 'package:process/process.dart';

abstract class PingCommand {
  Future<double> execute(String host, PingSettings settings);

  const PingCommand();

  factory PingCommand.create() {
    if (Platform.isAndroid) return BashPingCommand();
    if (Platform.isIOS) return SimplePingCommand();
    throw UnsupportedError("Unhandled platform.");
  }
}

class BashPingCommand extends PingCommand {
  final p = LocalProcessManager();
  @override
  Future<double> execute(String host, PingSettings settings) async {
    final args = _parseArgs(settings);
//    final now = DateTime.now();
    final result = await p.run(["ping", ...args, host]);
//    final result = await Process.run('ping', [...args, host]);
//    print("execute run time ${DateTime.now().difference(now).inMilliseconds}");
    return _parseResult(result);
  }

  List<String> _parseArgs(PingSettings settings) {
    return <String, String>{
      '-c': '1',
      '-W': settings.timeout.toString(),
      '-s': settings.packetSize.toString(),
    }.entries.expand((it) => [it.key, it.value]).toList();
  }

  double _parseResult(ProcessResult result) {
    final didSucceed = (result.stderr as String ?? "").isEmpty && result.stdout != null;
    if (!didSucceed) throw PingError.REQUEST_FAILED;
    final value = RegExp(r"time=(\d+(\.\d+)?) ms").firstMatch(result.stdout)?.group(1);
    if (value == null) {
      final didLosePacket = (result.stdout as String).contains("100% packet loss");
      if (didLosePacket) throw PingError.PACKET_LOST;
      throw PingError.INVALID_FORMAT;
    }
    return double.parse(value);
  }
}

class SimplePingCommand extends PingCommand {
  final MethodChannel _channel = MethodChannel('com.yondor.simplePing');

  @override
  Future<double> execute(String host, PingSettings settings) async {
    try {
      return await _channel.invokeMethod('ping', {
        'hostName': host,
        'packetSize': settings.packetSize,
        'timeout': settings.timeout,
      });
    } on PlatformException {
      throw PingError.REQUEST_FAILED;
    }
  }
}

class PingSettings {
  int count;
  int packetSize;
  int interval;
  int timeout;

  PingSettings({
    this.count,
    this.packetSize,
    this.interval,
    this.timeout,
  });
  factory PingSettings.fromJson(jsonRes) => jsonRes == null
      ? null
      : PingSettings(
          count: jsonRes['count'] as int,
          packetSize: jsonRes['packetSize'] as int,
          interval: jsonRes['interval'] as int,
          timeout: jsonRes['timeout'] as int,
        );
}

enum PingError {
  REQUEST_FAILED,
  PACKET_LOST,
  INVALID_FORMAT,
}
