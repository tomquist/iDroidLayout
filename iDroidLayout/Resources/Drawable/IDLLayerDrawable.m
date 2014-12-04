//
//  IDLLayerDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayerDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "IDLResourceManager.h"
#import "TBXML+IDL.h"

@interface IDLLayerDrawableItem : NSObject

@property (nonatomic, strong) IDLDrawable *drawable;
@property (nonatomic, assign) UIEdgeInsets insets;

@end

@implementation IDLLayerDrawableItem


@end

@interface IDLLayerDrawableConstantState ()

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign, getter = isPaddingComputed) BOOL paddingComputed;
@property (nonatomic, assign) BOOL hasPadding;
@property (nonatomic, assign) UIEdgeInsets padding;

@end

@implementation IDLLayerDrawableConstantState

- (void)dealloc {
    for (IDLLayerDrawableItem *item in self.items) {
        item.drawable.delegate = nil;
    }
}

- (instancetype)initWithState:(IDLLayerDrawableConstantState *)state owner:(IDLLayerDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[state.items count]];
            for (IDLLayerDrawableItem *origItem in state.items) {
                IDLLayerDrawableItem *item = [[IDLLayerDrawableItem alloc] init];
                IDLDrawable *drawable = [origItem.drawable copy];
                drawable.delegate = owner;
                item.drawable = drawable;
                item.insets = origItem.insets;
                [items addObject:item];
            }
            self.items = items;

        } else {
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:10];
            self.items = items;

        }
    }
    return self;
}

- (void)addLayer:(IDLDrawable *)drawable insets:(UIEdgeInsets)insets owner:(IDLLayerDrawable *)owner {
    IDLLayerDrawableItem *item = [[IDLLayerDrawableItem alloc] init];
    item.drawable = drawable;
    item.insets = insets;
    [self.items addObject:item];
    _paddingComputed = FALSE;
}

- (void)computePadding {
    UIEdgeInsets padding = UIEdgeInsetsZero;
    BOOL hasPadding = FALSE;
    for (IDLLayerDrawableItem *item in self.items) {
        IDLDrawable *drawable = item.drawable;
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
    UIEdgeInsets padding = UIEdgeInsetsZero;
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    padding = _padding;
    return padding;
}

- (BOOL)hasPadding {
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    return _hasPadding;
}


@end

@interface IDLLayerDrawable ()

@property (nonatomic, strong) IDLLayerDrawableConstantState *internalConstantState;

@end

@implementation IDLLayerDrawable


- (instancetype)initWithState:(IDLLayerDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLLayerDrawableConstantState *s = [[IDLLayerDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)onStateChangeToState:(UIControlState)state {
    [super onStateChangeToState:state];
    for (IDLLayerDrawableItem *item in self.internalConstantState.items) {
        item.drawable.state = self.state;
    }
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    [super onBoundsChangeToRect:bounds];
    for (IDLLayerDrawableItem *item in self.internalConstantState.items) {
        CGRect insetRect = UIEdgeInsetsInsetRect(bounds, item.insets);
        item.drawable.bounds = insetRect;
    }
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    IDLLayerDrawableConstantState *state = self.internalConstantState;
    BOOL changed = FALSE;
    for (IDLLayerDrawableItem *item in state.items) {
        if ([item.drawable setLevel:level]) {
            changed = TRUE;
        }
    }
    return changed;
}

- (void)drawInContext:(CGContextRef)context {
    for (IDLLayerDrawableItem *item in self.internalConstantState.items) {
        CGContextSaveGState(context);
        [item.drawable drawInContext:context];
        CGContextRestoreGState(context);
    }
    OUTLINE_RECT(context, self.bounds);
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = nil;
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *tagName = [TBXML elementName:child];
        if ([tagName isEqualToString:@"item"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            
            UIEdgeInsets insets = UIEdgeInsetsZero;
            insets.left = [attrs[@"left"] floatValue];
            insets.top = [attrs[@"top"] floatValue];
            insets.right = [attrs[@"right"] floatValue];
            insets.bottom = [attrs[@"bottom"] floatValue];
            
            NSString *drawableResId = attrs[@"drawable"];
            IDLDrawable *drawable = nil;
            if (drawableResId != nil) {
                drawable = [[IDLResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
            } else if (child->firstChild != NULL) {
                drawable = [IDLDrawable createFromXMLElement:child->firstChild];
            } else {
                NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
            }
            if (drawable != nil) {
                [self.internalConstantState addLayer:drawable insets:insets owner:self];
            }
        }
        child = child->nextSibling;
    }
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

- (CGSize)intrinsicSize {
    CGSize size = CGSizeMake(-1, -1);
    for (IDLLayerDrawableItem *item in self.internalConstantState.items) {
        UIEdgeInsets insets = item.insets;
        CGSize s = item.drawable.intrinsicSize;
        s.width += insets.left + insets.right;
        s.height += insets.top + insets.bottom;
        if (s.width > size.width) {
            size.width = s.width;
        }
        if (s.height > size.height) {
            size.height = s.height;
        }
    }
    return size;
}

#pragma mark - IDLDrawableDelegate

- (void)drawableDidInvalidate:(IDLDrawable *)drawable {
    [self.delegate drawableDidInvalidate:drawable];
}

@end
