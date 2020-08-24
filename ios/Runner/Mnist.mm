#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#import "ImageData.h"
#include "PathObject.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

#include "tensorflow/lite/kernels/register.h"
#include "tensorflow/lite/model.h"
#include "tensorflow/lite/op_resolver.h"
#include "tensorflow/lite/string_util.h"

namespace mnistext{

    NSString * modelPath = @"Frameworks/App.framework/flutter_assets/assets/model.tflite";
    

	int drawSize = 28;
	BOOL isUpload = NO;
	
	NSString* predict(UIImage* img) {
        std::unique_ptr<tflite::Interpreter> interpreter;
        NSString* graph_path = [[NSBundle mainBundle] pathForResource:modelPath ofType:nil];
        std::unique_ptr<tflite::FlatBufferModel> model(tflite::FlatBufferModel::BuildFromFile([graph_path UTF8String]));
		if (!model) {
			NSLog(@"Failed to mmap model %@",graph_path);
			return @"Failed to mmap model.";
		}
		
		tflite::ops::builtin::BuiltinOpResolver resolver;
		tflite::InterpreterBuilder(*model, resolver)(&interpreter);
		if (!interpreter) {
			NSLog(@"Failed to construct interpreter.");
			return @"Failed to construct interpreter.";
		}
		
		CGImageRef image = [img CGImage];
		std::vector<uint8_t> image_data = GetImageData(image);
		const int image_width = (int)CGImageGetWidth(image);
		const int image_height = (int)CGImageGetHeight(image);
		//        NSLog(@"image width=%d height=%d", image_width, image_height);
		const int image_channels = 4;
		
		uint8_t* in = image_data.data();
		
		int input = interpreter->inputs()[0];
		interpreter->ResizeInputTensor(input, {1,28,28,1});
		if (interpreter->AllocateTensors() != kTfLiteOk) {
			NSLog(@"Failed to allocate tensors.");
			return @"Failed to allocate tensors.";
		}
		
		float* out = interpreter->typed_tensor<float>(input);
		const int wanted_height = 28;
		const int wanted_width = 28;
		const int wanted_channels = 1;
		
		for (int y = 0; y < wanted_height; ++y) {
			const int in_y = (y * image_height) / wanted_height;
			uint8_t* in_row = in + (in_y * image_width * image_channels);
			float* out_row = out + (y * wanted_width * wanted_channels);
			//NSString* tmp_str = @"";
			for (int x = 0; x < wanted_width; ++x) {
				const int in_x = (x * image_width) / wanted_width;
				uint8_t* in_pixel = (in_row + (in_x * image_channels));
				if(*in_pixel==255){
					*in_pixel = 0;
					//tmp_str = [tmp_str stringByAppendingString:@"0"];
				}else{
					*in_pixel = 1;
					//tmp_str = [tmp_str stringByAppendingString:@"1"];
				}
				float* out_pixel = out_row + (x * wanted_channels);
				
				for (int c = 0; c < wanted_channels; ++c) {
					out_pixel[c] = in_pixel[c];
				}
			}
			//NSLog(@"%@",tmp_str);
			
		}
		//NSLog(@"=========================");
		
		if (interpreter->Invoke() != kTfLiteOk) {
			NSLog(@"Failed to invoke!");
			return @"Failed to invoke.";
		}
		
		float* output = interpreter->typed_output_tensor<float>(0);
		NSString * labels = @" 0123456789+-×÷=≈≠><.()%[]ABCDEF√个百千万亿三四五六七八九零①②③④mπ";
		const int output_size = labels.length;
		const int kNumResults = 5;
		const float kThreshold = 0.1f;
		std::vector<std::pair<float, int> > top_results;
		GetTopN(output, output_size, kNumResults, kThreshold, &top_results);
		
		if(top_results.size() > 1){
			for (const auto& result : top_results) {
				const float confidence = result.first;
				const int index = result.second;
				NSLog(@"index=%i;confidence=%f", index,confidence);
			}
		}
		return [labels substringWithRange:NSMakeRange(top_results.at(0).second, 1)];
		// return [NSString stringWithFormat:@"%i",top_results.at(0).second];
	}
	
	
	BOOL upload(NSMutableArray* arr, NSString* pathStr, NSString* versionName){
		NSLog(@"start uploading mnist result...");
		//NSString* urlString = @"http://192.168.6.31:30956/pyocr/savemnistdata";
		//NSString* urlString = @"http://192.168.20.18:8080/pyocr/savemnistdata";
		NSString* urlString = @"http://api.k12china.com/pyocr/savemnistdata";
		NSURL * URL = [NSURL URLWithString:urlString];
		
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:0 error:0];
		NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		NSString *payload = [NSString stringWithFormat:@"mnistresult=%@&path=%@&ver=%@", dataStr, pathStr, versionName];
		//NSLog(@"send data:%@", payload);
		NSData* postData = [payload dataUsingEncoding:NSUTF8StringEncoding];
		NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"post"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setValue:@"utf-8" forHTTPHeaderField:@"Charset"];
		[request setURL:URL];
		[request setHTTPBody:postData];
		NSURLSession *session = [NSURLSession sharedSession];
		NSURLSessionDataTask *task = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
										  if(error!=nil){
											  NSLog(@"upload mnist result error : %@", [error description]);
											  return;
										  }
										  NSDictionary *respJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
										  NSLog(@"upload mnist result resp : %@",respJson);
									  }];
		[task resume];
		return YES;
	}
	
	NSString * detectxy(NSString * jsonstr, float thickness, bool isSave){					
		NSLog(@"mnist plugin v20200226");		
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];  			
				
		NSData * jsonData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
		NSArray * pos = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
		
		// PathObject* allPObj = [[PathObject alloc] init];
		
		NSMutableArray* tmpPObjs = [PathObject getPathObjects:pos];
		NSMutableArray* pObjs = [NSMutableArray array];
		NSMutableArray* uploadDatas = [NSMutableArray array];
		NSString * mnistResult = @"";
		//BOOL skip = NO;
			
		//开始识别图片	
		for(int i=0; i<[tmpPObjs count]; i++){			
			PathObject * tmpObj = tmpPObjs[i];

			BOOL isAdded = NO;
			for(long j=[pObjs count]-1; j>=0; j--){
				PathObject * tmpObj2 = pObjs[j];
				// 合笔
				if([tmpObj2 checkConnect:tmpObj]){
					// 5
					if([tmpObj2 check5:tmpObj]){
						if(i<[pObjs count]-1){
							PathObject* tmpObj3 = pObjs[i+1];
							if([tmpObj checkCross:tmpObj3]){
								break;
							}
						}

						PathObject * tmpObj3 = [[PathObject alloc] init];
						[tmpObj3 addPaths:tmpObj];
						[tmpObj3 addPaths:tmpObj2];
						UIImage* tmpBmp = [tmpObj3 drawPathToSize:28];
						NSString* mnistResult = predict(tmpBmp);
						if([mnistResult isEqualToString:@"5"]){
							tmpObj3.checked5 = YES;
							pObjs[j] = tmpObj3;
							isAdded=YES;
							break;
						}
					}
					[tmpObj2 addPaths:tmpObj];
					pObjs[j] = tmpObj2;
					isAdded = true;
					break;
				}	
				//八
				if([tmpObj2 checkCHN8:tmpObj] && (j==i+1||j==i-1))	{
					UIImage* tmpBmp = [tmpObj drawPathToSize:28];
					NSString* mnistResult = predict(tmpBmp);
					if(![mnistResult isEqualToString:@"√"] && [mnistResult isEqualToString:@"1"]){
						continue;
					}
					PathObject * tmpObj3 = [[PathObject alloc] init];
					[tmpObj3 addPaths:tmpObj];
					[tmpObj3 addPaths:tmpObj2];
					tmpBmp = [tmpObj3 drawPathToSize:28];
					mnistResult = predict(tmpBmp);
					if([mnistResult isEqualToString:@"八"]){
						tmpObj3.checked8 = YES;
						pObjs[j] = tmpObj3;
						isAdded = true;
						break;
					}
				}
			}
			if(!isAdded){
				[pObjs addObject: tmpObj];
			}		
		}

		PathObject * mP = nil;
		for(int i=0;i<[pObjs count]; i++){
			PathObject * tmpP = pObjs[i];
			UIImage * img = [tmpP drawPathToSize:28];
			// [allPObj addPaths:pObjs[i]];
			NSString* str0 = @"";
			if(tmpP.checked8){
				str0 = @"八";				
			}
			if(tmpP.checked5){
				str0 = @"5";
			}
			if(str0.length == 0 && [tmpP.paths count] == 1 && i>=1){
				PathObject * lastObj = pObjs[i-1];
				//float lastW = lastObj.maxX - lastObj.minX;
				float lastH = lastObj.maxY - lastObj.minY;
				float size1 = MAX(lastObj.maxX-lastObj.minX, lastObj.maxY-lastObj.minY);
				float size2 = tmpP.maxX - tmpP.minX;
				if(size2 < size1*0.3 && tmpP.minY > lastObj.minY+lastH/2){
					str0 = @".";
				}
			}
			if(str0.length == 0){				
				str0 = predict(img);
				if([str0 isEqualToString:@"÷"] && [tmpP.paths count]==4){
					str0 = @"六";
				}
				if([str0 isEqualToString:@"<"] && [tmpP.paths count]==2){
					str0 = @"七";
				}else if([str0 isEqualToString:@"m"]){
					mP = tmpP;
					continue;
				}else if(mP!=nil){
					BOOL ism23 = NO;
					if([str0 isEqualToString:@"2"]){
						str0 = @"㎡";
						ism23 = YES;
					}else if([str0 isEqualToString:@"2"]){
						str0 = @"m³";
						ism23 = YES;
					}else{
						mnistResult = [NSString stringWithFormat:@"%@%@",mnistResult,"m"];
						if(isSave==YES){
							UIImage * mimg = [mP drawPathToSize:28];
							NSMutableDictionary* uploadObj = [[NSMutableDictionary alloc] init];        
							NSString* b64 = ImageToBase64(mimg);
							//NSLog(@"img b64 = %@", b64);
							[uploadObj setValue:b64 forKey:@"b64"];
							[uploadObj setValue:@"m" forKey:@"mnist"];        
							[uploadDatas addObject:uploadObj];	
						}
					}
					if(ism23==YES && isSave==YES){
						PathObject * tmpObj3 = [[PathObject alloc] init];
						[tmpObj3 addPaths:mP];
						[tmpObj3 addPaths:tmpP];
						img = [tmpObj3 drawPathToSize:28];
						tmpP = tmpObj3;
					}
					mP = nil;
				}				
			}


			if ([str0 containsString:@"Failed"]) {		
				[dictionary setValue:[NSNumber numberWithFloat:500]  forKey:@"code"];  
				[dictionary setValue:@"识别失败"  forKey:@"message"];  
				NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:0];
				NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
				NSLog(@"dataStr = %@", dataStr);				
				return dataStr;				
			}

			mnistResult = [NSString stringWithFormat:@"%@%@",mnistResult,str0];

			if(isSave == YES){
				NSMutableDictionary* uploadObj = [[NSMutableDictionary alloc] init];        
				NSString* b64 = ImageToBase64(img);
				//NSLog(@"img b64 = %@", b64);
				[uploadObj setValue:b64 forKey:@"b64"];
				[uploadObj setValue:mnistResult forKey:@"mnist"];        
				[uploadDatas addObject:uploadObj];	
			}			
		}

		if(isSave == YES){
//            if([mnistResult length] > 1){
//                NSMutableDictionary* uploadObj = [[NSMutableDictionary alloc] init];
//                UIImage* img = [allPObj drawPathToSize:224];
//                NSString* b64 = ImageToBase64(img);
//                [uploadObj setValue:b64 forKey:@"b64"];
//                [uploadObj setValue:mnistResult forKey:@"mnist"];
//                [uploadDatas addObject:uploadObj];
//            }            
			NSString *ver = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
			ver = [ver stringByReplacingOccurrencesOfString:@"." withString:@""];
			mnistext::upload(uploadDatas, jsonstr, ver);			
		}
		
		//model = nil;
		//interpreter = nil;
		
		//NSLog(@"mnist detect result : %@", mnistResult);		
		[dictionary setValue:[NSNumber numberWithFloat:200]  forKey:@"code"];  
		[dictionary setValue:mnistResult  forKey:@"message"];  
		NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:0];
		NSString *dataStr = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];		
		NSLog(@"dataStr = %@", dataStr);
		return dataStr;		

	}
	
	
	void detectclose(){
		NSLog(@"close mnist model");
	}		

}
