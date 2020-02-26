#import <UIKit/UIKit.h>
#import "BJImageCropper.h"
#import "Call.h"

@interface CustomCamera : UIImagePickerController {
    BJImageCropper *imageCropper;
    
    UILabel *boundsText;
    
    CGFloat sizeScale;
    const char *tmp;
    UIImage *image;
    UIImage *scaleImage;
    
    UIButton *back;
    id<CallbackDelegate> callbackImage;
    id<CallbackDelegate> retake;
}

@property (nonatomic, strong) IBOutlet UILabel *boundsText;
@property (nonatomic, strong) BJImageCropper *imageCropper;

@property (nonatomic, strong) UIImageView *preview;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *scaleImage;
@property (nonatomic, assign) CGFloat sizeScale;
@property (nonatomic, strong) id callbackImage;
@property (nonatomic, strong) id retake;

- (void) cropImageStart:(UIImage*)scaleImage1 type:(NSInteger)type;

@end
