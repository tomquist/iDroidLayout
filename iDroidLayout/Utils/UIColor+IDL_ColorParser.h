//
//  UIColor+IDL_ColorParser.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (IDL_ColorParser)

+ (UIColor *)colorFromIDLColorString:(NSString *)string;

@end
