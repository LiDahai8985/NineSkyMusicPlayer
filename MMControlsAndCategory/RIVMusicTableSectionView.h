//
//  RIVMusicTableSectionView.h
//  Rivendell
//
//  Created by LiDaHai on 16/7/11.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>

// 歌单tableview的sectionHeader的几种状态的显示方式
typedef NS_ENUM(NSUInteger, RIVMusicTableSectionViewState) {
    RIVMusicTableSectionViewStatePlayAll = 0, // 播放全部
    RIVMusicTableSectionViewStateSelectAll,   // 全选
    RIVMusicTableSectionViewStateSelectNone,  // 全部选
    RIVMusicTableSectionViewStatePauseAll,    //全部暂停下载
    RIVMusicTableSectionViewStateDownloadAll, //全部开始下载
};



@protocol RIVMusicTableSectionViewDelegate <NSObject>

@required
- (void)selectAllMusic:(BOOL)select;

@optional
- (void)playAllMusic;
- (void)downloadAllMusic:(BOOL)download;

@end

@interface RIVMusicTableSectionView : UIView

@property (assign, nonatomic) RIVMusicTableSectionViewState sectionState;
@property (weak) id<RIVMusicTableSectionViewDelegate> delegate;

- (id)initWithState:(RIVMusicTableSectionViewState)state musicCount:(NSInteger)count downloadAllHidden:(BOOL)hidden;

@end
