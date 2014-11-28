//
//  IDLClipDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 07.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLClipDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "IDLGravity.h"

IDLClipDrawableOrientation IDLClipDrawableOrientationFromString(NSString *string) {
    IDLClipDrawableOrientation ret = IDLClipDrawableOrientationHorizontal;
    if ([string isEqualToString:@"vertical"]) {
        ret = IDLClipDrawableOrientationVertical;
    }
    return ret;
}

@interface IDLClipDrawableConstantState ()

@property (nonatomic, strong) IDLDrawable *drawable;
@property (nonatomic, assign) IDLClipDrawableOrientation orientation;
@property (nonatomic, assign) IDLViewContentGravity gravity;

@end

@implementation IDLClipDrawableConstantState

- (void)dealloc {
    self.drawable.delegate = nil;
}

- (instancetype)initWithState:(IDLClipDrawableConstantState *)state owner:(IDLClipDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            IDLDrawable *copiedDrawable = [state.drawable copy];
            copiedDrawable.delegate = owner;
            self.drawable = copiedDrawable;
            
            self.orientation = state.orientation;
            self.gravity = state.gravity;
        } else {
            self.gravity = IDLViewContentGravityLeft;
        }
    }
    return self;
}

@end

@interface IDLClipDrawable ()

@property (nonatomic, strong) IDLClipDrawableConstantState *internalConstantState;

@end

@implementation IDLClipDrawable


- (instancetype)initWithState:(IDLClipDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLClipDrawableConstantState *s = [[IDLClipDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (id)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    NSUInteger level = self.level;
    if (level > 0) {
        IDLClipDrawableConstantState *state = self.internalConstantState;
        IDLClipDrawableOrientation orientation = state.orientation;
        CGRect r = CGRectZero;
        CGRect bounds = self.bounds;
        CGFloat w = bounds.size.width;
        CGFloat iw = 0; //mClipState.mDrawable.getIntrinsicWidth();
        if ((orientation & IDLClipDrawableOrientationHorizontal) != 0) {
            w -= (w - iw) * (10000 - level) / 10000;
        }
        int h = bounds.size.height;
        CGFloat ih = 0; //mClipState.mDrawable.getIntrinsicHeight();
        if ((orientation & IDLClipDrawableOrientationVertical) != 0) {
            h -= (h - ih) * (10000 - level) / 10000;
        }
        [IDLGravity applyGravity:state.gravity width:w height:h containerRect:&bounds outRect:&r];
        if (w > 0 && h > 0) {
            CGContextSaveGState(context);
            CGContextClipToRect(context, r);
            [state.drawable drawInContext:context];
            CGContextRestoreGState(context);
        }
    }
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    IDLClipDrawableConstantState *state = self.internalConstantState;
    
    NSDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    NSString *orientationString = [attrs objectForKey:@"clipOrientation"];
    state.orientation = IDLClipDrawableOrientationFromString(orientationString);
    
    NSString *gravityString = [attrs objectForKey:@"gravity"];
    if (gravityString != nil) {
        state.gravity = [IDLGravity gravityFromAttribute:gravityString];
    }
    
    NSString *drawableResId = [attrs objectForKey:@"drawable"];
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
    [self.internalConstantState.drawable setLevel:level];
    [self invalidateSelf];
    return TRUE;
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
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
