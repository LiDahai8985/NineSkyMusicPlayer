//
//  SongListCell.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/7.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "SongListCell.h"

@interface SongListCell ()

@property (strong, nonatomic) NSIndexPath *indexPtah;

@end


@implementation SongListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupContentWithSong:(id )song edit:(BOOL)edit indexPath:(NSIndexPath *)indexPath
{
    self.indexPtah = indexPath;
}

- (IBAction)menuBtnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(openSongMenu:)])
    {
        [self.delegate openSongMenu:self.indexPtah];
    }
}

- (IBAction)mvBtnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(openMvDetail:)])
    {
        [self.delegate openMvDetail:self.indexPtah];
    }
}

@end
