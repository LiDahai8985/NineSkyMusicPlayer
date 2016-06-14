//
//  MMNavigationController.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/26.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNavigationController : UINavigationController<UINavigationControllerDelegate>


@end


//push动画
@interface TransitionPushAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@end