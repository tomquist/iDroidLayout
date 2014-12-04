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
#import "UIView+IDLDrawable.h"
#import "NSObject+IDL_KVOObserver.h"

#pragma mark - import libs
#include <objc/runtime.h>

#pragma mark -

#define DEFAULT_CHILD_GRAVITY IDLViewContentGravityTop | IDLViewContentGravityLeft

@implementation UIScrollView (IDL_ViewGroup)

+ (void)load {
    Class c = self;
    SEL origSEL = @selector(drawRect:);
    SEL overrideSEL = @selector(idl_drawRect:);
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

static char matchParentChildrenKey;

- (IDLLayoutParams *)generateDefaultLayoutParams {
    return [[IDLFrameLayoutLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeMatchParent height:IDLLayoutParamsSizeMatchParent];
}

- (IDLLayoutParams *)generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[IDLFrameLayoutLayoutParams alloc] initWithAttributes:attrs];
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
        UIView *child = (self.subviews)[i];
        if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
            continue;
        }
        
        if (child.visibility != IDLViewVisibilityGone) {
            [self measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
            IDLFrameLayoutLayoutParams *lp = (IDLFrameLayoutLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            maxWidth = MAX(maxWidth, child.measuredSize.width + lpMargin.left + lpMargin.right);
            maxHeight = MAX(maxHeight, child.measuredSize.height + lpMargin.top + lpMargin.bottom);
            childState = [UIView combineMeasuredStatesCurrentState:childState newState:child.measuredState];
            if (measureMatchParentChildren) {
                if (lp.width == IDLLayoutParamsSizeMatchParent || lp.height == IDLLayoutParamsSizeMatchParent) {
                    [matchParentChildren addObject:child];
                }
            }
        }
    }
    
    // Account for padding too
    maxWidth += padding.left + padding.right;
    maxHeight += padding.top + padding.bottom;
    
    // Check against our minimum height and width
    CGSize minSize = self.minSize;
    maxHeight = MAX(maxHeight, minSize.height);
    maxWidth = MAX(maxWidth, minSize.width);
    
    // Check against our foreground's minimum height and width
    IDLLayoutMeasuredSize measuredSize = IDLLayoutMeasuredSizeMake([UIView resolveSizeAndStateForSize:maxWidth measureSpec:widthMeasureSpec childMeasureState:childState.widthState], [UIView resolveSizeAndStateForSize:maxHeight measureSpec:heightMeasureSpec childMeasureState:childState.heightState]);
    [self setMeasuredDimensionSize:measuredSize];
    
    count = [matchParentChildren count];
    if (count > 1) {
        for (int i = 0; i < count; i++) {
            UIView *child = matchParentChildren[i];
            
            if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
                continue;
            }
            
            IDLMarginLayoutParams *lp = (IDLMarginLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            IDLLayoutMeasureSpec childWidthMeasureSpec;
            IDLLayoutMeasureSpec childHeightMeasureSpec;
            
            if (lp.width == IDLLayoutParamsSizeMatchParent) {
                childWidthMeasureSpec.size = self.measuredSize.width - padding.left - padding.right - lpMargin.left - lpMargin.right;
                childWidthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
            } else {
                childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:widthMeasureSpec padding:(padding.left + padding.right + lpMargin.left + lpMargin.right) childDimension:lp.width];
            }
            
            if (lp.height == IDLLayoutParamsSizeMatchParent) {
                childHeightMeasureSpec.size = self.measuredSize.height - padding.top - padding.bottom - lpMargin.top - lpMargin.bottom;
                childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
            } else {
                childHeightMeasureSpec = [self childMeasureSpecWithMeasureSpec:heightMeasureSpec padding:(padding.top + padding.bottom + lpMargin.top + lpMargin.bottom) childDimension:lp.height];
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
        UIView *child = (self.subviews)[i];
        
        if (child.visibility != IDLViewVisibilityGone && ![NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
            IDLFrameLayoutLayoutParams *lp = (IDLFrameLayoutLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
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
                    childLeft = parentLeft + lpMargin.left;
                    break;
                case IDLViewContentGravityCenterHorizontal:
                    childLeft = parentLeft + (parentRight - parentLeft - width) / 2 + lpMargin.left - lpMargin.right;
                    break;
                case IDLViewContentGravityRight:
                    childLeft = parentRight - width - lpMargin.right;
                    break;
                default:
                    childLeft = parentLeft + lpMargin.left;
            }
            
            switch (verticalGravity) {
                case IDLViewContentGravityTop:
                    childTop = parentTop + lpMargin.top;
                    break;
                case IDLViewContentGravityCenterVertical:
                    childTop = parentTop + (parentBottom - parentTop - height) / 2 + lpMargin.top - lpMargin.bottom;
                    break;
                case IDLViewContentGravityBottom:
                    childTop = parentBottom - height - lpMargin.bottom;
                    break;
                default:
                    childTop = parentTop + lpMargin.top;
            }
            
            [child layoutWithFrame:CGRectMake(childLeft, childTop, width, height)];
            maxX = MAX(maxX, childLeft + width);
            maxY = MAX(maxY, childTop + height);
        }
    }
    self.contentSize = CGSizeMake(maxX + padding.right, maxY + padding.bottom);
}

- (void)measureChild:(UIView *)child withParentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec {
    if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
        return;
    }
    IDLLayoutParams *lp = child.layoutParams;
    
    IDLLayoutMeasureSpec childWidthMeasureSpec;
    IDLLayoutMeasureSpec childHeightMeasureSpec;
    
    UIEdgeInsets padding = self.padding;
    childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:padding.left + padding.right childDimension:lp.width];
    
    childHeightMeasureSpec.size = 0;
    childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeUnspecified;
    
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (void)measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed {
    if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
        return;
    }
    IDLMarginLayoutParams *lp = (IDLMarginLayoutParams *)child.layoutParams;
    UIEdgeInsets lpMargin = lp.margin;
    UIEdgeInsets padding = self.padding;
    IDLLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:(padding.left + padding.right + lpMargin.left + lpMargin.right + widthUsed) childDimension:lp.width];
    IDLLayoutMeasureSpec childHeightMeasureSpec;
    childHeightMeasureSpec.size = lpMargin.top + lpMargin.bottom + parentHeightMeasureSpec.size;
    childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeUnspecified;
    
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (BOOL)isViewGroup {
    BOOL ret = FALSE;
    if ([self class] == [UIScrollView class] || [NSStringFromClass([self class]) hasSuffix:@"UIScrollView"]) {
        ret = TRUE;
    }
    return ret;
}

