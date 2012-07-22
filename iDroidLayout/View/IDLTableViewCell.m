//
//  IDLTableViewCell.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLTableViewCell.h"
#import "IDLLayoutInflater.h"

@implementation IDLTableViewCell

@synthesize layoutBridge = _layoutBridge;

- (id)initWithLayoutResource:(NSString *)resource reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
        [inflater inflateResource:resource intoRootView:bridge attachToRoot:TRUE];
        [inflater release];
        
        _layoutBridge = bridge;
    }
    return self;
}

- (id)initWithLayoutURL:(NSURL *)url reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
        [inflater inflateURL:url intoRootView:bridge attachToRoot:TRUE];
        [inflater release];
        
        _layoutBridge = bridge;
    }
    return self;
}

- (BOOL)isViewGroup {
    return TRUE;
}

@end
