//
//  MMPlayerView.h
//  Player
//
//  Created by LDhai on 16/3/3.
//  Copyright © 2016年 LDhai. All rights reserved.
//

#import "MMPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanGestureDirection){
    PanGestureDirectionHorizontalMoved,
    PanGestureDirectionVerticalMoved
};

@interface MMPlayerView ()
{
    BOOL _isAllowDisappearMaskView;/** 是否允许隐藏maskView **/
    BOOL _isVolume;/** 是否在调节音量 **/
    BOOL _isMaskShowing;/** 是否显示maskView **/
}

/** 快进快退label */
@property (weak, nonatomic) IBOutlet UILabel *horizontalLabel;

/** 系统菊花 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

/** 返回按钮*/
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

/** 蒙版View */
@property (weak, nonatomic) IBOutlet UIView *topMaskView;

/** 蒙版View */
@property (weak, nonatomic) IBOutlet UIView *bottomMaskView;

/** 开始播放按钮 */
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

/** 当前播放时长label */
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

/** 视频总时长label */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/** 缓冲进度条 */
@property (weak, nonatomic) IBOutlet UIProgressView *cacheProgressView;

/** 播放进度滑杆 */
@property (weak, nonatomic) IBOutlet UISlider *videoTimeSlider;

/** 全屏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;

/** 播放属性 */
@property (strong, nonatomic) AVPlayer *player;

/** playerLayer */
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

/** 滑杆 */
@property (strong, nonatomic) UISlider *volumeViewSlider;

/** 计时器 */
@property (strong, nonatomic) NSTimer *timer;

/**  用来保存快进的总时长 */
@property (assign, nonatomic) CGFloat sumTime;

/** 是否为全屏 **/
@property (assign, nonatomic) BOOL isFullScreen;

/** 定义一个实例变量，保存枚举值 */
@property (assign, nonatomic) PanGestureDirection panDirection;



@end

@implementation MMPlayerView

/** 类方法创建，用于代码创建View */
+ (instancetype)sharePlayer
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
}

-(void)awakeFromNib
{
    //背景色为黑色
    self.backgroundColor = [UIColor blackColor];
    
    // 设置快进快退label，默认隐藏
    self.horizontalLabel.hidden = YES;
    
    //默认允许隐藏
    _isAllowDisappearMaskView = YES;
    
    self.videoTimeSlider.minimumTrackTintColor = [UIColor whiteColor];
    self.videoTimeSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.6];
    
    self.cacheProgressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.cacheProgressView.trackTintColor = [UIColor clearColor];
    
    //应用进入前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(msg_didBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    //应用进入后台通知(方式一)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(msg_didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    //应用进入后台通知(方式二)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(msg_didEnterBackgroundNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    //屏幕方向发生变化通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:pan];
}


//播放窗口自适应
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

//是否正在播放
- (BOOL)isPlaying {
    return self.player && self.player.rate == 1.0;
}


//是否全屏
- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    
    //屏幕高度和全屏按钮
    self.heightConstraint.constant = _isFullScreen?[[UIApplication sharedApplication] keyWindow].bounds.size.height:[[UIApplication sharedApplication] keyWindow].bounds.size.width*9/16;
    [self.fullScreenBtn setImage:_isFullScreen?[UIImage imageNamed:@"kr-video-player-shrinkscreen"]:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
    
    //防止屏幕方向未锁定的情况下，在播放器全屏播放且操作栏和StatusBar隐藏时，应用进入后台导致状态栏消失
    //或者在小屏时让状态栏隐藏，此时pop当前页面导致StatusBar不显示
    if (!_isFullScreen) {
        UIView *statusBarView = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        statusBarView.alpha = 1.0f;;
    }
}

