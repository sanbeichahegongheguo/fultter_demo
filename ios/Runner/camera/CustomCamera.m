//
//  CustomCamera.m
//  Gaika_iPhone
//
//  Created by Josu Igoa on 30/05/13.
//  Copyright (c) 2013 Josu Igoa. All rights reserved.
//
#define SHOW_PREVIEW NO

#import <QuartzCore/QuartzCore.h>
#import "CustomCamera.h"
#import "Call.h"

#ifndef CGWidth
#define CGWidth(rect)                   rect.size.width
#endif

#ifndef CGHeight
#define CGHeight(rect)                  rect.size.height
#endif

#ifndef CGOriginX
#define CGOriginX(rect)                 rect.origin.x
#endif

#ifndef CGOriginY
#define CGOriginY(rect)                 rect.origin.y
#endif
// @interface CustomCamera ()

// @end

@implementation CustomCamera
@synthesize retake;
@synthesize callbackImage;
@synthesize boundsText;
@synthesize imageCropper;
@synthesize preview;
@synthesize sizeScale;

NSString* _appFilesDirectory=nil;
UIButton *cancelButton;
UIButton *okButton;
UIView *black;
NSInteger _type;
//char* _appFilesDirectory=0;
-(void) call
{
    //[[self delegate]success:tmp];
}

-(void) dealloc
{
    NSLog(@"CustomCamera : - (void)dealloc");
    //[super dealloc];
}

/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    // override the touches ended method
    // so tapping the screen will take a picture
    [self takePicture];
}
*/

- (void)updateDisplay {
    self.boundsText.text = [NSString stringWithFormat:@"(%f, %f) (%f, %f)", CGOriginX(self.imageCropper.crop), CGOriginY(self.imageCropper.crop), CGWidth(self.imageCropper.crop), CGHeight(self.imageCropper.crop)];
    
    if (SHOW_PREVIEW) {
        self.preview.image = [self.imageCropper getCroppedImage];
        self.preview.frame = CGRectMake(10,10,self.imageCropper.crop.size.width * 0.1, self.imageCropper.crop.size.height * 0.1);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self.imageCropper] && [keyPath isEqualToString:@"crop"]) {
        [self updateDisplay];
    }
}


