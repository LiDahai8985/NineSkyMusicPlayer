//
//  MMRequestBegin.m
//  XinHuaPublish
//
//  Created by wangyangyang on 15/3/16.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMRequestBegin.h"
#import "AFNetworking.h"
#import "MMHttpRequest.h"
#import "CommonDefine.h"
#import "MMDataParseSuper.h"

@interface MMRequestBegin () <MMHttpRequestDelegate>

@end

@implementation MMRequestBegin

- (void)dealloc
{
    self.r_delegate = nil;
}

#pragma mark -
#pragma mark - MMHttpRequestDelegate

- (void)httpRequestFinished:(MMResponseModel *)responseModel
{
    if (self.r_delegate && [self.r_delegate respondsToSelector:@selector(requestBeginLoadFinishedWithModel:)])
    {
        [self.r_delegate requestBeginLoadFinishedWithModel:responseModel];
    }
}

- (void)httpRequestFailed:(MMResponseModel *)responseModel
{
    if (self.r_delegate && [self.r_delegate respondsToSelector:@selector(requestBeginLoadFailedWithModel:)])
    {
        [self.r_delegate requestBeginLoadFailedWithModel:responseModel];
    }
}

- (void)httpRequestCacheData:(MMResponseModel *)responseModel
{
    if (self.r_delegate && [self.r_delegate respondsToSelector:@selector(requestBeginNoLoadCacheDataWithModel:)])
    {
        [self.r_delegate requestBeginNoLoadCacheDataWithModel:responseModel];
    }
}

#pragma mark -
#pragma mark - 发出网络请求
/*
 功能: 请求网络数据进行入队操作
 by : lcc
 datetime:2012-8-17
 参数:params 所有参数集合
 methodName 意思如名字
 */
- (void) beginRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams  methodName:(NSString *)methodName  freshTime:(NSInteger) timerCount
{
    //如果是演示版本，则缓存所有接口
    if ([StatusBarObject getCacheStatus] && sysParams == nil) {
        //系统参数
        sysParams = [[NSMutableDictionary alloc] init];
        //添加本地缓存
        [sysParams setValue:[@(YES) stringValue] forKey:kResponseModel_LocalSave_Sign];
        //如果由分页码，默认加上分页
        if ([[params allKeys] containsObject:@"pn"]) {
            [sysParams setValue:[NSString stringWithFormat:@"%@%@",methodName,[params objectForKey:@"pn"]] forKey:kResponseModel_LocalSaveId_Sign];
        }
        //添加缓存策略
        [sysParams setValue:@(MMRequestReturnCacheDataDontLoad) forKey:kResponseModel_CachePolicy_Sign];
    }
    //判断判断策略是否从缓存中直接读取，回调成功请求的方法
    if (sysParams && [sysParams objectForKey:kResponseModel_CachePolicy_Sign]) {
        MMRequestCachePolicy cachePolicy = [[sysParams objectForKey:kResponseModel_CachePolicy_Sign] integerValue];
        if (cachePolicy == MMRequestReturnCacheDataElseLoad || cachePolicy == MMRequestReturnCacheDataDontLoad) {
            MMResponseModel *responseModel = [MMResponseModel new];
            responseModel.requestOperation = nil;
            responseModel.responseDataObject = nil;
            responseModel.requestMethodName = methodName;
            if (sysParams) {
                responseModel.sysParams = [sysParams mutableCopy];
            }
            if ([[(MMDataParseSuper *)self.r_delegate parseToObject] updateResponseModelInDB:responseModel]) {
                [self httpRequestCacheData:responseModel];
                //如果缓存策略是只加载缓存数据，则返回
                if (cachePolicy == MMRequestReturnCacheDataDontLoad) {
                    return;
                }
            }
        }
    }
    BOOL requestCreateResult = [MMHttpRequest createRequestWithParams:params systemParams:sysParams httpMethod:methodName freshTime:timerCount callBack:self];
    if (requestCreateResult == NO)
    {
        if (self.r_delegate && [self.r_delegate respondsToSelector:@selector(requestBeginLoadFailedWithModel:)])
        {
            MMResponseModel *responseModel = [MMResponseModel new];
            responseModel.requestOperation = nil;
            responseModel.responseDataObject = nil;
            responseModel.requestMethodName = methodName;
            responseModel.responseError = [NSError errorWithDomain:@"无法创建对象" code:0 userInfo:@{}];
            if (sysParams) {
                responseModel.sysParams = [sysParams mutableCopy];
            }
            [self.r_delegate requestBeginLoadFailedWithModel:responseModel];
        }
    }
}

