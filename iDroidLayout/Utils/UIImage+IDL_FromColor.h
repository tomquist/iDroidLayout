//
//  UIImage+IDL_FromColor.h
//  iDroidLayout
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IDL_FromColor)

+ (UIImage *)idl_imageFromColor:(UIColor *)color withSize:(CGSize)size;

@end
