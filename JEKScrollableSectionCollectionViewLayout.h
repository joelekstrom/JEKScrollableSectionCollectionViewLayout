//
//  JEKScrollableSectionCollectionViewLayout.h
//  Example Project
//
//  Created by Joel Ekström on 2018-07-19.
//  Copyright © 2018 Joel Ekström. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JEKScrollableSectionCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic) BOOL showsHorizontalScrollIndicators;

/**
 When YES, collectionView:viewForSupplementaryElementOfKind:atIndexPath:
 will be queried with the kind JEKCollectionElementKindSectionBackground,
 so you can optionally return a view to be used as a background for a section.
 */
@property (nonatomic) BOOL showsSectionBackgrounds;
extern NSString * const JEKCollectionElementKindSectionBackground;

@end

/**
 Implement this delegate protocol to listen for scrolling events on different sections.
 The protocol closely matches UIScrollViewDelegate. Simply conform to this protocol
 instead of UICollectionViewDelegateFlowLayout and implement the required methods.
 */
@protocol JEKCollectionViewDelegateScrollableSectionLayout <UICollectionViewDelegateFlowLayout>
@optional
- (void)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout *)layout section:(NSUInteger)section didScrollToOffset:(CGFloat)horizontalOffset;
- (void)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout *)layout sectionWillBeginDragging:(NSUInteger)section;
- (void)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout *)layout sectionWillEndDragging:(NSUInteger)section withVelocity:(CGFloat)velocity targetOffset:(inout CGFloat *)targetHorizontalOffset;
- (void)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout *)layout sectionDidEndDragging:(NSUInteger)section willDecelerate:(BOOL)decelerate;
- (void)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout *)layout sectionWillBeginDecelerating:(NSUInteger)section;
- (void)collectionView:(UICollectionView *)collectionView layout:(JEKScrollableSectionCollectionViewLayout *)layout sectionDidEndDecelerating:(NSUInteger)section;
@end
