//
//  LayoutBridge.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewGroup.h"

@interface IDLLayoutBridge : IDLViewGroup {
    CGRect _lastFrame;
    BOOL _resizeOnKeyboard;
}

@property (nonatomic, assign) BOOL resizeOnKeyboard;

@end
