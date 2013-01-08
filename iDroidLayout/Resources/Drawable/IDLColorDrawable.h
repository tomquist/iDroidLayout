//
//  IDLColorDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"

@interface IDLColorDrawable : IDLDrawable

- (id)initWithColor:(UIColor *)color;

@property (nonatomic, readonly) UIColor *color;

@end

@interface IDLColorDrawableConstantState : IDLDrawableConstantState

@end