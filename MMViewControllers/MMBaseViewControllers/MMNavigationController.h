//
//  MMNavigationController.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicPlayingAnimationView.h"

@interface MMNavigationController : UINavigationController<UINavigationControllerDelegate>

/**
 *  页面右上角动画显示播放状态按钮
 */
@property (strong, nonatomic) MusicPlayingAnimationView *rightPlayingView;

@end


//push动画
@interface TransitionPushAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@end