//
// Created by Tom Quist on 06.12.14.
// Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import "CollectionViewExampleViewController.h"
#import "IDLCollectionViewCell.h"
#import "UIView+IDL_Layout.h"
#import "ExampleCollectionViewCell.h"
#import "CollectionViewItem.h"

@interface CollectionViewExampleViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation CollectionViewExampleViewController {
    NSArray *_items;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static ExampleCollectionViewCell *prototypeCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prototypeCell = [[ExampleCollectionViewCell alloc] init];
    });
    [prototypeCell setItem:_items[(NSUInteger) indexPath.item]];
    CGSize size = collectionView.bounds.size;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *) collectionViewLayout;
    if (flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        size.height = [prototypeCell requiredHeightForWidth:size.width];
    }
    else
    {
        size.width = [prototypeCell requiredWidthForHeight:size.height];
    }

    return size;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewItem *item = _items[(NSUInteger) indexPath.item];
    ExampleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setItem:item];
    return cell;
}

#pragma mark - UICollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _items = [CollectionViewItem randomItems];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.collectionView registerClass:[ExampleCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    if ([self.collectionView.collectionViewLayout respondsToSelector:@selector(setEstimatedItemSize:)]) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
        //layout.estimatedItemSize = CGSizeMake(100, self.collectionView.bounds.size.width * 0.159f);
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
    ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).estimatedItemSize = CGSizeMake(size.width, size.width*0.159f);
}

@end