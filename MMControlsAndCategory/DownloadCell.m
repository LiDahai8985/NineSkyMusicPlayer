//
//  DownloadCell.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/30.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "DownloadCell.h"
#import "MMDownLoadManager.h"


@interface DownloadCell ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lengthLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation DownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setcontentWithObject:(MMDownloadModel *)object
{
    self.nameLabel.text = @"";
    self.lengthLabel.text = @"";
    self.progressView.progress = 0;
    
    self.nameLabel.text = object.songName;
    if (object.downloadState == DownloadStateDownloading) {
        self.lengthLabel.text = [NSString stringWithFormat:@"%0.1fM/%0.1fM",object.downloadedLength*1.0/1024/1024,object.totalLength*1.0/1024/1024];
    }
    else if (object.downloadState == DownloadStateAwaitting)
    {
        self.lengthLabel.text = @"等待下载";
    }
    else if (object.downloadState == DownloadStateSuspended)
    {
        self.lengthLabel.text = @"已暂停";
    }
    else if (object.downloadState == DownloadStateFailed)
    {
        self.lengthLabel.text = @"下载失败，请重新下载";
    }
    self.progressView.progress = object.totalLength==0?0:1.0*object.downloadedLength/object.totalLength;
}

@end
