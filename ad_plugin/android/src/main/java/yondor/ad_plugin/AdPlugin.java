package yondor.ad_plugin;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;

/** AdPlugin */
public class AdPlugin {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registrar.platformViewRegistry().registerViewFactory("banner", new BannerViewFactory(new StandardMessageCodec(), registrar.activity(), registrar.messenger()));
  }
}
