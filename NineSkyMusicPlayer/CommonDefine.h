//
//  CommonDefine.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/27.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//


#import "AppDelegate.h"


#define MMAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define iPhone4           ([[UIScreen mainScreen] bounds].size.height == 480)
#define iPhone5           ([[UIScreen mainScreen] bounds].size.height == 568)
#define iPhone6           ([[UIScreen mainScreen] bounds].size.height == 667)
#define iPhone6p          ([[UIScreen mainScreen] bounds].size.height == 736)

#define ScreenWidth       [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight      [[UIScreen mainScreen] bounds].size.height
#define ScreenScale       ScreenWidth/320.0

#define RGBColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define Img(name)         [UIImage imageNamed : name]

// 缓存主目录
#define MMCachesDirectory \
[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

// 缓存中文件目录
#define MMMusicTempCacheDirectoryPath \
[MMCachesDirectory stringByAppendingPathComponent:@"RIVMusicTempCache"]

// 缓存完成文件目录
#define MMMusicCacheDirectoryPath \
[MMCachesDirectory stringByAppendingPathComponent:@"RIVMusicCache"]

// 缓存完成文件路径
#define MMMusicCacheFilePath(fileName) \
[MMMusicCacheDirectoryPath stringByAppendingPathComponent:fileName]

//下载中文件暂存目录
#define MMMusicTempDownloadDirectoryPath \
[MMCachesDirectory stringByAppendingPathComponent:@"RIVMusicTempDownload"]

//下载中成文件存放路径
#define MMMusicTempDownloadFilePath(fileName) \
[MMMusicTempDownloadDirectoryPath stringByAppendingPathComponent:fileName]

//下载完成文件目录
#define MMMusicDownloadDirectoryPath \
[MMCachesDirectory stringByAppendingPathComponent:@"RIVMusicDownload"]

// 下载完成文件路径
#define MMMusicDownloadFilePath(fileName) \
[MMMusicDownloadDirectoryPath stringByAppendingPathComponent:fileName]

// 文件的已下载长度
#define MMDownloadLength(fileName) \
[[[NSFileManager defaultManager] attributesOfItemAtPath:MMMusicTempDownloadFilePath(fileName) error:nil][NSFileSize] integerValue]





// 所有下载完成的文件存放目录
#define HSDownloadFileDirectory \
[MMCachesDirectory stringByAppendingPathComponent:@"HSDownloadCache"]

// 下载完成后 单个文件的路径
#define HSDownloadFilePath(fileName) \
[HSDownloadFileDirectory stringByAppendingPathComponent:fileName]

// 所有 下载中 文件的存放目录
#define HSTempDownloadFileDirectory \
[MMCachesDirectory stringByAppendingPathComponent:@"HSTempDownloadCache"]

// 下载中 单个文件的存放路径
#define HSTempDownloadFilePath(fileName) \
[HSTempDownloadFileDirectory stringByAppendingPathComponent:fileName]

// 文件的已下载长度
#define HSDownloadedLength(fileName) [[[NSFileManager defaultManager] attributesOfItemAtPath:HSTempDownloadFilePath(fileName) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define HSTotalLengthFullpath [MMCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]