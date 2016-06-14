//
//  MMPlayerView.h
//  Player
//
//  Created by LDhai on 16/3/3.
//  Copyright © 2016年 LDhai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MMPlayerCyclicalPattern) {
    MMPlayerCyclicalPattern_single = 1,
    MMPlayerCyclicalPattern_oneByOne = 2,
    MMPlayerCyclicalPattern_random   = 3,
};

typedef NS_ENUM(NSInteger, MMPlayerContentMode) {
    MMPlayerContentMode_music = 0,
    MMPlayerContentMode_video = 1,
};

typedef void(^GoBackBlock)(void);




@interface MMPlayerView : UIView


/** 视频URL */
@property (nonatomic, strong) NSURL *mediaURL;

/** 播放器的播放模式 : 音乐， 视频 **/
@property (nonatomic, assign) MMPlayerContentMode  contentMode;

/** 播放模式 : 单曲循环，列表循环，随机 **/
@property (nonatomic, assign) MMPlayerCyclicalPattern cyclicalPattern;

/** 播放列表 **/
@property (nonatomic, copy) NSMutableArray *mmPlayItemList;

/** 当前播放状态 **/
@property (nonatomic, assign, readonly) BOOL isPlaying;

/** 返回按钮Block */
@property (nonatomic, copy) GoBackBlock goBackBlock;

/** 播放器的高度约束（供切换全屏小屏时用） **/
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;


/** 类方法创建，用于代码创建View */
+ (instancetype)sharePlayer;


/**
 *  取消延时
 */
- (void)cancelAutoFadeOutControlBar;


/**
 *  暂停播放
 */
- (void)mmPlayerPause;

/**
 *  开始播放
 */
- (void)mmPlayerPlay;


//清除释放自己
- (void)clear;

@end
