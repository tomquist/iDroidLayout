//
// Created by Tom Quist on 06.12.14.
// Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import "LoremIpsum.h"
#include "CollectionViewItem.h"

@implementation CollectionViewItem

+ (instancetype)createRandomItem  {
    CollectionViewItem *item = [[self alloc] init];
    item.title = [LoremIpsum title];
    item.subtitle = [LoremIpsum sentence];
    item.itemDescription = [LoremIpsum paragraph];
    return item;
}

+ (NSArray *)randomItems {
    static dispatch_once_t onceToken;
    static NSArray *result;
    dispatch_once(&onceToken, ^{
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i<1000; i++) {
            [items addObject:[CollectionViewItem createRandomItem]];
        }
        result = items;
    });
    return result;
}


@end