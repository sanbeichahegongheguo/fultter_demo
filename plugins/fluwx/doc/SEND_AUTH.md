## Send Auth
We'll get a `code` by sending auth:
```dart
   import 'package:fluwx/fluwx.dart' as fluwx;
   fluwx.sendAuth(
         scope: "snsapi_userinfo", state: "wechat_sdk_demo_test")；
```
Getting `access_token` is not supported by `fluwx`.
