//
//  IDLBitmapDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLBitmapDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "IDLResourceManager.h"
#import "UIImage+IDLNinePatch.h"

@interface IDLBitmapDrawable ()

@property (nonatomic, retain) UIImage *internalImage;

@end

@implementation IDLBitmapDrawable

- (void)dealloc {
    self.internalImage = nil;
    [super dealloc];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.internalImage = image;
        self.gravity = IDLViewContentGravityFill;
    }
    return self;
}

- (UIImage *)image {
    return self.internalImage;
}

-(void)drawOnLayer:(CALayer *)layer {
    CGRect containerRect = layer.bounds;
    CGRect dstRect = CGRectZero;
    [IDLGravity applyGravity:self.gravity width:self.image.size.width height:self.image.size.height containerRect:&containerRect outRect:&dstRect];

    CGRect contentsCenter = CGRectMake(0, 0, 1, 1);
    CGSize size = self.image.size;
    UIEdgeInsets capInsets = UIEdgeInsetsZero;
    if ([self.image respondsToSelector:@selector(capInsets)]) {
        capInsets = self.image.capInsets;
    } else if ([self.image respondsToSelector:@selector(leftCapWidth)]) {
        capInsets.left = [self.image leftCapWidth];
        capInsets.top = [self.image topCapHeight];
        if (capInsets.left > 0) {
            capInsets.right = size.width - capInsets.left - 1;
        }
        if (capInsets.top > 0) {
            capInsets.bottom = size.height - capInsets.top - 1;
        }
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero)) {
        contentsCenter = CGRectMake(capInsets.left/size.width, capInsets.top/size.height, (size.width - capInsets.left - capInsets.right)/size.width, (size.height - capInsets.top - capInsets.bottom)/size.height);
    }
    if (CGRectEqualToRect(containerRect, dstRect)) {
        layer.contentsCenter = contentsCenter;
        layer.contents = (id)self.image.CGImage;
        
    } else {
        CALayer *sublayer = [[CALayer alloc] init];
        sublayer.frame = dstRect;
        sublayer.contentsCenter = contentsCenter;
        sublayer.contents = (id)self.image.CGImage;
        [layer addSublayer:sublayer];
        [sublayer release];
    }
}

- (CGSize)intrinsicSize {
    return self.image.size;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *dictionary = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    NSString *bitmapIdentifier = [dictionary objectForKey:@"src"];
    if (bitmapIdentifier != nil) {
        IDLResourceManager *resMgr = [IDLResourceManager currentResourceManager];
        UIImage *image = [resMgr imageForIdentifier:bitmapIdentifier];
        self.internalImage = image;
    } else {
        NSLog(@"<bitmap> requires a valid src attribute");
    }
    
    NSString *gravityValue = [dictionary objectForKey:@"gravity"];
    if (gravityValue != nil) {
        self.gravity = [IDLGravity gravityFromAttribute:gravityValue];
    }
}

- (BOOL)hasPadding {
    return self.image.hasNinePatchPaddings;
}

- (UIEdgeInsets)padding {
    return self.image.ninePatchPaddings;
}

@end
