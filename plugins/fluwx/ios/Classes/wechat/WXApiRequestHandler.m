//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 15/7/14.
//
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiRequestHandler.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#import "WXMediaMessage+messageConstruct.h"
#import "StringUtil.h"

@implementation WXApiRequestHandler

#pragma mark - Public Methods

+ (BOOL)sendText:(NSString *)text
         InScene:(enum WXScene)scene {
    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:text
                                                   OrMediaMessage:nil
                                                            bText:YES
                                                          InScene:scene];
    return [WXApi sendReq:req];
}

+ (BOOL)sendImageData:(NSData *)imageData
              TagName:(NSString *)tagName
           MessageExt:(NSString *)messageExt
               Action:(NSString *)action
           ThumbImage:(UIImage *)thumbImage
              InScene:(enum WXScene)scene
                title:(NSString *)title
          description:(NSString *)description {
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;


    WXMediaMessage *message = [WXMediaMessage messageWithTitle:(title == (id) [NSNull null]) ? nil : title
                                                   Description:(description == (id) [NSNull null]) ? nil : description
                                                        Object:ext
                                                    MessageExt:(messageExt == (id) [NSNull null]) ? nil : messageExt
                                                 MessageAction:(action == (id) [NSNull null]) ? nil : action
                                                    ThumbImage:thumbImage
                                                      MediaTag:(tagName == (id) [NSNull null]) ? nil : tagName];

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];

    return [WXApi sendReq:req];
}

+ (BOOL)sendLinkURL:(NSString *)urlString
            TagName:(NSString *)tagName
              Title:(NSString *)title
        Description:(NSString *)description
         ThumbImage:(UIImage *)thumbImage
         MessageExt:(NSString *)messageExt
      MessageAction:(NSString *)messageAction
            InScene:(enum WXScene)scene {
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;

    WXMediaMessage *message = [WXMediaMessage messageWithTitle:(title == (id) [NSNull null]) ? nil : title
                                                   Description:(description == (id) [NSNull null]) ? nil : description
                                                        Object:ext
                                                    MessageExt:(messageExt == (id) [NSNull null]) ? nil : messageExt
                                                 MessageAction:(messageAction == (id) [NSNull null]) ? nil : messageAction
                                                    ThumbImage:thumbImage
                                                      MediaTag:(tagName == (id) [NSNull null]) ? nil : tagName];

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];
}

+ (BOOL)sendMusicURL:(NSString *)musicURL
             dataURL:(NSString *)dataURL
     MusicLowBandUrl:(NSString *)musicLowBandUrl
 MusicLowBandDataUrl:(NSString *)musicLowBandDataUrl
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
          MessageExt:(NSString *)messageExt
       MessageAction:(NSString *)messageAction
             TagName:(NSString *)tagName
             InScene:(enum WXScene)scene {
    WXMusicObject *ext = [WXMusicObject object];

    if ([StringUtil isBlank:musicURL]) {
        ext.musicLowBandUrl = musicLowBandUrl;
        ext.musicLowBandDataUrl = (musicLowBandDataUrl == (id) [NSNull null]) ? nil : musicLowBandDataUrl ;
    } else {
        ext.musicUrl = musicURL;
        ext.musicDataUrl = (dataURL == (id) [NSNull null]) ? nil : dataURL ;
    }


    WXMediaMessage *message = [WXMediaMessage messageWithTitle:(title == (id) [NSNull null]) ? nil : title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:(messageExt == (id) [NSNull null]) ? nil : messageExt
                                                 MessageAction:(messageAction == (id) [NSNull null]) ? nil : messageAction
                                                    ThumbImage:thumbImage
                                                      MediaTag:(tagName == (id) [NSNull null]) ? nil : tagName];

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];

    return [WXApi sendReq:req];
}

+ (BOOL)sendVideoURL:(NSString *)videoURL
     VideoLowBandUrl:(NSString *)videoLowBandUrl
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
          MessageExt:(NSString *)messageExt
       MessageAction:(NSString *)messageAction
             TagName:(NSString *)tagName
             InScene:(enum WXScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = (title == (id) [NSNull null]) ? nil : title;
    message.description = (description == (id) [NSNull null]) ? nil : description;
    message.messageExt = (messageExt == (id) [NSNull null]) ? nil : messageExt;
    message.messageAction = (messageAction == (id) [NSNull null]) ? nil : messageAction;
    message.mediaTagName = (tagName == (id) [NSNull null]) ? nil : tagName;
    [message setThumbImage:thumbImage];

    WXVideoObject *ext = [WXVideoObject object];
    if ([StringUtil isBlank:videoURL]) {
        ext.videoLowBandUrl = videoLowBandUrl;
    } else {
        ext.videoUrl = videoURL;
    }
    message.mediaObject = ext;

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];
}

