//
//  MusicPlayingAnimationView.h
//  MyDemo
//
//  Created by LiDaHai on 16/6/23.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayingAnimationView : UIControl

/**
 *  显示动画特效
 *
 *  @param animation 是否显示
 */
- (void)showWithAnimation:(BOOL)animation;

@end


@interface DashLineLayer : CALayer

/**
 *  虚线颜色
 */
@property (strong, nonatomic) UIColor *lineColor;

@end