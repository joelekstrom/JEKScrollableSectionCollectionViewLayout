//
//  JEKScrollableSectionCollectionViewLayout.m
//  Example Project
//
//  Created by Joel Ekström on 2018-07-19.
//  Copyright © 2018 Joel Ekström. All rights reserved.
//

#import "JEKScrollableSectionCollectionViewLayout.h"

static NSString * const JEKScrollableCollectionViewLayoutScrollViewKind = @"JEKScrollableCollectionViewLayoutScrollViewKind";

@interface JEKScrollableSectionDecorationViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, assign) CGSize sectionSize;
@property (nonatomic, assign) CGFloat sectionOffset;
@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;
@end

@interface JEKScrollableSectionInfo : NSObject
@property (nonatomic, strong) NSArray<UICollectionViewLayoutAttributes *> *itemAttributes;
@property (nonatomic, strong) JEKScrollableSectionDecorationViewLayoutAttributes *decorationViewAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *headerViewAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *footerViewAttributes;
@property (nonatomic, assign) CGFloat offset;
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesIntersectingRect:(CGRect)rect;
@end

@interface JEKScrollableSectionLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext
@property (nonatomic, strong) JEKScrollableSectionInfo *invalidatedSection;
@end

@interface JEKScrollableSectionCollectionViewLayout() <UIScrollViewDelegate>
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL isAdjustingBoundsToInvalidateHorizontalSection;
@property (nonatomic, strong) NSArray<JEKScrollableSectionInfo *> *sections;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *offsetCache;
@end

@interface JEKScrollableSectionDecorationView : UICollectionReusableView <UIGestureRecognizerDelegate>
@property (nonatomic, readonly, strong) UIScrollView *scrollView;
@end

@interface JEKScrollView : UIScrollView @end

@implementation JEKScrollableSectionCollectionViewLayout

- (instancetype)init
{
    if (self = [super init]) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    [self registerClass:JEKScrollableSectionDecorationView.class forDecorationViewOfKind:JEKScrollableCollectionViewLayoutScrollViewKind];
    self.offsetCache = [NSMutableDictionary new];
    self.showsHorizontalScrollIndicators = YES;
}

+ (Class)invalidationContextClass
{
    return JEKScrollableSectionLayoutInvalidationContext.class;
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection
{
    return YES;
}

- (void)prepareLayout
{
    [super prepareLayout];

    if (self.sections != nil) {
        return;
    }

    NSMutableArray<JEKScrollableSectionInfo *> *sections = [NSMutableArray new];
    NSInteger numberOfSections = [[self.collectionView dataSource] numberOfSectionsInCollectionView:self.collectionView];
    CGFloat yOffset = 0.0;

    for (NSInteger section = 0; section < numberOfSections; ++section) {
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathWithIndex:section];
        JEKScrollableSectionInfo *sectionInfo = [JEKScrollableSectionInfo new];
        CGRect sectionFrame = CGRectMake(0.0, yOffset, 0.0, 0.0);

        UIEdgeInsets sectionInsets = [self sectionInsetsForSection:section];
        CGFloat interItemSpacing = [self interItemSpacingForSection:section];
        sectionFrame.size.width = sectionInsets.left;

        sectionInfo.headerViewAttributes = [self supplementaryViewAttributesOfKind:UICollectionElementKindSectionHeader atIndexPath:sectionIndexPath];
        sectionInfo.headerViewAttributes.frame = CGRectOffset(sectionInfo.headerViewAttributes.frame, 0.0, yOffset);
        sectionFrame.origin.y += CGRectGetHeight(sectionInfo.headerViewAttributes.frame);

        NSMutableArray *items = [NSMutableArray new];
        for (NSInteger item = 0; item < [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section]; ++item) {
            NSIndexPath *indexPath = [sectionIndexPath indexPathByAddingIndex:item];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

            CGRect frame;
            frame.size = [self itemSizeForIndexPath:indexPath];
            frame.origin.x = CGRectGetMaxX(sectionFrame) + (item == 0 ? 0.0 : interItemSpacing);
            frame.origin.y = CGRectGetMinY(sectionFrame) + sectionInsets.top;
            sectionFrame.size.width += frame.size.width + (item == 0 ? 0.0 : interItemSpacing);
            sectionFrame.size.height = MAX(CGRectGetMaxY(frame) - sectionFrame.origin.y, sectionFrame.size.height);
            attributes.frame = frame;
            [items addObject:attributes];
        }

        sectionInfo.itemAttributes = [items copy];
        sectionFrame.size.width += sectionInsets.right;
        sectionFrame.size.height += sectionInsets.bottom;
        yOffset = CGRectGetMaxY(sectionFrame);

        sectionInfo.decorationViewAttributes = [JEKScrollableSectionDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:JEKScrollableCollectionViewLayoutScrollViewKind withIndexPath:sectionIndexPath];
        sectionInfo.decorationViewAttributes.frame = CGRectMake(0, sectionFrame.origin.y, self.collectionView.frame.size.width, sectionFrame.size.height);
        sectionInfo.decorationViewAttributes.zIndex = 1;
        sectionInfo.decorationViewAttributes.sectionSize = sectionFrame.size;
        sectionInfo.decorationViewAttributes.showsHorizontalScrollIndicator = self.showsHorizontalScrollIndicators;

        sectionInfo.footerViewAttributes = [self supplementaryViewAttributesOfKind:UICollectionElementKindSectionFooter atIndexPath:sectionIndexPath];
        sectionInfo.footerViewAttributes.frame = CGRectOffset(sectionInfo.headerViewAttributes.frame, 0.0, yOffset);
        yOffset += CGRectGetHeight(sectionInfo.footerViewAttributes.frame);

        [sectionInfo setOffset:self.offsetCache[@(section)].floatValue];
        [sections addObject:sectionInfo];
    }

    self.sections = [sections copy];
    self.contentSize = CGSizeMake(self.collectionView.frame.size.width, yOffset);
}

