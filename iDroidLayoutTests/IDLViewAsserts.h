//
//  IDLViewAsserts.h
//  iDroidLayout
//
//  Created by Tom Quist on 15.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>

@interface IDLViewAsserts : XCTestCase

- (void)assertGroup:(UIView *)parent contains:(UIView *)child;
- (void)assertGroup:(UIView *)parent notContains:(UIView *)child;
- (void)assertView:(UIView *)first isLeftAlignedToView:(UIView *)second;
- (void)assertView:(UIView *)first isRightAlignedToView:(UIView *)second;
- (void)assertView:(UIView *)first isTopAlignedToView:(UIView *)second;
- (void)assertView:(UIView *)first isBottomAlignedToView:(UIView *)second;

@end
