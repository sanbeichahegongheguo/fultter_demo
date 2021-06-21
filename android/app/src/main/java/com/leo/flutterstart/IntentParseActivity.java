package com.leo.flutterstart;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.TaskStackBuilder;

   import java.util.List;

public class IntentParseActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Uri data = getIntent().getData();
        try{
            Log.i("IntentParseActivity", "url: " + data.toString());
            Intent intent = new Intent(this,MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP |  Intent.FLAG_ACTIVITY_CLEAR_TOP);
            if(isLaunchedActivity(this,MainActivity.class)){
                startActivity(intent);
            }else{
                TaskStackBuilder.create(this).addParentStack(intent.getComponent()).addNextIntent(intent).startActivities();
            }
            finish();
        }catch (Exception e){
            e.printStackTrace();
            finish();
        }
    }

    public static boolean isLaunchedActivity(Context context, Class<?> clazz) {
        try {
            Intent intent = new Intent(context, clazz);
            ComponentName cmpName = intent.resolveActivity(context.getPackageManager());
            if (cmpName != null) { // 说明系统中存在这个activity
                ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
                List<ActivityManager.RunningTaskInfo> taskInfoList = am.getRunningTasks(10);
                for (ActivityManager.RunningTaskInfo taskInfo : taskInfoList) {
                    if (taskInfo.baseActivity.equals(cmpName)) { // 说明它已经启动了
                        return true;
                    }
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
