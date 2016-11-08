//
//  MusicPlayViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/22.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MusicPlayViewController.h"
#import "MvMainViewController.h"
#import "RIVPlayerView.h"

@interface MusicPlayViewController ()<RIVPlayerDelegate>
{
    NSInteger count;
}

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (strong, nonatomic) NSMutableArray *musicListArray;
@property (weak, nonatomic) IBOutlet UIProgressView *cacheProgressView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@end

@implementation MusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.musicListArray = [[NSMutableArray alloc] initWithObjects:
                           @"http://sp.9sky.com/convert/song/music/148/20160926184034941.mp3",
                           @"http://yinyueshiting.baidu.com/data2/music/124645382/440262194400128.mp3?xcode=6107a9895b5b03693d7cab37c0a62272",
                           @"http://yinyueshiting.baidu.com/data2/music/0a0e25790c3a5773257927b5a2e11426/260489222/260489119111600128.mp3?xcode=3791a86f4bebb014c7d4e558c0a93524",
                           @"http://yinyueshiting.baidu.com/data2/music/86bc4ece9550d99b19c947dbf231aecc/267447553/26744746739600128.mp3?xcode=ac00937ba9f9e74d86c86b4d2d72cc37",
                           nil];
    
    MMAppDelegate.playerView.delegate = self;
}

#pragma mark-
- (IBAction)playMusic:(id)sender {
    
    if ([self.playBtn.titleLabel.text isEqualToString:@"播放"]) {
        count = 0;
        NSURL *musicUrl = [NSURL URLWithString:[self.musicListArray objectAtIndex:0]];
        
        NSString *string = [NSString stringWithFormat:@"%@",[self.musicListArray objectAtIndex:0]];
        NSArray *array = [string componentsSeparatedByString:@"/"];
        NSString *identifierStr = [[NSString stringWithFormat:@"%@",[array lastObject]] substringToIndex:10];
        
        [MMAppDelegate.playerView setMediaURL:musicUrl cacheIdentifier:[NSString stringWithFormat:@"%@.mp3",identifierStr]];
    }
    else
    {
        [MMAppDelegate.playerView mmPlayerPause];
    }
    
    
    NSLog(@"开始播放");
}

- (IBAction)nextMusic:(id)sender {
    
    count ++;
    
    NSURL *musicUrl = [NSURL URLWithString:[self.musicListArray objectAtIndex:count%3]];
    
    NSString *string = [NSString stringWithFormat:@"%@",[self.musicListArray objectAtIndex:count%3]];
    NSArray *array = [string componentsSeparatedByString:@"/"];
    NSString *identifierStr = [[NSString stringWithFormat:@"%@",[array lastObject]] substringToIndex:10];
    
    [MMAppDelegate.playerView setMediaURL:musicUrl cacheIdentifier:[NSString stringWithFormat:@"%@.mp3",identifierStr]];
    
}

- (IBAction)previousMusic:(id)sender {
    
    if (count == 0) {
        count = self.musicListArray.count - 1;
    }
    else {
        count --;
    }
    
    NSURL *musicUrl = [NSURL URLWithString:[self.musicListArray objectAtIndex:count%3]];
    
    NSString *string = [NSString stringWithFormat:@"%@",[self.musicListArray objectAtIndex:count%3]];
    NSArray *array = [string componentsSeparatedByString:@"/"];
    NSString *identifierStr = [[NSString stringWithFormat:@"%@",[array lastObject]] substringToIndex:10];
    
    [MMAppDelegate.playerView setMediaURL:musicUrl cacheIdentifier:[NSString stringWithFormat:@"%@.mp3",identifierStr]];
}

- (IBAction)playVideo:(id)sender
{
    MvMainViewController *vc = [[MvMainViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)timeSliderTouchDown:(UISlider *)sender
{
    self.timeSlider.selected = YES;
}

- (IBAction)timeSliderTouchUp:(UISlider *)sender
{
    [MMAppDelegate.playerView seekToTime:sender.value];
    self.timeSlider.selected = NO;
}

- (IBAction)timeSliderValueChanged:(UISlider *)sender
{

}

#pragma mark-

- (void)player:(RIVPlayerView *)player playStateDidChange:(BOOL)playing
{
    [self.playBtn setTitle:playing?@"暂停":@"播放" forState:UIControlStateNormal];
}
- (void)player:(RIVPlayerView *)player playtimeDidCacheToValue:(CGFloat)value
{
    [self.cacheProgressView setProgress:value animated:YES];
}

- (void)player:(RIVPlayerView *)player playerDidFinishPlayWithError:(NSError *)error
{
    [self nextMusic:nil];
}

- (void)player:(RIVPlayerView *)player playerDidChangePlayTime:(NSInteger)cuttentTime totalTime:(NSInteger)totalTime
{
    CGFloat floatTime = cuttentTime;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",cuttentTime/60,cuttentTime%60];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",totalTime/60,totalTime%60];
    if (!self.timeSlider.selected) {
        self.timeSlider.value = floatTime/totalTime;
    }
}

#pragma mark-
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
