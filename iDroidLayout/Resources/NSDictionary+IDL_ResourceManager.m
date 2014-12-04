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

- (NSString *)stringFromIDLValueForKey:(NSString *)key {
    NSString *ret = nil;
    NSString *text = self[key];
    if ([[IDLResourceManager currentResourceManager] isValidIdentifier:text]) {
        NSString *textFromResouces = [[IDLResourceManager currentResourceManager] stringForIdentifier:text];
        ret = textFromResouces;
    } else {
        ret = text;
    }
    return ret;
}

- (UIColor *)colorFromIDLValueForKey:(NSString *)key {
    UIColor *ret = nil;
    id value = self[key];
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
    id value = self[key];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = value;
        ret = [[IDLResourceManager currentResourceManager] colorStateListForIdentifier:string];
    }
    return ret;
}

- (CGFloat)dimensionFromIDLValueForKey:(NSString *)key {
    return [self dimensionFromIDLValueForKey:key defaultValue:0];
}

- (CGFloat)dimensionFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue {
    CGFloat ret = 0;
    id value = self[key];
    if (value == nil) {
        ret = defaultValue;
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([[IDLResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            ret = [value floatValue];
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = [value floatValue];
    }
    return ret;
}

- (float)fractionValueFromIDLValueForKey:(NSString *)key {
    return [self fractionValueFromIDLValueForKey:key defaultValue:0];
}

- (float)fractionValueFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue {
    float ret = defaultValue;
    id value = self[key];
    if (value == nil) {
        ret = defaultValue;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = nil;
        if ([[IDLResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            stringValue = value;
        }
        if ([stringValue hasSuffix:@"%"]) {
            ret = [stringValue floatValue] / 100.f;
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = [value floatValue];
    }
    return ret;
}

- (BOOL)isFractionIDLValueForKey:(NSString *)key {
    BOOL ret = FALSE;
    id value = self[key];
    if (value == nil) {
        ret = FALSE;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = nil;
        if ([[IDLResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            stringValue = value;
        }
        ret = [stringValue hasSuffix:@"%"];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = FALSE;
    }
    return ret;
}

- (BOOL)boolFromIDLValueForKey:(NSString *)key {
    return [self boolFromIDLValueForKey:key defauleValue:FALSE];
}

- (BOOL)boolFromIDLValueForKey:(NSString *)key defauleValue:(BOOL)defaultValue {
    BOOL ret = defaultValue;
    id value = self[key];
    if (value == nil) {
        ret = defaultValue;
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([[IDLResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            ret = [value boolValue];
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = [value boolValue];
    }
    return ret;
}

@end
