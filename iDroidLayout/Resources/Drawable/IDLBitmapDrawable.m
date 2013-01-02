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

@interface IDLBitmapDrawableConstantState ()

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) IDLViewContentGravity gravity;

- (id)initWithState:(IDLBitmapDrawableConstantState *)state;

@end

@implementation IDLBitmapDrawableConstantState

- (void)dealloc {
    self.image = nil;
    [super dealloc];
}

- (id)initWithState:(IDLBitmapDrawableConstantState *)state {
    self = [super init];
    if (self) {
        if (state != nil) {
            self.image = state.image;
            self.gravity = state.gravity;
        } else {
            self.gravity = IDLViewContentGravityFill;
        }
    }
    return self;
}


@end

@interface IDLBitmapDrawable ()

@property (nonatomic, retain) IDLBitmapDrawableConstantState *internalConstantState;

@end

@implementation IDLBitmapDrawable

- (void)dealloc {
    self.internalConstantState = nil;
    [super dealloc];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        IDLBitmapDrawableConstantState *state = [[IDLBitmapDrawableConstantState alloc] initWithState:nil];
        state.image = image;
        self.internalConstantState = state;
        [state release];
    }
    return self;
}

- (id)initWithState:(IDLBitmapDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLBitmapDrawableConstantState *s = [[IDLBitmapDrawableConstantState alloc] initWithState:state];
        self.internalConstantState = s;
        [s release];
    }
    return self;
}

- (id)init {
    return [self initWithState:nil];
}

- (UIImage *)image {
    return self.internalConstantState.image;
}

-(void)drawOnLayer:(CALayer *)layer {
    CGRect containerRect = layer.bounds;
    CGRect dstRect = CGRectZero;
    UIImage *image = self.internalConstantState.image;
    
    [IDLGravity applyGravity:self.internalConstantState.gravity width:image.size.width height:image.size.height containerRect:&containerRect outRect:&dstRect];

    CGRect contentsCenter = CGRectMake(0, 0, 1, 1);
    CGSize size = image.size;
    UIEdgeInsets capInsets = UIEdgeInsetsZero;
    if ([image respondsToSelector:@selector(capInsets)]) {
        capInsets = image.capInsets;
    } else if ([image respondsToSelector:@selector(leftCapWidth)]) {
        capInsets.left = [image leftCapWidth];
        capInsets.top = [image topCapHeight];
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
        layer.contents = (id)image.CGImage;
        
    } else {
        CALayer *sublayer = [[CALayer alloc] init];
        sublayer.frame = dstRect;
        sublayer.contentsCenter = contentsCenter;
        sublayer.contents = (id)image.CGImage;
        [layer addSublayer:sublayer];
        [sublayer release];
    }
}

- (CGSize)intrinsicSize {
    return self.internalConstantState.image.size;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *dictionary = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    NSString *bitmapIdentifier = [dictionary objectForKey:@"src"];
    if (bitmapIdentifier != nil) {
        IDLResourceManager *resMgr = [IDLResourceManager currentResourceManager];
        UIImage *image = [resMgr imageForIdentifier:bitmapIdentifier];
        self.internalConstantState.image = image;
    } else {
        NSLog(@"<bitmap> requires a valid src attribute");
    }
    
    NSString *gravityValue = [dictionary objectForKey:@"gravity"];
    if (gravityValue != nil) {
        self.internalConstantState.gravity = [IDLGravity gravityFromAttribute:gravityValue];
    }
}

- (BOOL)hasPadding {
    return self.internalConstantState.image.hasNinePatchPaddings;
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.image.ninePatchPaddings;
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

@end
