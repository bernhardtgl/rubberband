//
//  UIImageHelper.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 2/1/09.
//  Copyright 2009 GBCB Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
- (UIImage*)scaleImageToSize:(CGSize)newSize;
@end
