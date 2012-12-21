//
//  IDLStateListDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLStateListDrawable.h"
#import "IDLDrawableContainer+IDL_Internal.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "IDLResourceManager.h"
#import "UIView+IDL_Layout.h"

@interface IDLStateListDrawableItem : NSObject

@property (nonatomic, assign) UIControlState state;
@property (nonatomic, retain) IDLDrawable *drawable;

@end

@implementation IDLStateListDrawableItem

@end

@interface IDLStateListDrawable ()

@property (nonatomic, retain) NSMutableArray *items;

@end

@implementation IDLStateListDrawable

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

- (void)addDrawable:(IDLDrawable *)drawable forState:(UIControlState)state {
    IDLStateListDrawableItem *item = [[IDLStateListDrawableItem alloc] init];
    item.drawable = drawable;
    item.state = state;
    [self.items addObject:item];
    [item release];
    [self addChildDrawable:drawable];
    [self onStateChanged];
}

- (NSInteger)indexOfState:(UIControlState)state {
    NSInteger ret = -1;
    NSInteger count = [self.items count];
    for (NSInteger i = 0; i < count; i++) {
        IDLStateListDrawableItem *item = [self.items objectAtIndex:i];
        if ((item.state & state) == item.state) {
            ret = i;
            break;
        }
    }
    return ret;
}
- (void)onStateChanged {
    NSInteger idx = [self indexOfState:self.state];
    if (idx < 0) {
        idx = 0;
    }
    if (![self selectDrawableAtIndex:idx]) {
        [super onStateChanged];
    }
}

- (BOOL)isStateful {
    return TRUE;
}

- (UIControlState)controlStateForAttribute:(NSString *)attributeName {
    UIControlState controlState = UIControlStateNormal;
    if ([attributeName isEqualToString:@"state_disabled"]) {
        controlState |= UIControlStateDisabled;
    } else if ([attributeName isEqualToString:@"state_highlighted"] || [attributeName isEqualToString:@"state_pressed"] || [attributeName isEqualToString:@"state_focused"]) {
        controlState |= UIControlStateHighlighted;
    } else if ([attributeName isEqualToString:@"state_selected"]) {
        controlState |= UIControlStateSelected;
    }
    return controlState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    
    
    self.constantSize = BOOLFromString([attrs objectForKey:@"constantSize"]);
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *tagName = [TBXML elementName:child];
        if ([tagName isEqualToString:@"item"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIControlState state = UIControlStateNormal;
            for (NSString *attrName in [attrs allKeys]) {
                BOOL value = BOOLFromString([attrs objectForKey:attrName]);
                if (value) {
                    state |= [self controlStateForAttribute:attrName];
                }
            }
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
                [self addDrawable:drawable forState:state];
            }
        }
        child = child->nextSibling;
    }
    
    
}

@end
