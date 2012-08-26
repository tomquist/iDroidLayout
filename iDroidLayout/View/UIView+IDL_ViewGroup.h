//
//  UIView+IDL_ViewGroup.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+IDL_Layout.h"

@interface UIView (IDL_ViewGroup)

- (IDLLayoutParams *)generateDefaultLayoutParams;
- (IDLLayoutParams *)generateLayoutParamsFromLayouParams:(IDLLayoutParams *)lp;
- (IDLLayoutParams *)generateLayoutParamsFromAttributes:(NSDictionary *)attrs;
- (BOOL)checkLayoutParams:(IDLLayoutParams *)layoutParams;
- (IDLLayoutMeasureSpec)childMeasureSpecWithMeasureSpec:(IDLLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension;

- (void)measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed;
-(void)measureChild:(UIView *)child withParentWidthMeasureSpec:(IDLLayoutMeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(IDLLayoutMeasureSpec)parentHeightMeasureSpec;
- (void)measureChildrenWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec;
- (UIView *)findViewTraversal:(NSString *)identifier;

/**
 * Adds a child view with the specified layout parameters.
 *
 * @param child the child view to add
 * @param index the position at which to add the child
 * @param lp the layout parameters to set on the child
 */
- (void)addView:(UIView *)child atIndex:(NSInteger)index withLayoutParams:(IDLLayoutParams *)lp;

- (void)addView:(UIView *)child atIndex:(NSInteger)index;
/**
 * Adds a child view with the specified layout parameters.
 *
 * @param child the child view to add
 * @param lp the layout parameters to set on the child
 */
- (void)addView:(UIView *)child withLayoutParams:(IDLLayoutParams *)lp;
/**
 * Adds a child view. If no layout parameters are already set on the child, the
 * default parameters for this ViewGroup are set on the child.
 *
 * @param child the child view to add
 *
 * @see generateDefaultLayoutParams
 */
- (void)addView:(UIView *)child;

/**
 * Adds a child view with this ViewGroup's default layout parameters and the
 * specified width and height.
 *
 * @param child the child view to add
 */
- (void)addView:(UIView *)child withSize:(CGSize)size;

/**
 * Removes the specified child from the group.
 * 
 * @param view to remove from the group
 */
- (void)removeView:(UIView *)view;

/**
 * Removes the view at the specified position in the group.
 *
 * @param index the position in the group of the view to remove
 */
- (void)removeViewAtIndex:(NSUInteger)index;

/**
 * Is called whenever a view has been removed through the 
 * removeView methods.
 */
- (void)onViewRemoved:(UIView *)view;

@property (nonatomic, readonly) BOOL isViewGroup;

@end
