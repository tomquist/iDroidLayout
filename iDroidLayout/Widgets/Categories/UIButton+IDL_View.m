//
//  UIButton+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIButton+IDL_View.h"
#import "UIView+IDL_Layout.h"
#import "IDLGravity.h"
#import "IDLResourceManager.h"
#import "UIColor+IDL_ColorParser.h"
#import "UIImage+IDL_FromColor.h"

@implementation UIButton (Layout)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    /*NSString *backgroundString = [attrs objectForKey:@"background"];
    if (backgroundString != nil) {
        NSMutableDictionary *mutableAttrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
        [mutableAttrs removeObjectForKey:@"background"];
        attrs = mutableAttrs;
    }*/
    
    [super setupFromAttributes:attrs];
    NSString *text = attrs[@"text"];
    if ([[IDLResourceManager currentResourceManager] isValidIdentifier:text]) {
        NSString *title = [[IDLResourceManager currentResourceManager] stringForIdentifier:text];
        [self setTitle:title forState:UIControlStateNormal];
    } else {
        [self setTitle:text forState:UIControlStateNormal];
    }
    NSString *textColor = attrs[@"textColor"];
    if ([textColor length] > 0) {
        IDLColorStateList *colorStateList = [[IDLResourceManager currentResourceManager] colorStateListForIdentifier:textColor];
        if (colorStateList != nil) {
            for (NSInteger i=[colorStateList.items count]-1; i>=0; i--) {
                IDLColorStateItem *item = (colorStateList.items)[i];
                [self setTitleColor:item.color forState:item.controlState];
            }
        } else {
            UIColor *color = [UIColor colorFromIDLColorString:textColor];
            if (color != nil) {
                [self setTitleColor:color forState:UIControlStateNormal];
            }
        }
    }
    
    NSString *fontName = attrs[@"font"];
    NSString *textSize = attrs[@"textSize"];
    if (fontName != nil) {
        CGFloat size = self.titleLabel.font.pointSize;
        if (textSize != nil) size = [textSize floatValue];
        self.titleLabel.font = [UIFont fontWithName:fontName size:size];
    } else if (textSize != nil) {
        CGFloat size = [textSize floatValue];
        self.titleLabel.font = [UIFont systemFontOfSize:size];
    }

    
    /*if ([backgroundString length] > 0) {
        IDLDrawableStateList *drawableStateList = [[IDLResourceManager currentResourceManager] drawableStateListForIdentifier:backgroundString];
        if (drawableStateList != nil) {
            for (NSInteger i=[drawableStateList.items count]-1; i>=0; i--) {
                IDLDrawableStateItem *item = [drawableStateList.items objectAtIndex:i];
                [self setBackgroundImage:item.image forState:item.controlState];
            }
        } else {
            UIColor *color = [UIColor colorFromIDLColorString:backgroundString];
            if (color != nil) {
                UIImage *image = [UIImage idl_imageFromColor:color withSize:CGSizeMake(1, 1)];
                [self setBackgroundImage:image forState:UIControlStateNormal];
            }
        }
    }*/
    
    NSString *imageString = attrs[@"image"];
    if ([imageString length] > 0) {
        IDLDrawableStateList *drawableStateList = [[IDLResourceManager currentResourceManager] drawableStateListForIdentifier:imageString];
        if (drawableStateList != nil) {
            for (NSInteger i=[drawableStateList.items count]-1; i>=0; i--) {
                IDLDrawableStateItem *item = (drawableStateList.items)[i];
                [self setBackgroundImage:item.image forState:item.controlState];
            }
        }
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
    UIEdgeInsets padding = self.padding;
    
    
    if (widthMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font];
        measuredSize.width.size = ceilf(size.width) + padding.left + padding.right;
        if (widthMode == IDLLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX) lineBreakMode:self.titleLabel.lineBreakMode];
        measuredSize.height.size = ceilf(size.height) + padding.top + padding.bottom;
        if (heightMode == IDLLayoutMeasureSpecModeAtMost) {
            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
        }
    }
    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
    
    [self setMeasuredDimensionSize:measuredSize];
}

- (void)setGravity:(IDLViewContentGravity)gravity {
    if ((gravity & IDLViewContentGravityTop) == IDLViewContentGravityTop) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    } else if ((gravity & IDLViewContentGravityBottom) == IDLViewContentGravityBottom) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    } else if ((gravity & IDLViewContentGravityFillVertical) == IDLViewContentGravityFillVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    }
}

- (void)setPadding:(UIEdgeInsets)padding {
    [super setPadding:padding];
    self.contentEdgeInsets = padding;
}


@end
