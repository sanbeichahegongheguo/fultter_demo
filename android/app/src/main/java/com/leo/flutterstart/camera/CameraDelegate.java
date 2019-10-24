package com.leo.flutterstart.camera;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;


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
                finishWithSuccess(data.getStringExtra("data"));
                return true;
            }
        }
        return false;
    }



    public void startCamera(MethodCall call, MethodChannel.Result result){
        Log.i(TAG,"startCamera");
        methodCall = call;
        pendingResult = result;
        Intent camera = new Intent(this.activity, CameraActivity.class);
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
