package io.flutter.plugins.webviewflutter.tencent;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Point;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qq.e.ads.splash.SplashAD;
import com.qq.e.ads.splash.SplashADListener;
import com.qq.e.comm.util.AdError;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class Splash implements PlatformView,SplashADListener {
    private Activity activity;
    private SplashAD splashAD;
    private BinaryMessenger messenger;
    private ViewGroup container;
    private TextView skipView;
    private ImageView splashHolder;
    private MethodChannel methodChannel;
    public boolean canJump = false;

    Splash(Activity activity, BinaryMessenger messenger, int id, Map<String, Object> params){
        this.activity = activity;
        this.messenger = messenger;
        methodChannel = new MethodChannel(messenger, "splash_" + id);
        initView();
    }
    /**
     * 为防止无广告时造成视觉上类似于"闪退"的情况，设定无广告时页面跳转根据需要延迟一定时间，demo
     * 给出的延时逻辑是从拉取广告开始算开屏最少持续多久，仅供参考，开发者可自定义延时逻辑，如果开发者采用demo
     * 中给出的延时逻辑，也建议开发者考虑自定义minSplashTimeWhenNoAD的值（单位ms）
     **/
    private int minSplashTimeWhenNoAD = 2000;
    /**
     * 记录拉取广告的时间
     */
    private long fetchSplashADTime = 0;

    private void  initView(){
        Point screenSize = new Point();
        activity.getWindowManager().getDefaultDisplay().getSize(screenSize);
        //容器
        //this:haxe中修改为mainContext
        container = new RelativeLayout(activity);
        container.setLayoutParams(new RelativeLayout.LayoutParams(screenSize.x,screenSize.y));
        //跳过按钮
        skipView = new TextView(activity);
        RelativeLayout.LayoutParams skipViewLayoutParams = new RelativeLayout.LayoutParams(96, RelativeLayout.LayoutParams.WRAP_CONTENT);
        skipViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        skipViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        skipViewLayoutParams.setMargins(16,16,16,16);
        skipView.setLayoutParams(skipViewLayoutParams);
        skipView.setVisibility(View.VISIBLE);
        skipView.setGravity(Gravity.CENTER);
        skipView.setBackgroundColor(Color.GRAY);
        skipView.setTextColor(Color.WHITE);
        skipView.setTextSize(14);
        splashHolder = new ImageView(activity);
        splashHolder.setLayoutParams(new RelativeLayout.LayoutParams(screenSize.x,screenSize.y));
        splashHolder.setScaleType(ImageView.ScaleType.FIT_XY);
        //LOgo
//        appLogo = new ImageView(activity);
//        RelativeLayout.LayoutParams logoParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
//        logoParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
//        logoParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
//        appLogo.setLayoutParams(logoParams);
//        appLogo.setImageDrawable(Drawable.createFromPath("ic_launcher"));
        // 如果targetSDKVersion >= 23，就要申请好权限。如果您的App没有适配到Android6.0（即targetSDKVersion < 23），那么只需要在这里直接调用fetchSplashAD接口。
        if (Build.VERSION.SDK_INT >= 23) {
            checkAndRequestPermission();
        } else {
            // 如果是Android6.0以下的机器，默认在安装时获得了所有权限，可以直接调用SDK
            fetchSplashAD(activity, container, skipView, "1106507482", getPosId(), this, 0);
        }
    }

    private String getPosId() {
        return "1060824764651558";
    }

    /**
     *
     * ----------非常重要----------
     *
     * Android6.0以上的权限适配简单示例：
     *
     * 如果targetSDKVersion >= 23，那么必须要申请到所需要的权限，再调用广点通SDK，否则广点通SDK不会工作。
     *
     * Demo代码里是一个基本的权限申请示例，请开发者根据自己的场景合理地编写这部分代码来实现权限申请。
     * 注意：下面的`checkSelfPermission`和`requestPermissions`方法都是在Android6.0的SDK中增加的API，如果您的App还没有适配到Android6.0以上，则不需要调用这些方法，直接调用广点通SDK即可。
     */
    @TargetApi(Build.VERSION_CODES.M)
    private void checkAndRequestPermission() {
        List<String> lackedPermission = new ArrayList<String>();
        if (!(activity.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED)) {
            lackedPermission.add(Manifest.permission.READ_PHONE_STATE);
        }

        if (!(activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED)) {
            lackedPermission.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
        }

        if (!(activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)) {
            lackedPermission.add(Manifest.permission.ACCESS_FINE_LOCATION);
        }

        // 权限都已经有了，那么直接调用SDK
        if (lackedPermission.size() == 0) {
            fetchSplashAD(activity, container, skipView, "1106507482", "1060824764651558", this, 0);
        } else {
            // 请求所缺少的权限，在onRequestPermissionsResult中再看是否获得权限，如果获得权限就可以调用SDK，否则不要调用SDK。
            String[] requestPermissions = new String[lackedPermission.size()];
            lackedPermission.toArray(requestPermissions);
        }
    }

    private boolean hasAllPermissionsGranted(int[] grantResults) {
        for (int grantResult : grantResults) {
            if (grantResult == PackageManager.PERMISSION_DENIED) {
                return false;
            }
        }
        return true;
    }


    /**
     * 拉取开屏广告，开屏广告的构造方法有3种，详细说明请参考开发者文档。
     *
     * @param activity        展示广告的activity
     * @param adContainer     展示广告的大容器
     * @param skipContainer   自定义的跳过按钮：传入该view给SDK后，SDK会自动给它绑定点击跳过事件。SkipView的样式可以由开发者自由定制，其尺寸限制请参考activity_splash.xml或者接入文档中的说明。
     * @param appId           应用ID
     * @param posId           广告位ID
     * @param adListener      广告状态监听器
     * @param fetchDelay      拉取广告的超时时长：取值范围[3000, 5000]，设为0表示使用广点通SDK默认的超时时长。
     */
    private void fetchSplashAD(Activity activity, ViewGroup adContainer, View skipContainer, String appId, String posId, SplashADListener adListener, int fetchDelay) {
        splashAD = new SplashAD(activity,appId, posId, adListener, fetchDelay);
        splashAD.fetchAndShowIn(adContainer);
    }

    //加载成功
    @Override
    public void onADPresent() {
        methodChannel.invokeMethod("show",null);
        Log.i("AD_DEMO", "onADPresent广告展示回传");
    }

    @Override
    public void onADClicked() {
        Log.i("AD_DEMO", "SplashADClicked clickUrl: " + (splashAD.getExt() != null ? splashAD.getExt().get("clickUrl") : ""));
    }

    /**
     * 倒计时回调，返回广告还将被展示的剩余时间。
     * 通过这个接口，开发者可以自行决定是否显示倒计时提示，或者还剩几秒的时候显示倒计时
     *
     * @param millisUntilFinished 剩余毫秒数
     */
    @Override
    public void onADTick(long millisUntilFinished) {
        Log.i("AD_DEMO", "SplashADTick " + millisUntilFinished + "ms");
//        skipView.setVisibility(View.VISIBLE);
//        skipView.setText(String.format(SKIP_TEXT, Math.round(millisUntilFinished / 1000f)));
    }

    @Override
    public void onADExposure() {
        Log.i("AD_DEMO", "SplashADExposure");
    }
    //广告关闭回传
    @Override
    public void onADDismissed() {
        methodChannel.invokeMethod("close",null);
        Log.i("AD_DEMO", "onADDismissed：广告关闭回传：4");
        next();
    }

    //onNoAD加载广告失败
    @Override
    public void onNoAD(AdError error) {
        /**
         * 为防止无广告时造成视觉上类似于"闪退"的情况，设定无广告时页面跳转根据需要延迟一定时间，demo
         * 给出的延时逻辑是从拉取广告开始算开屏最少持续多久，仅供参考，开发者可自定义延时逻辑，如果开发者采用demo
         * 中给出的延时逻辑，也建议开发者考虑自定义minSplashTimeWhenNoAD的值
         **/
        Log.i("AD_DEMO", String.format("LoadSplashADFail, eCode=%d, errorMsg=%s", error.getErrorCode(), error.getErrorMsg()));
        methodChannel.invokeMethod("error",null);
    }

    /**
     * 设置一个变量来控制当前开屏页面是否可以跳转，当开屏广告为普链类广告时，点击会打开一个广告落地页，此时开发者还不能打开自己的App主页。当从广告落地页返回以后，
     * 才可以跳转到开发者自己的App主页；当开屏广告是App类广告时只会下载App。
     */
    private void next() {
        canJump = true;
    }

    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {

    }
}
