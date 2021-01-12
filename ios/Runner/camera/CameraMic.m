#define SHOW_PREVIEW NO

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Call.h"
#import "CustomCamera.h"
#import "CustomGallery.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <Flutter/Flutter.h>
#import <TOCropViewController/TOCropViewController.h>
@interface CameraMic:NSObject<UIImagePickerControllerDelegate,
								UINavigationControllerDelegate,
								AVAudioRecorderDelegate,
								AVAudioPlayerDelegate, 
								CallbackDelegate,
                                UIAlertViewDelegate,TOCropViewControllerDelegate>
{
    NSString* _audioPath;
    AVAudioRecorder* _audioRecorder;
    AVAudioPlayer* _audioPlayer;
    FlutterResult _result;
    CustomCamera* _customCamera;
	CustomGallery* _customGallery;
    UIImage* image;
    UIImage *scaleImage;
    UIButton * galleryButton;
    UIView * customCameraView;
    UIView *cropView;
    UIButton *currentBtn;
    UIWebView *webV;
    UIButton *videoBtn;
    UIButton * closeBtn;
    UIViewController *topVC;
    UISwipeGestureRecognizer* recognizerRight;
    UISwipeGestureRecognizer* recognizerLeft;
    MPMoviePlayerController *moviePlayer;
    AVPlayerViewController *playVC;
    AVCaptureDevice *device;
    UIButton *flashBtn;
    UIButton *takePicture;
    const char *temp;
    BOOL isWebView;
}

@end
@implementation CameraMic
static NSString* _callbackId;
static NSString* _appFilesDirectory;
static NSString* _pickerType;
static NSString* _isFlash = @"F";
static NSArray* _titleArr;
static NSString* _singleType = @"base";
static NSNumber* _cType = 0;
static BOOL _isSingle = false;
+(const char*)setAppFilesDirectory:(NSString*)subdir
{

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);	
	_appFilesDirectory = [[paths objectAtIndex:0] stringByAppendingString:subdir];    
	const char *ptr = [_appFilesDirectory cStringUsingEncoding:NSUTF8StringEncoding];
    return ptr;
}

+(const char*)getAppDirectory
{

	if(_appFilesDirectory == nil){
		[CameraMic setAppFilesDirectory:@""];
	}
    printf("Cameramic getAppDirectory _appFilesDirectory: %s\n" , _appFilesDirectory);	
    const char *ptr = [_appFilesDirectory cStringUsingEncoding:NSUTF8StringEncoding];
	return ptr;
}
    
+(void)initCameraFromWebview:(UIViewController*)v
                  cType:(NSNumber*)cType
                    isSingle:(bool)isSingle
                            result:(FlutterResult)result{
    CameraMic* cm = [[CameraMic alloc] init];
    cm->topVC = v;
    cm->_result = result;
    _cType = cType;
    _isSingle = isSingle;
    [cm initCamera];
}

