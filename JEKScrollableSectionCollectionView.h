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

/**
 Implement this function to adjust the height of a scrollable section. For example,
 to fit multiple rows of items in each section.

 If you want to have top/bottom section insets, you must adjust the section height
 to fit them by implementing this function.

 @return The desired height for the current section
 */
- (CGFloat)collectionView:(nonnull JEKScrollableSectionCollectionView *)collectionView heightForSectionAtIndex:(NSInteger)section;

@end
