//
//  IDLResourceManager+IDL_Internal.m
//  iDroidLayout
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLResourceManager+IDL_Internal.h"


NSString *NSStringFromIDLResourceType(IDLResourceType type) {
    NSString *ret;
    switch (type) {
        case IDLResourceTypeString:
            ret = @"string";
            break;
        case IDLResourceTypeLayout:
            ret = @"layout";
            break;
        case IDLResourceTypeDrawable:
            ret = @"drawable";
            break;
        case IDLResourceTypeColor:
            ret = @"color";
            break;
        case IDLResourceTypeStyle:
            ret = @"style";
            break;
        case IDLResourceTypeValue:
            ret = @"value";
            break;
        case IDLResourceTypeArray:
            ret = @"array";
            break;
        default:
            ret = nil;
            break;
    }
    return ret;
}

IDLResourceType IDLResourceTypeFromString(NSString *typeString) {
    IDLResourceType ret = IDLResourceTypeUnknown;
    if ([typeString isEqualToString:@"string"]) {
        ret = IDLResourceTypeString;
    } else if ([typeString isEqualToString:@"layout"]) {
        ret = IDLResourceTypeLayout;
    } else if ([typeString isEqualToString:@"drawable"]) {
        ret = IDLResourceTypeDrawable;
    } else if ([typeString isEqualToString:@"color"]) {
        ret = IDLResourceTypeColor;
    } else if ([typeString isEqualToString:@"style"]) {
        ret = IDLResourceTypeStyle;
    } else if ([typeString isEqualToString:@"value"]) {
        ret = IDLResourceTypeValue;
    } else if ([typeString isEqualToString:@"array"]) {
        ret = IDLResourceTypeArray;
    }
    return ret;
}

@interface IDLResourceIdentifier()

- (instancetype)initWithString:(NSString *)string;

+ (BOOL)isResourceIdentifier:(NSString *)string;

@end

@implementation IDLResourceIdentifier


- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        BOOL valid = TRUE;
        if ([string length] > 0 && [string characterAtIndex:0] == '@') {
            NSRange separatorRange = [string rangeOfString:@"/"];
            if (separatorRange.location != NSNotFound) {
                NSRange firstPartRange = NSMakeRange(1, separatorRange.location - 1);
                NSRange identifierRange = NSMakeRange(separatorRange.location+1, [string length] - separatorRange.location - 1);
                NSString *identifier = [string substringWithRange:identifierRange];
                NSRange colonRange = [string rangeOfString:@":" options:0 range:firstPartRange];
                
                NSString *bundleIdentifier = nil;
                NSString *typeIdentifier = nil;
                if (colonRange.location != NSNotFound) {
                    bundleIdentifier = [string substringWithRange:NSMakeRange(1, colonRange.location - 1)];
                    typeIdentifier = [string substringWithRange:NSMakeRange(colonRange.location + firstPartRange.location, firstPartRange.length - colonRange.location)];
                } else {
                    typeIdentifier = [string substringWithRange:firstPartRange];
                }
                self.bundleIdentifier = bundleIdentifier;
                self.type = IDLResourceTypeFromString(typeIdentifier);
                if (self.type == IDLResourceTypeUnknown) {
                    valid = FALSE;
                }
                self.identifier = identifier;
            } else {
                valid = FALSE;
            }
        } else {
            valid = FALSE;
        }
        if (!valid) {
            self = nil;
        }
        
    }
    return self;
}

- (NSString *)description {
    NSString *ret = nil;
    NSString *bundleIdentifier = self.bundle!=nil?self.bundle.bundleIdentifier:self.bundleIdentifier;
    NSString *typeName = NSStringFromIDLResourceType(self.type);
    if (bundleIdentifier) {
        ret = [NSString stringWithFormat:@"@%@:%@/%@", bundleIdentifier, typeName, self.identifier];
    } else {
        ret = [NSString stringWithFormat:@"@%@/%@", typeName, self.identifier];
    }
    return ret;
}

+ (BOOL)isResourceIdentifier:(NSString *)string {
    static NSRegularExpression *regex;
    if (regex == nil) {
        regex = [[NSRegularExpression alloc] initWithPattern:@"@([A-Za-z0-9\\.\\-]+:)?[a-z]+/[A-Za-z0-9_\\.]+" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return string != nil && [string isKindOfClass:[NSString class]] && [string length] > 0 && [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])].location != NSNotFound;
}

@end

