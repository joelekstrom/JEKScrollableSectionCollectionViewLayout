//
//  IntegrationTests.m
//  Integration Tests
//
//  Created by Joel Ekström on 2018-08-01.
//  Copyright © 2018 Joel Ekström. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JEKScrollableSectionCollectionViewLayout.h"

@interface LayoutMeasurements : NSObject <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGSize headerSize;
@property (nonatomic, assign) CGSize footerSize;
@property (nonatomic, assign) UIEdgeInsets sectionInsets;
@property (nonatomic, assign) CGFloat interItemSpacing;
@property (nonatomic, assign) NSInteger numberOfSections;
@property (nonatomic, assign) NSInteger numberOfItems;
@end

@interface Tests : XCTestCase
@property (nonatomic, strong) JEKScrollableSectionCollectionViewLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LayoutMeasurements *measurements;
@end

#define AssertEqualCGSizes(A, B) XCTAssertTrue(CGSizeEqualToSize(A, B), @"%@ is not equal to %@", NSStringFromCGSize(A), NSStringFromCGSize(B))
#define AssertEqualCGRects(A, B) XCTAssertTrue(CGRectEqualToRect(A, B), @"%@ is not equal to %@", NSStringFromCGRect(A), NSStringFromCGRect(B))

@implementation Tests

- (void)setUp {
    [super setUp];
    self.layout = [JEKScrollableSectionCollectionViewLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 100.0) collectionViewLayout:self.layout];
    self.measurements = [LayoutMeasurements new];
    self.measurements.numberOfSections = 1;
    self.measurements.numberOfItems = 2;
    self.measurements.itemSize = CGSizeMake(10, 10);
    self.collectionView.dataSource = self.measurements;
    self.collectionView.delegate = self.measurements;
}

- (void)testInterItemSpacing {
    self.measurements.interItemSpacing = 5.0;
    [self.layout prepareLayout];
    UICollectionViewLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    CGRect expectedFrame = CGRectZero;
    expectedFrame.origin.x = self.measurements.itemSize.width + self.measurements.interItemSpacing;
    expectedFrame.size = self.measurements.itemSize;
    AssertEqualCGRects(attributes.frame, expectedFrame);
}

- (void)testSectionInsets {
    self.measurements.sectionInsets = UIEdgeInsetsMake(10, 20, 10, 50);
    [self.layout prepareLayout];
    UICollectionViewLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    CGRect expectedFrame = CGRectZero;
    expectedFrame.origin.x = self.measurements.sectionInsets.left + self.measurements.itemSize.width;
    expectedFrame.origin.y = self.measurements.sectionInsets.top;
    expectedFrame.size = self.measurements.itemSize;
    AssertEqualCGRects(attributes.frame, expectedFrame);

    CGSize expectedContentSize;
    expectedContentSize.width = self.collectionView.frame.size.width;
    expectedContentSize.height = self.measurements.sectionInsets.top + self.measurements.itemSize.height + self.measurements.sectionInsets.bottom;
    AssertEqualCGSizes(self.layout.collectionViewContentSize, expectedContentSize);
}

- (void)testHeaderViewLayout {
    self.measurements.sectionInsets = UIEdgeInsetsMake(5, 5, 0, 0);
    self.measurements.headerSize = CGSizeMake(10, 25);
    [self.layout prepareLayout];
    UICollectionViewLayoutAttributes *headerAttributes = [self.layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathWithIndex:0]];
    XCTAssertEqualObjects(headerAttributes.representedElementKind, UICollectionElementKindSectionHeader);

    CGRect expectedHeaderFrame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.measurements.headerSize.height);
    AssertEqualCGRects(headerAttributes.frame, expectedHeaderFrame);

    UICollectionViewLayoutAttributes *itemAttributes = [self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    XCTAssertEqual(itemAttributes.frame.origin.y, self.measurements.headerSize.height + self.measurements.sectionInsets.top);
}

- (void)testFooterViewLayout {
    self.measurements.sectionInsets = UIEdgeInsetsMake(5, 5, 25, 0);
    self.measurements.footerSize = CGSizeMake(10, 25);
    [self.layout prepareLayout];
    UICollectionViewLayoutAttributes *footerAttributes = [self.layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathWithIndex:0]];
    XCTAssertEqualObjects(footerAttributes.representedElementKind, UICollectionElementKindSectionFooter);

    CGRect expectedFooterFrame = CGRectMake(0, self.measurements.sectionInsets.top + self.measurements.itemSize.height + self.measurements.sectionInsets.bottom, self.collectionView.frame.size.width, self.measurements.footerSize.height);
    AssertEqualCGRects(footerAttributes.frame, expectedFooterFrame);
    XCTAssertEqual(self.layout.collectionViewContentSize.height, self.measurements.sectionInsets.top + self.measurements.itemSize.height + self.measurements.sectionInsets.bottom + self.measurements.footerSize.height);
}

@end

@implementation LayoutMeasurements
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.interItemSpacing;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.numberOfSections;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.sectionInsets;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItems;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return self.headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return self.footerSize;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return nil;
}
@end
