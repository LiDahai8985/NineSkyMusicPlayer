//
//  MMSuperViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MMSuperViewController.h"

@interface MMSuperViewController ()

@end

@implementation MMSuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //默认允许滑动退出当前页面
    self.allowSwipOut = YES;
    self.view.backgroundColor = RGBColor(17, 17, 17, 1);
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundImgView.backgroundColor = [UIColor clearColor];
        _backgroundImgView.image = [UIImage imageNamed:@"viewControllerBackgroundImg"];
        _backgroundImgView.alpha = 0.3;//默认显示0.3的透明
        _backgroundImgView.hidden = YES;
        [self.view insertSubview:_backgroundImgView atIndex:0];
    }
    return _backgroundImgView;
}

#pragma mark-


#pragma mark-

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc
{
    NSLog(@"------%@释放了------",NSStringFromClass([self class]));
}


#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
