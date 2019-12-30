package io.flutter.plugins.webviewflutter.flutter_webview_plugin;

import android.widget.FrameLayout;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public interface WebviewManagerInterface {
    void openUrl(
            boolean withJavascript,
            boolean clearCache,
            boolean hidden,
            boolean clearCookies,
            String userAgent,
            String url,
            Map<String, String> headers,
            boolean withZoom,
            boolean displayZoomControls,
            boolean withLocalStorage,
            boolean withOverviewMode,
            boolean scrollBar,
            boolean supportMultipleWindows,
            boolean appCacheEnabled,
            boolean allowFileURLs,
            boolean useWideViewPort,
            String invalidUrlRegex,
            boolean geolocationEnabled,
            boolean debuggingEnabled
    );
    void reloadUrl(String url);
    void reloadUrl(String url, Map<String, String> headers);
    void close(MethodCall call, MethodChannel.Result result);
    void close();
    void eval(MethodCall call, final MethodChannel.Result result);
    void reload(MethodCall call, MethodChannel.Result result);
    void back(MethodCall call, MethodChannel.Result result);
    void forward(MethodCall call, MethodChannel.Result result);
    void resize(FrameLayout.LayoutParams params);
    boolean canGoBack();
    boolean canGoForward();
    void cleanCache();
    void hide(MethodCall call, MethodChannel.Result result);
    void show(MethodCall call, MethodChannel.Result result);
    void stopLoading(MethodCall call, MethodChannel.Result result);
    void clearCookies();
    void cleanCookies(MethodCall call, final MethodChannel.Result result);
    boolean getClosed();
    <T> T getWebView();
    <T> T getResultHandler();
}
