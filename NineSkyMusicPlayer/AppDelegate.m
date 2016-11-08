//
//  AppDelegate.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "AppDelegate.h"
#import "MMTabBarController.h"
#import "MMNavigationController.h"
#import <AVFoundation/AVFoundation.h>


@interface AppDelegate ()
{
    NSInteger aa;
}

@property(assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;

@end



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    
    
    //打开音频会话
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    //接受远程的控制通知
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    
    MMTabBarController *tabBarController = [[MMTabBarController alloc] init];
    
    MMNavigationController *nav = [[MMNavigationController alloc] initWithRootViewController:tabBarController];
    self.window.rootViewController = nav;
    
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"begin=============");
    _backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"系统执行end=============");
        // 如果在系统规定时间内任务还没有完成，在时间到之前系统会调用到这个方法，一般是10分钟
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundUpdateTask];
        _backgroundUpdateTask = UIBackgroundTaskInvalid;
        
    }];
    
    [self.playerView mmPlayerPlay];
    //在非主线程开启一个操作在更长时间内执行； 执行的动作
//    aa =0;
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(go:) userInfo:nil repeats:YES];
    
}

- (void)test
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"dsfasfalsdkfjalksdjflksadjflkasdjf");
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark- 

- (MMNavigationController *)nav {
    return (MMNavigationController *)self.window.rootViewController;
}

- (RIVPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [RIVPlayerView player];
        _playerView.allowPlayBackground = YES;
        _playerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth*9/16);
    }
    return _playerView;
}


-(void)go:(NSTimer *)tim
{
    NSLog(@"%@==%ld ",[NSDate date],(long)aa);
    aa++;
//    if (aa==20) {
//        NSLog(@"主动执行end=============");
//        // 如果任务在到达系统给定时间前完成，则主动调用结束后台任务的方法
//        [[UIApplication sharedApplication] endBackgroundTask:_backgroundUpdateTask];
//        _backgroundUpdateTask = UIBackgroundTaskInvalid;
//    }
}


@end
