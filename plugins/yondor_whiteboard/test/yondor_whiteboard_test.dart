import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yondor_whiteboard/yondor_whiteboard.dart';

void main() {
  const MethodChannel channel = MethodChannel('yondor_whiteboard');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await YondorWhiteboard.platformVersion, '42');
  });
}