-(void)successful:(const char *)ptr{
	NSLog(@"take photo success , path = %s" , ptr);
        NSString * imgPath = [NSString stringWithFormat:@"%s",ptr];

//        UIImage * tmp = nil;
//        if(image == nil){
//            NSLog(@"load image");
//            tmp = [[UIImage alloc] initWithContentsOfFile:imgPath];
//        }else{
//            tmp = image;
//        }
        UIImage* tmp = [[UIImage alloc] initWithContentsOfFile:imgPath];
        NSData *imageData = nil;
        if([imgPath containsString:@"JPG"]
           ||[imgPath containsString:@"JPEG"]
           ||[imgPath containsString:@"jpg"]
           ||[imgPath containsString:@"jpeg"]){
            imageData = UIImageJPEGRepresentation(tmp, 1.0f);
        }else if([imgPath containsString:@"PNG"]||[imgPath containsString:@"png"]){
            imageData = UIImagePNGRepresentation(tmp);
        }
//        NSString * b64 = [imageData base64EncodedStringWithOptions: 0];
        NSInteger type = 1;
        if(currentBtn.tag == 100){
            type = 0;
        }
        
//        NSString * script = [NSString stringWithFormat:@"callPoto({path:\"%@\",type:%ld,data:\"%@\"});", imgPath, type,b64];
        NSString * script = [NSString stringWithFormat:@"{\"path\":\"%@\",\"type\":%ld}", imgPath, type];
//        NSLog(@"script===>%@",script);
        tmp = nil;;
        imageData = nil;
        _result(script);
//        [webV stringByEvaluatingJavaScriptFromString:script];
        if(_customCamera!=nil){
            [_customCamera dismissModalViewControllerAnimated:YES];
            [_customCamera.view removeFromSuperview];
            [_customCamera.view.superview removeFromSuperview];
        }
        [self removeGalleryBtn];
        _result = nil;
}
-(void)successfulData:(NSData*)imageData{
        NSNumber *myDoubleNumber = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        NSString *filename = [NSString stringWithFormat:@"%ld.jpg", (long)[myDoubleNumber integerValue]];
        NSString *path = [[NSString alloc] initWithUTF8String:[CameraMic getAppDirectory]];
        NSString *imagePath = [path stringByAppendingPathComponent:filename];
        [imageData writeToFile:imagePath atomically:YES];
        NSInteger type = 1;
        if(currentBtn.tag == 100){
            type = 0;
        }
        NSString * script = [NSString stringWithFormat:@"{\"path\":\"%@\",\"type\":%ld}", imagePath, type];
        imageData = nil;
        _result(script);
        if(_customCamera!=nil){
            [_customCamera dismissModalViewControllerAnimated:YES];
            [_customCamera.view removeFromSuperview];
            [_customCamera.view.superview removeFromSuperview];
        }
        [self removeGalleryBtn];
        _result = nil;
}

-(void)ok{
    NSLog(@"retake");
    
//    NSString * script = [NSString stringWithFormat:@"closeCamera();"];
    //        NSLog(@"script===>%@",script);
    _result(@"");
//    [webV stringByEvaluatingJavaScriptFromString:script];
    if(_customCamera!=nil){
        [_customCamera dismissModalViewControllerAnimated:YES];
        [_customCamera.view removeFromSuperview];
        [_customCamera.view.superview removeFromSuperview];
    }
    [self removeGalleryBtn];
   	//[self initCamera];
    
}


