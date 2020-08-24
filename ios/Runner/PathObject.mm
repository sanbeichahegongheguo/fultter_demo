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
    float miny = obj.minY;
    float maxy = obj.maxY;
    if([self checkCross:obj]){
        return YES;
    }
    if ((minx>self.minX && maxx<self.maxX) || (minx<self.minX && maxx>self.maxX)){
        return YES;
    }
    if((self.maxY - self.minY) < (maxy-miny)/3 && self.minY > miny+(maxy-miny)/2){
        return NO;
    }    
    if(self.minX<minx && minx<self.maxX-(self.maxX-self.minX)/2){
        return YES;
    }
    if([self check5:obj]){
        return YES;
    }
    return NO;
}

-(BOOL)check5:(PathObject *)obj{
    float minx = obj.minX;
    float miny = obj.minY;
    float maxx = obj.maxX;
    float maxy = obj.maxY;
    BOOL judge5 = (miny<self.minY+(self.maxY-self.minY)/4) && ((maxy-miny)<(self.maxY-self.minY)/4);
    if(minx > self.maxX){
        judge5 = judge5 && (minx-self.maxX)<(maxx-minx);
    }else{
        judge5 = judge5 && minx < self.maxX && maxy < self.maxY;
    }
    return judge5;
}

-(BOOL)checkCHN8:(PathObject *)obj{
    if([self.paths count]>1 || [obj.paths count]>1){
        return NO;
    }
    PathObject* leftObj;
    PathObject* rightObj;
    if(self.minX < obj.minX){
        leftObj = self;
        rightObj = obj;
    }else{
        leftObj = obj;
        rightObj = self;
    }
    if(leftObj.startPointX < leftObj.endPointX || leftObj.startPointY > leftObj.endPointY){
        return NO;
    }
    if(rightObj.startPointX > rightObj.endPointX || rightObj.startPointY > rightObj.endPointY){
        return NO;
    }
    if(rightObj.startPointX - leftObj.startPointX < rightObj.endPointX - leftObj.endPointX){
        return YES;
    }
    return NO;
}

-(BOOL)checkCross:(PathObject*)obj{
    BOOL check1 =  obj.maxX > self.minX && obj.minX < self.maxX;
    if(!check1){
        return NO;
    }
    float crossPart = (self.maxX - obj.minX) * 3;
    BOOL check2 = crossPart > obj.maxX - obj.minX || crossPart > self.maxX - self.minX;
    return check2;
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
        UIBezierPath * path = [self.paths[i] copy];
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
            obj.startPointX = x;
            obj.startPointY = y;
        }else if(i == [points count]-1){
            obj.endPointX = x;
            obj.endPointY = y;
        }
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
		/*if([points count] < 2){
			continue;
		}*/
        PathObject* tmpObj = [PathObject getPathFromAxis:points withThickness:1];		
		if(tmpObj.maxX == tmpObj.minX && tmpObj.maxY == tmpObj.minY){
			continue;
		}
        [tmpPObjs addObject:tmpObj];        
    }    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"minX" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    [tmpPObjs sortUsingDescriptors:sortDescriptors];
    
    
    /*for(int i=0; i<[tmpPObjs count]; i++){
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
    pObjs = [NSMutableArray arrayWithArray:[[pObjs reverseObjectEnumerator] allObjects]];*/
    return tmpPObjs;
}

@end
