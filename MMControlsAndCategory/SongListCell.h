//
//  SongListCell.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/7.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SongCellDelegate <NSObject>

- (void)openSongMenu:(NSIndexPath *)indexPath;
- (void)openMvDetail:(NSIndexPath *)indexPath;

@end


@interface SongListCell : UITableViewCell


@property (weak) id<SongCellDelegate> delegate;

@property (assign, nonatomic) BOOL isSongSelected;

- (void)setupContentWithSong:(id )song edit:(BOOL)edit indexPath:(NSIndexPath *)indexPath;


@end
