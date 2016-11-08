//
//  RIVMediaRequestTask.h
//  Player
//
//  Created by LiDaHai on 16/6/17.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RIVMediaRequestTask;
@protocol RIVMediaRequestTaskDelegate <NSObject>

- (void)task:(RIVMediaRequestTask *)task didReceiveMediaLength:(NSUInteger)mediaLength mimeType:(NSString *)mimeType;
- (void)taskDidReceiveMediaData:(RIVMediaRequestTask *)task;
- (void)taskDidFinishLoading:(RIVMediaRequestTask *)task;
- (void)taskDidFailLoading:(RIVMediaRequestTask *)task WithError:(NSInteger )errorCode;

@end



@interface RIVMediaRequestTask : NSObject

@property (nonatomic, strong, readonly) NSURL *url;


// 当前正在请求的request起始位置
@property (nonatomic, assign, readonly) NSUInteger offset;

//自定义文件格式
@property (nonatomic, strong, readonly) NSString   *mimeType;

// 当前请求文件的总长度
@property (nonatomic, assign, readonly) NSUInteger mediaLength;

// 当前正在请求的request已经缓存到的数据
@property (nonatomic, assign, readonly) NSUInteger downLoadingOffset;

// 任务代理
@property (nonatomic, weak) id <RIVMediaRequestTaskDelegate> m_delegate;


- (instancetype)initWithIdentifier:(NSString *)identifier;

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;

- (void)clearData;

@end
