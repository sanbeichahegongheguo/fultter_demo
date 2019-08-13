//
// Created by mo on 2018/8/16.
//


#import "FluwxShareHandler.h"
#import "ImageSchema.h"
#import "CallResults.h"

#import "FluwxKeys.h"
#import "StringToWeChatScene.h"
#import "FluwxMethods.h"
#import "StringUtil.h"
#import "ThumbnailHelper.h"
#import "NSStringWrapper.h"

@implementation FluwxShareHandler

CGFloat thumbnailWidth;

NSObject <FlutterPluginRegistrar> *_registrar;


- (instancetype)initWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _registrar = registrar;
        thumbnailWidth = 150;
    }

    return self;
}


- (void)handleShare:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!isWeChatRegistered) {
        result([FlutterError errorWithCode:resultErrorNeedWeChat message:resultMessageNeedWeChat details:nil]);
        return;
    }
//
//    if (![WXApi isWXAppInstalled]) {
//        result([FlutterError errorWithCode:@"wechat not installed" message:@"wechat not installed" details:nil]);
//        return;
//    }

    if ([shareText isEqualToString:call.method]) {
        [self shareText:call result:result];
    } else if ([shareImage isEqualToString:call.method]) {
        [self shareImage:call result:result];
    } else if ([shareWebPage isEqualToString:call.method]) {
        [self shareWebPage:call result:result];
    } else if ([shareMusic isEqualToString:call.method]) {
        [self shareMusic:call result:result];
    } else if ([shareVideo isEqualToString:call.method]) {
        [self shareVideo:call result:result];
    } else if([shareMiniProgram isEqualToString:call.method]){
        [self shareMiniProgram:call result:result];
    }


}

- (void)shareText:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *text = call.arguments[fluwxKeyText];
    NSString *scene = call.arguments[fluwxKeyScene];
    BOOL done = [WXApiRequestHandler sendText:text InScene:[StringToWeChatScene toScene:scene]];
    result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});
}


- (void)shareImage:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *imagePath = call.arguments[fluwxKeyImage];
    if ([imagePath hasPrefix:SCHEMA_ASSETS]) {
        [self shareAssetImage:call result:result imagePath:imagePath];
    } else if ([imagePath hasPrefix:SCHEMA_FILE]) {
        [self shareLocalImage:call result:result imagePath:imagePath];
    } else {
        [self shareNetworkImage:call result:result imagePath:imagePath];
    }


}


- (void)shareNetworkImage:(FlutterMethodCall *)call result:(FlutterResult)result imagePath:(NSString *)imagePath {


    NSString *thumbnail = call.arguments[fluwxKeyThumbnail];

    if ([StringUtil isBlank:thumbnail]) {
        thumbnail = imagePath;
    }


    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{

        NSURL *imageURL = [NSURL URLWithString:imagePath];
        //下载图片
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];


        UIImage *thumbnailImage = [self getThumbnail:thumbnail size:32 * 1024];


        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *scene = call.arguments[fluwxKeyScene];
            BOOL done = [WXApiRequestHandler sendImageData:imageData
                                                   TagName:call.arguments[fluwxKeyMediaTagName]
                                                MessageExt:call.arguments[fluwxKeyMessageExt]
                                                    Action:call.arguments[fluwxKeyMessageAction]
                                                ThumbImage:thumbnailImage
                                                   InScene:[StringToWeChatScene toScene:scene]
                                                    title:call.arguments[fluwxKeyTitle]
                                               description:call.arguments[fluwxKeyDescription]
                                                ];
            result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});

        });

    });

}

- (void)shareLocalImage:(FlutterMethodCall *)call result:(FlutterResult)result imagePath:(NSString *)imagePath {


    NSString *thumbnail = call.arguments[fluwxKeyThumbnail];

    if ([StringUtil isBlank:thumbnail]) {
        thumbnail = imagePath;
    }


    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{

//        NSURL *imageURL = [NSURL URLWithString:imagePath];
        NSUInteger startIndex = SCHEMA_FILE.length;

//        int startIndex = SCHEMA_FILE.e
        NSString *imagePathWithoutUri = [imagePath substringFromIndex:startIndex];
        //下载图片
        NSData *imageData = [NSData dataWithContentsOfFile:imagePathWithoutUri];


        UIImage *thumbnailImage = [self getThumbnail:thumbnail size:32 * 1024];


        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *scene = call.arguments[fluwxKeyScene];
            BOOL done = [WXApiRequestHandler sendImageData:imageData
                                                   TagName:call.arguments[fluwxKeyMediaTagName]
                                                MessageExt:call.arguments[fluwxKeyMessageExt]
                                                    Action:call.arguments[fluwxKeyMessageAction]
                                                ThumbImage:thumbnailImage
                                                   InScene:[StringToWeChatScene toScene:scene]
                                                     title:call.arguments[fluwxKeyTitle]
                                               description:call.arguments[fluwxKeyDescription]
            ];
            result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});

        });

    });

}



