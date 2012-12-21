//
//  IDLInsetDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"

@interface IDLInsetDrawable : IDLDrawable

@property (nonatomic, readonly) UIEdgeInsets insets;
@property (nonatomic, readonly) IDLDrawable *drawable;

@end
