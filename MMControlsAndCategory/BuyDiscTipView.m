//
//  BuyDiscTipView.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/7.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "BuyDiscTipView.h"


@interface BuyDiscTipView ()
{
    NSDate *oldDate;
    BOOL isFastAdd;
    BOOL isFastSubtract;
}

@property (assign, nonatomic) BOOL        isBuy;
@property (strong, nonatomic) UIView      *contentBgView;
@property (strong, nonatomic) UIImageView *coverImgView;
@property (strong, nonatomic) UILabel     *introLabel;
@property (strong, nonatomic) UILabel     *countLabel;
@property (strong, nonatomic) UILabel     *totalPriceLabel;
@property (strong, nonatomic) UIButton    *payBtn;
@property (strong, nonatomic) UIButton    *rechargeBtn;
@property (strong, nonatomic) NSTimer     *timer;


@end

@implementation BuyDiscTipView

- (void)dealloc
{
    NSLog(@"-------tipView释放了------");
}

- (id)initWithDisc:(id)disc delegate:(id<BuyDiscTipViewDelegate>)delegate isBuy:(BOOL)isBuy
{
    self = [[self.class alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    if (self) {
        self.isBuy = isBuy;
        self.delegate = delegate;
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    CGFloat contentWidth = ScreenWidth - 40;
    CGFloat contentHeight = (20 + (self.isBuy?0:44) + 15 + 90 + 15 + 15 + 20 + 15 + 20 + 15 + 35 + 20)*ScreenScale;
    
    UIButton *backBlackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBlackBtn.frame = self.bounds;
    backBlackBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [backBlackBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backBlackBtn];
    
    //内容view
    self.contentBgView = [[UIView alloc] initWithFrame:CGRectMake(20, (ScreenHeight - contentHeight)/2.0, contentWidth, contentHeight)];
    self.contentBgView.backgroundColor = [UIColor clearColor];
    
    //白色区域view
    UIView *whiteBgView = [[UIView alloc] initWithFrame:CGRectMake(20, 20*ScreenScale, contentWidth - 40, contentHeight - 20*ScreenScale)];
    whiteBgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.98];
    whiteBgView.layer.cornerRadius = 8.0;
    whiteBgView.clipsToBounds = YES;
    [self.contentBgView addSubview:whiteBgView];
    
    if (!self.isBuy)
    {
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, whiteBgView.frame.size.width, 44*ScreenScale)];
        topLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:248/255.0 blue:215/255.0 alpha:1];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.font = [UIFont systemFontOfSize:12*ScreenScale];
        topLabel.textColor = [UIColor colorWithRed:179/255.0 green:115/255.0 blue:7/255.0 alpha:1];
        topLabel.text = @"购买唱片后就可以收听你喜欢的歌曲啦！";
        [whiteBgView addSubview:topLabel];
    }
    
    
    //封面图
    self.coverImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (self.isBuy?0:44*ScreenScale)+15*ScreenScale, 90*ScreenScale, 90*ScreenScale)];
    self.coverImgView.backgroundColor = [UIColor blueColor];
    self.coverImgView.image = [UIImage imageNamed:@"3"];
    [whiteBgView addSubview:self.coverImgView];
    
    
    //唱片名和歌手
    self.introLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.coverImgView.frame) + 10, self.coverImgView.frame.origin.y, CGRectGetWidth(whiteBgView.frame) - (CGRectGetMaxX(self.coverImgView.frame) + 10) - 15, CGRectGetHeight(self.coverImgView.frame))];
    self.introLabel.backgroundColor = [UIColor clearColor];
    self.introLabel.textColor = [UIColor lightGrayColor];
    self.introLabel.attributedText = [self getIntroAttributedString];
    self.introLabel.numberOfLines = 0;
    [whiteBgView addSubview:self.introLabel];
    
    //分割线
    UILabel *seporateLine = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.coverImgView.frame) + 15*ScreenScale, CGRectGetWidth(whiteBgView.frame), 1)];
    seporateLine.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.4];
    [whiteBgView addSubview:seporateLine];
    
    //标题“购买数量”label
    UILabel *countLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.coverImgView.frame.origin.x, CGRectGetMaxY(seporateLine.frame) + 15*ScreenScale, 80*ScreenScale, 20*ScreenScale)];
    countLeftLabel.backgroundColor = [UIColor clearColor];
    countLeftLabel.font = [UIFont systemFontOfSize:15*ScreenScale];
    countLeftLabel.textColor = [UIColor grayColor];
    countLeftLabel.text = @"购买数量";
    [whiteBgView addSubview:countLeftLabel];
    
    //减号btn
    UIButton *subtractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    subtractBtn.frame = CGRectMake(CGRectGetMaxX(countLeftLabel.frame), countLeftLabel.frame.origin.y - 2, 25*ScreenScale, 25*ScreenScale);
    subtractBtn.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
    [subtractBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [subtractBtn setTitle:@"-" forState:UIControlStateNormal];
    subtractBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    subtractBtn.layer.borderWidth = 0.8;
    [subtractBtn addTarget:self action:@selector(subtractCount) forControlEvents:UIControlEventTouchUpInside];
    [subtractBtn addTarget:self action:@selector(subtractCountTouchDown) forControlEvents:UIControlEventTouchDown];
    [whiteBgView addSubview:subtractBtn];
    
    //加号btn
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(CGRectGetWidth(whiteBgView.frame) - 50 , CGRectGetMinY(countLeftLabel.frame) - 2, subtractBtn.frame.size.width, subtractBtn.frame.size.height);
    addBtn.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
    [addBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [addBtn setTitle:@"+" forState:UIControlStateNormal];
    addBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    addBtn.layer.borderWidth = 0.8;
    [addBtn addTarget:self action:@selector(addCount) forControlEvents:UIControlEventTouchUpInside];
    [addBtn addTarget:self action:@selector(addCountTouchDown) forControlEvents:UIControlEventTouchDown];
    [whiteBgView addSubview:addBtn];
    
    //数量label
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(subtractBtn.frame)-1, subtractBtn.frame.origin.y, CGRectGetMinX(addBtn.frame)- CGRectGetMaxX(subtractBtn.frame)+3, subtractBtn.frame.size.height)];
    self.countLabel.backgroundColor = whiteBgView.backgroundColor;
    self.countLabel.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
    self.countLabel.textColor = [UIColor grayColor];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.text = @"1";
    self.countLabel.layer.borderWidth = 0.8;
    self.countLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.countLabel.font = [UIFont systemFontOfSize:15*ScreenScale];
    [whiteBgView addSubview:self.countLabel];
    
    
    //标题“合计”lable
    UILabel *totalPriceLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(countLeftLabel.frame), CGRectGetMaxY(countLeftLabel.frame) + 15*ScreenScale, countLeftLabel.frame.size.width, countLeftLabel.frame.size.height)];
    totalPriceLeftLabel.backgroundColor = [UIColor clearColor];
    totalPriceLeftLabel.font = [UIFont systemFontOfSize:15*ScreenScale];
    totalPriceLeftLabel.textColor = [UIColor grayColor];
    totalPriceLeftLabel.text = @"合       计";
    [whiteBgView addSubview:totalPriceLeftLabel];
    
    //总价钱金币图片
    UIImageView *priceLogo = [[UIImageView alloc] initWithFrame:CGRectMake(subtractBtn.frame.origin.x, CGRectGetMinY(totalPriceLeftLabel.frame), 20, 20)];
    priceLogo.backgroundColor = [UIColor colorWithRed:179/255.0 green:115/255.0 blue:7/255.0 alpha:1];
    priceLogo.layer.masksToBounds = YES;
    priceLogo.layer.cornerRadius = 10;
    [whiteBgView addSubview:priceLogo];
    
    //总价钱label
    self.totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(priceLogo.frame) + 5, totalPriceLeftLabel.frame.origin.y, CGRectGetWidth(whiteBgView.frame) - CGRectGetMaxX(priceLogo.frame) - 20,totalPriceLeftLabel.frame.size.height)];
    self.totalPriceLabel.font = [UIFont systemFontOfSize:15*ScreenScale];
    self.totalPriceLabel.textAlignment = NSTextAlignmentLeft;
    self.totalPriceLabel.textColor = [UIColor grayColor];
    self.totalPriceLabel.text = @"24";
    [whiteBgView addSubview:self.totalPriceLabel];
    
    //去充值btn
    self.rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rechargeBtn.frame = CGRectMake(self.coverImgView.frame.origin.x, CGRectGetMaxY(totalPriceLeftLabel.frame) + 15*ScreenScale, (CGRectGetWidth(whiteBgView.frame) - 3*self.coverImgView.frame.origin.x)/2.0, 35*ScreenScale);
    [self.rechargeBtn setTitle:@"去充值" forState:UIControlStateNormal];
    self.rechargeBtn.titleLabel.font = [UIFont systemFontOfSize:14*ScreenScale];
    [self.rechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rechargeBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateHighlighted];
    [self.rechargeBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.rechargeBtn.clipsToBounds = YES;
    self.rechargeBtn.layer.cornerRadius = 5.0;
    self.rechargeBtn.backgroundColor = [UIColor redColor];
    [whiteBgView addSubview:self.rechargeBtn];
    
    //确认支付btn
    self.payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.payBtn.frame = CGRectMake(CGRectGetMaxX(self.rechargeBtn.frame) + self.coverImgView.frame.origin.x, self.rechargeBtn.frame.origin.y, (CGRectGetWidth(whiteBgView.frame) - 3*self.coverImgView.frame.origin.x)/2.0, self.rechargeBtn.frame.size.height);
    [self.payBtn setTitle:@"确认支付" forState:UIControlStateNormal];
    self.payBtn.titleLabel.font = self.rechargeBtn.titleLabel.font;
    [self.payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.payBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateHighlighted];
    [self.payBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.payBtn.clipsToBounds = YES;
    self.payBtn.layer.cornerRadius = 5.0;
    self.payBtn.backgroundColor = [UIColor redColor];
    [whiteBgView addSubview:self.payBtn];
    
    //关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(self.contentBgView.frame.size.width - 20 - 30*ScreenScale/2.0, 20*ScreenScale - 30*ScreenScale/2.0, 30*ScreenScale, 30*ScreenScale);
    closeBtn.clipsToBounds = YES;
    closeBtn.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [closeBtn setTitle:@"×" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:40];
    closeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 2, 0);
    closeBtn.layer.cornerRadius = 30*ScreenScale/2.0;
    [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBgView addSubview:closeBtn];
    
    [self addSubview:self.contentBgView];
    
    self.contentBgView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
}


