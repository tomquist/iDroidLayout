//
//  LinearLayout.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLinearLayout.h"
#import "UIView+IDL_Layout.h"

@implementation IDLLinearLayout

@synthesize orientation = _orientation;
@synthesize gravity = _gravity;
@synthesize weightSum = _weightSum;

- (void) dealloc {
	
	[super dealloc];
}


- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    _gravity = [IDLGravity gravityFromAttribute:[attrs objectForKey:@"gravity"]];
    NSString *orientationString = [attrs objectForKey:@"orientation"];
    if ([orientationString isEqualToString:@"horizontal"]) {
        _orientation = LinearLayoutOrientationHorizontal;
    } else {
        _orientation = LinearLayoutOrientationVertical;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gravity = IDLViewContentGravityLeft | IDLViewContentGravityTop;
        _orientation = LinearLayoutOrientationVertical;
        _baselineAligned = TRUE;
        _baselineAlignedChildIndex = -1;
        _baselineChildTop = 0;
    }
    return self;
}

- (id)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        _baselineAligned = TRUE;
        _baselineAlignedChildIndex = -1;
        _baselineChildTop = 0;
    }
    return self;
}

- (void)setGravity:(IDLViewContentGravity)gravity {
    if (_gravity != gravity) {
        if ((gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK) == 0) {
            gravity |= IDLViewContentGravityLeft;
        }
        
        if ((gravity & VERTICAL_GRAVITY_MASK) == 0) {
            gravity |= IDLViewContentGravityTop;
        }
        
        _gravity = gravity;
        [self requestLayout];
    }
}

- (void)setOrientation:(LinearLayoutOrientation)orientation {
    if (_orientation != orientation) {
        _orientation = orientation;
        [self requestLayout];
    }
}

- (void)setWeightSum:(float)weightSum {
    _weightSum = MAX(0.0f, weightSum);
}

- (CGFloat)baseline {
    if (_baselineAlignedChildIndex < 0) {
        return [super baseline];
    }
    
    if ([[self subviews] count] <= _baselineAlignedChildIndex) {
        @throw [NSException exceptionWithName:@"RuntimeException" reason:@"mBaselineAlignedChildIndex of LinearLayout set to an index that is out of bounds." userInfo:nil];
    }
    
    UIView *child = [[self subviews] objectAtIndex:_baselineAlignedChildIndex];
    CGFloat childBaseline = child.baseline;
    
    if (childBaseline == -1) {
        if (_baselineAlignedChildIndex == 0) {
            // this is just the default case, safe to return -1
            return -1;
        }
        // the user picked an index that points to something that doesn't
        // know how to calculate its baseline.
        @throw [NSException exceptionWithName:@"RuntimeException" reason:@"mBaselineAlignedChildIndex of LinearLayout points to a View that doesn't know how to get its baseline." userInfo:nil];
    }
    
    // TODO: This should try to take into account the virtual offsets
    // (See getNextLocationOffset and getLocationOffset)
    // We should add to childTop:
    // sum([getNextLocationOffset(getChildAt(i)) / i < mBaselineAlignedChildIndex])
    // and also add:
    // getLocationOffset(child)
    CGFloat childTop = _baselineChildTop;
    
    if (_orientation == LinearLayoutOrientationVertical) {
        IDLViewContentGravity majorGravity = _gravity & VERTICAL_GRAVITY_MASK;
        if (majorGravity != IDLViewContentGravityTop) {
            UIEdgeInsets padding = self.padding;
            switch (majorGravity) {
                case IDLViewContentGravityBottom:
                    childTop = self.frame.size.height - padding.bottom - _totalLength;
                    break;
                    
                case IDLViewContentGravityCenterVertical:
                    childTop += ((self.frame.size.height - padding.top - padding.bottom) - _totalLength) / 2;
                    break;
                default:
                    break;
            }
        }
    }
    
    IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
    return childTop + lp.margin.top + childBaseline;
}

/**
 * <p>Return the size offset of the next sibling of the specified child.
 * This can be used by subclasses to change the location of the widget
 * following <code>child</code>.</p>
 *
 * @param child the child whose next sibling will be moved
 * @return the location offset of the next child in pixels
 */
- (CGFloat)nextLocationOffsetOfChild:(UIView *)child {
    return 0;
}

/**
 * <p>Returns the number of children to skip after measuring/laying out
 * the specified child.</p>
 *
 * @param child the child after which we want to skip children
 * @param index the index of the child after which we want to skip children
 * @return the number of children to skip, 0 by default
 */
- (NSInteger)childrenSkipCountAfterChild:(UIView *)child atIndex:(NSInteger)index {
    return 0;
}


