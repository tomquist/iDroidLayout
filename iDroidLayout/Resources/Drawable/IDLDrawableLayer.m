//
//  IDLDrawableLayer.m
//  iDroidLayout
//
//  Created by Tom Quist on 30.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableLayer.h"

@implementation IDLDrawableLayer

- (id)init {
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

/*- (void)setDrawable:(IDLDrawable *)drawable {
    if (_drawable != drawable) {
        [_drawable release];
        _drawable = [drawable retain];
    }
    NSArray *sublayers = [self.sublayers copy];
    for (CALayer *l in sublayers) {
        [l removeFromSuperlayer];
    }
    [sublayers release];
    [drawable drawOnLayer:self];
}

- (void)layoutSublayers {
    [super layoutSublayers];
    self.drawable = self.drawable;
}*/

- (void)setDrawable:(IDLDrawable *)drawable {
    if (_drawable != drawable) {
        _drawable.delegate = nil;
        [_drawable release];
        _drawable = [drawable retain];
        _drawable.delegate = self;
    }
}

- (void)drawInContext:(CGContextRef)ctx {
    [self.drawable drawInContext:ctx];
}

- (void)drawableDidInvalidate:(IDLDrawable *)drawable {
    [self setNeedsDisplay];
}

- (void)layoutSublayers {
    [super layoutSublayers];
    self.drawable.bounds = self.bounds;
}

@end
