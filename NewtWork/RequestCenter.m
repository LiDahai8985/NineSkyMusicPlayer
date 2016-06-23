//
//  RequestCounter.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/6/20.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "RequestCenter.h"

@implementation RequestCenter

@end


@implementation DownloadRequest

- (NSString *)requestUrl {
    return @"http://baobab.wdjcdn.com/14562919706254.mp4";
}
- (NSString *)resumableDownloadPath {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"tmpFile"];
    return filePath;
}



@end