//
//  IDLFrameLayoutGravityTest.h
//  iDroidLayout
//
//  Created by Tom Quist on 16.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewAsserts.h"

@interface IDLFrameLayoutGravityTest : IDLViewAsserts {
    UIView *_parent;
    UIView *_leftView;
    UIView *_rightView;
    UIView *_centerHorizontalView;
    UIView *_leftCenterVerticalView;
    UIView *_rightCenterVerticalView;
    UIView *_centerView;
    UIView *_leftBottomView;
    UIView *_rightBottomView;
    UIView *_centerHorizontalBottomView;
    
}

@end
