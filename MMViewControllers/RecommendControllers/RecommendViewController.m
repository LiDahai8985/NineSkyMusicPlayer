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

@interface RecommendViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self creatViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
        tableView.contentInset = UIEdgeInsetsMake(ScreenWidth*13/32+42, 0, 0, 0);
        tableView.tag = 10001 + i;
        
        [scrollView addSubview:tableView];
    }
}

- (IBAction)subfieldTitleClicked:(id)sender {
    
}

#pragma mark- UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"RecommendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"--- %ld ---",indexPath.row];
    
    return cell;
}


#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}
#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
