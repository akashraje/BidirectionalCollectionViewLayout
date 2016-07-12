//
//  BidirectionCollectionLayout.m
//  BidirectionalCollectionView
//
//  Created by Akash Raje on 14/07/15.
//  Copyright (c) 2015 Akash Raje. All rights reserved.
//

#import "BidirectionCollectionLayout.h"

@interface BidirectionCollectionLayout ()

@end

@implementation BidirectionCollectionLayout
{
    NSDictionary *_layoutInfo;
    UIEdgeInsets maxInsets;
    CGFloat maxRowsWidth;
    CGFloat maxColumnHeight;
    __weak id<BidirectionalCollectionLayoutDelegate> delegate;
}

- (void)prepareLayout
{
    delegate = (id<BidirectionalCollectionLayoutDelegate>) self.collectionView.delegate;
    //Calculate max values
    maxInsets = [self maxInsets];
    maxRowsWidth = [self maxRowWidth];
    maxColumnHeight = [self maxColumnHeight];
    
    //Store calculated frames for cells in the dictionary
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    //Calculate Frame for a cell, per values from DataSource
    CGFloat originY = 0;
    CGFloat floatingSectionOriginY = self.collectionView.contentOffset.y;
    BOOL sectionIsFloating = NO;
    
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        
        UIEdgeInsets itemInsets = UIEdgeInsetsZero;
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            itemInsets = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            originY += itemInsets.top;
        }
        
        CGFloat height = 0;
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        CGFloat originX = itemInsets.left;
        
        if ([delegate respondsToSelector:@selector(collectionView:layout:shouldFloatSectionAtIndex:)]) {
            sectionIsFloating = [delegate collectionView:self.collectionView layout:self shouldFloatSectionAtIndex:section];
        }
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGSize itemSize = CGSizeZero;
            if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                itemSize = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                
                float selectedOriginY = originY;
                if (sectionIsFloating) {
                    if (floatingSectionOriginY >= originY) {
                        selectedOriginY = floatingSectionOriginY;
                    }
                    itemAttributes.zIndex = 1000;//any value greater than '0'
                }
                
                itemAttributes.frame = CGRectMake(originX, selectedOriginY, itemSize.width, itemSize.height);
            }
            cellLayoutInfo[indexPath] = itemAttributes;
            
            CGFloat interItemSpacingX = 0;
            if ([delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
                interItemSpacingX = [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
            }
            
            originX += floorf(itemSize.width + interItemSpacingX);
            height = height > itemSize.height ? height : itemSize.height;
        }
        
        CGFloat interItemSpacingY = 0;
        if ([delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            interItemSpacingY = [delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
        }
        
        originY += floor(height + interItemSpacingY);
        if (sectionIsFloating) {
            floatingSectionOriginY += height;
        }
    }
    
    _layoutInfo = cellLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:_layoutInfo.count];
    
    [_layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                     UICollectionViewLayoutAttributes *attributes,
                                                     BOOL *innerStop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }];
    
    return allAttributes;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _layoutInfo[indexPath];
}

- (CGSize)collectionViewContentSize
{
    CGFloat width = maxInsets.left
    + maxRowsWidth
    + maxInsets.right;
    
    CGFloat height = maxInsets.top
    + maxColumnHeight
    + maxInsets.bottom;
    
    return CGSizeMake(width, height);
}

//Maximum width of perticular section in CollectionView
- (CGFloat)maxRowWidth
{
    NSInteger sectionCount = [self.collectionView numberOfSections];
    CGFloat maxRowWidth = 0;
    for (NSInteger section = 0; section < sectionCount; section++) {
        CGFloat maxWidth = 0;
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        //Find total width of this section.
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                CGSize itemSize = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                maxWidth += itemSize.width ;
            }
        }
        
        CGFloat interItemSpace = 0;
        if ([delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            CGFloat interItemSpacingX = [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
            UIEdgeInsets itemInsets = UIEdgeInsetsZero;
            if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                itemInsets = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            }
            
            interItemSpace = interItemSpacingX * (itemCount - 1);
        }
        maxWidth += interItemSpace;
        maxRowWidth = maxWidth > maxRowWidth ? maxWidth : maxRowWidth;
    }
    
    return maxRowWidth;
}

//Maximum Height of perticular Column in CollectionView
- (CGFloat)maxColumnHeight
{
    NSInteger sectionCount = [self.collectionView numberOfSections];
    CGFloat maxHeight = 0;
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        CGFloat maxRowHeight = 0;
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                CGSize itemSize = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                maxRowHeight = itemSize.height > maxRowHeight ? itemSize.height : maxRowHeight;
            }
        }
        CGFloat interSectionSpacingY = 0;
        if ([delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            interSectionSpacingY = [delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
        }
        
        UIEdgeInsets itemInsets = UIEdgeInsetsZero;
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            itemInsets = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        
        maxHeight += maxRowHeight;
        
        //Add interSectionSpacing and Insets for all sections except last.
        if (section != sectionCount-1) {
            maxHeight += interSectionSpacingY + itemInsets.top;
        }
    }
    
    return maxHeight;
}

- (UIEdgeInsets)maxInsets
{
    UIEdgeInsets maxEdgeInsets = UIEdgeInsetsZero;
    NSInteger sectionCount = [self.collectionView numberOfSections];
    if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        UIEdgeInsets topRowInsets = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:0];
        UIEdgeInsets bottomRowInsets = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:sectionCount];
        maxEdgeInsets.top = topRowInsets.top;
        maxEdgeInsets.bottom = bottomRowInsets.bottom;
    }
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            UIEdgeInsets itemInsets = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            maxEdgeInsets.left = itemInsets.left;
            maxEdgeInsets.right = itemInsets.right;
        }
    }
    
    return maxEdgeInsets;
}

@end
