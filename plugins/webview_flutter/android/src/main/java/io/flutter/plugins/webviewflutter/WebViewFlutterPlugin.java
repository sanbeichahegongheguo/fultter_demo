// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.tencent.smtt.sdk.QbSdk;
import com.tencent.smtt.sdk.TbsVideo;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugins.webviewflutter.flutter_webview_plugin.FlutterWebviewPlugin;
import io.flutter.plugins.webviewflutter.tencent.BannerViewFactory;
import io.flutter.plugins.webviewflutter.tencent.SplashFactory;

/** WebViewFlutterPlugin */
public class WebViewFlutterPlugin implements MethodCallHandler {
  private Context context;
  private Activity activity;

  public WebViewFlutterPlugin(Context context, Activity activity) {
    this.context = context;
    this.activity = activity;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registrar.platformViewRegistry().registerViewFactory("plugins.flutter.io/webview", new WebViewFactory(registrar.messenger(), registrar.view(),registrar.activity()));
    registrar.platformViewRegistry().registerViewFactory("banner", new BannerViewFactory(new StandardMessageCodec(), registrar.activity(), registrar.messenger()));
    registrar.platformViewRegistry().registerViewFactory("splash", new SplashFactory(new StandardMessageCodec(), registrar.activity(), registrar.messenger()));
    FlutterCookieManager.registerWith(registrar.messenger());
    MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "plugins.flutter.io/webview");
    methodChannel.setMethodCallHandler(new WebViewFlutterPlugin(registrar.context(),registrar.activity()));
    FlutterWebviewPlugin.registerWith(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if ("init".equals(call.method)){
      final  MethodChannel.Result resp=result;
      QbSdk.initX5Environment(context, new QbSdk.PreInitCallback() {
        @Override
        public void onCoreInitFinished() {
          Log.i("WebViewFlutterPlugin","onCoreInitFinished");
        }

        @Override
        public void onViewInitFinished(boolean b) {
          //x5內核初始化完成的回调，为true表示x5内核加载成功，否则表示x5内核加载失败，会自动切换到系统内核。
          resp.success(b);
        }
      });
    }else if ("canUseTbsPlayer".equals(call.method)){
      //返回是否可以使用tbsPlayer
      result.success(TbsVideo.canUseTbsPlayer(context));
    }else if ("openVideo".equals(call.method)){
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
}
