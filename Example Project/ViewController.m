//
//  ViewController.m
//  JEKScrollableSectionCollectionView
//
//  Created by Joel Ekström on 2017-08-17.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "ViewController.h"
#import "JEKScrollableSectionCollectionView.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) UIEdgeInsets section1Insets;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = CGSizeMake(80, 80);
    flowLayout.headerReferenceSize = CGSizeMake(100.0, 40.0);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;

    self.collectionView = [[JEKScrollableSectionCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.view addSubview:self.collectionView];

    self.section1Insets = UIEdgeInsetsMake(5.0, 100.0, 5.0, 20.0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 20;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = indexPath.item % 2 == 0 ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 1) {
        return self.section1Insets;
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(JEKScrollableSectionCollectionView *)collectionView heightForSectionAtIndex:(NSInteger)section
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    if (section == 0) {
        return flowLayout.itemSize.height * 3 + 10.0; // 10.0 is the line spacing, (5.0 * 2)
    } else if (section == 1) {
        return flowLayout.itemSize.height + _section1Insets.top + _section1Insets.bottom;
    } else {
        return flowLayout.itemSize.height;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 0) {
        return 5.0;
    }
    return collectionViewLayout.minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 2) {
        return 5.0;
    }
    return collectionViewLayout.minimumInteritemSpacing;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];

    UILabel *label = view.subviews.firstObject;
    if (!label) {
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
    }

    if (indexPath.section == 0) {
        label.text = @"Section with multiple rows";
    } else if (indexPath.section == 1) {
        label.text = @"Section with insets";
    } else if (indexPath.section == 2) {
        label.text = @"Section with interItemSpacing";
    } else {
        label.text = [NSString stringWithFormat:@"Section %ld", indexPath.section];
    }
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did select item: %@", indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"End displaying cell at %@", indexPath);
}

@end
