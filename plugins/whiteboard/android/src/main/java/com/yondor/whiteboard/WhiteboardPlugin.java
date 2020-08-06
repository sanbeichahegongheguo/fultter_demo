package com.yondor.whiteboard;

import androidx.annotation.NonNull;

import com.yondor.whiteboard.manager.LogManager;
import com.yondor.whiteboard.manager.ToastManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;

/** WhiteboardPlugin */
public class WhiteboardPlugin implements FlutterPlugin, MethodCallHandler {

  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    LogManager.init(flutterPluginBinding.getApplicationContext(), "WhiteboardPlugin");
    ToastManager.init(flutterPluginBinding.getApplicationContext());
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "whiteboard");
    channel.setMethodCallHandler(this);
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("whiteboard_view", new WhiteboardViewFactory(StandardMessageCodec.INSTANCE
            , flutterPluginBinding.getBinaryMessenger()));

  }

  public static void registerWith(Registrar registrar) {
    LogManager.init(registrar.context(), "WhiteboardPlugin");
    ToastManager.init(registrar.activity().getApplication());
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "whiteboard");
    channel.setMethodCallHandler(new WhiteboardPlugin());
    registrar.platformViewRegistry().registerViewFactory("whiteboard_view", new WhiteboardViewFactory(StandardMessageCodec.INSTANCE, registrar.messenger()));
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
