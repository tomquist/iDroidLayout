//
//  LinearLayoutLayoutParams.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLinearLayoutLayoutParams.h"

@implementation IDLLinearLayoutLayoutParams

@synthesize gravity = _gravity;
@synthesize weight = _weight;

- (void) dealloc {
	
	[super dealloc];
}


- (id)initWithWidth:(CGFloat)width height:(CGFloat)height {
	self = [super initWithWidth:width height:height];
	if (self != nil) {
		
	}
	return self;
}

- (id)initWithLayoutParams:(IDLLayoutParams *)layoutParams {
    self = [super initWithLayoutParams:layoutParams];
    if (self) {
        if ([layoutParams isKindOfClass:[IDLLinearLayoutLayoutParams class]]) {
            IDLLinearLayoutLayoutParams *otherLP = (IDLLinearLayoutLayoutParams *)layoutParams;
            self.gravity = otherLP.gravity;
            self.weight = otherLP.weight;
        }
    }
    return self;
}

- (id)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        _gravity = [IDLGravity gravityFromAttribute:[attrs objectForKey:@"layout_gravity"]];
        _weight = [[attrs objectForKey:@"layout_weight"] floatValue];
    }
    return self;
}


@end
