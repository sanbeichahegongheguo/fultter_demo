// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.deviceinfo;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.provider.Settings;

import org.json.JSONException;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.lang.reflect.Field;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Arrays;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/** DeviceInfoPlugin */
public class DeviceInfoPlugin implements MethodCallHandler {
  private final Context context;

  /** Substitute for missing values. */
  private static final String[] EMPTY_STRING_LIST = new String[] {};

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/device_info");
    channel.setMethodCallHandler(new DeviceInfoPlugin(registrar.context()));
  }

  /** Do not allow direct instantiation. */
  private DeviceInfoPlugin(Context context) {
    this.context = context;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getAndroidDeviceInfo")) {
      Map<String, Object> build = new HashMap<>();
      build.put("board", Build.BOARD);
      build.put("bootloader", Build.BOOTLOADER);
      build.put("brand", Build.BRAND);
      build.put("device", Build.DEVICE);
      build.put("display", Build.DISPLAY);
      build.put("fingerprint", Build.FINGERPRINT);
      build.put("hardware", Build.HARDWARE);
      build.put("host", Build.HOST);
      build.put("id", Build.ID);
      build.put("manufacturer", Build.MANUFACTURER);
      build.put("model", Build.MODEL);
      build.put("serial", Build.SERIAL);
      build.put("product", Build.PRODUCT);
      if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
        build.put("supported32BitAbis", Arrays.asList(Build.SUPPORTED_32_BIT_ABIS));
        build.put("supported64BitAbis", Arrays.asList(Build.SUPPORTED_64_BIT_ABIS));
        build.put("supportedAbis", Arrays.asList(Build.SUPPORTED_ABIS));
      } else {
        build.put("supported32BitAbis", Arrays.asList(EMPTY_STRING_LIST));
        build.put("supported64BitAbis", Arrays.asList(EMPTY_STRING_LIST));
        build.put("supportedAbis", Arrays.asList(EMPTY_STRING_LIST));
      }
      build.put("tags", Build.TAGS);
      build.put("type", Build.TYPE);
      build.put("isPhysicalDevice", !isEmulator());
      build.put("androidId", getAndroidId());

      Map<String, Object> version = new HashMap<>();
      if (VERSION.SDK_INT >= VERSION_CODES.M) {
        version.put("baseOS", VERSION.BASE_OS);
        version.put("previewSdkInt", VERSION.PREVIEW_SDK_INT);
        version.put("securityPatch", VERSION.SECURITY_PATCH);
      }
      version.put("codename", VERSION.CODENAME);
      version.put("incremental", VERSION.INCREMENTAL);
      version.put("release", VERSION.RELEASE);
      version.put("sdkInt", VERSION.SDK_INT);
      build.put("version", version);
      result.success(build);
    } else if(call.method.equals("getYondorInfo") ){
      result.success(yondorInfo());
    }else {
      result.notImplemented();
    }
  }


  private  Map<String, Object> yondorInfo(){
    Map<String, Object> oj = new HashMap<>();
    oj.put("cd", new Date().getTime());
    oj.put("itd",(context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_LARGE); //判断是否平板设备
    oj.put("pb",android.os.Build.BRAND);//获取手机品牌
    oj.put("pm", android.os.Build.MODEL);//获取手机型号
    oj.put("bl",android.os.Build.VERSION.SDK_INT);//获取手机Android API等级
    oj.put("bv",android.os.Build.VERSION.RELEASE);//获取手机Android 版本
    String id ="|"+android.os.Build.SERIAL+"|"+getAndroidId();
    oj.put("kid",id);//获取设备的唯一标识，deviceId
    oj.put("vn",getVersionName());//返回版本名字
    oj.put("pf", "PARENT_APP");
    Field[] fields = Build.class.getDeclaredFields();
    for (Field field : fields) {
      field.setAccessible(true);
      try {
        if(field.getName().equals("SUPPORTED_32_BIT_ABIS")
                || field.getName().equals("SUPPORTED_64_BIT_ABIS")
                ||field.getName().equals("SUPPORTED_ABIS")
                ||field.getName().equals("UNKNOWN")){
          System.out.println("SUPPORTED_32_BIT_ABIS:"+field.get(null).toString());
        }else {
          Map<String, String> m = getField();
          if (m.containsKey(field.getName().toLowerCase())) {
            oj.put(m.get(field.getName().toLowerCase()), field.get(null).toString());
          }
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    oj.put("aid",getAndroidId());
    oj.put("lip",getLocalIpAddress());//ip
    return oj;
  }

  public String getLocalIpAddress() {
    try {
      for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
        NetworkInterface intf = en.nextElement();
        for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) {
          InetAddress inetAddress = enumIpAddr.nextElement();
          if (!inetAddress.isLoopbackAddress() ) {
            String ip =inetAddress.getHostAddress().toString();
            if(ip.indexOf("%")==-1){
              return ip;
            }else {
              return ip.substring(0,(ip.indexOf("%")));
            }
          }
        }
      }
    } catch (SocketException ex) {
      Log.e ("WifiPreference IpAddress", ex.toString() );
    }
    return null;
  }
  private Map<String,String> getField(){
    Map<String,String>  m =  new HashMap<String,String>() ;
    m.put("serial","sl");
    m.put("board","board");
    m.put("bootloader","bld");
    m.put("brand","brand");
    m.put("cpu_abi","ca");
    m.put("cpu_abi2","ca2");
    m.put("device","device");
    m.put("display","dp");
    m.put("fingerprint","fp");
    m.put("hardware","hw");
    m.put("host","host");
    m.put("id","id");
    m.put("is_debuggable","idb");
    m.put("is_container","ic");
    m.put("is_emulator","ie");
    m.put("is_eng","ieg");
    m.put("is_treble_enabled","ite");
    m.put("is_userdebug","iud");
    m.put("is_user","iu");
    m.put("permissions_review_required","prr");
    m.put("auto_test_oneplus","ato");
    m.put("soft_version","sv");
    m.put("region","rn");
    m.put("manufacturer","mf");
    m.put("model","ml");
    m.put("product","pd");
    m.put("radio","rd");
    m.put("tag","tag");
    m.put("tags","tags");
    m.put("time","time");
    m.put("type","type");
    m.put("user","user");
    m.put("no_hota","nh");
    return m;
  }
  /**
   * 返回版本名字
   * 对应build.gradle中的versionName
   *
   * @return
   */
  private String getVersionName() {
    String versionName = "";
    try {
      PackageManager packageManager = context.getPackageManager();
      PackageInfo packInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
      versionName = packInfo.versionName;
    } catch (Exception e) {
      e.printStackTrace();
    }
    return versionName;
  }
  /**
   * Returns the Android hardware device ID that is unique between the device + user and app
   * signing. This key will change if the app is uninstalled or its data is cleared. Device factory
   * reset will also result in a value change.
   *
   * @return The android ID
   */
  @SuppressLint("HardwareIds")
  private String getAndroidId() {
    return Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
  }

  /**
   * A simple emulator-detection based on the flutter tools detection logic and a couple of legacy
   * detection systems
   */
  private boolean isEmulator() {
    return (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
        || Build.FINGERPRINT.startsWith("generic")
        || Build.FINGERPRINT.startsWith("unknown")
        || Build.HARDWARE.contains("goldfish")
        || Build.HARDWARE.contains("ranchu")
        || Build.MODEL.contains("google_sdk")
        || Build.MODEL.contains("Emulator")
        || Build.MODEL.contains("Android SDK built for x86")
        || Build.MANUFACTURER.contains("Genymotion")
        || Build.PRODUCT.contains("sdk_google")
        || Build.PRODUCT.contains("google_sdk")
        || Build.PRODUCT.contains("sdk")
        || Build.PRODUCT.contains("sdk_x86")
        || Build.PRODUCT.contains("vbox86p")
        || Build.PRODUCT.contains("emulator")
        || Build.PRODUCT.contains("simulator");
  }
}
