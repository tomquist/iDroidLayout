//
//  IDLResourceManager+Core.m
//  iDroidLayout
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLResourceManager+Core.h"
#import "IDLResourceManager+IDL_Internal.h"
#import "UIImage+IDL_FromColor.h"
#import "IDLResourceValueSet.h"
#import "UIImage+IDLNinePatch.h"
#import "IDLXMLCache.h"
#import "IDLColorStateList.h"


@interface IDLResourceManager ()

@property (strong) NSMutableDictionary *resourceIdentifierCache;
@property (strong) IDLXMLCache *xmlCache;

@end

@implementation IDLResourceManager

static IDLResourceManager *currentResourceManager;

+ (void)initialize {
    [super initialize];
    currentResourceManager = [self defaultResourceManager];
    currentResourceManager.xmlCache = [IDLXMLCache sharedInstance];
}

+ (instancetype)defaultResourceManager {
    static IDLResourceManager *resourceManager;
    if (resourceManager == nil) {
        resourceManager = [[self alloc] init];
    }
    return resourceManager;
}

+ (IDLResourceManager *)currentResourceManager {
    @synchronized(self) {
        return currentResourceManager;
    }
}

+ (void)setCurrentResourceManager:(IDLResourceManager *)resourceManager {
    @synchronized(self) {
        currentResourceManager = resourceManager;
    }
}

+ (void)resetCurrentResourceManager {
    [self setCurrentResourceManager:[self defaultResourceManager]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        self.resourceIdentifierCache = [NSMutableDictionary dictionary];
        self.xmlCache = [[IDLXMLCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    for (IDLResourceIdentifier *identifier in [self.resourceIdentifierCache allValues]) {
        identifier.cachedObject = nil;
    }
}

- (BOOL)isValidIdentifier:(NSString *)identifier {
    return [IDLResourceIdentifier isResourceIdentifier:identifier];
}

- (BOOL)invalidateCacheForBundle:(NSBundle *)bundle {
    NSSet *keysToRemove = [self.resourceIdentifierCache keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        IDLResourceIdentifier *resId = obj;
        NSBundle *resBundle = resId.bundle;
        return (resBundle == bundle || [resBundle.bundleIdentifier isEqualToString:bundle.bundleIdentifier]);
    }];
    [self.resourceIdentifierCache removeObjectsForKeys:[keysToRemove allObjects]];
    return [keysToRemove count] > 0;
}

- (IDLResourceIdentifier *)resourceIdentifierForString:(NSString *)identifierString {
    IDLResourceIdentifier *identifier = [self.resourceIdentifierCache objectForKey:identifierString];
    if (identifier == nil) {
        identifier = [[IDLResourceIdentifier alloc] initWithString:identifierString];
        if (identifier != nil) {
            [self.resourceIdentifierCache setObject:identifier forKey:identifierString];
            [self.resourceIdentifierCache setObject:identifier forKey:[identifier description]];
        }
    }
    return identifier;
}

- (NSBundle *)resolveBundleForIdentifier:(IDLResourceIdentifier *)identifier {
    if (identifier.bundle == nil) {
        if (identifier.bundleIdentifier == nil) {
            identifier.bundle = [NSBundle mainBundle];
        } else {
            identifier.bundle = [NSBundle bundleWithIdentifier:identifier.bundleIdentifier];
        }
    }
    return identifier.bundle;
}

- (NSURL *)layoutURLForIdentifier:(NSString *)identifierString {
    NSURL *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        ret = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
    }
    return ret;
}

- (UIImage *)imageForIdentifier:(NSString *)identifierString withCaching:(BOOL)withCaching {
    UIImage *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == IDLResourceTypeColor) {
        UIColor *color = [self colorForIdentifier:identifierString];
        ret = [UIImage idl_imageFromColor:color withSize:CGSizeMake(1, 1)];
    } else if (identifier.type == IDLResourceTypeDrawable) {
        
        if (identifier.cachedObject != nil) {
            ret = identifier.cachedObject;
        } else if (identifier != nil) {
            NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
            ret = [UIImage idl_imageWithName:identifier.identifier fromBundle:bundle];
        }
        if (withCaching && ret != nil) {
            identifier.cachedObject = ret;
        }
    } else {
        NSLog(@"Could not create image from resource identifier %@: Invalid resource type", identifierString);
    }
    return ret;
}