- (UICollectionViewLayoutAttributes *)supplementaryViewAttributesOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = kind == UICollectionElementKindSectionHeader ? [self headerSizeForSection:indexPath.section] : [self footerSizeForSection:indexPath.section];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }

    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    attributes.frame = CGRectMake(0.0, 0.0, self.collectionView.frame.size.width, size.height);
    return attributes;
}

- (void)invalidateLayoutWithContext:(JEKScrollableSectionLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];

    if (context.invalidateEverything) {
        self.sections = nil;
        return;
    }

    if (context.invalidatedSection) {
        context.invalidatedSection.offset = self.offsetCache[@([self.sections indexOfObject:context.invalidatedSection])].floatValue;
    }

    for (NSIndexPath *indexPath in context.invalidatedDecorationIndexPaths[JEKScrollableCollectionViewLayoutScrollViewKind]) {
        UICollectionViewLayoutAttributes *attributes = self.sections[indexPath.section].decorationViewAttributes;
        attributes.frame = CGRectMake(0.0, attributes.frame.origin.y, self.collectionView.frame.size.width, attributes.frame.size.height);
    }

    for (NSIndexPath *indexPath in context.invalidatedSupplementaryIndexPaths[UICollectionElementKindSectionHeader]) {
        UICollectionViewLayoutAttributes *attributes = self.sections[indexPath.section].headerViewAttributes;
        attributes.frame = CGRectMake(0.0, attributes.frame.origin.y, self.collectionView.frame.size.width, attributes.frame.size.height);
    }

    for (NSIndexPath *indexPath in context.invalidatedSupplementaryIndexPaths[UICollectionElementKindSectionFooter]) {
        UICollectionViewLayoutAttributes *attributes = self.sections[indexPath.section].footerViewAttributes;
        attributes.frame = CGRectMake(0.0, attributes.frame.origin.y, self.collectionView.frame.size.width, attributes.frame.size.height);
    }

    self.contentSize = CGSizeMake(self.collectionView.frame.size.width, self.contentSize.height);
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.sections[indexPath.section].itemAttributes[indexPath.row];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    JEKScrollableSectionInfo *section = self.sections[indexPath.section];
    return elementKind == UICollectionElementKindSectionHeader ? section.headerViewAttributes : section.footerViewAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (elementKind == JEKScrollableCollectionViewLayoutScrollViewKind) {
        return self.sections[indexPath.section].decorationViewAttributes;
    }
    return nil;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *visibleAttributes = [NSMutableArray new];
    BOOL anyVisibleSectionFound = NO;
    for (JEKScrollableSectionInfo *section in self.sections) {
        NSArray *intersectingAttributes = [section layoutAttributesIntersectingRect:rect];
        if (intersectingAttributes.count > 0) {
            anyVisibleSectionFound = YES;
            [visibleAttributes addObjectsFromArray:intersectingAttributes];
        }

        // Optimization: If we have seen previously intersecting items but the current one
        // doesn't intersect, we can break to avoid extra work since they are enumerated
        // in visible order.
        // TODO: Find the first visible section/items using binary search instead of enumerating
        // from first index. Right now, if the visible bounds are on section 3000, then 2999 sections will be enumerated
        // but not visible.
        else if (anyVisibleSectionFound) { break; }
    }
    return visibleAttributes;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger section = scrollView.tag;
    self.offsetCache[@(section)] = @(scrollView.contentOffset.x);

    JEKScrollableSectionLayoutInvalidationContext *invalidationContext = [JEKScrollableSectionLayoutInvalidationContext new];
    invalidationContext.invalidatedSection = self.sections[section];
    [self invalidateLayoutWithContext:invalidationContext];
    [self adjustBoundsToInvalidateVisibleItemIndexPaths];
}

