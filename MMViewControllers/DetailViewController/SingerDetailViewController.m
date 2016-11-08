//
//  SingerDetailViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/6/23.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "SingerDetailViewController.h"
#import "MMTableSectionIndexView.h"

@interface SingerDetailViewController ()<MMTableSectionIndexViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) MMTableSectionIndexView   *sectionIndexView;

@end

@implementation SingerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _sectionIndexView = [[MMTableSectionIndexView alloc] initWithFrame:CGRectMake(0, 64, 30 * ScreenScale, ScreenHeight - 64 - 49)];
    _sectionIndexView.barStyle = UIBarStyleBlack;
    _sectionIndexView.tableViewIndexDelegate = self;
    [self.view addSubview:_sectionIndexView];
    
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


@end