/*
 功能: 请求网络数据进行入队操作 post
 by : lcc
 datetime:2014 - 1 - 2
 参数:params 所有参数集合
 methodName 意思如名字
 */
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger) timerCount
{
    //如果是演示版本，则缓存所有接口
    if ([StatusBarObject getCacheStatus] && sysParams == nil) {
        //系统参数
        sysParams = [[NSMutableDictionary alloc] init];
        //添加本地缓存
        [sysParams setValue:[@(YES) stringValue] forKey:kResponseModel_LocalSave_Sign];
        //如果由分页码，默认加上分页
        if ([[params allKeys] containsObject:@"pn"]) {
            [sysParams setValue:[NSString stringWithFormat:@"%@%@",methodName,[params objectForKey:@"pn"]] forKey:kResponseModel_LocalSaveId_Sign];
        }
        //添加缓存策略
        [sysParams setValue:@(MMRequestReturnCacheDataWhenFailed) forKey:kResponseModel_CachePolicy_Sign];
    }
    //判断判断策略是否从缓存中直接读取，回调成功请求的方法
    if (sysParams && [sysParams objectForKey:kResponseModel_CachePolicy_Sign]) {
        MMRequestCachePolicy cachePolicy = [[sysParams objectForKey:kResponseModel_CachePolicy_Sign] integerValue];
        if (cachePolicy == MMRequestReturnCacheDataElseLoad || cachePolicy == MMRequestReturnCacheDataDontLoad) {
            MMResponseModel *responseModel = [MMResponseModel new];
            responseModel.requestOperation = nil;
            responseModel.responseDataObject = nil;
            responseModel.requestMethodName = methodName;
            if (sysParams) {
                responseModel.sysParams = [sysParams mutableCopy];
            }
            if ([[(MMDataParseSuper *)self.r_delegate parseToObject] updateResponseModelInDB:responseModel]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self httpRequestCacheData:responseModel];
                });
                //如果缓存策略是只加载缓存数据，则返回
                if (cachePolicy == MMRequestReturnCacheDataDontLoad) {
                    return;
                }
            }
        }
    }
    BOOL requestCreateResult = [MMHttpRequest createFormRequestWithParams:params systemParams:sysParams httpMethod:methodName freshTime:timerCount callBack:self];
    if (requestCreateResult == NO)
    {
        if (self.r_delegate && [self.r_delegate respondsToSelector:@selector(requestBeginLoadFailedWithModel:)])
        {
            MMResponseModel *responseModel = [MMResponseModel new];
            responseModel.requestOperation = nil;
            responseModel.responseDataObject = nil;
            responseModel.requestMethodName = methodName;
            responseModel.responseError = [NSError errorWithDomain:@"无法创建对象" code:0 userInfo:@{}];
            if (sysParams) {
                responseModel.sysParams = [sysParams mutableCopy];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.r_delegate requestBeginLoadFailedWithModel:responseModel];
            });
        }
    }
}

/*
 功能: 请求网络数据进行入队操作 post
 by : lcc
 datetime:2014 - 1 - 2
 参数:params 所有参数集合
 methodName 意思如名字
 formBodyParam http body字段
 */
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger) timerCount formBodyParam:(NSMutableDictionary *)formBodyParam
{
    BOOL requestCreateResult = [MMHttpRequest createFormRequestWithParams:params systemParams:sysParams httpMethod:methodName freshTime:timerCount callBack:self formBodyParam:formBodyParam];
    if (requestCreateResult == NO)
    {
        if (self.r_delegate && [self.r_delegate respondsToSelector:@selector(requestBeginLoadFailedWithModel:)])
        {
            MMResponseModel *responseModel = [MMResponseModel new];
            responseModel.requestOperation = nil;
            responseModel.responseDataObject = nil;
            responseModel.requestMethodName = methodName;
            responseModel.responseError = [NSError errorWithDomain:@"无法创建对象" code:0 userInfo:@{}];
            if (sysParams) {
                responseModel.sysParams = [sysParams mutableCopy];
            }
            [self.r_delegate requestBeginLoadFailedWithModel:responseModel];
        }
    }
}

@end
