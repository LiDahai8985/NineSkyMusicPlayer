//
//  RecommendViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "RecommendViewController.h"
#import "DiscViewController.h"
#import "RequestCenter.h"
#import "RecommendTopThreeCell.h"
#import "RecommendLaterSevenCell.h"
#import "MMDownLoadManager.h"

@interface RecommendViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,MMDownloadDelegate>
{
    NSInteger currentPage;
    BOOL      isAlready;
    AFDownloadRequestOperation *requestOperation;
}

@property (strong, nonatomic) IBOutlet UIButton *newestBtn;
@property (strong, nonatomic) IBOutlet UIButton *payBtn;
@property (strong, nonatomic) IBOutlet UIButton *hotBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *flashViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sliderLineLeadingConstranit;
@property (strong, nonatomic) IBOutlet UIButton *downloadBtn;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgress;
@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.backgroundImgView.hidden = NO;
    self.backgroundImgView.alpha = 0.4;
    [self creatViews];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:MMMusicDownloadDirectoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:MMMusicDownloadDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    
    self.sliderLineLeadingConstranit.constant = (ScreenWidth-2)/3.0/2.0+1-35;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!isAlready) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testAction:) name:self.notificationId?:@"1010100" object:nil];
        isAlready = YES;
    }
}

- (void)testAction:(NSNotification *)nofication {
    NSLog(@"---->%@    %@",nofication.name,self.notificationId?:@"1010100");
}

- (IBAction)downloadBtnClick:(UIButton *)sender
{
//    [[MMDownLoadManager shareManager] downloadWithTask:[NSURL URLWithString:@"http://baobab.wdjcdn.com/14562919706254.mp4"] downloadIdentifier:@"14562919706254.mp4" delegate:self];
//    [[MMDownLoadManager shareManager] download:@"http://baobab.wdjcdn.com/14562919706254.mp4" downloadIdentifier:@"14562919706254.mp4" progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.downloadProgress.progress = progress;
//        });
//    } state:^(DownloadState state) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [sender setTitle:[self getTitleWithDownloadState:state] forState:UIControlStateNormal];
//        });
//    }];
}

- (IBAction)clearBtnClick:(UIButton *)sender
{
    [[MMDownLoadManager shareManager] deleteAllTasks];
}

- (void)downloadTask:(id)task
  downloadIdentifier:(NSString *)downloadIdentifier
        receivedSize:(NSInteger)receivedSize
           totalSize:(NSInteger)totalSize
               state:(DownloadState)state
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.downloadProgress.progress = 1.0*receivedSize/totalSize;
//        switch (state) {
//            case DownloadStateDownloading:
//                [self.downloadBtn setTitle:@"暂停" forState:UIControlStateNormal];
//                break;
//            case DownloadStateAwaitting:
//            case DownloadStateSuspended:
//            case DownloadStateCompleted:
//            case DownloadStateFailed:
//                [self.downloadBtn setTitle:@"开始" forState:UIControlStateNormal];
//                break;
//        }
//    });
//    
//    NSLog(@"--downloadIdentifier:%@\nreceivedSize:%ld\ntotalSize:%ld\nstate:%d",downloadIdentifier,receivedSize,totalSize,state);
}

#pragma mark- MMMethods

- (void)creatViews {
    
    UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:10000];
    scrollView.contentSize = CGSizeMake(ScreenWidth * 3, 0);
    
    for (NSInteger i = 0; i < 3 ; i ++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i * ScreenWidth, 0, ScreenWidth, ScreenHeight)
                                                              style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.contentInset = UIEdgeInsetsMake(ScreenWidth*7/15+42, 0, 50, 0);
        tableView.scrollIndicatorInsets = tableView.contentInset;
        tableView.tag = 10001 + i;
        
        [scrollView addSubview:tableView];
    }
}

