//
//  IDLDrawableContainer.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableContainer.h"

@interface IDLDrawableContainer ()

@property (nonatomic, retain) IDLDrawable *currentDrawable;
@property (nonatomic, retain) NSMutableArray *drawables;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGSize constantIntrinsicSize;
@property (nonatomic, assign) CGSize constantMinimumSize;
@property (nonatomic, assign, getter = isConstantSizeComputed) BOOL constantSizeComputed;
@property (nonatomic, assign) BOOL haveStateful;
@property (nonatomic, assign) BOOL internalStateful;
@property (nonatomic, assign, getter = isPaddingComputed) BOOL paddingComputed;
@property (nonatomic, assign) UIEdgeInsets computedPadding;
@property (nonatomic, assign) BOOL internalHasPadding;
@end

@implementation IDLDrawableContainer

@synthesize drawables = _drawables;
@synthesize currentIndex = _currentIndex;
@synthesize currentDrawable = _currentDrawable;
@synthesize constantSize = _constantSize;


- (void)dealloc {
    self.drawables = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        NSMutableArray *drawables = [[NSMutableArray alloc] init];
        self.drawables = drawables;
        self.currentIndex = -1;
        [drawables release];
    }
    return self;
}

- (void)addChildDrawable:(IDLDrawable *)drawable {
    [self.drawables addObject:drawable];
    drawable.state = self.state;
    [self invalidate];
}

- (void)drawOnLayer:(CALayer *)layer {
    [self.currentDrawable drawOnLayer:layer];
}

- (BOOL)selectDrawableAtIndex:(NSInteger)index {
    BOOL ret = TRUE;
    if (index == self.currentIndex) {
        ret = FALSE;
    } else if (index >= 0 && index < [self.drawables count]) {
        IDLDrawable *drawable = [self.drawables objectAtIndex:index];
        self.currentDrawable = drawable;
        self.currentIndex = index;
        self.currentDrawable.state = self.state;
    } else {
        self.currentDrawable = nil;
        self.currentIndex = -1;
    }
    return ret;
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

- (CGSize)intrinsicSize {
    CGSize ret = CGSizeZero;
    if (self.isConstantSize) {
        if (!self.isConstantSizeComputed) {
            [self computeConstantSize];
        }
        ret = self.constantIntrinsicSize;
    } else {
        ret = self.currentDrawable.intrinsicSize;
    }
    return ret;
}

- (CGSize)minimumSize {
    CGSize ret = CGSizeZero;
    if (self.isConstantSize) {
        if (!self.isConstantSizeComputed) {
            [self computeConstantSize];
        }
        ret = self.constantMinimumSize;
    } else {
        ret = self.currentDrawable.minimumSize;
    }
    return ret;
}

- (void)invalidate {
    self.haveStateful = FALSE;
    self.constantSizeComputed = FALSE;
    self.paddingComputed = FALSE;
}

- (void)onStateChanged {
    [super onStateChanged];
    [self.currentDrawable setState:self.state];
}

- (BOOL)isStateful {
    if (self.haveStateful) {
        return self.internalStateful;
    }
    BOOL stateful = FALSE;
    for (IDLDrawable *child in self.drawables) {
        if (child.isStateful) {
            stateful = TRUE;
            break;
        }
    }
    self.internalStateful = stateful;
    self.haveStateful = TRUE;
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
    self.computedPadding = padding;
    self.internalHasPadding = hasPadding;
    self.paddingComputed = TRUE;
}

- (UIEdgeInsets)padding {
    UIEdgeInsets padding = UIEdgeInsetsZero;
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    padding = self.computedPadding;
    return padding;
}

- (BOOL)hasPadding {
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    return self.internalHasPadding;
}

@end
