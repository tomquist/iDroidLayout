//
//  IDLColorDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"

@interface IDLColorDrawable : IDLDrawable

- (instancetype)initWithColor:(UIColor *)color;

@property (strong, nonatomic, readonly) UIColor *color;

@end

@interface IDLColorDrawableConstantState : IDLDrawableConstantState

@end