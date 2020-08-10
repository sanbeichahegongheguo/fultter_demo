package com.yondor.yondor_whiteboard.manager;

import android.content.Context;
import android.os.Handler;
import android.widget.Toast;

import androidx.annotation.StringRes;

public class ToastManager {

    private static Context context;
    private static Handler handler;

    public static void init(Context context) {
        ToastManager.context = context;
        handler = new Handler();
    }

    public static void showShort(@StringRes int stringResId) {
        showShort(context.getString(stringResId));
    }

    public static void showShort(String text) {
        handler.post(() -> Toast.makeText(context, text, Toast.LENGTH_SHORT).show());
    }

}
