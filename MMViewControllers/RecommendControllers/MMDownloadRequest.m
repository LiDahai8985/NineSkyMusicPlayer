//
//  MMDownloadRequest.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/29.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MMDownloadRequest.h"

@interface MMDownloadRequest ()<NSURLSessionDelegate>

@property (strong, nonatomic) NSURL *downloadUrl;
@property (assign, nonatomic) NSInteger totalLength;
@property (strong, nonatomic) NSOutputStream *stream;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (copy, nonatomic) NSString *downloadIdentifier;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;

@end

@implementation MMDownloadRequest

- (instancetype)initWithDownloadUrl:(NSURL *)url
                 downloadIdentifier:(NSString *)downloadIdentifier
                      downloadQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        self.downloadUrl = url;
        self.downloadIdentifier = downloadIdentifier;
        self.downloadQueue = queue;
        //用于缓存
        if (![[NSFileManager defaultManager] fileExistsAtPath:MMMusicDownloadDirectoryPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:MMMusicDownloadDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:MMMusicTempDownloadDirectoryPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:MMMusicTempDownloadDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return self;
}

- (void)main
{
    if (!self.downloadUrl)
    {
        return;
    }
    
    // 判断该文件是否下载完成
    if ([[NSFileManager defaultManager] fileExistsAtPath:MMMusicDownloadFilePath(self.downloadIdentifier)]) {
        
        NSLog(@"----该资源已下载完成");
        return;
    }
    
    // 创建缓存目录文件
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.downloadQueue];
    
    // 创建流
    self.stream = [NSOutputStream outputStreamToFileAtPath:MMMusicTempDownloadDirectoryPath append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downloadUrl];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", MMDownloadLength(self.downloadIdentifier)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    self.task = [session dataTaskWithRequest:request];
    
    // 开始下载
    [self.task resume];
}

- (void)cancel
{
    [self.task suspend];
}


#pragma mark NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 打开流
    [self.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + MMDownloadLength(self.downloadIdentifier);
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入数据
    [self.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = MMDownloadLength(self.downloadIdentifier);
    NSUInteger expectedSize = self.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    NSLog(@"--下载进度---------------%0.2f-------------------",progress);
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:MMMusicTempDownloadFilePath(self.downloadIdentifier)]) {
        // 下载完成
        [[NSFileManager defaultManager] moveItemAtPath:MMMusicTempDownloadFilePath(self.downloadIdentifier) toPath:MMMusicDownloadFilePath(self.downloadIdentifier) error:nil];
        
    } else if (error){
        // 下载失败
        
    }
    
    // 关闭流
    [self.stream close];
    self.stream = nil;
}
@end
