//
//  MarginLayoutParams.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLMarginLayoutParams.h"

@implementation IDLMarginLayoutParams

@synthesize margin = _margin;

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
    if (self != nil) {
        if ([layoutParams isKindOfClass:[IDLMarginLayoutParams class]]) {
            IDLMarginLayoutParams *otherLP = (IDLMarginLayoutParams *)layoutParams;
            self.margin = otherLP.margin;
        }
    }
    return self;
}

- (id)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        NSString *marginString = [attrs objectForKey:@"layout_margin"];
        if (marginString != nil) {
            CGFloat margin = [marginString floatValue];
            _margin = UIEdgeInsetsMake(margin, margin, margin, margin);
        } else {
            NSString *marginLeftString = [attrs objectForKey:@"layout_marginLeft"];
            NSString *marginTopString = [attrs objectForKey:@"layout_marginTop"];
            NSString *marginBottomString = [attrs objectForKey:@"layout_marginBottom"];
            NSString *marginRightString = [attrs objectForKey:@"layout_marginRight"];
            _margin = UIEdgeInsetsMake([marginTopString floatValue], [marginLeftString floatValue], [marginBottomString floatValue], [marginRightString floatValue]);
        }
    }
    return self;
}

@end
