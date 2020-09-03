package com.leo.flutterstart.camera;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDelegate;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class CameraPlugin implements MethodChannel.MethodCallHandler, ActivityAware, FlutterPlugin {
    static
    {
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
    }
    private static final String CHANNEL = "plugins.yondor/camera";
    private  Activity activity;
    private  CameraDelegate delegate;
    MethodChannel channel;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
        final CameraDelegate delegate = new CameraDelegate(registrar.activity());
        registrar.addActivityResultListener(delegate);
        channel.setMethodCallHandler(new CameraPlugin(registrar.activity(), delegate));
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (activity == null) {
            result.error("no_activity", "image_cropper plugin requires a foreground activity.", null);
            return;
        }
        if (call.method.equals("open")) {
            Map<String,Object> param = new HashMap<>();
            Object type = call.argument("type");
            Object isSingle = call.argument("isSingle");
            Object msg = call.argument("msg");
            if(null!=type){
                param.put("type",type);
            }
            if (null != isSingle){
                param.put("isSingle",isSingle);
            }
            if (null != msg){
                param.put("msg",msg);
            }
            Log.i("CameraPlugin",param.toString());
            delegate.startCamera(call, result,param);
        }
    }

    CameraPlugin(Activity activity, CameraDelegate delegate) {
        this.activity = activity;
        this.delegate = delegate;
    }
    public CameraPlugin(){

    }
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.i("CameraPlugin","onAttachedToActivity");
        activity = binding.getActivity();
        delegate = new CameraDelegate(activity);
        binding.addActivityResultListener(delegate);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
