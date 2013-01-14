//
//  IDLRotateDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 13.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLRotateDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "NSDictionary+IDL_ResourceManager.h"

@interface IDLRotateDrawableConstantState ()

@property (nonatomic, retain) IDLDrawable *drawable;
@property (nonatomic, assign) CGPoint pivot;
@property (nonatomic, assign) BOOL pivotXRelative;
@property (nonatomic, assign) BOOL pivotYRelative;
@property (nonatomic, assign) CGFloat fromDegrees;
@property (nonatomic, assign) CGFloat toDegrees;
@property (nonatomic, assign) CGFloat currentDegrees;

@end

@implementation IDLRotateDrawableConstantState

- (void)dealloc {
    self.drawable.delegate = nil;
    self.drawable = nil;
    [super dealloc];
}

- (id)initWithState:(IDLRotateDrawableConstantState *)state owner:(IDLRotateDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            IDLDrawable *copiedDrawable = [state.drawable copy];
            copiedDrawable.delegate = owner;
            self.drawable = copiedDrawable;
            [copiedDrawable release];
            
            self.pivot = state.pivot;
            self.pivotXRelative = state.pivotXRelative;
            self.pivotYRelative = state.pivotYRelative;
            
            self.fromDegrees = self.currentDegrees = state.fromDegrees;
            self.toDegrees = state.toDegrees;
        } else {
            
        }
    }
    return self;
}

@end

@interface IDLRotateDrawable ()

@property (nonatomic, retain) IDLRotateDrawableConstantState *internalConstantState;

@end

@implementation IDLRotateDrawable

- (void)dealloc {
    self.internalConstantState = nil;
    [super dealloc];
}

- (id)initWithState:(IDLRotateDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLRotateDrawableConstantState *s = [[IDLRotateDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
        [s release];
    }
    return self;
}

- (id)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    IDLRotateDrawableConstantState *state = self.internalConstantState;
    CGRect bounds = self.bounds;
    
    // Calculate pivot point
    CGFloat px = state.pivotXRelative ? (bounds.size.width * state.pivot.x) : state.pivot.x;
    CGFloat py = state.pivotYRelative ? (bounds.size.height * state.pivot.y) : state.pivot.y;
    
    // Save context state
    CGContextSaveGState(context);
    
    // Rotate
    CGContextTranslateCTM(context, px, py);
    CGContextRotateCTM(context, state.currentDegrees*M_PI/180.f);
    CGContextTranslateCTM(context, -px, -py);
    
    // Draw child
    [state.drawable drawInContext:context];
    
    // Restore context state
    CGContextRestoreGState(context);
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    IDLRotateDrawableConstantState *state = self.internalConstantState;
    
    NSDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    
    CGPoint pivot = CGPointMake(0.5f, 0.5f);
    BOOL pivotXRelative = TRUE;
    BOOL pivotYRelative = TRUE;
    if ([attrs isFractionIDLValueForKey:@"pivotX"]) {
        pivot.x = [attrs fractionValueFromIDLValueForKey:@"pivotX"];
    } else if ([attrs objectForKey:@"pivotX"] != nil) {
        pivot.x = [attrs dimensionFromIDLValueForKey:@"pivotX" defaultValue:0.5f];
        pivotXRelative = FALSE;
    }
    if ([attrs isFractionIDLValueForKey:@"pivotY"]) {
        pivot.y = [attrs fractionValueFromIDLValueForKey:@"pivotY"];
    } else if ([attrs objectForKey:@"pivotY"] != nil) {
        pivot.y = [attrs dimensionFromIDLValueForKey:@"pivotY" defaultValue:0.5f];
        pivotYRelative = FALSE;
    }
    state.pivot = pivot;
    state.pivotXRelative = pivotXRelative;
    state.pivotYRelative = pivotYRelative;
    
    CGFloat fromDegrees = [attrs dimensionFromIDLValueForKey:@"fromDegrees" defaultValue:0.f];
    CGFloat toDegrees = [attrs dimensionFromIDLValueForKey:@"toDegrees" defaultValue:360.f];
    
    toDegrees = MAX(fromDegrees, toDegrees);
    state.fromDegrees = state.currentDegrees = fromDegrees;
    state.toDegrees = toDegrees;
    
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
    IDLRotateDrawableConstantState *state = self.internalConstantState;
    [state.drawable setLevel:level];
    state.currentDegrees = state.fromDegrees + (state.toDegrees - state.fromDegrees) * ((CGFloat)level / IDLDrawableMaxLevel);
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
