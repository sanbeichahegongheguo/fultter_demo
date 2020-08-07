package com.flutter_webview_plugin;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Point;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.webkit.WebStorage;
import android.widget.FrameLayout;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.os.Build;

import com.flutter_webview_plugin.byo.WebviewManagerByo;
import com.flutter_webview_plugin.tencent.BannerViewFactory;
import com.flutter_webview_plugin.tencent.SplashFactory;
import com.tencent.smtt.sdk.QbSdk;
import com.tencent.smtt.sdk.TbsVideo;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;

/**
 * FlutterWebviewPlugin
 */
public class FlutterWebviewPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {
    private Activity activity;
    private WebviewManagerInterface webViewManager;
    private Context context;
    public static MethodChannel channel;
    private static final String CHANNEL_NAME = "flutter_webview_plugin";
    private static final String JS_CHANNEL_NAMES_FIELD = "javascriptChannelNames";
    private int openType = 1;
    public static void registerWith(PluginRegistry.Registrar registrar) {
        if (registrar.activity() != null) {
            channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
            final FlutterWebviewPlugin instance = new FlutterWebviewPlugin(registrar.activity(), registrar.context());
            registrar.addActivityResultListener(instance);
            channel.setMethodCallHandler(instance);
            registrar.platformViewRegistry().registerViewFactory("banner", new BannerViewFactory(new StandardMessageCodec(), registrar.activity(), registrar.messenger()));
            registrar.platformViewRegistry().registerViewFactory("splash", new SplashFactory(new StandardMessageCodec(), registrar.activity(), registrar.messenger()));
        }
    }

    FlutterWebviewPlugin(Activity activity, Context context) {
        this.activity = activity;
        this.context = context;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "launch":
                openUrl(call, result);
                break;
            case "close":
                close(call, result);
                break;
            case "eval":
                eval(call, result);
                break;
            case "resize":
                resize(call, result);
                break;
            case "reload":
                reload(call, result);
                break;
            case "back":
                back(call, result);
                break;
            case "forward":
                forward(call, result);
                break;
            case "hide":
                hide(call, result);
                break;
            case "show":
                show(call, result);
                break;
            case "reloadUrl":
                reloadUrl(call, result);
                break;
            case "stopLoading":
                stopLoading(call, result);
                break;
            case "cleanCookies":
                cleanCookies(call, result);
                break;
            case "canGoBack":
                canGoBack(result);
                break;
            case "canGoForward":
                canGoForward(result);
                break;
            case "cleanCache":
                cleanCache(result);
                break;
            case "initX5":
                initX5(call,result);
                break;
            case "canUseTbsPlayer":
                canUseTbsPlayer(call,result);
                break;
            case "openVideo":
                openVideo(call,result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void cleanCache(MethodChannel.Result result) {
        webViewManager.cleanCache();
        WebStorage.getInstance().deleteAllData();
        result.success(null);
    }

    void openUrl(MethodCall call, MethodChannel.Result result) {
        boolean hidden = call.argument("hidden");
        String url = call.argument("url");
        String userAgent = call.argument("userAgent");
        boolean withJavascript = call.argument("withJavascript");
        boolean clearCache = call.argument("clearCache");
        boolean clearCookies = call.argument("clearCookies");
        boolean mediaPlaybackRequiresUserGesture = call.argument("mediaPlaybackRequiresUserGesture");
        boolean withZoom = call.argument("withZoom");
        boolean displayZoomControls = call.argument("displayZoomControls");
        boolean withLocalStorage = call.argument("withLocalStorage");
        boolean withOverviewMode = call.argument("withOverviewMode");
        boolean supportMultipleWindows = call.argument("supportMultipleWindows");
        boolean appCacheEnabled = call.argument("appCacheEnabled");
        Map<String, String> headers = call.argument("headers");
        boolean scrollBar = call.argument("scrollBar");
        boolean allowFileURLs = call.argument("allowFileURLs");
        boolean useWideViewPort = call.argument("useWideViewPort");
        String invalidUrlRegex = call.argument("invalidUrlRegex");
        boolean geolocationEnabled = call.argument("geolocationEnabled");
        boolean debuggingEnabled = call.argument("debuggingEnabled");
        boolean ignoreSSLErrors = call.argument("ignoreSSLErrors");
        if (call.hasArgument("openType")){
            openType = call.argument("openType");
        }

        if (webViewManager == null || webViewManager.getClosed() == true) {
            Map<String, Object> arguments = (Map<String, Object>) call.arguments;
            List<String> channelNames = new ArrayList();
            if (arguments.containsKey(JS_CHANNEL_NAMES_FIELD)) {
                channelNames = (List<String>) arguments.get(JS_CHANNEL_NAMES_FIELD);
            }
            if (openType ==2){
                webViewManager = new WebviewManagerByo(activity, context, channelNames);
            }else{
                webViewManager = new WebviewManager(activity, context, channelNames);
            }
        }

        FrameLayout.LayoutParams params = buildLayoutParams(call);
        if (this.openType==2){
            android.webkit.WebView webView = webViewManager.getWebView();
            activity.addContentView(webView , params);
        }else{
            com.tencent.smtt.sdk.WebView webView = webViewManager.getWebView();
            activity.addContentView(webView , params);
        }

        webViewManager.openUrl(withJavascript,
                clearCache,
                hidden,
                clearCookies,
                mediaPlaybackRequiresUserGesture,
                userAgent,
                url,
                headers,
                withZoom,
                displayZoomControls,
                withLocalStorage,
                withOverviewMode,
                scrollBar,
                supportMultipleWindows,
                appCacheEnabled,
                allowFileURLs,
                useWideViewPort,
                invalidUrlRegex,
                geolocationEnabled,
                debuggingEnabled,
                ignoreSSLErrors
        );
        result.success(null);
    }

    private FrameLayout.LayoutParams buildLayoutParams(MethodCall call) {
        Map<String, Number> rc = call.argument("rect");
        FrameLayout.LayoutParams params;
        if (rc != null) {
            params = new FrameLayout.LayoutParams(
                    dp2px(activity, rc.get("width").intValue()), dp2px(activity, rc.get("height").intValue()));
            params.setMargins(dp2px(activity, rc.get("left").intValue()), dp2px(activity, rc.get("top").intValue()),
                    0, 0);
        } else {
            Display display = activity.getWindowManager().getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);
            int width = size.x;
            int height = size.y;
            params = new FrameLayout.LayoutParams(width, height);
        }

        return params;
    }

    private void stopLoading(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.stopLoading(call, result);
        }
        result.success(null);
    }

