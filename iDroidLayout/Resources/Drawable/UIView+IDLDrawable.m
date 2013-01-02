//
//  UIView+IDLDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIView+IDLDrawable.h"
#import "UIView+IDL_Layout.h"
#import "NSObject+IDL_KVOObserver.h"
#import "IDLDrawableLayer.h"
#include <objc/runtime.h>

@interface IDLBackgroundDrawableLayer : CALayer

@end

@implementation IDLBackgroundDrawableLayer

@end

@interface UIView ()

@property (nonatomic, readonly) NSMutableDictionary *observerHacks;

@end

@implementation UIView (IDLDrawable)

static char backgroundDrawableKey;

- (void)setBackgroundDrawable:(IDLDrawable *)backgroundDrawable {
    objc_setAssociatedObject(self,
                             &backgroundDrawableKey,
                             backgroundDrawable,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (backgroundDrawable.hasPadding) {
        self.padding = backgroundDrawable.padding;
    }
    [self onBackgroundDrawableChanged];
}

- (IDLDrawable *)backgroundDrawable {
    return objc_getAssociatedObject(self, &backgroundDrawableKey);
}

- (void)onBackgroundDrawableChanged {
    IDLDrawableLayer *existingBackgroundLayer = nil;
    CALayer *layer = self.layer;
    for (CALayer *sublayer in layer.sublayers) {
        if ([sublayer isKindOfClass:[IDLDrawableLayer class]]) {
            existingBackgroundLayer = (IDLDrawableLayer *)sublayer;
            break;
        }
    }
    IDLDrawable *drawable = self.backgroundDrawable;
    drawable.bounds = self.bounds;
    static NSString *BackgroundDrawableFrameTag = @"backgroundDrawableFrame";
    static NSString *BackgroundDrawableStateTag = @"backgroundDrawableState";
    if (drawable != nil) {
        if ([self isKindOfClass:[UIControl class]]) {
            UIControl *control = (UIControl *)self;
            drawable.state = control.state;
        } else {
            drawable.state = UIControlStateNormal;
        }
        if (existingBackgroundLayer == nil) {
            existingBackgroundLayer = [[IDLDrawableLayer alloc] init];
            [self.layer insertSublayer:existingBackgroundLayer atIndex:0];
            [existingBackgroundLayer release];
        }
        existingBackgroundLayer.drawable = drawable;
        existingBackgroundLayer.frame = self.bounds;
        [existingBackgroundLayer setNeedsDisplay];
        
        if (![self idl_hasObserverWithIdentifier:BackgroundDrawableFrameTag]) {
            __block UIView *selfRef = self;
            __block IDLDrawableLayer *layer = existingBackgroundLayer;
            [self idl_addObserver:^(NSString *keyPath, id object, NSDictionary *change) {
                layer.frame = self.bounds;
            } withIdentifier:BackgroundDrawableFrameTag forKeyPaths:@[@"frame"] options:NSKeyValueObservingOptionNew];
            
            if ([self isKindOfClass:[UIControl class]] && ![self idl_hasObserverWithIdentifier:BackgroundDrawableStateTag]) {
                [self idl_addObserver:^(NSString *keyPath, id object, NSDictionary *change) {
                    selfRef.backgroundDrawable.state = ((UIControl *)selfRef).state;
                } withIdentifier:BackgroundDrawableStateTag forKeyPaths:@[@"highlighted", @"enabled", @"selected"] options:NSKeyValueObservingOptionNew];
            }
        }
    } else {
        [self idl_removeObserverWithIdentifier:BackgroundDrawableFrameTag];
        [self idl_removeObserverWithIdentifier:BackgroundDrawableStateTag];
        [existingBackgroundLayer removeFromSuperlayer];
    }
}

@end