- (void)forceUniformWidthWithCount:(NSInteger)count heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    // Pretend that the linear layout has an exact size.
    IDLLayoutMeasureSpec uniformMeasureSpec;
    uniformMeasureSpec.size = self.measuredSize.width;
    uniformMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
    for (int i = 0; i< count; ++i) {
        UIView *child = [[self subviews] objectAtIndex:i];
        if (child.visibility == IDLViewVisibilityGone) {
            continue;
        }
        
        IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *)child.layoutParams;
        
        if (lp.width == IDLLayoutParamsSizeMatchParent) {
            // Temporarily force children to reuse their old measured height
            // FIXME: this may not be right for something like wrapping text?
            CGFloat oldHeight = lp.height;
            lp.height = child.measuredSize.height;
            
            // Remeasue with new dimensions
            [self measureChildWithMargins:child parentWidthMeasureSpec:uniformMeasureSpec widthUsed:0.f parentHeightMeasureSpec:heightMeasureSpec heightUsed:0.f];
            lp.height = oldHeight;
        }
    }
}

- (void)measureChild:(UIView *)child atIndex:(NSInteger)index beforeLayoutWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec totalWidth:(CGFloat)totalWidth heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec totalHeight:(CGFloat)totalHeight {
    [self measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:totalWidth parentHeightMeasureSpec:heightMeasureSpec heightUsed:totalHeight];
}

/**
 * Measures the children when the orientation of this LinearLayout is set
 * to {@link #VERTICAL}.
 *
 * @param widthMeasureSpec Horizontal space requirements as imposed by the parent.
 * @param heightMeasureSpec Vertical space requirements as imposed by the parent.
 *
 * @see #getOrientation()
 * @see #setOrientation(int)
 * @see #onMeasure(int, int)
 */
