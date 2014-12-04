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
@property (nonatomic, strong) IDLDrawable *drawable;

@end

@implementation IDLStateListDrawableItem


@end


@interface IDLStateListDrawableConstantState ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation IDLStateListDrawableConstantState


- (instancetype)initWithState:(IDLStateListDrawableConstantState *)state owner:(IDLStateListDrawable *)owner {
    self = [super initWithState:state owner:owner];
    if (self) {
        if (state != nil) {
            NSInteger count = MIN([self.drawables count], [state.items count]);
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:count];
            for (NSInteger i = 0; i<count; i++) {
                IDLStateListDrawableItem *origItem = (state.items)[i];
                IDLStateListDrawableItem *item = [[IDLStateListDrawableItem alloc] init];
                item.drawable = (self.drawables)[i];
                item.state = origItem.state;
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

- (void)addDrawable:(IDLDrawable *)drawable forState:(UIControlState)state {
    IDLStateListDrawableItem *item = [[IDLStateListDrawableItem alloc] init];
    item.drawable = drawable;
    item.state = state;
    [self.items addObject:item];
    [self addChildDrawable:drawable];
}

@end

@interface IDLStateListDrawable ()

@property (nonatomic, strong) IDLStateListDrawableConstantState *internalConstantState;

@end

@implementation IDLStateListDrawable


- (instancetype)initWithState:(IDLStateListDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLStateListDrawableConstantState *s = [[IDLStateListDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (instancetype)initWithColorStateListe:(IDLColorStateList *)colorStateList {
    self = [self init];
    if (self) {
        for (IDLColorStateItem *item in colorStateList.items) {
            IDLColorDrawable *colorDrawable = [[IDLColorDrawable alloc] initWithColor:item.color];
            [self.internalConstantState addDrawable:colorDrawable forState:item.controlState];
        }
    }
    return self;
}

- (NSInteger)indexOfState:(UIControlState)state {
    NSInteger ret = -1;
    NSInteger count = [self.internalConstantState.items count];
    for (NSInteger i = 0; i < count; i++) {
        IDLStateListDrawableItem *item = (self.internalConstantState.items)[i];
        if ((item.state & state) == item.state) {
            ret = i;
            break;
        }
    }
    return ret;
}
- (void)onStateChangeToState:(UIControlState)state {
    NSInteger idx = [self indexOfState:self.state];
    if (![self selectDrawableAtIndex:idx]) {
        [super onStateChangeToState:state];
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
    
    
    self.internalConstantState.constantSize = BOOLFromString(attrs[@"constantSize"]);
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *tagName = [TBXML elementName:child];
        if ([tagName isEqualToString:@"item"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIControlState state = UIControlStateNormal;
            for (NSString *attrName in [attrs allKeys]) {
                BOOL value = BOOLFromString(attrs[attrName]);
                if (value) {
                    state |= [self controlStateForAttribute:attrName];
                }
            }
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
                [self.internalConstantState addDrawable:drawable forState:state];
            }
        }
        child = child->nextSibling;
    }
    
    
}

@end
