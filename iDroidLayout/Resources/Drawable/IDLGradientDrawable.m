//
//  IDLGradientDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLGradientDrawable.h"

@implementation IDLGradientDrawable

- (void)drawOnLayer:(CALayer *)layer {
    CAGradientLayer *sublayer = [CAGradientLayer layer];
    sublayer.frame = layer.bounds;
    CAGradientLayer * gradient = [CAGradientLayer layer];
    [gradient setColors:[NSArray arrayWithObjects:(id)[self.startColor CGColor], (id)[self.endColor CGColor], nil]];
}

@end
