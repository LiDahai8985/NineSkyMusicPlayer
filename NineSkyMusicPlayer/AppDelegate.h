//
//  AppDelegate.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIVPlayerView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *nav;

@property (strong, nonatomic) RIVPlayerView  *playerView;

@end

