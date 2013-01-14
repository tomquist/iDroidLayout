//
//  RelativeLayout.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLRelativeLayout.h"
#import "IDLDependencyGraphNode.h"

@interface IDLRelativeLayoutLayoutParams ()

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@end

@implementation IDLRelativeLayout

@synthesize ignoreGravity = _ignoreGravity;
@synthesize gravity = _gravity;

- (void)dealloc {
	[_ignoreGravity release];
    [_sortedHorizontalChildren release];
    [_sortedVerticalChildren release];
    [_graph release];
    [_baselineView release];
	[super dealloc];
}

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    _gravity = [IDLGravity gravityFromAttribute:[attrs objectForKey:@"gravity"]];
    _ignoreGravity = [[attrs objectForKey:@"ignoreGravity"] retain];
}

- (id)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        _dirtyHierarchy = TRUE;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dirtyHierarchy = TRUE;
        _graph = [[IDLDependencyGraph alloc] init];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _dirtyHierarchy = TRUE;
    }
    return self;
}

- (IDLLayoutParams *)generateDefaultLayoutParams {
    return [[[IDLRelativeLayoutLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeWrapContent height:IDLLayoutParamsSizeWrapContent] autorelease];
}

- (IDLLayoutParams *)generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[[IDLRelativeLayoutLayoutParams alloc] initWithAttributes:attrs] autorelease];
}

- (IDLLayoutParams *)generateLayoutParamsFromLayouParams:(IDLLayoutParams *)lp {
    return [[[IDLRelativeLayoutLayoutParams alloc] initWithLayoutParams:lp] autorelease];
}

- (void)sortChildren {
    int count = [self.subviews count];
    if ([_sortedVerticalChildren count] != count) {
        if (_sortedVerticalChildren == nil) _sortedVerticalChildren = [[NSMutableArray alloc] initWithCapacity:count];
        else [_sortedVerticalChildren removeAllObjects];
        for (NSInteger i=0;i<count;i++) {
            [_sortedVerticalChildren addObject:[NSNull null]];
        }
    }
    if ([_sortedHorizontalChildren count] != count) {
        if (_sortedHorizontalChildren == nil) _sortedHorizontalChildren = [[NSMutableArray alloc] initWithCapacity:count];
        else [_sortedHorizontalChildren removeAllObjects];
        for (NSInteger i=0;i<count;i++) {
            [_sortedHorizontalChildren addObject:[NSNull null]];
        }
    }
    
    IDLDependencyGraph *graph = _graph;
    [graph clear];
    
    for (int i = 0; i < count; i++) {
        UIView *child = [self.subviews objectAtIndex:i];
        [graph addView:child];
    }
    
    [graph getSortedViews:_sortedVerticalChildren forRules:@[@(IDLRelativeLayoutRuleAbove), @(IDLRelativeLayoutRuleBelow), @(IDLRelativeLayoutRuleAlignBaseline), @(IDLRelativeLayoutRuleAlignTop), @(IDLRelativeLayoutRuleAlignBottom)]];
    [graph getSortedViews:_sortedHorizontalChildren forRules:@[@(IDLRelativeLayoutRuleLeftOf), @(IDLRelativeLayoutRuleRightOf), @(IDLRelativeLayoutRuleAlignLeft), @(IDLRelativeLayoutRuleAlignRight)]];
    
}

- (UIView *)relatedViewForRules:(NSArray *)rules relation:(IDLRelativeLayoutRule)relation {
    NSString *identifier = rules[relation];
    if (identifier != nil && ![identifier isKindOfClass:[NSNull class]]) {
        IDLDependencyGraphNode *node = _graph.keyNodes[identifier];
        if (node == nil) return nil;
        UIView *v = node.view;
        
        // Find the first non-GONE view up the chain
        while (v.visibility == IDLViewVisibilityGone) {
            rules = ((IDLRelativeLayoutLayoutParams *) v.layoutParams).rules;
            node = _graph.keyNodes[rules[relation]];
            if (node == nil) return nil;
            v = node.view;
        }
        
        return v;
    }
    
    return nil;
}

