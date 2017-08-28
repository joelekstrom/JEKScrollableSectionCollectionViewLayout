//
//  JEKScrollableSectionCollectionView.m
//  JEKScrollableSectionCollectionView
//
//  Created by Joel Ekström on 2017-08-28.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import "JEKScrollableSectionCollectionView.h"

@class JEKScrollableCollectionViewController;
@interface JEKScrollableSectionCollectionView()

@property (nonatomic, strong) JEKScrollableCollectionViewController *controller;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *registeredCellClasses;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UINib *> *registeredCellNibs;
@property (nonatomic, assign) NSUInteger registrationHash;

@end

@interface JEKScrollableCollectionViewController : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) JEKScrollableSectionCollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *referenceLayout;
@property (nonatomic, weak) id<UICollectionViewDataSource> externalDataSource;
@property (nonatomic, weak) id<UICollectionViewDelegateFlowLayout> externalDelegate;

- (instancetype)initWithCollectionView:(JEKScrollableSectionCollectionView *)collectionView referenceLayout:(UICollectionViewFlowLayout *)referenceLayout;

@end

static NSString * const JEKCollectionViewWrapperCellIdentifier = @"JEKCollectionViewWrapperCellIdentifier";

@interface JEKCollectionViewWrapperCell : UICollectionViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger registrationHash;

- (void)registerCellClasses:(NSDictionary<NSString *, Class> *)classes nibs:(NSDictionary<NSString *, UINib *> *)nibs;

@end

#pragma mark -

