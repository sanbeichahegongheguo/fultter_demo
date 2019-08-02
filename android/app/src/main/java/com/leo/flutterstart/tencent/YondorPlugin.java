package com.leo.flutterstart.tencent;

import android.app.Activity;


import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;

/** YondorPlugin */
public final class YondorPlugin  {
  /** Plugin registration. */
  public static void registerWith(PluginRegistry registry, Activity activity) {
    final String key = YondorPlugin.class.getCanonicalName();
    if (registry.hasPlugin(key)) return;
    PluginRegistry.Registrar registrar = registry.registrarFor(key);
    //这个banner就是flutter调用的依据
    registrar.platformViewRegistry().registerViewFactory("banner", new BannerViewFactory(new StandardMessageCodec(), activity, registrar.messenger()));
  }

}
