//
//  BuyDiscTipView.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/7.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuyDiscTipView;
@protocol BuyDiscTipViewDelegate <NSObject>

- (void)tipView:(BuyDiscTipView *)tipView clickButtonAtIndex:(NSInteger)index totalCount:(NSInteger)count;
- (void)tipViewCancelButtonClick:(BuyDiscTipView *)tipView;

@end


@interface BuyDiscTipView : UIView

@property (weak) id<BuyDiscTipViewDelegate> delegate;

- (id)initWithDisc:(id)disc delegate:(id<BuyDiscTipViewDelegate>)delegate isBuy:(BOOL)isBuy;

- (void)showWithView:(UIView *)view animation:(BOOL)animation;

@end
