//
//  MMHttpRequest.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/3/16.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMResponseModel.h"

@protocol MMHttpRequestDelegate;

@interface MMHttpRequest : NSObject

/*
 功 能: 每次生产出一个新的请求链接
 date: 2013 - 5 - 12
 param: httpMethod 具体某一个方法的名字
 params 参数如 id，name 等
 */
+ (BOOL)createRequestWithParams:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams  httpMethod:(NSString *) methodName freshTime:(NSInteger) timerCount callBack:(id<MMHttpRequestDelegate>)callBack;

/*
 功 能: 每次生产出一个新的请求 post
 date: 2014 - 1 - 2
 param: httpMethod 具体某一个方法的名字
 params 参数如 id，name 等
 */
+ (BOOL)createFormRequestWithParams:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams httpMethod:(NSString *) methodName freshTime:(NSInteger) timerCount callBack:(id<MMHttpRequestDelegate>)callBack;

/*
 功 能: 每次生产出一个新的请求 post
 date: 2014 - 1 - 2
 param: httpMethod 具体某一个方法的名字
 params 参数如 id，name 等
 formBodyParam http body 字段
 */
+ (BOOL)createFormRequestWithParams:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams httpMethod:(NSString *) methodName freshTime:(NSInteger) timerCount callBack:(id<MMHttpRequestDelegate>)callBack  formBodyParam:(NSMutableDictionary *)formBodyParam;

//获取上次刷新的时间
+ (NSMutableDictionary *)shareTimeArr;

@end

@protocol MMHttpRequestDelegate <NSObject>

- (void)httpRequestFinished:(MMResponseModel *)responseModel;

- (void)httpRequestFailed:(MMResponseModel *)responseModel;

- (void)httpRequestCacheData:(MMResponseModel *)responseModel;

@end
