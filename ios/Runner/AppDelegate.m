#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "mnist.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
   didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel *yondorChannel = [FlutterMethodChannel methodChannelWithName:@"yondor" binaryMessenger:controller];
  [yondorChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
       if ([call.method isEqualToString:@"detectxy"]) {
                  NSString *pos = call.arguments[@"pos"];
                  float thickness = [call.arguments[@"thickness"] doubleValue];
                  bool isSave = [call.arguments[@"isSave"] boolValue];
                  NSString *res = mnistext::detectxy(pos,thickness,isSave);
                  result(res);
              }else{
                  result(FlutterMethodNotImplemented);
              }
  }];



  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
