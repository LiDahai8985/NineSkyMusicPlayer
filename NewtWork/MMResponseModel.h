//
//  MMResponseModel.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/3/16.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMResponseModel : NSObject

/**
 *  请求结果本身
 */
@property (nonatomic, strong) id requestOperation;

/**
 *  请求得到结果对象，可能是字符串可能是个对象
 */
@property (nonatomic, copy) id responseDataObject;

/**
 *  请求得到的错误信息
 */
@property (nonatomic, strong) NSError *responseError;

/**
 *  请求方法名字
 */
@property (nonatomic, copy) NSString *requestMethodName;

/**
 *  系统参数，用户对每个接口做特定的定制
 */
@property (nonatomic, strong) NSMutableDictionary *sysParams;

@end
