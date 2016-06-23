//
//  MMHttpRequest.m
//  XinHuaPublish
//
//  Created by wangyangyang on 15/3/16.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMHttpRequest.h"
#import "AFNetworking.h"
#import "MMRequestDefine.h"
#import "CommonDefine.h"

static NSMutableDictionary *timeDictionary = nil;

@implementation MMHttpRequest

//获取上次刷新的时间
+ (NSMutableDictionary *) shareTimeArr
{
    @synchronized (self)
    {
        if (timeDictionary == nil)
        {
            timeDictionary = [[NSMutableDictionary alloc] init];
        }
    }
    
    return timeDictionary;
}

/*
 功 能: 每次生产出一个新的请求 get
 date: 2013 - 5 - 12
 param: httpMethod 具体某一个方法的名字
 params 参数如 id，name 等
 by:lcc

 */
+ (BOOL)createRequestWithParams:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams  httpMethod:(NSString *) methodName freshTime:(NSInteger) timerCount callBack:(id<MMHttpRequestDelegate>)callBack
{
    if ([self continueFreshWithMethodName:methodName freshTime:timerCount])
    {
        NSInteger paramsCount = [[params allKeys] count];
        NSMutableString *parameterList=[NSMutableString stringWithCapacity:64];
        
        //获取参数用于传递
        for (int i = 0; i < paramsCount; i++)
        {
            //获取键值
            NSString *tmpKey = [[params allKeys] objectAtIndex:i];
            NSString *tmpKeyValue = [NSString stringWithFormat:@"%@",[params objectForKey:tmpKey]];
            
            /*这里应该对键值进行编码
             *编码原因是因为在用到汉字，会报错 -- bad url
             */
            if (i == 0)
            {
                [parameterList appendFormat:@"%@=%@",tmpKey,[self URLEncodedString:tmpKeyValue]];
            }
            else
            {
                [parameterList appendFormat:@"&%@=%@",tmpKey,[self URLEncodedString:tmpKeyValue]];
            }
        }
        
        //请求的地址,判断是否有自定义地址，默认为HTTPURL
        NSString *urlPathStr = nil;
        if (sysParams && [[sysParams allKeys] containsObject:kRequestModel_HTTPURL_Sign]) {
            [NSString stringWithFormat:@"%@?%@",[sysParams objectForKey:kRequestModel_HTTPURL_Sign],parameterList];
        }
        else {
            
                NSString *rootUrl = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyAppRootUrl"]];
                if(rootUrl && [rootUrl length] > 0 && ![rootUrl isEqualToString:@"null"] && ![rootUrl isEqualToString:@"<null>"] && ![rootUrl isEqualToString:@"(null)"])
                {
                    [NSString stringWithFormat:@"%@?%@",rootUrl,parameterList];
                    
                }
                else
                {
                    [NSString stringWithFormat:@"%@?%@",HTTPURL,parameterList];
                }
        }
        
#ifndef DEBUG
        NSLog(@"请求链接地址:%@",urlPathStr);
#endif
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSError *serializationError = nil;
        NSMutableURLRequest *requestOne = [manager.requestSerializer requestWithMethod:@"GET" URLString:urlPathStr parameters:nil error:&serializationError];
        requestOne.timeoutInterval = RequestTimeoutInterval;
        AFHTTPRequestOperation *operation =  [manager HTTPRequestOperationWithRequest:requestOne success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (callBack && [callBack respondsToSelector:@selector(httpRequestFinished:)]) {
                MMResponseModel *responseModel = [MMResponseModel new];
                responseModel.requestOperation = operation;
                responseModel.responseDataObject = responseObject;
                responseModel.requestMethodName = methodName;
                if (sysParams) {
                    responseModel.sysParams = [sysParams mutableCopy];
                }
                [callBack httpRequestFinished:responseModel];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"----%@-----Error: %@", urlPathStr, error);
            if (callBack && [callBack respondsToSelector:@selector(httpRequestFailed:)]) {
                MMResponseModel *responseModel = [MMResponseModel new];
                responseModel.requestOperation = operation;
                responseModel.responseError = error;
                responseModel.requestMethodName = methodName;
                if (sysParams) {
                    responseModel.sysParams = [sysParams mutableCopy];
                }
                [callBack httpRequestFailed:responseModel];
            }
        }];
        [manager.operationQueue addOperation:operation];
        return YES;
    }
    else
    {
        return NO;
    }
}