- (void)showWithView:(UIView *)view animation:(BOOL)animation
{
    [view addSubview:self];
    if (animation) {
        CAKeyframeAnimation * animation;
        animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.35;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        animation.repeatCount = 0;
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 0.25)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 0.5)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.08, 1.08, 0.75)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        animation.values = values;
        
        [self.contentBgView.layer addAnimation:animation forKey:nil];
    }
}

- (void)hide
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.35;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBackwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.875, 0.875, 0.875)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.75, 0.75, 0.75)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.625, 0.625, 0.625)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 0.5)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.375, 0.375, 0.375)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.25, 0.25, 0.25)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.125, 0.125, 0.125)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.06, 0.06, 0.06)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 0)]];
    animation.values = values;
    
    [self.contentBgView.layer addAnimation:animation forKey:nil];
    
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tipViewCancelButtonClick:)]) {
        [self.delegate tipViewCancelButtonClick:self];
    }
}

- (NSMutableAttributedString *)getIntroAttributedString
{
    NSString *firstString = @"时间不存在收到付款链接阿斯蒂芬";
    NSString *secondString = @"推乐队";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",firstString,secondString]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15*ScreenScale] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.2 alpha:1] range:NSMakeRange(0, firstString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10*ScreenScale] range:NSMakeRange(firstString.length, attributedString.length - firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.6 alpha:1] range:NSMakeRange(firstString.length, attributedString.length - firstString.length)];
    
    //增大行间距
    NSMutableParagraphStyle *nameParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [nameParagraphStyle setLineSpacing:1];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:nameParagraphStyle range:NSMakeRange(0, firstString.length)];
    
    NSMutableParagraphStyle *singerParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [singerParagraphStyle setLineSpacing:4];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:singerParagraphStyle range:NSMakeRange(firstString.length+1, secondString.length)];
    
    
    
    return attributedString;
}

