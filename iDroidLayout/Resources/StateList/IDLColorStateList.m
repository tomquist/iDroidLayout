//
//  IDLColorStateList.m
//  iDroidLayout
//
//  Created by Tom Quist on 06.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLColorStateList.h"
#import "TBXML.h"
#import "UIView+IDL_Layout.h"
#import "IDLResourceManager.h"
#import "UIColor+IDL_ColorParser.h"
#import "IDLColorStateItem+IDL_Internal.h"
#import "IDLResourceStateList+IDL_Internal.h"
#import "IDLStateListDrawable.h"
#import "IDLColorDrawable.h"

@interface IDLColorStateList ()

- (IDLColorStateItem *)itemForControlState:(UIControlState)controlState;

@end

@implementation IDLColorStateList

+ (IDLColorStateItem *)createItemWithControlState:(UIControlState)controlState fromElement:(TBXMLElement *)element {
    IDLColorStateItem *ret = nil;
    NSString *colorIdentifier = [TBXML valueOfAttributeNamed:@"color" forElement:element];
    if (colorIdentifier == nil) {
        NSLog(@"<item> tag requires a 'color' attribute. I'm ignoring this color state item.");
    } else {
        ret = [[IDLColorStateItem alloc] initWithControlState:controlState colorResourceIdentifier:colorIdentifier];
    }
    return ret;
}

+ (instancetype)createWithSingleColorIdentifier:(NSString *)colorIdentifier {
    IDLColorStateList *list = [[self alloc] init];
    IDLColorStateItem *item = [[IDLColorStateItem alloc] initWithControlState:UIControlStateNormal colorResourceIdentifier:colorIdentifier];
    list.internalItems = @[item];
    return list;
}

+ (instancetype)createFromXMLData:(NSData *)data {
    return (IDLColorStateList *)[super createFromXMLData:data];
}

+ (instancetype)createFromXMLURL:(NSURL *)url {
    return (IDLColorStateList *)[super createFromXMLURL:url];
}

- (IDLColorStateItem *)itemForControlState:(UIControlState)controlState {
    return (IDLColorStateItem *)[super itemForControlState:controlState];
}

- (UIColor *)colorForControlState:(UIControlState)controlState defaultColor:(UIColor *)defaultColor {
    UIColor *ret = defaultColor;
    IDLColorStateItem *item = [self itemForControlState:controlState];
    if (item != nil) {
        ret = item.color;
    }
    return ret;
}

- (UIColor *)colorForControlState:(UIControlState)controlState {
    return [self colorForControlState:controlState defaultColor:nil];
}

- (IDLDrawable *)convertToDrawable {
    IDLStateListDrawable *drawable = [[IDLStateListDrawable alloc] initWithColorStateListe:self];
    return drawable;
}

@end