//设置播放地址
- (void)setMediaURL:(NSURL *)mediaURL
{
    //结束之前正在播放的对象
    [self endPreviousPlay];
    
    // 创建AVPlayer
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:mediaURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];

    //画面的自适应模式
    //self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    //播放窗口放在操作面板下面
    [self.layer insertSublayer:self.playerLayer below:self.topMaskView.layer];
    [self mmPlayerPlay];
    
    if (self.player.rate == 1.0) {
        [self.startBtn setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
    } else {
        [self.startBtn setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
    }
    
    // 监听播放器播放状态属性
    [self.player.currentItem addObserver:self
                              forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"loadedTimeRanges"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"playbackBufferEmpty"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"playbackLikelyToKeepUp"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_player.currentItem];
    
    //获取系统音量
    [self configureVolume];
    
    [self.activity startAnimating];

    [UIApplication sharedApplication].statusBarHidden = NO;
    
    _isMaskShowing = YES;
    //延迟线程
    [self afterHideMaskView];
    
    if (!self.timer)
    {
        //计时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:self
                                                    selector:@selector(updateTimeLabel)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
}

//先结束释放之前的播放
- (void)endPreviousPlay {
    if (!self.player) {
        return;
    }
    
    //暂停现有播放
    [self.player pause];
    
    AVPlayerItem *currentPlayerItem = self.player.currentItem;
    
    //移除播放完成的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:currentPlayerItem];
    
    //移除当前播放对象的一些播放状态通知
    [currentPlayerItem removeObserver:self forKeyPath:@"status"];
    [currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [currentPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    //替换当前播放对象为空
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

//获取系统音量
- (void)configureVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    //使用这个category的应用不会随着手机静音键打开而静音，可在在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
}

#pragma mark - ShowOrHideMaskView

//延时隐藏工具栏
- (void)afterHideMaskView
{
    if (!_isMaskShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMaskView) object:nil];
    [self performSelector:@selector(hideMaskView) withObject:nil afterDelay:7.0f];

}

//取消延时
- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

//隐藏工具栏
- (void)hideMaskView
{
    if (!_isMaskShowing || !_isAllowDisappearMaskView) {
        return;
    }
    
    UIView *statusBarView = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.topMaskView.alpha = 0.0f;
        self.bottomMaskView.alpha = 0.0f;
        //全屏状态下隐藏状态栏
        statusBarView.alpha = self.isFullScreen?0.0f:1.0f;
    }completion:^(BOOL finished) {
        _isMaskShowing = NO;
    }];
}

//显示工具栏
- (void)animateShow
{
    if (_isMaskShowing) {
        return;
    }
    UIView *statusBarView = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomMaskView.alpha = 1.0f;
        self.topMaskView.alpha = 1.0f;
        statusBarView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        _isMaskShowing = YES;
        [self afterHideMaskView];
    }];
}


//设置快进退和音量label的隐藏显示
- (void)setHorizontalLabelHidden:(id)object {
    self.horizontalLabel.hidden = YES;
}

//设置maskView允许隐藏
- (void)setAllowMaskViewDisappear {
    _isAllowDisappearMaskView = YES;
}


#pragma mark - 计时器事件
//更新播放时间和总时间的显示
- (void)updateTimeLabel
{
    if (self.player.currentItem.duration.timescale != 0) {
        
        AVPlayerItem *currentPlayerItem = self.player.currentItem;
        
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        
        //duration 总时长
        NSInteger durMin = (NSInteger)currentPlayerItem.duration.value / currentPlayerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)currentPlayerItem.duration.value / currentPlayerItem.duration.timescale % 60;//总分钟
        
        //防止在滑动快进退的时候时间闪跳
        if (_isAllowDisappearMaskView) {
            self.videoTimeSlider.maximumValue = 1;//播放对象总时长
            self.videoTimeSlider.value = CMTimeGetSeconds([currentPlayerItem currentTime]) / (currentPlayerItem.duration.value / currentPlayerItem.duration.timescale);//当前进度条
            //当前播放时间
            self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
        }
        
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
    
    if (_player.status == AVPlayerStatusReadyToPlay) {
        [self.activity stopAnimating];
        // 加载完成后，再添加拖拽手势
        // 添加平移手势，用来控制音量和快进快退
    } else {
        [self.activity startAnimating];
    }
    
}

#pragma mark - 设备方向改变通知
//监听设备旋转方向
- (void)deviceOrientationDidChangeNotification {

    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationPortrait:{
            //切换到小屏(默认16：9的宽高比)
            self.isFullScreen = NO;
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:{
            
            self.isFullScreen = YES;
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark -   --kvo && observer

//播放对象的相关状态变化通知
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = self.player.currentItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.cacheProgressView setProgress:timeInterval / totalDuration animated:NO];
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        //监听播放器在缓冲数据的状态
        [self.activity startAnimating];
        self.activity.hidden = NO;
        if (self.player.currentItem.isPlaybackBufferEmpty) {
            [self bufferingSomeSecond];
        }
    }
    else if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusFailed:
                NSLog(@"AVPlayerStatusFailed");
                break;
            case AVPlayerStatusUnknown:
                NSLog(@"AVPlayerStatusUnknown");
                break;
                case AVPlayerStatusReadyToPlay:
                NSLog(@"AVPlayerStatusReadyToPlay");
                break;
            default:
                break;
        }
    }
}

