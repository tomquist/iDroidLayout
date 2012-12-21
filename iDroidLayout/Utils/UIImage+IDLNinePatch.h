//
//  UIImage+IDLNinePatch.h
//  iDroidLayout
//
//  Created by Tom Quist on 19.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IDLNinePatch)

+ (UIImage *)idl_imageWithName:(NSString *)name fromBundle:(NSBundle *)bundle;

@property (nonatomic, readonly) BOOL hasNinePatchPaddings;
@property (nonatomic, readonly) UIEdgeInsets ninePatchPaddings;

@end
