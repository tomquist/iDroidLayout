//
//  IDLResourceManager.m
//  iDroidLayout
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLResourceManager.h"
#import "UIColor+IDL_ColorParser.h"
#import "UIImage+IDL_FromColor.h"
#import "IDLResourceValueSet.h"
#import "IDLBitmapDrawable.h"
#import "IDLColorDrawable.h"
#import "UIImage+IDLNinePatch.h"
#import "IDLXMLCache.h"

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

@interface IDLResourceIdentifier : NSObject

@property (nonatomic, retain) NSString *bundleIdentifier;
@property (nonatomic, assign) IDLResourceType type;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, assign) NSBundle *bundle;
@property (nonatomic, retain) id cachedObject;
@property (nonatomic, retain) NSString *valueIdentifier;

- (id)initWithString:(NSString *)string;

+ (BOOL)isResourceIdentifier:(NSString *)string;

@end

@implementation IDLResourceIdentifier

- (void)dealloc {
    self.bundleIdentifier = nil;
    self.identifier = nil;
    self.cachedObject = nil;
    self.valueIdentifier = nil;
    [super dealloc];
}

- (id)initWithString:(NSString *)string {
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
            [self autorelease];
            return nil;
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

@interface IDLResourceManager ()

@property (retain) NSMutableDictionary *resourceIdentifierCache;
@property (retain) IDLXMLCache *xmlCache;

@end

@implementation IDLResourceManager

static IDLResourceManager *currentResourceManager;

+ (void)initialize {
    [super initialize];
    currentResourceManager = [[self defaultResourceManager] retain];
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
        [currentResourceManager release];
        currentResourceManager = [resourceManager retain];
    }
}

+ (void)resetCurrentResourceManager {
    [self setCurrentResourceManager:[self defaultResourceManager]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.resourceIdentifierCache = nil;
    self.xmlCache = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.resourceIdentifierCache = [NSMutableDictionary dictionary];
        self.xmlCache = [[[IDLXMLCache alloc] init] autorelease];
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
        [identifier release];
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

- (NSString *)stringForIdentifier:(NSString *)identifierString {
    NSString *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil) {
        NSString *valueSetIdentifier = [self valueSetIdentifierForIdentifier:identifier];
        if ([valueSetIdentifier length] > 0) {
            IDLResourceValueSet *valueSet = [self resourceValueSetForIdentifier:valueSetIdentifier];
            if (valueSet != nil) {
                NSRange range = [identifier.identifier rangeOfString:@"."];
                if (range.location != NSNotFound && range.location > 0) {
                    ret = [valueSet stringForName:[identifier.identifier substringFromIndex:range.location+1]];
                }

            }
        }
        if (ret == nil) {
            // Fallback to localized strings
            NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
            ret = [bundle localizedStringForKey:identifier.identifier value:nil table:nil];
        }
    }
    return ret;
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

- (IDLDrawableStateList *)drawableStateListForIdentifier:(NSString *)identifierString {
    IDLDrawableStateList *drawableStateList = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.cachedObject != nil && ([identifier.cachedObject isKindOfClass:[IDLDrawableStateList class]] || [identifier.cachedObject isKindOfClass:[UIImage class]])) {
        if ([identifier.cachedObject isKindOfClass:[IDLDrawableStateList class]]) {
            drawableStateList = identifier.cachedObject;
        } else if ([identifier.cachedObject isKindOfClass:[UIImage class]]) {
            drawableStateList = [IDLDrawableStateList createWithSingleDrawableIdentifier:identifierString];
        }
    } else if (identifier.type == IDLResourceTypeDrawable) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
        if (url != nil) {
            drawableStateList = [IDLDrawableStateList createFromXMLURL:url];
        }
        if (drawableStateList != nil) {
            identifier.cachedObject = drawableStateList;
        }
    } else if (identifier.type == IDLResourceTypeColor) {
        IDLColorStateList *colorStateList = [self colorStateListForIdentifier:identifierString];
        if (colorStateList != nil) {
            drawableStateList = [IDLDrawableStateList createFromColorStateList:colorStateList];
        }
    }
    if (drawableStateList == nil) {
        UIImage *image = [self imageForIdentifier:identifierString];
        if (image != nil) {
            drawableStateList = [IDLDrawableStateList createWithSingleDrawableIdentifier:identifierString];
        }
    }
    
    return drawableStateList;
}

- (IDLDrawable *)drawableForIdentifier:(NSString *)identifierString {
    IDLDrawable *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == IDLResourceTypeDrawable && identifier.cachedObject != nil && ([identifier.cachedObject isKindOfClass:[IDLDrawable class]] || [identifier.cachedObject isKindOfClass:[UIImage class]])) {
        if ([identifier.cachedObject isKindOfClass:[IDLDrawable class]]) {
            ret = [[identifier.cachedObject copy] autorelease];
        } else if ([identifier.cachedObject isKindOfClass:[UIImage class]]) {
            ret = [[[IDLBitmapDrawable alloc] initWithImage:identifier.cachedObject] autorelease];
        }
    } else if (identifier.type == IDLResourceTypeDrawable) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
        if (url != nil) {
            ret = [IDLDrawable createFromXMLURL:url];
        } else {
            UIImage *image = [self imageForIdentifier:identifierString];
            if (image != nil) {
                ret = [[[IDLBitmapDrawable alloc] initWithImage:image] autorelease];
            }
        }
        if (ret != nil) {
            identifier.cachedObject = ret;
            ret = [[ret copy] autorelease];
        }
    } else if (identifier.type == IDLResourceTypeColor) {
        IDLColorStateList *colorStateList = [self colorStateListForIdentifier:identifierString];
        if (colorStateList != nil) {
            ret = [colorStateList convertToDrawable];
        }
    }
    if (ret == nil) {
        UIImage *image = [self imageForIdentifier:identifierString];
        if (image != nil) {
            ret = [[[IDLBitmapDrawable alloc] initWithImage:image] autorelease];
        } else {
            UIColor *color = [UIColor colorFromIDLColorString:identifierString];
            if (color != nil) {
                ret = [[[IDLColorDrawable alloc] initWithColor:color] autorelease];
            }
        }
    }
    
    return ret;
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

- (NSArray *)stringArrayForIdentifier:(NSString *)identifierString {
    NSArray *array = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == IDLResourceTypeArray) {
        if (identifier.cachedObject != nil) {
            array = identifier.cachedObject;
        } else if (identifier != nil) {
            IDLResourceValueSet *valueSet = [self resourceValueSetForIdentifier:identifierString];
            if (valueSet != nil) {
                NSRange range = [identifier.identifier rangeOfString:@"."];
                if (range.location != NSNotFound && range.location > 0) {
                    array = [valueSet stringArrayForName:[identifier.identifier substringFromIndex:range.location+1]];
                }
            }
            if (array != nil) {
                identifier.cachedObject = array;
            }
        }
    }
    return array;
}

@end
