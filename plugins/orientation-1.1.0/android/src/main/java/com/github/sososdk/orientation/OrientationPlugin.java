package com.github.sososdk.orientation;

import android.app.Activity;
import android.view.OrientationEventListener;
import android.view.View;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.List;

import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_FULL_USER;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_USER;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE;
import static android.content.pm.ActivityInfo.SCREEN_ORIENTATION_USER_PORTRAIT;

/** OrientationPlugin */
public class OrientationPlugin implements MethodCallHandler {
  private final Activity activity;
  private final OrientationEventListener orientationEventListener;
  private EventChannel.EventSink eventSink;
  private int currentOrientation = SCREEN_ORIENTATION_UNSPECIFIED;

  public OrientationPlugin(Registrar registrar) {
    this.activity = registrar.activity();
    this.orientationEventListener = new OrientationEventListener(activity) {
      @Override public void onOrientationChanged(int angle) {
        if (eventSink != null) {
          sendOrientationChange(eventSink, convertAngle(angle));
        }
      }
    };
  }

  /** Plugin registration. */
  public static void registerWith(final Registrar registrar) {
    final OrientationPlugin plugin = new OrientationPlugin(registrar);
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "sososdk.github.com/orientation");
    channel.setMethodCallHandler(plugin);

    EventChannel eventChannel = new EventChannel(registrar.messenger(), "sososdk.github.com/orientationEvent");
    eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override public void onListen(Object o, EventChannel.EventSink eventSink) {
        plugin.enableOrientationEventListener(eventSink);
      }

