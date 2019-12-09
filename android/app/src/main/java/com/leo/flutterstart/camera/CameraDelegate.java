package com.leo.flutterstart.camera;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;


import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class CameraDelegate implements PluginRegistry.ActivityResultListener {
    private String TAG = "CameraDelegate";
    private final Activity activity;
    private MethodChannel.Result pendingResult;
    private MethodCall methodCall;
    private int REQUEST_CAMERA = 89;

    public CameraDelegate(Activity activity) {
        this.activity = activity;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.i(TAG,"requestCode:"+requestCode);
        if (REQUEST_CAMERA == requestCode){
            Log.i(TAG,"resultCode:"+resultCode);
            if (Activity.RESULT_OK == resultCode){
                JSONObject object = new JSONObject();
                try {
                    object.put("path",data.getStringExtra("data"));
                    object.put("type",data.getIntExtra("type",0));
                    finishWithSuccess(object.toString());
                } catch (JSONException e) {
                    finishWithSuccess("");
                    e.printStackTrace();
                }
                return true;
            }else if (Activity.RESULT_CANCELED == resultCode){
                finishWithSuccess("");
            }
        }
        return false;
    }



    public void startCamera(MethodCall call, MethodChannel.Result result, Map<String,Object> param){
        Log.i(TAG,"startCamera");
        methodCall = call;
        pendingResult = result;
        Intent camera = new Intent(this.activity, CameraActivity.class);
        camera.putExtra("isSingle",false);
        if (param.containsKey("isSingle")){
            camera.putExtra("isSingle",Boolean.valueOf(param.get("isSingle").toString()));
        }
        if (param.containsKey("type")){
            camera.putExtra("type",Integer.valueOf(param.get("type").toString()));
        }
        if (param.containsKey("msg")){
            camera.putExtra("msg",param.get("msg").toString());
        }
        Log.i(TAG,param.toString());
        this.activity.startActivityForResult(camera,REQUEST_CAMERA);
    }

    private void finishWithSuccess(String imagePath) {
        Log.i(TAG,"finishWithSuccess:"+imagePath);
        pendingResult.success(imagePath);
        clearMethodCallAndResult();
    }

    private void finishWithError(String errorCode, String errorMessage, Throwable throwable) {
        pendingResult.error(errorCode, errorMessage, throwable);
        clearMethodCallAndResult();
    }


    private void clearMethodCallAndResult() {
        methodCall = null;
        pendingResult = null;
    }
}
