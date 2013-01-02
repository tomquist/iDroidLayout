//
//  IDLLayoutViewController.m
//  iDroidLayout
//
//  Created by Tom Quist on 23.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayoutViewController.h"
#import "IDLLayoutInflater.h"

@implementation IDLLayoutViewController

- (void)dealloc {
    [_layoutUrl release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (nibBundleOrNil == nil) {
            nibBundleOrNil = [NSBundle mainBundle];
        }
        if (nibNameOrNil != nil) {
            _layoutUrl = [[nibBundleOrNil URLForResource:nibNameOrNil withExtension:@"xml"] retain];
        }
    }
    return self;
}

- (id)initWithLayoutName:(NSString *)layoutNameOrNil bundle:(NSBundle *)layoutBundleOrNil {
    self = [self initWithNibName:layoutNameOrNil bundle:layoutBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithLayoutURL:(NSURL *)layoutURL {
    self = [super init];
    if (self) {
        _layoutUrl = [layoutURL retain];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView {
    IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    bridge.resizeOnKeyboard = TRUE;
    bridge.scrollToTextField = TRUE;
    bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (_layoutUrl != nil) {
        IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
        inflater.actionTarget = self;
        [inflater inflateURL:_layoutUrl intoRootView:bridge attachToRoot:TRUE];
        [inflater release];
    }
    self.view = bridge;
    [bridge release];
}

- (IDLLayoutBridge *)view {
    return (IDLLayoutBridge *)super.view;
}

@end
