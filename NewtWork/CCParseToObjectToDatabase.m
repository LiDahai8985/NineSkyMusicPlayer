
//
//  ParseToObjectToDatabase.m
//  NetAccessShengji
//
//  Created by lcc on 13-11-1.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import "CCParseToObjectToDatabase.h"
#import "JSONKit.h"
#import "ScrollViewObject.h"
#import "NewsObject.h"
#import "StartImgObjec.h"
#import "NewsDetailObject.h"
#import "CommentObject.h"
#import "SubscribeClassifyObject.h"
#import "FMDBManage.h"
#import "LocalServiceObject.h"
#import "PushInfoObject.h"
#import "MyAskObject.h"
#import "MyOrderObject.h"
#import "OrderParentLatticeObject.h"
#import "MMDataParseSuper.h"
#import "NSData+Base64.h"
#import "SubsribeColumnObject.h"
#import "NewsiLiveObject.h"
#import "MyLiveObject.h"
#import "LiveReportObject.h"
#import "ReportDetailObject.h"
#import "ContactEditObject.h"


@implementation CCParseToObjectToDatabase

#pragma mark -
#pragma mark - 入库

//用户信息入库
- (void) insertUserWithArr:(NSMutableArray *) arr
{
    [FMDBManage deleteFromTable:[UserObject class] WithString:@"1=1"];
    for (UserObject *tmpObj in arr)
    {
        [FMDBManage updateTable:tmpObj setString:@"1=1" WithString:@"1=1"];
    }
}

/**
 *  数据入库
 *
 *  @param responseModel 要保存的responseModel
 */
- (void) saveResponseModelInDB:(MMResponseModel *)responseModel
{
    MMDataParseLocalData *localData = [MMDataParseLocalData new];
    
    NSMutableDictionary *sysParams = responseModel.sysParams;
    if ([sysParams objectForKey:kResponseModel_LocalSaveId_Sign]) {
        localData.requestMethodName = [sysParams objectForKey:kResponseModel_LocalSaveId_Sign];
    }
    else {
        localData.requestMethodName = responseModel.requestMethodName;
    }
    if ([responseModel.responseDataObject isKindOfClass:[NSString class]] == NO) {
        localData.responseDataObject = [responseModel.responseDataObject JSONStringWithOptions:JKSerializeOptionValidFlags error:nil];
    }
    else {
        localData.responseDataObject = responseModel.responseDataObject;
    }
    NSData *localDatatMP = [localData.responseDataObject dataUsingEncoding:NSUTF8StringEncoding];
    localData.responseDataObject = [localDatatMP base64Encoding];
    
    [FMDBManage deleteFromTable:[MMDataParseLocalData class] WithString:[NSString stringWithFormat:@"%@='%@'",@"requestMethodName",localData.requestMethodName]];
    [FMDBManage updateTable:localData setString:[NSString stringWithFormat:@"%@=%@",@"requestMethodName",localData.requestMethodName] WithString:[NSString stringWithFormat:@"%@='%@'",@"requestMethodName",localData.requestMethodName]];
}

/**
 *  读取本地缓存数据，并更新responseModel
 *
 *  @param responseModel 要更新的responseModel
 */
- (BOOL) updateResponseModelInDB:(MMResponseModel *)responseModel
{
    NSString *requestMethodName = nil;
    NSMutableDictionary *sysParams = responseModel.sysParams;
    if ([sysParams objectForKey:kResponseModel_LocalSaveId_Sign]) {
        requestMethodName = [sysParams objectForKey:kResponseModel_LocalSaveId_Sign];
    }
    else {
        requestMethodName = responseModel.requestMethodName;
    }
    NSMutableArray *tmpArr = [FMDBManage getDataFromTable:[MMDataParseLocalData class] WithString:[NSString stringWithFormat:@"%@='%@'",@"requestMethodName",requestMethodName]];
    MMDataParseLocalData *localData = [tmpArr firstObject];
    if (localData) {
        NSData *base64Data = [NSData dataWithBase64EncodedString:localData.responseDataObject];
        responseModel.responseDataObject = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        return YES;
    }
    return NO;
}

/*
 功能:数据解析
 date:2014-4-5
 responseModel:要解析的model
 */