-(id)initCamera
{
	if (self = [super init])
	{
        AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        NSLog(@"author===> %ld",author);
        if (author == AVAuthorizationStatusRestricted || author ==AVAuthorizationStatusDenied){
            NSLog(@"打不开相机");
            //无权限 做一个提示
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您先去设置允许APP访问您的相机 设置>隐私>照片" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            alertView.tag = 10111;
            _result(@"");
            _result = nil;
            [alertView show];
            return self;
        }
        
//        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//        {
//            NSLog(@"照相机不可用");
//            _callbackId=nil;
//            return self;
//        }
        
        
		_pickerType=@"camera";
		_customCamera = [[CustomCamera alloc] init];
		[_customCamera setSourceType:UIImagePickerControllerSourceTypeCamera];// 设置类型
		[_customCamera setDelegate:self];// 设置代理
	    _customCamera.showsCameraControls = YES;
		_customCamera.allowsEditing = NO;
        _customCamera.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        _customCamera.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        _customCamera.callbackImage = self;//将外部调用用语句绑定
        _customCamera.retake = self;
        
        _customCamera.toolbarHidden = YES;//是否显示工具栏
        _customCamera.allowsEditing = YES;
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        if(false){
//        if(YES){
            _customCamera.showsCameraControls = YES;//隐藏相机控件
        }else{
            _customCamera.showsCameraControls = NO;//隐藏相机控件
            _isFlash = @"F";
            //自定义拍照界面start
            // 拍照界面容器
            customCameraView = [[UIView alloc] initWithFrame:[UIScreen  mainScreen].bounds];
            
            // 拍照按钮
            takePicture = [UIButton buttonWithType:UIButtonTypeCustom];
            takePicture.frame = CGRectMake(width/2-width/7/2,height-height/8, width/7, width/7);
            [takePicture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //        [takePicture setTitle:@"照相" forState:UIControlStateNormal];
            [takePicture addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchDown];
            takePicture.layer.cornerRadius = width/14;  //按钮大小要动态适应屏幕大小
            takePicture.clipsToBounds = YES;
            [takePicture setShowsTouchWhenHighlighted:YES];
            takePicture.backgroundColor = [UIColor whiteColor];
            takePicture.layer.masksToBounds = YES;
            //设置边框的颜色
            [takePicture.layer setBorderColor:[UIColor grayColor].CGColor];
            
            //设置边框的粗细
            [takePicture.layer setBorderWidth:width/7/8];
            
            [customCameraView addSubview:takePicture];
            
            // 相册按钮
            UIButton * albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            albumBtn.frame = CGRectMake(20, height-height/8+(width/7-width/11)/2, width/11, width/11);
            [albumBtn setImage:[UIImage imageNamed:@"bd_ocr_gallery1.png" ]
                      forState:UIControlStateNormal ];
//            [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
            albumBtn.contentMode=UIViewContentModeScaleAspectFill;
            [albumBtn addTarget:self action:@selector(galleryButtonAction) forControlEvents:UIControlEventTouchDown];
            [customCameraView addSubview:albumBtn];
            
            // 闪光按钮
            
            Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
            if (captureDeviceClass !=nil) {
                device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                if([device hasTorch] && [device hasFlash]){
                    
                    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    flashBtn.frame = CGRectMake(width-width/7-20,height-height/8, width/7, width/7);
                    [flashBtn setImage:[UIImage imageNamed:@"bd_ocr_light_off.png" ]
                              forState:UIControlStateNormal ];
                    //            [flashBtn setTitle:@"闪光" forState:UIControlStateNormal];
                    [flashBtn addTarget:self action:@selector(flashFn) forControlEvents:UIControlEventTouchDown];
                    [customCameraView addSubview:flashBtn];
                    
                }else{
                    NSLog(@"初始化失败");
                }
            }else{
                NSLog(@"没有闪光设备");
            }
            
            
            //视频按钮
            videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            videoBtn.frame = CGRectMake(width-20-251/3, 20, 251/3, 95/3);
            [videoBtn setImage:[UIImage imageNamed:@"photo_demonstration_icon.png"] forState:UIControlStateNormal];
//            [videoBtn setTitle:@"视频" forState:UIControlStateNormal];
            videoBtn.contentMode=UIViewContentModeScaleAspectFill;
            [videoBtn addTarget:self action:@selector(getVideo) forControlEvents:UIControlEventTouchDown];
            //返回按钮
            UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectMake(20, 20, width/12, width/12);
            [backBtn setImage:[UIImage imageNamed:@"bd_ocr_close.png"] forState:UIControlStateNormal];
            //        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchDown];
            [customCameraView addSubview:backBtn];
            if (!_isSingle){
                //单题收录和试卷收录
                _titleArr = @[@"试卷收录",@"单题收录"];
                for (int i = 0; i < _titleArr.count; i ++) {
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(width/2*i , height-height/5-32, width/2, 65);
                    [btn setTitle:_titleArr[i] forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont systemFontOfSize:18];
                    btn.showsTouchWhenHighlighted = YES;
                    //设置tag值
                    btn.tag = i+100;
                    
                    btn.selected = NO;
                    NSLog(@"_cType======>%@",_cType);
                    if([_cType isEqualToNumber:[[NSNumber alloc]initWithInt:1]]){
                        if(i == 1){
                            btn.selected = YES;
                            currentBtn = btn;
                        }
                    }else{
                        if(i == 0){
                            btn.selected = YES;
                            currentBtn = btn;
                            [customCameraView addSubview:videoBtn];
                        }
                    }
                    
                    [btn addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
                    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"ph"] forState:UIControlStateNormal];
                    [btn setBackgroundImage:[UIImage imageNamed:@"button1"] forState:UIControlStateNormal];
                    
                    [btn setTitleColor:[UIColor colorWithRed:255.0/255 green:214.0/255 blue:10.0/255 alpha:1] forState:UIControlStateSelected];
                    [btn setImage:[UIImage imageNamed:@"pho"] forState:UIControlStateSelected];
                    [btn setBackgroundImage:[UIImage imageNamed:@"button2"] forState:UIControlStateSelected];
                    [customCameraView addSubview:btn];
                    
                }
                //添加手势
                recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSlip)];
                recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
                [_customCamera.view addGestureRecognizer:recognizerRight];
                
                recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSlip)];
                recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
                [_customCamera.view addGestureRecognizer:recognizerLeft];
            }
            
        
            
            
            // 将自定义的相机界面赋值给cameraOverlayView属性即可显示自定义界面
            //        customCameraView.backgroundColor = [UIColor whiteColor];
            _customCamera.cameraOverlayView= customCameraView;
            
            // 此属性可transform自定义界面 cameraViewTransform:更改比例
            _customCamera.cameraViewTransform = CGAffineTransformMakeScale(1, 1);
           
        }
        