/*
 功 能: 每次生产出一个新的请求 post
 date: 2014 - 1 - 2
 param: httpMethod 具体某一个方法的名字
 params 参数如 id，name 等
 */
+ (BOOL)createFormRequestWithParams:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams httpMethod:(NSString *) methodName freshTime:(NSInteger) timerCount callBack:(id<MMHttpRequestDelegate>)callBack
{
    if ([self continueFreshWithMethodName:methodName freshTime:timerCount])
    {
        //请求的地址,判断是否有自定义地址，默认为HTTPURL
        NSString *urlPathStr = nil;
        if (sysParams && [[sysParams allKeys] containsObject:kRequestModel_HTTPURL_Sign]) {
            urlPathStr = [NSString stringWithFormat:@"%@%@",[sysParams objectForKey:kRequestModel_HTTPURL_Sign],methodName];
        }
        else {
            if ([methodName isEqualToString:AppUrlInit]) {
                urlPathStr = [NSString stringWithFormat:@"http://xhpfm.mobile.zhongguowangshi.com:8091/init"];
            }
            else
            {
                NSString *rootUrl = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyAppRootUrl"]];
                if(rootUrl && [rootUrl length] > 0 && ![rootUrl isEqualToString:@"null"] && ![rootUrl isEqualToString:@"<null>"] && ![rootUrl isEqualToString:@"(null)"])
                {
                    urlPathStr = [NSString stringWithFormat:@"%@%@",rootUrl,methodName];
                }
                else
                {
                    urlPathStr = [NSString stringWithFormat:@"%@%@",HTTPURL,methodName];
                }
            }
        }
        
#ifndef DEBUG
        NSLog(@"请求链接地址:%@",urlPathStr);
#endif
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters addEntriesFromDictionary:params];

        NSError *serializationError = nil;
        NSMutableURLRequest *requestOne = [manager.requestSerializer requestWithMethod:@"POST" URLString:urlPathStr parameters:parameters error:&serializationError];
        requestOne.timeoutInterval = RequestTimeoutInterval;
        
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:requestOne success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (callBack && [callBack respondsToSelector:@selector(httpRequestFinished:)]) {
                MMResponseModel *responseModel = [MMResponseModel new];
                responseModel.requestOperation = operation;
                responseModel.responseDataObject = responseObject;
                responseModel.requestMethodName = methodName;
                if (sysParams) {
                    responseModel.sysParams = [sysParams mutableCopy];
                }
                [callBack httpRequestFinished:responseModel];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"----%@-----Error: %@", urlPathStr, error);
            if (callBack && [callBack respondsToSelector:@selector(httpRequestFailed:)]) {
                MMResponseModel *responseModel = [MMResponseModel new];
                responseModel.requestOperation = operation;
                responseModel.responseError = error;
                responseModel.requestMethodName = methodName;
                if (sysParams) {
                    responseModel.sysParams = [sysParams mutableCopy];
                }
                [callBack httpRequestFailed:responseModel];
            }
        }];
        [manager.operationQueue addOperation:operation];
        return YES;
    }
    else
    {
        return NO;
    }
}

/*
 功 能: 每次生产出一个新的请求 post
 date: 2014 - 1 - 2
 param: httpMethod 具体某一个方法的名字
 params 参数如 id，name 等
 formBodyParam http body 字段
 */
