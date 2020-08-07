package com.flutter_webview_plugin.tencent;

import android.app.Activity;
import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class SplashFactory extends PlatformViewFactory {
    private Activity activity;
    private BinaryMessenger messenger;

    public SplashFactory(MessageCodec<Object> createArgsCodec, Activity activity, BinaryMessenger messenger) {
        super(createArgsCodec);
        this.activity = activity;
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new Splash(activity, messenger, id,(Map<String, Object>) args);
    }
}
