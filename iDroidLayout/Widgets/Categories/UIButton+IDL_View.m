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
    NSString *text = [attrs objectForKey:@"text"];
    if ([[IDLResourceManager currentResourceManager] isValidIdentifier:text]) {
        NSString *title = [[IDLResourceManager currentResourceManager] stringForIdentifier:text];
        [self setTitle:title forState:UIControlStateNormal];
    } else {
        [self setTitle:text forState:UIControlStateNormal];
    }
    NSString *textColor = [attrs objectForKey:@"textColor"];
    if ([textColor length] > 0) {
        IDLColorStateList *colorStateList = [[IDLResourceManager currentResourceManager] colorStateListForIdentifier:textColor];
        if (colorStateList != nil) {
            for (NSInteger i=[colorStateList.items count]-1; i>=0; i--) {
                IDLColorStateItem *item = [colorStateList.items objectAtIndex:i];
                [self setTitleColor:item.color forState:item.controlState];
            }
        } else {
            UIColor *color = [UIColor colorFromIDLColorString:textColor];
            if (color != nil) {
                [self setTitleColor:color forState:UIControlStateNormal];
            }
        }
    }
    
    NSString *fontName = [attrs objectForKey:@"font"];
    NSString *textSize = [attrs objectForKey:@"textSize"];
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
    
    NSString *imageString = [attrs objectForKey:@"image"];
    if ([imageString length] > 0) {
        IDLDrawableStateList *drawableStateList = [[IDLResourceManager currentResourceManager] drawableStateListForIdentifier:imageString];
        if (drawableStateList != nil) {
            for (NSInteger i=[drawableStateList.items count]-1; i>=0; i--) {
                IDLDrawableStateItem *item = [drawableStateList.items objectAtIndex:i];
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
    
    IDLLayoutMeasuredDimension width;
    width.state = IDLLayoutMeasuredStateNone;
    IDLLayoutMeasuredDimension height;
    height.state = IDLLayoutMeasuredStateNone;
    UIEdgeInsets padding = self.padding;
    
    
    if (widthMode == IDLLayoutMeasureSpecModeExactly) {
        width.size = widthSize;
    } else {
        CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font];
        width.size = size.width + padding.left + padding.right;
        if (widthMode == IDLLayoutMeasureSpecModeAtMost) {
            width.size = MIN(width.size, widthSize);
        }
    }
    width.size = MAX(width.size, self.minWidth);
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        height.size = heightSize;
    } else {
        CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(width.size - padding.left - padding.right, CGFLOAT_MAX) lineBreakMode:self.titleLabel.lineBreakMode];
        height.size = size.height + padding.top + padding.bottom;
        if (heightMode == IDLLayoutMeasureSpecModeAtMost) {
            height.size = MIN(height.size, heightSize);
        }
    }
    height.size = MAX(height.size, self.minHeight);
    
    [self setMeasuredDimensionWidth:width height:height];
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