- (id) paraseDataFromResponseModel:(MMResponseModel *)responseModel
{
    NSLog(@"%@-%@",responseModel.requestMethodName,responseModel.responseDataObject);
    
    NSString *methodString = responseModel.requestMethodName;
    NSDictionary *infoDic = nil;
    if ([responseModel.responseDataObject isKindOfClass:[NSDictionary class]])
    {
        infoDic = responseModel.responseDataObject;
    }
    else if ([responseModel.responseDataObject isKindOfClass:[NSString class]])
    {
        infoDic = (NSDictionary *)[responseModel.responseDataObject objectFromJSONString];
    }
    NSMutableArray *infoArr = [[NSMutableArray alloc] init];
    
    if ([infoDic.allKeys containsObject:STATUS]  || [[infoDic allKeys] containsObject:@"msg"])
    {
        //方法替换特殊符号
        methodString = [methodString stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
        
        //提交问记者，记者回复（提示语有后台控制，此方法单独处理）
        if ([methodString isEqualToString:AskReporterOrReporterAnswer])
        {
            [infoArr addObject:infoDic];
        }
        
        //数据返回成功
        else if ([[infoDic objectForKey:STATUS] isEqualToString:SUCCESS])
        {
            //具体接口判断
            if ([infoDic.allKeys containsObject:DATA])
            {
                //取数据
                id tmpArr = [infoDic objectForKey:DATA];
                
                //域名根地址获取
                if ([methodString isEqualToString:AppUrlInit])
                {
                    if (infoDic) {
                        [infoArr addObject:infoDic];
                    }
                }
                //部分加密参数 获取
                else if ([methodString isEqualToString:GetAppInitConfigs])
                {
                    if (infoDic) {
                        [infoArr addObject:infoDic];
                    }
                }
                //首页的导航栏
                else if ([methodString isEqualToString:HOME_LANMU_METHOD])
                {
                    NSMutableArray *tmpDataOrder = [[NSMutableArray alloc] init];
                    //获取首页已订阅数据
                    NSArray *tmpArrOrder = [infoDic objectForKey:@"data_order"];
     
                    //解析首页已订阅数据
                    [tmpArrOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        ScrollViewObject *listObject = [MTLJSONAdapter modelOfClass:ScrollViewObject.class fromJSONDictionary:obj error:&error];
                        [tmpDataOrder addObject:listObject];
                    }];
                    
                    //解析首页所有未订阅数据
                    NSMutableArray *tmpDataAll = [[NSMutableArray alloc] init];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        SubscribeClassifyObject *listObject = [MTLJSONAdapter modelOfClass:SubscribeClassifyObject.class fromJSONDictionary:obj error:&error];
                        listObject.mmProvinceId = [obj objectForKey:@"id"];
                        [tmpDataAll addObject:listObject];
                    }];
                    
                    //添加首页已订阅数据
                    [infoArr addObject:tmpDataOrder];
                    
                    //添加首页所有未订阅的数据
                    [infoArr addObject:tmpDataAll];
            
                }
                //详情页订阅
                else if ([methodString isEqualToString:DetailOrder])
                {
                    [infoArr addObject:infoDic];
                }
                //地方导航栏
                else if ([methodString isEqualToString:DiFang_LANMU_METHOD])
                {
                    //获取地方已订阅数据
                    NSArray *tmpArrAreaOrder = [infoDic objectForKey:@"data_order"];
                    
                    //获取地方所有未订阅数据
                    NSArray *tmpArrAreaAll = [[infoDic objectForKey:@"data"] objectForKey:@"items"];
                    
                    //解析地方已订阅数据
                    NSMutableArray *tmpDataAreaOrder = [[NSMutableArray alloc] init];
                    [tmpArrAreaOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        ScrollViewObject *listObject = [MTLJSONAdapter modelOfClass:ScrollViewObject.class fromJSONDictionary:obj error:&error];
                        [tmpDataAreaOrder addObject:listObject];
                    }];
                    
                    //解析地方所有未订阅数据
                    NSMutableArray *tmpDataAreaAll = [[NSMutableArray alloc] init];
                    [tmpArrAreaAll enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        SubsribeColumnObject *listObject = [MTLJSONAdapter modelOfClass:SubsribeColumnObject.class fromJSONDictionary:obj error:&error];
                        listObject.mmProvinceId = [obj objectForKey:@"id"];
                        [tmpDataAreaAll addObject:listObject];
                    }];
                    
                    //添加地方已订阅数据
                    [infoArr addObject:tmpDataAreaOrder];
                    
                    //添加地方所有未订阅数据
                    [infoArr addObject:tmpDataAreaAll];
                }
                
                //登录  和   第三方登录
                else if ([methodString isEqualToString:USER_LOGIN_METHOD] ||[methodString isEqualToString:USER_OPENREGLOGIN_METHOD])
                {
                    UserObject *tmpObj = [[UserObject alloc] init];
                    tmpObj.u_id = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"userId"]];
                    tmpObj.u_phoneNo = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"account"]];
                    tmpObj.u_userName = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"account"]];
                    tmpObj.u_appID = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"appId"]];
                    tmpObj.u_imgUrl = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"headimage"]];
                    tmpObj.u_userstatus = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"userstatus"]];
                    
                    if ([methodString isEqualToString:USER_OPENREGLOGIN_METHOD]) {
                        tmpObj.u_isThirdLogin = @"1";
                    }
                    else {
                        tmpObj.u_isThirdLogin = @"0";
                    }
                    
                    tmpObj.u_userType = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"usertype"]];
                    
                    XinHuaAppDelegate.userObject = tmpObj;
                    
                    [infoArr addObject:tmpObj];
                    //用户信息存到本地
                    [self insertUserWithArr:infoArr];
                    
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //注册
                else if ([methodString isEqualToString:USER_REGIST_METHOD])
                {
                    UserObject *tmpObj = [[UserObject alloc] init];
                    tmpObj.u_id = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"userId"]];
                    tmpObj.u_phoneNo = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"account"]];
                    tmpObj.u_userName = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"account"]];
                    tmpObj.u_appID = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"appId"]];
                    tmpObj.u_imgUrl = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"headimage"]];
                    tmpObj.u_userstatus = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"userstatus"]];
                    
                    XinHuaAppDelegate.userObject = tmpObj;
                    [infoArr addObject:tmpObj];
                    
                    [self insertUserWithArr:infoArr];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //头像修改
                else if ([methodString isEqualToString:USER_HEADERIMAGE_UPAVATAR]) {
                    [infoArr addObject:infoDic];
                }
                //启动图
                else if ([methodString isEqualToString:START_IMG_METHOD])
                {
                    StartImgObjec *tmpObj = [[StartImgObjec alloc] init];
                    
                    tmpObj.s_imgUrl = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"imgUrl"]];
                    tmpObj.s_hrefurl = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"hrefUrl"]];
                    tmpObj.s_title = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"sTitle"]];
                    tmpObj.s_openType = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"openType"]];
                    tmpObj.s_linkUrl = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"hrefUrl"]];
                    tmpObj.s_staysecond = [NSString stringWithFormat:@"%@",[tmpArr objectForKey:@"staysecond"]];
                    
                    [infoArr addObject:tmpObj];
                    //                        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    //                        [userDefault setValue:tmpObj.s_imgUrl forKey:IMGURL];
                    
                }
                //意见反馈
                else if ([methodString isEqualToString:ADVICE_BACK_METHOD])
                {
                    [infoArr addObject:tmpArr];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //新闻详情
                else if ([methodString isEqualToString:NEWS_DETAIL_METHOD])
                {
                    NSError *error = nil;
                    NewsDetailObject *listObject = [MTLJSONAdapter modelOfClass:NewsDetailObject.class fromJSONDictionary:[tmpArr firstObject] error:&error];
                    [infoArr addObject:listObject];
                }
                //推送消息
                else if ([methodString isEqualToString:USER_PUSHLIST])
                {
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        PushInfoObject *listObject = [MTLJSONAdapter modelOfClass:PushInfoObject.class fromJSONDictionary:obj error:&error];
                        [infoArr addObject:listObject];
                    }];
                }
                //我的评论
                else if ([methodString isEqualToString:USER_COMMENT])
                {
                    NSMutableDictionary *tmpInfoDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *tmpData = [[NSMutableArray alloc] init];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        CommentObject *listObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:obj error:&error];
                        listObject.c_isMyComment = YES;
                        listObject.c_subCommentListArray = [[NSMutableArray alloc] initWithCapacity:0];
                        NSArray *tmpSubList = [obj objectForKey:@"floor"];
                        
                        [tmpSubList enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
                            NSError *subError = nil;
                            CommentObject *subListObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:obj error:&subError];
                            subListObject.c_floorNum = tmpSubList.count - idx;
                            [listObject.c_subCommentListArray addObject:subListObject];
                        }];
                        
                        listObject.c_isHasMore = listObject.c_subCommentListArray && [listObject.c_subCommentListArray count] > 9;
                        
                        [tmpData addObject:listObject];
                    }];
                    
                    [tmpInfoDic setObject:tmpData forKey:DATA];
                    [infoArr addObject:tmpInfoDic];
                }
                //用户修改密码
                else if ([methodString isEqualToString:USER_CHANGEPWD_METHOD])
                {
                    [infoArr addObject:tmpArr];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //用户找回密码
                else if ([methodString isEqualToString:USER_FINDPWD]) {
                    [infoArr addObject:tmpArr];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //用户提交评论
                else if ([methodString isEqualToString:COMMIT_COMMENT_METHOD])
                {
                    NSDictionary *commentObjectDic = [infoDic objectForKey:DATA];
                    NSError *error = nil;
                    CommentObject *listObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:commentObjectDic error:&error];
                    listObject.c_subCommentListArray = [[NSMutableArray alloc] initWithCapacity:0];
                    NSArray *tmpSubList = [commentObjectDic objectForKey:@"floor"];
                    
                    [tmpSubList enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
                        NSError *subError = nil;
                        CommentObject *subListObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:obj error:&subError];
                        subListObject.c_floorNum = tmpSubList.count - idx;
                        [listObject.c_subCommentListArray addObject:subListObject];
                    }];
                    
                    listObject.c_isHasMore = listObject.c_subCommentListArray && [listObject.c_subCommentListArray count] > 9;
                    [infoArr addObject:listObject];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //评论列表
                else if ([methodString isEqualToString:COMMENT_LIST_METHOD])
                {
                    NSMutableDictionary *tmpInfoDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *tmpData = [[NSMutableArray alloc] init];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        CommentObject *listObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:obj error:&error];
                        listObject.c_subCommentListArray = [[NSMutableArray alloc] initWithCapacity:0];
                        NSArray *tmpSubList = [obj objectForKey:@"floor"];
                        
                        [tmpSubList enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
                            NSError *subError = nil;
                            CommentObject *subListObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:obj error:&subError];
                            subListObject.c_floorNum = tmpSubList.count - idx;
                            
                            [listObject.c_subCommentListArray addObject:subListObject];
                        }];
                        
                        listObject.c_isHasMore = listObject.c_subCommentListArray && [listObject.c_subCommentListArray count] > 9;
                        [tmpData addObject:listObject];
                        
                    }];
                    
                    [tmpInfoDic setObject:tmpData forKey:DATA];
                    [infoArr addObject:tmpInfoDic];
                }
                else if ([methodString isEqualToString:USER_REGSHARE])
                {
                    NSLog(@"%@-----分享统计成功",methodString);
                }
                else if ([methodString isEqualToString:CHECK_VERSION_METHOD])
                {
                    [infoArr addObject:tmpArr];
                }
                //首页数据
                else if ([methodString isEqualToString:HOME_LIST_METHOD]) {
                    
                    id tmpArrScroll = [infoDic objectForKey:@"data_scroll"];
                    id tmpArrList = [infoDic objectForKey:@"data"];
                    id tmpArrTufa = [infoDic objectForKey:@"data_topic"];
                    id tmpArrServer = [infoDic objectForKey:@"data_service"];
                    //轮播图数据
                    NSMutableArray *tmpDataScroll = [[NSMutableArray alloc] init];
                    [tmpArrScroll enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        [tmpDataScroll addObject:listObject];
                    }];
                    
                    //服务类数据
                    NSMutableArray *tmpDataServer = [[NSMutableArray alloc] init];
                    [tmpDataServer logOnDealloc];
                    [tmpArrServer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        LocalServiceObject *listObject = [MTLJSONAdapter modelOfClass:LocalServiceObject.class fromJSONDictionary:obj error:&error];
                        [tmpDataServer addObject:listObject];
                    }];
                    
                    //列表数据
                    NSMutableArray *tmpDataList = [[NSMutableArray alloc] init];
                    [tmpDataList logOnDealloc];
                    
                    //接着添加列表数据
                    [tmpArrList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        
                        if (listObject.h_showType.integerValue == 3014)
                        {
                            listObject.h_serverArray = tmpDataServer;
                        }
                        
                        [tmpDataList addObject:listObject];
                    }];
                    
                    //突发事件
                    NSMutableArray *tmpDataTufa = [[NSMutableArray alloc] init];
                    [tmpArrTufa enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        
                        [tmpDataTufa addObject:listObject];
                    }];
                    
                    [infoArr addObject:tmpDataScroll];
                    [infoArr addObject:tmpDataList];
                    [infoArr addObject:tmpDataTufa];
                    [infoArr addObject:tmpDataServer];
                    [infoArr addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:DATAMORESIGN]]];
                }
                //本地新闻
                else if ([methodString isEqualToString:AREANEWS_LIST]) {
                    //轮播数据
                    id tmpArrScroll = [infoDic objectForKey:@"data_scroll"];
                    
                    //列表数据
                    id tmpArrList = [infoDic objectForKey:@"data"];
                    
                    //二级栏目数据
                    id tmpArrCate = [infoDic objectForKey:@"data_cate"];
                    
                    //服务数据
                    id tmpArrServer = [infoDic objectForKey:@"data_service"];
                    
                    //轮播图数据
                    NSMutableArray *tmpDataScroll = [[NSMutableArray alloc] init];
                    [tmpArrScroll enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        [tmpDataScroll addObject:listObject];
                    }];
                    
                    //二级栏目数据
                    NSMutableArray *tmpDataCate = [[NSMutableArray alloc] init];
                    [tmpDataCate logOnDealloc];
                    [tmpArrCate enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NewsObject *listObject = [[NewsObject alloc] init];
                        listObject.h_id = [obj objectForKey:@"id"];
                        listObject.h_groupedCategoryId = [obj objectForKey:@"id"];
                        listObject.h_columntype = [obj objectForKey:@"columntype"];
                        listObject.h_topic = [obj objectForKey:@"name"];
                        listObject.h_newsType = @"1100";
                        listObject.h_newsTag = @"";
                        listObject.h_catename = [obj objectForKey:@"name"];
                        [tmpDataCate addObject:listObject];
                    }];
                    
                    //服务类数据
                    NSMutableArray *tmpDataServer = [[NSMutableArray alloc] init];
                    [tmpDataServer logOnDealloc];
                    [tmpArrServer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        LocalServiceObject *listObject = [MTLJSONAdapter modelOfClass:LocalServiceObject.class fromJSONDictionary:obj error:&error];
                        [tmpDataServer addObject:listObject];
                    }];
                    
                    //列表数据
                    NSMutableArray *tmpDataList = [[NSMutableArray alloc] init];
                    [tmpDataList logOnDealloc];
                    //接着添加列表数据
                    [tmpArrList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        
                        if (listObject.h_showType.integerValue == 3014)
                        {
                            listObject.h_serverArray = tmpDataServer;
                        }
                        
                        [tmpDataList addObject:listObject];
                    }];
                    
                    [infoArr addObject:tmpDataScroll];
                    [infoArr addObject:tmpDataList];
                    [infoArr addObject:tmpDataCate];
                    [infoArr addObject:[infoDic objectForKey:DATAMORESIGN]];
                    [infoArr addObject:[infoDic objectForKey:@"location"]];
                }
                //地方中心的子栏目
                else if ([methodString isEqualToString:CateNews_List]) {
                    id tmpArrScroll = [infoDic objectForKey:@"data_scroll"];
                    id tmpArrList = [infoDic objectForKey:@"data"];
                    //轮播图数据
                    NSMutableArray *tmpDataScroll = [[NSMutableArray alloc] init];
                    [tmpArrScroll enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        [tmpDataScroll addObject:listObject];
                    }];

                    //列表数据
                    NSMutableArray *tmpDataList = [[NSMutableArray alloc] init];
                    [tmpDataList logOnDealloc];
                    //接着添加列表数据
                    [tmpArrList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        
                        [tmpDataList addObject:listObject];
                    }];
                    [infoArr addObject:tmpDataScroll];
                    [infoArr addObject:tmpDataList];
                    [infoArr addObject:[infoDic objectForKey:DATAMORESIGN]];
                }
                //用户栏目订阅
                else if ([methodString isEqualToString:USER_ORDERCOLUMNS]) {
                    [infoArr addObject:tmpArr];
                }
                //栏目城市列表
                else if ([methodString isEqualToString:COLUMN_LIST_METHOD]) {

                    NSDictionary *provinceDic = [infoDic objectForKey:@"province"];
                    SubsribeColumnObject *provinceObject = [MTLJSONAdapter modelOfClass:SubsribeColumnObject.class fromJSONDictionary:provinceDic error:nil];
                    provinceObject.mmProvinceId = [provinceDic objectForKey:@"id"];
                    //总共要选择的
                    NSMutableArray *tmpDataAll = [[NSMutableArray alloc] init];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        SubscribeClassifyObject *listObject = [MTLJSONAdapter modelOfClass:SubscribeClassifyObject.class fromJSONDictionary:obj error:&error];
                        listObject.mmProvinceId = provinceObject.mmProvinceId;
                        [tmpDataAll addObject:listObject];
                    }];
                    [infoArr addObject:provinceObject];
                    [infoArr addObject:tmpDataAll];
                }
                //问记者版本号
                else if ([methodString isEqualToString:USER_OCSVERSION]) {
                    [infoArr addObject:tmpArr];
                }
                //专题
                else if ([methodString isEqualToString:SUBJECT_LIST_METHOD]) {
                    NSArray *tmpArr = [infoDic objectForKey:DATA];
                    
                    NSString *currentThemeColumnName = @"";
                    
                    //存放某一专题子分类中包含的newsObject
                    NSMutableArray *currentThemeColumnArray = [NSMutableArray array];
                    
                    //存放专题的子类
                    NSMutableArray *sectionDataArray = [NSMutableArray array];
                    
                    //key：专题子类的标题  value：对应某一标题的列表array
                    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                    
                    for (NSInteger i = 0; i < tmpArr.count ; i ++)
                    {
                        NSDictionary *tmpDic = [tmpArr objectAtIndex:i];
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:tmpDic error:&error];
                        NSArray *liveDataArray = [tmpDic objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        
                        NSString *themeColumnName = [NSString stringWithFormat:@"%@",[tmpDic objectForKey:@"columnname"]];
                        
                        if ([themeColumnName isEqualToString:currentThemeColumnName] == NO)
                        {
                            //排除 i == 0的情况，如果和之前的themeName不相等，则把现有的section数据保存
                            if ([currentThemeColumnName isEqualToString:@""] == NO) {
                                
                                NSDictionary *tmpLastDic = [tmpArr objectAtIndex:i - 1];
                                NewsObject *tmpObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:tmpLastDic error:&error];
                                NSArray *liveDataArray = [tmpLastDic objectForKey:@"data_report"];
                                if (liveDataArray && liveDataArray.count > 0) {
                                    listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                                }
                                
                                NewsObject *sectionNewsObject = [[NewsObject alloc] init];
                                sectionNewsObject.h_newsTag = @"";
                                sectionNewsObject.h_newsType = @"1100";
                                sectionNewsObject.h_columntype = tmpObject.h_columntype;
                                sectionNewsObject.h_groupedCategoryId = tmpObject.h_columnid;
                                sectionNewsObject.h_catename = currentThemeColumnName;
                                [sectionDataArray addObject:sectionNewsObject];
                                [resultDic setValue:currentThemeColumnArray forKey:currentThemeColumnName];
                                currentThemeColumnArray = [NSMutableArray array];
                            }
                        }
                        //专题列表中不显示catename，重新设置h_catename为空
                        listObject.h_catename = @"";
                        [currentThemeColumnArray addObject:listObject];
                        
                        //如果是最后一条，判断是加在上个section里面，还是新的section里面
                        if (tmpArr.count - 1 == i)
                        {
                            //如果是和之前section的themeName相等，则加在上个section里面
                            if ([themeColumnName isEqualToString:currentThemeColumnName])
                            {
                                NewsObject *sectionNewsObject = [[NewsObject alloc] init];
                                sectionNewsObject.h_newsTag = @"";
                                sectionNewsObject.h_newsType = @"1100";
                                sectionNewsObject.h_columntype = listObject.h_columntype;
                                sectionNewsObject.h_groupedCategoryId = listObject.h_columnid;
                                sectionNewsObject.h_catename = currentThemeColumnName;
                                [sectionDataArray addObject:sectionNewsObject];
                                [resultDic setValue:currentThemeColumnArray forKey:currentThemeColumnName];
                            }
                            //如果和之前的themeName不相等，则加在新的section里面
                            else {
                                NewsObject *sectionNewsObject = [[NewsObject alloc] init];
                                sectionNewsObject.h_newsTag = @"";
                                sectionNewsObject.h_newsType = @"1100";
                                sectionNewsObject.h_columntype = listObject.h_columntype;
                                sectionNewsObject.h_groupedCategoryId = listObject.h_columnid;
                                sectionNewsObject.h_catename = themeColumnName;
                                [sectionDataArray addObject:sectionNewsObject];
                                [resultDic setValue:currentThemeColumnArray forKey:themeColumnName];
                            }
                        }
                        else {
                            currentThemeColumnName = themeColumnName;
                        }
                    }
                    
                    //轮播图数据
                    NSMutableArray *tmpDataScroll = [[NSMutableArray alloc] init];
                    [[infoDic objectForKey:@"data_scroll"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        [tmpDataScroll addObject:listObject];
                    }];
                    
                    //专题分区的标题array
                    [infoArr addObject:sectionDataArray];
                    
                    //以专题分区标题为key的每个区里对应新闻数为value的字典
                    [infoArr addObject:resultDic];
                    
                    //轮播图数组
                    [infoArr addObject:tmpDataScroll];
                    
                    //专题介绍，封面，标题等信息的数组
                    [infoArr addObject:[infoDic objectForKey:@"data_main"]];
                }
                //现场的报道列表
                else if ([methodString isEqualToString:NewsReportList])
                {
                    //用于存放所有的直播流
                    NSMutableArray *liveStreamArray = [[NSMutableArray alloc] initWithCapacity:0];
                    //用于存放所有的报道
                    NSMutableArray *reportListArray = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    NSArray *tmpLiveStreamArray = [infoDic objectForKey:@"data_livereport"];
                    NSArray *tmpReportListArray = [infoDic objectForKey:@"data"];
                    NSDictionary *tmpMainInfoDic = [infoDic objectForKey:@"data_main"];
                    
                    //顶部头信息
                    NewsiLiveObject *liveObject = [[NewsiLiveObject alloc] init];
                    liveObject.n_commentNum = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"commentcount"]];
                    liveObject.n_commentstatus = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"commentstatus"]];
                    liveObject.n_id= [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"id"]];
                    liveObject.n_newstype = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"newstype"]];
                    liveObject.n_releasedate = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"releasedate"]];
                    liveObject.n_scenestate = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"scenestate"]];
                    liveObject.n_shareUrl = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"shareurl"]];
                    liveObject.n_content = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"summary"]];
                    liveObject.n_title = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"topic"]];
                    liveObject.n_smallimagehref = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"smallimagehref"]];
                    
                    //直播流
                    [tmpLiveStreamArray enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
                        NSError *error = nil;
                        LiveReportObject *listObject = [MTLJSONAdapter modelOfClass:LiveReportObject.class fromJSONDictionary:obj error:&error];
                        //加顶部信息
                        listObject.l_newsiliveObj = liveObject;
                        NSError *askError = nil;
                        if (listObject.l_allowask && [listObject.l_allowask boolValue]) {
                            
                            NSDictionary *askObjectDic = [obj objectForKey:@"askitem"];
                            listObject.l_askObject = [MTLJSONAdapter modelOfClass:MyAskObject.class fromJSONDictionary:askObjectDic error:&askError];
                            
                        }
                        
                        [liveStreamArray addObject:listObject];
                    }];
                    
                    //报道列表
                    [tmpReportListArray enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
                        NSError *error = nil;
                        LiveReportObject *listObject = [MTLJSONAdapter modelOfClass:LiveReportObject.class fromJSONDictionary:obj error:&error];
                        //加顶部信息
                        listObject.l_newsiliveObj = liveObject;
                        listObject.l_superLiveId = [NSString stringWithFormat:@"%@",[tmpMainInfoDic objectForKey:@"id"]];
                        //评论权限状态
                        listObject.l_reportCommentStatus = liveObject.n_commentstatus;
                        NSError *askError = nil;
                        if (listObject.l_allowask && [listObject.l_allowask boolValue]) {
                            
                            NSDictionary *askObjectDic = [obj objectForKey:@"askitem"];
                            listObject.l_askObject = [MTLJSONAdapter modelOfClass:MyAskObject.class fromJSONDictionary:askObjectDic error:&askError];
                        }
                        [reportListArray addObject:listObject];
                    }];
                    
                    [infoArr addObject:liveObject];
                    [infoArr addObject:liveStreamArray];
                    [infoArr addObject:reportListArray];
                    [infoArr addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:DATAMORESIGN]]];
                }
                //报道详情
                else if ([methodString isEqualToString:NewsReportDetail])
                {
                    //用于存放数据
                    NSMutableArray *askArray = [[NSMutableArray alloc] initWithCapacity:0];
                    NSMutableArray *commentsArray = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    //原始数据源
                    NSDictionary *tmpReportDetailDic = [infoDic objectForKey:@"data"];
                    NSArray *tmpAskArray = [infoDic objectForKey:@"data_ask"];
                    NSArray *tmpCommentsArray = [infoDic objectForKey:@"data_comment"];
                    
                    //报道详情
                    NSError *tmpReportDetailError = nil;
                    ReportDetailObject *reportDetail = [MTLJSONAdapter modelOfClass:ReportDetailObject.class fromJSONDictionary:tmpReportDetailDic error:&tmpReportDetailError];
                    
                    //问记者
                    [tmpAskArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                        
                        NSError *tmpAskError = nil;
                        MyAskObject *askObject = [MTLJSONAdapter modelOfClass:MyAskObject.class fromJSONDictionary:obj error:&tmpAskError];
                        [askArray addObject:askObject];
                        
                    }];
                    
                    //评论
                    [tmpCommentsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                        
                        NSError *tmpCommentError = nil;
                        CommentObject *commentObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:obj error:&tmpCommentError];
                        
                        commentObject.c_subCommentListArray = [[NSMutableArray alloc] initWithCapacity:0];
                        NSArray *tmpSubList = [obj objectForKey:@"floor"];
                        
                        [tmpSubList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                            NSError *subError = nil;
                            CommentObject *subListObject = [MTLJSONAdapter modelOfClass:CommentObject.class fromJSONDictionary:obj error:&subError];
                            subListObject.c_floorNum = tmpSubList.count - idx;
                            [commentObject.c_subCommentListArray addObject:subListObject];
                        }];
 
                        commentObject.c_isHasMore = commentObject.c_subCommentListArray && [commentObject.c_subCommentListArray count] > 9;
                        
                        [commentsArray addObject:commentObject];
                        
                    }];
                    
                    [infoArr addObject:reportDetail];
                    [infoArr addObject:askArray];
                    [infoArr addObject:commentsArray];
                    
                }
                //搜索热词
                else if ([methodString isEqualToString:SEARCHHOTWORDS_METHOD]) {
                    [infoArr addObject:tmpArr];
                }
                //记者中心
                else if ([methodString isEqualToString:ReporterCenter])
                {
                    NSMutableDictionary *tmpInfoDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        
                        [listArray addObject:listObject];
                    }];
                    
                    [tmpInfoDic setObject:listArray forKey:DATA];
                    [infoArr addObject:tmpInfoDic];
                }
                //【订阅】 编辑栏目页面列表数据
                else if ([methodString isEqualToString:OrderLatticelist])
                {
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [tmpArr enumerateObjectsUsingBlock:^(id parentObjDic, NSUInteger idx, BOOL *stop) {
                        //订阅父级栏目对象
                        OrderParentLatticeObject *parentObject = [[OrderParentLatticeObject alloc] init];
                        parentObject.o_id = [parentObjDic objectForKey:@"id"];
                        parentObject.o_name = [parentObjDic objectForKey:@"name"];
                        
                        //订阅子级栏目对象
                        NSMutableArray *subOrderObjcetListArray = [[NSMutableArray alloc] initWithCapacity:0];
                        [[parentObjDic objectForKey:@"items"] enumerateObjectsUsingBlock:^(id subObjectDic, NSUInteger idx, BOOL *stop) {
                            NSError *error = nil;
                            OrderSubLatticeObjec *subOrderObject = [MTLJSONAdapter modelOfClass:OrderSubLatticeObjec.class fromJSONDictionary:subObjectDic error:&error];
                            [subOrderObjcetListArray addObject:subOrderObject];
                        }];
                        
                        parentObject.o_subLatticeObjectArray = subOrderObjcetListArray;
                        [listArray addObject:parentObject];
                    }];
                    
                    [infoArr addObject:listArray];
                }
                //【订阅】 添加或者删除订阅
                else if ([methodString isEqualToString:USER_SAVELATTICE])
                {
                    [infoArr addObject:infoDic];
                }
                //【订阅】 用户已订阅的栏目LatticeNewsList
                else if ([methodString isEqualToString:MyOrderList])
                {
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        MyOrderObject *myOrderObject = [MTLJSONAdapter modelOfClass:MyOrderObject.class fromJSONDictionary:obj error:&error];
                        myOrderObject.cellString = @"MyOrderCell";
                        [listArray addObject:myOrderObject];
                    }];
                    [infoArr addObject:listArray];
                }
                //【订阅】 栏目对应的新闻列表
                else if ([methodString isEqualToString:LatticeNewsList])
                {
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *newsObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (newsObject && liveDataArray.count > 0) {
                            newsObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        [listArray addObject:newsObject];
                    }];
                    [tmpDic setObject:listArray forKey:DATA];
                    [infoArr addObject:tmpDic];
                }
                //提问我的版本号
                else if ([methodString isEqualToString:USER_OCSVERSION]) {
                    [infoArr addObject:tmpArr];
                }
                //我的提问列表
                else if ([methodString isEqualToString:MyAskList])
                {
                    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        MyAskObject *newsObject = [MTLJSONAdapter modelOfClass:MyAskObject.class fromJSONDictionary:obj error:&error];
                        [listArray addObject:newsObject];
                    }];
                    [tmpDic setObject:listArray forKey:DATA];
                    [infoArr addObject:tmpDic];
                }
                //报道详情页查看更多提问
                else if ([methodString isEqualToString:NewsReportDetailGetMoreAskList])
                {
                    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        MyAskObject *newsObject = [MTLJSONAdapter modelOfClass:MyAskObject.class fromJSONDictionary:obj error:&error];
                        [listArray addObject:newsObject];
                    }];
                    [tmpDic setObject:listArray forKey:DATA];
                    [infoArr addObject:tmpDic];
                }
                //我的报道
                else if ([methodString isEqualToString:MyBaoDaoList])
                {
                    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        LiveReportObject *reportObject = [MTLJSONAdapter modelOfClass:LiveReportObject.class fromJSONDictionary:obj error:&error];
                        reportObject.l_VCtype = @"1";
                        [listArray addObject:reportObject];
                    }];
                    [tmpDic setObject:listArray forKey:DATA];
                    [infoArr addObject:tmpDic];
 
                }
                //我的现场
                else if ([methodString isEqualToString:MyLiveList])
                {
                    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        MyLiveObject *liveObject = [MTLJSONAdapter modelOfClass:MyLiveObject.class fromJSONDictionary:obj error:&error];
                        [listArray addObject:liveObject];
                    }];
                    [tmpDic setObject:listArray forKey:DATA];
                    [infoArr addObject:tmpDic];
                }
                //创建报道
                else if ([methodString isEqualToString:NewsLiveAddReport])
                {
                    NSString *message = [infoDic objectForKey:@"message"];
                    NSString *data = [infoDic objectForKey:@"data"];
                    [infoArr addObject:data];
                    [infoArr addObject:message];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                else if ([methodString isEqualToString:UpdateBuildReportState])
                {
                    NSLog(@"---------------->%@",infoDic);
                }
                //报道视频状态返回
                else if ([methodString isEqualToString:NewsReportVideoStateInfo])
                {
                    NSDictionary *dataDic = [infoDic objectForKey:@"data"];
                    NSString *message = [NSString stringWithFormat:@"%@",[infoDic objectForKey:@"message"]];
                    
                    //报道详情
                    NSError *tmpReportDetailError = nil;
                    ReportDetailObject *reportDetail = [MTLJSONAdapter modelOfClass:ReportDetailObject.class fromJSONDictionary:dataDic error:&tmpReportDetailError];
                    
                    [infoArr addObject:message];
                    if (reportDetail)
                    {
                        [infoArr addObject:reportDetail];
                    }
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //直播流状态返回
                else if ([methodString isEqualToString:GetLivingVideoState])
                {
                    NSDictionary *dataDic = [infoDic objectForKey:@"data"];
                    NSString *message = [infoDic objectForKey:@"message"];
                    
                    LiveReportObject *report = [[LiveReportObject alloc] init];
                    report.l_mediaurl = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"mediaurl"]];
                    report.l_id = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"id"]];
                    
                    [infoArr addObject:report];
                    [infoArr addObject:message];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //联系编辑
                else if([methodString isEqualToString:MylianxiEdit])
                {
                    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithDictionary:infoDic];
                    NSMutableArray *listArray = [[NSMutableArray alloc] initWithCapacity:0];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        ContactEditObject *editObject = [MTLJSONAdapter modelOfClass:ContactEditObject.class fromJSONDictionary:obj error:&error];
                        [listArray addObject:editObject];
                    }];
                    [tmpDic setObject:listArray forKey:DATA];
                    [infoArr addObject:tmpDic];

                }
                else if([methodString isEqualToString:MylianxiEditAddMessage])
                {
                    [infoArr addObject:tmpArr];
                    [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
                }
                //搜索结果
                else if ([methodString isEqualToString:SEARCH_METHOD]) {
                    __block NSMutableArray *tmplist = [NSMutableArray array];
                    [tmpArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSError *error = nil;
                        NewsObject *listObject = [MTLJSONAdapter modelOfClass:NewsObject.class fromJSONDictionary:obj error:&error];
                        NSArray *liveDataArray = [obj objectForKey:@"data_report"];
                        if (liveDataArray && liveDataArray.count > 0) {
                            listObject.h_liveObject = [MTLJSONAdapter modelOfClass:NewsiLiveObject.class fromJSONDictionary:[liveDataArray firstObject] error:&error];
                        }
                        [tmplist addObject:listObject];
                    }];
                    [infoArr addObject:tmplist];
                    [infoArr addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:DATAMORESIGN]]];
                }
                else if ([methodString isEqualToString:USER_CANCELCOLUMNS]) {
                    [infoArr addObject:infoDic];
                }
                
            }
            else if ([methodString  isEqualToString:COMMIT_COMMENT_METHOD])
            {
                NSString *message = [infoDic objectForKey:@"message"];
                [infoArr addObject:message];
                [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
            }
            //创建现场-－提交现场
            else if ([methodString isEqualToString:BuildLive])
            {
                 NSString *message = [infoDic objectForKey:@"message"];
                [infoArr addObject:message];
                [infoArr insertObject:[NSString stringWithFormat:@"%@",SUCCESS] atIndex:0];
            }
            //举报评论
            else if ([methodString isEqualToString:COMMENT_REPORT_METHOD])
            {
                [infoArr addObject:infoDic];
            }
        }
        
        //数据返回失败以及其他原因
        else
        {
            NSString *message = [infoDic objectForKey:@"message"];
            NSString *data = [infoDic objectForKey:DATA];
            [infoArr insertObject:[NSString stringWithFormat:@"%@",message?:data] atIndex:0];
        }

    }
    else
    {
        if ([infoDic.allKeys count]>0 && [infoDic.allKeys containsObject:@""])
        {
            
        }
    }
    //判断返回的的数据
    
    return infoArr;
}

@end