      @Override public void onCancel(Object o) {
        plugin.disableOrientationEventListener();
      }
    });
  }

  private void enableOrientationEventListener(EventChannel.EventSink sink) {
    eventSink = sink;
    if (orientationEventListener.canDetectOrientation()) {
      orientationEventListener.enable();
    } else {
      eventSink.error("SensorError", "Cannot detect sensors. Not enabled", null);
    }
  }

  private void disableOrientationEventListener() {
    eventSink = null;
    orientationEventListener.disable();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    Object arguments = call.arguments;
    if (method.equals("SystemChrome.setEnabledSystemUIOverlays")) {
      setSystemChromeEnabledSystemUIOverlays((List) arguments);
      result.success(null);
    } else if (method.equals("SystemChrome.setPreferredOrientations")) {
      setSystemChromePreferredOrientations((List) arguments);
      result.success(null);
    } else if (method.equals("SystemChrome.forceOrientation")) {
      forceOrientation((String) arguments);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  private void setSystemChromeEnabledSystemUIOverlays(List overlaysToShow) {
    // Start by assuming we want to hide all system overlays (like an immersive game).
    int enabledOverlays = View.SYSTEM_UI_FLAG_VISIBLE
        | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        | View.SYSTEM_UI_FLAG_IMMERSIVE
        | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        | View.SYSTEM_UI_FLAG_FULLSCREEN
        | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION;
    // Re-add any desired system overlays.
    for (int i = 0; i < overlaysToShow.size(); ++i) {
      if (overlaysToShow.get(i).equals("SystemUiOverlay.top")) {
        enabledOverlays &= ~View.SYSTEM_UI_FLAG_FULLSCREEN;
      } else if (overlaysToShow.get(i).equals("SystemUiOverlay.bottom")) {
        enabledOverlays &= ~View.SYSTEM_UI_FLAG_HIDE_NAVIGATION;
      }
    }
    activity.getWindow().getDecorView().setSystemUiVisibility(enabledOverlays);
  }

  private void setSystemChromePreferredOrientations(List orientations) {
    int requestedOrientation = 0x00;
    for (int index = 0; index < orientations.size(); index += 1) {
      if (orientations.get(index).equals("DeviceOrientation.portraitUp")) {
        requestedOrientation |= 0x01;
      } else if (orientations.get(index).equals("DeviceOrientation.landscapeLeft")) {
        requestedOrientation |= 0x02;
      } else if (orientations.get(index).equals("DeviceOrientation.portraitDown")) {
        requestedOrientation |= 0x04;
      } else if (orientations.get(index).equals("DeviceOrientation.landscapeRight")) {
        requestedOrientation |= 0x08;
      }
    }
    switch (requestedOrientation) {
      case 0x00:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_UNSPECIFIED);
        break;
      case 0x01:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_PORTRAIT);
        break;
      case 0x02:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_LANDSCAPE);
        break;
      case 0x04:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_REVERSE_PORTRAIT);
        break;
      case 0x05:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_USER_PORTRAIT);
        break;
      case 0x08:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_REVERSE_LANDSCAPE);
        break;
      case 0x0a:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_USER_LANDSCAPE);
        break;
      case 0x0b:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_USER);
        break;
      case 0x0f:
        activity.setRequestedOrientation(SCREEN_ORIENTATION_FULL_USER);
        break;
      case 0x03: // portraitUp and landscapeLeft
      case 0x06: // portraitDown and landscapeLeft
      case 0x07: // portraitUp, portraitDown, and landscapeLeft
      case 0x09: // portraitUp and landscapeRight
      case 0x0c: // portraitDown and landscapeRight
      case 0x0d: // portraitUp, portraitDown, and landscapeRight
      case 0x0e: // portraitDown, landscapeLeft, and landscapeRight
        // Android can't describe these cases, so just default to whatever the first
        // specified value was.
        activity.setRequestedOrientation(SCREEN_ORIENTATION_FULL_USER);
        break;
    }
  }

  private void forceOrientation(String orientation) {
    if (orientation.equals("DeviceOrientation.portraitUp")) {
      activity.setRequestedOrientation(SCREEN_ORIENTATION_PORTRAIT);
    } else if (orientation.equals("DeviceOrientation.portraitDown")) {
      activity.setRequestedOrientation(SCREEN_ORIENTATION_REVERSE_PORTRAIT);
    } else if (orientation.equals("DeviceOrientation.landscapeLeft")) {
      activity.setRequestedOrientation(SCREEN_ORIENTATION_REVERSE_LANDSCAPE);
    } else if (orientation.equals("DeviceOrientation.landscapeRight")) {
      activity.setRequestedOrientation(SCREEN_ORIENTATION_LANDSCAPE);
    } else {
      activity.setRequestedOrientation(SCREEN_ORIENTATION_UNSPECIFIED);
    }
  }

  private static void sendOrientationChange(EventChannel.EventSink eventSink, int orientation) {
    String value = orientation(orientation);
    if (value != null) {
      eventSink.success(value);
    }
  }

  private static String orientation(int orientation) {
    if (orientation == SCREEN_ORIENTATION_PORTRAIT) {
      return "DeviceOrientation.portraitUp";
    } else if (orientation == SCREEN_ORIENTATION_REVERSE_PORTRAIT) {
      return "DeviceOrientation.portraitDown";
    } else if (orientation == SCREEN_ORIENTATION_LANDSCAPE) {
      return "DeviceOrientation.landscapeRight";
    } else if (orientation == SCREEN_ORIENTATION_REVERSE_LANDSCAPE) {
      return "DeviceOrientation.landscapeLeft";
    } else {
      return null;
    }
  }

  private int convertAngle(int angle) {
    if ((currentOrientation == 0 && (angle >= 300 || angle <= 60)) ||
        (currentOrientation == 1 && (angle >= 30 && angle <= 150)) ||
        (currentOrientation == 2 && (angle >= 120 && angle <= 240)) ||
        (currentOrientation == 3 && (angle >= 210 && angle <= 330))) {
    } else {
      currentOrientation = (angle + 45) % 360 / 90;
    }

    if (currentOrientation == 0) {
      return SCREEN_ORIENTATION_PORTRAIT;
    } else if (currentOrientation == 1) {
      return SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
    } else if (currentOrientation == 2) {
      return SCREEN_ORIENTATION_REVERSE_PORTRAIT;
    } else if (currentOrientation == 3) {
      return SCREEN_ORIENTATION_LANDSCAPE;
    } else {
      return SCREEN_ORIENTATION_UNSPECIFIED;
    }
  }
}
