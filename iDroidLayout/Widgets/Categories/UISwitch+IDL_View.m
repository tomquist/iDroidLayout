//
//  UISwitch+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UISwitch+IDL_View.h"
#import "UIView+IDL_Layout.h"
#import "UIColor+IDL_ColorParser.h"

@implementation UISwitch (IDL_View)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    
    NSString *tintColor = [attrs objectForKey:@"tintColor"];
    if (tintColor != nil) {
        if ([self respondsToSelector:@selector(setTintColor:)]) {
            self.tintColor = [UIColor colorFromAndroidColorString:tintColor];
        }
    }
    
    NSString *onTintColor = [attrs objectForKey:@"onTintColor"];
    if (onTintColor != nil) {
        if ([self respondsToSelector:@selector(setOnTintColor:)]) {
            self.onTintColor = [UIColor colorFromAndroidColorString:onTintColor];
        }
    }

    NSString *thumbTintColor = [attrs objectForKey:@"thumbTintColor"];
    if (thumbTintColor != nil) {
        if ([self respondsToSelector:@selector(setThumbTintColor:)]) {
            self.thumbTintColor = [UIColor colorFromAndroidColorString:thumbTintColor];
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
