//
//  TextView.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLTextView.h"
#import "UIView+IDL_Layout.h"
#import "UILabel+IDL_View.h"

@implementation IDLTextView

@synthesize contentVerticalAlignment = _contentVerticalAlignment;

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
        CGSize size = [self.text sizeWithFont:self.font];
        width.size = size.width + padding.left + padding.right;
        if (widthMode == IDLLayoutMeasureSpecModeAtMost) {
            width.size = MIN(width.size, widthSize);
        }
    }
    width.size = MAX(width.size, self.minWidth);
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        height.size = heightSize;
    } else {
        CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(width.size - padding.left - padding.right, CGFLOAT_MAX) lineBreakMode:self.lineBreakMode];
        height.size = MAX(size.height, self.numberOfLines * self.font.lineHeight) + padding.top + padding.bottom;
        if (heightMode == IDLLayoutMeasureSpecModeAtMost) {
            height.size = MIN(height.size, heightSize);
        }
    }
    height.size = MAX(height.size, self.minHeight);
    
    [self setMeasuredDimensionWidth:width height:height];
}

- (void)setGravity:(IDLViewContentGravity)gravity {
    [super setGravity:gravity];
    if ((gravity & IDLViewContentGravityTop) == IDLViewContentGravityTop) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    } else if ((gravity & IDLViewContentGravityBottom) == IDLViewContentGravityBottom) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    } else if ((gravity & IDLViewContentGravityFillVertical) == IDLViewContentGravityFillVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    }
}

- (IDLViewContentGravity)gravity {
    IDLViewContentGravity ret = [super gravity];
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            ret |= IDLViewContentGravityTop;
            break;
        case UIControlContentVerticalAlignmentBottom:
            ret |= IDLViewContentGravityBottom;
            break;
        case UIControlContentVerticalAlignmentCenter:
            ret |= IDLViewContentGravityCenterVertical;
            break;
        case UIControlContentVerticalAlignmentFill:
            ret |= IDLViewContentGravityFillVertical;
            break;
    }
    return ret;
}

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    _contentVerticalAlignment = contentVerticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    bounds = UIEdgeInsetsInsetRect(bounds, self.padding);
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    CGRect result;
    switch (_contentVerticalAlignment)
    {
        case UIControlContentVerticalAlignmentTop:
            result = CGRectMake(rect.origin.x, bounds.origin.y, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentCenter:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height) / 2, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentBottom:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height), rect.size.width, rect.size.height);
            break;
        default:
            result = bounds;
            break;
    }
    return result;
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect r = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:r];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self requestLayout];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self requestLayout];
}

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
    [super setLineBreakMode:lineBreakMode];
    [self requestLayout];
}
@end
