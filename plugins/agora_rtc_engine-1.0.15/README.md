## [for 3.0.1 dev version](https://github.com/AgoraIO/Flutter-SDK/tree/dev/3.0.0)
### We suggest you use the dev version and welcome to communicate with us by creating issues.

# AgoraRtcEngine

![pub package](https://img.shields.io/pub/v/agora_rtc_engine.svg)

This Flutter plugin is a wapper for [Agora Video SDK](https://docs.agora.io/en).

Agora.io provides building blocks for you to add real-time voice and video communications through a simple and powerful SDK. You can integrate the Agora SDK to enable real-time communications in your own application quickly.

*Note*: This plugin is still under development, and some APIs might not be available yet.

## Usage

To use this plugin, add `agora_rtc_engine` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started

* See the [example](example) directory for a sample app using AgoraRtcEngine.
* Or checkout this [tutorial](https://github.com/AgoraIO-Community/Agora-Flutter-Quickstart) for a simple video call app using Agora Flutter SDK.

## Device Permission

Agora Video SDK requires camera and microphone permission to start video call.

### Android

Open the *AndroidManifest.xml* file and add the required device permissions to the file.

```xml
..
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- The Agora SDK requires Bluetooth permissions in case users are using Bluetooth devices.-->
<uses-permission android:name="android.permission.BLUETOOTH" />
..
```

### iOS

Open the *info.plist* and add:

- Privacy - Microphone Usage Description, and add a note in the Value column.
- Privacy - Camera Usage Description, and add a note in the Value column.

Your application can still run the voice call when it is switched to the background if the background mode is enabled. Select the app target in Xcode, click the **Capabilities** tab, enable **Background Modes**, and check **Audio, AirPlay, and Picture in Picture**.

## Error handling

### iOS black screen

Our SDK use `PlatformView`, you should set `io.flutter.embedded_views_preview` to `YES` in your *info.plist*

### iOS memory leak

If your flutter channel is stable, `PlatformView` will cause memory leak, you can run `flutter channel beta`

[You can refer to this pull request](https://github.com/flutter/engine/pull/14326)

### Android black screen

**Tips: please make sure your all configurations are correct, but still black screen**

If your MainActivity extends `io.flutter.embedding.android.FlutterActivity` and override the `configureFlutterEngine` method

#### stable flutter channel

The `FlutterEngine` class will register all plugins auto

The `GeneratedPluginRegistrant.registerWith(flutterEngine)` method has been added by default, so it causes the plugin register twice, our SDK may not work

If you remove the `GeneratedPluginRegistrant.registerWith(flutterEngine)` method, so some other plugins may not work because the plugin can't get the activity instance when register by `FlutterEngine`, 

***We suggest you don't use the stable channel, because the iOS platform also has memory leak bug***

#### others flutter channel

The `io.flutter.embedding.android.FlutterActivity` will register all plugins auto by the `configureFlutterEngine` method

* Don't forget add `super.configureFlutterEngine(flutterEngine)`
* Don't add `GeneratedPluginRegistrant.registerWith(flutterEngine)`

[You can refer to the official documents](https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration)

### Android Release crash

It causes by code obfuscation because of flutter set `android.enableR8=true` by the default

Add the following line in the *app/proguard-rules.pro* file to prevent code obfuscation:
```
-keep class io.agora.**{*;}
```

## How to contribute

To help work on this sdk, see our [contributor guide](CONTRIBUTING.md).
