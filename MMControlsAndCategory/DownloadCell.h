//
//  DownloadCell.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/30.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MMDownloadModel;
@interface DownloadCell : UITableViewCell

- (void)setcontentWithObject:(MMDownloadModel *)object;

@end
