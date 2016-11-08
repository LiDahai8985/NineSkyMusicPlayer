//
//  BuyDiscTipView.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/7/7.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuyDiscTipView1;
@protocol BuyDiscTipViewDelegate <NSObject>

- (void)tipView:(BuyDiscTipView1 *)tipView clickButtonAtIndex:(NSInteger)index;
- (void)tipViewCancelButtonClick:(BuyDiscTipView1 *)tipView;

@end


@interface BuyDiscTipView1 : UIView

@property (weak) id<BuyDiscTipViewDelegate> delegate;

- (id)initWithDisc:(id)disc delegate:(id<BuyDiscTipViewDelegate>)delegate isBuy:(BOOL)isBuy;

@end

