import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_start/common/config/config.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:uuid/uuid.dart';

import 'CommonUtils.dart';

class DeviceInfo {
  static DeviceInfo instance = new DeviceInfo();
  DeviceInfoPlugin _deviceInfo = new DeviceInfoPlugin();
  DeviceInfoPlugin get deviceInfo => _deviceInfo;
  String _osVersion;
  String get osVersion => _osVersion;
  Map<String, dynamic> _deviceInfoMap;
  String deviceId = "";
  String _yondorDeviceId = "";
  String _deviceUUID = "";
  bool _ios13;
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (null == this._deviceInfoMap) {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        this._deviceInfoMap = _readAndroidBuildData(androidInfo);
        return this._deviceInfoMap;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        _osVersion = iosInfo.systemVersion;
        this._deviceInfoMap = _readIosDeviceInfo(iosInfo);
        return this._deviceInfoMap;
      }
    }
    print(this._deviceInfoMap);
    return this._deviceInfoMap;
  }

  Future<String> getDeviceId() async {
    //直接返回
    if (ObjectUtil.isNotEmpty(this.deviceId)) {
      return this.deviceId;
    }

    if (null == this._deviceInfoMap) {
      await getDeviceInfo();
      print("DeviceInfo  ${_deviceInfoMap?.toString()}");
    }
    //根据平台获取deviceId
    if (Platform.isAndroid) {
      var imei = await ImeiPlugin.getImei();

      if (null != imei && imei == "Permission Denied") {
        this.deviceId = this._deviceInfoMap["androidId"];
      } else {
        this.deviceId = imei;
      }
    } else if (Platform.isIOS) {
      this.deviceId = this._deviceInfoMap["identifierForVendor"];
    }
    //如果deviceId不存在生成一个uid
    if (ObjectUtil.isEmptyString(this.deviceId)) {
      var uid = SpUtil.getString(Config.PHONE_UID);
      if (null == uid || uid == "") {
        uid = new Uuid().v1().replaceAll("-", "");
        SpUtil.putString(Config.PHONE_UID, uid);
      }
      this.deviceId = uid;
    }
    return this.deviceId;
  }

  Future<String> getDeviceUUID() async {
    if (null != _deviceUUID && _deviceUUID != "") {
      return _deviceUUID;
    }
    var uid = SpUtil.getString(Config.PHONE_UID);
    if (null == uid || uid == "") {
      uid = new Uuid().v1();
      SpUtil.putString(Config.PHONE_UID, uid);
    }
    _deviceUUID = uid;
    return uid;
  }

  Future<String> getYondorDeviceId() async {
    //直接返回
    if (ObjectUtil.isNotEmpty(this._yondorDeviceId)) {
      return this._yondorDeviceId;
    }

    var did = await this.getDeviceId();
    if (Platform.isAndroid) {
      var yondorInfo = await new DeviceInfo().deviceInfo.yondorInfo;
      did = did + yondorInfo["kid"];
    }
    this._yondorDeviceId = did;
    return this._yondorDeviceId;
  }

  bool ios13() {
    if (_ios13 == null) {
      if (Platform.isIOS) {
        _ios13 = CommonUtils.ios13();
      } else {
        _ios13 = true;
      }
    }
    return _ios13;
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
