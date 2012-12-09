//
//  NSDictionary+IDL_ResourceManager.m
//  iDroidLayout
//
//  Created by Tom Quist on 02.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "NSDictionary+IDL_ResourceManager.h"
#import "IDLResourceManager.h"
#import "UIColor+IDL_ColorParser.h"

@implementation NSDictionary (IDL_ResourceManager)

- (UIColor *)colorFromIDLValueForKey:(NSString *)key {
    UIColor *ret = nil;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = value;
        if ([[IDLResourceManager currentResourceManager] isValidIdentifier:string]) {
            ret = [[IDLResourceManager currentResourceManager] colorForIdentifier:string];
        } else {
            ret = [UIColor colorFromIDLColorString:string];
        }
    }
    return ret;
}

- (IDLColorStateList *)colorStateListFromIDLValueForKey:(NSString *)key {
    IDLColorStateList *ret = nil;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = value;
        ret = [[IDLResourceManager currentResourceManager] colorStateListForIdentifier:string];
    }
    return ret;
}

@end
