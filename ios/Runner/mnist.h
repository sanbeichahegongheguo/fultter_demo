#ifndef MNISTEXT_H
#define MNISTEXT_H

namespace mnistext{
	BOOL upload(NSMutableArray* arr, NSString* pathStr);
	NSString * detectxy(NSString * jsonstr, float thickness, bool isSave);	
	void detectclose();
	NSString * predict(UIImage * img);
	
}
	

#endif
