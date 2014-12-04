//
//  IDLShadowDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 15.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLShadowDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "NSDictionary+IDL_ResourceManager.h"

@interface IDLShadowDrawableConstantState ()

@property (nonatomic, strong) IDLDrawable *drawable;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGSize offset;
@property (nonatomic, assign) CGFloat blur;
@property (nonatomic, strong) UIColor *shadowColor;

@end

@implementation IDLShadowDrawableConstantState

- (void)dealloc {
    self.drawable.delegate = nil;
}

- (instancetype)initWithState:(IDLShadowDrawableConstantState *)state owner:(IDLShadowDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            IDLDrawable *copiedDrawable = [state.drawable copy];
            copiedDrawable.delegate = owner;
            self.drawable = copiedDrawable;
            
            self.alpha = state.alpha;
            self.blur = state.blur;
            self.offset = state.offset;
            self.shadowColor = state.shadowColor;
        } else {
            self.alpha = 1.f;
            
        }
    }
    return self;
}

@end

@interface IDLShadowDrawable ()

@property (nonatomic, strong) IDLShadowDrawableConstantState *internalConstantState;

@end

@implementation IDLShadowDrawable


- (instancetype)initWithState:(IDLShadowDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLShadowDrawableConstantState *s = [[IDLShadowDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    IDLShadowDrawableConstantState *state = self.internalConstantState;
    
    CGContextSetAlpha(context, state.alpha);
    if (state.shadowColor != nil) {
        CGContextSetShadowWithColor(context, state.offset, state.blur, state.shadowColor.CGColor);
    } else if (state.blur > 0 || !CGSizeEqualToSize(CGSizeZero, state.offset)) {
        CGContextSetShadow(context, state.offset, state.blur);
    }
    CGContextBeginTransparencyLayerWithRect(context, self.bounds, NULL);
    // Draw child
    [state.drawable drawInContext:context];
    CGContextEndTransparencyLayer(context);
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    IDLShadowDrawableConstantState *state = self.internalConstantState;
    
    NSDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    
    state.alpha = [attrs fractionValueFromIDLValueForKey:@"alpha" defaultValue:1];
    CGSize offset = CGSizeMake(0, 0);
    offset.width = [attrs dimensionFromIDLValueForKey:@"shadowHorizontalOffset" defaultValue:0];
    offset.height = [attrs dimensionFromIDLValueForKey:@"shadowVerticalOffset" defaultValue:0];
    state.offset = offset;
    
    state.blur = ABS([attrs dimensionFromIDLValueForKey:@"blur" defaultValue:0]);
    state.shadowColor = [attrs colorFromIDLValueForKey:@"shadowColor"];
    
    NSString *drawableResId = attrs[@"drawable"];
    IDLDrawable *drawable = nil;
    if (drawableResId != nil) {
        drawable = [[IDLResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
    } else if (element->firstChild != NULL) {
        drawable = [IDLDrawable createFromXMLElement:element->firstChild];
    } else {
        NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
    }
    if (drawable != nil) {
        drawable.delegate = self;
        drawable.state = self.state;
        state.drawable = drawable;
    }
    
}

- (void)onStateChangeToState:(UIControlState)state {
    [self.internalConstantState.drawable setState:state];
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    return [self.internalConstantState.drawable setLevel:level];
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    IDLShadowDrawableConstantState *state = self.internalConstantState;
    if (state.offset.width > 0) {
        bounds.size.width -= state.offset.width;
    } else if (state.offset.width < 0) {
        bounds.origin.x -= state.offset.width;
        bounds.size.width += state.offset.width;
    }
    
    if (state.offset.height > 0) {
        bounds.size.height -= state.offset.height;
    } else if (state.offset.width < 0) {
        bounds.origin.y -= state.offset.width;
        bounds.size.height += state.offset.height;
    }
    
    self.internalConstantState.drawable.bounds = bounds;
}

- (BOOL)isStateful {
    return self.internalConstantState.drawable.isStateful;
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.drawable.padding;
}

- (BOOL)hasPadding {
    return self.internalConstantState.drawable.hasPadding;
}

#pragma mark - IDLDrawableDelegate

- (void)drawableDidInvalidate:(IDLDrawable *)drawable {
    [self.delegate drawableDidInvalidate:self];
}

@end
