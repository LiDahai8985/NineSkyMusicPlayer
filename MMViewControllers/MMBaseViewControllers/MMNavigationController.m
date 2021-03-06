//
//  MMNavigationController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MMNavigationController.h"
#import "MMSuperViewController.h"


@interface MMNavigationController ()

@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *percentDriven;

/**
 *  是否是手势交互
 */
@property (assign, nonatomic) BOOL isInteractiving;

/**
 *  是否允许子viewController通过手势滑动pop出页面
 */
@property (assign, nonatomic) BOOL isAllowSwipOut;

/**
 *  当前显示的最上层的viewController
 */
@property (strong, nonatomic) UIViewController *mmTopViewController;

@end

@implementation MMNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //默认隐藏导航条
    self.navigationBarHidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //控制器切换controller到控制对象
    self.percentDriven = [[UIPercentDrivenInteractiveTransition alloc] init];
    self.delegate = self;
    
    //添加右上角播放状态按钮
    [self.rightPlayingView addTarget:self
                              action:@selector(enterMusicDetail)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightPlayingView];
    
    //添加滑动手势
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(panGestureRecognizerAction:)]];
}

- (void )setMmTopViewController:(UIViewController *)mmTopViewController
{
    _mmTopViewController = mmTopViewController;
}

- (BOOL)isAllowSwipOut
{
    return !([self.mmTopViewController isKindOfClass:[MMSuperViewController class]] && !((MMSuperViewController *)self.mmTopViewController).allowSwipOut);
}


- (MusicPlayingAnimationView *)rightPlayingView {
    if (!_rightPlayingView) {
        _rightPlayingView = [[MusicPlayingAnimationView alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 14, 50, 50)];
        _rightPlayingView.backgroundColor = [UIColor clearColor];
    }
    
    return _rightPlayingView;
}

/**nav不会将 preferredStatusBarStyle方法调用转给它的子视图,而是由它自己管理状态
 *所以此方法只在nav的子viewController里面写是不行的，要在nav中进行处理
 **/
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return [self.visibleViewController preferredStatusBarStyle];
//}

#pragma mark- Methods

- (void)enterMusicDetail {
    [self.rightPlayingView showWithAnimation:YES];
}


#pragma mark-  手势动作处理

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView* view = self.view;
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    //NSLog(@"\n----->panGestureRecognizerAction<-----\n----->mmTopViewController----->:%@\n----->topViewController----->:%@\n----->velocityInView----->:%f\n----->translation----->:%f",NSStringFromClass([self.mmTopViewController class]),NSStringFromClass([self.topViewController class]),[gestureRecognizer velocityInView:view].x,translation.x);
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.isInteractiving = YES;
            
            /****  此处设置mmTopViewController来记录当前处于正在滑动退出的页面，
             因为每次手势滑动开始时会立即执行popViewControllerAnimated:方法，此时
             self.topViewController会发生变化   ****/
            self.mmTopViewController = self.topViewController;
            //nav内有子viewController时 允许滑动的状态  向右滑动 三个条件同时满足时才执行pop
            if (self.viewControllers.count > 1 && self.isAllowSwipOut && [gestureRecognizer velocityInView:view].x > 0) {
                [self popViewControllerAnimated:YES];
                NSLog(@"*********************");
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            //允许滑动才执行跟随改变的动作
            if (self.isAllowSwipOut) {
                //防止向左滑动返回到边界后继续左滑页面弹起
                if (translation.x < 10) {
                    [self.percentDriven updateInteractiveTransition:0];
                }
                else {
                    CGFloat fraction = fabs(translation.x / view.bounds.size.width);
                    [self.percentDriven updateInteractiveTransition:fraction];
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.isInteractiving = NO;
            CGFloat fraction = fabs(translation.x / view.bounds.size.width);
            
            //当滑动很快或者华东距离大于屏幕宽度一半距离时执行pop操作，否则返回原状态
            
            if (self.isAllowSwipOut && (fraction > 0.5 || [gestureRecognizer velocityInView:view].x >180)) {
                [self.percentDriven finishInteractiveTransition];
            } else {
                [self.percentDriven cancelInteractiveTransition];
            }
            self.mmTopViewController = nil;
            break;
        }
        default:
            break;
    }
}


#pragma mark-  UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop) {
        return [[TransitionPopAnimation alloc] init];
    }
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    //没有通过手动交互（如手势滑动）时，要返回空，有交互时，返回当前交互的对象
    return self.isInteractiving ? self.percentDriven:nil;
}

#pragma mark- UIDeviceOrientations

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end





@implementation TransitionPopAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //－－－－－－－正常pop效果－－－－－－－
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    //给将要pop出的viewcontroller的view添加阴影
    fromVC.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:fromVC.view.frame].CGPath;
    fromVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    fromVC.view.layer.shadowOffset = CGSizeMake(-3, 0);
    fromVC.view.layer.shadowOpacity = 0.2;
    fromVC.view.layer.shadowRadius = 2.0;
    
    //设置将要出现的viewcontroller的view的起始坐标
    toVC.view.frame = CGRectOffset([transitionContext finalFrameForViewController:toVC], -toVC.view.frame.size.width/3, 0);
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];
    
    
    //控制viewController的view动画移动
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toVC.view.frame  = [transitionContext finalFrameForViewController:toVC];
        fromVC.view.frame = CGRectMake(fromVC.view.frame.size.width, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height);
    } completion:^(BOOL finished) {
        
        // 执行到最后必须调用此方法，以更新转场动作各个状态
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}


@end
