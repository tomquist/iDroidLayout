//
//  IDLDrawableContainer+IDL_Internal.h
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableContainer.h"

@interface IDLDrawableContainer (IDL_Internal)

@property (nonatomic, readonly) NSArray *drawables;
@property (nonatomic, readonly) NSInteger currentIndex;

- (BOOL)selectDrawableAtIndex:(NSInteger)index;
- (void)addChildDrawable:(IDLDrawable *)drawable;
- (void)invalidate;

@end
