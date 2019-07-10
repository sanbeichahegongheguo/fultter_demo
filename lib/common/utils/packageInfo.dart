import 'package:package_info/package_info.dart';
class Package{
  static Package instance = new Package();
  String appName;
  String packageName;
  String version;
  String buildNumber;
  Package() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      //APP名称
      appName = packageInfo.appName;
      //包名
      packageName = packageInfo.packageName;
      //版本名
      version = packageInfo.version;
      //版本号
      buildNumber = packageInfo.buildNumber;
    });
  }


}
