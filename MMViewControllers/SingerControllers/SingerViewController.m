//
//  SingerViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "SingerViewController.h"
#import "CommonDefine.h"
#import "SingerCollectionViewCell.h"

@interface SingerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation SingerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingerCollectionViewCell class]) bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:NSStringFromClass([SingerCollectionViewCell class])];
}


#pragma mark- UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 49;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SingerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SingerCollectionViewCell class]) forIndexPath:indexPath];
    
    NSInteger tmpCellIndex = indexPath.item/2;
    BOOL      isUpCell = indexPath.item%2 == 0;
    CGRect    cellRect = cell.frame;
    if (iPhone4) {
        if (tmpCellIndex%3 == 0) {
            cellRect.origin.y = 107 + (isUpCell?0:150);
        }
        else if (tmpCellIndex%3 == 1) {
            cellRect.origin.y = 77 + (isUpCell?0:150);
        }
        else {
            cellRect.origin.y = 137 + (isUpCell?0:150);
        }
    }
    else {
        if (tmpCellIndex%3 == 0) {
            cellRect.origin.y = (132 + (isUpCell?0:180)) * ScreenScale;
        }
        else if (tmpCellIndex%3 == 1) {
            cellRect.origin.y = (77 + (isUpCell?0:180)) * ScreenScale;
        }
        else {
            cellRect.origin.y = (170 + (isUpCell?0:180)) * ScreenScale;
        }
    }
    
    cell.frame = cellRect;
    
    cell.textLabel.text = [NSString stringWithFormat:@"- %ld -",(long)indexPath.item];
    return cell;
}

#pragma mark- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return iPhone4?CGSizeMake(100, 100*4/3):CGSizeMake(115*ScreenScale, 154*ScreenScale);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSLog(@"----------%ld----------",(long)section);
    //限制一列显示多少行
    return UIEdgeInsetsMake(0,18*ScreenScale, 100, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}


#pragma mark-
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
