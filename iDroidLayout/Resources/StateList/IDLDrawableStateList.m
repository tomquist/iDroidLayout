//
//  IDLDrawableStateList.m
//  iDroidLayout
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableStateList.h"
#import "UIImage+IDL_FromColor.h"
#import "IDLResourceStateList+IDL_Internal.h"
#import "IDLResourceStateList+IDL_Internal.h"
#import "IDLDrawableStateItem+IDL_Internal.h"

@interface IDLColorWrapperDrawableStateItem : IDLDrawableStateItem

@property (nonatomic, strong) IDLColorStateItem *colorStateItem;

- (instancetype)initWithColorStateItem:(IDLColorStateItem *)colorStateItem;

@end

@implementation IDLColorWrapperDrawableStateItem

- (instancetype)initWithColorStateItem:(IDLColorStateItem *)colorStateItem {
    self = [super initWithControlState:colorStateItem.controlState drawableResourceIdentifier:nil];
    if (self) {
        self.colorStateItem = colorStateItem;
    }
    return self;
}

- (UIImage *)image {
    return [UIImage idl_imageFromColor:self.colorStateItem.color withSize:CGSizeMake(1, 1)];
}

@end

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
        ret = [[IDLDrawableStateItem alloc] initWithControlState:controlState drawableResourceIdentifier:drawableIdentifier];
    }
    return ret;
}

+ (instancetype)createWithSingleDrawableIdentifier:(NSString *)imageIdentifier {
    IDLDrawableStateList *list = [[self alloc] init];
    IDLDrawableStateItem *item = [[IDLDrawableStateItem alloc] initWithControlState:UIControlStateNormal drawableResourceIdentifier:imageIdentifier];
    list.internalItems = [NSArray arrayWithObject:item];
    return list;
}

+ (IDLDrawableStateList *)createFromXMLData:(NSData *)data {
    return (IDLDrawableStateList *)[super createFromXMLData:data];
}

+ (IDLDrawableStateList *)createFromXMLURL:(NSURL *)url {
    return (IDLDrawableStateList *)[super createFromXMLURL:url];
}

+ (IDLDrawableStateList *)createFromColorStateList:(IDLColorStateList *)colorStateList {
    IDLDrawableStateList *ret = nil;
    if (colorStateList != nil) {
        ret = [[IDLDrawableStateList alloc] init];
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[colorStateList.items count]];
        for (IDLColorStateItem *colorStateItem in colorStateList.items) {
            IDLDrawableStateItem *item = [[IDLColorWrapperDrawableStateItem alloc] initWithColorStateItem:colorStateItem];
            [items addObject:item];
        }
        ret.internalItems = items;
    }
    return ret;
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
