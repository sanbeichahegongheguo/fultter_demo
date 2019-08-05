//
//  ImageData.cpp
//  drawtest
//
//  Created by yondor on 2019/4/3.
//  Copyright © 2019年 yondor. All rights reserved.
//

#include "ImageData.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

std::vector<uint8_t> GetImageData(CGImageRef image){
//    CGImageRef image = [img CGImage];
    const int width = (int)CGImageGetWidth(image);
    const int height = (int)CGImageGetHeight(image);
    const int channels = 4;
    CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
    const int bytes_per_row = (width * channels);
    const int bytes_in_image = (bytes_per_row * height);
    std::vector<uint8_t> result(bytes_in_image);
    const int bits_per_component = 8;
    
    CGContextRef context =
    CGBitmapContextCreate(result.data(), width, height, bits_per_component, bytes_per_row,
                          color_space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(color_space);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);

    return result;
}


void GetTopN(const float* prediction, const int prediction_size, const int num_results,
                    const float threshold, std::vector<std::pair<float, int> >* top_results) {
    // Will contain top N results in ascending order.
    std::priority_queue<std::pair<float, int>, std::vector<std::pair<float, int> >,
    std::greater<std::pair<float, int> > >
    top_result_pq;
    
    const long count = prediction_size;
    for (int i = 0; i < count; ++i) {
        const float value = prediction[i];
        
        // Only add it if it beats the threshold and has a chance at being in
        // the top N.
        if (value < threshold) {
            continue;
        }
        
        top_result_pq.push(std::pair<float, int>(value, i));
        
        // If at capacity, kick the smallest value out.
        if (top_result_pq.size() > num_results) {
            top_result_pq.pop();
        }
    }
    
    // Copy to output vector and reverse into descending order.
    while (!top_result_pq.empty()) {
        top_results->push_back(top_result_pq.top());
        top_result_pq.pop();
    }
    std::reverse(top_results->begin(), top_results->end());
}


NSString* ImageToBase64(UIImage* img){
    NSData *imageData = UIImageJPEGRepresentation(img, 1.0f);
    return [imageData base64EncodedStringWithOptions: 0];
}


