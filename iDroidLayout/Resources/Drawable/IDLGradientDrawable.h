//
//  IDLGradientDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"

@interface IDLGradientDrawable : IDLDrawable

@property (nonatomic, readonly) UIColor *startColor;
@property (nonatomic, readonly) UIColor *endColor;

@end
