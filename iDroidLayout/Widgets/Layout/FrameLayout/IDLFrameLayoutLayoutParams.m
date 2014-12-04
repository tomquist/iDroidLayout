//
//  FrameLayoutLayoutParams.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLFrameLayoutLayoutParams.h"

@implementation IDLFrameLayoutLayoutParams

@synthesize gravity = _gravity;

- (instancetype)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        NSString *gravityString = attrs[@"layout_gravity"];
        _gravity = [IDLGravity gravityFromAttribute:gravityString];
    }
    return self;
}

@end
