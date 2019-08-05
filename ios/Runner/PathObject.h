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
@property float thickness;
@property (retain)NSMutableArray * paths;


-(BOOL)addPaths:(PathObject *)obj;
-(BOOL)mustAddPaths:(PathObject*)obj;
-(BOOL)checkConnect:(PathObject *)obj;
-(BOOL)check5:(PathObject *)obj;
-(BOOL)checkCross:(PathObject*)obj;
-(UIImage *)drawPathToSize:(float)psize;
+(PathObject *)getPathFromAxis:(NSArray *)points withThickness:(float)thickness;
+(NSMutableArray *)getPathObjects:(NSArray *)pos;

@end

#endif /* PathObject_h */
