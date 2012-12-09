//
//  IDLResourceStateItem.m
//  iDroidLayout
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLResourceStateItem.h"

@interface IDLResourceStateItem ()

@property (nonatomic, assign) UIControlState internalControlState;

@end

@implementation IDLResourceStateItem

- (id)initWithControlState:(UIControlState)controlState {
    self = [super init];
    if (self) {
        self.internalControlState = controlState;
    }
    return self;
}

- (UIControlState)controlState {
    return self.internalControlState;
}

@end
