package com.leo.flutterstart;

import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.WindowManager;

import com.leo.flutterstart.camera.CameraPlugin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.connectivity.ConnectivityPlugin;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
//import com.leo.flutterstart.tencent.YondorPlugin;

public class MainActivity extends FlutterActivity {
  /** Channel名称  **/
//  private static final String CHANNEL = "yondor"
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    UpdateVersionPlugin.registerWith(registrarFor("iwubida.com/update_version"));
    CameraPlugin.registerWith(registrarFor("yondor/camera"));
    //Banner插件
//    YondorPlugin.registerWith(this,this);
    final MainActivity content = this;
    //屏幕常亮
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    getWindow().setFormat(PixelFormat.TRANSLUCENT);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED, WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED);
    new MethodChannel(getFlutterView(), "yondor").setMethodCallHandler(
            // 提供各个方法的具体实现
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
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
