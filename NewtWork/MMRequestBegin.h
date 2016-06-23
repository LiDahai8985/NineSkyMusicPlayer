//
//  MMRequestBegin.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/3/16.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMResponseModel.h"

@protocol MMRequestBeginDelegate <NSObject>
/*
 功能:成功返回数据
 */
- (void) requestBeginLoadFinishedWithModel:(MMResponseModel *)responseModel;

/*
 功能:数据请求失败
 */
- (void) requestBeginLoadFailedWithModel:(MMResponseModel *)responseModel;

/*
 功能:从缓存中返回数据
 */
- (void) requestBeginNoLoadCacheDataWithModel:(MMResponseModel *)responseModel;

@end

@interface MMRequestBegin : NSObject

@property (weak) id<MMRequestBeginDelegate> r_delegate;

/*
 功能: 请求网络数据进行入队操作
 by : lcc
 datetime:2012-8-17
 参数:params 所有参数集合
 methodName 意思如名字
 */
- (void) beginRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams  methodName:(NSString *)methodName  freshTime:(NSInteger) timerCount;

/*
 功能: 请求网络数据进行入队操作 post
 by : lcc
 datetime:2014 - 1 - 2
 参数:params 所有参数集合
 methodName 意思如名字
 */
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger) timerCount;

/*
 功能: 请求网络数据进行入队操作 post
 by : lcc
 datetime:2014 - 1 - 2
 参数:params 所有参数集合
 methodName 意思如名字
 formBodyParam http body字段
 */
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger) timerCount formBodyParam:(NSMutableDictionary *)formBodyParam;

@end
