#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "mnist.h"

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
            NSString *thickness = call.arguments[@"thickness"];
            NSString *isSave = call.arguments[@"isSave"];

            NSData *jsonData = [msg dataUsingEncoding:NSUTF8StringEncoding];

            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                options:NSJSONReadingMutableContainers
                                error:&err];
            if(err){
                XLog(@"%@：%@", tag, msg);
            }else{
                XLog(@"%@：%@", tag, dic);
            }

        }else{
            XLog(@"%@：%@", tag, msg);
        }
  }];



  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
