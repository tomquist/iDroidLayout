//
//  IDLDrawable+IDL_Internal.h
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <iDroidLayout/iDroidLayout.h>
#import "TBXML.h"

#if OUTLINE_DRAWABLE
#define OUTLINE_RECT(context, rect) [self outlineRect:rect inContext:context]
#else
#define OUTLINE_RECT(context, rect) 
#endif

@interface IDLDrawable (IDL_Internal)

- (id)initWithState:(IDLDrawableConstantState *)state;

- (void)inflateWithElement:(TBXMLElement *)element;
+ (IDLDrawable *)createFromXMLElement:(TBXMLElement *)element;
- (void)outlineRect:(CGRect)rect inContext:(CGContextRef)context;
- (void)onBoundsChangeToRect:(CGRect)bounds;
- (void)onStateChangeToState:(UIControlState)state;
- (BOOL)onLevelChangeToLevel:(NSUInteger)level;
- (void)invalidateSelf;

@end
