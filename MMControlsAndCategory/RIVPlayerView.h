//
//  RIVPlayerView.h
//  Player
//
//  Created by LDhai on 16/3/3.
//  Copyright © 2016年 LDhai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIVPlayerView;
@protocol RIVPlayerDelegate <NSObject>

- (void)player:(RIVPlayerView *)player playStateDidChange:(BOOL)playing;
- (void)player:(RIVPlayerView *)player playtimeDidCacheToValue:(CGFloat)value;
- (void)player:(RIVPlayerView *)player playerDidFinishPlayWithError:(NSError *)error;
- (void)player:(RIVPlayerView *)player playerDidChangePlayTime:(NSInteger)time totalTime:(NSInteger)totalTime;

@end


@interface RIVPlayerView : UIView


@property (nonatomic, weak) id<RIVPlayerDelegate> delegate;

// 当前播放状态
@property (nonatomic, assign, readonly) BOOL isPlaying;

// 是否允许后台播放
@property (nonatomic, assign) BOOL allowPlayBackground;

// 播放器的高度约束（供切换全屏小屏时用）
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;


// 类方法创建，用于代码创建View
+ (instancetype)player;

// 设置播放地址和唯一标示
- (void)setMediaURL:(NSURL *)mediaURL cacheIdentifier:(NSString *)cacheIdentifier;


// 暂停播放
- (void)mmPlayerPause;

// 开始播放
- (void)mmPlayerPlay;

// 设置播放时间
- (void)seekToTime:(CGFloat)value;

// 清除释放自己
- (void)clear;

@end
