//
//  IDLDrawableContainer.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableContainer.h"
#import "IDLDrawableContainer+IDL_Internal.h"
#import "IDLDrawable+IDL_Internal.h"

@interface IDLDrawableContainerConstantState ()

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

@end

@implementation IDLDrawableContainerConstantState

- (void)dealloc {
    for (IDLDrawable *drawable in self.drawables) {
        drawable.delegate = nil;
    }
    self.drawables = nil;
    [super dealloc];
}

- (id)initWithState:(IDLDrawableContainerConstantState *)state owner:(IDLDrawableContainer *)owner {
    self = [super init];
    if (self) {
        self.owner = owner;
        if (state != nil) {
            NSMutableArray *drawables = [[NSMutableArray alloc] initWithCapacity:[state.drawables count]];
            for (IDLDrawable *drawable in state.drawables) {
                IDLDrawable *copiedDrawable = [drawable copy];
                copiedDrawable.delegate = owner;
                [drawables addObject:copiedDrawable];
                [copiedDrawable release];
            }
            self.drawables = drawables;
            [drawables release];
            self.constantIntrinsicSize = state.constantIntrinsicSize;
            self.constantMinimumSize = state.constantMinimumSize;
            self.constantSizeComputed = state.constantSizeComputed;
            self.haveStateful = state.haveStateful;
            self.stateful = state.stateful;
            self.paddingComputed = state.paddingComputed;
            self.padding = state.padding;
            self.hasPadding = state.hasPadding;
        } else {
            NSMutableArray *drawables = [[NSMutableArray alloc] initWithCapacity:10];
            self.drawables = drawables;
            [drawables release];
        }
    }
    return self;
}

- (void)addChildDrawable:(IDLDrawable *)drawable {
    [self.drawables addObject:drawable];
    drawable.delegate = self.owner;
    
    self.haveStateful = FALSE;
    self.constantSizeComputed = FALSE;
    self.paddingComputed = FALSE;
}

- (void)computeConstantSize {
    CGSize minSize = CGSizeZero;
    CGSize intrinsicSize = CGSizeZero;
    for (IDLDrawable *drawable in self.drawables) {
        CGSize min = drawable.minimumSize;
        CGSize intrinsic = drawable.intrinsicSize;
        if (min.width > minSize.width) minSize.width = min.width;
        if (min.height > minSize.height) minSize.height = min.height;
        if (intrinsic.width > intrinsicSize.width) intrinsicSize.width = intrinsic.width;
        if (intrinsic.height > intrinsicSize.height) intrinsicSize.height = intrinsic.height;
    }
    self.constantIntrinsicSize = intrinsicSize;
    self.constantMinimumSize = minSize;
    self.constantSizeComputed = TRUE;
}

- (CGSize)constantIntrinsicSize {
    if (!self.isConstantSizeComputed) {
        [self computeConstantSize];
    }
    return _constantIntrinsicSize;
}

- (CGSize)constantMinimumSize {
    if (!self.isConstantSizeComputed) {
        [self computeConstantSize];
    }
    return _constantMinimumSize;
}

- (BOOL)isStateful {
    if (self.haveStateful) {
        return _stateful;
    }
    BOOL stateful = FALSE;
    for (IDLDrawable *child in self.drawables) {
        if (child.isStateful) {
            stateful = TRUE;
            break;
        }
    }
    _stateful = stateful;
    _haveStateful = TRUE;
    return stateful;
}

- (void)computePadding {
    UIEdgeInsets padding = UIEdgeInsetsZero;
    BOOL hasPadding = FALSE;
    for (IDLDrawable *drawable in self.drawables) {
        if (drawable.hasPadding) {
            hasPadding = TRUE;
            UIEdgeInsets childPadding = drawable.padding;
            padding.left = MAX(padding.left, childPadding.left);
            padding.right = MAX(padding.right, childPadding.right);
            padding.top = MAX(padding.top, childPadding.top);
            padding.bottom = MAX(padding.bottom, childPadding.bottom);
        }
    }
    _padding = padding;
    _hasPadding = hasPadding;
    _paddingComputed = TRUE;
}

- (UIEdgeInsets)padding {
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    return _padding;
}

- (BOOL)hasPadding {
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    return _hasPadding;
}

@end

@interface IDLDrawableContainer ()

@property (nonatomic, retain) IDLDrawableContainerConstantState *internalConstantState;
@property (nonatomic, retain) IDLDrawable *currentDrawable;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation IDLDrawableContainer

@synthesize currentDrawable = _currentDrawable;

- (void)dealloc {
    self.internalConstantState = nil;
    self.currentDrawable = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.currentIndex = -1;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    [self.currentDrawable drawInContext:context];
}

- (BOOL)selectDrawableAtIndex:(NSInteger)index {
    BOOL ret = TRUE;
    IDLDrawableContainerConstantState *state = self.internalConstantState;
    if (index == self.currentIndex) {
        ret = FALSE;
    } else if (index >= 0 && index < [state.drawables count]) {
        IDLDrawable *drawable = [state.drawables objectAtIndex:index];
        self.currentDrawable = drawable;
        self.currentIndex = index;
        drawable.state = self.state;
        drawable.bounds = self.bounds;
        [drawable setLevel:self.level];
    } else {
        self.currentDrawable = nil;
        self.currentIndex = -1;
    }
    if (ret) [self invalidateSelf];
    return ret;
}

- (CGSize)intrinsicSize {
    CGSize ret = CGSizeZero;
    IDLDrawableContainerConstantState *state = self.internalConstantState;
    if (state.isConstantSize) {
        ret = state.constantIntrinsicSize;
    } else {
        ret = self.currentDrawable.intrinsicSize;
    }
    return ret;
}

- (CGSize)minimumSize {
    CGSize ret = CGSizeZero;
    IDLDrawableContainerConstantState *state = self.internalConstantState;
    if (state.isConstantSize) {
        ret = state.constantMinimumSize;
    } else {
        ret = self.currentDrawable.minimumSize;
    }
    return ret;
}

- (void)onStateChangeToState:(UIControlState)state {
    [super onStateChangeToState:state];
    [self.currentDrawable setState:self.state];
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    self.currentDrawable.bounds = bounds;
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    BOOL ret = FALSE;
    if (_currentDrawable != nil) {
        ret = [_currentDrawable setLevel:level];
    }
    return ret;
}

- (BOOL)isStateful {
    return self.internalConstantState.isStateful;
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.padding;
}

- (BOOL)hasPadding {
    return self.internalConstantState.hasPadding;
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (IDLDrawable *)currentDrawable {
    return _currentDrawable;
}

#pragma mark - IDLDrawableDelegate

- (void)drawableDidInvalidate:(IDLDrawable *)drawable {
    if (drawable == _currentDrawable) {
        [self.delegate drawableDidInvalidate:self];
    }
}

@end
