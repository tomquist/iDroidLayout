//
//  IDLStateListDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableContainer.h"

@interface IDLStateListDrawable : IDLDrawableContainer

- (void)addDrawable:(IDLDrawable *)drawable forState:(UIControlState)state;

@end
