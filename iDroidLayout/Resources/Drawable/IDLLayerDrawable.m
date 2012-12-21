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

@property (nonatomic, retain) IDLDrawable *drawable;
@property (nonatomic, assign) UIEdgeInsets insets;

@end

@implementation IDLLayerDrawableItem

@end

@interface IDLLayerDrawable ()

@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic, assign, getter = isPaddingComputed) BOOL paddingComputed;
@property (nonatomic, assign) UIEdgeInsets computedPadding;
@property (nonatomic, assign) BOOL internalHasPadding;


@end

@implementation IDLLayerDrawable

- (void)dealloc {
    self.items = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        self.items = items;
        [items release];
    }
    return self;
}

- (void)addLayer:(IDLDrawable *)drawable insets:(UIEdgeInsets)insets {
    IDLLayerDrawableItem *item = [[IDLLayerDrawableItem alloc] init];
    item.drawable = drawable;
    item.insets = insets;
    [self.items addObject:item];
    [item release];
}

- (void)onStateChanged {
    [super onStateChanged];
    for (IDLLayerDrawableItem *item in self.items) {
        item.drawable.state = self.state;
    }
}

- (void)drawOnLayer:(CALayer *)layer {
    for (IDLLayerDrawableItem *item in self.items) {
        CALayer *sublayer = [[CALayer alloc] init];
        sublayer.frame = UIEdgeInsetsInsetRect(layer.bounds, item.insets);
        [item.drawable drawOnLayer:sublayer];
        [layer addSublayer:sublayer];
        [sublayer release];
    }
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
            insets.left = [[attrs objectForKey:@"left"] floatValue];
            insets.top = [[attrs objectForKey:@"top"] floatValue];
            insets.right = [[attrs objectForKey:@"right"] floatValue];
            insets.bottom = [[attrs objectForKey:@"bottom"] floatValue];
            
            NSString *drawableResId = [attrs objectForKey:@"drawable"];
            IDLDrawable *drawable = nil;
            if (drawableResId != nil) {
                drawable = [[IDLResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
            } else if (child->firstChild != NULL) {
                drawable = [IDLDrawable createFromXMLElement:child->firstChild];
            } else {
                NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
            }
            if (drawable != nil) {
                [self addLayer:drawable insets:insets];
            }
        }
        child = child->nextSibling;
    }
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