- (void)subtractCount
{
    isFastSubtract = NO;
    if ([self.countLabel.text integerValue] > 1) {
        self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)([self.countLabel.text integerValue] - 1)];
    }
}

- (void)subtractCountTouchDown
{
    isFastSubtract = YES;
    oldDate = [NSDate date];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(subtractCountFast) userInfo:nil repeats:YES];
}

- (void)subtractCountFast
{
    NSLog(@"--- ----- --->%f",[oldDate timeIntervalSinceDate:[NSDate date]]);
    if (isFastSubtract) {
        
        if ([[NSDate date] timeIntervalSinceDate:oldDate] > 0.5) {
            if ([self.countLabel.text integerValue] > 1) {
                self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)([self.countLabel.text integerValue] - 1)];
            }
        }
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}


- (void)addCount
{
    isFastAdd = NO;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)([self.countLabel.text integerValue] + 1)];
}


- (void)addCountTouchDown
{
    isFastAdd = YES;
    oldDate = [NSDate date];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(addCountFast) userInfo:nil repeats:YES];
}

- (void)addCountFast
{
    NSLog(@"--- +++++ --->%f",[oldDate timeIntervalSinceDate:[NSDate date]]);
    if (isFastAdd) {
        
        if ([[NSDate date] timeIntervalSinceDate:oldDate] > 0.5) {
            self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)([self.countLabel.text integerValue] + 1)];
        }
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}


- (void)bottomBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tipView:clickButtonAtIndex:totalCount:)]) {
        [self.delegate tipView:self clickButtonAtIndex:sender == self.rechargeBtn?0:1 totalCount:[self.countLabel.text integerValue]];
    }
}


@end
