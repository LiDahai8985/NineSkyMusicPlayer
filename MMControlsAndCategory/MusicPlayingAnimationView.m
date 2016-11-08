//
//  MusicPlayingAnimationView.m
//  MyDemo
//
//  Created by LiDaHai on 16/6/23.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#define LineDefaultColor   [UIColor whiteColor]
#define LineHighlightColor [UIColor redColor]

#import "MusicPlayingAnimationView.h"

@interface MusicPlayingAnimationView ()
{
    DashLineLayer *leftLine;
    DashLineLayer *midLine;
    DashLineLayer *rightLine;
    BOOL          isAnimating;
}

@end

@implementation MusicPlayingAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //添加左边虚线
        DashLineLayer *leftBottomWhiteLine = [DashLineLayer layer];
        leftBottomWhiteLine.frame = CGRectMake(frame.size.width/2.0 - 10, frame.size.height/2 -1, 6, 12);
        leftBottomWhiteLine.lineColor = LineDefaultColor;
        [leftBottomWhiteLine setNeedsDisplay];
        
        leftLine = [DashLineLayer layer];
        leftLine.frame = leftBottomWhiteLine.frame;
        leftLine.lineColor = LineHighlightColor;
        [leftLine setNeedsDisplay];
        
        CALayer *leftLineMaskLayer = [CALayer layer];
        leftLineMaskLayer.anchorPoint = CGPointMake(0.5, 1);
        leftLineMaskLayer.bounds = CGRectMake(0, 0, leftLine.frame.size.width, 0);
        leftLineMaskLayer.position = CGPointMake(leftLine.frame.size.width/2, leftLine.frame.size.height);
        leftLineMaskLayer.backgroundColor = LineHighlightColor.CGColor;
        leftLine.mask = leftLineMaskLayer;
        
        //中间虚线
        DashLineLayer *midBottomWhiteLine = [DashLineLayer layer];
        midBottomWhiteLine.frame = CGRectMake(frame.size.width/2.0, frame.size.height/2 - 11, leftBottomWhiteLine.frame.size.width, 22);
        midBottomWhiteLine.lineColor = LineDefaultColor;
        [midBottomWhiteLine setNeedsDisplay];
        
        midLine = [DashLineLayer layer];
        midLine.frame = midBottomWhiteLine.frame;
        midLine.lineColor = LineHighlightColor;
        [midLine setNeedsDisplay];
        
        CALayer *midLineMaskLayer = [CALayer layer];
        midLineMaskLayer.anchorPoint = CGPointMake(0.5, 1);
        midLineMaskLayer.bounds = CGRectMake(0, 0, midLine.frame.size.width, 0);
        midLineMaskLayer.position = CGPointMake(midLine.frame.size.width/2, midLine.frame.size.height);
        midLineMaskLayer.backgroundColor = LineHighlightColor.CGColor;
        midLine.mask = midLineMaskLayer;
        
        //右边虚线
        DashLineLayer *rightBottomWhiteLine = [DashLineLayer layer];
        rightBottomWhiteLine.frame = CGRectMake(frame.size.width/2.0 + 10, frame.size.height/2 +4, leftBottomWhiteLine.frame.size.width, 7);
        rightBottomWhiteLine.lineColor = LineDefaultColor;
        [rightBottomWhiteLine setNeedsDisplay];
        
        rightLine = [DashLineLayer layer];
        rightLine.frame = rightBottomWhiteLine.frame;
        rightLine.lineColor = LineHighlightColor;
        [rightLine setNeedsDisplay];
        
        CALayer *rightLineMaskLayer = [CALayer layer];
        rightLineMaskLayer.anchorPoint = CGPointMake(0.5, 1);
        rightLineMaskLayer.bounds = CGRectMake(0, 0, rightLine.frame.size.width, 0);
        rightLineMaskLayer.position = CGPointMake(rightLine.frame.size.width/2, rightLine.frame.size.height);
        rightLineMaskLayer.backgroundColor = LineHighlightColor.CGColor;
        rightLine.mask = rightLineMaskLayer;
        
        [self.layer addSublayer:leftBottomWhiteLine];
        [self.layer addSublayer:leftLine];
        [self.layer addSublayer:midBottomWhiteLine];
        [self.layer addSublayer:midLine];
        [self.layer addSublayer:rightBottomWhiteLine];
        [self.layer addSublayer:rightLine];
        
        //防止动画中时进入后台再返回前台是动画停止
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msg_applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

//显示并动画
- (void)showWithAnimation:(BOOL)animation {
    
    CABasicAnimation *lineAnimation = (CABasicAnimation *)[leftLine.mask animationForKey:@"LineAnimation"];
    
    //记录当前动画状态
    isAnimating = animation;
    
    if (animation && !lineAnimation) {
        
        //先将位置归零
        leftLine.mask.bounds = CGRectMake(0, 0, leftLine.frame.size.width, 0);
        midLine.mask.bounds = CGRectMake(0, 0, midLine.frame.size.width, 0);
        rightLine.mask.bounds = CGRectMake(0, 0, rightLine.frame.size.width, 0);
        
            for (NSInteger i = 0; i < 3; i ++ ) {
                CABasicAnimation *anim = [CABasicAnimation animation];
                anim.keyPath = @"bounds.size.height";
                anim.autoreverses = YES;
                anim.repeatCount = MAXFLOAT;
                
                switch (i) {
                    case 0:
                        anim.fromValue = @(0.5);
                        anim.toValue = @(12);
                        anim.duration = 0.3;
                        [leftLine.mask addAnimation:anim forKey:@"LineAnimation"];
                        break;
                    case 1:
                        anim.fromValue = @(0.5);
                        anim.toValue = @(22);
                        anim.duration = 0.4;
                        [midLine.mask addAnimation:anim forKey:@"LineAnimation"];
                        break;
                    case 2:
                        anim.fromValue = @(0.5);
                        anim.toValue = @(7);
                        anim.duration = 0.3;
                        [rightLine.mask addAnimation:anim forKey:@"LineAnimation"];
                        break;
                }
            }
    }
    else if (lineAnimation){
        [leftLine.mask removeAnimationForKey:@"LineAnimation"];
        [midLine.mask removeAnimationForKey:@"LineAnimation"];
        [rightLine.mask removeAnimationForKey:@"LineAnimation"];
        
        //最后停在某一位置
        leftLine.mask.bounds = CGRectMake(0, 0, leftLine.frame.size.width, arc4random()%11 + arc4random()%10*0.1);
        midLine.mask.bounds = CGRectMake(0, 0, midLine.frame.size.width, arc4random()%21 + arc4random()%10*0.1);
        rightLine.mask.bounds = CGRectMake(0, 0, rightLine.frame.size.width, arc4random()%6 + arc4random()%10*0.1);
    }
}

- (void)msg_applicationWillEnterForegroundNotification:(NSNotification *)notification {
    [self showWithAnimation:isAnimating];
}

@end




@implementation DashLineLayer

- (void)drawInContext:(CGContextRef)ctx {
    
    CGRect rect = self.frame;
    
    //画虚线
    CGFloat  lengths[2] = {2,3};
    CGContextBeginPath(ctx);
    
    CGContextSetLineWidth(ctx, rect.size.width);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineDash(ctx, 0, lengths, 2);
    CGContextMoveToPoint(ctx, rect.size.width/2, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width/2, 0);
    CGContextStrokePath(ctx);
}

@end