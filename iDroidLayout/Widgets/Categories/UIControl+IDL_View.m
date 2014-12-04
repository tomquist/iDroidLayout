//
//  UIControl+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIControl+IDL_View.h"
#import "UIView+IDL_Layout.h"
#import "NSDictionary+IDL_ResourceManager.h"

@implementation UIControl (IDL_View)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    id delegate = attrs[IDLViewAttributeActionTarget];
    if (delegate != nil) {
        NSString *onClickKeyPath = [attrs stringFromIDLValueForKey:@"onClickKeyPath"];
        NSString *onClickSelector = [attrs stringFromIDLValueForKey:@"onClick"];
        SEL selector = NULL;
        if (onClickSelector != nil && (selector = NSSelectorFromString(onClickSelector)) != NULL) {
            if ([onClickKeyPath length] > 0) {
                [self addTarget:[delegate valueForKeyPath:onClickKeyPath] action:selector forControlEvents:UIControlEventTouchUpInside];
            } else {
                [self addTarget:delegate action:selector forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)setGravity:(IDLViewContentGravity)gravity {
    if ((gravity & IDLViewContentGravityTop) == IDLViewContentGravityTop) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    } else if ((gravity & IDLViewContentGravityBottom) == IDLViewContentGravityBottom) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    } else if ((gravity & IDLViewContentGravityFillVertical) == IDLViewContentGravityFillVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    } else if ((gravity & IDLViewContentGravityCenterVertical) == IDLViewContentGravityCenterVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    if ((gravity & IDLViewContentGravityLeft) == IDLViewContentGravityLeft) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    } else if ((gravity & IDLViewContentGravityRight) == IDLViewContentGravityRight) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    } else if ((gravity & IDLViewContentGravityFillHorizontal) == IDLViewContentGravityFillHorizontal) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    } else if ((gravity & IDLViewContentGravityCenterHorizontal) == IDLViewContentGravityCenterHorizontal) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
}

- (IDLViewContentGravity)gravity {
    IDLViewContentGravity ret = IDLViewContentGravityNone;
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            ret |= IDLViewContentGravityTop;
            break;
        case UIControlContentVerticalAlignmentBottom:
            ret |= IDLViewContentGravityBottom;
            break;
        case UIControlContentVerticalAlignmentCenter:
            ret |= IDLViewContentGravityCenterVertical;
            break;
        case UIControlContentVerticalAlignmentFill:
            ret |= IDLViewContentGravityFillVertical;
            break;
    }
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft:
            ret |= IDLViewContentGravityLeft;
            break;
        case UIControlContentHorizontalAlignmentRight:
            ret |= IDLViewContentGravityRight;
            break;
        case UIControlContentHorizontalAlignmentCenter:
            ret |= IDLViewContentGravityCenterHorizontal;
            break;
        case UIControlContentHorizontalAlignmentFill:
            ret |= IDLViewContentGravityFillHorizontal;
            break;
    }
    return ret;
}

@end
 