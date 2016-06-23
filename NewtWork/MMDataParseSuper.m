//
//  MMDataParseSuper.m
//  XinHuaPublish
//
//  Created by wangyangyang on 15/3/16.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMDataParseSuper.h"
#import "MMRequestBegin.h"


@interface MMDataParseSuper() <MMRequestBeginDelegate>

@property (strong, nonatomic) MMRequestBegin *myRequest;

@end

@implementation MMDataParseSuper

- (void)dealloc
{

}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        self.myRequest = [[MMRequestBegin alloc] init];
        [self.myRequest setR_delegate:self];
    }
    
    return self;
    
}

/*
 功能: 请求网络数据进行入队操作 get
 by : lcc
 datetime:2012-8-17
 
 参数:params 所有参数集合
 methodName 意思如名字
 */
- (void) beginRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger)timerCount
{
    [self.myRequest beginRequestDataWithParam:params systemParams:sysParams methodName:methodName freshTime:timerCount];
}

/*
 功能: 请求网络数据进行入队操作 post
 by : lcc
 datetime:2014 - 1 - 2
 参数:params 所有参数集合
 methodName 意思如名字
 */
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams methodName:(NSString *)methodName freshTime:(NSInteger)timerCount
{
    [self.myRequest beginPostRequestDataWithParam:params systemParams:sysParams methodName:methodName freshTime:timerCount];
}

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
- (void) beginPostRequestDataWithParam:(NSMutableDictionary *)params systemParams:(NSMutableDictionary *)sysParams methodName:(NSString *)methodName freshTime:(NSInteger)timerCount formBodyParam:(NSMutableDictionary *)formBodyParam
{
    [self.myRequest beginPostRequestDataWithParam:params systemParams:sysParams methodName:methodName freshTime:timerCount formBodyParam:formBodyParam];
}

#pragma mark -
#pragma mark - 网络访问代理

//数据返回成功
- (void) requestBeginLoadFinishedWithModel:(MMResponseModel *)responseModel
{
    [self dataParseSuperRequestNetAccessLoadWithModel:responseModel];
}

//数据放回失败
- (void) requestBeginLoadFailedWithModel:(MMResponseModel *)responseModel
{
    [self dataParseSuperRequestNetAccessLoadFailedWithModel:responseModel];
}

//从缓存中返回数据
- (void) requestBeginNoLoadCacheDataWithModel:(MMResponseModel *)responseModel
{
    [self dataParseSuperRequestNetAccessNoLoadCacheDataWithModel:responseModel];
}

#pragma mark -
#pragma mark - 数据解析

- (void) dataParseSuperRequestNetAccessLoadWithModel:(MMResponseModel *)responseModel
{
    NSString *methodName = responseModel.requestMethodName;
    id responseDataObject = responseModel.responseDataObject;
    
    NSAssert(self.parseToObject, @"MMDataParseSuper---parseToObject不存在，无法解析");
    NSAssert(self.m_delegate, @"MMDataParseSuper---m_delegate未设置，无法回调");
    
    @try {
        //本地数据解析成对象或者数组
        NSMutableArray *infoArr = [self.parseToObject paraseDataFromResponseModel:responseModel];
        
        [self.m_delegate finishLoadDataCallBack:methodName loadingData:infoArr];
        
#pragma mark 判断是否要把网络数据保存在本地
        //判断是否要把网络数据保存在本地，判断是否开启缓存，判断缓存策略是否不是默认
        NSMutableDictionary *sysParams = responseModel.sysParams;
        if (sysParams && [[sysParams objectForKey:kResponseModel_LocalSave_Sign] boolValue] && [[sysParams objectForKey:kResponseModel_CachePolicy_Sign] integerValue] != MMRequestReloadIgnoringCacheData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.parseToObject saveResponseModelInDB:responseModel];
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"----%@----接口数据返回解析异常----%@",methodName,responseDataObject);
        [self dataParseSuperRequestNetAccessLoadFailedWithModel:responseModel];
    }
}

- (void) dataParseSuperRequestNetAccessLoadFailedWithModel:(MMResponseModel *)responseModel
{

    NSAssert(self.parseToObject, @"MMDataParseSuper---parseToObject不存在，无法解析");
    NSAssert(self.m_delegate, @"MMDataParseSuper---m_delegate未设置，无法回调");
    
    NSMutableDictionary *sysParams = responseModel.sysParams;
    
    //代理回调
    [self.m_delegate failLoadData:responseModel.requestMethodName reasonError:responseModel.responseError];
}

- (void) dataParseSuperRequestNetAccessNoLoadCacheDataWithModel:(MMResponseModel *)responseModel
{
    //判断缓存模式，来调用
    MMRequestCachePolicy cachePolicy = [[responseModel.sysParams objectForKey:kResponseModel_CachePolicy_Sign] integerValue];

    
    //代理回调
    [self.m_delegate failLoadData:responseModel.requestMethodName reasonError:responseModel.responseError];
}

@end

/**
 *  用于本地保存的data
 */

@implementation MMDataParseLocalData

@end