- (void)viewDidLoad
{
    NSLog(@"CustomCamera : - (void)viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setImageCropper:nil];
    [self setBoundsText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)cropImageStart:(UIImage*)scaleImage1 type:(NSInteger)type
{
    //[[self retake] setGalleryEnable:NO];
    [[self retake]removeGalleryBtn];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSLog(@"CustomCamera : - (void)cropImageStart");
    NSLog(@"Screen size=%f,%f",width,height);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tactile_noise.png"]];
    _type = type;
    UIImage *picture = [[UIImage alloc]init];
    //picture = [UIImage imageNamed:imagePath];
    NSLog(@"picture size=%f,%f type=%d",scaleImage1.size.width , scaleImage1.size.height,_type);
    
	
	//sizeScale = width / scaleImage1.size.width;
    //sizeScale = scaleImage1.size.width / width;
	sizeScale = 0.5;
	
	NSLog(@"sizeScale =%f",sizeScale);
    
    /*  黑色背景覆盖后方父视图  */
    black = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//    black.backgroundColor = [UIColor whiteColor];
    black.backgroundColor = [UIColor blackColor];
    [self.view addSubview:black];
    
    /*  添加图片视图  */
    self.imageCropper = [[BJImageCropper alloc] initWithImage:scaleImage1 andMaxSize:CGSizeMake(width*1.0, height*1.0)];
    [self.view addSubview:self.imageCropper];
    self.imageCropper.center = self.view.center;
    self.imageCropper.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.imageCropper.imageView.layer.shadowRadius = 3.0f;
    self.imageCropper.imageView.layer.shadowOpacity = 0.8f;
    self.imageCropper.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    
    [self.imageCropper addObserver:self forKeyPath:@"crop" options:NSKeyValueObservingOptionNew context:nil];
    
    NSLog(@"view.size =%f,%f",self.imageCropper.imageView.bounds.size.width,self.imageCropper.imageView.bounds.size.height);
    
    NSLog(@"Button init success");
    //controlView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-80)/2, 100, 80, 40)];
    okButton = [[UIButton alloc] initWithFrame:CGRectMake(width/14*6, height-width/7-10, width/7, width/7)];
    [okButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:width/26];
    okButton.layer.borderColor = [UIColor whiteColor].CGColor;
    okButton.layer.borderWidth = 1.0;
    okButton.backgroundColor = [UIColor clearColor];
    okButton.layer.cornerRadius = width/14;  //按钮大小要动态适应屏幕大小
    okButton.clipsToBounds = YES;
    [okButton setShowsTouchWhenHighlighted:YES];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(width/14, height-width/7-10, width/7, width/7)];
    [cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:width/26];
    cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cancelButton.layer.borderWidth = 1.0;
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.layer.cornerRadius = width/14;
    cancelButton.clipsToBounds = YES;
    [cancelButton setShowsTouchWhenHighlighted:YES];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    //_customCamera.cameraOverlayView = controlView;
}


+(const char*)setAppFilesDirectory:(NSString*)subdir
{
    //NSLog(@"setAppFilesDirectory");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  //  NSLog(@"paths");
    
    NSString *tmp = [[paths objectAtIndex:0] stringByAppendingString:subdir];
	_appFilesDirectory= [[NSString alloc]initWithString:tmp];
    //NSLog(@"_appFilesDirectory");
	
    const char *ptr = [_appFilesDirectory cStringUsingEncoding:NSUTF8StringEncoding];
   // NSLog(@"---setAppFilesDirectory    ptr---");
    return ptr;
}

+(const char*)getAppDirectory
{
    //NSLog(@"getAppDirectory _appFilesDirectory");
	/*
    if(_appFilesDirectory != nil){
		NSLog(@"customCamera  _appFilesDirectory111 %@\n",_appFilesDirectory);
	}
	*/
	
	
	if (_appFilesDirectory == nil) {  
		NSLog(@"equals nil");  
		[CustomCamera setAppFilesDirectory:@""];
	} else if (_appFilesDirectory == [NSNull null]) {  
		NSLog(@"equals NSNull instance");  
		if ([_appFilesDirectory isEqual:nil]) {  
			NSLog(@"isEqual:nil");  
		} 
		[CustomCamera setAppFilesDirectory:@""];
	}  
	
	/*
    if(_appFilesDirectory == nil)
    [CustomCamera setAppFilesDirectory:@""];
	*/
	
	/*
	if(_appFilesDirectory == nil){
		NSLog(@"customCamera  _appFilesDirectory is nil");
	}
    NSLog(@"customCamera  _appFilesDirectory222 %@\n",_appFilesDirectory);
	NSLog(@"customCamera  _appFilesDirectory  length %ld\n",[_appFilesDirectory length]);
	*/
	
    const char *ptr = [_appFilesDirectory cStringUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"---getAppDirectory   ptr---");
    
    return ptr;
}

- (void)okButtonAction {
    /*
     if (controlView == nil) {
     //controlView = [[ScanCodeIdentifyCarView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
     // controlView.backgroundColor = [UIColor clearColor];
     
     }*/
    NSLog(@"按下确认按钮");
    image = [self.imageCropper getFinishImage]; //获取裁剪图片
    
    //NSLog(@"image");
    
    scaleImage = [self scaleImage:image toScale:sizeScale];   //拍摄后的照片进行尺寸大小缩放,原来为0.5
    NSLog(@"sizeScale okButtonAction =%f",sizeScale);
    
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    //NSLog(@"myDoubleNumber");
    
    NSString *filename = [NSString stringWithFormat:@"%ld.jpg", (long)[myDoubleNumber integerValue]];
    NSLog(@"okButtonAction   filename  : %@",filename);
    
    /*------------------ERROR---------------------*/
    NSString *path = [[NSString alloc] initWithUTF8String:[CustomCamera getAppDirectory]];
    NSLog(@"okButtonAction path : %@",path);
    
    NSString *imagePath = [path stringByAppendingPathComponent:filename];
   // NSLog(@"imagePath");
    
   // NSLog(@"scaleImage");
    [UIImageJPEGRepresentation(scaleImage, sizeScale) writeToFile:imagePath atomically:YES];
    
   //NSLog(@"customCamera");
    //[_customCamera dismissModalViewControllerAnimated:YES];
    //[_customCamera.view removeFromSuperview];
    //[_customCamera.view.superview removeFromSuperview];
   // NSLog(@"图片路径");
    
    //[self.view removeFromSuperview];
    //[self.view.superview removeFromSuperview];
    
    const char *ptr = [imagePath cStringUsingEncoding:NSUTF8StringEncoding];
    tmp = ptr;
    NSLog(@"path:%s",tmp);
    [[self callbackImage]successful:tmp];
}

-(void)cancelButtonAction {
    NSLog(@"按下取消按钮%ld",_type);
    [black removeFromSuperview];
    [cancelButton removeFromSuperview];
    [okButton removeFromSuperview];
    [self.imageCropper removeFromSuperview];
//    [self.imageCropper removeObserver:self forKeyPath:@"crop"];
    
//    if(_type == 0){
//        [[self retake] ok];
//    }else{
      [[self retake] cancelFn];
//    }
    
//    [self.view removeFromSuperview];
}

-(void)galleryButtonAction{
    NSLog(@"按下相册按钮1");
//    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您先去设置允许APP访问您的相册 设置>隐私>照片" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//    [alert show];
//    [[self retake] initGallery];
}

-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    //NSLog(@"尺寸:%f",scaleSize);
    //NSLog(@"%f",scaleSize);
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/*
-(UIView *)findView:(UIView *)aView withName:(NSString *)name{
    NSLog(@"try3");
    Class cl = [aView class];
    NSString *desc = [cl description];
    if ([name isEqualToString:desc])
        return aView;
    for (UIView *view in aView.subviews) {
        Class cll = [view class];
        NSString *stringl = [cll description];
        if ([stringl isEqualToString:name]) {
            return view;
        }
    }
    return nil;
}

-(void)addSomeElements:(UIView *)view{
    NSLog(@"try2");
    UIView *PLCameraView = [self findView:view withName:@"PLCameraView"];
    UIView *PLCropOverlay = [self findView:PLCameraView withName:@"PLCropOverlay"];
    UIView *bottomBar = [self findView:PLCropOverlay withName:@"PLCropOverlayBottomBar"];
    UIImageView *bottomBarImageForSave = [bottomBar.subviews objectAtIndex:0];
    UIButton *retakeButton=[bottomBarImageForSave.subviews objectAtIndex:0];
    [retakeButton setTitle:@"重拍"  forState:UIControlStateNormal];
    UIButton *useButton=[bottomBarImageForSave.subviews objectAtIndex:1];
    [useButton setTitle:@"保存" forState:UIControlStateNormal];
    UIImageView *bottomBarImageForCamera = [bottomBar.subviews objectAtIndex:1];
    UIButton *cancelButton=[bottomBarImageForCamera.subviews objectAtIndex:1];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"try1");
    [self addSomeElements:self.view];
} 
*/

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"CustomCamera : - (void)viewDidDisappear");
    [[self retake] removeGalleryBtn];
    [super viewDidDisappear:animated];
}

-(void) viewDidAppear: (BOOL)animated
{
    NSLog(@"CustomCamera : - (void)viewDidAppear");
    [super viewDidAppear:animated];
    
    [self updateDisplay];
}

@end
