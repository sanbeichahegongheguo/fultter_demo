//
//  PathObject.m
//  drawtest
//
//  Created by yondor on 2019/4/1.
//  Copyright © 2019年 yondor. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include "PathObject.h"

@implementation PathObject

-(id)init{
    self.maxX = -1;
    self.maxY = -1;
    self.minX = -1;
    self.minY = -1;
    self.thickness = -1;
    self.paths = [[NSMutableArray alloc] init];
    return self;
}


-(BOOL)addPaths:(PathObject*)obj{
    if([self.paths count]>=2){
        return NO;
    }
    [self.paths addObjectsFromArray:obj.paths];
    self.minX = (self.minX==-1)?obj.minX:MIN(obj.minX, self.minX);
    self.minY = (self.minY==-1)?obj.minY:MIN(obj.minY, self.minY);
    self.maxX = (self.maxX==-1)?obj.maxX:MAX(obj.maxX, self.maxX);
    self.maxY = (self.maxY==-1)?obj.maxY:MAX(obj.maxY, self.maxY);
    return YES;
}

-(BOOL)mustAddPaths:(PathObject*)obj{
    [self.paths addObjectsFromArray:obj.paths];
    self.minX = (self.minX==-1)?obj.minX:MIN(obj.minX, self.minX);
    self.minY = (self.minY==-1)?obj.minY:MIN(obj.minY, self.minY);
    self.maxX = (self.maxX==-1)?obj.maxX:MAX(obj.maxX, self.maxX);
    self.maxY = (self.maxY==-1)?obj.maxY:MAX(obj.maxY, self.maxY);
    return YES;
}


-(BOOL)checkConnect:(PathObject *)obj{
    float minx = obj.minX;
    float maxx = obj.maxX;
    return (minx>self.minX && maxx<self.maxX) || (minx<self.minX && maxx>self.maxX);
}

-(BOOL)check5:(PathObject *)obj{
    float minx = obj.minX;
    float miny = obj.minY;
    float maxx = obj.maxX;
    float maxy = obj.maxY;
    BOOL judge5 = (miny<self.minY+(self.maxY-self.minY)/3) && ((maxy-miny)<(self.maxY-self.minY)/2);
    if(minx > self.maxX){
        judge5 = judge5 && (minx-self.maxX)<(maxx-minx);
    }else{
        judge5 = judge5 && minx < self.maxX && maxy < self.maxY;
    }
    return judge5;
}

-(BOOL)checkCross:(PathObject*)obj{
    return obj.maxX > self.minX && obj.minX < self.maxX;
}


-(UIImage *)drawPathToSize:(float)psize {
    float scaleWidth = (psize * 0.9)/(self.maxX - self.minX + 1);
    float scaleHeight = (psize * 0.9)/(self.maxY - self.minY + 1);
    float scale = MIN(scaleWidth, scaleHeight);
    if(scale == 0){
        scale = 1;
    }
    
    float offsetX = (psize - (self.maxX-self.minX)*scale)/2;
    float offsetY = (psize - (self.maxY-self.minY)*scale)/2;
   // NSLog(@"scale=%f, offsetX=%f, offsetY=%f", scale, offsetX, offsetY);
    float startX = self.minX * scale;
    float startY = self.minY * scale;

   // NSLog(@"position = (%f, %f, %f, %f)", self.minX, self.minY, self.maxX, self.maxY);
  //  NSLog(@"thickness = %f", self.thickness);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(psize, psize),NO,1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * white = [UIColor whiteColor];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    CGRect rect = CGRectMake(0,0,psize,psize);
    [img drawInRect:rect];
    CGContextSetFillColorWithColor(context, white.CGColor);
    CGContextSetStrokeColorWithColor(context, white.CGColor);
    CGContextFillRect(context, rect);
    
    for(int i=0; i<[self.paths count]; i++){
        UIBezierPath * path = self.paths[i];
        [path applyTransform:CGAffineTransformMakeScale(scale, scale)];
        [path applyTransform:CGAffineTransformMakeTranslation((offsetX-startX), (offsetY-startY))];
        
        [path setLineWidth:self.thickness];
        [path setLineJoinStyle:kCGLineJoinBevel];
        [path setLineCapStyle:kCGLineCapButt];
        [[UIColor blackColor] setStroke];
        [path stroke];
    }

    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

+(PathObject *)getPathFromAxis:(NSArray *)points withThickness:(float)thickness{
    PathObject * obj = [[PathObject alloc] init];

    UIBezierPath * path = [[UIBezierPath alloc] init];//[UIBezierPath bezierPath];
    for(int i=0; i<[points count]; i++){
        NSArray* p = points[i];
        float x = [p[0] floatValue];
        float y = [p[1] floatValue];
        if(i == 0){
            [path moveToPoint:CGPointMake(x, y)];
        }else{
            [path addLineToPoint:CGPointMake(x, y)];
        }
        obj.minX = (obj.minX==-1)?x:MIN(x, obj.minX);
        obj.minY = (obj.minY==-1)?y:MIN(y, obj.minY);
        obj.maxX = (obj.maxX==-1)?x:MAX(x, obj.maxX);
        obj.maxY = (obj.maxY==-1)?y:MAX(y, obj.maxY);
    }

    obj.thickness = thickness;
    [obj.paths addObject:path];
    return obj;
}

+(NSMutableArray *)getPathObjects:(NSArray *)pos{
    NSMutableArray* tmpPObjs = [NSMutableArray array];   
    for(int i=0; i<[pos count]; i++){
        NSArray* points = pos[i];
        PathObject* tmpObj = [PathObject getPathFromAxis:points withThickness:1];
        [tmpPObjs addObject:tmpObj];
        
    }    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"minX" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    [tmpPObjs sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray* pObjs = [NSMutableArray array];
    for(int i=0; i<[tmpPObjs count]; i++){
        PathObject * tmpObj = tmpPObjs[i];
        BOOL isAdded = NO;
        for(int j=(int)([pObjs count]-1); j>=0; j--){
            PathObject* tmpObj2 = pObjs[j];
            if([tmpObj2 checkConnect:tmpObj]){
                [tmpObj2 addPaths:tmpObj];
                pObjs[j] = tmpObj2;
                isAdded = YES;
                break;
            }
        }
        if(!isAdded){
            [pObjs addObject:tmpObj];
        }
    }
    pObjs = [NSMutableArray arrayWithArray:[[pObjs reverseObjectEnumerator] allObjects]];
    return pObjs;
}

@end
