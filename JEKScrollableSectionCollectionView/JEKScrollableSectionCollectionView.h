//
//  JEKScrollableSectionCollectionView.h
//  JEKScrollableSectionCollectionView
//
//  Created by Joel Ekström on 2017-08-28.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JEKScrollableSectionCollectionView : UICollectionView

@end

@protocol JEKScrollableCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(JEKScrollableSectionCollectionView *)collectionView heightForSectionAtIndex:(NSInteger)section;

@end
