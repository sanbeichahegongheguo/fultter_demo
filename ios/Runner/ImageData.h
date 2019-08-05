//
//  ImageData.hpp
//  drawtest
//
//  Created by yondor on 2019/4/3.
//  Copyright © 2019年 yondor. All rights reserved.
//

#ifndef ImageData_hpp
#define ImageData_hpp

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <queue>
#include <sstream>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

std::vector<uint8_t> GetImageData(CGImageRef image);
void GetTopN(const float* prediction, const int prediction_size, const int num_results,
             const float threshold, std::vector<std::pair<float, int> >* top_results);

//std::vector<uint8_t> LoadImageFromFile(const char* file_name, int* out_width, int* out_height, int* out_channels);
NSString* ImageToBase64(UIImage* img);
#endif /* ImageData_hpp */
