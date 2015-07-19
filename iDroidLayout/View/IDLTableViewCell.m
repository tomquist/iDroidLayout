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


- (instancetype)initWithLayoutURL:(NSURL *)url reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
        [inflater inflateURL:url intoRootView:bridge attachToRoot:TRUE];

        _layoutBridge = bridge;
    }
    return self;
}

- (instancetype)initWithLayoutResource:(NSString *)resource reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
        [inflater inflateResource:resource intoRootView:bridge attachToRoot:TRUE];

        _layoutBridge = bridge;
    }
    return self;
}

- (BOOL)isViewGroup {
    return TRUE;
}

- (CGFloat)requiredHeightInView:(UIView *)view {
    [self.layoutBridge measureWithWidthMeasureSpec:IDLLayoutMeasureSpecMake(view.bounds.size.width, IDLLayoutMeasureSpecModeExactly) heightMeasureSpec:IDLLayoutMeasureSpecMake(CGFLOAT_MAX, IDLLayoutMeasureSpecModeAtMost)];
    return self.layoutBridge.measuredSize.height;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.layoutBridge sizeThatFits:size];
}

@end
