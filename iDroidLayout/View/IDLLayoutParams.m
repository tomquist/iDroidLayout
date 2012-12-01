//
//  LayoutParams.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayoutParams.h"

#define LAYOUT_SIZE_MATCH_PARENT @"match_parent"
#define LAYOUT_SIZE_FILL_PARENT @"fill_parent"
#define LAYOUT_SIZE_WRAP_CONTENT @"wrap_content"

@implementation IDLLayoutParams

@synthesize width = _width;
@synthesize height = _height;

- (void)dealloc {
	
	[super dealloc];
}


- (id)initWithWidth:(CGFloat)width height:(CGFloat)height {
	self = [super init];
	if (self != nil) {
		_width = width;
        _height = height;
	}
	return self;
}

- (id)initWithLayoutParams:(IDLLayoutParams *)layoutParams {
    self = [self initWithWidth:layoutParams.width height:layoutParams.height];
	if (self != nil) {
		
	}
	return self;
}

+ (CGFloat)sizeForLayoutSizeAttribute:(NSString *)sizeAttr {
    CGFloat ret = 0;
    if ([sizeAttr isEqualToString:LAYOUT_SIZE_MATCH_PARENT] || [sizeAttr isEqualToString:LAYOUT_SIZE_FILL_PARENT]) {
        ret = IDLLayoutParamsSizeMatchParent;
    } else if ([sizeAttr isEqualToString:LAYOUT_SIZE_WRAP_CONTENT]) {
        ret = IDLLayoutParamsSizeWrapContent;
    } else {
        ret = [sizeAttr floatValue];
    }
    return ret;
}

- (id)initWithAttributes:(NSDictionary *)attrs {
    self = [super init];
    if (self) {
        NSString *widthAttr = [attrs objectForKey:@"layout_width"];
        NSString *heightAttr = [attrs objectForKey:@"layout_height"];
        if (widthAttr == nil || heightAttr == nil) {
            NSLog(@"You have to set the layout_width and laypit_height parameters.");
            [self release];
            return nil;
        }
        _width = [IDLLayoutParams sizeForLayoutSizeAttribute:widthAttr];
        _height = [IDLLayoutParams sizeForLayoutSizeAttribute:heightAttr];
    }
    return self;
}

@end
