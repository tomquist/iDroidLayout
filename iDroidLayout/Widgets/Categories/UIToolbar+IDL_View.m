//
//  UIToolbar+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIToolbar+IDL_View.h"
#import "UIView+IDL_Layout.h"
#import "NSDictionary+IDL_ResourceManager.h"

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
    UIColor *tintColor = [attrs colorFromIDLValueForKey:@"tintColor"];
    if (tintColor != nil) {
        self.tintColor = tintColor;
    }
    NSString *barStyle = attrs[@"barStyle"];
    if (barStyle != nil) {
        self.barStyle = UIBarStyleFromString(barStyle);
    }
    NSString *translucent = attrs[@"translucent"];
    if (translucent != nil) {
        self.translucent = BOOLFromString(translucent);
    }
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    IDLLayoutMeasuredSize measuredSize;
    measuredSize.width.state = IDLLayoutMeasuredStateNone;
    measuredSize.height.state = IDLLayoutMeasuredStateNone;
    
    switch (widthMode) {
        case IDLLayoutMeasureSpecModeAtMost:
        case IDLLayoutMeasureSpecModeExactly:
            measuredSize.width.size = widthSize;
            break;
        default:
            measuredSize.width.size = 320.f;
            break;
    }
    switch (heightMode) {
        case IDLLayoutMeasureSpecModeExactly:
            measuredSize.height.size = heightSize;
            break;
        default:
            measuredSize.height.size = 44.f;
            break;
    }
    measuredSize.width.size = MAX(measuredSize.width.size, self.minSize.width);
    
    [self setMeasuredDimensionSize:measuredSize];
}

@end
