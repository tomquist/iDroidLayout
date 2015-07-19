//
// Created by Tom Quist on 06.12.14.
// Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import "ExampleCollectionViewCell.h"
#import "CollectionViewItem.h"
#import "IDLLayoutBridge.h"


@implementation ExampleCollectionViewCell {
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UILabel *_descriptionLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithLayoutResource:@"collectionViewCell.xml"];
    if (self) {
        _titleLabel = (UILabel *)[self.layoutBridge findViewById:@"title"];
        _subtitleLabel = (UILabel *)[self.layoutBridge findViewById:@"subtitle"];
        _descriptionLabel = (UILabel *)[self.layoutBridge findViewById:@"description"];
    }
    return self;
}

- (void)setItem:(CollectionViewItem *)item {
    
    _titleLabel.text = item.title;
    _subtitleLabel.text = item.subtitle;
    _descriptionLabel.text = item.itemDescription;
}

/*- (CGSize)sizeThatFits:(CGSize)size {
    size.height = [self requiredHeightForWidth:size.width];
    return size;
} */

@end