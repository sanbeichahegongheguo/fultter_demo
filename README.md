# flutter_start

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

DEBUG:

flutter  build apk --debug --target-platform=android-arm

Android:
editable_text.dart
    set selection(TextSelection newSelection) {
      if (newSelection.start > text.length || newSelection.end > text.length)
        //throw FlutterError('invalid text selection: $newSelection');
text.dart
    this.textScaleFactor = 1



    #configuration.allowsInlineMediaPlayback = YES;
    #configuration.mediaPlaybackRequiresUserAction = false;
    #_webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    #_navigationDelegate = [[FLTWKNavigationDelegate alloc] initWithChannel:_channel];
    #_webView.navigationDelegate = _navigationDelegate;
    #_webView.scrollView.bounces = false;//禁止滑动