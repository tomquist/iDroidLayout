//
// Created by Tom Quist on 06.12.14.
// Copyright (c) 2014 Tom Quist. All rights reserved.
//


@interface CollectionViewItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *itemDescription;

+ (instancetype)createRandomItem;
+ (NSArray *)randomItems;

@end

