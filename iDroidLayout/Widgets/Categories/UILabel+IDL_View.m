//
//  UILabel+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UILabel+IDL_View.h"
#import "UIView+IDL_Layout.h"
#import "UIColor+IDL_ColorParser.h"
#import "IDLResourceManager.h"
#import "NSDictionary+IDL_ResourceManager.h"
#import "UIView+IDLDrawable.h"
#import "NSObject+IDL_KVOObserver.h"
#import "IDLColorDrawable.h"

#include "objc/runtime.h"
#include "objc/message.h"

@implementation UILabel (Layout)

+ (void)load {
    Class c = self;
    SEL origSEL = @selector(drawRect:);
    SEL overrideSEL = @selector(idl_drawRect:);
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    
    self.text = [attrs stringFromIDLValueForKey:@"text"];
    
    self.gravity = [IDLGravity gravityFromAttribute:[attrs objectForKey:@"gravity"]];
    NSString *lines = [attrs objectForKey:@"lines"];
    self.numberOfLines = [lines integerValue];
    
    IDLColorStateList *textColorStateList = [attrs colorStateListFromIDLValueForKey:@"textColor"];
    if (textColorStateList != nil) {
        self.textColor = [textColorStateList colorForControlState:UIControlStateNormal];
        UIColor *highlightedColor = [textColorStateList colorForControlState:UIControlStateHighlighted];
        if (highlightedColor != nil) {
            self.highlightedTextColor = highlightedColor;
        }
    } else {
        UIColor *color = [attrs colorFromIDLValueForKey:@"textColor"];
        if (color != nil) {
            self.textColor = color;
        }
    }
    
    NSString *fontName = [attrs objectForKey:@"font"];
    NSString *textSize = [attrs objectForKey:@"textSize"];
    if (fontName != nil) {
        CGFloat size = self.font.pointSize;
        if (textSize != nil) size = [textSize floatValue];
        self.font = [UIFont fontWithName:fontName size:size];
    } else if (textSize != nil) {
        CGFloat size = [textSize floatValue];
        self.font = [UIFont systemFontOfSize:size];
    }
}

- (IDLViewContentGravity)gravity {
    IDLViewContentGravity ret;
    switch (self.textAlignment) {
        case NSTextAlignmentLeft:
            ret = IDLViewContentGravityLeft;
            break;
        case NSTextAlignmentRight:
            ret = IDLViewContentGravityRight;
            break;
        case NSTextAlignmentCenter:
            ret = IDLViewContentGravityCenterHorizontal;
            break;
        case NSTextAlignmentJustified:
            ret = IDLViewContentGravityFillHorizontal;
            break;
        default:
            ret = IDLViewContentGravityNone;
            break;
    }
    return ret;
}

- (void)setGravity:(IDLViewContentGravity)gravity {
    if ((gravity & IDLViewContentGravityLeft) == IDLViewContentGravityLeft) {
        self.textAlignment = NSTextAlignmentLeft;
    } else if ((gravity & IDLViewContentGravityRight) == IDLViewContentGravityRight) {
        self.textAlignment = NSTextAlignmentRight;
    } else {
        self.textAlignment = NSTextAlignmentCenter;
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
    
    if (widthMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: self.font}
                                                        context:nil].size;
        measuredSize.width.size = ceilf(size.width);
        if (widthMode == IDLLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        //CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(measuredSize.width.size, CGFLOAT_MAX) lineBreakMode:self.lineBreakMode];
        CGSize size = [self.text boundingRectWithSize:CGSizeMake(measuredSize.width.size, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: self.font}
                                              context:nil].size;
        measuredSize.height.size = MAX(ceilf(size.height), self.numberOfLines * self.font.lineHeight);
        if (heightMode == IDLLayoutMeasureSpecModeAtMost) {
            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
        }
    }
    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
    
    [self setMeasuredDimensionSize:measuredSize];
}

- (void)setBackgroundDrawable:(IDLDrawable *)backgroundDrawable {
    self.backgroundDrawable.delegate = nil;
    [super setBackgroundDrawable:backgroundDrawable];
}

- (void)onBackgroundDrawableChanged {
    static NSString *BackgroundDrawableFrameTag = @"backgroundDrawableFrame";
    IDLDrawable *drawable = self.backgroundDrawable;
    if (drawable != nil) {
        drawable.delegate = self;
        drawable.state = UIControlStateNormal;
        self.backgroundColor = [UIColor clearColor];
        
        if (![self idl_hasObserverWithIdentifier:BackgroundDrawableFrameTag]) {
            __weak UIView *selfRef = self;
            [self idl_addObserver:^(NSString *keyPath, id object, NSDictionary *change) {
                selfRef.backgroundDrawable.bounds = selfRef.bounds;
                [selfRef setNeedsDisplay];
            } withIdentifier:BackgroundDrawableFrameTag forKeyPaths:@[@"frame"] options:NSKeyValueObservingOptionNew];
        }
    } else {
        [self idl_removeObserverWithIdentifier:BackgroundDrawableFrameTag];
    }
    [self setNeedsDisplay];
}

- (void)idl_drawRect:(CGRect)rect {
    IDLDrawable *drawable = self.backgroundDrawable;
    if (drawable != nil) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        drawable.bounds = rect;
        [drawable drawInContext:context];
    }
    [self idl_drawRect:rect];
}

- (void)drawableDidInvalidate:(IDLDrawable *)drawable {
    [self setNeedsDisplay];
}

@end
