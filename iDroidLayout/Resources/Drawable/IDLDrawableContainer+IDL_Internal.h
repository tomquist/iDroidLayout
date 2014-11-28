//
//  IDLDrawableContainer+IDL_Internal.h
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableContainer.h"

@interface IDLDrawableContainer (IDL_Internal)

@property (nonatomic, readonly) NSInteger currentIndex;

- (instancetype)initWithState:(IDLDrawableContainerConstantState *)state;
- (BOOL)selectDrawableAtIndex:(NSInteger)index;

@end

@interface IDLDrawableContainerConstantState (IDL_Internal)

@property (nonatomic, assign) IDLDrawableContainer *owner;

// Drawables
@property (nonatomic, retain) NSMutableArray *drawables;

// Dimension
@property (nonatomic, assign) CGSize constantIntrinsicSize;
@property (nonatomic, assign) CGSize constantMinimumSize;
@property (nonatomic, assign, getter = isConstantSizeComputed) BOOL constantSizeComputed;
@property (nonatomic, assign, getter = isConstantSize) BOOL constantSize;

// Statful
@property (nonatomic, assign) BOOL haveStateful;
@property (nonatomic, assign, getter = isStateful) BOOL stateful;

// Padding
@property (nonatomic, assign, getter = isPaddingComputed) BOOL paddingComputed;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, assign) BOOL hasPadding;

- (instancetype)initWithState:(IDLDrawableContainerConstantState *)state owner:(IDLDrawableContainer *)owner;
- (void)addChildDrawable:(IDLDrawable *)drawable;

@end