//
//  IDLStateListDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableContainer.h"
#import "IDLColorStateList.h"

@interface IDLStateListDrawable : IDLDrawableContainer

- (instancetype)initWithColorStateListe:(IDLColorStateList *)colorStateList;

@end

@interface IDLStateListDrawableConstantState : IDLDrawableContainerConstantState

@end