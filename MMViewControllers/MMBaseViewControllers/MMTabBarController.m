//
//  MMTabBarController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MMTabBarController.h"
#import "MMSuperViewController.h"
#import "MMNavigationController.h"
#import "RecommendViewController.h"
#import "DiscViewController.h"
#import "SingerViewController.h"
#import "UserViewController.h"


@interface MMTabBarController ()

@end

@implementation MMTabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTabBarItemsAndControllers];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark-

//设置tabBar底部items
- (void)setTabBarItemsAndControllers {
    NSArray *itemNamesArray = @[@"推荐",@"唱片",@"音乐人",@"我的"];
    NSArray *itemDeafaultImgArray = @[[[UIImage imageNamed:@"tabbar_recommend_default"] imageWithRenderingMode:UIImageRenderingModeAutomatic],
                                      [[UIImage imageNamed:@"tabbar_disc_default"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                      [[UIImage imageNamed:@"tabbar_singer_default"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                      [[UIImage imageNamed:@"tabbar_user_default"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    NSArray *itemSelectedImgArray = @[[[UIImage imageNamed:@"no_comment"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                      [[UIImage imageNamed:@"no_comment"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                      [[UIImage imageNamed:@"no_comment"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                      [[UIImage imageNamed:@"no_comment"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],];
    
    NSArray *viewControllerNamesArray = @[@"RecommendViewController",@"DiscViewController",@"SingerViewController",@"UserViewController",@"DiscViewController"];
    NSMutableArray *tabBarControllers = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < itemDeafaultImgArray.count; i ++) {
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:itemNamesArray[i] image:itemDeafaultImgArray[i] selectedImage:itemSelectedImgArray[i]];
        item.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
        textAttrs[NSFontAttributeName]=[UIFont systemFontOfSize:13];
        
        [item setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
        
        MMSuperViewController *controller = [[NSClassFromString(viewControllerNamesArray[i]) alloc] init];
//        MMNavigationController *nav = [[MMNavigationController alloc] initWithRootViewController:controller];
//        nav.navigationBarHidden = YES;
        [tabBarControllers addObject:controller];
        controller.tabBarItem = item;
    }
    
    //ios8之前用此方法
    //    [self.tabBar setSelectedImageTintColor:[UIColor redColor]];
    
    //设置字体颜色
    self.tabBar.tintColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    
    //设置背景色
    self.tabBar.barTintColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.99];
    
    //显示阴影
    self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.tabBar.layer.shadowRadius = 5;
    self.tabBar.layer.shadowOpacity = 1.0;
    
    //使用自定义shadowImage的前提是使用自定义BackgroundImage，如果backgroundImage是默认的，则shadowImage也是默认效果
    //    [self.tabBar setShadowImage:[UIImage imageNamed:@"xinhua_report_placeHolder8_3"]];
    //    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"xinhua_report_placeHolder8_3"]];
    
    [self setViewControllers:tabBarControllers animated:NO];
    
    self.selectedIndex = 1;
}

#pragma mark-

- (BOOL) shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
