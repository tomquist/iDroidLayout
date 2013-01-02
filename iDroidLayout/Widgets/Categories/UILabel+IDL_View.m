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

#include "objc/runtime.h"
#include "objc/message.h"

@implementation UILabel (Layout)

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
        self.textAlignment = UITextAlignmentLeft;
    } else if ((gravity & IDLViewContentGravityRight) == IDLViewContentGravityRight) {
        self.textAlignment = UITextAlignmentRight;
    } else {
        self.textAlignment = UITextAlignmentCenter;
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
    
    if (widthMode == IDLLayoutMeasureSpecModeExactly) {
        width.size = widthSize;
    } else {
        CGSize size = [self.text sizeWithFont:self.font];
        width.size = size.width;
        if (widthMode == IDLLayoutMeasureSpecModeAtMost) {
            width.size = MIN(width.size, widthSize);
        }
    }
    width.size = MAX(width.size, self.minWidth);
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        height.size = heightSize;
    } else {
        CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(width.size, CGFLOAT_MAX) lineBreakMode:self.lineBreakMode];
        height.size = MAX(size.height, self.numberOfLines * self.font.lineHeight);
        if (heightMode == IDLLayoutMeasureSpecModeAtMost) {
            height.size = MIN(height.size, heightSize);
        }
    }
    height.size = MAX(height.size, self.minHeight);
    
    [self setMeasuredDimensionWidth:width height:height];
}

- (void)onBackgroundDrawableChanged {
    __block id selfRef = self;
    if (![self idl_hasObserverWithIdentifier:@"uiLabelFrameObserver"]) {
        [self idl_addObserver:^(NSString *keyPath, id object, NSDictionary *change) {
            [selfRef onBackgroundDrawableChanged];
        } withIdentifier:@"uiLabelFrameObserver" forKeyPaths:@[@"frame"] options:NSKeyValueObservingOptionNew];
    }
    
    IDLDrawable *drawable = self.backgroundDrawable;
    if (drawable != nil && !CGSizeEqualToSize(CGSizeZero, self.bounds.size)) {
        UIImage *image = [drawable renderToImageOfSize:self.bounds.size];
        self.backgroundColor = [UIColor colorWithPatternImage:image];
    } else {
        self.backgroundColor = nil;
    }
}


@end
