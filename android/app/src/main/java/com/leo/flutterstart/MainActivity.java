package com.leo.flutterstart;

import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.PixelFormat;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import com.leo.flutterstart.camera.CameraPlugin;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    @Override
    public Resources getResources() {
        // 字体大小不跟随系统
        Resources res = super.getResources();
        Configuration config = new Configuration();
        config.setToDefaults();
        res.updateConfiguration(config, res.getDisplayMetrics());
        return res;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        System.out.println("configureFlutterEngine==>11111111");
        flutterEngine.getPlugins().add(new UpdateVersionPlugin());
//        System.out.println("configureFlutterEngine==>22222222222");
//        ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
//        System.out.println("configureFlutterEngine==>33333333333");
//        CameraPlugin.registerWith(shimPluginRegistry.registrarFor("yondor/camera"));
//        System.out.println("configureFlutterEngine==>444444444");
        final MainActivity content = this;
        //屏幕常亮
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().setFormat(PixelFormat.TRANSLUCENT);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED, WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED);
        System.out.println("configureFlutterEngine==>77777777");
        new MethodChannel(flutterEngine.getDartExecutor(), "yondor").setMethodCallHandler(
                // 提供各个方法的具体实现
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        switch (call.method){
                            case "detectxy":
                                try {
                                    String pos = call.argument("pos");
                                    Log.i("pos",pos);
                                    Integer thickness = call.argument("thickness");
                                    Boolean isSave = call.argument("isSave");
                                    JSONObject obj = com.leo.flutterstart.YondorMnist.detectxy(new JSONArray(pos),thickness,isSave,content);
                                    if(null != obj){
                                        result.success(obj.toString());
                                    }else {
                                        result.success("");
                                    }
                                } catch (JSONException e) {
                                    result.success("");
                                    e.printStackTrace();
                                }
                                break;
                            default:
                                result.notImplemented();
                                break;
                        }
                    }
                });
    }
}
