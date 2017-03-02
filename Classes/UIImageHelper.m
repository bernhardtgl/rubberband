//
//  UIImageHelper.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 2/1/09.
//  Copyright 2009 GBCB Software. All rights reserved.
//

#import "UIImageHelper.h"

@implementation UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image 
			  scaledToSize:(CGSize)newSize;
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}
- (UIImage*)scaleImageToSize:(CGSize)newSize
{
	return [UIImage imageWithImage:self scaledToSize:newSize];
}
@end
