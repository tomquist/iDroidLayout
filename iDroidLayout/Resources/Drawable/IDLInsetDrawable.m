//
//  IDLInsetDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLInsetDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "IDLResourceManager.h"
#import "TBXML+IDL.h"

@implementation IDLInsetDrawable

- (void)drawOnLayer:(CALayer *)layer {
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = UIEdgeInsetsInsetRect(layer.frame, self.insets);
    [self.drawable drawOnLayer:sublayer];
    [layer addSublayer:sublayer];
}

- (CGSize)minimumSize {
    return self.drawable.minimumSize;
}

- (CGSize)intrinsicSize {
    return self.drawable.intrinsicSize;
}

- (void)onStateChanged {
    [super onStateChanged];
    self.drawable.state = self.state;
}

- (UIEdgeInsets)padding {
    UIEdgeInsets insets = self.insets;
    if (self.drawable.hasPadding) {
        UIEdgeInsets childInsets = self.drawable.padding;
        insets.left += childInsets.left;
        insets.top += childInsets.top;
        insets.right += childInsets.right;
        insets.bottom += childInsets.bottom;
    }
    return insets;
}

- (BOOL)hasPadding {
    return self.drawable.hasPadding || !UIEdgeInsetsEqualToEdgeInsets(self.insets, UIEdgeInsetsZero);
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.left = [[attrs objectForKey:@"insetLeft"] floatValue];
    insets.top = [[attrs objectForKey:@"insetTop"] floatValue];
    insets.right = [[attrs objectForKey:@"insetRight"] floatValue];
    insets.bottom = [[attrs objectForKey:@"insetBottom"] floatValue];
    
    NSString *drawableResId = [attrs objectForKey:@"drawable"];
    IDLDrawable *drawable = nil;
    if (drawableResId != nil) {
        drawable = [[IDLResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
    } else if (element->firstChild != NULL) {
        drawable = [IDLDrawable createFromXMLElement:element->firstChild];
    } else {
        NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
    }
    if (drawable != nil) {
        drawable.state = self.state;
        _drawable = drawable;
        _insets = insets;
    }
}

@end
