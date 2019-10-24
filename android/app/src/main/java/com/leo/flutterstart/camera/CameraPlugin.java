package com.leo.flutterstart.camera;

import androidx.appcompat.app.AppCompatDelegate;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class CameraPlugin implements MethodChannel.MethodCallHandler {
    static
    {
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
    }
    private static final String CHANNEL = "plugins.yondor/camera";
//
    private final PluginRegistry.Registrar registrar;
    private final CameraDelegate delegate;


    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
        final CameraDelegate delegate = new CameraDelegate(registrar.activity());
        registrar.addActivityResultListener(delegate);
        channel.setMethodCallHandler(new CameraPlugin(registrar, delegate));
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (registrar.activity() == null) {
            result.error("no_activity", "image_cropper plugin requires a foreground activity.", null);
            return;
        }
        if (call.method.equals("open")) {
            delegate.startCamera(call, result);
        }
    }

    CameraPlugin(PluginRegistry.Registrar registrar, CameraDelegate delegate) {
        this.registrar = registrar;
        this.delegate = delegate;
    }
}