- (IDLRelativeLayoutLayoutParams *)relatedViewParamsWithRules:(NSArray *)rules relation:(IDLRelativeLayoutRule)relation {
    UIView *v = [self relatedViewForRules:rules relation:relation];
    if (v != nil) {
        IDLLayoutParams *params = v.layoutParams;
        if ([params isKindOfClass:[IDLRelativeLayoutLayoutParams class]]) {
            return (IDLRelativeLayoutLayoutParams *)v.layoutParams;
        }
    }
    return nil;
}

- (void)applyHorizontalSizeRulesWithChildLayoutParams:(IDLRelativeLayoutLayoutParams *)childParams myWidth:(CGFloat)myWidth {
    UIEdgeInsets childParamsMargin = childParams.margin;
    
    NSArray *rules = childParams.rules;
    IDLRelativeLayoutLayoutParams *anchorParams;
    
    // -1 indicated a "soft requirement" in that direction. For example:
    // left=10, right=-1 means the view must start at 10, but can go as far as it wants to the right
    // left =-1, right=10 means the view must end at 10, but can go as far as it wants to the left
    // left=10, right=20 means the left and right ends are both fixed
    childParams.left = -1;
    childParams.right = -1;
    UIEdgeInsets padding = self.padding;
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleLeftOf];
    if (anchorParams != nil) {
        childParams.right = anchorParams.left - (anchorParams.margin.left +
                                                 childParamsMargin.right);
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleLeftOf] != [NSNull null]) {
        if (myWidth >= 0) {
            childParams.right = myWidth - padding.right - childParamsMargin.right;
        } else {
            // FIXME uh oh...
        }
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleRightOf];
    if (anchorParams != nil) {
        childParams.left = anchorParams.right + (anchorParams.margin.right +
                                                 childParamsMargin.left);
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleRightOf] != [NSNull null]) {
        childParams.left = padding.left + childParamsMargin.left;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleAlignLeft];
    if (anchorParams != nil) {
        childParams.left = anchorParams.left + childParamsMargin.left;
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleAlignLeft] != [NSNull null]) {
        childParams.left = padding.left + childParamsMargin.left;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleAlignRight];
    if (anchorParams != nil) {
        childParams.right = anchorParams.right - childParamsMargin.right;
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleAlignRight] != [NSNull null]) {
        if (myWidth >= 0) {
            childParams.right = myWidth - padding.right - childParamsMargin.right;
        } else {
            // FIXME uh oh...
        }
    }
    
    id alignParentLeft = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentLeft];
    if ([NSNull null] != alignParentLeft && [alignParentLeft boolValue]) {
        childParams.left = padding.left + childParamsMargin.left;
    }
    
    id alignParentRight = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentRight];
    if ([NSNull null] != alignParentRight && [alignParentRight boolValue]) {
        if (myWidth >= 0) {
            childParams.right = myWidth - padding.right - childParamsMargin.right;
        } else {
            // FIXME uh oh...
        }
    }
}

/**
 * Get a measure spec that accounts for all of the constraints on this view.
 * This includes size contstraints imposed by the RelativeLayout as well as
 * the View's desired dimension.
 *
 * @param childStart The left or top field of the child's layout params
 * @param childEnd The right or bottom field of the child's layout params
 * @param childSize The child's desired size (the width or height field of
 *        the child's layout params)
 * @param startMargin The left or top margin
 * @param endMargin The right or bottom margin
 * @param startPadding mPaddingLeft or mPaddingTop
 * @param endPadding mPaddingRight or mPaddingBottom
 * @param mySize The width or height of this view (the RelativeLayout)
 * @return MeasureSpec for the child
 */
