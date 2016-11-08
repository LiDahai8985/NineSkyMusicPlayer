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
#import "XZMRefresh.h"

@interface DiscViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView   *collectionView;
@property (strong, nonatomic) IBOutlet UITableView        *menuTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet UIImageView        *bottomBackgroundImgview;
@end

@implementation DiscViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bottomBackgroundImgview.hidden = iPhone4;
    
    /**
     *  显示阴影
     */
    self.backgroundImgView.hidden = NO;
    self.backgroundImgView.alpha = 0.6;
    self.backgroundImgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.backgroundImgView.layer.shadowOffset = CGSizeMake(-2, 0);
    self.backgroundImgView.layer.shadowRadius = 3;
    self.backgroundImgView.layer.shadowOpacity = 1.0;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DiscCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([DiscCollectionViewCell class])];
    
    self.collectionView.backgroundView = [self collectionViewBackgroundView];
    self.menuTableView.backgroundView = [self menuTableViewBackgroundView];
    
//    self.collectionView.xzm_footer = [XZMRefreshNormalFooter footer];
//    [self.collectionView.xzm_footer setRefreshingTarget:self refreshingAction:@selector(pullUpRefresh)];

    [self.collectionView xzm_addNormalFooterWithTarget:self action:@selector(pullUpRefresh)];
    [self.collectionView.xzm_footer setTitle:@"加载中..." forState:XZMRefreshStateRefreshing];
    [self.collectionView.xzm_gifFooter setImages:@[] forState:XZMRefreshStateRefreshing];
    self.collectionView.xzm_footer.statusLabel.backgroundColor = [UIColor redColor];
    self.collectionView.xzm_footer.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


//
- (void)pullUpRefresh
{
    [self.collectionView.xzm_footer performSelector:@selector(endRefreshing) withObject:nil afterDelay:2];
}

#pragma mark- Methods

//左上角菜单
- (IBAction)menuBtnClick:(id)sender {
    [self.view sendSubviewToBack:self.menuTableView];
    CGRect backgroundImgViewRect = self.backgroundImgView.frame;
    backgroundImgViewRect.origin.x = self.collectionViewLeadingConstraint.constant == 70?0:70;
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundImgView.frame = backgroundImgViewRect;
        self.collectionViewLeadingConstraint.constant = self.collectionViewLeadingConstraint.constant == 70?0:70;
        [self.view layoutIfNeeded];
    }];
}

//唱片列表背景
- (UIView *)collectionViewBackgroundView {
    
    UIImageView *backUp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disc_rack_background"]];
    UIImageView *backBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disc_rack_background"]];
    UIImageView *backMid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disc_rack_background"]];
    if (iPhone4) {
        backUp.frame = CGRectMake(0, 133, ScreenWidth, 55);
        backBottom.frame = CGRectMake(0, ScreenHeight - 55 - 49 - 8, ScreenWidth,  55);
        backMid.frame = CGRectMake(0, (backUp.frame.origin.y+backBottom.frame.origin.y)/2.0, ScreenWidth, 55);
    }
    else {
        
        backUp.frame = CGRectMake(0, 140.5*ScreenScale, ScreenWidth, 60*ScreenScale);
        backBottom.frame = CGRectMake(0, ScreenHeight - 65*ScreenScale - 60*ScreenScale - 49 + 10, ScreenWidth,  60*ScreenScale);
        backMid.frame = CGRectMake(0, (backUp.frame.origin.y+backBottom.frame.origin.y)/2.0, ScreenWidth, 60*ScreenScale);
    }
    
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    tmpView.backgroundColor = [UIColor clearColor];
    
    [tmpView addSubview:backUp];
    [tmpView addSubview:backMid];
    [tmpView addSubview:backBottom];
    
    return tmpView;
}

//分类列表
- (UIImageView *)menuTableViewBackgroundView {
    
    self.menuTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    UIImageView *backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    backgroundImgView.frame = CGRectMake(0, 0, self.menuTableView.frame.size.width , self.menuTableView.frame.size.width);
    
    return backgroundImgView;
}



#pragma mark- UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DiscCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DiscCollectionViewCell class]) forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"唱片 -%ld-",(long)indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DiscDetailViewController *vc = [[DiscDetailViewController alloc] init];
    [MMAppDelegate.nav pushViewController:vc animated:YES];


//    UIActivityViewController *activeViewController = [[UIActivityViewController alloc]initWithActivityItems:@[@"百度",[NSURL URLWithString:@"http://www.baidu.com"]] applicationActivities:nil];
//    [self.navigationController presentViewController:activeViewController animated:YES completion:nil];
//    //分享结果回调方法
//    UIActivityViewControllerCompletionHandler myblock = ^(NSString *type,BOOL completed){
//        NSLog(@"%d %@",completed,type);
//    };
//    activeViewController.completionHandler = myblock;
    
}
#pragma mark- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return iPhone4?CGSizeMake(92, 110):CGSizeMake(104*ScreenScale, 122*ScreenScale);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return iPhone4?UIEdgeInsetsMake(70, 8, 15, 0):UIEdgeInsetsMake(70*ScreenScale, 7, 65*ScreenScale, 7);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return -3.0;
}

#pragma mark- UITableViewDelegate && UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 25;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self menuBtnClick:nil];
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
