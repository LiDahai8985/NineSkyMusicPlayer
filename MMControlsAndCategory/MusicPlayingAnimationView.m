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
}

@end

@implementation MusicPlayingAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //添加左边虚线
        DashLineLayer *leftBottomWhiteLine = [DashLineLayer layer];
        leftBottomWhiteLine.frame = CGRectMake(frame.size.width/2.0 - 10, frame.size.height/2 - 1, 6, 13);
        leftBottomWhiteLine.lineColor = LineDefaultColor;
        [leftBottomWhiteLine setNeedsDisplay];
        
        leftLine = [DashLineLayer layer];
        leftLine.frame = CGRectMake(frame.size.width/2.0 - 10, frame.size.height/2 - 1, 6, 13);
        leftLine.lineColor = LineHighlightColor;
        [leftLine setNeedsDisplay];
        
        CALayer *leftLineMaskLayer = [CALayer layer];
        leftLineMaskLayer.anchorPoint = CGPointMake(0.5, 1);
        leftLineMaskLayer.bounds = CGRectMake(0, 0, leftLine.frame.size.width, 7.8);
        leftLineMaskLayer.position = CGPointMake(leftLine.frame.size.width/2, leftLine.frame.size.height);
        leftLineMaskLayer.backgroundColor = LineHighlightColor.CGColor;
        leftLine.mask = leftLineMaskLayer;
        
        //中间虚线
        DashLineLayer *midBottomWhiteLine = [DashLineLayer layer];
        midBottomWhiteLine.frame = CGRectMake(frame.size.width/2.0, frame.size.height/2 - 12, 6, 24);
        midBottomWhiteLine.lineColor = LineDefaultColor;
        [midBottomWhiteLine setNeedsDisplay];
        
        midLine = [DashLineLayer layer];
        midLine.frame = CGRectMake(frame.size.width/2.0, frame.size.height/2 - 12, 6, 24);
        midLine.lineColor = LineHighlightColor;
        [midLine setNeedsDisplay];
        
        CALayer *midLineMaskLayer = [CALayer layer];
        midLineMaskLayer.anchorPoint = CGPointMake(0.5, 1);
        midLineMaskLayer.bounds = CGRectMake(0, 0, midLine.frame.size.width, 16.5);
        midLineMaskLayer.position = CGPointMake(midLine.frame.size.width/2, midLine.frame.size.height);
        midLineMaskLayer.backgroundColor = LineHighlightColor.CGColor;
        midLine.mask = midLineMaskLayer;
        
        //右边虚线
        DashLineLayer *rightBottomWhiteLine = [DashLineLayer layer];
        rightBottomWhiteLine.frame = CGRectMake(frame.size.width/2.0 + 10, frame.size.height/2 + 4.5, 6, 7.5);
        rightBottomWhiteLine.lineColor = LineDefaultColor;
        [rightBottomWhiteLine setNeedsDisplay];
        
        rightLine = [DashLineLayer layer];
        rightLine.frame = CGRectMake(frame.size.width/2.0 + 10, frame.size.height/2 + 4.5, 6, 7.5);
        rightLine.lineColor = LineHighlightColor;
        [rightLine setNeedsDisplay];
        
        CALayer *rightLineMaskLayer = [CALayer layer];
        rightLineMaskLayer.anchorPoint = CGPointMake(0.5, 1);
        rightLineMaskLayer.bounds = CGRectMake(0, 0, rightLine.frame.size.width, 6.3);;
        rightLineMaskLayer.position = CGPointMake(rightLine.frame.size.width/2, rightLine.frame.size.height);
        rightLineMaskLayer.backgroundColor = LineHighlightColor.CGColor;
        rightLine.mask = rightLineMaskLayer;
        
        [self.layer addSublayer:leftBottomWhiteLine];
        [self.layer addSublayer:leftLine];
        [self.layer addSublayer:midBottomWhiteLine];
        [self.layer addSublayer:midLine];
        [self.layer addSublayer:rightBottomWhiteLine];
        [self.layer addSublayer:rightLine];
    }
    
    return self;
}

//显示并动画
- (void)showWithAnimation:(BOOL)animation {
    
    CABasicAnimation *lineAnimation = (CABasicAnimation *)[leftLine.mask animationForKey:@"LineAnimation"];
    
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
                        anim.toValue = @(13);
                        anim.duration = 0.3;
                        [leftLine.mask addAnimation:anim forKey:@"LineAnimation"];
                        break;
                    case 1:
                        anim.fromValue = @(0.5);
                        anim.toValue = @(24);
                        anim.duration = 0.4;
                        [midLine.mask addAnimation:anim forKey:@"LineAnimation"];
                        break;
                    case 2:
                        anim.fromValue = @(0.5);
                        anim.toValue = @(8);
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
        leftLine.mask.bounds = CGRectMake(0, 0, leftLine.frame.size.width, arc4random()%12 + arc4random()%10*0.1);
        midLine.mask.bounds = CGRectMake(0, 0, midLine.frame.size.width, arc4random()%23 + arc4random()%10*0.1);
        rightLine.mask.bounds = CGRectMake(0, 0, rightLine.frame.size.width, arc4random()%6 + arc4random()%10*0.1);
    }
}

@end




@implementation DashLineLayer

- (void)drawInContext:(CGContextRef)ctx {
    
    CGRect rect = self.frame;
    
    //画虚线
    CGFloat  lengths[2] = {2,3.5};
    CGContextBeginPath(ctx);
    
    CGContextSetLineWidth(ctx, rect.size.width);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineDash(ctx, 0, lengths, 2);
    CGContextMoveToPoint(ctx, rect.size.width/2, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width/2, 0);
    CGContextStrokePath(ctx);
}

@end