- (IDLLayoutMeasureSpec)childMeasureSpecForChildStart:(CGFloat)childStart childEnd:(CGFloat)childEnd childSize:(CGFloat)childSize startMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin startPadding:(CGFloat)startPadding endPadding:(CGFloat)endPadding mySize:(CGFloat)mySize {
    IDLLayoutMeasureSpecMode childSpecMode = IDLLayoutMeasureSpecModeUnspecified;
    CGFloat childSpecSize = 0.f;
    
    // Figure out start and end bounds.
    CGFloat tempStart = childStart;
    CGFloat tempEnd = childEnd;
    
    // If the view did not express a layout constraint for an edge, use
    // view's margins and our padding
    if (tempStart < 0) {
        tempStart = startPadding + startMargin;
    }
    if (tempEnd < 0) {
        tempEnd = mySize - endPadding - endMargin;
    }
    
    // Figure out maximum size available to this view
    CGFloat maxAvailable = tempEnd - tempStart;
    
    if (childStart >= 0 && childEnd >= 0) {
        // Constraints fixed both edges, so child must be an exact size
        childSpecMode = IDLLayoutMeasureSpecModeExactly;
        childSpecSize = maxAvailable;
    } else {
        if (childSize >= 0) {
            // Child wanted an exact size. Give as much as possible
            childSpecMode = IDLLayoutMeasureSpecModeExactly;
            
            if (maxAvailable >= 0) {
                // We have a maxmum size in this dimension.
                childSpecSize = MIN(maxAvailable, childSize);
            } else {
                // We can grow in this dimension.
                childSpecSize = childSize;
            }
        } else if (childSize == IDLLayoutParamsSizeMatchParent) {
            // Child wanted to be as big as possible. Give all availble
            // space
            childSpecMode = IDLLayoutMeasureSpecModeExactly;
            childSpecSize = maxAvailable;
        } else if (childSize == IDLLayoutParamsSizeWrapContent) {
            // Child wants to wrap content. Use AT_MOST
            // to communicate available space if we know
            // our max size
            if (maxAvailable >= 0) {
                // We have a maxmum size in this dimension.
                childSpecMode = IDLLayoutMeasureSpecModeAtMost;
                childSpecSize = maxAvailable;
            } else {
                // We can grow in this dimension. Child can be as big as it
                // wants
                childSpecMode = IDLLayoutMeasureSpecModeUnspecified;
                childSpecSize = 0;
            }
        }
    }
    
    return IDLLayoutMeasureSpecMake(childSpecSize, childSpecMode);
}

- (void)measureChild:(UIView *)child horizontalWithLayoutParams:(IDLRelativeLayoutLayoutParams *)params myWidth:(CGFloat)myWidth myHeight:(CGFloat)myHeight {
    UIEdgeInsets paramsMargin = params.margin;
    UIEdgeInsets padding = self.padding;
    IDLLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecForChildStart:params.left childEnd:params.right childSize:params.width startMargin:paramsMargin.left endMargin:paramsMargin.right startPadding:padding.left endPadding:padding.right mySize:myWidth];
    IDLLayoutMeasureSpec childHeightMeasureSpec;
    if (params.width == IDLLayoutParamsSizeMatchParent) {
        childHeightMeasureSpec = IDLLayoutMeasureSpecMake(myHeight - padding.top - padding.bottom, IDLLayoutMeasureSpecModeExactly);
    } else {
        childHeightMeasureSpec = IDLLayoutMeasureSpecMake(myHeight - padding.top - padding.bottom, IDLLayoutMeasureSpecModeAtMost);
    }
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

/**
 * Measure a child. The child should have left, top, right and bottom information
 * stored in its LayoutParams. If any of these values is -1 it means that the view
 * can extend up to the corresponding edge.
 *
 * @param child Child to measure
 * @param params LayoutParams associated with child
 * @param myWidth Width of the the RelativeLayout
 * @param myHeight Height of the RelativeLayout
 */
- (void)measureChild:(UIView *)child withLayoutParams:(IDLRelativeLayoutLayoutParams *)params myWidth:(CGFloat)myWidth myHeight:(CGFloat)myHeight {
    UIEdgeInsets paramsMargin = params.margin;
    UIEdgeInsets padding = self.padding;
    IDLLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecForChildStart:params.left childEnd:params.right childSize:params.width startMargin:paramsMargin.left endMargin:paramsMargin.right startPadding:padding.left endPadding:padding.right mySize:myWidth];
    IDLLayoutMeasureSpec childHeightMeasureSpec = [self childMeasureSpecForChildStart:params.top childEnd:params.bottom childSize:params.height startMargin:paramsMargin.top endMargin:paramsMargin.bottom startPadding:padding.top endPadding:padding.bottom mySize:myHeight];
    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (void)centerChild:(UIView *)child horizontalWithLayoutParams:(IDLRelativeLayoutLayoutParams *)params myWidth:(CGFloat)myWidth {
    CGFloat childWidth = child.measuredSize.width;
    CGFloat left = (myWidth - childWidth) / 2.f;
    
    params.left = left;
    params.right = left + childWidth;
}

