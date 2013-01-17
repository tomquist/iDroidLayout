//
//  IDLDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 16.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"
#import "IDLXMLCache.h"
#import "IDLStateListDrawable.h"
#import "IDLLayerDrawable.h"
#import "IDLColorDrawable.h"
#import "IDLInsetDrawable.h"
#import "IDLBitmapDrawable.h"
#import "IDLNinePatchDrawable.h"
#import "IDLGradientDrawable.h"
#import "IDLClipDrawable.h"
#import "IDLRotateDrawable.h"
#import "IDLShadowDrawable.h"
#import "IDLDrawable+IDL_Internal.h"

NSUInteger const IDLDrawableMaxLevel = 10000;

@implementation IDLDrawableConstantState

@end

@interface IDLDrawable ()

@property (nonatomic, assign) BOOL stateInitialized;

@end

@implementation IDLDrawable

- (id)initWithState:(IDLDrawableConstantState *)state {
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)onStateChangeToState:(UIControlState)state {
    
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    return FALSE;
}

- (CGSize)intrinsicSize {
    return CGSizeMake(-1, -1);
}

- (CGSize)minimumSize {
    CGSize size = self.intrinsicSize;
    size.width = MAX(size.width, 0);
    size.height = MAX(size.height, 0);
    return size;
}

- (void)drawInContext:(CGContextRef)context {
    OUTLINE_RECT(context, self.bounds);
}

#if OUTLINE_DRAWABLE
- (void)outlineRect:(CGRect)rect inContext:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetLineWidth(context, 1);
/*    CGFloat lengths[] = {5.f};
    CGContextSetLineDash(context, 1.f, lengths, 1);*/
    CGContextStrokeRect(context, rect);
    CGContextRestoreGState(context);
}
#endif

- (BOOL)isStateful {
    return FALSE;
}

- (void)invalidateSelf {
    [self.delegate drawableDidInvalidate:self];
}

- (UIImage *)renderToImage {
    UIGraphicsBeginImageContext(_bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    
}

- (BOOL)hasPadding {
    return FALSE;
}

- (UIEdgeInsets)padding {
    return UIEdgeInsetsZero;
}

- (void)setBounds:(CGRect)bounds {
    if (!CGRectEqualToRect(_bounds, bounds)) {
        _bounds = bounds;
        [self onBoundsChangeToRect:bounds];
    }
}

- (void)setState:(UIControlState)state {
    if (_state != state || !_stateInitialized) {
        _stateInitialized = TRUE;
        _state = state;
        [self onStateChangeToState:state];
    }
}

- (BOOL)setLevel:(NSUInteger)level {
    BOOL ret = FALSE;
    if (_level != level) {
        _level = level;
        ret = [self onLevelChangeToLevel:level];
    }
    return ret;
}

+ (IDLDrawable *)createFromXMLElement:(TBXMLElement *)element {
    IDLDrawable *drawable = nil;
    NSString *tagName = [TBXML elementName:element];
    Class drawableClass = NULL;
    if ([tagName isEqualToString:@"selector"]) {
        drawableClass = [IDLStateListDrawable class];
    } else if ([tagName isEqualToString:@"layer-list"]) {
        drawableClass = [IDLLayerDrawable class];
    } else if ([tagName isEqualToString:@"color"]) {
        drawableClass = [IDLColorDrawable class];
    } else if ([tagName isEqualToString:@"bitmap"]) {
        drawableClass = [IDLBitmapDrawable class];
    } else if ([tagName isEqualToString:@"inset"]) {
        drawableClass = [IDLInsetDrawable class];
    } else if ([tagName isEqualToString:@"nine-patch"]) {
        drawableClass = [IDLNinePatchDrawable class];
    } else if ([tagName isEqualToString:@"shape"]) {
        drawableClass = [IDLGradientDrawable class];
    } else if ([tagName isEqualToString:@"clip"]) {
        drawableClass = [IDLClipDrawable class];
    } else if ([tagName isEqualToString:@"rotate"]) {
        drawableClass = [IDLRotateDrawable class];
    } else if ([tagName isEqualToString:@"shadow"]) {
        drawableClass = [IDLShadowDrawable class];
    } else {
        drawableClass = NSClassFromString(tagName);
    }
    if (drawableClass != NULL && [drawableClass isSubclassOfClass:[IDLDrawable class]]) {
        drawable = [[drawableClass alloc] init];
        [drawable inflateWithElement:element];
    }
    return [drawable autorelease];
}

+ (IDLDrawable *)createFromXMLData:(NSData *)data {
    if (data == nil) return nil;
    IDLDrawable *ret = nil;
    NSError *error = nil;
    TBXML *xml = [[TBXML newTBXMLWithXMLData:data error:&error] autorelease];
    if (error == nil) {
        ret = [self createFromXMLElement:xml.rootXMLElement];
    } else {
        NSLog(@"Could not parse drawable: %@", error);
    }
    return ret;
}

+ (IDLDrawable *)createFromXMLURL:(NSURL *)url {
    NSError *error = nil;
    TBXML *xml = [[IDLXMLCache sharedInstance] xmlForUrl:url error:&error];
    IDLDrawable *ret = nil;
    if (xml == nil || error != nil) {
        NSLog(@"Could not parse drawable %@: %@", [url absoluteString], error);
    } else {
        ret = [self createFromXMLElement:xml.rootXMLElement];
    }
    return ret;
}

- (IDLDrawableConstantState *)constantState {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    IDLDrawableConstantState *state = self.constantState;
    if (state != nil) {
        return [[[self class] allocWithZone:zone] initWithState:state];
    } else {
        return nil;
    }
}

- (IDLDrawable *)currentDrawable {
    return self;
}

@end
