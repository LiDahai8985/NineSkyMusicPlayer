//
//  RIVMusicTableSectionView.m
//  Rivendell
//
//  Created by LiDaHai on 16/7/11.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "RIVMusicTableSectionView.h"


@interface RIVMusicTableSectionView ()

@property (weak, nonatomic) IBOutlet UIImageView *leftImgView;
@property (weak, nonatomic) IBOutlet UILabel     *leftTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton    *managerBtn;
@property (weak, nonatomic) IBOutlet UIButton    *downloadAllBtn;
@property (assign, nonatomic) BOOL isEditing;//是否在编辑状态
@property (assign, nonatomic) NSInteger  musicCount;//歌曲数量
@property (assign, nonatomic) RIVMusicTableSectionViewState lastState;//记录编辑前的状态

@end

@implementation RIVMusicTableSectionView

- (id)initWithState:(RIVMusicTableSectionViewState)state musicCount:(NSInteger)count downloadAllHidden:(BOOL)hidden
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"RIVMusicTableSectionView" owner:nil options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, ScreenWidth, 64);
        self.downloadAllBtn.hidden = hidden;
        self.musicCount = count;
        self.sectionState = state;
        self.lastState = state;
    }
    return self;
}


- (void)setSectionState:(RIVMusicTableSectionViewState)sectionState
{
    _sectionState = sectionState;
    
    switch (_sectionState) {
        case RIVMusicTableSectionViewStatePlayAll:
            self.leftImgView.image = Img(@"播放全部");
            self.leftTitleLabel.attributedText = [self getAttributedString];
            break;
        case RIVMusicTableSectionViewStateDownloadAll:
            self.leftImgView.image = Img(@"全部开始下载");
            self.leftTitleLabel.text = @"全部开始";
            break;
        case RIVMusicTableSectionViewStatePauseAll:
            self.leftImgView.image = Img(@"全部暂停");
            self.leftTitleLabel.text = @"全部暂停";
            break;
        case RIVMusicTableSectionViewStateSelectAll:
            self.leftImgView.image = Img(@"music_selected");
            self.leftTitleLabel.text = @"全选";
            break;
        case RIVMusicTableSectionViewStateSelectNone:
            self.leftImgView.image = Img(@"music_noSelect");
            self.leftTitleLabel.text = @"全部选";
            break;
            
        default:
            break;
    }
}

- (NSMutableAttributedString *)getAttributedString
{
    NSString *firstString = @"播放全部";
    NSString *secondString = [NSString stringWithFormat:@"（%ld）",(long)self.musicCount];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",firstString,secondString]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15*ScreenScale] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.0 alpha:1] range:NSMakeRange(0, firstString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10*ScreenScale] range:NSMakeRange(firstString.length, attributedString.length - firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.6 alpha:1] range:NSMakeRange(firstString.length, attributedString.length - firstString.length)];
    
    return attributedString;
}

//编辑状态
- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    [self.managerBtn setImage:isEditing?nil:Img(@"") forState:UIControlStateNormal];
    [self.managerBtn setTitle:isEditing?@"取消":@"" forState:UIControlStateNormal];
    self.sectionState = isEditing?RIVMusicTableSectionViewStateSelectNone:self.lastState;
}

//按钮点击事件处理
- (IBAction)btnClick:(id)sender
{
    //管理
    if (sender == self.managerBtn) {
        self.isEditing = !self.isEditing;
    }
    //下载全部
    else if (sender == self.downloadAllBtn)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadAllMusic:)]) {
            [self.delegate downloadAllMusic:YES];
        }
    }
    //左边事件处理
    else
    {
        //管理状态下
        if (self.isEditing) {
            //是否全选状态
            BOOL selectAll = self.sectionState ==RIVMusicTableSectionViewStateSelectAll?YES:NO;
            self.sectionState = selectAll?RIVMusicTableSectionViewStateSelectNone:RIVMusicTableSectionViewStateSelectAll;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectAllMusic:)]) {
                [self.delegate selectAllMusic:selectAll];
            }
        }
        //非管理状态下
        else
        {
            //播放全部
            if (self.sectionState == RIVMusicTableSectionViewStatePlayAll) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(playAllMusic)]) {
                    [self.delegate playAllMusic];
                }
            }
            else {
                //下载全部
                BOOL downloadAll = self.sectionState ==RIVMusicTableSectionViewStateDownloadAll?YES:NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(downloadAllMusic:)]) {
                    [self.delegate downloadAllMusic:downloadAll];
                    self.sectionState = downloadAll?RIVMusicTableSectionViewStatePauseAll:RIVMusicTableSectionViewStateDownloadAll;
                }
            }
        }
    }
}




@end
