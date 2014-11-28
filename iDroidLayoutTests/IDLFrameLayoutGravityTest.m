//
//  IDLFrameLayoutGravityTest.m
//  iDroidLayout
//
//  Created by Tom Quist on 16.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLFrameLayoutGravityTest.h"
#import "iDroidLayout.h" // iDroidLayout

@implementation IDLFrameLayoutGravityTest

- (void)setUp {
    [super setUp];
    IDLLayoutInflater *layoutInflater = [[IDLLayoutInflater alloc] init];
    IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 500, 1000)];
    UIView *inflatedView = [layoutInflater inflateResource:@"framelayout_gravity.xml" intoRootView:bridge attachToRoot:TRUE];
    
    _parent = [inflatedView findViewById:@"parent"];
    
    _leftView = [inflatedView findViewById:@"left"];
    _rightView = [inflatedView findViewById:@"right"];
    _centerHorizontalView = [inflatedView findViewById:@"center_horizontal"];
    
    _leftCenterVerticalView = [inflatedView findViewById:@"left_center_vertical"];
    _rightCenterVerticalView = [inflatedView findViewById:@"right_center_vertical"];
    _centerView = [inflatedView findViewById:@"center"];
    
    _leftBottomView = [inflatedView findViewById:@"left_bottom"];
    _rightBottomView = [inflatedView findViewById:@"right_bottom"];
    _centerHorizontalBottomView = [inflatedView findViewById:@"center_horizontal_bottom"];
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
