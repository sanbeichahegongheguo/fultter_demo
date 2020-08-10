#import "YondorWhiteboardPlugin.h"
#if __has_include(<yondor_whiteboard/yondor_whiteboard-Swift.h>)
#import <yondor_whiteboard/yondor_whiteboard-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "yondor_whiteboard-Swift.h"
#endif

@implementation YondorWhiteboardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYondorWhiteboardPlugin registerWithRegistrar:registrar];
}
@end
