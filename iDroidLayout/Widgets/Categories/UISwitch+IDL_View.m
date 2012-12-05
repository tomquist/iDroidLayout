//
//  UISwitch+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UISwitch+IDL_View.h"
#import "UIView+IDL_Layout.h"
#import "NSDictionary+IDL_ResourceManager.h"

@implementation UISwitch (IDL_View)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    
    UIColor *tintColor = [attrs colorFromIDLValueForKey:@"tintColor"];
    if (tintColor != nil) {
        if ([self respondsToSelector:@selector(setTintColor:)]) {
            self.tintColor = tintColor;
        }
    }
    
    UIColor *onTintColor = [attrs colorFromIDLValueForKey:@"onTintColor"];
    if (onTintColor != nil) {
        if ([self respondsToSelector:@selector(setOnTintColor:)]) {
            self.onTintColor = onTintColor;
        }
    }

    UIColor *thumbTintColor = [attrs colorFromIDLValueForKey:@"thumbTintColor"];
    if (thumbTintColor != nil) {
        if ([self respondsToSelector:@selector(setThumbTintColor:)]) {
            self.thumbTintColor = thumbTintColor;
        }
    }
    
    NSString *isOn = [attrs objectForKey:@"isOn"];
    if (isOn != nil) {
        self.on = BOOLFromString(isOn);
    }
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    IDLLayoutMeasuredDimension width;
    width.state = IDLLayoutMeasuredStateNone;
    width.size = self.frame.size.width;
    IDLLayoutMeasuredDimension height;
    height.state = IDLLayoutMeasuredStateNone;
    height.size = self.frame.size.height;
    
    [self setMeasuredDimensionWidth:width height:height];
}

@end
