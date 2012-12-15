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
    if ([string rangeOfString:@"#" options:0 range:NSMakeRange(0, 1)].location == 0) {
        NSScanner *scanner = [NSScanner scannerWithString:[string substringFromIndex:1]];
        NSUInteger length = [string length]-1;

        uint color;
        CGFloat alpha = 1.f;
        CGFloat red   = 0.f;
        CGFloat green = 0.f;
        CGFloat blue  = 0.f;
        [scanner scanHexInt:&color];
        
        BOOL valid = FALSE;
        switch (length) {
            case 5:
            case 4:
                alpha = ((color & 0xF000) >> 12) / 15.0;
            case 3:
                red   = ((color & 0xF00) >> 8) / 15.0f;
                green = ((color & 0x0F0) >> 4) / 15.0f;
                blue  =  (color & 0x00F) / 15.0f;
                valid = TRUE;
                break;
            case 8:
                alpha = ((color & 0xFF000000) >> 24) / 255.0f;
            case 7:
            case 6:
                red   = ((color & 0xFF0000) >> 16) / 255.0f;
                green = ((color & 0x00FF00) >> 8) / 255.0f;
                blue  =  (color & 0x0000FF) / 255.0f;
                valid = TRUE;
                break;
            default:
                break;
        }
        if (valid) {
            ret = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        }
    }
    return ret;
}

@end
