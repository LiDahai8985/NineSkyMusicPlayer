//
//  MMSuperViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MMSuperViewController.h"

@interface MMSuperViewController ()

@property (strong, nonatomic) UIImageView  *backgroundImgView;

@end

@implementation MMSuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //默认允许滑动退出当前页面
    self.allowSwipOut = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
    }
    return _backgroundImgView;
}

#pragma mark-

- (void)showBackgroundImgView {
    [self.view insertSubview:self.backgroundImgView atIndex:0];
}

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
