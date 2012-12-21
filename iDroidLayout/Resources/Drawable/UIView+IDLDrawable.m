//
//  UIView+IDLDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIView+IDLDrawable.h"
#import "UIView+IDL_Layout.h"
#include <objc/runtime.h>

@interface IDLCategoryObserverHack : NSObject

@property (readwrite, retain) NSString *tag;
@property (readwrite, copy) void (^observerBlock)(NSDictionary *change);
@property (readwrite, assign) id object;
@property (readwrite, retain) NSArray *keyPaths;

- (id)initWithTag:(NSString *)tag object:(id)obj keyPaths:(NSArray *)keyPaths observerBlock:(void (^)(NSDictionary *change))block;

@end

@implementation IDLCategoryObserverHack
@synthesize tag = _tag;
@synthesize observerBlock = _observerBlock;
@synthesize keyPaths = _keyPaths;
@synthesize object = _object;

- (id)initWithTag:(NSString *)tag object:(id)obj keyPaths:(NSArray *)keyPaths observerBlock:(void (^)(NSDictionary *change))block {
    self = [super init];
    if (self) {
        self.tag = tag;
        self.object = obj;
        self.keyPaths = keyPaths;
        self.observerBlock = block;
        for (NSString *keyPath in keyPaths) {
            [obj addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];            
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.observerBlock(change);
}

- (void)dealloc {
    for (NSString *keyPath in self.keyPaths) {
        [self.object removeObserver:self forKeyPath:keyPath];
    }
    [super dealloc];
}
@end

@interface IDLBackgroundDrawableLayer : CALayer

@end

@implementation IDLBackgroundDrawableLayer

@end

@interface UIView ()

@property (nonatomic, readonly) NSMutableDictionary *observerHacks;

@end

@implementation UIView (IDLDrawable)

static char backgroundDrawableKey;
static char observerHacksKey;

- (NSMutableDictionary *)observerHacks {
    @synchronized(self) {
        NSMutableDictionary *array = objc_getAssociatedObject(self, &observerHacksKey);
        if (array == nil) {
            array = [[[NSMutableDictionary alloc] init] autorelease];
            objc_setAssociatedObject(self,
                                     &observerHacksKey,
                                     array,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return array;
    }
}

- (void)addObserverHack:(IDLCategoryObserverHack *)hack {
    NSMutableDictionary *observers = self.observerHacks;
    [observers setObject:hack forKey:hack.tag];
}

- (BOOL)hasObserverHackWithTag:(NSString *)tag {
    NSMutableDictionary *observers = self.observerHacks;
    return [observers objectForKey:tag] != nil;
}

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
    static NSString *TAG = @"backgroundDrawableFrame";
    if (![self hasObserverHackWithTag:TAG]) {
        __block id selfRef = self;
        IDLCategoryObserverHack *hack = [[IDLCategoryObserverHack alloc] initWithTag:TAG object:self keyPaths:@[@"frame"] observerBlock:^(NSDictionary *change) {
            [selfRef onBackgroundDrawableChanged];
        }];
        [self addObserverHack:hack];
        [hack release];
        
        if ([self isKindOfClass:[UIControl class]]) {
            IDLCategoryObserverHack *hack = [[IDLCategoryObserverHack alloc] initWithTag:@"backgroundDrawableState" object:self keyPaths:@[@"highlighted", @"enabled", @"selected"] observerBlock:^(NSDictionary *change) {
                [selfRef onBackgroundDrawableChanged];
            }];
            [self addObserverHack:hack];
            [hack release];
        }

    }
    
    IDLBackgroundDrawableLayer *existingBackgroundLayer = nil;
    for (CALayer *sublayer in self.layer.sublayers) {
        if ([sublayer isKindOfClass:[IDLBackgroundDrawableLayer class]]) {
            existingBackgroundLayer = (IDLBackgroundDrawableLayer *)sublayer;
            break;
        }
    }
    IDLDrawable *drawable = self.backgroundDrawable;
    if (drawable != nil) {
        if ([self isKindOfClass:[UIControl class]]) {
            UIControl *control = (UIControl *)self;
            drawable.state = control.state;
        }
        CALayer *layer = [IDLBackgroundDrawableLayer layer];
        layer.frame = self.bounds;
        [drawable drawOnLayer:layer];
        [self.layer insertSublayer:layer atIndex:0];
    }
    [existingBackgroundLayer removeFromSuperlayer];
}

@end
