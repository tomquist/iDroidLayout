//
//  IDLResourceManager.m
//  iDroidLayout
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLResourceManager.h"
#import "UIColor+IDL_ColorParser.h"

typedef enum IDLResourceType {
    IDLResourceTypeUnknown,
    IDLResourceTypeString,
    IDLResourceTypeLayout,
    IDLResourceTypeDrawable
} IDLResourceType;

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
    }
    return ret;
}

@interface IDLResourceIdentifier : NSObject

@property (nonatomic, retain) NSString *bundleIdentifier;
@property (nonatomic, assign) IDLResourceType type;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, assign) NSBundle *bundle;
@property (nonatomic, retain) id cachedObject;

- (id)initWithString:(NSString *)string;

+ (BOOL)isResourceIdentifier:(NSString *)string;

@end

@implementation IDLResourceIdentifier

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
        regex = [[NSRegularExpression alloc] initWithPattern:@"@([A-Za-z0-9\\.\\-]+:)?[a-z]+/[^A-Za-z0-9_\\.]" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return string != nil && [string isKindOfClass:[NSString class]] && [string length] > 0 && [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])].location != NSNotFound;
}

@end

@interface IDLResourceManager ()

@property (retain) NSMutableDictionary *resourceIdentifierCache;

@end

@implementation IDLResourceManager

+ (IDLResourceManager *)defaultResourceManager {
    static IDLResourceManager *resourceManager;
    if (resourceManager == nil) {
        resourceManager = [[IDLResourceManager alloc] init];
    }
    return resourceManager;
}

+ (IDLResourceManager *)currentResourceManager {
    return [self defaultResourceManager];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.resourceIdentifierCache = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.resourceIdentifierCache = [NSMutableDictionary dictionary];
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

- (IDLResourceIdentifier *)resourceIdentifierForString:(NSString *)identifierString {
    IDLResourceIdentifier *identifier = [self.resourceIdentifierCache objectForKey:identifierString];
    if (identifier == nil) {
        identifier = [[IDLResourceIdentifier alloc] initWithString:identifierString];
        [self.resourceIdentifierCache setObject:identifier forKey:identifierString];
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
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        ret = [bundle localizedStringForKey:identifier.identifier value:nil table:nil];
    }
    return ret;
}

- (NSURL *)layoutURLForIdentifier:(NSString *)identifierString {
    NSURL *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        ret = [bundle URLForResource:identifier.identifier withExtension:@"xml"];
    }
    return ret;
}

- (UIImage *)imageForIdentifier:(NSString *)identifierString withCaching:(BOOL)withCaching {
    UIImage *ret = nil;
    IDLResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.cachedObject != nil) {
        ret = identifier.cachedObject;
    } else if (identifier != nil) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @".png";
        }
        NSString *fileName = [identifier.identifier stringByDeletingPathExtension];
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale >= 2.f) {
            NSString *retinaFileName = [fileName stringByAppendingString:@"@2x"];
            NSURL *retinaImageURL = [bundle URLForResource:retinaFileName withExtension:extension];
            if (retinaImageURL != nil) {
                UIImage *nonScaledImage = [[UIImage alloc] initWithContentsOfFile:[retinaImageURL path]];
                UIImage *retinaImage = nil;
                if (nonScaledImage != nil) {
                    if (nonScaledImage.scale >= 2.f) {
                        retinaImage = [nonScaledImage retain];
                    } else {
                        retinaImage = [[UIImage alloc] initWithCGImage:nonScaledImage.CGImage scale:2.f orientation:nonScaledImage.imageOrientation];
                    }
                    [nonScaledImage release];
                }
                if (retinaImage != nil) {
                    ret = [retinaImage autorelease];
                }
            }
        }
        
        if (ret == nil) {
            NSURL *imageURL = [bundle URLForResource:fileName withExtension:extension];
            if (imageURL != nil) {
                ret = [UIImage imageWithContentsOfFile:imageURL.path];
            }
        }
    }
    if (withCaching && ret != nil) {
        identifier.cachedObject = ret;
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

@end
