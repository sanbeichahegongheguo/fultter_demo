#import "CameraPlugin.h"
#import "CameraMic.h"
#import <TOCropViewController/TOCropViewController.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>


@interface FLTCameraPlugin() <TOCropViewControllerDelegate>
@end

@implementation FLTCameraPlugin {
    FlutterResult _result;
    NSDictionary *_arguments;
    UIViewController *_viewController;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.yondor/camera"
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    FLTCameraPlugin* instance = [[FLTCameraPlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"open" isEqualToString:call.method]) {
      _result = result;
      _arguments = call.arguments;
      bool isSingle = false;
    
      NSNumber* type = 0;
      isSingle = call.arguments[@"isSingle"];
      type = call.arguments[@"type"];
      [CameraMic initCameraFromWebview:_viewController cType:type isSingle:isSingle result:result];
//     [_viewController presentViewController:cropViewController animated:YES completion:nil];
  } else {
      result(FlutterMethodNotImplemented);
  }
}



@end
