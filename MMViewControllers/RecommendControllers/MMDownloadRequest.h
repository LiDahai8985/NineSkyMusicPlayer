//
//  MMDownloadRequest.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/29.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMDownloadRequest : NSOperation

- (instancetype)initWithDownloadUrl:(NSURL *)url downloadIdentifier:(NSString *)downloadIdentifier;

@end
