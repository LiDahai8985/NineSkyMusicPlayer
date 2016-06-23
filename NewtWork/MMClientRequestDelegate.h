//
//  MMClientRequestDelegate.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/5/8.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMClientRequestDelegate <NSObject>

/**
 *  正常网络请求，成功请求后调用
 *
 */
- (void)finishLoadDataCallBack:(NSString *) methodName loadingData:(id) objectData;


/**
 *  正常网络请求，请求失败后调用，用户兼容老的版本
 *
 */
- (void)failLoadData:(id) reasonString;

/**
 *  正常网络请求，请求失败后调用，新的版本使用，加了请求方法名回调
 *
 */
- (void)failLoadData:(NSString *) methodName reasonError:(NSError *) reasonError;

@end
