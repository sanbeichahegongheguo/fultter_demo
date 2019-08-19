
#import <Foundation/Foundation.h>

@interface NetWorkInfoManager : NSObject


+ (instancetype)sharedManager;

/** 获取ip */
- (NSString *)getDeviceIPAddresses;

- (NSString *)getIpAddressWIFI;
- (NSString *)getIpAddressCell;

@end
