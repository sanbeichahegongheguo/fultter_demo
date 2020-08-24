//
//  PathObject.h
//  drawtest
//
//  Created by yondor on 2019/4/1.
//  Copyright © 2019年 yondor. All rights reserved.
//
#import <UIKit/UIKit.h>
#ifndef PathObject_h
#define PathObject_h

@interface PathObject : NSObject
@property float maxX;
@property float maxY;
@property float minX;
@property float minY;
@property float startPointX;
@property float startPointY;
@property float endPointX;
@property float endPointY;
@property float thickness;

@property BOOL checked8;
@property BOOL checked5;

@property (retain)NSMutableArray * paths;


-(BOOL)addPaths:(PathObject *)obj;
-(BOOL)checkConnect:(PathObject *)obj;
-(BOOL)check5:(PathObject *)obj;
-(BOOL)checkCHN8:(PathObject *)obj;
-(BOOL)checkCross:(PathObject*)obj;
-(UIImage *)drawPathToSize:(float)psize;
+(PathObject *)getPathFromAxis:(NSArray *)points withThickness:(float)thickness;
+(NSMutableArray *)getPathObjects:(NSArray *)pos;

@end

#endif /* PathObject_h */
