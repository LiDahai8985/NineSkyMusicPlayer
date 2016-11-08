//
//  MMDownLoadManager.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/29.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//


#import "MMDownLoadManager.h"


@interface MMDownLoadManager ()<NSURLSessionDelegate>

// 保存所有任务(注：用下载地址,以文件名作为key)
@property (nonatomic, strong) NSMutableDictionary *tasks;

// 保存所有下载相关信息
@property (nonatomic, strong) NSMutableDictionary *sessionModels;

// 当前下载队列中的任务
@property (strong, nonatomic) NSMutableArray   *downloadingQueueRequestArray;

@end




@implementation MMDownLoadManager

+ (instancetype)shareManager
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

// 所有下载任务
- (NSMutableArray *)allDownloadArray
{
    if (!_allDownloadArray) {
        _allDownloadArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _allDownloadArray;
}

// 当前下载队列中的任务
- (NSMutableArray *)downloadingQueueRequestArray
{
    if (!_downloadingQueueRequestArray) {
        _downloadingQueueRequestArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _downloadingQueueRequestArray;
}


// 已创建的任务
- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

// 任务对应的model
- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}

//  创建缓存目录文件
- (void)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:HSTempDownloadFileDirectory]) {
        [fileManager createDirectoryAtPath:HSTempDownloadFileDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if (![fileManager fileExistsAtPath:HSDownloadFileDirectory]) {
        [fileManager createDirectoryAtPath:HSDownloadFileDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

#pragma mark- 内部方法
// 执行下载
- (void)startDownloadTask:(MMDownloadModel *)model
{
    // 下载任务已配置，直接处理
    if ([[self.tasks allKeys] containsObject:model.taskId]) {
        NSURLSessionDataTask *task = [self getTask:model.taskId];
        if (task.state == NSURLSessionTaskStateRunning) {
            [self pause:model.taskId downloadNext:YES];
        } else {
            [self resume:model.taskId];
        }
        return;
    }
    
    // 创建缓存目录文件
    [self createCacheDirectory];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:HSTempDownloadFilePath(model.taskId) append:YES];
    
    NSLog(@"-----下载地址%@-----",HSTempDownloadFilePath(model.taskId));
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:model.downloadUrl]];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", HSDownloadedLength(model.taskId)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    double taskId = [NSDate date].timeIntervalSince1970;
    [task setValue:@(taskId) forKeyPath:@"taskIdentifier"];
    
    // 保存任务
    [self.tasks setValue:task forKey:model.taskId];
    
    model.stream = stream;
    [self.sessionModels setValue:model forKey:@(task.taskIdentifier).stringValue];
    
    [self resume:model.taskId];
}

// 开始下载
- (void)resume:(NSString *)downloadIdentifier
{
    NSURLSessionDataTask *task = [self getTask:downloadIdentifier];
    [task resume];
    
    MMDownloadModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    sessionModel.downloadedLength = HSDownloadedLength(sessionModel.taskId);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
    {
        [self.delegate downloadDidReceiveData];
    }
}

//  暂停下载当前下载，开始下一个任务下载
- (void)pause:(NSString *)downloadIdentifier downloadNext:(BOOL)next
{
    NSURLSessionDataTask *task = [self getTask:downloadIdentifier];
    [task suspend];
    
    MMDownloadModel *model = [self getSessionModel:task.taskIdentifier];
    model.downloadedLength = HSDownloadedLength(model.taskId);
    
    // 关闭流
    [model.stream close];
    model.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:model.taskId];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    // 执行下一个下载
    if (next) {
        [self startNextDownloadTask];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
    {
        [self.delegate downloadDidReceiveData];
    }
}

// 开始下载下一个等待中的任务
- (void)startNextDownloadTask
{
    if (self.downloadingQueueRequestArray && [self.downloadingQueueRequestArray count] > 0) {
        MMDownloadModel *model = [self.downloadingQueueRequestArray objectAtIndex:0];
        model.downloadState = DownloadStateDownloading;
        [self startDownloadTask:model];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
    {
        [self.delegate downloadDidReceiveData];
    }
}

//  根据下载标示获得对应的下载任务
- (NSURLSessionDataTask *)getTask:(NSString *)downloadIdentifier
{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:downloadIdentifier];
}

//  根据下载标示获取对应的下载信息模型
- (MMDownloadModel *)getSessionModel:(NSUInteger)taskIdentifier
{
    return (MMDownloadModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

//  判断该文件是否下载完成
- (BOOL)isCompletion:(NSString *)downloadIdentifier
{
    if ([self fileTotalLength:downloadIdentifier] && HSDownloadedLength(downloadIdentifier) == [self fileTotalLength:downloadIdentifier]) {
        return YES;
    }
    return NO;
}


//  获取某一资源总大小
- (NSInteger)fileTotalLength:(NSString *)downloadIdentifier
{
    return [[NSDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath][downloadIdentifier] integerValue];
}



#pragma mark- 外部开放方法
// 添加下载任务资源
- (void)addToDownloadQueueWithDownloadModels:(NSArray<MMDownloadModel *> *)array
{
    //下载地址为空
    if (!array)
    {
        NSLog(@"----下载内容不能为空----");
        return;
    }
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    
    // 先判断已下载完成的列表中是否包含新添加的任务
    for (NSInteger i = mutableArray.count - 1; i >= 0; i --)
    {
        MMDownloadModel *model = mutableArray[i];
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"taskId", model.taskId];
        NSArray *resultArray = [self.downloadFinishedArray filteredArrayUsingPredicate:predicateID];
        
        //移除已下载完成的任务
        if (resultArray && [resultArray count] > 0)
        {
            [mutableArray removeObjectAtIndex:i];
        }
    };
    
    // 再判断总任务列表中是否已经存在下载任务，没有则添加
    [mutableArray enumerateObjectsUsingBlock:^(MMDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"taskId", obj.taskId];
        NSArray *resultArray = [self.allDownloadArray filteredArrayUsingPredicate:predicateID];
        
        if (!resultArray || [resultArray count] == 0) {
            
            obj.totalLength = 0;
            obj.downloadedLength = 0;
            [self.allDownloadArray addObject:obj];
        }
    }];
    
    // 添加到当前下载任务队列
    [mutableArray enumerateObjectsUsingBlock:^(MMDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"taskId", obj.taskId];
        NSArray *resultArray = [self.downloadingQueueRequestArray filteredArrayUsingPredicate:predicateID];
        
        // 下载队列中没有，则添加到下载队列
        if (!resultArray || [resultArray count] == 0){
            
            // 保证下载任务为同一对象
            NSArray *allResultArray = [self.allDownloadArray filteredArrayUsingPredicate:predicateID];
            MMDownloadModel *model = [allResultArray objectAtIndex:0];
            
            //当前下载队列中没有正在下载的对象，则添加
            model.downloadState = self.downloadingQueueRequestArray.count==0?DownloadStateDownloading:DownloadStateAwaitting;
            [self.downloadingQueueRequestArray addObject:model];
        }
    }];
    
    // 排序所有下载任务的顺序为--正在下载--等待下载--暂停&失败
    [self.downloadingQueueRequestArray enumerateObjectsUsingBlock:^(MMDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"taskId", obj.taskId];
        NSArray *resultArray = [self.allDownloadArray filteredArrayUsingPredicate:predicateID];
        if (resultArray && [resultArray count] > 0) {
            [self.allDownloadArray removeObjectsInArray:resultArray];
            [self.allDownloadArray insertObject:resultArray[0] atIndex:idx];
        }
    }];

    // 执行下载
    if (self.downloadingQueueRequestArray.count > 0) {
        MMDownloadModel *model = self.downloadingQueueRequestArray[0];
        
        // 直接下载
        if ([[self.tasks allKeys] containsObject:model.taskId]) {
            NSURLSessionDataTask *task = [self getTask:model.taskId];
            if (task.state != NSURLSessionTaskStateRunning)
            [self resume:model.taskId];
        }
        else
        {
            // 建立下载任务，下载
            [self startDownloadTask:model];
        }
    }
}

