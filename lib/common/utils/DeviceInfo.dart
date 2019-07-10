import 'dart:io';

import 'package:device_info/device_info.dart';

class DeviceInfo{
  static DeviceInfo instance = new DeviceInfo();
  Map<String, dynamic> _deviceInfoMap;


  Future<String> getDeviceId() async {
    if (null==this._deviceInfoMap){
       await getDeviceInfo();
       print("DeviceInfo  ${_deviceInfoMap?.toString()}");
    }
    if(Platform.isAndroid) {
      return this._deviceInfoMap["androidId"];
    }else if (Platform.isIOS){
      return this._deviceInfoMap["identifierForVendor"];
    }
    return "";
  }


  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (null==this._deviceInfoMap){
      DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
      if(Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        this._deviceInfoMap = _readAndroidBuildData(androidInfo);
        return this._deviceInfoMap ;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        this._deviceInfoMap  = _readIosDeviceInfo(iosInfo);
        return this._deviceInfoMap ;
      }
    }
    return null;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}