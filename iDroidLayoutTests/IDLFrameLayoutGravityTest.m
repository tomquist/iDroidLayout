//
//  IDLFrameLayoutGravityTest.m
//  iDroidLayout
//
//  Created by Tom Quist on 16.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLFrameLayoutGravityTest.h"
#import <iDroidLayout/iDroidLayout.h>

@implementation IDLFrameLayoutGravityTest

- (void)setUp {
    [super setUp];
    IDLLayoutInflater *layoutInflater = [[IDLLayoutInflater alloc] init];
    IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 500, 1000)];
    UIView *inflatedView = [layoutInflater inflateResource:@"framelayout_gravity.xml" intoRootView:bridge attachToRoot:TRUE];
    
    _parent = [[inflatedView findViewById:@"parent"] retain];
    
    _leftView = [[inflatedView findViewById:@"left"] retain];
    _rightView = [[inflatedView findViewById:@"right"] retain];
    _centerHorizontalView = [[inflatedView findViewById:@"center_horizontal"] retain];
    
    _leftCenterVerticalView = [[inflatedView findViewById:@"left_center_vertical"] retain];
    _rightCenterVerticalView = [[inflatedView findViewById:@"right_center_vertical"] retain];
    _centerView = [[inflatedView findViewById:@"center"] retain];
    
    _leftBottomView = [[inflatedView findViewById:@"left_bottom"] retain];
    _rightBottomView = [[inflatedView findViewById:@"right_bottom"] retain];
    _centerHorizontalBottomView = [[inflatedView findViewById:@"center_horizontal_bottom"] retain];
}

- (void)tearDown {
    [_parent release];
    [_leftView release];
    [_rightView release];
    [_centerHorizontalView release];
    [_leftCenterVerticalView release];
    [_rightCenterVerticalView release];
    [_centerView release];
    [_leftBottomView release];
    [_rightBottomView release];
    [_centerHorizontalBottomView release];
}

- (void)testLeftTopAligned {
    [self assertView:_parent isLeftAlignedToView:_leftView];
    [self assertView:_parent isTopAlignedToView:_leftView];
}

- (void)testRightTopAligned {
    [self assertView:_parent isRightAlignedToView:_rightView];
    [self assertView:_parent isTopAlignedToView:_rightView];
}

@end
