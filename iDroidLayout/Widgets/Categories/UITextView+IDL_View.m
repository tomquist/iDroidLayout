//
//  UITextView+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "UITextView+IDL_View.h"
#import "UIView+IDL_ViewGroup.h"

@implementation UITextView (IDL_View)

- (void)setPadding:(UIEdgeInsets)padding {
    [super setPadding:padding];
    self.contentInset = padding;
}

- (BOOL)isViewGroup {
    return FALSE;
}

@end
