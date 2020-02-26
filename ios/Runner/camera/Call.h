//
//  Call.h
//  cameramictest
//
//  Created by yondor on 17/2/24.
//
//
#import <Foundation/Foundation.h>

@protocol  CallbackDelegate <NSObject>

@required
-(void) successful:(const char*)ptr;
-(void) ok;
-(void) cancelFn;
-(id)initGallery;
-(void)removeGalleryBtn;
-(void)setGalleryEnable:(BOOL)value;
@end