+ (BOOL)createFormRequestWithParams:(NSMutableDictionary *) params systemParams:(NSMutableDictionary *) sysParams httpMethod:(NSString *) methodName freshTime:(NSInteger) timerCount callBack:(id<MMHttpRequestDelegate>)callBack  formBodyParam:(NSMutableDictionary *)formBodyParam
{
    if ([self continueFreshWithMethodName:methodName freshTime:timerCount])
    {
        //请求的地址,判断是否有自定义地址，默认为HTTPURL
        NSString *urlPathStr = nil;
        if (sysParams && [[sysParams allKeys] containsObject:kRequestModel_HTTPURL_Sign]) {
            urlPathStr = [NSString stringWithFormat:@"%@%@",[sysParams objectForKey:kRequestModel_HTTPURL_Sign],methodName];
        }
        else {
            if ([methodName isEqualToString:AppUrlInit]) {
                urlPathStr = [NSString stringWithFormat:@"http://xhpfm.mobile.zhongguowangshi.com:8091/init"];
            }
            else
            {
                NSString *rootUrl = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MyAppRootUrl"]];
                if(rootUrl && [rootUrl length] > 0 && ![rootUrl isEqualToString:@"null"] && ![rootUrl isEqualToString:@"<null>"] && ![rootUrl isEqualToString:@"(null)"])
                {
                    urlPathStr = [NSString stringWithFormat:@"%@%@",rootUrl,methodName];
                }
                else
                {
                    urlPathStr = [NSString stringWithFormat:@"%@%@",HTTPURL,methodName];
                }
            }
        }
        
#ifndef DEBUG
        NSLog(@"请求链接地址:%@",urlPathStr);
#endif
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:sysParams];
        [parameters addEntriesFromDictionary:params];
        
        AFHTTPRequestOperation *operation = [manager POST:urlPathStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            __weak id<AFMultipartFormData> weakFormData = formData;
            //添加要上传到http body 字段的值
            [formBodyParam enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSData *dataUpload = [NSData dataWithContentsOfFile:obj];
                    [weakFormData appendPartWithFileData:dataUpload name:key fileName:@"userText.png" mimeType:@"image/png"];
                }
                else if ([obj isKindOfClass:[NSData class]]) {
                    [weakFormData appendPartWithFormData:obj name:key];
                }
                else {
                    [weakFormData appendPartWithFileURL:obj name:key error:nil];
                }
            }];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (callBack && [callBack respondsToSelector:@selector(httpRequestFinished:)]) {
                MMResponseModel *responseModel = [MMResponseModel new];
                responseModel.requestOperation = operation;
                responseModel.responseDataObject = responseObject;
                responseModel.requestMethodName = methodName;
                if (sysParams) {
                    responseModel.sysParams = [sysParams mutableCopy];
                }
                [callBack httpRequestFinished:responseModel];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            if (callBack && [callBack respondsToSelector:@selector(httpRequestFailed:)]) {
                MMResponseModel *responseModel = [MMResponseModel new];
                responseModel.requestOperation = operation;
                responseModel.responseError = error;
                responseModel.requestMethodName = methodName;
                if (sysParams) {
                    responseModel.sysParams = [sysParams mutableCopy];
                }
                [callBack httpRequestFailed:responseModel];
            }
        }];
        return YES;
    }
    else
    {
        return NO;
    }
}

/*
 功 能: 主要对汉字以及特殊符号进行编码处理
 date: 2013 - 6 - 10
 param: myString:要编码的字符串
 by:lcc
 */
+ (NSString *)URLEncodedString:(NSString *) myString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (CFStringRef)myString,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8));
    return result;
}

#pragma mark -
#pragma mark - 请求入"对"
/*
 功能: 防止用户不断请求刷新
 date:2013 - 6 - 11
 methodName 意思如名字
 */
+ (BOOL) continueFreshWithMethodName:(NSString *)methodName freshTime:(NSInteger) timerCount
{
    BOOL isFresh = NO;
    
    NSMutableDictionary *tmpDic = [MMHttpRequest shareTimeArr];
    
    //计算时间
    NSDate *date = [NSDate date];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSTimeInterval nowTime=[date timeIntervalSince1970]*1;
    
    if ([tmpDic.allKeys containsObject:methodName])
    {
        //取出上次刷新的时间进行比对
        double oldTime = [[tmpDic objectForKey:methodName] doubleValue];
        
        
        if (nowTime - oldTime > timerCount)
        {
            isFresh = YES;
            [tmpDic setObject:[NSString stringWithFormat:@"%f",nowTime] forKey:methodName];
        }
        else
        {
            isFresh = NO;
        }
    }
    else
    {
        isFresh = YES;
        
        [tmpDic setObject:[NSString stringWithFormat:@"%f",nowTime] forKey:methodName];
    }
    
    return isFresh;
}

@end