- (void)shareAssetImage:(FlutterMethodCall *)call result:(FlutterResult)result imagePath:(NSString *)imagePath {


    NSString *thumbnail = call.arguments[fluwxKeyThumbnail];

    if ([StringUtil isBlank:thumbnail]) {
        thumbnail = imagePath;
    }


    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{

        NSData *imageData = [NSData dataWithContentsOfFile:[self readImageFromAssets:imagePath]];

        UIImage *thumbnailImage = [self getThumbnail:thumbnail size:32 * 1024];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *scene = call.arguments[fluwxKeyScene];
//            BOOL done = [WXApiRequestHandler sendImageData:imageData
//                                                   TagName:call.arguments[fluwxKeyMediaTagName]
//                                                MessageExt:fluwxKeyMessageExt
//                                                    Action:fluwxKeyMessageAction
//                                                ThumbImage:thumbnailImage
//                                                   InScene:[StringToWeChatScene toScene:scene]];
            BOOL done  = [WXApiRequestHandler sendImageData:imageData
                                                    TagName:call.arguments[fluwxKeyMediaTagName]
                                                   MessageExt:call.arguments[fluwxKeyMessageExt]
                                                     Action:call.arguments[fluwxKeyMessageAction]
                                                 ThumbImage:thumbnailImage
                                                    InScene:[StringToWeChatScene toScene:scene]
                                                      title:call.arguments[fluwxKeyTitle]
                                                description:call.arguments[fluwxKeyDescription]];
            result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});

        });

    });

}


- (void)shareWebPage:(FlutterMethodCall *)call result:(FlutterResult)result {

    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{

        NSString *thumbnail = call.arguments[fluwxKeyThumbnail];

        UIImage *thumbnailImage = [self getThumbnail:thumbnail size:32 * 1024];


        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *webPageUrl = call.arguments[@"webPage"];
            NSString *scene = call.arguments[fluwxKeyScene];

            BOOL done = [WXApiRequestHandler sendLinkURL:webPageUrl
                                                 TagName:call.arguments[fluwxKeyMediaTagName]
                                                   Title:call.arguments[fluwxKeyTitle]
                                             Description:call.arguments[fluwxKeyDescription]
                                              ThumbImage:thumbnailImage
                                              MessageExt:call.arguments[fluwxKeyMessageExt]
                                           MessageAction:call.arguments[fluwxKeyMessageAction]
                                                 InScene:[StringToWeChatScene toScene:scene]];
            result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});

        });

    });


}

- (void)shareMusic:(FlutterMethodCall *)call result:(FlutterResult)result {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{

        NSString *thumbnail = call.arguments[fluwxKeyThumbnail];

        UIImage *thumbnailImage = [self getThumbnail:thumbnail size:32 * 1024];


        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *scene = call.arguments[fluwxKeyScene];

            BOOL done = [WXApiRequestHandler sendMusicURL:call.arguments[@"musicUrl"]
                                                  dataURL:call.arguments[@"musicDataUrl"]
                                          MusicLowBandUrl:call.arguments[@"musicLowBandUrl"]
                                      MusicLowBandDataUrl:call.arguments[@"musicLowBandDataUrl"]
                                                    Title:call.arguments[fluwxKeyTitle]
                                              Description:call.arguments[fluwxKeyDescription]
                                               ThumbImage:thumbnailImage
                                               MessageExt:call.arguments[fluwxKeyMessageExt]
                                            MessageAction:call.arguments[fluwxKeyMessageAction]
                                                  TagName:call.arguments[fluwxKeyMediaTagName]
                                                  InScene:[StringToWeChatScene toScene:scene]];
            result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});

        });

    });

}

- (void)shareVideo:(FlutterMethodCall *)call result:(FlutterResult)result {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{

        NSString *thumbnail = call.arguments[fluwxKeyThumbnail];

        UIImage *thumbnailImage = [self getThumbnail:thumbnail size:32 * 1024];


        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *scene = call.arguments[fluwxKeyScene];

            BOOL done = [WXApiRequestHandler sendVideoURL:call.arguments[@"videoUrl"]
                                          VideoLowBandUrl:call.arguments[@"videoLowBandUrl"]
                                                    Title:call.arguments[fluwxKeyTitle]
                                              Description:call.arguments[fluwxKeyDescription]
                                               ThumbImage:thumbnailImage
                                               MessageExt:call.arguments[fluwxKeyMessageExt]
                                            MessageAction:call.arguments[fluwxKeyMessageAction]
                                                  TagName:call.arguments[fluwxKeyMediaTagName]
                                                  InScene:[StringToWeChatScene toScene:scene]];
            result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});

        });

    });

}

