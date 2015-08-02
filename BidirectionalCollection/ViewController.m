//
//  ViewController.m
//  BidirectionalCollection
//
//  Created by Akash Raje on 18/07/15.
//  Copyright (c) 2015 Akash Raje. All rights reserved.
//

#import "ViewController.h"

@interface CollectionCell : UICollectionViewCell
{
    
    __weak IBOutlet UILabel *_lblIndex;
}
@property (nonatomic, strong) NSString* index;
@end

@implementation CollectionCell

- (void)setIndex:(NSString *)index {
    _index  = index;
    _lblIndex.text = index;
}
@end


@interface ViewController ()
{
    __weak IBOutlet UICollectionView *_collectionView;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --mark CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, 200);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CollectionCellId" forIndexPath:indexPath];
    cell.index = [NSString stringWithFormat:@"%ld - %ld",(long)indexPath.section, (long)indexPath.row];

    return cell;
}
@end

