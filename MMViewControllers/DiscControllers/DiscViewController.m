//
//  DiscViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "DiscViewController.h"
#import "DiscCollectionViewCell.h"
#import "DiscDetailViewController.h"

@interface DiscViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView   *collectionView;
@property (strong, nonatomic) IBOutlet UITableView        *menuTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewLeadingConstraint;

@end

@implementation DiscViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self showBackgroundImgView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DiscCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([DiscCollectionViewCell class])];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark- Methods

- (IBAction)menuBtnClick:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.collectionViewLeadingConstraint.constant = self.collectionViewLeadingConstraint.constant == 70?0:70;
        [self.view layoutIfNeeded];
    }];
}



#pragma mark- UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 150;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DiscCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DiscCollectionViewCell class]) forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"唱片 -%ld-",(long)indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DiscDetailViewController *vc = [[DiscDetailViewController alloc] init];
    [MMAppDelegate.nav pushViewController:vc animated:YES];
}
#pragma mark- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return iPhone4?CGSizeMake(85, 103):CGSizeMake(104*ScreenScale, 122*ScreenScale);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return iPhone4?UIEdgeInsetsMake(80, 8, 20, 0):UIEdgeInsetsMake(70*ScreenScale, 7, 50*ScreenScale, 7);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return -3.0;
}

#pragma mark- UITableViewDelegate && UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"DiscMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.text = @"摇滚";
    return cell;
}
#pragma mark- 支持屏幕方向

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