- (void)measureVerticalWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    _totalLength = 0;
    CGFloat maxWidth = 0;
    IDLLayoutMeasuredWidthHeightState childState = {IDLLayoutMeasuredStateNone, IDLLayoutMeasuredStateNone};
    CGFloat alternativeMaxWidth = 0;
    CGFloat weightedMaxWidth = 0;
    BOOL allFillParent = TRUE;
    float totalWeight = 0;
    
    NSInteger count = [self.subviews count];
    
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    
    BOOL matchWidth = FALSE;
    
    NSInteger baselineChildIndex = _baselineAlignedChildIndex;        
    BOOL useLargestChild = _useLargestChild;
    
    CGFloat largestChildHeight = CGFLOAT_MIN;
    
    // See how tall everyone is. Also remember max width.
    for (int i = 0; i < count; ++i) {
        UIView *child = [self.subviews objectAtIndex:i];
        
        if (child.visibility == IDLViewVisibilityGone) {
            i += [self childrenSkipCountAfterChild:child atIndex:i];
            continue;
        }
        
        IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
        UIEdgeInsets lpMargin = lp.margin;
        totalWeight += lp.weight;
        
        if (heightMode == IDLLayoutMeasureSpecModeExactly && lp.height == 0 && lp.weight > 0) {
            // Optimization: don't bother measuring children who are going to use
            // leftover space. These views will get measured again down below if
            // there is any leftover space.
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + lpMargin.top + lpMargin.bottom);
        } else {
            CGFloat oldHeight = CGFLOAT_MIN;
            
            if (lp.height == 0 && lp.weight > 0) {
                // heightMode is either UNSPECIFIED or AT_MOST, and this
                // child wanted to stretch to fill available space.
                // Translate that to WRAP_CONTENT so that it does not end up
                // with a height of 0
                oldHeight = 0;
                lp.height = IDLLayoutParamsSizeWrapContent;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self measureChild:child atIndex:i beforeLayoutWithWidthMeasureSpec:widthMeasureSpec totalWidth:0 heightMeasureSpec:heightMeasureSpec totalHeight:(totalWeight == 0 ? _totalLength : 0)];
            
            if (oldHeight != CGFLOAT_MIN) {
                lp.height = oldHeight;
            }
            
            CGFloat childHeight = child.measuredSize.height;
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + childHeight + lpMargin.top + lpMargin.bottom + [self nextLocationOffsetOfChild:child]);
            
            if (useLargestChild) {
                largestChildHeight = MAX(childHeight, largestChildHeight);
            }
        }
        
        /**
         * If applicable, compute the additional offset to the child's baseline
         * we'll need later when asked {@link #getBaseline}.
         */
        if ((baselineChildIndex >= 0) && (baselineChildIndex == i + 1)) {
            _baselineChildTop = _totalLength;
        }
        
        // if we are trying to use a child index for our baseline, the above
        // book keeping only works if there are no children above it with
        // weight.  fail fast to aid the developer.
        if (i < baselineChildIndex && lp.weight > 0) {
            @throw [NSException exceptionWithName:@"LayoutError" reason:@"A child of LinearLayout with index less than mBaselineAlignedChildIndex has weight > 0, which won't work.  Either remove the weight, or don't set mBaselineAlignedChildIndex." userInfo:nil];
        }
        
        BOOL matchWidthLocally = FALSE;
        if (widthMode != IDLLayoutMeasureSpecModeExactly && lp.width == IDLLayoutParamsSizeMatchParent) {
            // The width of the linear layout will scale, and at least one
            // child said it wanted to match our width. Set a flag
            // indicating that we need to remeasure at least that view when
            // we know our width.
            matchWidth = TRUE;
            matchWidthLocally = TRUE;
        }
        
        CGFloat margin = lpMargin.left + lpMargin.right;
        CGFloat measuredWidth = child.measuredSize.width + margin;
        maxWidth = MAX(maxWidth, measuredWidth);
        childState = [UIView combineMeasuredStatesCurrentState:childState newState:child.measuredState];
        
        allFillParent = allFillParent && lp.width == IDLLayoutParamsSizeMatchParent;
        if (lp.weight > 0) {
            /*
             * Widths of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxWidth = MAX(weightedMaxWidth,
                                   matchWidthLocally ? margin : measuredWidth);
        } else {
            alternativeMaxWidth = MAX(alternativeMaxWidth,
                                      matchWidthLocally ? margin : measuredWidth);
        }
        
        i += [self childrenSkipCountAfterChild:child atIndex:i];
    }
    
    if (useLargestChild &&
        (heightMode == IDLLayoutMeasureSpecModeAtMost || heightMode == IDLLayoutMeasureSpecModeUnspecified)) {
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [[self subviews] objectAtIndex:i];
            
            if (child.visibility == IDLViewVisibilityGone) {
                i += [self childrenSkipCountAfterChild:child atIndex:i];
            }
            
            IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
            // Account for negative margins
            CGFloat totalLength = _totalLength;
            UIEdgeInsets lpMargin = lp.margin;
            _totalLength = MAX(totalLength, totalLength + largestChildHeight +
                               lpMargin.top + lpMargin.bottom + [self nextLocationOffsetOfChild:child]);
        }
    }
    
    // Add in our padding
    UIEdgeInsets padding = self.padding;
    _totalLength += padding.top + padding.bottom;
    
    CGFloat heightSize = _totalLength;
    
    // Check against our minimum height
    CGSize minSize = self.minSize;
    heightSize = MAX(heightSize, minSize.height);
    
    // Reconcile our calculated size with the heightMeasureSpec
    IDLLayoutMeasuredDimension heightSizeAndState = [UIView resolveSizeAndStateForSize:heightSize measureSpec:heightMeasureSpec childMeasureState:IDLLayoutMeasuredStateNone];
    heightSize = heightSizeAndState.size;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds
    CGFloat delta = heightSize - _totalLength;
    if (delta != 0 && totalWeight > 0.0f) {
        float weightSum = _weightSum > 0.0f ? _weightSum : totalWeight;
        
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [[self subviews] objectAtIndex:i];
            
            if (child.visibility == IDLViewVisibilityGone) {
                continue;
            }
            
            IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            float childExtra = lp.weight;
            if (childExtra > 0) {
                // Child said it could absorb extra space -- give him his share
                float share = (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                IDLLayoutMeasureSpec childWidthMeasureSpec = [IDLViewGroup childMeasureSpecForMeasureSpec:widthMeasureSpec padding:(padding.left + padding.right + lpMargin.left + lpMargin.right) childDimension:lp.width];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if ((lp.height != 0) || (heightMode != IDLLayoutMeasureSpecModeExactly)) {
                    // child was measured once already above...
                    // base new measurement on stored values
                    CGFloat childHeight = child.measuredSize.height + share;
                    if (childHeight < 0) {
                        childHeight = 0;
                    }
                    IDLLayoutMeasureSpec childHeightMeasureSpec = IDLLayoutMeasureSpecMake(childHeight, IDLLayoutMeasureSpecModeExactly);
                    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                } else {
                    // child was skipped in the loop above.
                    // Measure for this first time here      
                    IDLLayoutMeasureSpec childHeightMeasureSpec = IDLLayoutMeasureSpecMake((share > 0 ? share : 0), IDLLayoutMeasureSpecModeExactly);
                    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
                
                // Child may now not fit in vertical dimension.
                IDLLayoutMeasuredWidthHeightState newState = child.measuredState;
                newState.widthState = IDLLayoutMeasuredStateNone;
                childState = [UIView combineMeasuredStatesCurrentState:childState newState:newState];
            }
            
            CGFloat margin =  lpMargin.left + lpMargin.right;
            CGFloat measuredWidth = child.measuredSize.width + margin;
            maxWidth = MAX(maxWidth, measuredWidth);
            
            BOOL matchWidthLocally = widthMode != IDLLayoutMeasureSpecModeExactly && lp.width == IDLLayoutParamsSizeMatchParent;
            
            alternativeMaxWidth = MAX(alternativeMaxWidth,
                                      matchWidthLocally ? margin : measuredWidth);
            
            allFillParent = allFillParent && lp.width == IDLLayoutParamsSizeMatchParent;
            
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + child.measuredSize.height + lpMargin.top + lpMargin.bottom + [self nextLocationOffsetOfChild:child]);
        }
        
        // Add in our padding
        _totalLength += padding.top + padding.bottom;
        // TODO: Should we recompute the heightSpec based on the new total length?
    } else {
        alternativeMaxWidth = MAX(alternativeMaxWidth, weightedMaxWidth);
        
        
        // We have no limit, so make all weighted views as tall as the largest child.
        // Children will have already been measured once.
        if (useLargestChild && widthMode == IDLLayoutMeasureSpecModeUnspecified) {
            for (int i = 0; i < count; i++) {
                UIView *child = [[self subviews] objectAtIndex:i];
                
                if (child.visibility == IDLViewVisibilityGone) {
                    continue;
                }
                
                IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
                
                float childExtra = lp.weight;
                if (childExtra > 0) {
                    IDLLayoutMeasureSpec childWidthMeasureSpec;
                    IDLLayoutMeasureSpec childHeightMeasureSpec;
                    childWidthMeasureSpec.size = child.measuredSize.width;
                    childWidthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
                    childHeightMeasureSpec.size = largestChildHeight;
                    childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
                    
                    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
            }
        }
    }
    
    if (!allFillParent && widthMode != IDLLayoutMeasureSpecModeExactly) {
        maxWidth = alternativeMaxWidth;
    }
    
    maxWidth += padding.left + padding.right;
    
    // Check against our minimum width
    maxWidth = MAX(maxWidth, minSize.width);
    
    IDLLayoutMeasuredSize measuredSize = IDLLayoutMeasuredSizeMake([UIView resolveSizeAndStateForSize:maxWidth measureSpec:widthMeasureSpec childMeasureState:childState.widthState] , heightSizeAndState);
    [self setMeasuredDimensionSize:measuredSize];
    
    if (matchWidth) {
        [self forceUniformWidthWithCount:count heightMeasureSpec:heightMeasureSpec];
    }
}

- (void)forceUniformHeightWithCount:(NSInteger)count widthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec {
    // Pretend that the linear layout has an exact size. This is the measured height of
    // ourselves. The measured height should be the max height of the children, changed
    // to accomodate the heightMesureSpec from the parent
    IDLLayoutMeasureSpec uniformMeasureSpec;
    uniformMeasureSpec.size = self.measuredSize.height;
    uniformMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
    for (int i = 0; i < count; ++i) {
        UIView *child = [[self subviews] objectAtIndex:i];
        
        if (child.visibility == IDLViewVisibilityGone) {
            continue;
        }
        
        IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
        
        if (lp.height == IDLLayoutParamsSizeMatchParent) {
            // Temporarily force children to reuse their old measured width
            // FIXME: this may not be right for something like wrapping text?
            int oldWidth = lp.width;
            lp.width = child.measuredSize.width;
            
            // Remeasure with new dimensions
            [self measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:uniformMeasureSpec heightUsed:0];
            lp.width = oldWidth;
        }
    }
}


/**
 * Measures the children when the orientation of this LinearLayout is set
 * to {@link #HORIZONTAL}.
 *
 * @param widthMeasureSpec Horizontal space requirements as imposed by the parent.
 * @param heightMeasureSpec Vertical space requirements as imposed by the parent.
 *
 * @see #getOrientation()
 * @see #setOrientation(int)
 * @see #onMeasure(int, int) 
 */
- (void)measureHorizontalWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    _totalLength = 0.f;
    CGFloat maxHeight = 0.f;
    IDLLayoutMeasuredWidthHeightState childState = {IDLLayoutMeasuredStateNone, IDLLayoutMeasuredStateNone};
    CGFloat alternativeMaxHeight = 0.f;
    CGFloat weightedMaxHeight = 0.f;
    BOOL allFillParent = TRUE;
    float totalWeight = 0.f;
    
    NSInteger count = [[self subviews] count];
    
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    
    BOOL matchHeight = FALSE;
    
    int maxAscent[VERTICAL_GRAVITY_COUNT];
    int maxDescent[VERTICAL_GRAVITY_COUNT];
    
    maxAscent[0] = maxAscent[1] = maxAscent[2] = maxAscent[3] = -1;
    maxDescent[0] = maxDescent[1] = maxDescent[2] = maxDescent[3] = -1;
    
    BOOL baselineAligned = _baselineAligned;
    BOOL useLargestChild = _useLargestChild;
    
    BOOL isExactly = widthMode == IDLLayoutMeasureSpecModeExactly;
    
    CGFloat largestChildWidth = CGFLOAT_MIN;
    
    // See how wide everyone is. Also remember max height.
    for (int i = 0; i < count; ++i) {
        UIView *child = [[self subviews] objectAtIndex:i];
        
        if (child.visibility == IDLViewVisibilityGone) {
            i += [self childrenSkipCountAfterChild:child atIndex:i];
            continue;
        }
        
        IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
        UIEdgeInsets lpMargin = lp.margin;
        
        totalWeight += lp.weight;
        
        if (widthMode == IDLLayoutMeasureSpecModeExactly && lp.width == 0 && lp.weight > 0) {
            // Optimization: don't bother measuring children who are going to use
            // leftover space. These views will get measured again down below if
            // there is any leftover space.
            if (isExactly) {
                _totalLength += lpMargin.left + lpMargin.right;
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + lpMargin.left + lpMargin.right);
            }
            
            // Baseline alignment requires to measure widgets to obtain the
            // baseline offset (in particular for TextViews). The following
            // defeats the optimization mentioned above. Allow the child to
            // use as much space as it wants because we can shrink things
            // later (and re-measure).
            if (baselineAligned) {
                IDLLayoutMeasureSpec freeSpec;
                freeSpec.size = 0;
                freeSpec.mode = IDLLayoutMeasureSpecModeUnspecified;
                [child measureWithWidthMeasureSpec:freeSpec heightMeasureSpec:freeSpec];
            }
        } else {
            CGFloat oldWidth = CGFLOAT_MIN;
            
            if (lp.width == 0 && lp.weight > 0) {
                // widthMode is either UNSPECIFIED or AT_MOST, and this
                // child
                // wanted to stretch to fill available space. Translate that to
                // WRAP_CONTENT so that it does not end up with a width of 0
                oldWidth = 0.f;
                lp.width = IDLLayoutParamsSizeWrapContent;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self measureChild:child atIndex:i beforeLayoutWithWidthMeasureSpec:widthMeasureSpec totalWidth:(totalWeight == 0 ? _totalLength : 0) heightMeasureSpec:heightMeasureSpec totalHeight:0];
            
            if (oldWidth != CGFLOAT_MIN) {
                lp.width = oldWidth;
            }
            
            CGFloat childWidth = child.measuredSize.width;
            if (isExactly) {
                _totalLength += childWidth + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child];
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + childWidth + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child]);
            }
            
            if (useLargestChild) {
                largestChildWidth = MAX(childWidth, largestChildWidth);
            }
        }
        
        BOOL matchHeightLocally = false;
        if (heightMode != IDLLayoutMeasureSpecModeExactly && lp.height == IDLLayoutParamsSizeMatchParent) {
            // The height of the linear layout will scale, and at least one
            // child said it wanted to match our height. Set a flag indicating that
            // we need to remeasure at least that view when we know our height.
            matchHeight = true;
            matchHeightLocally = true;
        }
        
        CGFloat margin = lpMargin.top + lpMargin.bottom;
        CGFloat childHeight = child.measuredSize.height + margin;
        childState = [UIView combineMeasuredStatesCurrentState:childState newState:child.measuredState];
        
        if (baselineAligned) {
            CGFloat childBaseline = child.baseline;
            if (childBaseline != -1) {
                // Translates the child's vertical gravity into an index
                // in the range 0..VERTICAL_GRAVITY_COUNT
                IDLViewContentGravity gravity = (lp.gravity < IDLViewContentGravityNone ? _gravity : lp.gravity) & VERTICAL_GRAVITY_MASK;
                int index = ((gravity >> AXIS_Y_SHIFT)
                             & ~AXIS_SPECIFIED) >> 1;
                
                maxAscent[index] = MAX(maxAscent[index], childBaseline);
                maxDescent[index] = MAX(maxDescent[index], childHeight - childBaseline);
            }
        }
        
        maxHeight = MAX(maxHeight, childHeight);
        
        allFillParent = allFillParent && lp.height == IDLLayoutParamsSizeMatchParent;
        if (lp.weight > 0) {
            /*
             * Heights of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxHeight = MAX(weightedMaxHeight,
                                    matchHeightLocally ? margin : childHeight);
        } else {
            alternativeMaxHeight = MAX(alternativeMaxHeight,
                                       matchHeightLocally ? margin : childHeight);
        }
        
        i += [self childrenSkipCountAfterChild:child atIndex:i];
    }
    
    // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
    // the most common case
    if (maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP] != -1 ||
        maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL] != -1 ||
        maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM] != -1 ||
        maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL] != -1) {
        int ascent = MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL],
                         MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                             MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP], maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
        int descent = MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_FILL],
                          MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                              MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_TOP], maxDescent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
        maxHeight = MAX(maxHeight, ascent + descent);
    }
    
    if (useLargestChild &&
        (widthMode == IDLLayoutMeasureSpecModeAtMost || widthMode == IDLLayoutMeasureSpecModeUnspecified)) {
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [[self subviews] objectAtIndex:i];
            
            if (child.visibility == IDLViewVisibilityGone) {
                i += [self childrenSkipCountAfterChild:child atIndex:i];
                continue;
            }
            
            IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *)
            child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            if (isExactly) {
                _totalLength += largestChildWidth + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child];
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + largestChildWidth + lpMargin.left + lpMargin.right + [ self nextLocationOffsetOfChild:child]);
            }
        }
    }
    
    // Add in our padding
    UIEdgeInsets padding = self.padding;
    _totalLength += padding.left + padding.right;
    
    CGFloat widthSize = _totalLength;
    
    // Check against our minimum width
    CGSize minSize = self.minSize;
    widthSize = MAX(widthSize, minSize.width);
    
    // Reconcile our calculated size with the widthMeasureSpec
    IDLLayoutMeasuredDimension widthSizeAndState = [UIView resolveSizeAndStateForSize:widthSize measureSpec:widthMeasureSpec childMeasureState:IDLLayoutMeasuredStateNone];
    widthSize = widthSizeAndState.size;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds
    CGFloat delta = widthSize - _totalLength;
    if (delta != 0 && totalWeight > 0.0f) {
        float weightSum = _weightSum > 0.0f ? _weightSum : totalWeight;
        
        maxAscent[0] = maxAscent[1] = maxAscent[2] = maxAscent[3] = -1;
        maxDescent[0] = maxDescent[1] = maxDescent[2] = maxDescent[3] = -1;
        maxHeight = -1;
        
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [[self subviews] objectAtIndex:i];
            
            if (child.visibility == IDLViewVisibilityGone) {
                continue;
            }
            
            IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            float childExtra = lp.weight;
            if (childExtra > 0) {
                // Child said it could absorb extra space -- give him his share
                int share = (int) (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                IDLLayoutMeasureSpec childHeightMeasureSpec = [self childMeasureSpecWithMeasureSpec:heightMeasureSpec padding:(padding.top + padding.bottom + lpMargin.top + lpMargin.bottom) childDimension:lp.height];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if ((lp.width != 0) || (widthMode != IDLLayoutMeasureSpecModeExactly)) {
                    // child was measured once already above ... base new measurement
                    // on stored values
                    CGFloat childWidth = child.measuredSize.width + share;
                    if (childWidth < 0) {
                        childWidth = 0;
                    }
                    
                    IDLLayoutMeasureSpec childWidthMeasureSpec;
                    childWidthMeasureSpec.size = childWidth;
                    childWidthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
                    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                } else {
                    // child was skipped in the loop above. Measure for this first time here
                    IDLLayoutMeasureSpec childWidthMeasureSpec;
                    childWidthMeasureSpec.size = (share > 0 ? share : 0);
                    childWidthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
                    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
                
                // Child may now not fit in horizontal dimension.
                IDLLayoutMeasuredWidthHeightState newState = child.measuredState;
                newState.heightState = IDLLayoutMeasuredStateNone;
                childState = [UIView combineMeasuredStatesCurrentState:childState newState:newState];
            }
            
            if (isExactly) {
                _totalLength += child.measuredSize.width + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child];
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + child.measuredSize.width + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child]);
            }
            
            BOOL matchHeightLocally = heightMode != IDLLayoutMeasureSpecModeExactly && lp.height == IDLLayoutParamsSizeMatchParent;
            
            CGFloat margin = lpMargin.top + lpMargin.bottom;
            CGFloat childHeight = child.measuredSize.height + margin;
            maxHeight = MAX(maxHeight, childHeight);
            alternativeMaxHeight = MAX(alternativeMaxHeight,
                                       matchHeightLocally ? margin : childHeight);
            
            allFillParent = allFillParent && lp.height == IDLLayoutParamsSizeMatchParent;
            
            if (baselineAligned) {
                CGFloat childBaseline = child.baseline;
                if (childBaseline != -1) {
                    // Translates the child's vertical gravity into an index in the range 0..2
                    IDLViewContentGravity gravity = (lp.gravity < IDLViewContentGravityNone ? _gravity : lp.gravity) & VERTICAL_GRAVITY_MASK;
                    int index = ((gravity >> AXIS_Y_SHIFT)
                                 & ~AXIS_SPECIFIED) >> 1;
                    
                    maxAscent[index] = MAX(maxAscent[index], childBaseline);
                    maxDescent[index] = MAX(maxDescent[index],
                                            childHeight - childBaseline);
                }
            }
        }
        
        // Add in our padding
        _totalLength += padding.left + padding.right;
        // TODO: Should we update widthSize with the new total length?
        
        // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
        // the most common case
        if (maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP] != -1 ||
            maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL] != -1 ||
            maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM] != -1 ||
            maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL] != -1) {
            int ascent = MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL],
                             MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                                 MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP], maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
            int descent = MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_FILL],
                              MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                                  MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_TOP], maxDescent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
            maxHeight = MAX(maxHeight, ascent + descent);
        }
    } else {
        alternativeMaxHeight = MAX(alternativeMaxHeight, weightedMaxHeight);
        
        // We have no limit, so make all weighted views as wide as the largest child.
        // Children will have already been measured once.
        if (useLargestChild && widthMode == IDLLayoutMeasureSpecModeUnspecified) {
            for (int i = 0; i < count; i++) {
                UIView *child = [[self subviews] objectAtIndex:i];
                
                if (child.visibility == IDLViewVisibilityGone) {
                    continue;
                }
                
                IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) child.layoutParams;
                
                float childExtra = lp.weight;
                if (childExtra > 0) {
                    IDLLayoutMeasureSpec childWidthMeasureSpec;
                    IDLLayoutMeasureSpec childHeightMeasureSpec;
                    childWidthMeasureSpec.size = largestChildWidth;
                    childWidthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
                    childHeightMeasureSpec.size = child.measuredSize.height;
                    childHeightMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
                    [child measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
            }
        }
    }
    
    if (!allFillParent && heightMode != IDLLayoutMeasureSpecModeExactly) {
        maxHeight = alternativeMaxHeight;
    }
    
    maxHeight += padding.top + padding.bottom;
    
    // Check against our minimum height
    maxHeight = MAX(maxHeight, minSize.height);
    
    widthSizeAndState.state |= childState.widthState;
    IDLLayoutMeasuredSize measuredSize = IDLLayoutMeasuredSizeMake(widthSizeAndState, [UIView resolveSizeAndStateForSize:maxHeight measureSpec:heightMeasureSpec childMeasureState:childState.heightState]);
    [self setMeasuredDimensionSize:measuredSize];
    
    if (matchHeight) {
        [self forceUniformHeightWithCount:count widthMeasureSpec:widthMeasureSpec];
    }
}


- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    if (_orientation == LinearLayoutOrientationVertical) {
        [self measureVerticalWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    } else {
        [self measureHorizontalWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
}

/**
 * <p>Return the location offset of the specified child. This can be used
 * by subclasses to change the location of a given widget.</p>
 *
 * @param child the child for which to obtain the location offset
 * @return the location offset in pixels
 */
-(CGFloat)locationOffsetOfChild:(UIView *)child {
    return 0;
}

- (void)setChildFrameOfChild:(UIView *)child withFrame:(CGRect)frame {
    [child layoutWithFrame:frame];
}

/**
 * Position the children during a layout pass if the orientation of this
 * LinearLayout is set to LinearLayoutOrientationVertical.
 */
- (void)layoutVertical {
    UIEdgeInsets padding = self.padding;
    
    CGFloat childTop;
    CGFloat childLeft;
    
    // Where right end of child should go
    CGFloat width = self.frame.size.width;
    CGFloat childRight = width - padding.right;
    
    // Space available for child
    CGFloat childSpace = width - padding.left - padding.right;
    
    NSInteger count = [self.subviews count];
    
    IDLViewContentGravity majorGravity = _gravity & VERTICAL_GRAVITY_MASK;
    IDLViewContentGravity minorGravity = _gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    
    switch (majorGravity) {
        case IDLViewContentGravityBottom:
            // mTotalLength contains the padding already
            childTop = padding.top + self.frame.size.height - _totalLength;
            break;
            
            // mTotalLength contains the padding already
        case IDLViewContentGravityCenterVertical:
            childTop = padding.top + (self.frame.size.height - _totalLength) / 2;
            break;
            
        case IDLViewContentGravityTop:
        default:
            childTop = padding.top;
            break;
    }
    
    for (int i = 0; i < count; i++) {
        UIView *child = [self.subviews objectAtIndex:i];
        if (child.visibility != IDLViewVisibilityGone) {
            CGSize childSize = child.measuredSize;
            
            IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            IDLViewContentGravity gravity = lp.gravity;
            if (gravity < IDLViewContentGravityNone) {
                gravity = minorGravity;
            }
            switch (gravity & HORIZONTAL_GRAVITY_MASK) {
                case IDLViewContentGravityCenterHorizontal:
                    childLeft = padding.left + ((childSpace - childSize.width) / 2)
                    + lpMargin.left - lpMargin.right;
                    break;
                    
                case IDLViewContentGravityRight:
                    childLeft = childRight - childSize.width - lpMargin.right;
                    break;
                    
                case IDLViewContentGravityLeft:
                default:
                    childLeft = padding.left + lpMargin.left;
                    break;
            }
            
            childTop += lpMargin.top;
            [self setChildFrameOfChild:child withFrame:CGRectMake(childLeft, childTop + [self locationOffsetOfChild:child], childSize.width, childSize.height)];
            childTop += childSize.height + lpMargin.bottom + [self nextLocationOffsetOfChild:child];
            
            i += [self childrenSkipCountAfterChild:child atIndex:i];
        }
    }
}

/**
 * Position the children during a layout pass if the orientation of this
 * LinearLayout is set to LinearLayoutOrientationHorizontal.
 */
- (void)layoutHorizontal {
    UIEdgeInsets padding = self.padding;
    
    CGFloat childTop;
    CGFloat childLeft;
    
    // Where bottom of child should go
    CGFloat height = self.frame.size.height;
    CGFloat childBottom = height - padding.bottom; 
    
    // Space available for child
    CGFloat childSpace = height - padding.top - padding.bottom;
    
    NSInteger count = [self.subviews count];
    
    IDLViewContentGravity majorGravity = _gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    IDLViewContentGravity minorGravity = _gravity & VERTICAL_GRAVITY_MASK;
    
    BOOL baselineAligned = _baselineAligned;
    switch (majorGravity) {
        case IDLViewContentGravityRight:
            // mTotalLength contains the padding already
            childLeft = padding.left + self.frame.size.width - _totalLength;
            break;
            
        case IDLViewContentGravityCenterHorizontal:
            // mTotalLength contains the padding already
            childLeft = padding.left + (self.frame.size.width - _totalLength) / 2;
            break;
            
        case IDLViewContentGravityLeft:
        default:
            childLeft = padding.left;
            break;
    }
    
    for (NSInteger i = 0; i < count; i++) {
        UIView *child = [self.subviews objectAtIndex:i];
        if (child.visibility != IDLViewVisibilityGone) {
            
            CGSize childSize = child.measuredSize;
            CGFloat childBaseline = -1;
            
            IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            if (baselineAligned && lp.height != IDLLayoutParamsSizeMatchParent) {
                childBaseline = child.baseline;
            }
            
            IDLViewContentGravity gravity = lp.gravity;
            if (gravity < IDLViewContentGravityNone) {
                gravity = minorGravity;
            }
            
            switch (gravity & VERTICAL_GRAVITY_MASK) {
                case IDLViewContentGravityTop:
                    childTop = padding.top + lpMargin.top;
                    if (childBaseline != -1) {
                        childTop += _maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP] - childBaseline;
                    }
                    break;
                    
                case IDLViewContentGravityCenterVertical:
                    childTop = padding.top + ((childSpace - childSize.height) / 2) + lpMargin.top - lpMargin.bottom;
                    break;
                    
                case IDLViewContentGravityBottom:
                    childTop = childBottom - childSize.height - lpMargin.bottom;
                    if (childBaseline != -1) {
                        int descent = childSize.height - childBaseline;
                        childTop -= (_maxDescent[MAX_ASCENT_DESCENT_INDEX_BOTTOM] - descent);
                    }
                    break;
                default:
                    childTop = padding.top;
                    break;
            }
            
            childLeft += lpMargin.left;
            [self setChildFrameOfChild:child withFrame:CGRectMake(childLeft + [self locationOffsetOfChild:child], childTop,
                                                                  childSize.width, childSize.height)];
            childLeft += childSize.width + lpMargin.right + [self nextLocationOffsetOfChild:child];
            
            i += [self childrenSkipCountAfterChild:child atIndex:i];
        }
    }
}