- (void)centerChild:(UIView *)child verticalWithLayoutParams:(IDLRelativeLayoutLayoutParams *)params myHeight:(CGFloat)myHeight {
    CGFloat childHeight = child.measuredSize.height;
    CGFloat top = (myHeight - childHeight) / 2.f;
    
    params.top = top;
    params.bottom = top + childHeight;
}


- (BOOL)positionChild:(UIView *)child horizontalWithLayoutParams:(IDLRelativeLayoutLayoutParams *)params myWidth:(CGFloat)myWidth wrapContent:(BOOL)wrapContent {
    
    NSArray *rules = params.rules;
    UIEdgeInsets padding = self.padding;
    
    if (params.left < 0 && params.right >= 0) {
        // Right is fixed, but left varies
        params.left = params.right - child.measuredSize.width;
    } else if (params.left >= 0 && params.right < 0) {
        // Left is fixed, but right varies
        params.right = params.left + child.measuredSize.width;
    } else if (params.left < 0 && params.right < 0) {
        // Both left and right vary
        id centerInParent = [rules objectAtIndex:IDLRelativeLayoutRuleCenterInParent];
        id centerHorizontal = [rules objectAtIndex:IDLRelativeLayoutRuleCenterHorizontal];
        if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerHorizontal != [NSNull null] && [centerHorizontal boolValue])) {
            if (!wrapContent) {
                [self centerChild:child horizontalWithLayoutParams:params myWidth:myWidth];
            } else {
                params.left = padding.left + params.margin.left;
                params.right = params.left + child.measuredSize.width;
            }
            return TRUE;
        } else {
            params.left = padding.left + params.margin.left;
            params.right = params.left + child.measuredSize.width;
        }
    }
    id alignParentRight = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentRight];
    return  (alignParentRight != [NSNull null] && [alignParentRight boolValue]);
}

- (BOOL)positionChild:(UIView *)child verticalWithLayoutParams:(IDLRelativeLayoutLayoutParams *)params myHeight:(CGFloat)myHeight wrapContent:(BOOL)wrapContent {
    
    NSArray *rules = params.rules;
    UIEdgeInsets padding = self.padding;
    
    if (params.top < 0 && params.bottom >= 0) {
        // Bottom is fixed, but top varies
        params.top = params.bottom - child.measuredSize.height;
    } else if (params.top >= 0 && params.bottom < 0) {
        // Top is fixed, but bottom varies
        params.bottom = params.top + child.measuredSize.height;
    } else if (params.top < 0 && params.bottom < 0) {
        // Both top and bottom vary
        id centerInParent = [rules objectAtIndex:IDLRelativeLayoutRuleCenterInParent];
        id centerVertical = [rules objectAtIndex:IDLRelativeLayoutRuleCenterVertical];
        if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerVertical != [NSNull null] && [centerVertical boolValue])) {
            if (!wrapContent) {
                [self centerChild:child verticalWithLayoutParams:params myHeight:myHeight];
            } else {
                params.top = padding.top + params.margin.top;
                params.bottom = params.top + child.measuredSize.height;
            }
            return true;
        } else {
            params.top = padding.top + params.margin.top;
            params.bottom = params.top + child.measuredSize.height;
        }
    }
    id alignParentBottom = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentBottom];
    return  (alignParentBottom != [NSNull null] && [alignParentBottom boolValue]);
}