// 外部开放方法，对已有下载任务进行处理
- (void)downloadTaskWithDownloadModel:(MMDownloadModel *)model
{
    // 当前任务列表中是否存在要处理的下载任务
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"taskId", model.taskId];
    NSArray *resultArray = [self.allDownloadArray filteredArrayUsingPredicate:predicateID];
    
    // 如果下载任务存在
    if (resultArray && [resultArray count] > 0)
    {
        //如果是正在下载或者正在排队的任务，则暂停，否则添加到下载队列排队或者直接下载
        NSArray *queueResultArray = [self.downloadingQueueRequestArray filteredArrayUsingPredicate:predicateID];
        if (queueResultArray && [queueResultArray count] > 0) {
            model.downloadState = DownloadStateSuspended;
            [self.downloadingQueueRequestArray removeObjectsInArray:queueResultArray];
            [self pause:model.taskId downloadNext:YES];
        }
        else
        {
            if (self.downloadingQueueRequestArray.count == 0) {
                //当前下载队列中没有正在下载的对象，则开始下载
                model.downloadState = DownloadStateDownloading;
                [self startDownloadTask:model];
            }
            else
            {
                model.downloadState = DownloadStateAwaitting;
            }
            
            [self.downloadingQueueRequestArray addObject:model];
        }
    }
}