- (void)onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    if (_orientation == LinearLayoutOrientationVertical) {
        [self layoutVertical];
    } else {
        [self layoutHorizontal];
    }
}

- (BOOL)checkLayoutParams:(IDLLayoutParams *)layoutParams {
    return [layoutParams isKindOfClass:[IDLLinearLayoutLayoutParams class]];
}

/**
 * Returns a set of layout parameters with a width of
 * {@link android.view.ViewGroup.LayoutParams#MATCH_PARENT}
 * and a height of {@link android.view.ViewGroup.LayoutParams#WRAP_CONTENT}
 * when the layout's orientation is {@link #VERTICAL}. When the orientation is
 * {@link #HORIZONTAL}, the width is set to {@link LayoutParams#WRAP_CONTENT}
 * and the height to {@link LayoutParams#WRAP_CONTENT}.
 */
-(IDLLayoutParams *)generateDefaultLayoutParams {
    if (_orientation == LinearLayoutOrientationHorizontal) {
        return [[[IDLLinearLayoutLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeWrapContent height:IDLLayoutParamsSizeWrapContent] autorelease];
    } else if (_orientation == LinearLayoutOrientationVertical) {
        return [[[IDLLinearLayoutLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeMatchParent height:IDLLayoutParamsSizeWrapContent] autorelease];
    }
    return nil;
}

-(IDLLayoutParams *)generateLayoutParamsFromLayoutParams:(IDLLayoutParams *)layoutParams {
    return [[[IDLLinearLayoutLayoutParams alloc] initWithLayoutParams:layoutParams] autorelease];
}

- (IDLLayoutParams *)generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[[IDLLinearLayoutLayoutParams alloc] initWithAttributes:attrs] autorelease];
}

@end
