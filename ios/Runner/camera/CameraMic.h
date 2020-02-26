#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Call.h"
#import "CustomCamera.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <Flutter/Flutter.h>
@interface CameraMic:NSObject<UIImagePickerControllerDelegate,
								UINavigationControllerDelegate, 
								AVAudioRecorderDelegate,
								AVAudioPlayerDelegate, 
								CallbackDelegate,
                                UIAlertViewDelegate>{
    NSString* _audioPath;
    AVAudioRecorder* _audioRecorder;
    AVAudioPlayer* _audioPlayer;
    
    CustomCamera* _customCamera;
    UIImage* image;
    UIImage *scaleImage;
    
    UIView *cropView;
    UIWebView *webV;
    UIButton *videoBtn;

    const char *temp;
    BOOL isWebView;
}

-(void)successful:(const char *)ptr;
-(void)ok;
-(id)initCamera;
-(id)initGallery;
-(void)setGalleryEnable:(BOOL)value;
-(void)removeGalleryBtn;
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info;
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize ;
-(void)goWifiSettingPage;
-(id)initMicAndStartRecording:(int)removeLastRecording;
-(void)stopRecordingAudio;
-(void)playAudio:(NSString*)filename;
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag;
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex;
+(void)initCameraFromWebview:(UIViewController*)v   cType:(NSNumber*)cType
                    isSingle:(bool)isSingle result:(FlutterResult)result;
    
@end
