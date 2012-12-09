//
//  IDLDrawableStateList.m
//  iDroidLayout
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableStateList.h"
#import "IDLResourceStateList+IDL_Internal.h"
#import "IDLDrawableStateItem+IDL_Internal.h"

@interface IDLDrawableStateList ()

- (IDLDrawableStateItem *)itemForControlState:(UIControlState)controlState;

@end

@implementation IDLDrawableStateList

+ (IDLDrawableStateItem *)createItemWithControlState:(UIControlState)controlState fromElement:(TBXMLElement *)element {
    IDLDrawableStateItem *ret = nil;
    NSString *drawableIdentifier = [TBXML valueOfAttributeNamed:@"drawable" forElement:element];
    if (drawableIdentifier == nil) {
        NSLog(@"<item> tag requires a 'drawable' attribute. I'm ignoring this drawable state item.");
    } else {
        ret = [[[IDLDrawableStateItem alloc] initWithControlState:controlState drawableResourceIdentifier:drawableIdentifier] autorelease];
    }
    return ret;
}

+ (IDLDrawableStateList *)createWithSingleDrawableIdentifier:(NSString *)imageIdentifier {
    IDLDrawableStateList *list = [[[self alloc] init] autorelease];
    IDLDrawableStateItem *item = [[IDLDrawableStateItem alloc] initWithControlState:UIControlStateNormal drawableResourceIdentifier:imageIdentifier];
    list.internalItems = [NSArray arrayWithObject:item];
    [item release];
    return list;
}

+ (IDLDrawableStateList *)createFromXMLData:(NSData *)data {
    return (IDLDrawableStateList *)[super createFromXMLData:data];
}

+ (IDLDrawableStateList *)createFromXMLURL:(NSURL *)url {
    return (IDLDrawableStateList *)[super createFromXMLURL:url];
}

- (IDLDrawableStateItem *)itemForControlState:(UIControlState)controlState {
    return (IDLDrawableStateItem *)[super itemForControlState:controlState];
}

- (UIImage *)imageForControlState:(UIControlState)controlState defaultImage:(UIImage *)defaultImage {
    UIImage *ret = defaultImage;
    IDLDrawableStateItem *item = [self itemForControlState:controlState];
    if (item != nil) {
        ret = item.image;
    }
    return ret;
}

- (UIImage *)imageForControlState:(UIControlState)controlState {
    return [self imageForControlState:controlState defaultImage:nil];
}

@end