- (IBAction)subfieldTitleClicked:(id)sender {
    
    UIButton *currentBtn = (UIButton *)sender;
    UIScrollView *backgroundScrollView = [(UIScrollView *)self.view viewWithTag:10000];
    currentPage = currentBtn.tag - 10011;
    
    self.newestBtn.selected = currentPage == 0;
    self.payBtn.selected = currentPage == 1;
    self.hotBtn.selected = currentPage == 2;
    
    backgroundScrollView.contentOffset = CGPointMake(currentPage*ScreenWidth, 0);
    [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationId?:@"1010100" object:nil];
}

#pragma mark- UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 13 + 76*ScreenScale + 13;
    }
    return 13 + 54*ScreenScale + 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"RecommendTopThreeCell";
    
    if (indexPath.row > 2) {
        cellId = @"RecommendLaterSevenCell";
    }
    else {
        cellId = @"RecommendTopThreeCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        if (indexPath.row > 2) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RecommendLaterSevenCell" owner:nil options:nil] lastObject];
        }
        else {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RecommendTopThreeCell" owner:nil options:nil] lastObject];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    RecommendViewController *vc = [[RecommendViewController alloc] init];
//    vc.notificationId = [NSString stringWithFormat:@"Notification_%ld",indexPath.row];
//    [self.navigationController pushViewController:vc animated:YES];

//    NSLog(@"-----下载地址：%@",MMMusicDownloadDirectoryPath);
//    if (isAlready) {
//        
//        [requestOperation start];
//    }
//    else
//    {
//        [requestOperation pause];
//    }
//    
//    isAlready = !isAlready;

//    MMDownloadRequest *request = [[MMDownLoadManager shareManager].downloadRequestArray objectAtIndex:indexPath.row];
//    if ([[[MMDownLoadManager shareManager] downloadQueue].operations containsObject:request]) {
//        if (!request.isExecuting) {
//            [request cancel];
//            [[[MMDownLoadManager shareManager] downloadQueue].operations ];
//        }
//    }
    
    
}

#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    
    if (scrollView.tag == 10000) {
        self.sliderLineLeadingConstranit.constant = (ScreenWidth-2)/3.0/2.0+1-35 + (offset.x/ScreenWidth)*(ScreenWidth-2)/3.0;
    }
    else {
        
        UITableView *newestTableView = (UITableView *)[self.view viewWithTag:10001];
        UITableView *payTableView = (UITableView *)[self.view viewWithTag:10002];
        UITableView *hotTableView = (UITableView *)[self.view viewWithTag:10003];
        
        //当前tableview滑动时，其他tableview滑动不改变约束值
        if (currentPage == scrollView.tag - 10001) {
            if (offset.y > -(64+42)) {
                self.flashViewTopConstraint.constant = -(newestTableView.contentInset.top - 64 - 42);
            }
            else
            {
                self.flashViewTopConstraint.constant = -(newestTableView.contentInset.top + offset.y);
            }
            
            switch (scrollView.tag) {
                case 10001:
                    payTableView.contentOffset = CGPointMake(0, -(newestTableView.contentInset.top + self.flashViewTopConstraint.constant));
                    hotTableView.contentOffset = CGPointMake(0, -(newestTableView.contentInset.top + self.flashViewTopConstraint.constant));
                    break;
                case 10002:
                    newestTableView.contentOffset = CGPointMake(0, -(newestTableView.contentInset.top + self.flashViewTopConstraint.constant));
                    hotTableView.contentOffset = CGPointMake(0, -(newestTableView.contentInset.top + self.flashViewTopConstraint.constant));
                    break;
                case 10003:
                    payTableView.contentOffset = CGPointMake(0, -(newestTableView.contentInset.top + self.flashViewTopConstraint.constant));
                    newestTableView.contentOffset = CGPointMake(0, -(newestTableView.contentInset.top + self.flashViewTopConstraint.constant));
                    break;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.tag == 10000) {
        CGPoint offset = scrollView.contentOffset;
        currentPage = (NSInteger)offset.x/ScreenWidth;
        self.newestBtn.selected = currentPage == 0;
        self.payBtn.selected = currentPage == 1;
        self.hotBtn.selected = currentPage == 2;
    }
}


#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