@implementation JEKScrollableSectionCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)referenceLayout
{
    NSAssert([referenceLayout isKindOfClass:UICollectionViewFlowLayout.class], @"%@ must be initialized with a UICollectionViewFlowLayout", NSStringFromClass(self.class));
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.headerReferenceSize = referenceLayout.headerReferenceSize;
    layout.footerReferenceSize = referenceLayout.footerReferenceSize;
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.controller = [[JEKScrollableCollectionViewController alloc] initWithCollectionView:self referenceLayout:referenceLayout];
        self.registeredCellClasses = [NSMutableDictionary new];
        self.registeredCellNibs = [NSMutableDictionary new];
        [super registerClass:JEKCollectionViewWrapperCell.class forCellWithReuseIdentifier:JEKCollectionViewWrapperCellIdentifier];
    }
    return self;
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate
{
    [super setDelegate:delegate ? self.controller : nil];
    self.controller.externalDelegate = (id<UICollectionViewDelegateFlowLayout>)delegate;
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    [super setDataSource:dataSource ? self.controller : nil];
    self.controller.externalDataSource = dataSource;
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    _registeredCellClasses[identifier] = cellClass;
    [self updateRegistrationHash];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier
{
    _registeredCellNibs[identifier] = nib;
    [self updateRegistrationHash];
}

- (void)updateRegistrationHash
{
    self.registrationHash = [self.registeredCellClasses.description hash] ^ [self.registeredCellNibs.description hash];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    if ([identifier isEqualToString:JEKCollectionViewWrapperCellIdentifier]) {
        return [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    }

    JEKCollectionViewWrapperCell *cell = (JEKCollectionViewWrapperCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section]];
    return [cell.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
}

@end

#pragma mark -

@implementation JEKScrollableCollectionViewController

- (instancetype)initWithCollectionView:(JEKScrollableSectionCollectionView *)collectionView referenceLayout:(UICollectionViewFlowLayout *)referenceLayout
{
    if (self = [super init]) {
        self.collectionView = collectionView;
        self.referenceLayout = referenceLayout;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.collectionView) {
        return [self.externalDataSource numberOfSectionsInCollectionView:collectionView];
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return 1;
    }
    return [self.externalDataSource collectionView:self.collectionView numberOfItemsInSection:collectionView.tag];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        JEKCollectionViewWrapperCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JEKCollectionViewWrapperCellIdentifier forIndexPath:indexPath];
        cell.collectionView.tag = indexPath.section;
        if (cell.registrationHash != self.collectionView.registrationHash) {
            [cell registerCellClasses:self.collectionView.registeredCellClasses nibs:self.collectionView.registeredCellNibs];
            cell.registrationHash = self.collectionView.registrationHash;
        }
        return cell;
    }
    return [self.externalDataSource collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView && [self.externalDataSource respondsToSelector:_cmd]) {
        return [self.externalDataSource collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    return nil;
}

#pragma mark UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        CGSize size;
        size.width = CGRectGetWidth(collectionView.frame);
        size.height = self.referenceLayout.itemSize.height + self.referenceLayout.minimumLineSpacing;
        if ([self.externalDelegate respondsToSelector:@selector(collectionView:heightForSectionAtIndex:)]) {
            size.height = [(id)self.externalDelegate collectionView:self.collectionView heightForSectionAtIndex:indexPath.section];
        }
        return size;
    }

    if ([self.externalDelegate respondsToSelector:_cmd]) {
        return [self.externalDelegate collectionView:self.collectionView layout:self.referenceLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
    }

    return self.referenceLayout.itemSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        if ([self.externalDelegate respondsToSelector:_cmd]) {
            return [self.externalDelegate collectionView:self.collectionView layout:self.referenceLayout referenceSizeForHeaderInSection:section];
        }
        return self.referenceLayout.headerReferenceSize;
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        if ([self.externalDelegate respondsToSelector:_cmd]) {
            return [self.externalDelegate collectionView:self.collectionView layout:self.referenceLayout referenceSizeForFooterInSection:section];
        }
        return self.referenceLayout.footerReferenceSize;
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return 0.0;
    }

    if ([self.externalDelegate respondsToSelector:_cmd]) {
        return [self.externalDelegate collectionView:self.collectionView layout:self.referenceLayout minimumLineSpacingForSectionAtIndex:collectionView.tag];
    }

    return self.referenceLayout.minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return 0.0;
    }

    if ([self.externalDelegate respondsToSelector:_cmd]) {
        return [self.externalDelegate collectionView:self.collectionView layout:self.referenceLayout minimumInteritemSpacingForSectionAtIndex:collectionView.tag];
    }

    return self.referenceLayout.minimumInteritemSpacing;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        JEKCollectionViewWrapperCell *wrapperCell = (JEKCollectionViewWrapperCell *)cell;
        wrapperCell.collectionView.dataSource = self;
        wrapperCell.collectionView.delegate = self;
        [wrapperCell.collectionView reloadData];
    } else if ([self.externalDelegate respondsToSelector:_cmd]) {
        [self.externalDelegate collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        JEKCollectionViewWrapperCell *wrapperCell = (JEKCollectionViewWrapperCell *)cell;
        wrapperCell.collectionView.dataSource = nil;
        wrapperCell.collectionView.delegate = nil;
    } else if ([self.externalDelegate respondsToSelector:_cmd]) {
        [self.externalDelegate collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        return NO;
    } else if ([self.externalDelegate respondsToSelector:_cmd]) {
        return [self.externalDelegate collectionView:self.collectionView shouldHighlightItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        return NO;
    } else if ([self.externalDelegate respondsToSelector:_cmd]) {
        return [self.externalDelegate collectionView:self.collectionView shouldSelectItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.externalDelegate respondsToSelector:_cmd]) {
        return [self.externalDelegate collectionView:self.collectionView shouldDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.externalDelegate respondsToSelector:_cmd]) {
        [self.externalDelegate collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:collectionView.tag]];
    }
}

@end

@implementation JEKCollectionViewWrapperCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (void)registerCellClasses:(NSDictionary<NSString *, Class> *)classes nibs:(NSDictionary<NSString *, UINib *> *)nibs
{
    [classes enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, Class class, BOOL * _Nonnull stop) {
        [self.collectionView registerClass:class forCellWithReuseIdentifier:identifier];
    }];

    [nibs enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, UINib *nib, BOOL * _Nonnull stop) {
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }];
}

@end