//        UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//        UIViewController *topVC = appRootVC;
//        while (topVC.presentedViewController) {
//            topVC = topVC.presentedViewController;
//        }
        
        if (_customGallery==nil){
            _customGallery = [[CustomGallery alloc] init];
            _customGallery.modalPresentationStyle = UIModalPresentationCurrentContext;
            _customGallery.delegate = self;
            [_customGallery setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        [topVC presentViewController:_customCamera animated:YES completion:nil];
        NSLog(@"成功打开照相机");
		galleryButton = [[UIButton alloc] initWithFrame:CGRectMake(width*6/7, 0 , width/7, width/7)];
	    [galleryButton setTitle:NSLocalizedString(@"相册", nil) forState:UIControlStateNormal];
	    galleryButton.titleLabel.font = [UIFont systemFontOfSize:width/26];
	    galleryButton.backgroundColor = [UIColor clearColor];
	    galleryButton.layer.cornerRadius = width/14;  //按钮大小要动态适应屏幕大小
	    galleryButton.clipsToBounds = YES;
	    [galleryButton setShowsTouchWhenHighlighted:YES];
	    [galleryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	    [galleryButton addTarget:self action:@selector(galleryButtonAction) forControlEvents:UIControlEventTouchUpInside];
        //自定义z拍照界面end
       
	}

	return self;
    
}
//取消回滚
-(void)cancelFn{
    
    _pickerType=@"camera";
    [_customCamera setSourceType:UIImagePickerControllerSourceTypeCamera];
    
    
    [takePicture addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchDown];
    
    
    recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSlip)];
    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_customCamera.view addGestureRecognizer:recognizerRight];
    
    recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSlip)];
    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_customCamera.view addGestureRecognizer:recognizerLeft];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"好的");
    if (alertView.tag == 10111) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    id alertbutton = [alertView buttonTitleAtIndex:buttonIndex];
//    NSLog(@"按下了[%@]按钮",alertbutton);
//}

