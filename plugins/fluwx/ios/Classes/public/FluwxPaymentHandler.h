//
// Created by mo on 2018/8/24.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FluwxPlugin.h"
#import "WXApiRequestHandler.h"
#import "WXApi.h"
@class StringUtil;


@interface FluwxPaymentHandler : NSObject
-(instancetype) initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)handlePayment:(FlutterMethodCall *)call result:(FlutterResult)result;
@end
