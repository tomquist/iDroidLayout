//
//  IDLTextArea.m
//  iDroidLayout
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLTextArea.h"
#import "UIView+IDL_Layout.h"
#import "UILabel+IDL_View.h"

@implementation IDLTextArea

- (void)setText:(NSString *)text {
    [super setText:text];
    [self requestLayout];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self requestLayout];
}

@end
