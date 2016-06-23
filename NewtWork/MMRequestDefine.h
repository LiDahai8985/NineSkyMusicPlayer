//
//  MMRequestComment.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/5/6.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#ifndef XinHuaPublish_MMRequestDefine_h
#define XinHuaPublish_MMRequestDefine_h

/**
 *  用于判断是否保存到本地
 */
static NSString* kResponseModel_LocalSave_Sign = @"kResponseModel_LocalSave_Sign";

/**
 *  请求的地址
 */
static NSString* kRequestModel_HTTPURL_Sign = @"kRequestModel_HTTPURL_Sign";

/**
 *  保存到本地的唯一区别码，默认是请求方法名method
 */
static NSString* kResponseModel_LocalSaveId_Sign = @"kResponseModel_LocalSaveId_Sign";

/**
 *  缓存策略
 */
static NSString* kResponseModel_CachePolicy_Sign = @"kResponseModel_CachePolicy_Sign";

/**
 *  缓存策略
 */

typedef NS_ENUM(NSUInteger, MMRequestCachePolicy)
{
    /**
     *  默认的，忽略缓存数据，此种情况下不缓存本地数据
     *  对于的网络回调方法 methodStrCallBack:
     */
    MMRequestReloadIgnoringCacheData = 0,
    
    /**
     *  先加载本地数据，再请求网络数据
     *  对应的网络回调方法 methodStrBeforeLoadCacheCallBack:(网络加载前调用) 和 methodStrCallBack:(网络加载后调用)
     */
    MMRequestReturnCacheDataElseLoad = 1,
    
    /**
     *  只加载本地数据，不请求网络数据，及网络只会请求一次
     *  对应的网络回调方法 methodStrNontLoadCacheCallBack:
     */
    MMRequestReturnCacheDataDontLoad = 2,
    
    /**
     *  只在网络失败的时候，加载本地数据
     *  对应的网络回调方法 methodStrFailLoadCacheCallBack:
     */
    MMRequestReturnCacheDataWhenFailed = 3,
    
};

#endif
