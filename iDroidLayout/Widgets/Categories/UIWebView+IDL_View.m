//
//  UIWebView+IDL_View.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIWebView+IDL_View.h"
#import "UIView+IDL_Layout.h"

@implementation UIWebView (IDL_View)

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];
    NSString *src = attrs[@"src"];
    if (src != nil) {
        NSURL *url = [NSURL URLWithString:src];
        [self loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

@end
