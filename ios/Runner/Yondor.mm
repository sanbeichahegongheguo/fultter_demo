//
//  Generated file. Do not edit.
//

#import "Yondor.h"
#import "mnist.h"

@implementation Yondor

+ (void)registerYondor:(NSObject<FlutterPluginRegistrar>*)controller {
    NSObject<FlutterBinaryMessenger>* messenger = controller.messenger;
    FlutterMethodChannel *yondorChannel = [FlutterMethodChannel methodChannelWithName:@"yondor" binaryMessenger:messenger];
    
    
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
}

@end
