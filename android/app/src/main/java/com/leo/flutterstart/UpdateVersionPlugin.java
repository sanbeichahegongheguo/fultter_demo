package com.leo.flutterstart;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.king.app.updater.AppUpdater;
import com.king.app.updater.callback.UpdateCallback;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
/** UpdateVersionPlugin */
public class UpdateVersionPlugin implements FlutterPlugin,EventChannel.StreamHandler {

    private static String TAG = "MY_UPDATE";
    private Context context;
    private EventChannel channel;

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final EventChannel channel = new EventChannel(registrar.messenger(), "plugins.iwubida.com/update_version");
        UpdateVersionPlugin updateVersionPlugin = new UpdateVersionPlugin();
        updateVersionPlugin.context = registrar.context();
        channel.setStreamHandler(updateVersionPlugin);
    }


    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {

        if (o.toString().length() < 5) {
            eventSink.error(TAG, "URL错误", o);
            return;
        }
        if (!o.toString().startsWith("http")){
            eventSink.error(TAG, "URL错误", o);
            return;
        }

        AppUpdater update = new AppUpdater(context,o.toString()).setUpdateCallback(new UpdateCallback() {

            Map data = new HashMap<String, Object>();

            // 发送数据到 Flutter
            private  void sendData() {
                eventSink.success(data);
            }

            @Override
            public void onDownloading(boolean isDownloading) {

            }

            @Override
            public void onStart(String url) {
                data.put("start", true);
                data.put("cancel", false);
                data.put("done",false );
                data.put("error", false);
                data.put("percent", 1);
                sendData();
            }

            @Override
            public void onProgress(int progress, int total, boolean isChange) {
                int percent = (int)(progress * 1.0 / total * 100);
                if (isChange && percent > 0) {
                    data.put("percent", percent);
                    sendData();
                }
            }

            @Override
            public void onFinish(File file) {
                data.put("done", true);
                data.put("percent", 100);
                sendData();
            }

            @Override
            public void onError(Exception e) {
                data.put("error", e.toString());
                sendData();
            }

            @Override
            public void onCancel() {
                data.put("cancel", true);
                sendData();
            }
        });
        update.start();
    }

    @Override
    public void onCancel(Object o) {
        Log.i(TAG, "取消下载-集成的第三方下载没有提供取消方法");
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new EventChannel(binding.getBinaryMessenger(), "plugins.iwubida.com/update_version");
        this.context = binding.getApplicationContext();
        channel.setStreamHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setStreamHandler(null);
    }
}