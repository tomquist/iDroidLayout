//
//  UIScrollView+IDL_ViewGroup.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIScrollView+IDL_ViewGroup.h"
#import "UIView+IDL_Layout.h"
#import "IDLMarginLayoutParams.h"
#import "UIView+IDL_ViewGroup.h"
#import "IDLFrameLayoutLayoutParams.h"

#pragma mark - import libs
#include <objc/runtime.h>

#pragma mark -

#define DEFAULT_CHILD_GRAVITY IDLViewContentGravityTop | IDLViewContentGravityLeft

@implementation UIScrollView (Layout)

static char matchParentChildrenKey;

- (IDLLayoutParams *)generateDefaultLayoutParams {
    return [[[IDLFrameLayoutLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeMatchParent height:IDLLayoutParamsSizeMatchParent] autorelease];
}

- (IDLLayoutParams *)generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[[IDLFrameLayoutLayoutParams alloc] initWithAttributes:attrs] autorelease];
}

- (BOOL)checkLayoutParams:(IDLLayoutParams *)layoutParams {
    return  layoutParams != nil;
}

- (void)setMatchParentChildren:(NSMutableArray *)list {
    objc_setAssociatedObject(self,
                             &matchParentChildrenKey,
                             list,
                             OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)matchParentChildren {
    NSMutableArray *list = objc_getAssociatedObject(self, &matchParentChildrenKey);
    if (list == nil) {
        list = [NSMutableArray arrayWithCapacity:[self.subviews count]];
        [self setMatchParentChildren:list];
    }
    return list;
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    NSInteger count = MIN(1, [self.subviews count]);
    
    BOOL measureMatchParentChildren = widthMeasureSpec.mode != IDLLayoutMeasureSpecModeExactly || heightMeasureSpec.mode != IDLLayoutMeasureSpecModeExactly;
    NSMutableArray *matchParentChildren = self.matchParentChildren;
    [matchParentChildren removeAllObjects];
    
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;
    UIEdgeInsets padding = self.padding;
    IDLLayoutMeasuredWidthHeightState childState;
    childState.heightState = IDLLayoutMeasuredStateNone;
    childState.widthState = IDLLayoutMeasuredStateNone;
    
    for (int i = 0; i < count; i++) {
        UIView *child = [self.subviews objectAtIndex:i];
        [self measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
        IDLFrameLayoutLayoutParams *lp = (IDLFrameLayoutLayoutParams *)child.layoutParams;
        maxWidth = MAX(maxWidth, child.measuredSize.width + lp.margin.left + lp.margin.right);
        maxHeight = MAX(maxHeight, child.measuredSize.height + lp.margin.top + lp.margin.bottom);
        childState = [UIView combineMeasuredStatesCurrentState:childState newState:child.measuredState];
        if (measureMatchParentChildren) {
            if (lp.width == IDLLayoutParamsSizeMatchParent || lp.height == IDLLayoutParamsSizeMatchParent) {
                [matchParentChildren addObject:child];
            }
        }
    }
    
    // Account for padding too
    maxWidth += padding.left + padding.right;
    maxHeight += padding.top + padding.bottom;
    
    // Check against our minimum height and width
    maxHeight = MAX(maxHeight, self.minHeight);
    maxWidth = MAX(maxWidth, self.minWidth);
    
    // Check against our foreground's minimum height and width
    [self setMeasuredDimensionWidth:[UIView resolveSizeAndStateForSize:maxWidth measureSpec:widthMeasureSpec childMeasureState:childState.widthState] height:[UIView resolveSizeAndStateForSize:maxHeight measureSpec:heightMeasureSpec childMeasureState:childState.heightState]];
    
    count = [matchParentChildren count];
    if (count > 1) {
        for (int i = 0; i < count; i++) {
            UIView *child = [matchParentChildren objectAtIndex:i];
            
            IDLMarginLayoutParams *lp = (IDLMarginLayoutParams *)child.layoutParams;
            IDLLayoutMeasureSpec childWidthMeasureSpec;
            IDLLayoutMeasureSpec childHeightMeasureSpec;
            
            if (lp.width == IDLLayoutParamsSizeMatchParent) {
                childWidthMeasureSpec.size = self.measuredSize.width - padding.left - padding.right - lp.margin.left - lp.margin.right;
                childWidthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
            } else {
                childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:widthMeasureSpec padding:(padding.left + padding.right + lp.margin.left + lp.margin.right) childDimension:lp.width];
            }
            
            if (lp.height == IDLLayoutParamsSizeMatchParent) {
                childHeightMeasureSpec.size = self.measuredSize.height - padding.top - padding.bottom - lp.margin.top - lp.margin.bottom;
                childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
            } else {
                childHeightMeasureSpec = [self childMeasureSpecWithMeasureSpec:heightMeasureSpec padding:(padding.top + padding.bottom + lp.margin.top + lp.margin.bottom) childDimension:lp.height];
            }
            [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
        }
    }
    
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    if (heightMode == IDLLayoutMeasureSpecModeUnspecified) {
        return;
    }
    
    /*if ([self.subviews count] > 0) {
     UIView *child = [self.subviews objectAtIndex:0];
     CGFloat height = self.measuredSize.height;
     CGSize childMeasuredSize = child.measuredSize;
     if (child.measuredSize.height < height) {
     FrameLayoutLayoutParams *lp = (FrameLayoutLayoutParams *) child.layoutParams;
     
     IDLLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:widthMeasureSpec padding:(padding.left + padding.right) childDimension:lp.width];
     height -= padding.top;
     height -= padding.bottom;
     IDLLayoutMeasureSpec childHeightMeasureSpec = IDLLayoutMeasureSpecMake(height, IDLLayoutMeasureSpecModeExactly);
     
     [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
     }
     }*/
}

- (void)onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    NSInteger count = MIN(1, [self.subviews count]);
    
    UIEdgeInsets padding = self.padding;
    CGFloat parentLeft = padding.left;
    CGFloat parentRight = frame.size.width - padding.right;
    
    CGFloat parentTop = padding.top;
    CGFloat parentBottom = frame.size.height - padding.bottom;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    for (int i = 0; i < count; i++) {
        UIView *child = [self.subviews objectAtIndex:i];
        IDLFrameLayoutLayoutParams *lp = (IDLFrameLayoutLayoutParams *)child.layoutParams;
        
        CGFloat width = child.measuredSize.width;
        CGFloat height = child.measuredSize.height;
        
        CGFloat childLeft;
        CGFloat childTop;
        
        IDLViewContentGravity gravity = lp.gravity;
        if (gravity == -1) {
            gravity = DEFAULT_CHILD_GRAVITY;
        }
        
        IDLViewContentGravity verticalGravity = gravity & VERTICAL_GRAVITY_MASK;
        
        switch (gravity & HORIZONTAL_GRAVITY_MASK) {
            case IDLViewContentGravityLeft:
                childLeft = parentLeft + lp.margin.left;
                break;
            case IDLViewContentGravityCenterHorizontal:
                childLeft = parentLeft + (parentRight - parentLeft - width) / 2 + lp.margin.left - lp.margin.right;
                break;
            case IDLViewContentGravityRight:
                childLeft = parentRight - width - lp.margin.right;
                break;
            default:
                childLeft = parentLeft + lp.margin.left;
        }
        
        switch (verticalGravity) {
            case IDLViewContentGravityTop:
                childTop = parentTop + lp.margin.top;
                break;
            case IDLViewContentGravityCenterVertical:
                childTop = parentTop + (parentBottom - parentTop - height) / 2 +
                lp.margin.top - lp.margin.bottom;
                break;
            case IDLViewContentGravityBottom:
                childTop = parentBottom - height - lp.margin.bottom;
                break;
            default:
                childTop = parentTop + lp.margin.top;
        }
        
        [child layoutWithFrame:CGRectMake(childLeft, childTop, width, height)];
        maxX = MAX(maxX, childLeft + width);
        maxY = MAX(maxY, childTop + height);
    }
    self.contentSize = CGSizeMake(maxX + padding.right, maxY + padding.bottom);
}

- (void)measureChild:(UIView *)child withParentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec {
    IDLLayoutParams *lp = child.layoutParams;
    
    IDLLayoutMeasureSpec childWidthMeasureSpec;
    IDLLayoutMeasureSpec childHeightMeasureSpec;
    
    childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:self.padding.left + self.padding.right childDimension:lp.width];
    
    childHeightMeasureSpec.size = 0;
    childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeUnspecified;
    
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (void)measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed {
    IDLMarginLayoutParams *lp = (IDLMarginLayoutParams *)child.layoutParams;
    UIEdgeInsets padding = self.padding;
    IDLLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:(padding.left + padding.right + lp.margin.left + lp.margin.right + widthUsed) childDimension:lp.width];
    IDLLayoutMeasureSpec childHeightMeasureSpec;
    childHeightMeasureSpec.size = lp.margin.top + lp.margin.bottom + parentHeightMeasureSpec.size;
    childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeUnspecified;
    
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (BOOL)isViewGroup {
    return TRUE;
}

@end