// NOTE: UICollectionView will only ever dequeue new cells if its bounds
// change, regardless if all layout attributes are updated within invalidateLayoutWithContext.
// Therefore a hack is required to make this layout work. After updating the frames in
// invalidateLayoutWithContext: above, slightly change the bounds to make sure that the
// collectionView queries for cells that may have entered the visible area.
- (void)adjustBoundsToInvalidateVisibleItemIndexPaths
{
    _isAdjustingBoundsToInvalidateHorizontalSection = YES;
    CGRect bounds = self.collectionView.bounds;
    bounds.origin.x = bounds.origin.x == 0.0 ? -0.1 : 0.0;
    [self.collectionView setBounds:bounds];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (_isAdjustingBoundsToInvalidateHorizontalSection) {
        _isAdjustingBoundsToInvalidateHorizontalSection = NO;
        return YES;
    } else if (newBounds.size.width != self.contentSize.width) {
        return YES;
    }
    return NO;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForBoundsChange:newBounds];
    if (newBounds.size.width != self.collectionViewContentSize.width) {
        for (JEKScrollableSectionInfo *section in self.sections) {
            NSIndexPath *sectionIndexPath = [NSIndexPath indexPathWithIndex:[self.sections indexOfObject:section]];
            [context invalidateDecorationElementsOfKind:JEKScrollableCollectionViewLayoutScrollViewKind atIndexPaths:@[sectionIndexPath]];
            [context invalidateSupplementaryElementsOfKind:UICollectionElementKindSectionHeader atIndexPaths:@[sectionIndexPath]];
            [context invalidateSupplementaryElementsOfKind:UICollectionElementKindSectionFooter atIndexPaths:@[sectionIndexPath]];
        }
    }
    return context;
}

#pragma mark - Measurements

- (id<UICollectionViewDelegateFlowLayout>)flowLayoutDelegate
{
    id delegate = self.collectionView.delegate;
    return [delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] ? delegate : nil;
}

- (CGFloat)interItemSpacingForSection:(NSUInteger)section
{
    id<UICollectionViewDelegateFlowLayout> delegate = [self flowLayoutDelegate];
    return [delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)] ? [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section] : self.minimumInteritemSpacing;
}

- (UIEdgeInsets)sectionInsetsForSection:(NSUInteger)section
{
    id<UICollectionViewDelegateFlowLayout> delegate = [self flowLayoutDelegate];
    return [delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)] ? [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section] : self.sectionInset;
}

- (CGSize)headerSizeForSection:(NSUInteger)section
{
    id<UICollectionViewDelegateFlowLayout> delegate = [self flowLayoutDelegate];
    return [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)] ? [delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section] : self.headerReferenceSize;
}

- (CGSize)footerSizeForSection:(NSUInteger)section
{
    id<UICollectionViewDelegateFlowLayout> delegate = [self flowLayoutDelegate];
    return [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)] ? [delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section] : self.footerReferenceSize;
}

