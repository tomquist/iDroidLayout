//
//  IDLResourceValueSet.m
//  iDroidLayout
//
//  Created by Tom Quist on 14.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLResourceValueSet.h"
#import "IDLStyle+IDL_Internal.h"
#import "TBXML.h"
#import "IDLResourceManager.h"
#import "IDLStringArray.h"

@interface IDLResourceValueSet ()

@property (nonatomic, retain) NSDictionary *values;

@end

@implementation IDLResourceValueSet

@synthesize values = _values;

- (void)dealloc {
    self.values = nil;
    [super dealloc];
}

+ (NSArray *)parseStringArrayFromElement:(TBXMLElement *)element {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    TBXMLElement *child = element->firstChild;
    NSCharacterSet *whiteSpaceCharSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while (child != nil) {
        NSString *tagName = [TBXML elementName:child];
        if ([tagName isEqualToString:@"item"]) {
            NSString *value = [[TBXML textForElement:child] stringByTrimmingCharactersInSet:whiteSpaceCharSet];
            [array addObject:value];
        }
        child = child->nextSibling;
    }
    NSArray *nonMutableArray = [[[IDLStringArray alloc] initWithArray:array] autorelease];
    [array release];
    return nonMutableArray;
}

+ (IDLResourceValueSet *)inflateParser:(TBXML *)parser {
    IDLResourceValueSet *ret = nil;
    TBXMLElement *root = parser.rootXMLElement;
    if ([[TBXML elementName:root] isEqualToString:@"resources"]) {
        ret = [[[self alloc] init] autorelease];
        NSCharacterSet *whiteSpaceCharSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSMutableDictionary *mutableValues = [[NSMutableDictionary alloc] init];
        TBXMLElement *child = root->firstChild;
        while (child != nil) {
            NSString *tagName = [TBXML elementName:child];
            NSString *resourceName = [TBXML valueOfAttributeNamed:@"name" forElement:child];
            if ([resourceName length] > 0) {
                if ([tagName isEqualToString:@"style"]) {
                    IDLStyle *style = [IDLStyle createFromXMLElement:child];
                    [mutableValues setObject:style forKey:resourceName];
                } else if ([tagName isEqualToString:@"string"]) {
                    NSString *string = [[TBXML textForElement:child] stringByTrimmingCharactersInSet:whiteSpaceCharSet];
                    [mutableValues setObject:string forKey:resourceName];
                } else if([tagName isEqualToString:@"string-array"]) {
                    NSArray *stringArray = [self parseStringArrayFromElement:child];
                    [mutableValues setObject:stringArray forKey:resourceName];
                }
            }
            child = child->nextSibling;
        }
        NSDictionary *nonMutableValues = [[NSDictionary alloc] initWithDictionary:mutableValues];
        [mutableValues release];
        ret.values = nonMutableValues;
        [nonMutableValues release];
    }
    return ret;
}

+ (IDLResourceValueSet *)createFromXMLData:(NSData *)data {
    if (data == nil) return nil;
    IDLResourceValueSet *ret = nil;
    NSError *error = nil;
    TBXML *xml = [[TBXML newTBXMLWithXMLData:data error:&error] autorelease];
    if (error == nil) {
        @autoreleasepool {
            ret = [[self inflateParser:xml] retain];
        }
        [ret autorelease];
    } else {
        NSLog(@"Could not parse resource value set: %@", error);
    }
    return ret;
}

+ (IDLResourceValueSet *)createFromXMLURL:(NSURL *)url {
    return [self createFromXMLData:[NSData dataWithContentsOfURL:url]];
}

- (IDLStyle *)styleForName:(NSString *)name {
    IDLStyle *ret = nil;
    id value = [self.values objectForKey:name];
    if ([value isKindOfClass:[IDLStyle class]]) {
        ret = value;
    }
    return ret;
}

- (NSString *)stringForName:(NSString *)name {
    NSString *ret = nil;
    id value = [self.values objectForKey:name];
    if ([value isKindOfClass:[NSString class]]) {
        ret = value;
        IDLResourceManager *resourceManager = [IDLResourceManager currentResourceManager];
        if ([resourceManager isValidIdentifier:ret]) {
            ret = [resourceManager stringForIdentifier:ret];
        }
    }
    return ret;
}

- (NSArray *)stringArrayForName:(NSString *)name {
    NSArray *ret = nil;
    id value = [self.values objectForKey:name];
    if ([value isKindOfClass:[IDLStringArray class]]) {
        ret = value;
    }
    return ret;
}

@end