/*向右滑动*/
-(void)rightSlip{
    NSLog(@"向右滑动: %@",currentBtn);
    if(currentBtn.tag == 101){
        [currentBtn setSelected:NO];
        UIButton *btn = (UIButton *)[[currentBtn superview]viewWithTag:100];
        [btn setSelected:YES];
        currentBtn =btn;
        [customCameraView addSubview:videoBtn];
    }
}
-(void)leftSlip{
    NSLog(@"向左滑动: %@",currentBtn);
    if(currentBtn.tag == 100){
        [currentBtn setSelected:NO];
        UIButton *btn = (UIButton *)[[currentBtn superview]viewWithTag:101];
        [btn setSelected:YES];
        currentBtn =btn;
        [videoBtn removeFromSuperview];
    }
}
//获取视频
-(void)getVideo{
    NSLog(@"播放视频");
    [_customCamera.view removeGestureRecognizer:recognizerRight];
    [_customCamera.view removeGestureRecognizer:recognizerLeft];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSString *filePath = [NSString stringWithFormat:@"test.mp4"];
    
//    NSLog(@"%@",filePath);
////    NSURL *thePath = [NSURL URLWithString:@"http://1258961577.vod2.myqcloud.com/29a8cf75vodcq1258961577/70e601145285890796576610182/jpnDiAjtFBwA.mp4"];
//    NSURL *thePath = [NSURL fileURLWithPath:filePath];
//    NSLog(@"%@",thePath);
    playVC = [[AVPlayerViewController alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    //为即将播放的视频内容进行建模
    AVPlayerItem *avplayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
    playVC.player = [AVPlayer playerWithPlayerItem:avplayerItem];
    playVC.showsPlaybackControls = NO;
    [playVC.player play];
    [_customCamera.cameraOverlayView addSubview: playVC.view];
    playVC.view.frame =CGRectMake(0, 0, width, height);
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(20, 20, width/10, width/10);
    
//    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"bd_ocr_close1.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(colseVide) forControlEvents:UIControlEventTouchDown];
    [_customCamera.cameraOverlayView addSubview:closeBtn];
//    NSURL*theurl=[NSURL fileURLWithPath:thePath];
//    moviePlayer =[[MPMoviePlayerController alloc]initWithContentURL:theurl];
//    moviePlayer.view.frame = CGRectMake(0, 0, width, height);
//    [_customCamera.view addSubview: moviePlayer.view];
//    moviePlayer.shouldAutoplay = NO;
//    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
//    moviePlayer.repeatMode = MPMovieRepeatModeOne;
//    [moviePlayer  prepareToPlay];
    
}
//关闭视频
-(void)colseVide{
    NSLog(@"关闭视频");
    [playVC.view removeFromSuperview];
    [closeBtn removeFromSuperview];
    [playVC.player pause];
    playVC = nil;
    recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSlip)];
    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_customCamera.view addGestureRecognizer:recognizerRight];
    
    recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSlip)];
    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_customCamera.view addGestureRecognizer:recognizerLeft];
}

//切换收录
- (void)choose:(UIButton *)sender{
    NSLog(@"choose : %@",sender);
    if(!sender.selected){
        if(sender.tag == 100 ){
            NSLog(@"试卷收录");
            [customCameraView addSubview:videoBtn];
        }else{
            [videoBtn removeFromSuperview];
        }
        for (int i = 0; i < _titleArr.count; i++) {
            UIButton *btn = (UIButton *)[[sender superview]viewWithTag:100 + i];
            //选中当前按钮时
            if (sender.tag == btn.tag) {
                currentBtn = sender;
                sender.selected = YES;
            }else{
                
                [btn setSelected:NO];
            }
        }
    }
}

-(void)flashFn{
    NSLog(@"闪光");
//    if(_isFlash == @"F"){
//        _isFlash = @"T";
//        _customCamera.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
//    }else{
//        _isFlash = @"F";
//        _customCamera.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
//    }
    [device lockForConfiguration:nil];
    
    if(_isFlash == @"F"){
        _isFlash = @"T";
        [device setTorchMode:AVCaptureTorchModeOn];
        [device setFlashMode:AVCaptureFlashModeOn];
        [flashBtn setImage:[UIImage imageNamed:@"bd_ocr_light_on.png" ]
                  forState:UIControlStateNormal ];
    }else{
        _isFlash = @"F";
        [device setTorchMode:AVCaptureTorchModeOff];
        [device setFlashMode:AVCaptureFlashModeOff];
        [flashBtn setImage:[UIImage imageNamed:@"bd_ocr_light_off.png" ]
                  forState:UIControlStateNormal ];
    }
    [device unlockForConfiguration];
}

