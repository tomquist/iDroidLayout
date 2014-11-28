//
//  IDLBitmapDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"
#import "IDLGravity.h"

@interface IDLBitmapDrawable : IDLDrawable

- (instancetype)initWithImage:(UIImage *)image;

@end

@interface IDLBitmapDrawableConstantState : IDLDrawableConstantState

@end
