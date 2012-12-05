//
//  RelativeLayoutLayoutParams.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLMarginLayoutParams.h"

typedef enum RelativeLayoutRule {
    /**
     * Rule that aligns a child's right edge with another child's left edge.
     */
    RelativeLayoutRuleLeftOf = 0,
    /**
     * Rule that aligns a child's left edge with another child's right edge.
     */
    RelativeLayoutRuleRightOf = 1,
    /**
     * Rule that aligns a child's bottom edge with another child's top edge.
     */
    RelativeLayoutRuleAbove = 2,
    /**
     * Rule that aligns a child's top edge with another child's bottom edge.
     */
    RelativeLayoutRuleBelow = 3,
    
    /**
     * Rule that aligns a child's baseline with another child's baseline.
     */
    RelativeLayoutRuleAlignBaseline = 4,
    /**
     * Rule that aligns a child's left edge with another child's left edge.
     */
    RelativeLayoutRuleAlignLeft = 5,
    /**
     * Rule that aligns a child's top edge with another child's top edge.
     */
    RelativeLayoutRuleAlignTop = 6,
    /**
     * Rule that aligns a child's right edge with another child's right edge.
     */
    RelativeLayoutRuleAlignRight = 7,
    /**
     * Rule that aligns a child's bottom edge with another child's bottom edge.
     */
    RelativeLayoutRuleAlignBottom = 8,
    
    /**
     * Rule that aligns the child's left edge with its RelativeLayout
     * parent's left edge.
     */
    RelativeLayoutRuleAlignParentLeft = 9,
    /**
     * Rule that aligns the child's top edge with its RelativeLayout
     * parent's top edge.
     */
    RelativeLayoutRuleAlignParentTop = 10,
    /**
     * Rule that aligns the child's right edge with its RelativeLayout
     * parent's right edge.
     */
    RelativeLayoutRuleAlignParentRight = 11,
    /**
     * Rule that aligns the child's bottom edge with its RelativeLayout
     * parent's bottom edge.
     */
    RelativeLayoutRuleAlignParentBottom = 12,
    
    /**
     * Rule that centers the child with respect to the bounds of its
     * RelativeLayout parent.
     */
    RelativeLayoutRuleCenterInParent = 13,
    /**
     * Rule that centers the child horizontally with respect to the
     * bounds of its RelativeLayout parent.
     */
    RelativeLayoutRuleCenterHorizontal = 14,
    /**
     * Rule that centers the child vertically with respect to the
     * bounds of its RelativeLayout parent.
     */
    RelativeLayoutRuleCenterVertical = 15
} RelativeLayoutRule;

@interface IDLRelativeLayoutLayoutParams : IDLMarginLayoutParams {
    BOOL _alignParentLeft;
    BOOL _alignParentTop;
    BOOL _alignParentRight;
    BOOL _alignParentBottom;
    BOOL _centerInParent;
    BOOL _centerHorizontal;
    BOOL _centerVertical;
    
    NSArray *_rules;
    
    CGFloat _left;
    CGFloat _right;
    CGFloat _top;
    CGFloat _bottom;
    BOOL _alignWithParent;
}

@property (nonatomic, readonly) NSArray *rules;
@property (nonatomic, assign) BOOL alignWithParent;

@end
