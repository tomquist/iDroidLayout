//
//  IDLLayoutInflaterTest.m
//  iDroidLayout
//
//  Created by Tom Quist on 14.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayoutInflaterTest.h"
#import <iDroidLayout/iDroidLayout.h>

@interface IDLCustomTestView : UIView

@end

@implementation IDLCustomTestView

@end

@implementation IDLLayoutInflaterTest

- (void)testInflateURL {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testLayout1" withExtension:@"xml"];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    
    IDLLayoutBridge *rootView = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *view = [inflater inflateURL:url intoRootView:rootView attachToRoot:FALSE];
    STAssertNotNil(view, @"Inflater returned nil when inflating simple view");
}

- (void)testInflateAttachToRootTrue {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testLayout1" withExtension:@"xml"];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    
    IDLLayoutBridge *rootView = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *view = [inflater inflateURL:url intoRootView:rootView attachToRoot:TRUE];
    STAssertEquals(view, rootView, @"Inflater did not return rootView");
    STAssertEquals((NSUInteger)1, [[rootView subviews] count], @"Inflater did not attach inflated view to rootView");
}

- (void)testInflateAttachToRootFalse {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testLayout1" withExtension:@"xml"];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    
    IDLLayoutBridge *rootView = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *view = [inflater inflateURL:url intoRootView:rootView attachToRoot:FALSE];
    STAssertNil([view superview], @"Inflater attached inflated view to rootView");
}

- (void)testInflateCustomView {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testLayout2" withExtension:@"xml"];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    
    IDLLayoutBridge *rootView = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *view = [inflater inflateURL:url intoRootView:rootView attachToRoot:FALSE];
    STAssertEquals([IDLCustomTestView class], [view class], @"Inflater inflated the wrong view type");
}

- (void)testInflateIDLPrefixedViews {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testLayout3" withExtension:@"xml"];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    
    IDLLayoutBridge *rootView = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *view = [inflater inflateURL:url intoRootView:rootView attachToRoot:FALSE];
    STAssertEquals([IDLCustomTestView class], [view class], @"Inflater didn't resolve the non-prefixed view name to a prefixed class name");
}


- (void)testInflateSubviews {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testLayout4" withExtension:@"xml"];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    
    IDLLayoutBridge *rootView = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *view = [inflater inflateURL:url intoRootView:rootView attachToRoot:FALSE];
    STAssertEquals([IDLLinearLayout class], [view class], @"Inflater did not inflate the LinearLayout root view");
    STAssertEquals((NSUInteger)2, [[view subviews] count], @"Inflater inflated the wrong number of subviews");
}

@end
