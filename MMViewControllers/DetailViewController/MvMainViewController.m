//
//  MvMainViewController.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/20.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MvMainViewController.h"
#import "RIVPlayerView.h"

@interface MvMainViewController ()
{
    NSInteger count;
}

@property (strong, nonatomic) RIVPlayerView *playerView;
@property (strong, nonatomic) NSMutableArray *musicListArray;

@end

@implementation MvMainViewController

- (void)dealloc
{
    [self.playerView clear];
    self.playerView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(deviceOrientationDidChangeNotification)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
    
    
    self.musicListArray = [[NSMutableArray alloc] initWithObjects:
                           @"http://7xtz76.com1.z0.glb.clouddn.com/unnamed.mp4?e=1469013383&token=psLGL0Fam_zrJcI2NeBZCu42lt4qGr6jPmCMilLC:X8d7ljTi6mytK1HGPfp3APyZ5sA=",
                           @"http://yinyueshiting.baidu.com/data2/music/124645382/440262194400128.mp3?xcode=6107a9895b5b03693d7cab37c0a62272",
                           @"http://yinyueshiting.baidu.com/data2/music/0a0e25790c3a5773257927b5a2e11426/260489222/260489119111600128.mp3?xcode=3791a86f4bebb014c7d4e558c0a93524",
                           @"http://yinyueshiting.baidu.com/data2/music/86bc4ece9550d99b19c947dbf231aecc/267447553/26744746739600128.mp3?xcode=ac00937ba9f9e74d86c86b4d2d72cc37",
                           nil];
}

- (RIVPlayerView *)playerView
{
    if (!_playerView) {
        _playerView = [RIVPlayerView player];
        _playerView.allowPlayBackground = YES;
        _playerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth*9/16);
    }
    return _playerView;
}

#pragma mark- 
- (IBAction)playMusic:(id)sender {
    
    if (!self.playerView.superview) {
        [self.view addSubview:self.playerView];
    }
    
    [MMAppDelegate.playerView mmPlayerPause];
    
    count = 0;
    NSURL *musicUrl = [NSURL URLWithString:[self.musicListArray objectAtIndex:0]];
    
    NSString *string = [NSString stringWithFormat:@"%@",[self.musicListArray objectAtIndex:0]];
    NSArray *array = [string componentsSeparatedByString:@"/"];
    NSString *identifierStr = [[NSString stringWithFormat:@"%@",[array lastObject]] substringToIndex:10];
    
    [self.playerView setMediaURL:musicUrl cacheIdentifier:[NSString stringWithFormat:@"%@.mp3",identifierStr]];
    
    NSLog(@"开始播放");
}

- (IBAction)nextMusic:(id)sender {
    
    if (!self.playerView.superview) {
        [self.view addSubview:self.playerView];
    }
    
    count ++;
    
    NSURL *musicUrl = [NSURL URLWithString:[self.musicListArray objectAtIndex:count%3]];
    
    NSString *string = [NSString stringWithFormat:@"%@",[self.musicListArray objectAtIndex:count%3]];
    NSArray *array = [string componentsSeparatedByString:@"/"];
    NSString *identifierStr = [[NSString stringWithFormat:@"%@",[array lastObject]] substringToIndex:10];
    
    [self.playerView setMediaURL:musicUrl cacheIdentifier:[NSString stringWithFormat:@"%@.mp3",identifierStr]];
    
}

- (IBAction)previousMusic:(id)sender {
    
    if (!self.playerView.superview) {
        [self.view addSubview:self.playerView];
    }
    
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
    
    [self.playerView setMediaURL:musicUrl cacheIdentifier:[NSString stringWithFormat:@"%@.mp3",identifierStr]];
}

- (IBAction)playVideo:(id)sender
{
    if (!self.playerView.superview) {
        [self.view addSubview:self.playerView];
        
        self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.playerView.heightConstraint = [NSLayoutConstraint constraintWithItem:self.playerView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute multiplier:1
                                                               constant:ScreenWidth*9/16];
        
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0]];
        [self.view addConstraint:self.playerView.heightConstraint];
    }
    
    [MMAppDelegate.playerView mmPlayerPause];
    
    NSURL *url = [NSURL URLWithString:@"http://7xtz76.com1.z0.glb.clouddn.com/song/mv/25/20160813125842526.mp4"];
    [self.playerView setMediaURL:url cacheIdentifier:nil];
}
#pragma mark-



- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
