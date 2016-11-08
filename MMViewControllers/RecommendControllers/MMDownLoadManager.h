//
//  MMDownLoadManager.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/29.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,DownloadState) {
    DownloadStateDownloading = 0,  // 下载中..
    DownloadStateAwaitting,        // 等待下载
    DownloadStateSuspended,        // 下载暂停
    DownloadStateCompleted,        // 下载完成
    DownloadStateFailed,           // 下载失败
};



@protocol MMDownloadDelegate <NSObject>

- (void)downloadDidReceiveData;

@end


@class MMDownloadModel;
@interface MMDownLoadManager : NSObject

// 下载代理
@property (weak, nonatomic) id<MMDownloadDelegate> delegate;

// 所有下载任务（不包含已完成）
@property (strong, nonatomic) NSMutableArray   *allDownloadArray;

// 已完成下载任务的列表
@property (strong, nonatomic) NSMutableArray   *downloadFinishedArray;


// 返回单例对象
+ (instancetype)shareManager;

// 添加下载任务资源
- (void)addToDownloadQueueWithDownloadModels:(NSArray<MMDownloadModel *> *)array;

// 对已存在的任务执行下载处理
- (void)downloadTaskWithDownloadModel:(MMDownloadModel *)model;

// 暂停全部下载
- (void)downloadPauseAllTasks;

//  删除该资源
- (void)deleteDownloadTask:(NSArray <MMDownloadModel *> *)array;

//  清空所有下载资源
- (void)deleteAllTasks;


@end




@interface MMDownloadModel : NSObject

/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;

/** 任务唯一标示 */
@property (nonatomic, copy) NSString *taskId;

// 对象id
@property (nonatomic, copy) NSString *songId;

// 名字
@property (nonatomic, copy) NSString *songName;

// mvId
@property (nonatomic, copy) NSString *mvId;

// 下载地址
@property (nonatomic, copy) NSString *downloadUrl;

// 获得服务器这次请求 返回数据的总长度
@property (nonatomic, assign) NSInteger totalLength;

// 获得服务器这次请求 已下载数据的总长度
@property (nonatomic, assign) NSInteger downloadedLength;

// 当前的下载状态
@property (nonatomic, assign) DownloadState downloadState;

@end