+ (BOOL)sendEmotionData:(NSData *)emotionData
             ThumbImage:(UIImage *)thumbImage
                InScene:(enum WXScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:thumbImage];

    WXEmoticonObject *ext = [WXEmoticonObject object];
    ext.emoticonData = emotionData;

    message.mediaObject = ext;

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];
}

+ (BOOL)sendFileData:(NSData *)fileData
       fileExtension:(NSString *)extension
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
             InScene:(enum WXScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:thumbImage];

    WXFileObject *ext = [WXFileObject object];
    ext.fileExtension = @"pdf";
    ext.fileData = fileData;

    message.mediaObject = ext;

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];
}

+ (BOOL)sendMiniProgramWebpageUrl:(NSString *)webpageUrl
                         userName:(NSString *)userName
                             path:(NSString *)path
                            title:(NSString *)title
                      Description:(NSString *)description
                       ThumbImage:(UIImage *)thumbImage
                      hdImageData:(NSData *)hdImageData
                  withShareTicket:(BOOL)withShareTicket
                  miniProgramType:(WXMiniProgramType)programType
                       MessageExt:(NSString *)messageExt
                    MessageAction:(NSString *)messageAction
                          TagName:(NSString *)tagName
                          InScene:(enum WXScene)scene {
    WXMiniProgramObject *ext = [WXMiniProgramObject object];
    ext.webpageUrl = (webpageUrl == (id) [NSNull null]) ? nil : webpageUrl;
    ext.userName =(userName == (id) [NSNull null]) ? nil : userName ;
    ext.path = (path == (id) [NSNull null]) ? nil : path;
    ext.hdImageData = (hdImageData == (id) [NSNull null]) ? nil : hdImageData;
    ext.withShareTicket = withShareTicket;


//    WXMiniProgramType miniProgramType = WXMiniProgramTypeRelease;
//    if(programType == 0){
//        miniProgramType = WXMiniProgramTypeRelease;
//    } else if(programType == 1){
//        miniProgramType =WXMiniProgramTypeTest;
//    } else if(programType == 2){
//        miniProgramType = WXMiniProgramTypePreview;
//    }

    ext.miniProgramType = programType;

    WXMediaMessage *message = [WXMediaMessage messageWithTitle:(title == (id) [NSNull null]) ? nil : title
                                                   Description:(description == (id) [NSNull null]) ? nil : description
                                                        Object:ext
                                                    MessageExt:(messageExt == (id) [NSNull null]) ? nil : messageExt
                                                 MessageAction:(messageAction == (id) [NSNull null]) ? nil : messageAction
                                                    ThumbImage:thumbImage
                                                      MediaTag:(tagName == (id) [NSNull null]) ? nil : tagName];

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];

    return [WXApi sendReq:req];
}

+ (BOOL)launchMiniProgramWithUserName:(NSString *)userName
                                 path:(NSString *)path
                                 type:(WXMiniProgramType)miniProgramType {
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName = userName;
    launchMiniProgramReq.path = (path == (id) [NSNull null]) ? nil : path;
    launchMiniProgramReq.miniProgramType = miniProgramType;

    return [WXApi sendReq:launchMiniProgramReq];
}


+ (BOOL)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene {
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = info;
    ext.url = url;
    ext.fileData = data;

    WXMediaMessage *message = [WXMediaMessage messageWithTitle:title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:messageExt
                                                 MessageAction:action
                                                    ThumbImage:thumbImage
                                                      MediaTag:nil];

    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    return [WXApi sendReq:req];

}

