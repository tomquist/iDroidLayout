//
//  UIView+IDL_ViewGroup.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIView+IDL_ViewGroup.h"
#import "IDLMarginLayoutParams.h"

@implementation UIView (IDL_ViewGroup)

- (IDLLayoutParams *)generateDefaultLayoutParams {
    return [[[IDLLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeWrapContent height:IDLLayoutParamsSizeWrapContent] autorelease];
}

- (IDLLayoutParams *)generateLayoutParamsFromLayouParams:(IDLLayoutParams *)lp {
    return lp;
}

- (IDLLayoutParams *)generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[[IDLLayoutParams alloc] initWithAttributes:attrs] autorelease];
}

- (BOOL)checkLayoutParams:(IDLLayoutParams *)layoutParams {
    return  layoutParams != nil;
}

- (BOOL)isViewGroup {
    return FALSE;
}

- (IDLLayoutMeasureSpec)childMeasureSpecWithMeasureSpec:(IDLLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension {
    IDLLayoutMeasureSpecMode specMode = spec.mode;
    CGFloat specSize = spec.size;
    
    CGFloat size = MAX(0, specSize - padding);
    
    IDLLayoutMeasureSpec result;
    result.size = 0;
    result.mode = IDLLayoutMeasureSpecModeUnspecified;
    
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

- (void)measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed {
    IDLMarginLayoutParams *lp = (IDLMarginLayoutParams *) child.layoutParams;
    IDLLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:self.padding.left + self.padding.right + lp.margin.left + lp.margin.right + widthUsed childDimension:lp.width];
    IDLLayoutMeasureSpec childHeightMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentHeightMeasureSpec padding:self.padding.top + self.padding.bottom + lp.margin.top + lp.margin.bottom + heightUsed childDimension:lp.height];
    
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

/**
 * Ask one of the children of this view to measure itself, taking into
 * account both the MeasureSpec requirements for this view and its padding.
 * The heavy lifting is done in getChildMeasureSpec.
 *
 * @param child The child to measure
 * @param parentWidthMeasureSpec The width requirements for this view
 * @param parentHeightMeasureSpec The height requirements for this view
 */
-(void)measureChild:(UIView *)child withParentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec {
    IDLLayoutParams *lp = child.layoutParams;
    
    IDLLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:(self.padding.left + self.padding.right) childDimension:lp.width];
    IDLLayoutMeasureSpec childHeightMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentHeightMeasureSpec padding:(self.padding.top + self.padding.bottom) childDimension:lp.height];
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

/**
 * Ask all of the children of this view to measure themselves, taking into
 * account both the MeasureSpec requirements for this view and its padding.
 * We skip children that are in the GONE state The heavy lifting is done in
 * getChildMeasureSpec.
 *
 * @param widthMeasureSpec The width requirements for this view
 * @param heightMeasureSpec The height requirements for this view
 */
-(void)measureChildrenWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    int size = [self.subviews count];
    for (int i = 0; i < size; ++i) {
        UIView *child = [self.subviews objectAtIndex:i];
        if (child.visibility != IDLViewVisibilityGone) {
            [self measureChild:child withParentWidthMeasureSpec:widthMeasureSpec parentHeightMeasureSpec:heightMeasureSpec];
        }
    }
}

- (UIView *)findViewTraversal:(NSString *)identifier {
    if ([self.identifier isEqualToString:identifier]) {
        return self;
    }
    
    NSArray *where = self.subviews;
    NSInteger len = [where count];
    
    for (NSInteger i = 0; i < len; i++) {
        UIView *v = [where objectAtIndex:i];
        
        v = [v findViewById:identifier];
        if (v != nil) {
            return v;
        }
    }
    return nil;
}

- (void)addView:(UIView *)child atIndex:(NSInteger)index withLayoutParams:(IDLLayoutParams *)lp {
    if (!self.isViewGroup) {
        @throw [NSException exceptionWithName:@"UnsuportedOperationException" reason:@"Views can only be added on ViewGroup objects" userInfo:nil];
    }
    if (![self checkLayoutParams:lp]) {
        if (lp != nil) {
            lp = [self generateLayoutParamsFromLayouParams:lp];
        }
        if (lp == nil || ![self checkLayoutParams:lp]) {
            lp = [self generateDefaultLayoutParams];
        }
    }
    child.layoutParams = lp;
    if (index == -1) {
        [self addSubview:child];
    } else {
        [self insertSubview:child atIndex:index];
    }
    [self requestLayout];
    
}

- (void)addView:(UIView *)child atIndex:(NSInteger)index {
    IDLLayoutParams *params = child.layoutParams;
    if (params == nil) {
        params = [self generateDefaultLayoutParams];
        if (params == nil) {
            @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:@"generateDefaultLayoutParams() cannot return nil" userInfo:nil];
        }
    }
    [self addView:child atIndex:index withLayoutParams:params];
}

- (void)addView:(UIView *)child withLayoutParams:(IDLLayoutParams *)lp {
    [self addView:child atIndex:-1 withLayoutParams:lp];
}

- (void)addView:(UIView *)child {
    [self addView:child atIndex:-1];
}

- (void)addView:(UIView *)child withSize:(CGSize)size {
    IDLLayoutParams *lp = [self generateDefaultLayoutParams];
    lp.width = size.width;
    lp.height = size.height;
    [self addView:child atIndex:-1 withLayoutParams:lp];
}

- (void)removeViewInternal:(UIView *)view {
    if (!self.isViewGroup) {
        @throw [NSException exceptionWithName:@"UnsuportedOperationException" reason:@"Views can only be removed from ViewGroup objects" userInfo:nil];
    }
    if (view.superview == self) {
        [view removeFromSuperview];
        [self onViewRemoved:view];
    }
}

- (void)removeView:(UIView *)view {
    [self removeViewInternal:view];
    [self requestLayout];
    [self setNeedsDisplay];
}

- (void)removeViewAtIndex:(NSUInteger)index {
    NSArray *subviews = self.subviews;
    if (index < [subviews count]) {
        [self removeView:[subviews objectAtIndex:index]];
    }
}

- (void)onViewRemoved:(UIView *)view {
    
}

@end
