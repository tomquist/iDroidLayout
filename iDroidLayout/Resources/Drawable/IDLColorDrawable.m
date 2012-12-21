//
//  IDLColorDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLColorDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "IDLResourceManager.h"

@interface IDLColorDrawable ()

@property (nonatomic, retain) UIColor *color;

@end

@implementation IDLColorDrawable

- (id)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        self.color = color;
    }
    return self;
}

- (void)drawOnLayer:(CALayer *)layer {
    layer.backgroundColor = self.color.CGColor;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    NSString *color = [attrs objectForKey:@"color"];
    if (color != nil) {
        self.color = [[IDLResourceManager currentResourceManager] colorForIdentifier:color];
    }
}

@end
