//
//  IDLResourceManager+IDL_Internal.h
//  iDroidLayout
//
//  Created by Tom Quist on 28.03.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLResourceManager+Core.h"

@class IDLXMLCache;
@class IDLResourceValueSet;

typedef NS_ENUM(NSInteger, IDLResourceType) {
    IDLResourceTypeUnknown,
    IDLResourceTypeString,
    IDLResourceTypeLayout,
    IDLResourceTypeDrawable,
    IDLResourceTypeColor,
    IDLResourceTypeStyle,
    IDLResourceTypeValue,
    IDLResourceTypeArray
};

NSString *NSStringFromIDLResourceType(IDLResourceType type);
IDLResourceType IDLResourceTypeFromString(NSString *typeString);

@interface IDLResourceIdentifier : NSObject

@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, assign) IDLResourceType type;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak) NSBundle *bundle;
@property (nonatomic, strong) id cachedObject;
@property (nonatomic, strong) NSString *valueIdentifier;

- (instancetype)initWithString:(NSString *)string NS_DESIGNATED_INITIALIZER;
+ (BOOL)isResourceIdentifier:(NSString *)string;

@end

@interface IDLResourceManager (IDL_Internal)

@property (retain) IDLXMLCache *xmlCache;
- (IDLResourceIdentifier *)resourceIdentifierForString:(NSString *)identifierString;
- (NSBundle *)resolveBundleForIdentifier:(IDLResourceIdentifier *)identifier;
- (NSString *)valueSetIdentifierForIdentifier:(IDLResourceIdentifier *)identifier;
- (IDLResourceValueSet *)resourceValueSetForIdentifier:(NSString *)identifierString;

@end