- (void)takePicture {
    //移除手势
    [_customCamera.view removeGestureRecognizer:recognizerRight];
    [_customCamera.view removeGestureRecognizer:recognizerLeft];
    [takePicture removeTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchDown];
    // 拍照
    [_customCamera takePicture];
    
}
-(id)initGallery
{
	NSLog(@"打开相册CameraMic");
//    [self removeGalleryBtn];
	if(self = [super init])
	{
       
//        CustomCamera *customCamera = [[CustomCamera alloc] init];
        

//        NSLog(@"打开相册CameraMic11111");
//        [_customCamera setDelegate:self];
//        _customCamera.allowsEditing = YES;
//        if(_customCamera!=nil){
//            [_customCamera dismissModalViewControllerAnimated:YES];
//            [_customCamera.view removeFromSuperview];
//            [_customCamera.view.superview removeFromSuperview];
////            _customCamera = nil;
//        }
//
        
//        UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//        UIViewController *topVC = appRootVC;
//        while (topVC.presentedViewController) {
//            topVC = topVC.presentedViewController;
//        }
//        NSLog(@"%@s",topVC.presentedViewController);
//        if(topVC.presentedViewController){
//                    [topVC presentViewController:_customCamera animated:YES completion:nil];
//        }else{
//            NSLog(@"相册不可用");
//        }

        return self;
        
        
        
        
//        [[[[UIApplication sharedApplication] keyWindow] rootViewController]  presentViewController:_customCamera animated:YES completion:nil];
    }else{
        return self;
    }
	
}
-(void)showGallery{
    NSLog(@"打开相册");
    NSLog(@"打开相册");
    NSLog(@"%@",[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]?@"YES":@"NO");
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        NSLog(@"相册不可用");
        return;
    }
    [_customCamera.view removeGestureRecognizer:recognizerRight];
    [_customCamera.view removeGestureRecognizer:recognizerLeft];
    _pickerType=@"gallery";
      [_customCamera presentViewController:_customGallery animated:YES completion:nil];
}

//点击相册的取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_customGallery dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"按下相册取消%@",_pickerType);
    if(_pickerType == @"camera"){
        [self ok];
    }else{
        
        _pickerType=@"camera";
        recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSlip)];
        recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_customCamera.view addGestureRecognizer:recognizerRight];
        
        recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSlip)];
        recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_customCamera.view addGestureRecognizer:recognizerLeft];
    }
}

-(void)galleryButtonAction{
    NSLog(@"按下相册按钮");
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您先去设置允许APP访问您的相册 设置>隐私>照片" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//        [alert show];
    
    [self showGallery];
    
}

-(void)removeGalleryBtn{
    NSLog(@"removeGalleryBtn");
	if(galleryButton!=nil){
        NSLog(@"removegallerybutton");
        [galleryButton setHidden:YES];
		//[galleryButton dismissModalViewControllerAnimated:YES];
	    [galleryButton removeFromSuperview];	
		galleryButton = nil;	
	}
}

-(void)setGalleryEnable:(BOOL)value{
    NSLog(@"here");
    NSLog(@"setGalleryEnable");
    if(galleryButton!=nil){
        NSLog(@"here1 : %i",value);
        //[galleryButton setHidden:value];
        galleryButton.hidden = value;
    }
}

/*拍照完成后的操作  cwd*/
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
 
    NSLog(@"imagePickerController");
    UIImage* _image = nil;
    if([_pickerType  isEqual: @"gallery"]){
        NSLog(@"相册图片...........");
        _image = [info objectForKey:UIImagePickerControllerOriginalImage] ;
    }else{
        _image = [info objectForKey: UIImagePickerControllerOriginalImage]; //不管是否裁剪，获取原始图片
    }

    if(_pickerType==@"gallery"){
        [self cropImageStar:_image];
        _image = nil;
        image = nil;
        scaleImage = nil;
        return;
    }
    [self removeGalleryBtn];
    if(_customCamera != nil) {
        //调用裁剪
        [self cropImageStar:_image];
        _image = nil;
        image = nil;
        scaleImage = nil;
    } else {NSLog(@"_customCamera = nil");}
}
-(void)cropImageStar:(UIImage*)cropImage{
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:cropImage];
    cropController.delegate = self;
    //截图的展示样式
    cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetOriginal;
    //隐藏比例选择按钮
    cropController.aspectRatioPickerButtonHidden = YES;
    cropController.aspectRatioLockEnabled = NO;
    //重置后缩小到当前设置的长宽比
    cropController.resetAspectRatioEnabled = NO;
    //是否可以手动拖动
    cropController.cropView.cropBoxResizeEnabled = YES;
    UIButton* _resetButton = cropController.toolbar.resetButton;
    [_resetButton setImage:nil forState:UIControlStateNormal];
    [_resetButton setTitle: @"还原" forState:UIControlStateNormal];
    [_resetButton setTintColor:[UIColor systemBlueColor]];
    [_resetButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [_resetButton sizeToFit];
    _resetButton.contentMode = UIViewContentModeCenter;
    _resetButton.enabled = NO;
    [topVC dismissViewControllerAnimated:NO completion:nil];
    [topVC presentViewController:cropController animated:NO completion:nil];
}

