//
//  UIToolbar+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIToolbar+IDL_View.h"
#import "UIView+IDL_Layout.h"
#import "UIColor+IDL_ColorParser.h"

UIBarStyle UIBarStyleFromString(NSString *barStyle) {
    UIBarStyle ret = UIBarStyleDefault;
    if ([barStyle isEqualToString:@"black"]) {
        ret = UIBarStyleBlack;
    } else if ([barStyle isEqualToString:@"default"]) {
        ret = UIBarStyleDefault;
    }
    return ret;
}

@implementation UIToolbar (IDL_View)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    NSString *tintColor = [attrs objectForKey:@"tintColor"];
    if (tintColor != nil) {
        self.tintColor = [UIColor colorFromAndroidColorString:tintColor];
    }
    NSString *barStyle = [attrs objectForKey:@"barStyle"];
    if (barStyle != nil) {
        self.barStyle = UIBarStyleFromString(barStyle);
    }
    NSString *translucent = [attrs objectForKey:@"translucent"];
    if (translucent != nil) {
        self.translucent = BOOLFromString(translucent);
    }
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    IDLLayoutMeasuredDimension width;
    width.state = IDLLayoutMeasuredStateNone;
    IDLLayoutMeasuredDimension height;
    height.state = IDLLayoutMeasuredStateNone;
    
    switch (widthMode) {
        case IDLLayoutMeasureSpecModeAtMost:
        case IDLLayoutMeasureSpecModeExactly:
            width.size = widthSize;
            break;
        default:
            width.size = 320.f;
            break;
    }
    switch (heightMode) {
        case IDLLayoutMeasureSpecModeExactly:
            height.size = heightSize;
            break;
        default:
            height.size = 44.f;
            break;
    }
    width.size = MAX(width.size, self.minWidth);
    
    [self setMeasuredDimensionWidth:width height:height];
}

@end
