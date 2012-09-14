//
//  UIImageView+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIImageView+IDL_View.h"
#import "UIView+IDL_Layout.h"

@implementation UIImageView (Layout)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    NSString *imageRes = [attrs objectForKey:@"src"];
    self.image = [UIImage imageNamed:imageRes];
    
    NSString *scaleType = [attrs objectForKey:@"scaleType"];
    if (scaleType != nil) {
        if ([scaleType isEqualToString:@"center"]) {
            self.contentMode = UIViewContentModeCenter;
        } else if ([scaleType isEqualToString:@"centerCrop"]) {
            self.contentMode = UIViewContentModeScaleAspectFill;
            self.clipsToBounds = TRUE;
        } else if ([scaleType isEqualToString:@"centerInside"]) {
            self.contentMode = UIViewContentModeScaleAspectFit;
        } else if ([scaleType isEqualToString:@"fitXY"]) {
            self.contentMode = UIViewContentModeScaleToFill;
        } else if ([scaleType isEqualToString:@"top"]) {
            self.contentMode = UIViewContentModeTop;
        } else if ([scaleType isEqualToString:@"topLeft"]) {
            self.contentMode = UIViewContentModeTopLeft;
        } else if ([scaleType isEqualToString:@"topRight"]) {
            self.contentMode = UIViewContentModeTopRight;
        } else if ([scaleType isEqualToString:@"left"]) {
            self.contentMode = UIViewContentModeLeft;
        } else if ([scaleType isEqualToString:@"right"]) {
            self.contentMode = UIViewContentModeRight;
        } else if ([scaleType isEqualToString:@"bottom"]) {
            self.contentMode = UIViewContentModeBottom;
        } else if ([scaleType isEqualToString:@"bottomLeft"]) {
            self.contentMode = UIViewContentModeBottomLeft;
        } else if ([scaleType isEqualToString:@"bottomRight"]) {
            self.contentMode = UIViewContentModeBottomRight;
        }
    }
}

- (BOOL)isImageScaling {
    return self.contentMode == UIViewContentModeScaleAspectFill || self.contentMode == UIViewContentModeScaleAspectFit || self.contentMode == UIViewContentModeScaleToFill;
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    CGSize imageSize = self.image.size;
    IDLLayoutMeasuredDimension width;
    width.size = imageSize.width;
    width.state = IDLLayoutMeasuredStateNone;
    IDLLayoutMeasuredDimension height;
    height.size = imageSize.height;
    height.state = IDLLayoutMeasuredStateNone;
    //UIEdgeInsets padding = self.padding;
    switch (widthMode) {
        case IDLLayoutMeasureSpecModeExactly: {
            width.size = widthSize;
            if ([self isImageScaling]) {
                height.size = (width.size/imageSize.width)*imageSize.height;
            }
            break;
        }
        case IDLLayoutMeasureSpecModeAtMost: {
            if (widthSize < imageSize.width) {
                width.size = widthSize;
                if ([self isImageScaling]) {
                    height.size = (width.size/imageSize.width)*imageSize.height;
                }
            }
            break;
        }
        case IDLLayoutMeasureSpecModeUnspecified:
        default:
            break;
    }
    switch (heightMode) {
        case IDLLayoutMeasureSpecModeExactly:
            height.size = heightSize;
            break;
        case IDLLayoutMeasureSpecModeAtMost:
            height.size = MIN(heightSize, height.size);
            break;
        case IDLLayoutMeasureSpecModeUnspecified:
        default:
            break;
    }
    //if (widthMode == IDLLayoutMeasureSpecModeAtMost || widthMode == IDLLayoutMeasureSpecModeUnspecified) {
    width.size = MIN(width.size, (height.size/imageSize.height) * imageSize.width);
    //}
    [self setMeasuredDimensionWidth:width height:height];
}

@end