# pragma mark -TOCropViewControllerDelegate 图片裁剪
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)cropImage withRect:(CGRect)cropRect angle:(NSInteger)angle{
    NSLog(@"TOCropViewControllerDelegate");
    cropImage = [self scaleImage:cropImage toScale:0.5];
    NSData *imgData = UIImageJPEGRepresentation(cropImage, 0.7);
    [self successfulData:imgData];
    [topVC dismissViewControllerAnimated:YES completion:nil];
}



- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    _result(@"");
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
    _result = nil;
}


/*拍摄后的照片进行尺寸大小缩放*/
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize  
{  
   NSLog(@"scaleImage"); UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];  
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    return scaledImage;  
}

-(void)goWifiSettingPage
{
  NSLog(@"goWifiSettingPage");
  NSData *encryptString = [[NSData alloc] initWithBytes:(unsigned char []){0x70,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x57,0x49,0x46,0x49} length:15];
  NSString *string = [[NSString alloc] initWithData:encryptString encoding:NSUTF8StringEncoding];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:string]])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
	}
}


-(id)initMicAndStartRecording:(int)removeLastRecording
{
    
	if (self = [super init])
	{
		if (removeLastRecording == 1 && [_audioPath length] != 0)
		{
			NSFileManager *fileManager = [NSFileManager defaultManager];

			if ([fileManager fileExistsAtPath:_audioPath])
			{ 
				BOOL success = [fileManager removeItemAtPath:_audioPath error:nil];
        		if(!success) NSLog(@"Error: not file!!");
			}
		}
        NSLog(@"initMicAndStartRecording");
		//obtaining saving path
	    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
	    NSString *filename = [NSString stringWithFormat:@"%ld.caf", (long)[myDoubleNumber integerValue]];
	    NSString *path = [[NSString alloc] initWithUTF8String:[CameraMic getAppDirectory]];
	    _audioPath = [path stringByAppendingPathComponent:filename];
	    NSURL *soundFileURL = [NSURL fileURLWithPath:_audioPath];

		NSDictionary *recordSettings = [NSMutableDictionary dictionary];
		[recordSettings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
		[recordSettings setValue: [NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
		[recordSettings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey]; 
		[recordSettings setValue: [NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
		[recordSettings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
		[recordSettings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
		[recordSettings setValue:  [NSNumber numberWithInt: AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];

		NSError *error = nil;

		_audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];

		if (error)
		{
			NSLog(@"error: %@", [error localizedDescription]);
		}
		else
		{
			[_audioRecorder prepareToRecord];
			[_audioRecorder record];
		}

	    // [[[[UIApplication sharedApplication] keyWindow] rootViewController]  presentViewController:_customCamera animated:YES completion:nil];
	}

	return self;
}

-(void)stopRecordingAudio
{
    NSLog(@"stopRecordingAudio");
	[_audioRecorder stop];
    const char *ptr = [_audioPath cStringUsingEncoding:NSUTF8StringEncoding];
}

-(void)playAudio:(NSString*)filename
{
    NSLog(@"stopRecordingAudio");
    if (!_audioRecorder.recording)
    {
		NSError *error;

		NSLog(@"File Exists:%d",[[NSFileManager defaultManager] fileExistsAtPath:filename]);
		_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filename] error:&error];
		_audioPlayer.delegate = self;
		if (error)
		      NSLog(@"Errorea gertatu da: %@", [error localizedDescription]);
		else
		      [_audioPlayer play];
   }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
}


@end
