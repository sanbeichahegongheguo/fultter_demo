#import "FluwxLaunchMiniProgramHandler.h"
#import "WXApiRequestHandler.h"
#import "FluwxKeys.h"

@implementation FluwxLaunchMiniProgramHandler

- (instancetype)initWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    self = [super init];
//    if (self) {
//
//    }

    return self;
}

- (void)handleLaunchMiniProgram:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *userName = call.arguments[@"userName"];
    NSString *path = call.arguments[@"path"];
//    WXMiniProgramType *miniProgramType = call.arguments[@"miniProgramType"];

    NSNumber *typeInt = call.arguments[@"miniProgramType"];
    WXMiniProgramType miniProgramType = WXMiniProgramTypeRelease;
    if([typeInt isEqualToNumber:@1]){
        miniProgramType =WXMiniProgramTypeTest;
    } else if([typeInt isEqualToNumber:@2]){
        miniProgramType = WXMiniProgramTypePreview;
    }

    BOOL done =  [WXApiRequestHandler launchMiniProgramWithUserName:userName
                                        path:path
                                        type:miniProgramType];
    result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});
}
@end
