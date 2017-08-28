//
//  JEKScrollableSectionCollectionView.h
//  JEKScrollableSectionCollectionView
//
//  Created by Joel Ekström on 2017-08-28.
//  Copyright © 2017 Joel Ekström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JEKScrollableCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView heightForSectionAtIndex:(NSInteger)section;

@end

@interface JEKScrollableSectionCollectionView : UICollectionView

@end