- (void)shareMiniProgram:(FlutterMethodCall *)call result:(FlutterResult)result {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0,0);
    dispatch_async(globalQueue, ^{

        NSString *thumbnail = call.arguments[fluwxKeyThumbnail];

        UIImage *thumbnailImage = [self getThumbnail:thumbnail size:120 * 1024];

        NSData *hdImageData = nil;

        NSString *hdImagePath = call.arguments[@"hdImagePath"];
        if (![StringUtil isBlank:hdImagePath]) {
            if ([hdImagePath hasPrefix:SCHEMA_ASSETS]) {
                hdImageData = [NSData dataWithContentsOfFile:[self readImageFromAssets:hdImagePath]];

            } else if ([hdImagePath hasPrefix:SCHEMA_FILE]) {
                NSUInteger startIndex = SCHEMA_FILE.length;

//        int startIndex = SCHEMA_FILE.e
                NSString *imagePathWithoutUri = [hdImagePath substringFromIndex:startIndex];
                hdImageData = [NSData dataWithContentsOfFile:imagePathWithoutUri];
            } else {
                NSURL *hdImageURL = [NSURL URLWithString:hdImagePath];
                hdImageData = [NSData dataWithContentsOfURL:hdImageURL];


            }

        }

        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *scene = call.arguments[fluwxKeyScene];

            NSNumber *typeInt = call.arguments[@"miniProgramType"];
            WXMiniProgramType miniProgramType = WXMiniProgramTypeRelease;
            if([typeInt isEqualToNumber:@1]){
                miniProgramType =WXMiniProgramTypeTest;
            } else if([typeInt isEqualToNumber:@2]){
                miniProgramType = WXMiniProgramTypePreview;
            }

            BOOL done = [WXApiRequestHandler sendMiniProgramWebpageUrl:call.arguments[@"webPageUrl"]
                                                              userName:call.arguments[@"userName"]
                                                                  path:call.arguments[@"path"]
                                                                 title:call.arguments[fluwxKeyTitle]
                                                           Description:call.arguments[fluwxKeyDescription]
                                                            ThumbImage:thumbnailImage
                                                           hdImageData:hdImageData
                                                       withShareTicket:[call.arguments[@"withShareTicket"] boolValue]
                                                       miniProgramType:miniProgramType
                                                            MessageExt:call.arguments[fluwxKeyMessageExt]
                                                         MessageAction:call.arguments[fluwxKeyMessageAction]
                                                               TagName:call.arguments[fluwxKeyMediaTagName]
                                                               InScene:[StringToWeChatScene toScene:scene]];
            result(@{fluwxKeyPlatform: fluwxKeyIOS, fluwxKeyResult: @(done)});

        });

    });

}

- (UIImage *)getThumbnail:(NSString *)thumbnail size:(NSUInteger)size {


    UIImage *thumbnailImage = nil;

    if ([StringUtil isBlank:thumbnail]) {
        return nil;
    }


    if ([thumbnail hasPrefix:SCHEMA_ASSETS]) {
        NSData *imageData2 = [NSData dataWithContentsOfFile:[self readImageFromAssets:thumbnail]];
        UIImage *tmp = [UIImage imageWithData:imageData2];
        thumbnailImage = [ThumbnailHelper compressImage:tmp toByte:size isPNG:FALSE];

    } else if ([thumbnail hasPrefix:SCHEMA_FILE]) {
        NSUInteger startIndex = SCHEMA_FILE.length;

//        int startIndex = SCHEMA_FILE.e
        NSString *thumbnailPathWithoutUri = [thumbnail substringFromIndex:startIndex];
        NSData *thumbnailData = [NSData dataWithContentsOfFile:thumbnailPathWithoutUri];
        UIImage *tmp = [UIImage imageWithData:thumbnailData];
        thumbnailImage = [ThumbnailHelper compressImage:tmp toByte:size isPNG:FALSE];
    } else {
        NSURL *thumbnailURL = [NSURL URLWithString:thumbnail];
        NSData *thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];

        UIImage *tmp = [UIImage imageWithData:thumbnailData];
        thumbnailImage = [ThumbnailHelper compressImage:tmp toByte:size isPNG:FALSE];

    }


    return thumbnailImage;

}

- (NSString *)readImageFromAssets:(NSString *)imagePath {
    NSArray *array = [self formatAssets:imagePath];
    NSString *key;
    if ([StringUtil isBlank:array[1]]) {
        key = [_registrar lookupKeyForAsset:array[0]];
    } else {
        key = [_registrar lookupKeyForAsset:array[0] fromPackage:array[1]];
    }

    return [[NSBundle mainBundle] pathForResource:key ofType:nil];

}


- (NSArray *)formatAssets:(NSString *)originPath {
    NSString *path = nil;
    NSString *packageName = @"";
    NSInteger from = [SCHEMA_ASSETS length];
    NSInteger to = [originPath length];
    NSString *pathWithoutSchema = [originPath substringFromIndex:from toIndex:to];
    NSInteger indexOfPackage = [pathWithoutSchema lastIndexOfString:fluwxKeyPackage];

    if (indexOfPackage != JavaNotFound) {
        path = [pathWithoutSchema substringFromIndex:0 toIndex:indexOfPackage];
        int begin = indexOfPackage + [fluwxKeyPackage length];
        packageName = [pathWithoutSchema substringFromIndex:begin toIndex:[pathWithoutSchema length]];
    } else {
        path = pathWithoutSchema;
    }

    return @[path, packageName];
}


@end