+ (BOOL)addCardsToCardPackage:(NSArray *)cardIds cardExts:(NSArray *)cardExts {
    NSMutableArray *cardItems = [NSMutableArray array];
    for (NSString *cardId in cardIds) {
        WXCardItem *item = [[WXCardItem alloc] init];
        item.cardId = cardId;
        item.appID = @"wxf8b4f85f3a794e77";
        [cardItems addObject:item];
    }

    for (NSInteger index = 0; index < cardItems.count; index++) {
        WXCardItem *item = cardItems[index];
        NSString *ext = cardExts[index];
        item.extMsg = ext;
    }

    AddCardToWXCardPackageReq *req = [[AddCardToWXCardPackageReq alloc] init];
    req.cardAry = cardItems;
    return [WXApi sendReq:req];
}

+ (BOOL)chooseCard:(NSString *)appid
          cardSign:(NSString *)cardSign
          nonceStr:(NSString *)nonceStr
          signType:(NSString *)signType
         timestamp:(UInt32)timestamp {
    WXChooseCardReq *chooseCardReq = [[WXChooseCardReq alloc] init];
    chooseCardReq.appID = appid;
    chooseCardReq.cardSign = cardSign;
    chooseCardReq.nonceStr = nonceStr;
    chooseCardReq.signType = signType;
    chooseCardReq.timeStamp = timestamp;
    return [WXApi sendReq:chooseCardReq];

}

+ (BOOL)sendAuthRequestScope:(NSString *)scope
                       State:(NSString *)state
                      OpenID:(NSString *)openID
            InViewController:(UIViewController *)viewController {
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = scope; // @"post_timeline,sns"
    req.state = state;
    req.openID = openID;

    return [WXApi sendAuthReq:req
               viewController:viewController
                     delegate:[FluwxResponseHandler defaultManager]];
}

+ (BOOL)sendAuthRequestScope:(NSString *)scope
                       State:(NSString *)state
                      OpenID:(NSString *)openID {
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = scope; // @"post_timeline,sns"
    req.state = state;
    req.openID = openID;

    return [WXApi sendReq:req];
}

+ (BOOL)openProfileWithAppID:(NSString *)appID
                 Description:(NSString *)description
                    UserName:(NSString *)userName
                      ExtMsg:(NSString *)extMessage {
    [WXApi registerApp:appID];
    JumpToBizProfileReq *req = [[JumpToBizProfileReq alloc] init];
    req.profileType = WXBizProfileType_Device;
    req.username = userName;
    req.extMsg = extMessage;
    return [WXApi sendReq:req];
}

+ (BOOL)jumpToBizWebviewWithAppID:(NSString *)appID
                      Description:(NSString *)description
                        tousrname:(NSString *)tousrname
                           ExtMsg:(NSString *)extMsg {
    [WXApi registerApp:appID];
    JumpToBizWebviewReq *req = [[JumpToBizWebviewReq alloc] init];
    req.tousrname = tousrname;
    req.extMsg = extMsg;
    req.webType = WXMPWebviewType_Ad;
    return [WXApi sendReq:req];
}

+ (BOOL)openUrl:(NSString *)url {
    OpenWebviewReq *req = [[OpenWebviewReq alloc] init];
    req.url = url;
    return [WXApi sendReq:req];
}

+ (BOOL)chooseInvoice:(NSString *)appid
             cardSign:(NSString *)cardSign
             nonceStr:(NSString *)nonceStr
             signType:(NSString *)signType
            timestamp:(UInt32)timestamp {
    WXChooseInvoiceReq *chooseInvoiceReq = [[WXChooseInvoiceReq alloc] init];
    chooseInvoiceReq.appID = appid;
    chooseInvoiceReq.cardSign = cardSign;
    chooseInvoiceReq.nonceStr = nonceStr;
    chooseInvoiceReq.signType = signType;
//    chooseCardReq.cardType = @"INVOICE";
    chooseInvoiceReq.timeStamp = timestamp;
//    chooseCardReq.canMultiSelect = 1;
    return [WXApi sendReq:chooseInvoiceReq];
}



+ (BOOL)sendPayment:(NSString *)appId PartnerId:(NSString *)partnerId PrepayId:(NSString *)prepayId NonceStr:(NSString *)nonceStr Timestamp:(UInt32)timestamp Package:(NSString *)package Sign:(NSString *)sign {

    PayReq *req = [[PayReq alloc] init];
    req.openID = (appId == (id) [NSNull null]) ? nil : appId;
    req.partnerId = partnerId;
    req.prepayId = prepayId;
    req.nonceStr = nonceStr;
    req.timeStamp = timestamp;
    req.package = package;
    req.sign = sign;
    



    return [WXApi sendReq:req];
}

@end
