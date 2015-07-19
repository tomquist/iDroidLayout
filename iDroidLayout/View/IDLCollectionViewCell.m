//
//  IDLCollectionViewCell.m
//  iDroidLayout
//
//  Created by Tom Quist on 06.12.14.
//  Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import "IDLCollectionViewCell.h"
#import "IDLLayoutBridge.h"
#import "IDLLayoutInflater.h"

@implementation IDLCollectionViewCell


- (CGSize)sizeThatFits:(CGSize)size {
    return [self.layoutBridge sizeThatFits:size];
}

- (CGSize)preferredSize {
    [self.layoutBridge measureWithWidthMeasureSpec:IDLLayoutMeasureSpecMake(CGFLOAT_MAX, IDLLayoutMeasureSpecModeAtMost) heightMeasureSpec:IDLLayoutMeasureSpecMake(CGFLOAT_MAX, IDLLayoutMeasureSpecModeAtMost)];
    return self.layoutBridge.measuredSize;
}

- (CGFloat)requiredWidthForHeight:(CGFloat)height {
    [self.layoutBridge measureWithWidthMeasureSpec:IDLLayoutMeasureSpecMake(CGFLOAT_MAX, IDLLayoutMeasureSpecModeAtMost) heightMeasureSpec:IDLLayoutMeasureSpecMake(height, IDLLayoutMeasureSpecModeExactly)];
    return self.layoutBridge.measuredSize.width;
}

- (CGFloat)requiredHeightForWidth:(CGFloat)width {
    [self.layoutBridge measureWithWidthMeasureSpec:IDLLayoutMeasureSpecMake(width, IDLLayoutMeasureSpecModeExactly) heightMeasureSpec:IDLLayoutMeasureSpecMake(CGFLOAT_MAX, IDLLayoutMeasureSpecModeAtMost)];
    return self.layoutBridge.measuredSize.height;
}

- (instancetype)initWithLayoutURL:(NSURL *)url {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        self.contentView.translatesAutoresizingMaskIntoConstraints = TRUE;
        IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
        [inflater inflateURL:url intoRootView:bridge attachToRoot:TRUE];

        _layoutBridge = bridge;
    }
    return self;
}

- (instancetype)initWithLayoutResource:(NSString *)resource {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
        self.contentView.translatesAutoresizingMaskIntoConstraints = TRUE;
        [inflater inflateResource:resource intoRootView:bridge attachToRoot:YES];

        _layoutBridge = bridge;
    }
    return self;
}

@end
