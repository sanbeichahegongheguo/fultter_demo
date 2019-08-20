import 'package:flutter/services.dart';

class Download{
  static const channelName = 'plugins.iwubida.com/update_version';
  static const stream = const EventChannel(channelName);

  static  startDownload(url,{downloadSubscription,updateDownload}) {
    if (downloadSubscription == null) {
      return stream
          .receiveBroadcastStream(url)
          .listen(updateDownload);
    }else{
      stream.receiveBroadcastStream(url);
    }
  }
}