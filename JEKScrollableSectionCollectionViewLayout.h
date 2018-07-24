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

@end
