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

@implementation UIButton (Layout)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    NSString *text = [attrs objectForKey:@"text"];
    [self setTitle:text forState:UIControlStateNormal];
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    IDLLayoutMeasuredDimension width;
    IDLLayoutMeasuredDimension height;
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


@end
