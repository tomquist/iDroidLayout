//
//  LayoutBridge.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLinearLayout.h"

@interface IDLLayoutBridge : IDLViewGroup {
    CGRect _lastFrame;
    BOOL _resizeOnKeyboard;
    BOOL _scrollToTextField;
}

@property (nonatomic, assign, getter = isResizingOnKeyboard) BOOL resizeOnKeyboard;
@property (nonatomic, assign, getter = isScrollingToTextField) BOOL scrollToTextField;

@end
