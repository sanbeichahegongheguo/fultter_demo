// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "DeviceInfoPlugin.h"
#import "DeviceInfoManager.h"
#import <sys/utsname.h>

@implementation FLTDeviceInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/device_info"
                                  binaryMessenger:[registrar messenger]];
  FLTDeviceInfoPlugin* instance = [[FLTDeviceInfoPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getIosDeviceInfo" isEqualToString:call.method]) {
    UIDevice* device = [UIDevice currentDevice];
    struct utsname un;
    uname(&un);

    result(@{
      @"name" : [device name],
      @"systemName" : [device systemName],
      @"systemVersion" : [device systemVersion],
      @"model" : [device model],
      @"localizedModel" : [device localizedModel],
      @"identifierForVendor" : [[device identifierForVendor] UUIDString],
      @"isPhysicalDevice" : [self isDevicePhysical],
      @"utsname" : @{
        @"sysname" : @(un.sysname),
        @"nodename" : @(un.nodename),
        @"release" : @(un.release),
        @"version" : @(un.version),
        @"machine" : @(un.machine),
      }
    });
  }else if([@"getYondorInfo" isEqualToString:call.method]){
    NSString *cpuName = [[DeviceInfoManager sharedManager] getCPUProcessor];
    //   NSLog(@"http back cpuName 名称：%@",cpuName);
    NSUInteger cpuCount = [[DeviceInfoManager sharedManager] getCPUCount];
    //     NSLog(@"http back cpuCount cup数目：%@",@(cpuCount));
    CGFloat cpuUsage = [[DeviceInfoManager sharedManager] getCPUUsage];
    //     NSLog(@"http back cpuUsage 使用总比例：%@",@(cpuUsage));
    NSUInteger cpuFrequency = [[DeviceInfoManager sharedManager] getCPUFrequency];
    //     NSLog(@"http back cpuFrequency 频率：%@",@(cpuFrequency));
    NSArray *perCPUArr = [[DeviceInfoManager sharedManager] getPerCPUUsage];
    //     NSLog(@"http back perCPUArr 各个CPU使用频率：%@",perCPUArr);
    NSMutableString *perCPUUsage = [NSMutableString string];
    //NSString *perCPUS =@"";
    for (NSNumber *per in perCPUArr) {
        [perCPUUsage appendFormat:@"%.2f,", per.floatValue];
    }
    NSString *applicationSize = [[DeviceInfoManager sharedManager] getApplicationSize];
    //    NSLog(@"当前 App 所占内存空间：%@",applicationSize);
    int64_t totalDisk = [[DeviceInfoManager sharedManager] getTotalDiskSpace];
    NSString *totalDiskInfo = [NSString stringWithFormat:@"%.2f", totalDisk/1024/1024.0];
    //  NSLog(@"磁盘总空间：%@",totalDiskInfo);
    int64_t usedDisk = [[DeviceInfoManager sharedManager] getUsedDiskSpace];
    NSString *usedDiskInfo = [NSString stringWithFormat:@"%.2f", usedDisk/1024/1024.0];
    //   NSLog(@"磁盘 已使用空间：%@",usedDiskInfo);
    int64_t freeDisk = [[DeviceInfoManager sharedManager] getFreeDiskSpace];
    NSString *freeDiskInfo = [NSString stringWithFormat:@"%.2f", freeDisk/1024/1024.0];
    //   NSLog(@"磁盘空闲空间：%@",freeDiskInfo);
    int64_t totalMemory = [[DeviceInfoManager sharedManager] getTotalMemory];
    NSString *totalMemoryInfo = [NSString stringWithFormat:@"%.2f", totalMemory/1024/1024.0];
    //    NSLog(@"系统总内存空间：%@",totalMemoryInfo);
    int64_t freeMemory = [[DeviceInfoManager sharedManager] getFreeMemory];
    NSString *freeMemoryInfo = [NSString stringWithFormat:@"%.2f", freeMemory/1024/1024.0];
    //   NSLog(@"空闲的内存空间：%@",freeMemoryInfo);
    int64_t usedMemory = [[DeviceInfoManager sharedManager] getFreeDiskSpace];
    NSString *usedMemoryInfo = [NSString stringWithFormat:@"%.2f", usedMemory/1024/1024.0];
    //   NSLog(@"已使用的内存空间：%@",usedMemoryInfo);
    int64_t activeMemory = [[DeviceInfoManager sharedManager] getActiveMemory];
    NSString *activeMemoryInfo = [NSString stringWithFormat:@"%.2f", activeMemory/1024/1024.0];
    //  NSLog(@"活跃的内存：%@",activeMemoryInfo);
    int64_t inActiveMemory = [[DeviceInfoManager sharedManager] getInActiveMemory];
    NSString *inActiveMemoryInfo = [NSString stringWithFormat:@"%.2f", inActiveMemory/1024/1024.0];
    //  NSLog(@"最近使用过：%@",inActiveMemoryInfo);
    int64_t wiredMemory = [[DeviceInfoManager sharedManager] getWiredMemory];
    NSString *wiredMemoryInfo = [NSString stringWithFormat:@"%.2f", wiredMemory/1024/1024.0];
    //  NSLog(@"用来存放内核和数据结构的内存：%@",wiredMemoryInfo);
    int64_t purgableMemory = [[DeviceInfoManager sharedManager] getPurgableMemory];
    NSString *purgableMemoryInfo = [NSString stringWithFormat:@"%.2f", purgableMemory/1024/1024.0];
    //  NSLog(@"可释放的内存空间：内存吃紧自动释放：%@",purgableMemoryInfo);

    // 广告位标识符：在同一个设备上的所有App都会取到相同的值，是苹果专门给各广告提供商用来追踪用户而设的，用户可以在 设置|隐私|广告追踪里重置此id的值，或限制此id的使用，故此id有可能会取不到值，但好在Apple默认是允许追踪的，而且一般用户都不知道有这么个设置，所以基本上用来监测推广效果，是戳戳有余了
    NSString *idfa = [[DeviceInfoManager sharedManager] getIDFA];
    //  NSLog(@"广告位标识符idfa：%@",idfa);
    //  UUID是Universally Unique Identifier的缩写，中文意思是通用唯一识别码。它是让分布式系统中的所有元素，都能有唯一的辨识资讯，而不需要透过中央控制端来做辨识资讯的指 定。这样，每个人都可以建立不与其它人冲突的 UUID。在此情况下，就不需考虑数据库建立时的名称重复问题。苹果公司建议使用UUID为应用生成唯一标识字符串。
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //  NSLog(@"唯一识别码uuid：%@",uuid);
    NSString *device_token_crc32 = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token_crc32"] ? : @"";
    //  NSLog(@"device_token_crc32真机测试才会显示：%@",device_token_crc32);
    NSString *macAddress = [[DeviceInfoManager sharedManager] getMacAddress];
    //  NSLog(@"macAddress：%@",macAddress);
    NSString *deviceIP = [[NetWorkInfoManager sharedManager] getDeviceIPAddresses];
    //  NSLog(@"deviceIP：%@",deviceIP);
    NSString *cellIP = [[NetWorkInfoManager sharedManager] getIpAddressCell];
    //  NSLog(@"蜂窝地址：%@",cellIP);
    NSString *wifiIP = [[NetWorkInfoManager sharedManager] getIpAddressWIFI];
    //  NSLog(@"WIFI IP地址：%@",wifiIP);

    const NSString *deviceName = [[DeviceInfoManager sharedManager] getDeviceName];
    //  NSLog(@"设备型号：%@",[deviceName copy]);
    NSString *iPhoneName = [UIDevice currentDevice].name;
    //  NSLog(@"设备名称：%@",iPhoneName);
    NSString *deviceColor = [[DeviceInfoManager sharedManager] getDeviceColor];
    //  NSLog(@"设备颜色(Private API)：%@",deviceColor);
    NSString *deviceEnclosureColor = [[DeviceInfoManager sharedManager] getDeviceEnclosureColor];
    //  NSLog(@"设备外壳颜色(Private API)：%@",deviceEnclosureColor);
    NSString *appVerion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //  NSLog(@"app版本号：%@",appVerion);
    NSString *device_model = [[DeviceInfoManager sharedManager] getDeviceModel];
    //  NSLog(@"device_model：%@",device_model);
    NSString *localizedModel = [UIDevice currentDevice].localizedModel;
    //  NSLog(@"localizedModel：%@",localizedModel);
    NSString *systemName = [UIDevice currentDevice].systemName;
    //  NSLog(@"当前系统名称：%@",systemName);
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    //  NSLog(@"当前系统版本号：%@",systemVersion);
    const NSString *initialFirmware = [[DeviceInfoManager sharedManager] getInitialFirmware];
    // NSLog(@"设备支持最低系统版本：%@",[initialFirmware copy]);
    const NSString *latestFirmware = [[DeviceInfoManager sharedManager] getLatestFirmware];
    // NSLog(@"设备支持的最高系统版本：%@",[latestFirmware copy]);
    BOOL canMakePhoneCall = [DeviceInfoManager sharedManager].canMakePhoneCall;
    // NSLog(@"能否打电话：%@",@(canMakePhoneCall));
    NSDate *systemUptime = [[DeviceInfoManager sharedManager] getSystemUptime];
    // NSLog(@"设备上次重启的时间：%@",systemUptime);
    NSUInteger busFrequency = [[DeviceInfoManager sharedManager] getBusFrequency];
    // NSLog(@"当前设备的总线频率Bus Frequency：%@",@(busFrequency));
    NSUInteger ramSize = [[DeviceInfoManager sharedManager] getRamSize];
    // NSLog(@"当前设备的主存大小(随机存取存储器（Random Access Memory)：%@",@(ramSize));

    BatteryInfoManager *batteryManager = [BatteryInfoManager sharedManager];
    CGFloat batteryLevel = [[UIDevice currentDevice] batteryLevel];
    NSString *levelValue = [NSString stringWithFormat:@"%.2f", batteryLevel];
    //NSLog(@"电池电量：%@",levelValue);
    NSInteger batteryCapacity = batteryManager.capacity;
    NSString *capacityValue = [NSString stringWithFormat:@"%ld", batteryCapacity];
    //NSLog(@"电池容量：%@",capacityValue);
    CGFloat batteryMAH = batteryCapacity * batteryLevel;
    NSString *mahValue = [NSString stringWithFormat:@"%.2f", batteryMAH];
    //NSLog(@"当前电池剩余电量：%@",mahValue);
    CGFloat batteryVoltage = batteryManager.voltage;
    NSString *voltageValue = [NSString stringWithFormat:@"%.2f", batteryVoltage];
    //NSLog(@"电池电压：%@",voltageValue);
    NSString *batterStatus = batteryManager.status ? : @"unkonwn";
    //时间
    NSDate *date = [NSDate new];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    double i=time;      //NSTimeInterval返回的是double类型
    NSString *timeIntervalStr = [NSString stringWithFormat:@"%.f", i];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:systemUptime];
    result(@{
      @"cd" : timeIntervalStr,
      @"pf" : @"PARENT_APP",
      //cpu 5
      @"cn" : cpuName,
      @"cc" : @(cpuCount),
      @"cu" : @(cpuUsage),
      @"cf" : @(cpuFrequency),
      @"pca" : perCPUUsage,
      //内存，磁盘 11
      @"as" : applicationSize,
      @"tdi" : totalDiskInfo,
      @"udi" : usedDiskInfo,
      @"fdi" : freeDiskInfo,
      @"tmi" :totalMemoryInfo,
      @"fmi" : freeMemoryInfo,
      @"umi" : usedMemoryInfo,
      @"ami" : activeMemoryInfo,
      @"iami" : inActiveMemoryInfo,
      @"wmi" : wiredMemoryInfo,
      @"pmi" : purgableMemoryInfo,
      //设备，手机 11
      @"idfa" : idfa,
      @"uuid" : uuid,
      @"dtc" : device_token_crc32,
      @"ma" : macAddress,
      @"di" : deviceIP,
      @"ci" : cellIP,
      @"wi" : wifiIP,
      @"dn" : deviceName,
      @"in" : iPhoneName,
      @"dc" : deviceColor,
      @"dec" : deviceEnclosureColor,
      //电量，IP 16
       @"av" : appVerion,
       @"dm" : device_model,
       @"lm" : localizedModel,
       @"sn" : systemName,
       @"sv" : systemVersion,
       @"ifw" : initialFirmware,
       @"lf" : latestFirmware,
       @"cmpc" : @(canMakePhoneCall),
       @"su" : strDate,
       @"bf" : @(busFrequency),
       @"rs" : @(ramSize/1024/1024),
       @"lv" : levelValue,
       @"cv" : capacityValue,
       @"mv" : mahValue,
       @"vv" : voltageValue,
       @"bs" : batterStatus,
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

// return value is false if code is run on a simulator
- (NSString*)isDevicePhysical {
#if TARGET_OS_SIMULATOR
  NSString* isPhysicalDevice = @"false";
#else
  NSString* isPhysicalDevice = @"true";
#endif

  return isPhysicalDevice;
}

@end
