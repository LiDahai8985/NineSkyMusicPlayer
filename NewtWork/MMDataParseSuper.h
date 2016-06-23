//
//  MMDataParseSuper.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/3/16.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMParseToObjectToDatabaseDelegate.h"
#import "MMRequestDefine.h"
#import "MMClientRequestDelegate.h"

@class MMResponseModel;
@class MMDataParseLocalData;

@interface MMDataParseSuper : NSObject

/**
 *  逻辑回调代码
 */
@property (nonatomic, weak) id<MMClientRequestDelegate> m_delegate;

/**
 *  解析数据的类
 */
@property (nonatomic) id<MMParseToObjectToDatabaseDelegate> parseToObject;

/**
 *  请求网络数据进行入队操作 get
 *  by : lcc
 *  datetime:2012-8-17
 *
 *  @param params     所有参数集合
 *  @param sysParams  系统参数结合
 *  @param methodName 请求名字
 *  @param timerCount
 */
- (void) beginRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger)timerCount;

/**
 *  请求网络数据进行入队操作 post
 *  by : lcc
 *  datetime:2014 - 1 - 2
 *
 *  @param params     所有参数集合
 *  @param sysParams  系统参数结合
 *  @param methodName 请求名字
 *  @param timerCount
 */
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger)timerCount;

/**
 *  请求网络数据进行入队操作 post
 *  by : lcc
 *  datetime:2014 - 1 - 2
 *
 *  @param params     所有参数集合
 *  @param sysParams  系统参数结合
 *  @param methodName 请求名字
 *  @param timerCount
 *  @param formBodyParam http body字段
 */
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *)params systemParams:(NSMutableDictionary *)sysParams methodName:(NSString *)methodName freshTime:(NSInteger)timerCount formBodyParam:(NSMutableDictionary *)formBodyParam;

/**
 *  网络数据返回成功回调 成功
 *
 *  @param responseModel 请求返回的结果
 */
- (void) dataParseSuperRequestNetAccessLoadWithModel:(MMResponseModel *)responseModel;

/**
 *  网络数据返回失败回调 失败
 *
 *  @param responseModel 请求返回的结果
 */
- (void) dataParseSuperRequestNetAccessLoadFailedWithModel:(MMResponseModel *)responseModel;

@end

/**
 *  用于本地保存的data
 */
@interface MMDataParseLocalData : NSObject

@property (nonatomic, copy) NSString *requestMethodName;
@property (nonatomic, copy) NSString *responseDataObject;

@end
