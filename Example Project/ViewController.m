//
//  ViewController.m
//  JEKScrollableSectionCollectionViewLayout
//
//  Created by Joel Ekström on 2017-08-17.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "ViewController.h"
#import "JEKScrollableSectionCollectionViewLayout.h"
#import "ExampleCell.h"

@interface ViewController () <UICollectionViewDelegateFlowLayout, JEKCollectionViewDelegateScrollableSectionLayout>

@property (nonatomic, assign) UIEdgeInsets section1Insets;
@property (nonatomic, strong) NSArray<NSMutableArray<NSNumber *> *> *testData;
@property (nonatomic, assign) NSInteger flowLayoutSectionIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    JEKScrollableSectionCollectionViewLayout *layout = (JEKScrollableSectionCollectionViewLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(80.0, 80.0);
    layout.headerReferenceSize = CGSizeMake(100.0, 50.0);
    self.section1Insets = UIEdgeInsetsMake(20.0, 100.0, 20.0, 100.0);
    self.testData = [self generateTestData];
    self.flowLayoutSectionIndex = 4;

    layout.showsSectionBackgrounds = NO; // Set to YES to test background views
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:JEKCollectionElementKindSectionBackground withReuseIdentifier:@"backgroundView"];
}

- (NSArray *)generateTestData
{
    // Create 20 sections with a random amount of items in each
    NSMutableArray *sections = [NSMutableArray new];
    for (NSInteger section = 0; section < 20; section++) {
        NSMutableArray *sectionArray = [NSMutableArray new];
        [sections addObject:sectionArray];
        NSInteger numberOfItems = 20 + arc4random_uniform(50);
        for (NSInteger item = 0; item < numberOfItems; item++) {
            [sectionArray addObject:@(item)];
        }
    }
    return [sections copy];
}

- (NSNumber *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.testData[indexPath.section][indexPath.item];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.testData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.testData[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSNumber *item = [self itemAtIndexPath:indexPath];
    NSString *reuseIdentifier = item.integerValue % 2 == 0 ? @"lightGrayCell" : @"darkGrayCell";
    ExampleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = item.stringValue;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == self.flowLayoutSectionIndex) {
        return CGSizeMake(80.0 + ((float)arc4random_uniform(20) - 10.0), 80.0 + ((float)arc4random_uniform(20) - 10.0));
    }
    return collectionViewLayout.itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 1) {
        return self.section1Insets;
    }
    return collectionViewLayout.sectionInset;
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
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        UILabel *label = view.subviews.firstObject;

        if (indexPath.section == 0) {
            label.text = @"Section with multiple sizes";
        } else if (indexPath.section == 1) {
            label.text = @"Section with insets";
        } else if (indexPath.section == 2) {
            label.text = @"Section with interItemSpacing";
        } else if (indexPath.section == self.flowLayoutSectionIndex) {
            label.text = @"Section with multiple sizes, using flow layout";
        } else {
            label.text = [NSString stringWithFormat:@"Section %ld", indexPath.section];
        }
        return view;
    } else if (kind == JEKCollectionElementKindSectionBackground) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"backgroundView" forIndexPath:indexPath];
        view.backgroundColor = indexPath.section % 2 == 0 ? [UIColor colorWithRed:41.0 / 255.0 green:70.0 / 255.0 blue:142.0 / 255.0 alpha:1.0] : [UIColor colorWithRed:29.0 / 255.0 green:96.00 / 255.0 blue:96.0 / 255.0 alpha:1.0];
        return view;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did select item: %@", indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"End displaying cell at %@", indexPath);
}

- (BOOL)shouldUseFlowLayoutInSection:(NSInteger)section
{
    return self.flowLayoutSectionIndex == section;
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout*)collectionViewLayout shouldUseFlowLayoutInSection:(NSInteger)section
{
    return [self shouldUseFlowLayoutInSection: section];
}

- (nullable JEKScrollViewConfiguration *)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout *)layout scrollViewConfigurationForSection:(NSUInteger)section
{
    JEKScrollViewConfiguration * config = JEKScrollViewConfiguration.defaultConfiguration;
    config.scrollEnabled = ![self shouldUseFlowLayoutInSection: section];
    return config;
}


@end
