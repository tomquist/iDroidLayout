//
// Created by Tom Quist on 06.12.14.
// Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDLCollectionViewCell.h"

@class CollectionViewItem;


@interface ExampleCollectionViewCell : IDLCollectionViewCell

- (void)setItem:(CollectionViewItem *)item;

@end