//
//  BidirectionCollectionLayout.h
//  BidirectionalCollectionView
//
//  Created by Akash Raje on 14/07/15.
//  Copyright (c) 2015 Akash Raje. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BidirectionalCollectionLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout shouldFloatSectionAtIndex:(NSInteger)section;

@end

@interface BidirectionCollectionLayout : UICollectionViewFlowLayout

@end
