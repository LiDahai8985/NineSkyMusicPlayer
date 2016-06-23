//
//  MMParseToObjectToDatabaseDelegate.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/4/5.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#ifndef XinHuaPublish_MMParseToObjectToDatabaseDelegate_h
#define XinHuaPublish_MMParseToObjectToDatabaseDelegate_h

#import "MMResponseModel.h"

@protocol MMParseToObjectToDatabaseDelegate <NSObject>

/*
 功能:数据解析
 date:2014-4-5
 responseModel:要解析的model
 */
- (id) paraseDataFromResponseModel:(MMResponseModel *)responseModel;

/**
 *  数据入库
 *
 *  @param responseModel 要保存的responseModel
 */
- (void) saveResponseModelInDB:(MMResponseModel *)responseModel;

/**
 *  读取本地缓存数据，并更新responseModel
 *
 *  @param responseModel 要更新的responseModel
 *  @return 是否更新成功
 */
- (BOOL) updateResponseModelInDB:(MMResponseModel *)responseModel;

@end

#endif
