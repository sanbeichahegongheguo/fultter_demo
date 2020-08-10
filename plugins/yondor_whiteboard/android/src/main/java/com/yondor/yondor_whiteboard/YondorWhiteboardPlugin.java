package com.yondor.yondor_whiteboard;

import androidx.annotation.NonNull;

import com.yondor.yondor_whiteboard.manager.LogManager;
import com.yondor.yondor_whiteboard.manager.ToastManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;

/** YondorWhiteboardPlugin */
public class YondorWhiteboardPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    LogManager.init(flutterPluginBinding.getApplicationContext(), "YondorWhiteboardPlugin");
    ToastManager.init(flutterPluginBinding.getApplicationContext());
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "yondor_whiteboard");
    channel.setMethodCallHandler(this);
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("whiteboard_view", new WhiteboardViewFactory(StandardMessageCodec.INSTANCE
            , flutterPluginBinding.getBinaryMessenger()));
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    LogManager.init(registrar.context(), "WhiteboardPlugin");
    ToastManager.init(registrar.activity().getApplication());
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "yondor_whiteboard");
    channel.setMethodCallHandler(new YondorWhiteboardPlugin());
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
