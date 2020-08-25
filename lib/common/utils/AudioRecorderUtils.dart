import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderUtils {
  FlutterAudioRecorder recorder;
  var recording;
  start(message) async {
    try {
      bool hasPermission = await FlutterAudioRecorder.hasPermissions;
      if (hasPermission) {
        Directory tempDir = await getTemporaryDirectory();
        var customPath = "${tempDir.path}/${DateTime.now().microsecondsSinceEpoch.toString()}";
        recorder = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV, sampleRate: 16000); // .wav .aac .m4a
        await recorder.initialized;
        await recorder.start();
        recording = await recorder.current(channel: 0);
        print("调用成功");
      } else {
        showToast('调用失败', position: ToastPosition.bottom);
      }
    } catch (err) {
      print("调用失败2${err}");
    }
  }

  ///暂停录音
  pause() async {
    await recorder.pause();
  }

  ///继续录音
  resume() async {
    await recorder.resume();
  }

  ///结束录音
  stop() async {
    var result = await recorder.stop();
    print("path====>${result.path}");
    File file = new File(result.path);
    List<int> imageBytes = await file.readAsBytes();
    return convert.base64Encode(imageBytes);
  }

  void dispose() {
    recorder.stop();
    recorder = null;
  }
}