- (void)applyVerticalSizeRulesWithChildLayoutParams:(IDLRelativeLayoutLayoutParams *)childParams myHeight:(CGFloat)myHeight {
    NSArray *rules = childParams.rules;
    IDLRelativeLayoutLayoutParams *anchorParams;
    UIEdgeInsets childParamsMargin = childParams.margin;
    UIEdgeInsets padding = self.padding;
    
    childParams.top = -1;
    childParams.bottom = -1;
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleAbove];
    if (anchorParams != nil) {
        childParams.bottom = anchorParams.top - (anchorParams.margin.top +
                                                 childParamsMargin.bottom);
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleAbove] != [NSNull null]) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - padding.bottom - childParamsMargin.bottom;
        } else {
            // FIXME uh oh...
        }
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleBelow];
    if (anchorParams != nil) {
        childParams.top = anchorParams.bottom + (anchorParams.margin.bottom +
                                                 childParamsMargin.top);
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleBelow] != [NSNull null]) {
        childParams.top = padding.top + childParamsMargin.top;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleAlignTop];
    if (anchorParams != nil) {
        childParams.top = anchorParams.top + childParamsMargin.top;
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleAlignTop] != [NSNull null]) {
        childParams.top = padding.top + childParamsMargin.top;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleAlignBottom];
    if (anchorParams != nil) {
        childParams.bottom = anchorParams.bottom - childParamsMargin.bottom;
    } else if (childParams.alignWithParent && [rules objectAtIndex:IDLRelativeLayoutRuleAlignBottom] != [NSNull null]) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - padding.bottom - childParamsMargin.bottom;
        } else {
            // FIXME uh oh...
        }
    }
    
    id alignParentTop = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentTop];
    if ([NSNull null] != alignParentTop && [alignParentTop boolValue]) {
        childParams.top = padding.top + childParamsMargin.top;
    }
    
    id alignParentBottom = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentBottom];
    if ([NSNull null] != alignParentBottom && [alignParentBottom boolValue]) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - padding.bottom - childParamsMargin.bottom;
        } else {
            // FIXME uh oh...
        }
    }
    
    id alignBaseline = [rules objectAtIndex:IDLRelativeLayoutRuleAlignBaseline];
    if (alignBaseline != [NSNull null] && [alignBaseline boolValue]) {
        _hasBaselineAlignedChild = true;
    }
}

- (CGFloat)relatedViewBaselineForRules:(NSArray *)rules relation:(IDLRelativeLayoutRule)relation {
    UIView *v = [self relatedViewForRules:rules relation:relation];
    if (v != nil) {
        return v.baseline;
    }
    return -1;
}

- (void)alignChild:(UIView *)child baselineWithLayoutParams:(IDLRelativeLayoutLayoutParams *)params {
    NSArray *rules = params.rules;
    CGFloat anchorBaseline = [self relatedViewBaselineForRules:rules relation:IDLRelativeLayoutRuleAlignBaseline];
    
    if (anchorBaseline != -1) {
        IDLRelativeLayoutLayoutParams *anchorParams = [self relatedViewParamsWithRules:rules relation:IDLRelativeLayoutRuleAlignBaseline];
        if (anchorParams != nil) {
            CGFloat offset = anchorParams.top + anchorBaseline;
            CGFloat baseline = child.baseline;
            if (baseline != -1) {
                offset -= baseline;
            }
            CGFloat height = params.bottom - params.top;
            params.top = offset;
            params.bottom = params.top + height;
        }
    }
    
    if (_baselineView == nil) {
        _baselineView = [child retain];
    } else {
        IDLRelativeLayoutLayoutParams *lp = (IDLRelativeLayoutLayoutParams *)_baselineView.layoutParams;
        if (params.top < lp.top || (params.top == lp.top && params.left < lp.left)) {
            [_baselineView release];
            _baselineView = [child retain];
        }
    }
}


- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    if (_dirtyHierarchy) {
        _dirtyHierarchy = false;
        [self sortChildren];
    }
    
    CGFloat myWidth = -1;
    CGFloat myHeight = -1;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    // Record our dimensions if they are known;
    if (widthMode != IDLLayoutMeasureSpecModeUnspecified) {
        myWidth = widthSize;
    }
    
    if (heightMode != IDLLayoutMeasureSpecModeUnspecified) {
        myHeight = heightSize;
    }
    
    if (widthMode == IDLLayoutMeasureSpecModeExactly) {
        width = myWidth;
    }
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        height = myHeight;
    }
    
    _hasBaselineAlignedChild = FALSE;
    
    UIView *ignore = nil;
    IDLViewContentGravity gravity = _gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    BOOL horizontalGravity = gravity != IDLViewContentGravityLeft && gravity != 0;
    gravity = _gravity & VERTICAL_GRAVITY_MASK;
    BOOL verticalGravity = gravity != IDLViewContentGravityTop && gravity != 0;
    
    CGFloat left = CGFLOAT_MAX;
    CGFloat top = CGFLOAT_MAX;
    CGFloat right = CGFLOAT_MIN;
    CGFloat bottom = CGFLOAT_MIN;
    
    BOOL offsetHorizontalAxis = FALSE;
    BOOL offsetVerticalAxis = FALSE;
    
    if ((horizontalGravity || verticalGravity) && _ignoreGravity != nil) {
        ignore = [self findViewById:_ignoreGravity];
    }
    
    BOOL isWrapContentWidth = widthMode != IDLLayoutMeasureSpecModeExactly;
    BOOL isWrapContentHeight = heightMode != IDLLayoutMeasureSpecModeExactly;
    
    NSArray *views = _sortedHorizontalChildren;
    NSInteger count = [views count];
    for (int i = 0; i < count; i++) {
        UIView *child = [views objectAtIndex:i];
        if (child.visibility != IDLViewVisibilityGone) {
            IDLRelativeLayoutLayoutParams *params = (IDLRelativeLayoutLayoutParams *)child.layoutParams;
            
            [self applyHorizontalSizeRulesWithChildLayoutParams:params myWidth:myWidth];
            [self measureChild:child horizontalWithLayoutParams:params myWidth:myWidth myHeight:myHeight];
            if ([self positionChild:child horizontalWithLayoutParams:params myWidth:myWidth wrapContent:isWrapContentWidth]) {
                offsetHorizontalAxis = TRUE;
            }
        }
    }
    
    views = _sortedVerticalChildren;
    count = [views count];
    
    for (int i = 0; i < count; i++) {
        UIView *child = [views objectAtIndex:i];
        
        if (child.visibility != IDLViewVisibilityGone) {
            IDLRelativeLayoutLayoutParams *params = (IDLRelativeLayoutLayoutParams *)child.layoutParams;
            UIEdgeInsets paramsMargin = params.margin;
            
            [self applyVerticalSizeRulesWithChildLayoutParams:params myHeight:myHeight];
            [self measureChild:child withLayoutParams:params myWidth:myWidth myHeight:myHeight];
            if ([self positionChild:child verticalWithLayoutParams:params myHeight:myHeight wrapContent:isWrapContentHeight]) {
                offsetVerticalAxis = TRUE;
            }
            
            if (isWrapContentWidth) {
                width = MAX(width, params.right);
            }
            
            if (isWrapContentHeight) {
                height = MAX(height, params.bottom);
            }
            
            if (child != ignore || verticalGravity) {
                left = MIN(left, params.left - paramsMargin.left);
                top = MIN(top, params.top - paramsMargin.top);
            }
            
            if (child != ignore || horizontalGravity) {
                right = MAX(right, params.right + paramsMargin.right);
                bottom = MAX(bottom, params.bottom + paramsMargin.bottom);
            }
        }
    }
    
    if (_hasBaselineAlignedChild) {
        for (int i = 0; i < count; i++) {
            UIView *child = [self.subviews objectAtIndex:i];
            
            if (child.visibility != IDLViewVisibilityGone) {
                IDLRelativeLayoutLayoutParams *params = (IDLRelativeLayoutLayoutParams *)child.layoutParams;
                [self alignChild:child baselineWithLayoutParams:params];
                
                UIEdgeInsets paramsMargin = params.margin;
                if (child != ignore || verticalGravity) {
                    left = MIN(left, params.left - paramsMargin.left);
                    top = MIN(top, params.top - paramsMargin.top);
                }
                
                if (child != ignore || horizontalGravity) {
                    right = MAX(right, params.right + paramsMargin.right);
                    bottom = MAX(bottom, params.bottom + paramsMargin.bottom);
                }
            }
        }
    }
    
    UIEdgeInsets padding = self.padding;
    CGSize minSize = self.minSize;
    if (isWrapContentWidth) {
        // Width already has left padding in it since it was calculated by looking at
        // the right of each child view
        width += padding.right;
        
        if (self.layoutParams.width >= 0) {
            width = MAX(width, self.layoutParams.width);
        }
        
        width = MAX(width, minSize.width);
        width = [UIView resolveSizeForSize:width measureSpec:widthMeasureSpec];
        
        if (offsetHorizontalAxis) {
            for (int i = 0; i < count; i++) {
                UIView *child = [self.subviews objectAtIndex:i];
                
                if (child.visibility != IDLViewVisibilityGone) {
                    IDLRelativeLayoutLayoutParams *params = (IDLRelativeLayoutLayoutParams *)child.layoutParams;
                    NSArray *rules = params.rules;
                    id centerInParent = [rules objectAtIndex:IDLRelativeLayoutRuleCenterInParent];
                    id centerHorizontal = [rules objectAtIndex:IDLRelativeLayoutRuleCenterHorizontal];
                    id alignParentRight = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentRight];
                    if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerHorizontal != [NSNull null] && [centerHorizontal boolValue])) {
                        [self centerChild:child horizontalWithLayoutParams:params myWidth:width];
                    } else if (alignParentRight != [NSNull null] && [alignParentRight boolValue]) {
                        CGFloat childWidth = child.measuredSize.width;
                        params.left = width - padding.right - childWidth;
                        params.right = params.left + childWidth;
                    }
                }
            }
        }
    }
    
    if (isWrapContentHeight) {
        // Height already has top padding in it since it was calculated by looking at
        // the bottom of each child view
        height += padding.bottom;
        
        if (self.layoutParams.height >= 0) {
            height = MAX(height, self.layoutParams.height);
        }
        
        height = MAX(height, minSize.height);
        height = [UIView resolveSizeForSize:height measureSpec:heightMeasureSpec];
        
        if (offsetVerticalAxis) {
            for (int i = 0; i < count; i++) {
                UIView *child = [self.subviews objectAtIndex:i];
                
                if (child.visibility != IDLViewVisibilityGone) {
                    IDLRelativeLayoutLayoutParams *params = (IDLRelativeLayoutLayoutParams *)child.layoutParams;
                    NSArray *rules = params.rules;
                    id centerInParent = [rules objectAtIndex:IDLRelativeLayoutRuleCenterInParent];
                    id centerVertical = [rules objectAtIndex:IDLRelativeLayoutRuleCenterVertical];
                    id alignParentBottom = [rules objectAtIndex:IDLRelativeLayoutRuleAlignParentBottom];
                    if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerVertical != [NSNull null] && [centerVertical boolValue])) {
                        [self centerChild:child verticalWithLayoutParams:params myHeight:height];
                    } else if (alignParentBottom != [NSNull null] && [alignParentBottom boolValue]) {
                        CGFloat childHeight = child.measuredSize.height;
                        params.top = height - padding.bottom - childHeight;
                        params.bottom = params.top + childHeight;
                    }
                }
            }
        }
    }
    
    if (horizontalGravity || verticalGravity) {
        _selfBounds = CGRectMake(padding.left, padding.top, width, height);
        
        [IDLGravity applyGravity:_gravity width:right-left height:bottom-top containerRect:&_selfBounds outRect:&_contentBounds];
        
        CGFloat horizontalOffset = _contentBounds.origin.x - left;
        CGFloat verticalOffset = _contentBounds.origin.y - top;
        if (horizontalOffset != 0 || verticalOffset != 0) {
            for (int i = 0; i < count; i++) {
                UIView *child = [self.subviews objectAtIndex:i];
                
                if (child.visibility != IDLViewVisibilityGone && child != ignore) {
                    IDLRelativeLayoutLayoutParams *params = (IDLRelativeLayoutLayoutParams *)child.layoutParams;
                    if (horizontalGravity) {
                        params.left += horizontalOffset;
                        params.right += horizontalOffset;
                    }
                    if (verticalGravity) {
                        params.top += verticalOffset;
                        params.bottom += verticalOffset;
                    }
                }
            }
        }
    }
    IDLLayoutMeasuredSize measuredSize;
    measuredSize.width.state = IDLLayoutMeasuredStateNone;
    measuredSize.width.size = width;
    measuredSize.height.state = IDLLayoutMeasuredStateNone;
    measuredSize.height.size = height;
    [self setMeasuredDimensionSize:measuredSize];
    
}

- (void)onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    //  The layout has actually already been performed and the positions
    //  cached.  Apply the cached values to the children.
    int count = [self.subviews count];
    
    for (int i = 0; i < count; i++) {
        UIView *child = [self.subviews objectAtIndex:i];
        
        if (child.visibility != IDLViewVisibilityGone) {
            IDLRelativeLayoutLayoutParams *st = (IDLRelativeLayoutLayoutParams *)child.layoutParams;
            [child layoutWithFrame:CGRectMake(st.left, st.top, st.right-st.left, st.bottom - st.top)];
        }
    }
}


@end
