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

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, assign) IDLViewContentGravity gravity;

- (id)initWithImage:(UIImage *)image;

@end