// 暂停全部下载
- (void)downloadPauseAllTasks
{
    if ([self.downloadingQueueRequestArray count] > 0)
    {
        // 暂停当前下载
        MMDownloadModel *model = self.downloadingQueueRequestArray[0];
        [self pause:model.taskId downloadNext:NO];
        
        // 移除下载队列
        for (NSInteger i = self.downloadingQueueRequestArray.count - 1; i >= 0 ; i --) {
            MMDownloadModel *model = self.downloadingQueueRequestArray[i];
            model.downloadState = DownloadStateSuspended;
            [self.downloadingQueueRequestArray removeObjectAtIndex:i];
        }
        
        // 通知刷新页面
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
        {
            [self.delegate downloadDidReceiveData];
        }
    }
}

//  删除该资源
- (void)deleteDownloadTask:(NSArray <MMDownloadModel *> *)array
{
    if (array && [array count] > 0) {
        for (MMDownloadModel *model in array) {
            
            // 先暂停下载任务
            [self pause:model.taskId downloadNext:NO];
            
            // 从队列中删除
            [self.downloadingQueueRequestArray removeObject:model];
            
            // 任务中删除
            [self.allDownloadArray removeObject:model];
            
            
            // 删除文件
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:HSTempDownloadFilePath(model.taskId)]) {
                
                // 任务状态清零
                [self.sessionModels removeObjectForKey:@([self getTask:model.taskId].taskIdentifier).stringValue];
                
                // 删除资源总长度
                if ([fileManager fileExistsAtPath:HSTotalLengthFullpath]) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
                    [dict removeObjectForKey:model.taskId];
                    [dict writeToFile:HSTotalLengthFullpath atomically:YES];
                }
                
                // 删除任务
                [self.tasks removeObjectForKey:model.taskId];
                
                // 删除沙盒中的资源
                [fileManager removeItemAtPath:HSTempDownloadFilePath(model.taskId) error:nil];
            }
        }
    }
    
}

//  清空所有下载中资源
- (void)deleteAllTasks
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HSTempDownloadFileDirectory]) {
        
        // 删除任务
        [[self.tasks allValues] makeObjectsPerformSelector:@selector(cancel)];
        [self.tasks removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HSTotalLengthFullpath]) {
            [fileManager removeItemAtPath:HSTotalLengthFullpath error:nil];
        }
        
        // 关闭正在下载的任务
        for (MMDownloadModel *sessionModel in [self.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:HSTempDownloadFileDirectory error:nil];
    }
}


#pragma mark - 代理
#pragma mark NSURLSessionDataDelegate
// 接收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    MMDownloadModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    NSLog(@"---------开始当前下载任务id：%@---------",sessionModel.taskId);
    // 打开流
    [sessionModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + HSDownloadedLength(sessionModel.taskId);
    sessionModel.totalLength = totalLength;
    sessionModel.downloadedLength = HSDownloadedLength(sessionModel.taskId);
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[sessionModel.taskId] = @(totalLength);
    [dict writeToFile:HSTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
    {
        [self.delegate downloadDidReceiveData];
    }
}

// 接收到服务器返回的数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    MMDownloadModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    NSLog(@"---------当前下载任务id：%@---------",sessionModel.taskId);
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    sessionModel.downloadedLength = HSDownloadedLength(sessionModel.taskId);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
    {
        [self.delegate downloadDidReceiveData];
    }
}

// 请求完毕（成功|失败）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    MMDownloadModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    
    if (!sessionModel) return;
    
    // 关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    // 下载完成
    if ([self isCompletion:sessionModel.taskId]) {
        sessionModel.downloadedLength = HSDownloadedLength(sessionModel.taskId);
        sessionModel.downloadState = DownloadStateCompleted;
        [self.downloadingQueueRequestArray removeObject:sessionModel];
        [self.allDownloadArray removeObject:sessionModel];
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
        {
            [self.delegate downloadDidReceiveData];
        }
        
        NSLog(@"---------完成当前下载任务id：%@---------",sessionModel.taskId);
        
        // 成功后，移动文件到保存下载完成的文件的存放路径
        [[NSFileManager defaultManager] moveItemAtPath:HSTempDownloadFilePath(sessionModel.taskId) toPath:HSDownloadFilePath(sessionModel.taskId) error:nil];
        
    } else if (error){
        // 下载失败
        NSLog(@"---------失败当前下载任务id：%@---------",sessionModel.taskId);
        sessionModel.downloadState = DownloadStateFailed;
        [self.downloadingQueueRequestArray removeObject:sessionModel];
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidReceiveData)])
        {
            [self.delegate downloadDidReceiveData];
        }
    }
    
    // 清除任务
    [self.tasks removeObjectForKey:sessionModel.taskId];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    // 下载下一个
    [self startNextDownloadTask];
}



@end




@implementation MMDownloadModel : NSObject

@end
