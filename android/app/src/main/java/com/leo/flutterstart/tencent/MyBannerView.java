package com.leo.flutterstart.tencent;

import android.app.Activity;
import android.graphics.Point;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;


import com.qq.e.ads.banner2.UnifiedBannerADListener;
import com.qq.e.ads.banner2.UnifiedBannerView;
import com.qq.e.comm.util.AdError;
import java.util.Map;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class MyBannerView implements PlatformView, MethodChannel.MethodCallHandler {
    private UnifiedBannerView bannerView;
    private LinearLayout linearLayout;
    private Activity activity;
    private String bannerId;
    private String appId;
    private int refresh = 0;
    MyBannerView(Activity activity, BinaryMessenger messenger, int id, Map<String, Object> params) {
        MethodChannel methodChannel = new MethodChannel(messenger, "banner_" + id);
        methodChannel.setMethodCallHandler(this);
        this.activity = activity;
        if (null!=params){
            if(params.containsKey("appId")){
                appId = (String)params.get("appId");
            }
            if(params.containsKey("bannerId")){
                bannerId = (String)params.get("bannerId");
            }
            if(params.containsKey("refresh")){
                refresh = (Integer)params.get("refresh");
            }
        }
        if (linearLayout == null) {
            linearLayout = new LinearLayout(activity);
        }
        loadAD();
    }

    @Override
    public View getView() {
        return linearLayout;
    }

    @Override
    public void dispose() {
        if (bannerView != null){
            bannerView.destroy();
            Log.i("BannerView", "dispose");
        }
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "loadAD":
                loadAD();
                break;
            default:
                result.notImplemented();
        }
    }

    private void loadAD() {
        //按照官方demo先销毁
        if(this.bannerView != null){
            linearLayout.removeView(bannerView);
            bannerView.destroy();
        }

        bannerView = new UnifiedBannerView(activity, appId, bannerId, new UnifiedBannerADListener() {
            @Override
            public void onNoAD(AdError adError) {
                Log.i("BannerView", "code :"+adError.getErrorCode()+" msg:"+adError.getErrorMsg());
            }

            @Override
            public void onADReceive() {
                Log.i("BannerView", " 广告加载成功回调");
            }

            @Override
            public void onADExposure() {
                Log.i("BannerView", " 当广告曝光时发起的回调");

            }

            @Override
            public void onADClosed() {
                Log.i("BannerView", "当广告关闭时调用");
            }

            @Override
            public void onADClicked() {
                Log.i("BannerView", "当广告点击时发起的回调，由于点击去重等原因可能和平台最终的统计数据有差异");
            }

            @Override
            public void onADLeftApplication() {
                Log.i("BannerView", " 由于广告点击离开 APP 时调用");
            }

            @Override
            public void onADOpenOverlay() {
                Log.i("BannerView", "当广告打开浮层时调用，如打开内置浏览器、内容展示浮层，一般发生在点击之后");
            }

            @Override
            public void onADCloseOverlay() {
                Log.i("BannerView", "浮层关闭时调用");
            }
        });
        bannerView.setRefresh(refresh);
        linearLayout.addView(bannerView,getUnifiedBannerLayoutParams());
        bannerView.loadAD();
    }
    /**
     * banner2.0规定banner宽高比应该为6.4:1 , 开发者可自行设置符合规定宽高比的具体宽度和高度值
     *
     * @return
     */
    private FrameLayout.LayoutParams getUnifiedBannerLayoutParams() {
        Point screenSize = new Point();
        activity.getWindowManager().getDefaultDisplay().getSize(screenSize);
        return new FrameLayout.LayoutParams(screenSize.x,  Math.round(screenSize.x / 6.4F));
    }

}
