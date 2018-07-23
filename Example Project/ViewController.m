//
//  ViewController.m
//  JEKScrollableSectionCollectionView
//
//  Created by Joel Ekström on 2017-08-17.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "ViewController.h"
#import "JEKScrollableSectionCollectionViewLayout.h"
#import "ExampleCell.h"

@interface ViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) UIEdgeInsets section1Insets;
@property (nonatomic, strong) NSArray<NSMutableArray<NSNumber *> *> *testData;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    JEKScrollableSectionCollectionViewLayout *layout = (JEKScrollableSectionCollectionViewLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(80.0, 80.0);
    layout.headerReferenceSize = CGSizeMake(100.0, 50.0);
    self.section1Insets = UIEdgeInsetsMake(5.0, 100.0, 5.0, 20.0);
    self.testData = [self generateTestData];
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 1) {
        return self.section1Insets;
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView heightForSectionAtIndex:(NSInteger)section
{
    JEKScrollableSectionCollectionViewLayout *layout = (JEKScrollableSectionCollectionViewLayout *)collectionView.collectionViewLayout;
    if (section == 0) {
        return layout.itemSize.height * 3 + 10.0; // 10.0 is the line spacing, (5.0 * 2)
    } else if (section == 1) {
        return layout.itemSize.height + _section1Insets.top + _section1Insets.bottom;
    } else {
        return layout.itemSize.height;
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
    return 0.0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    UILabel *label = view.subviews.firstObject;

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
