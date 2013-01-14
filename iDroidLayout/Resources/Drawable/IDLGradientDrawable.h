//
//  IDLGradientDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"

typedef NS_ENUM(NSInteger, IDLGradientDrawableShape) {
    IDLGradientDrawableShapeRectangle = 0,
    IDLGradientDrawableShapeOval,
    IDLGradientDrawableShapeLine,
    IDLGradientDrawableShapeRing
};

typedef NS_ENUM(NSInteger, IDLGradientDrawableGradientType) {
    IDLGradientDrawableGradientTypeNone = 0,
    IDLGradientDrawableGradientTypeLinear,
    IDLGradientDrawableGradientTypeRadial
};

typedef struct IDLGradientDrawableCornerRadius {
    CGFloat topLeft;
    CGFloat topRight;
    CGFloat bottomLeft;
    CGFloat bottomRight;
} IDLGradientDrawableCornerRadius;

UIKIT_EXTERN const IDLGradientDrawableCornerRadius IDLGradientDrawableCornerRadiusZero;

@interface IDLGradientDrawable : IDLDrawable

@end

@interface IDLGradientDrawableConstantState : IDLDrawableConstantState

@end
