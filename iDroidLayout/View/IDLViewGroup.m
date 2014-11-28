//
//  ViewGroup.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewGroup.h"
#import "IDLMarginLayoutParams.h"

@implementation IDLViewGroup



- (instancetype)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        
    }
    return self;
}

/**
 * Does the hard part of measureChildren: figuring out the MeasureSpec to
 * pass to a particular child. This method figures out the right MeasureSpec
 * for one dimension (height or width) of one child view.
 *
 * The goal is to combine information from our MeasureSpec with the
 * LayoutParams of the child to get the best possible results. For example,
 * if the this view knows its size (because its MeasureSpec has a mode of
 * EXACTLY), and the child has indicated in its LayoutParams that it wants
 * to be the same size as the parent, the parent should ask the child to
 * layout given an exact size.
 *
 * @param spec The requirements for this view
 * @param padding The padding of this view for the current dimension and
 *        margins, if applicable
 * @param childDimension How big the child wants to be in the current
 *        dimension
 * @return a MeasureSpec integer for the child
 */
+ (IDLLayoutMeasureSpec)childMeasureSpecForMeasureSpec:(IDLLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension {
    IDLLayoutMeasureSpecMode specMode = spec.mode;
    CGFloat specSize = spec.size;
    
    CGFloat size = MAX(0, specSize - padding);
    
    IDLLayoutMeasureSpec result = IDLLayoutMeasureSpecMake(0.f, IDLLayoutMeasureSpecModeUnspecified);
    
    switch (specMode) {
            // Parent has imposed an exact size on us
        case IDLLayoutMeasureSpecModeExactly:
            if (childDimension >= 0) {
                result.size = childDimension;
                result.mode = IDLLayoutMeasureSpecModeExactly;
            } else if (childDimension == IDLLayoutParamsSizeMatchParent) {
                // Child wants to be our size. So be it.
                result.size = size;
                result.mode = IDLLayoutMeasureSpecModeExactly;
            } else if (childDimension == IDLLayoutParamsSizeWrapContent) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                result.size = size;
                result.mode = IDLLayoutMeasureSpecModeAtMost;
            }
            break;
            
            // Parent has imposed a maximum size on us
        case IDLLayoutMeasureSpecModeAtMost:
            if (childDimension >= 0) {
                // Child wants a specific size... so be it
                result.size = childDimension;
                result.mode = IDLLayoutMeasureSpecModeExactly;
            } else if (childDimension == IDLLayoutParamsSizeMatchParent) {
                // Child wants to be our size, but our size is not fixed.
                // Constrain child to not be bigger than us.
                result.size = size;
                result.mode = IDLLayoutMeasureSpecModeAtMost;
            } else if (childDimension == IDLLayoutParamsSizeWrapContent) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                result.size = size;
                result.mode = IDLLayoutMeasureSpecModeAtMost;
            }
            break;
            
            // Parent asked to see how big we want to be
        case IDLLayoutMeasureSpecModeUnspecified:
            if (childDimension >= 0) {
                // Child wants a specific size... let him have it
                result.size = childDimension;
                result.mode = IDLLayoutMeasureSpecModeExactly;
            } else if (childDimension == IDLLayoutParamsSizeMatchParent) {
                // Child wants to be our size... find out how big it should
                // be
                result.size = 0;
                result.mode = IDLLayoutMeasureSpecModeUnspecified;
            } else if (childDimension == IDLLayoutParamsSizeWrapContent) {
                // Child wants to determine its own size.... find out how
                // big it should be
                result.size = 0;
                result.mode = IDLLayoutMeasureSpecModeUnspecified;
            }
            break;
    }
    return result;
}

- (void)onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    @throw [NSException exceptionWithName:@"UnimplementedMethodException" reason:@"onLayoutWithFrame:didFrameChange: has to be implemented in a ViewGroup subclass" userInfo:nil];
}


- (BOOL)isViewGroup {
    return TRUE;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /*IDLLayoutMeasureSpec widthMeasureSpec;
     IDLLayoutMeasureSpec heightMeasureSpec;
     widthMeasureSpec.size = self.frame.size.width;
     heightMeasureSpec.size = self.frame.size.height;
     widthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
     heightMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
     [self measureWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
     [self layoutWithFrame:self.frame];*/
}

@end