//获取缓冲到的时长
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

//缓冲延迟播放
- (void)bufferingSomeSecond
{
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self mmPlayerPlay];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.player.currentItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
//    });
}


//应用进入前台
- (void) msg_didBecomeActiveNotification:(NSNotification *)notify
{
    self.startBtn.selected = YES;
    [self startOrStopPlayingAction:self.startBtn];
}

//应用进入后台
- (void) msg_didEnterBackgroundNotification:(NSNotification *)notify
{
    if (self.contentMode == MMPlayerContentMode_video) {
        self.startBtn.selected = NO;
        [self startOrStopPlayingAction:self.startBtn];
    }
}

#pragma mark - Action
//单击屏幕方法
- (void)singleTapAction:(UITapGestureRecognizer *)gesture
{
    //单击的时候允许让maskView消失
    _isAllowDisappearMaskView = YES;
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (_isMaskShowing) {
            [self hideMaskView];
        } else {
            [self animateShow];
        }
    }
}

//播放、暂停
- (IBAction)startOrStopPlayingAction:(UIButton *)button
{
    [NSObject cancelPreviousPerformRequestsWithTarget:button];
    
    if (button.selected) {
        [_player play];
        [button setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
        
    } else {
        [_player pause];
        [button setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
        
    }
    button.selected =!button.selected;
}

//slider滑动事件
- (IBAction)timeSliderValueChanged:(UISlider *)slider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAllowMaskViewDisappear) object:nil];
    _isAllowDisappearMaskView = NO;
    [self afterHideMaskView];
    
    AVPlayerItem *currentPlayerItem = self.player.currentItem;
    
    //当前滑动到的时间总秒数
    NSInteger currentTime = (NSInteger)currentPlayerItem.duration.value*slider.value / currentPlayerItem.duration.timescale;
    //当前时长进度progress
    NSInteger currentMin = currentTime / 60;//当前秒
    NSInteger currentSec = currentTime%60;//当前分钟
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", currentMin, currentSec];
}

//slider摁下事件
- (IBAction) timeSliderTouchDown:(UISlider *)slider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAllowMaskViewDisappear) object:nil];
    _isAllowDisappearMaskView = NO;
}

//slider完成事件
- (IBAction) timeSliderTouchUp:(UISlider *)slider
{
    //防止进度条跳闪，延迟一秒后再让定时器刷新时间
    [self performSelector:@selector(setAllowMaskViewDisappear) withObject:nil afterDelay:1];

    //拖动改变视频播放进度
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        
        //计算出拖动的当前秒数
        CGFloat total = (CGFloat)self.player.currentItem.duration.value / self.player.currentItem.duration.timescale;
        
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        
        __weak typeof(self) weakSelf = self;
        [weakSelf.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
            
            [weakSelf mmPlayerPlay];
            
        }];
    }
}

//播放完了
- (void)moviePlayDidEnd:(id)sender
{
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    if (self.goBackBlock) {
        self.goBackBlock();
    }
}

