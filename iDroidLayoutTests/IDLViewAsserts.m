//
//  IDLViewAsserts.m
//  iDroidLayout
//
//  Created by Tom Quist on 15.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewAsserts.h"

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

@end
