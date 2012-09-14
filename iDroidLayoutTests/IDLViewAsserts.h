//
//  IDLViewAsserts.h
//  iDroidLayout
//
//  Created by Tom Quist on 15.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

@interface IDLViewAsserts : SenTestCase

- (void)assertGroup:(UIView *)parent contains:(UIView *)child;
- (void)assertGroup:(UIView *)parent notContains:(UIView *)child;

@end
