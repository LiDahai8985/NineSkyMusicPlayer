//
//  CCClientRequest.m
//  WoZaiXianChang
//
//  Created by lcc on 13-9-17.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import "CCClientRequest.h"
#import "MMDataParseSuper.h"
#import "CCParseToObjectToDatabase.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonDigest.h>

//刷新时间
#define FreshTimeTypeOne 0
#define FreshTimeTypeTwo 0

@interface CCClientRequest()
{
    MMDataParseSuper *superRequest;
}

@end

//所有界面数据返回 与 请求
@implementation CCClientRequest

- (void)dealloc
{
    [superRequest setM_delegate:nil];
    superRequest = nil;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        superRequest = [[MMDataParseSuper alloc] init];
        superRequest.parseToObject = [[CCParseToObjectToDatabase alloc] init];
        [superRequest setM_delegate:self];
        
    }
    
    return self;
}

#pragma mark - 
#pragma mark - 所有数据请求

//初始化根地址信息
- (void)appUrlInit
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [self addParamToDic:params];
    
}




#pragma mark -
#pragma mark - MMClientRequestDelegate

- (void) finishLoadDataCallBack:(NSString *) methodName loadingData:(id) objectData
{
    //替换方法部分内容，防止调用不成功
    methodName = [methodName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //根据返回的方法明动态调用
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@CallBack:",methodName]);
    @try {
        //代理回调
        [self c_delegatePerformSelector:selector withObject:objectData withObject:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@----------解析失败",methodName);
        [self failLoadData:[NSString stringWithFormat:@"%@CallBack:",methodName]];
    }
}


/**
 *  正常网络请求，请求失败后调用，用户兼容老的版本
 *
 */
- (void)failLoadData:(id) reasonString
{
    if (self.c_delegate != nil && [self.c_delegate respondsToSelector:@selector(failLoadData:)])
    {
        [self.c_delegate performSelector:@selector(failLoadData:) withObject:reasonString];
    }
}

/**
 *  正常网络请求，请求失败后调用，新的版本使用，加了请求方法名回调
 *
 */
- (void)failLoadData:(NSString *) methodName reasonError:(NSError *) reasonError
{
    //替换方法部分内容，防止调用不成功
    methodName = [methodName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //根据返回的方法明动态调用
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@FailLoadData:",methodName]);
    @try {
        //代理回调，兼容老版本的错误返回方法
        if ([self c_delegatePerformSelector:selector withObject:reasonError withObject:nil] == NO) {
            [self failLoadData:methodName];
        };
    }
    @catch (NSException *exception) {
        NSLog(@"%@----------解析失败",methodName);
        [self failLoadData:@"请稍后重试"];
    }
}

- (BOOL)c_delegatePerformSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2
{
    if (self.c_delegate != nil && [self.c_delegate respondsToSelector:selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.c_delegate performSelector:selector withObject:object1 withObject:object2];
#pragma clang diagnostic pop
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - 系统参数

- (void) addParamToDic:(NSMutableDictionary *) params
{
    //end
    
    NSLog(@"-------->%@",params);
}

#pragma mark -
#pragma mark - 工具方法
//服务权限接口
-(NSString *)sha1:(NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end