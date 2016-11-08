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
#import "SingerDetailViewController.h"
#import "MMTableSectionIndexView.h"

@interface SingerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MMTableSectionIndexViewDelegate>

@property (strong, nonatomic) MMTableSectionIndexView   *sectionIndexView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation SingerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.backgroundImgView.hidden = NO;
    self.backgroundImgView.alpha = 0.6;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingerCollectionViewCell class]) bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:NSStringFromClass([SingerCollectionViewCell class])];
}

- (MMTableSectionIndexView *)sectionIndexView {
    if (!_sectionIndexView) {
        _sectionIndexView = [[MMTableSectionIndexView alloc] initWithFrame:CGRectMake(-55, 64, 30 * ScreenScale, ScreenHeight - 64 - 49)];
        _sectionIndexView.barStyle = UIBarStyleBlack;
        _sectionIndexView.tableViewIndexDelegate = self;
        [self.view addSubview:_sectionIndexView];
    }
    return _sectionIndexView;
}

#pragma mark- Methods


- (IBAction)showTableSectionIndexView {
    CGRect rect = self.sectionIndexView.frame;
    rect.origin.x = rect.origin.x == 0?(-55):0;
    [UIView animateWithDuration:0.3 animations:^{
        self.sectionIndexView.frame = rect;
    }];
}

#pragma mark- UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SingerDetailViewController *vc = [[SingerDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
    return 15.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}


#pragma mark-  MMTableSectionIndexViewDelegate

- (void)tableViewIndex:(MMTableSectionIndexView *)tableViewIndex didSelectSectionAtIndex:(NSInteger)index withTitle:(NSString *)title {
    NSLog(@"-----当前字母序号是:%ld",(long)index);
}

- (NSArray *)tableViewIndexTitle:(MMTableSectionIndexView *)tableViewIndex {
    return @[@"推荐",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
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
