//
//  IDLEditText.m
//  iDroidLayout
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLEditText.h"
#import "UIView+IDL_Layout.h"
#import "UILabel+IDL_View.h"

@implementation IDLEditText

@synthesize contentVerticalAlignment = _contentVerticalAlignment;

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    IDLLayoutMeasuredSize measuredSize;
    measuredSize.width.state = IDLLayoutMeasuredStateNone;
    IDLLayoutMeasuredDimension height;
    measuredSize.height.state = IDLLayoutMeasuredStateNone;
    UIEdgeInsets padding = self.padding;
    
    
    if (widthMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size = [self.text sizeWithFont:self.font];
        measuredSize.width.size = size.width + padding.left + padding.right;
        if (widthMode == IDLLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX)];
        height.size = MAX(size.height, self.font.lineHeight) + padding.top + padding.bottom;
        if (heightMode == IDLLayoutMeasureSpecModeAtMost) {
            height.size = MIN(height.size, heightSize);
        }
    }
    height.size = MAX(height.size, minSize.height);
    
    [self setMeasuredDimensionSize:measuredSize];
}


- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    [super setContentVerticalAlignment:contentVerticalAlignment];
    _contentVerticalAlignment = contentVerticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.padding);
    CGRect rect = [super textRectForBounds:bounds];
    CGRect result;
    switch (_contentVerticalAlignment) {
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

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.padding);
    CGRect rect = [super editingRectForBounds:bounds];
    CGRect result;
    switch (_contentVerticalAlignment) {
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

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.padding);
    CGRect rect = [super placeholderRectForBounds:bounds];
    CGRect result;
    switch (_contentVerticalAlignment) {
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
    CGRect r = [self textRectForBounds:rect];
    [super drawTextInRect:r];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    CGRect r = [self textRectForBounds:rect];
    [super drawPlaceholderInRect:r];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self requestLayout];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self requestLayout];
}

@end