- (void)setBackgroundDrawable:(IDLDrawable *)backgroundDrawable {
    self.backgroundDrawable.delegate = nil;
    [super setBackgroundDrawable:backgroundDrawable];
}

- (void)onBackgroundDrawableChanged {
    static NSString *BackgroundDrawableFrameTag = @"backgroundDrawableFrame";
    IDLDrawable *drawable = self.backgroundDrawable;
    if (drawable != nil) {
        drawable.delegate = self;
        drawable.state = UIControlStateNormal;
        drawable.bounds = self.bounds;
        self.backgroundColor = [UIColor clearColor];

        if (![self idl_hasObserverWithIdentifier:BackgroundDrawableFrameTag]) {
            __weak UIView *selfRef = self;
            [self idl_addObserver:^(NSString *keyPath, id object, NSDictionary *change) {
                selfRef.backgroundDrawable.bounds = selfRef.bounds;
                [selfRef setNeedsDisplay];
            } withIdentifier:BackgroundDrawableFrameTag forKeyPaths:@[@"frame"] options:NSKeyValueObservingOptionNew];
        }
    } else {
        [self idl_removeObserverWithIdentifier:BackgroundDrawableFrameTag];
    }
    
    [self setNeedsDisplay];
}

- (void)idl_drawRect:(CGRect)rect {
    IDLDrawable *drawable = self.backgroundDrawable;
    if (drawable != nil) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        drawable.bounds = self.bounds;
        [drawable drawInContext:context];
        CGContextRestoreGState(context);
    } else {
        if (self.isOpaque) {
            UIColor *color = self.backgroundColor;
            if (color == nil) color = [UIColor whiteColor];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [color CGColor]);
            CGContextFillRect(context, self.bounds);
        }
    }
    [self idl_drawRect:rect];
}

- (void)drawableDidInvalidate:(IDLDrawable *)drawable {
    [self setNeedsDisplay];
}


@end
