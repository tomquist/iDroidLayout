//
//  IDLStyle.m
//  iDroidLayout
//
//  Created by Tom Quist on 09.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLStyle.h"
#import "IDLStyle+IDL_Internal.h"
#import "IDLResourceManager.h"

@interface IDLStyle ()

@property (nonatomic, retain) NSMutableDictionary *internalAttributes;
@property (nonatomic, retain) NSString *parentIdentifier;
@property (nonatomic, assign) BOOL includesParentStyleAttributes;

@end

@implementation IDLStyle

@synthesize attributes = _attributes;
@synthesize parentIdentifier = _parentIdentifier;

+ (IDLStyle *)createFromXMLElement:(TBXMLElement *)element {
    NSString *parentStyleId = [TBXML valueOfAttributeNamed:@"parent" forElement:element];
    TBXMLElement *child = element->firstChild;
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    while (child != NULL) {
        NSString *childName = [TBXML elementName:child];
        if ([childName isEqualToString:@"item"]) {
            NSString *name = [TBXML valueOfAttributeNamed:@"name" forElement:child];
            NSRange prefixRange = [name rangeOfString:@":"];
            if (prefixRange.location != NSNotFound) {
                name = [name substringFromIndex:(prefixRange.location+1)];
            }
            NSString *value = [TBXML textForElement:child];
            if (name != nil && [name length] > 0 && value != nil) {
                [attributes setObject:value forKey:name];
            }
        }
        child = child->nextSibling;
    }
    IDLStyle *style = [[IDLStyle alloc] init];
    if ([parentStyleId length] > 0) {
        style.parentIdentifier = parentStyleId;
    } else {
        style.includesParentStyleAttributes = TRUE;
    }
    style.internalAttributes = attributes;
    [attributes release];
    return style;
}

- (NSDictionary *)attributes {
    // Lazy-load parent style attributes
    // Double-Checked locking should be fine here, even though it is an anti-pattern in other cases
    if (!self.includesParentStyleAttributes) {
        @synchronized(self) {
            if (!self.includesParentStyleAttributes) {
                NSDictionary *parentAttributes = self.parentStyle.attributes;
                for (NSString *name in [parentAttributes allKeys]) {
                    if ([self.internalAttributes objectForKey:name] == nil) {
                        id value = [parentAttributes objectForKey:name];
                        [self.internalAttributes setObject:value forKey:name];
                    }
                }
                self.includesParentStyleAttributes = TRUE;
            }
        }
    }
    return self.internalAttributes;
}

- (IDLStyle *)parentStyle {
    IDLStyle *parentStyle = nil;
    if ([self.parentIdentifier length] > 0) {
        parentStyle = [[IDLResourceManager currentResourceManager] styleForIdentifier:self.parentIdentifier];
    }
    return  parentStyle;
}

@end