- (CGSize)itemSizeForIndexPath:(NSIndexPath *)indexPath
{
    id<UICollectionViewDelegateFlowLayout> delegate = [self flowLayoutDelegate];
    return [delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)] ? [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath] : self.itemSize;
}

@end

@implementation JEKScrollableSectionDecorationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[JEKScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.directionalLockEnabled = YES;
        [self addSubview:_scrollView];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)applyLayoutAttributes:(JEKScrollableSectionDecorationViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    self.scrollView.tag = layoutAttributes.indexPath.section;
    self.scrollView.contentSize = layoutAttributes.sectionSize;
    self.scrollView.showsHorizontalScrollIndicator = layoutAttributes.showsHorizontalScrollIndicator;
    [self.scrollView setContentOffset:CGPointMake(layoutAttributes.sectionOffset, 0.0) animated:NO];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.superview) {
        UICollectionView *collectionView = (UICollectionView *)self.superview;
        self.scrollView.delegate = (JEKScrollableSectionCollectionViewLayout *)collectionView.collectionViewLayout;
        [collectionView addGestureRecognizer:self.scrollView.panGestureRecognizer];
        _scrollView.transform = [self shouldFlipLayoutDirection] ? CGAffineTransformMakeScale(-1.0, 1.0) : CGAffineTransformIdentity;
    } else {
        self.scrollView.delegate = nil;
        [self.scrollView.panGestureRecognizer.view removeGestureRecognizer:self.scrollView.panGestureRecognizer];
    }
}

- (BOOL)shouldFlipLayoutDirection
{
    if (@available(iOS 11.0, *)) {
        return self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    }
    return NO;
}

@end

@implementation JEKScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(nonnull UITouch *)touch
{
    JEKScrollableSectionDecorationView *decorationView = (JEKScrollableSectionDecorationView *)self.superview;
    if (CGRectContainsPoint(decorationView.frame, [touch locationInView:decorationView.superview])) {
        return YES;
    } else {
        // NOTE: This is a bugfix. When the collection view receives a touch it will pause the deceleration
        // of any scroll view that is currently scrolling - however the scroll view is never informed that it
        // is stopped, which makes its scrolling indicator stay visible forever. We make sure that the scroll view
        // knows that it is stopped by forcing a stop whenever anything else receives a touch.
        [self setContentOffset:self.contentOffset animated:NO];
        return NO;
    }
}

@end

@implementation JEKScrollableSectionDecorationViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    JEKScrollableSectionDecorationViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.sectionOffset = self.sectionOffset;
    copy.sectionSize = self.sectionSize;
    copy.showsHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
    return copy;
}

@end

@implementation JEKScrollableSectionInfo

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesIntersectingRect:(CGRect)rect
{
    NSMutableArray *intersectingAttributes = [NSMutableArray new];
    if (self.headerViewAttributes && CGRectIntersectsRect(self.headerViewAttributes.frame, rect)) {
        [intersectingAttributes addObject:self.headerViewAttributes];
    }

    if (self.footerViewAttributes && CGRectIntersectsRect(self.footerViewAttributes.frame, rect)) {
        [intersectingAttributes addObject:self.footerViewAttributes];
    }

    if (CGRectIntersectsRect(self.decorationViewAttributes.frame, rect)) {
        [intersectingAttributes addObject:self.decorationViewAttributes];
        BOOL visibleItemsFound = NO;
        for (UICollectionViewLayoutAttributes *attributes in self.itemAttributes) {
            if (CGRectIntersectsRect(attributes.frame, rect)) {
                visibleItemsFound = YES;
                [intersectingAttributes addObject:attributes];
            }

            // Optimization: If we have seen previously intersecting items but the current one
            // doesn't intersect, we can break to avoid extra work since they are enumerated
            // in visible order.
            else if (visibleItemsFound) { break; }
        }
    }
    return intersectingAttributes;
}

- (void)setOffset:(CGFloat)offset
{
    for (UICollectionViewLayoutAttributes *attributes in self.itemAttributes) {
        CGRect originalFrame = CGRectOffset(attributes.frame, _offset, 0.0);
        attributes.frame = CGRectOffset(originalFrame, -offset, 0.0);
    }
    _offset = offset;
    self.decorationViewAttributes.sectionOffset = offset;
}

@end

@implementation JEKScrollableSectionLayoutInvalidationContext @end
