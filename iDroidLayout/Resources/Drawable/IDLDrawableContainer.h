//
//  IDLDrawableContainer.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"

@interface IDLDrawableContainer : IDLDrawable

@property (nonatomic, assign, getter = isConstantSize) BOOL constantSize;

@end
