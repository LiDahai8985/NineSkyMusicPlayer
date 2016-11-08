//
//  RIVResourceLoaderURLConnection.m
//  Player
//
//  Created by LiDaHai on 16/6/17.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "RIVResourceLoaderURLConnection.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface RIVResourceLoaderURLConnection ()

@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, copy)   NSString       *cachePath;
@property (nonatomic, copy)   NSString       *tempCachePath;
@property (nonatomic, copy)   NSString       *cacheIdentifier;
@property (nonatomic, strong) RIVMediaRequestTask *task;

@end

@implementation RIVResourceLoaderURLConnection

- (void)dealloc
{
    [self.task clearData];
    NSLog(@"-------- %@释放了 ----------",NSStringFromClass([self class]));
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _pendingRequests = [NSMutableArray array];
        _cachePath = MMMusicCacheFilePath(identifier);
        _tempCachePath = [MMMusicTempCacheDirectoryPath stringByAppendingPathComponent:identifier];
        self.cacheIdentifier = identifier;
    }
    return self;
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest
{
    NSString *mimeType = self.task.mimeType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = self.task.mediaLength;
}

#pragma mark - AVURLAsset resource loader methods

//对存放所有的请求的数组进行处理
- (void)processPendingRequests
{
    //请求完成的数组
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests)
    {
        //对每次请求加上长度，文件类型等信息
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        
        //判断此次请求的数据是否处理完全
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        
        //如果完整，把此次请求放进 请求完成的数组
        if (didRespondCompletely) {
            [requestsCompleted addObject:loadingRequest];
            [loadingRequest finishLoading];
        }
    }
    
    //在所有请求的数组中移除已经完成的
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

/**  注  意
  *
  *  对请求地址进行自定义scheme，非自定义的URL Scheme不会触发AVAssetResourceLoader的delegate方法
  *
  *  注  意
 **/
- (NSURL *)getSchemeVideoURL:(NSURL *)url
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}


/**
 *  是否需要请求数据
 */
- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest
{
    long long startOffset = dataRequest.requestedOffset;
    
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    /**意思是当前这个url请求的起始位置+已经下载的长度 < 新请求的起始位置。
     比如当前是从10分钟的位置开始下载，下载了5分钟，到了15分钟的位置，然后
     这时拖动滑竿，如果滑竿停止的位置在15分钟的前面，那么不需要建立新的请求
     */
    if ((self.task.offset + self.task.downLoadingOffset) < startOffset)
    {
        //NSLog(@"NO DATA FOR REQUEST");
        return NO;
    }
    
    //小于已缓存的数据时，不发送请求
    if (startOffset < self.task.offset) {
        return NO;
    }
    
    NSData *filedata;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        // 已缓存完成，在最终缓存路径获取文件
        filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.cachePath] options:NSDataReadingMappedIfSafe error:nil];
    }
    else
    {
        // 为缓存完成，在缓存暂存路径获取文件
        filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.tempCachePath] options:NSDataReadingMappedIfSafe error:nil];
    }
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = self.task.downLoadingOffset - ((NSInteger)startOffset - self.task.offset);
    
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
    //给播放器发出的请求进行填充数据
    [dataRequest respondWithData:[filedata subdataWithRange:NSMakeRange((NSUInteger)startOffset- self.task.offset, (NSUInteger)numberOfBytesToRespondWith)]];
    
    
    long long endOffset = startOffset + dataRequest.requestedLength;
    BOOL didRespondFully = (self.task.offset + self.task.downLoadingOffset) >= endOffset;
    
    return didRespondFully;
}


#pragma mark- AVAssetResourceLoaderDelegate
/**
 *  播放器发出的数据请求从这里开始，我们保存从这里发出的所有请求存放到数组，自己来处理这些请求，
 *  当一个请求完成后，对请求发出finishLoading消息并从数组中移除
 *  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
 *  这里会出现很多个loadingRequest请求， 需要为每一次请求作出处理
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 播放器每一小块数据的请求
 *
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.pendingRequests addObject:loadingRequest];
    [self dealWithLoadingRequest:loadingRequest];
    //NSLog(@"----%@", loadingRequest);
    return YES;
}


/**
 这个方法发出的请求说明播放器自己关闭了这个请求，我们不需要再对这个请求进行处理，
 系统每次结束一个旧的请求，便必然会发出一个或多个新的请求，除了播放器已经获得整
 个视频完整的数据，这时候就不会再发起请求。
 **/
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.pendingRequests removeObject:loadingRequest];
    
}

- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, NSUIntegerMax);
    
    if (self.task.downLoadingOffset > 0) {
        [self processPendingRequests];
    }
    
    if (!self.task) {
        self.task = [[RIVMediaRequestTask alloc] initWithIdentifier:self.cacheIdentifier];
        self.task.m_delegate = self;
        [self.task setUrl:interceptedURL offset:0];
    } else {
        // 如果新的rang的起始位置比当前缓存的位置还大300k，则重新按照range请求数据
        if (self.task.offset + self.task.downLoadingOffset + 1024 * 300 < range.location ||
            // 如果往回拖也重新请求
            range.location < self.task.offset) {
            [self.task setUrl:interceptedURL offset:range.location];
        }
    }
}

#pragma mark - RIVMediaRequestTaskDelegate

- (void)task:(RIVMediaRequestTask *)task didReceiveMediaLength:(NSUInteger)mediaLength mimeType:(NSString *)mimeType
{
    
}

- (void)taskDidReceiveMediaData:(RIVMediaRequestTask *)task
{
    [self processPendingRequests];
    
}

- (void)taskDidFinishLoading:(RIVMediaRequestTask *)task
{
    if ([self.m_delegate respondsToSelector:@selector(loaderDidFinishLoadingWithTask:)]) {
        [self.m_delegate loaderDidFinishLoadingWithTask:task];
    }
}

- (void)taskDidFailLoading:(RIVMediaRequestTask *)task WithError:(NSInteger)errorCode
{
    if ([self.m_delegate respondsToSelector:@selector(loaderDidFailLoadingWithTask:WithError:)]) {
        [self.m_delegate loaderDidFailLoadingWithTask:task WithError:errorCode];
    }
    
}

@end

