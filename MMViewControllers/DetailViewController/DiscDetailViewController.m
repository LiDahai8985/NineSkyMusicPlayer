//
//  DiscDetailViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/6/23.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "DiscDetailViewController.h"
#import "UIImage+ImageEffects.h"
#import "FXBlurView.h"
#import "SongListCell.h"
#import "BuyDiscTipView.h"
#import "RIVMusicTableSectionView.h"
#import "MusicPlayViewController.h"
#import "MvMainViewController.h"
#import "MMDownLoadManager.h"



@interface DiscDetailViewController ()<UITableViewDelegate,UITableViewDataSource,BuyDiscTipViewDelegate,RIVMusicTableSectionViewDelegate,UIAlertViewDelegate,SongCellDelegate>
{
    BOOL State;
}

@property (weak, nonatomic) IBOutlet UIView      *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *headBgImgView;
@property (weak, nonatomic) IBOutlet UIView      *priceView;
@property (weak, nonatomic) IBOutlet UILabel     *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton    *buyBtn;
@property (weak, nonatomic) IBOutlet UIButton    *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton    *collectBtn;
@property (weak, nonatomic) IBOutlet UIButton    *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton    *shareBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (strong, nonatomic) BuyDiscTipView       *tipView;
@property (strong, nonatomic) RIVMusicTableSectionView *tableSectionView;
@end

@implementation DiscDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.backgroundImgView.hidden = NO;
    
    self.headerView.frame = CGRectMake(0, 0, ScreenWidth, 20+100*ScreenScale+20+50+10);
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.headerHeight.constant = 20+100*ScreenScale+20+50+10 + 64;
    
        self.tableSectionView = [[RIVMusicTableSectionView alloc] initWithState:RIVMusicTableSectionViewStatePlayAll musicCount:10 downloadAllHidden:YES];
    
    [self performSelector:@selector(updateDiscInfo) withObject:nil afterDelay:0.3];
    
    
    
}




- (void)updateDiscInfo
{
    __block UIImage *image = [UIImage imageNamed:@"3"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        image = [image blurredImageWithRadius:60 iterations:60 tintColor:[UIColor blackColor]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headBgImgView.image = image;
            [UIView animateWithDuration:0.3 animations:^{
                self.headBgImgView.alpha = 1.0;
            }];
        });
    });
    
    State = YES;
    [self.tableView reloadData];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    NSString *firstString = @"￥6.00";
    NSString *secondString = @"已售2139张";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",firstString,secondString]];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, firstString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(firstString.length + 2, secondString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.5 alpha:1] range:NSMakeRange(firstString.length+2, secondString.length)];
    
    self.priceLabel.attributedText = attributedString;
    
    self.priceView.hidden = NO;
    
    [self.collectBtn setTitle:@"200" forState:UIControlStateNormal];
    [self.commentBtn setTitle:@"200" forState:UIControlStateNormal];
}


#pragma mark- UITableViewDelegate && UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return State?20:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 17 + 26*ScreenScale + 17;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SongListCell";
    
    SongListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SongListCell" owner:nil options:nil] lastObject];
        cell.delegate = self;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return State?self.tableSectionView:nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return State?50:0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row%2 == 1) {
        MusicPlayViewController *vc = [[MusicPlayViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
//    }
//    else
//    {
//        BuyDiscTipView *tipView = [[BuyDiscTipView alloc] initWithDisc:nil delegate:self isBuy:indexPath.item%2==1?YES:NO];
//        [tipView showWithView:self.view animation:YES];
//    }
//    
//    MMDownloadModel *model = [[MMDownloadModel alloc] init];
//    model.taskId = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld%ld%ld%ld.mp4",indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row];
//    model.downloadUrl = @"http://baobab.wdjcdn.com/14562919706254.mp4";
//    model.songName = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld%ld%ld%ld.mp4",indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row];
//    [[MMDownLoadManager shareManager] addToDownloadQueueWithDownloadModels:@[model]];
}

#pragma mark-
- (void)tipView:(BuyDiscTipView *)tipView clickButtonAtIndex:(NSInteger)index totalCount:(NSInteger)count
{
    
}

- (void)tipViewCancelButtonClick:(BuyDiscTipView *)tipView
{
    
}

#pragma mark- 歌曲管理Delegate
- (void)selectAllMusic:(BOOL)select
{
    
}

- (void)playAllMusic
{
    
}

#pragma mark-

- (void)openSongMenu:(NSIndexPath *)indexPath
{
    // 判断是否安装应用
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin"]]) {
    }
}

- (void)openMvDetail:(NSIndexPath *)indexPath
{
    MvMainViewController *vc = [[MvMainViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark-

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    self.headerHeight.constant = 20+100*ScreenScale+20+50+10 + 64 - (offset.y < 0?offset.y:0);
    
    if (offset.y > 20+100*ScreenScale+20+50+10) {
        self.headerTop.constant = -(20+100*ScreenScale+20+50+10);
    }
    else if (offset.y > 0){
        
        self.headerTop.constant = -offset.y;
    }
    else {
        self.headerTop.constant = 0;
    }
}

#pragma mark-
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
