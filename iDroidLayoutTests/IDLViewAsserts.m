//
//  IDLViewAsserts.m
//  iDroidLayout
//
//  Created by Tom Quist on 15.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewAsserts.h"
#import <iDroidLayout/iDroidLayout.h>

@implementation IDLViewAsserts

/**
 * Assert that the specified group contains a specific child once and only once.
 *
 * @param parent The group
 * @param child The child that should belong to group
 */
- (void)assertGroup:(UIView *)parent contains:(UIView *)child {
    NSUInteger count = [[parent subviews] count];
    BOOL found = FALSE;
    for (int i = 0; i < count; i++) {
        if ([[parent subviews] objectAtIndex:i] == child) {
            if (!found) {
                found = TRUE;
            } else {
                STFail([NSString stringWithFormat:@"child %@ is duplicated in parent", child]);
            }
        }
    }
    STAssertTrue(found, [NSString stringWithFormat:@"group does not contain %@", child]);
}

/**
 * Assert that the specified group does not contain a specific child.
 *
 * @param parent The group
 * @param child The child that should not belong to group
 */
- (void)assertGroup:(UIView *)parent notContains:(UIView *)child {
    NSUInteger count = [[parent subviews] count];
    for (int i = 0; i < count; i++) {
        if ([[parent subviews] objectAtIndex:i] == child) {
            STFail([NSString stringWithFormat:@"child %@ is found in parent", child]);
        }
    }
}

/**
 * Finds the most common ancestor of two views.
 */
- (UIView *)findMostCommonAncestorOfView:(UIView *)view1 andView:(UIView *)view2 {
    NSMutableArray *path1 = [[NSMutableArray alloc] init];
    NSMutableArray *path2 = [[NSMutableArray alloc] init];
    UIView *n1 = view1;
    while (n1 != nil) {
        [path1 addObject:n1];
        n1 = [n1 superview];
    }
    UIView *n2 = view2;
    while (n2 != nil) {
        [path2 addObject:n2];
        n2 = [n2 superview];
    }
    UIView *result = nil;
    while ([path1 lastObject] == [path2 lastObject]) {
        result = [path1 lastObject];
        [path1 removeLastObject];
        [path2 removeLastObject];
    }
    return result;
}

/**
 * Assert that two views are left aligned, that is that their left edges
 * are on the same x location.
 *
 * @param first The first view
 * @param second The second view
 */
- (void)assertView:(UIView *)first isLeftAlignedToView:(UIView *)second {
    UIView *commonAncestor = [self findMostCommonAncestorOfView:first andView:second];
    if (commonAncestor == nil) {
        STFail(@"Views can't be aligned because they don't have a common ancestor");
    }
    CGPoint origin1 = [commonAncestor convertPoint:first.frame.origin fromView:first];
    CGPoint origin2 = [commonAncestor convertPoint:second.frame.origin fromView:second];
    STAssertEquals(origin1.x, origin2.x, @"views are not left aligned");
}

/**
 * Assert that two views are right aligned, that is that their right edges
 * are on the same x location.
 *
 * @param first The first view
 * @param second The second view
 */
- (void)assertView:(UIView *)first isRightAlignedToView:(UIView *)second {
    UIView *commonAncestor = [self findMostCommonAncestorOfView:first andView:second];
    if (commonAncestor == nil) {
        STFail(@"Views can't be aligned because they don't have a common ancestor");
    }
    CGPoint origin1 = [commonAncestor convertPoint:first.frame.origin fromView:first];
    CGPoint origin2 = [commonAncestor convertPoint:second.frame.origin fromView:second];
    STAssertEquals(origin1.x + first.measuredSize.width, origin2.x + second.measuredSize.width, @"views are not right aligned");
}

/**
 * Assert that two views are top aligned, that is that their top edges
 * are on the same y location.
 *
 * @param first The first view
 * @param second The second view
 */
- (void)assertView:(UIView *)first isTopAlignedToView:(UIView *)second {
    UIView *commonAncestor = [self findMostCommonAncestorOfView:first andView:second];
    if (commonAncestor == nil) {
        STFail(@"Views can't be aligned because they don't have a common ancestor");
    }
    CGPoint origin1 = [commonAncestor convertPoint:first.frame.origin fromView:first];
    CGPoint origin2 = [commonAncestor convertPoint:second.frame.origin fromView:second];
    STAssertEquals(origin1.y, origin2.y, @"views are not top aligned");
}

/**
 * Assert that two views are bottom aligned, that is that their bottom edges
 * are on the same y location.
 *
 * @param first The first view
 * @param second The second view
 */
- (void)assertView:(UIView *)first isBottomAlignedToView:(UIView *)second {
    UIView *commonAncestor = [self findMostCommonAncestorOfView:first andView:second];
    if (commonAncestor == nil) {
        STFail(@"Views can't be aligned because they don't have a common ancestor");
    }
    CGPoint origin1 = [commonAncestor convertPoint:first.frame.origin fromView:first];
    CGPoint origin2 = [commonAncestor convertPoint:second.frame.origin fromView:second];
    STAssertEquals(origin1.y + first.measuredSize.height, origin2.y + second.measuredSize.height, @"views are not bottom aligned");
}

@end
