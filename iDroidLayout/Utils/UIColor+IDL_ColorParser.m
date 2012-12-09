//
//  UIColor+IDL_ColorParser.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIColor+IDL_ColorParser.h"

@implementation UIColor (IDL_ColorParser)

+ (UIColor *)colorFromIDLColorString:(NSString *)string {
    if (string == nil) return nil;
    UIColor *ret = nil;
    if ([string rangeOfString:@"#" options:0 range:NSMakeRange(0, 1)].location != NSNotFound) {
        NSScanner *scanner = [NSScanner scannerWithString:[string substringFromIndex:1]];
        uint base = 0;
        if ([string length] <= 7) { // Without alpha set alpha to FF
            base = 0xFF000000;
        }
        
        uint color;
        [scanner scanHexInt:&color];
        color |= base;
        
        CGFloat alpha = ((color & 0xFF000000) >> 24) / 255.0f;
        CGFloat red   = ((color & 0x00FF0000) >> 16) / 255.0f;
        CGFloat green = ((color & 0x0000FF00) >>  8) / 255.0f;
        CGFloat blue  =  (color & 0x000000FF) / 255.0f;
        ret = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    return ret;
}

@end
