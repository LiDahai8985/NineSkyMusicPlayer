//
//  BuyDiscTipView.m
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/7.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "BuyDiscTipView1.h"

@interface BuyDiscTipView1 ()

@property (assign, nonatomic) BOOL        isBuy;
@property (strong, nonatomic) IBOutlet UIImageView *coverImgView;
@property (strong, nonatomic) IBOutlet UILabel     *introLabel;
@property (strong, nonatomic) IBOutlet UILabel     *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton    *payBtn;
@property (strong, nonatomic) IBOutlet UIButton    *rechargeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeightConstraint;

@end

@implementation BuyDiscTipView1

- (void)dealloc
{
    NSLog(@"-------tipView释放了------");
}

- (id)initWithDisc:(id)disc delegate:(id<BuyDiscTipViewDelegate>)delegate isBuy:(BOOL)isBuy
{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] lastObject];
    
    if (self) {
        self.isBuy = isBuy;
        self.delegate = delegate;
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    self.tipLabelTopConstraint.constant = self.isBuy?(-42):0;
    self.imgWidthConstraint.constant = 90 * ScreenScale;
    self.imgHeightConstraint.constant = 90 * ScreenScale;
    
}


- (IBAction)btnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tipView:clickButtonAtIndex:)]) {
        [self.delegate tipView:self clickButtonAtIndex:sender == self.rechargeBtn?0:1];
    }
}

- (IBAction)cancelBtnClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tipViewCancelButtonClick:)]) {
        [self.delegate tipViewCancelButtonClick:self];
    }
}

@end
