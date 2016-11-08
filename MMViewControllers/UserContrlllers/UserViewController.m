//
//  UserViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "UserViewController.h"
#import "DownloadCell.h"
#import "MMDownLoadManager.h"
#import <MJRefresh.h>


@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate,MMDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *testImgView;
@property (strong, nonatomic) CALayer *maskLayer;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.backgroundImgView.hidden = NO;
    self.backgroundImgView.alpha = 0.7;
    self.view.backgroundColor = [UIColor whiteColor];
    self.maskLayer = [CALayer layer];
    self.maskLayer.anchorPoint = CGPointZero;
    self.maskLayer.bounds = CGRectMake(0, 0, 100, 185);
    self.maskLayer.backgroundColor = [UIColor redColor].CGColor;
    
    self.testImgView.layer.mask = self.maskLayer;
    
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
//    for (int i = 0; i < 100;  i++) {
//        MMDownloadModel *model = [[MMDownloadModel alloc] init];
//        model.taskId = [NSString stringWithFormat:@"1111111%d.mp4",i];
//        model.downloadUrl = @"http://baobab.wdjcdn.com/14562919706254.mp4";
//        model.taskName = [NSString stringWithFormat:@"1111111%d.mp4",i];
//        model.downloadState = i==0?DownloadStateDownloading:DownloadStateSuspended;
//        [self.dataArray addObject:model];
//    }
    
    [MMDownLoadManager shareManager].delegate = self;
    
    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpRefresh)];
    self.tableView.mj_footer.automaticallyHidden = NO;


}

#pragma mark-

- (void)refreshTableData
{
    [self.tableView.mj_header performSelector:@selector(endRefreshing) withObject:nil afterDelay:2];
}

- (void)pullUpRefresh
{
    [self.tableView.mj_footer performSelector:@selector(endRefreshing) withObject:nil afterDelay:2];
}

#pragma mark- Methods
- (void) startAnimation:(id)sender
{
    //    CABasicAnimation
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"bounds.size.width";
    anim.autoreverses = YES;
    anim.repeatCount = MAXFLOAT;
    anim.fromValue = @(0.5);
    anim.toValue = @(200);
    anim.duration = 0.3;
    [self.maskLayer addAnimation:anim forKey:@"LineAnimation"];
}

#pragma mark- UITableViewDelegate && UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MMDownLoadManager shareManager].allDownloadArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"DownloadCell";
    
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellId owner:nil options:nil] lastObject];
    }
    
    MMDownloadModel *model = [[MMDownLoadManager shareManager].allDownloadArray objectAtIndex:indexPath.row];
    [cell setcontentWithObject:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self startAnimation:nil];
    //    MMDownloadModel *model = [[MMDownLoadManager shareManager].allDownloadArray objectAtIndex:indexPath.row];
//    [[MMDownLoadManager shareManager] downloadTaskWithDownloadModel:model];
}


#pragma mark-

- (IBAction) startAllTask:(id)sender
{
    [self startAnimation:nil];
    //[[MMDownLoadManager shareManager] addToDownloadQueueWithDownloadModels:[MMDownLoadManager shareManager].allDownloadArray];
}

- (IBAction)pauseAllTask:(id)sender
{
    [[MMDownLoadManager shareManager] downloadPauseAllTasks];
}

#pragma mark-
- (void)downloadDidReceiveData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