    void close(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.close(call, result);
            webViewManager = null;
        }
    }

    /**
     * Checks if can navigate back
     *
     * @param result
     */
    private void canGoBack(MethodChannel.Result result) {
        if (webViewManager != null) {
            result.success(webViewManager.canGoBack());
        } else {
            result.error("Webview is null", null, null);
        }
    }

    /**
     * Navigates back on the Webview.
     */
    private void back(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.back(call, result);
        }
        result.success(null);
    }

    /**
     * Checks if can navigate forward
     * @param result
     */
    private void canGoForward(MethodChannel.Result result) {
        if (webViewManager != null) {
            result.success(webViewManager.canGoForward());
        } else {
            result.error("Webview is null", null, null);
        }
    }

    /**
     * Navigates forward on the Webview.
     */
    private void forward(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.forward(call, result);
        }
        result.success(null);
    }

    /**
     * Reloads the Webview.
     */
    private void reload(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.reload(call, result);
        }
        result.success(null);
    }

    private void reloadUrl(MethodCall call, MethodChannel.Result result) {
        if (webViewManager != null) {
            String url = call.argument("url");
            Map<String, String> headers = call.argument("headers");
            if (headers != null) {
                webViewManager.reloadUrl(url, headers);
            } else {
                webViewManager.reloadUrl(url);
            }

        }
        result.success(null);
    }

    private void eval(MethodCall call, final MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.eval(call, result);
        }
    }

    private void resize(MethodCall call, final MethodChannel.Result result) {
        if (webViewManager != null) {
            FrameLayout.LayoutParams params = buildLayoutParams(call);
            webViewManager.resize(params);
        }
        result.success(null);
    }

    private void hide(MethodCall call, final MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.hide(call, result);
        }
        result.success(null);
    }

    private void show(MethodCall call, final MethodChannel.Result result) {
        if (webViewManager != null) {
            webViewManager.show(call, result);
        }
        result.success(null);
    }

    private void cleanCookies(MethodCall call, final MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
                @Override
                public void onReceiveValue(Boolean aBoolean) {

                }
            });
        } else {
            CookieManager.getInstance().removeAllCookie();
        }
        result.success(null);
    }

    private int dp2px(Context context, float dp) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }

    @Override
    public boolean onActivityResult(int i, int i1, Intent intent) {
        if (webViewManager != null && webViewManager.getResultHandler() != null) {
            if (this.openType==2){
                WebviewManagerByo.ResultHandler resultHandler = webViewManager.getResultHandler();
                return resultHandler.handleResult(i, i1, intent);
            }else{
                WebviewManager.ResultHandler resultHandler = webViewManager.getResultHandler();
                return resultHandler.handleResult(i, i1, intent);
            }
        }
        return false;
    }

    void initX5(MethodCall call, MethodChannel.Result result) {
        final  MethodChannel.Result resp = result;
        QbSdk.initX5Environment(context, new QbSdk.PreInitCallback() {
            @Override
            public void onCoreInitFinished() {
                Log.i("WebViewFlutterPlugin","onCoreInitFinished");
            }

            @Override
            public void onViewInitFinished(boolean b) {
                //x5內核初始化完成的回调，为true表示x5内核加载成功，否则表示x5内核加载失败，会自动切换到系统内核。
                Log.i("onViewInitFinished","onViewInitFinished" + b);
                resp.success(b);
            }
        });
    }
    void canUseTbsPlayer(MethodCall call, MethodChannel.Result result) {
        //返回是否可以使用tbsPlayer
        result.success(TbsVideo.canUseTbsPlayer(context));
    }
    void openVideo(MethodCall call, MethodChannel.Result result) {
        //返回是否可以使用tbsPlayer
        String url = call.argument("url");
        Integer screenMode = 103 ;
        if (null!=call.argument("screenMode")){
            screenMode = Integer.parseInt(call.argument("screenMode").toString());
        }
        Bundle bundle = new Bundle();
        bundle.putInt("screenMode", screenMode);
        TbsVideo.openVideo(context, url, bundle);
        result.success(null);
    }
}
