//
//  RecommendViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "RecommendViewController.h"
#import "DiscViewController.h"
#import "AppDelegate.h"

@interface RecommendViewController ()

@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark-

- (IBAction) pushNextViewControllerInTabbar:(id)sender {
    RecommendViewController *vc = [[RecommendViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction) pushNextViewControllerOutTabbar:(id)sender {
    DiscViewController *vc = [[DiscViewController alloc] initWithNibName:@"DiscViewController" bundle:[NSBundle mainBundle]];
    
    [MMAppDelegate.nav pushViewController:vc animated:YES];
}



#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
