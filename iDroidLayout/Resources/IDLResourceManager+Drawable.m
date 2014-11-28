//
//  IDLResourceManager+Drawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLResourceManager+Drawable.h"
#import "IDLResourceManager+IDL_Internal.h"
#import "IDLDrawable.h"
#import "IDLDrawableStateList.h"
#import "IDLBitmapDrawable.h"
#import "IDLColorDrawable.h"
#import "UIColor+IDL_ColorParser.h"

@implementation IDLResourceManager (Drawable)


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
            ret = [identifier.cachedObject copy];
        } else if ([identifier.cachedObject isKindOfClass:[UIImage class]]) {
            ret = [[IDLBitmapDrawable alloc] initWithImage:identifier.cachedObject];
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
                ret = [[IDLBitmapDrawable alloc] initWithImage:image];
            }
        }
        if (ret != nil) {
            identifier.cachedObject = ret;
            ret = [ret copy];
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
            ret = [[IDLBitmapDrawable alloc] initWithImage:image];
        } else {
            UIColor *color = [UIColor colorFromIDLColorString:identifierString];
            if (color != nil) {
                ret = [[IDLColorDrawable alloc] initWithColor:color];
            }
        }
    }
    
    return ret;
}



@end