//返回按钮事件
- (IBAction)backButtonAction
{
    if (!self.isFullScreen) {
        [self.timer invalidate];
        self.timer = nil;
        [self mmPlayerPause];
        if (self.goBackBlock) {
            self.goBackBlock();
        }
    }else {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

//全屏按钮事件
- (IBAction)fullScreenAction:(UIButton *)sender {
    if (self.isFullScreen) {
        //切换到小屏
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
    else {
        //切换到全屏
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

//清楚并释放
- (void)clear {
    [self.timer invalidate];
    self.timer = nil;
    [self endPreviousPlay];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.player = nil;
}


#pragma mark - 外部开放方法

/**
 *  暂停播放
 */
- (void)mmPlayerPause
{
    self.startBtn.selected = NO;
    [self startOrStopPlayingAction:self.startBtn];
}

/**
 *  开始播放
 */
- (void)mmPlayerPlay
{
    self.startBtn.selected = YES;
    [self startOrStopPlayingAction:self.startBtn];
}

#pragma mark - 平移手势方法

- (void)panGestureAction:(UIPanGestureRecognizer *)pan
{
    //根据在view上Pan的位置，确定是跳音量、亮度
    CGPoint locationPoint = [pan locationInView:self];
    //NSLog(@"========%@",NSStringFromCGPoint(locationPoint));
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            NSLog(@"x:%f  y:%f",veloctyPoint.x, veloctyPoint.y);
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.panDirection = PanGestureDirectionHorizontalMoved;
                
                // 取消隐藏之前先取消之前执行设置隐藏的方法
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setHorizontalLabelHidden:) object:nil];
                self.horizontalLabel.hidden = NO;
                // 给sumTime初值
                CMTime time = self.player.currentTime;
                self.sumTime = time.value/time.timescale;
                NSLog(@"===%f",self.sumTime);
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanGestureDirectionVerticalMoved;
                // 显示音量还是亮度
                _isVolume = locationPoint.x > self.bounds.size.width / 2;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            // 正在移动
            
            switch (self.panDirection) {
                case PanGestureDirectionHorizontalMoved:{
                     // 水平移动的方法只要x方向的值
                    _isAllowDisappearMaskView = NO;
                    [self horizontalMoved:veloctyPoint.x];
                    break;
                }
                case PanGestureDirectionVerticalMoved:{
                    // 垂直移动方法只要y方向的值
                    [self verticalMoved:veloctyPoint.y];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            
            _isAllowDisappearMaskView = YES;
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanGestureDirectionHorizontalMoved:{
                    
                    //延迟隐藏视图
                    [self performSelector:@selector(setHorizontalLabelHidden:) withObject:nil afterDelay:1.0f];
                    
                    //转换成CMTime才能给player来控制播放进度
                    CMTime dragedCMTime = CMTimeMake(self.sumTime, 1);
                    [_player pause];
                    [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
                        //快进、快退时候把开始播放按钮改为播放状态
                        self.startBtn.selected = YES;
                        [self startOrStopPlayingAction:self.startBtn];
                        // ⚠️在滑动结束后，视屏要跳转
                        [_player play];
                        
                    }];
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case PanGestureDirectionVerticalMoved:{
                    // 垂直移动结束后，隐藏音量控件
                    // 且，把状态改为不再控制音量
                    _isVolume = NO;
                    [self performSelector:@selector(setHorizontalLabelHidden:) withObject:@"1" afterDelay:1.0f];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - pan垂直移动的方法

- (void)verticalMoved:(CGFloat)value
{
    if (_isVolume) {
        // 更改系统的音量
        self.volumeViewSlider.value -= value / 10000; // 越小幅度越小
    }else {
        //亮度
        [UIScreen mainScreen].brightness -= value / 10000;
        NSString *brightness = [NSString stringWithFormat:@"亮度%.0f%%",[UIScreen mainScreen].brightness/1.0*100];
        
        // 取消隐藏之前先取消之前执行设置隐藏的方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setHorizontalLabelHidden:) object:nil];
        self.horizontalLabel.hidden = NO;
        self.horizontalLabel.text = brightness;
    }
}

#pragma mark - pan水平移动的方法
//快退进状态显示
- (void)horizontalMoved:(CGFloat)value
{
    // 快进快退的方法，为防止滑动时停止在屏幕上不动时，记录最后一次是快进还是快退来显示
    NSString *style = @"";
    if (value < 0) {
        style = @"快退";
    }
    else if (value > 0){
        style = @"快进";
    }
    else if ([self.horizontalLabel.text rangeOfString:@"快进"].length > 0) {
        style = @"快进";
    }
    else {
        style = @"快退";
    }
    
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime = self.player.currentItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) {
        self.sumTime = totalMovieDuration;
    }else if (self.sumTime < 0){
        self.sumTime = 0;
    }
    
    // 当前快进的时间
    NSString *nowTime = [self durationStringWithTime:(int)self.sumTime];
    // 总时间
    NSString *durationTime = [self durationStringWithTime:(int)totalMovieDuration];
    
    // 给label赋值
    self.horizontalLabel.text = [NSString stringWithFormat:@"%@  %@ / %@",style, nowTime, durationTime];
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@",nowTime];
    
    //改变进度条的值
    self.videoTimeSlider.value = self.sumTime/totalMovieDuration;
}

#pragma mark - 根据时长求出字符串

//时长转换为字符串类型
- (NSString *)durationStringWithTime:(int)time
{
    // 获取分钟
    NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
    // 获取秒数
    NSString *sec = [NSString stringWithFormat:@"%02d",time % 60];
    return [NSString stringWithFormat:@"%@:%@", min, sec];
}

#pragma mark 强制转屏相关
//强制转换屏幕方向
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


#pragma mark-
- (void)dealloc
{
    //关闭定时器
    [self.timer invalidate];
    self.timer = nil;
    
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    NSLog(@"------%@释放了------",self.class);
}

@end