- (UIImage *)imageForIdentifier:(NSString *)identifierString {
    return [self imageForIdentifier:identifierString withCaching:TRUE];
}

- (UIColor *)colorForIdentifier:(NSString *)identifierString {
    UIColor *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil) {
        if (identifier.type == IDLResourceTypeDrawable) {
            UIImage *image = [self imageForIdentifier:identifierString];
            if (image != nil) {
                ret = [UIColor colorWithPatternImage:image];
            }
        }
    }
    return ret;
}

- (IDLColorStateList *)colorStateListForIdentifier:(NSString *)identifierString {
    IDLColorStateList *colorStateList = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.cachedObject != nil && ([identifier.cachedObject isKindOfClass:[IDLColorStateList class]] || [identifier.cachedObject isKindOfClass:[UIColor class]])) {
        if ([identifier.cachedObject isKindOfClass:[IDLColorStateList class]]) {
            colorStateList = identifier.cachedObject;
        } else if ([identifier.cachedObject isKindOfClass:[UIColor class]]) {
            colorStateList = [IDLColorStateList createWithSingleColorIdentifier:identifierString];
        }
    } else if (identifier.type == IDLResourceTypeColor) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
        if (url != nil) {
            colorStateList = [IDLColorStateList createFromXMLURL:url];
        }
        if (colorStateList != nil) {
            identifier.cachedObject = colorStateList;
        }
    }
    if (colorStateList == nil) {
        UIColor *color = [self colorForIdentifier:identifierString];
        if (color != nil) {
            colorStateList = [IDLColorStateList createWithSingleColorIdentifier:identifierString];
        }
    }
    
    return colorStateList;
}

- (NSString *)valueSetIdentifierForIdentifier:(IDLResourceIdentifier *)identifier {
    NSString *ret = nil;
    if (identifier.valueIdentifier != nil) {
        ret = identifier.valueIdentifier;
    } else {
        NSRange range = [identifier.identifier rangeOfString:@"."];
        if (range.location != NSNotFound && range.location > 0) {
            NSString *valueSetIdentifier = [identifier.identifier substringToIndex:range.location];
            NSString *bundleIdentifier = identifier.bundle!=nil?identifier.bundle.bundleIdentifier:identifier.bundleIdentifier;
            NSString *typeName = NSStringFromIDLResourceType(IDLResourceTypeValue);
            if (bundleIdentifier) {
                ret = [NSString stringWithFormat:@"@%@:%@/%@", bundleIdentifier, typeName, valueSetIdentifier];
            } else {
                ret = [NSString stringWithFormat:@"@%@/%@", typeName, valueSetIdentifier];
            }
            identifier.valueIdentifier = ret;
        }
    }
    return ret;
}

- (IDLResourceValueSet *)resourceValueSetForIdentifier:(NSString *)identifierString {
    IDLResourceValueSet *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil && identifier.type != IDLResourceTypeValue) {
        NSString *valueSetIdentifier = [self valueSetIdentifierForIdentifier:identifier];
        identifier = [self resourceIdentifierForString:valueSetIdentifier];
    }
    
    if (identifier != nil) {
        if (identifier.cachedObject != nil && [identifier.cachedObject isKindOfClass:[IDLResourceValueSet class]]) {
            ret = identifier.cachedObject;
        } else {
            NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
            NSString *extension = [identifier.identifier pathExtension];
            if ([extension length] == 0) {
                extension = @"xml";
            }
            NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
            if (url != nil) {
                ret = [IDLResourceValueSet createFromXMLURL:url];
            }
            if (ret != nil) {
                identifier.cachedObject = ret;
            }
        }
    }
    return ret;
}

- (IDLStyle *)styleForIdentifier:(NSString *)identifierString {
    IDLStyle *style = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == IDLResourceTypeStyle) {
        if (identifier.cachedObject != nil) {
            style = identifier.cachedObject;
        } else if (identifier != nil) {
            IDLResourceValueSet *valueSet = [self resourceValueSetForIdentifier:identifierString];
            if (valueSet != nil) {
                NSRange range = [identifier.identifier rangeOfString:@"."];
                if (range.location != NSNotFound && range.location > 0) {
                    style = [valueSet styleForName:[identifier.identifier substringFromIndex:range.location+1]];
                }
                
            }
            if (style != nil) {
                identifier.cachedObject = style;
            }
        }
    }
    return style;
}

@end
