//
//  IDLGradientDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"

typedef enum IDLGradientDrawableShape {
    IDLGradientDrawableShapeRectangle = 0,
    IDLGradientDrawableShapeOval,
    IDLGradientDrawableShapeLine,
    IDLGradientDrawableShapeRing
} IDLGradientDrawableShape;

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
