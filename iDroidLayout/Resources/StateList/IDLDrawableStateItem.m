//
//  IDLDrawableStateItem.m
//  iDroidLayout
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawableStateItem.h"
#import "IDLResourceStateItem+IDL_Internal.h"
#import "IDLResourceManager.h"
#import "UIColor+IDL_ColorParser.h"
#import "UIImage+IDL_FromColor.h"

@interface IDLDrawableStateItem ()

@property (nonatomic, strong) NSString *resourceIdentifier;

@end

@implementation IDLDrawableStateItem


- (instancetype)initWithControlState:(UIControlState)controlState drawableResourceIdentifier:(NSString *)resourceIdentifier {
    self = [super initWithControlState:controlState];
    if (self) {
        self.resourceIdentifier = resourceIdentifier;
    }
    return self;
}

- (UIImage *)image {
    UIImage *ret = nil;
    if ([[IDLResourceManager currentResourceManager] isValidIdentifier:self.resourceIdentifier]) {
        ret = [[IDLResourceManager currentResourceManager] imageForIdentifier:self.resourceIdentifier];
    } else {
        // Try to parse color string
        UIColor *color = [UIColor colorFromIDLColorString:self.resourceIdentifier];
        if (color != nil) {
            ret = [UIImage idl_imageFromColor:color withSize:CGSizeMake(1, 1)];
        }
    }
    return ret;
}

@end
