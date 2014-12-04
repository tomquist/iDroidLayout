//
//  RelativeLayoutLayoutParams.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLMarginLayoutParams.h"

typedef NS_ENUM(NSUInteger ,IDLRelativeLayoutRule) {
    /**
     * Rule that aligns a child's right edge with another child's left edge.
     */
    IDLRelativeLayoutRuleLeftOf = 0,
    /**
     * Rule that aligns a child's left edge with another child's right edge.
     */
    IDLRelativeLayoutRuleRightOf = 1,
    /**
     * Rule that aligns a child's bottom edge with another child's top edge.
     */
    IDLRelativeLayoutRuleAbove = 2,
    /**
     * Rule that aligns a child's top edge with another child's bottom edge.
     */
    IDLRelativeLayoutRuleBelow = 3,
    
    /**
     * Rule that aligns a child's baseline with another child's baseline.
     */
    IDLRelativeLayoutRuleAlignBaseline = 4,
    /**
     * Rule that aligns a child's left edge with another child's left edge.
     */
    IDLRelativeLayoutRuleAlignLeft = 5,
    /**
     * Rule that aligns a child's top edge with another child's top edge.
     */
    IDLRelativeLayoutRuleAlignTop = 6,
    /**
     * Rule that aligns a child's right edge with another child's right edge.
     */
    IDLRelativeLayoutRuleAlignRight = 7,
    /**
     * Rule that aligns a child's bottom edge with another child's bottom edge.
     */
    IDLRelativeLayoutRuleAlignBottom = 8,
    
    /**
     * Rule that aligns the child's left edge with its RelativeLayout
     * parent's left edge.
     */
    IDLRelativeLayoutRuleAlignParentLeft = 9,
    /**
     * Rule that aligns the child's top edge with its RelativeLayout
     * parent's top edge.
     */
    IDLRelativeLayoutRuleAlignParentTop = 10,
    /**
     * Rule that aligns the child's right edge with its RelativeLayout
     * parent's right edge.
     */
    IDLRelativeLayoutRuleAlignParentRight = 11,
    /**
     * Rule that aligns the child's bottom edge with its RelativeLayout
     * parent's bottom edge.
     */
    IDLRelativeLayoutRuleAlignParentBottom = 12,
    
    /**
     * Rule that centers the child with respect to the bounds of its
     * RelativeLayout parent.
     */
    IDLRelativeLayoutRuleCenterInParent = 13,
    /**
     * Rule that centers the child horizontally with respect to the
     * bounds of its RelativeLayout parent.
     */
    IDLRelativeLayoutRuleCenterHorizontal = 14,
    /**
     * Rule that centers the child vertically with respect to the
     * bounds of its RelativeLayout parent.
     */
    IDLRelativeLayoutRuleCenterVertical = 15
};

@interface IDLRelativeLayoutLayoutParams : IDLMarginLayoutParams

@property (nonatomic, readonly) NSArray *rules;
@property (nonatomic, assign) BOOL alignWithParent;

@end
