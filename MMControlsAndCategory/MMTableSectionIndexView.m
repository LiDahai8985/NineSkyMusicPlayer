//
//  MMTableSectionIndexView.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/6/28.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import "MMTableSectionIndexView.h"

@interface MMTableSectionIndexView () {
    BOOL         isLayedOut;
    CAShapeLayer *shapeLayer;
    CGFloat      fontSize;
    CGFloat      startY;
}

@property (nonatomic, strong) NSArray           *letters;
@property (nonatomic, assign) CGFloat           letterHeight;
@property (strong, nonatomic) IndexViewTipLabel *tipLabel;

@end



@implementation MMTableSectionIndexView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        if (frame.size.height > 480 - 64 - 49) {
            self.letterHeight = 15 * ScreenScale;
            fontSize = 11.5 * ScreenScale;
        } else {
            self.letterHeight = 13;
            fontSize = 9;
        }
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)dealloc {
    _letters = nil;
    [_tipLabel removeFromSuperview];
    _tipLabel = nil;
}

- (void)setup{
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 1.0f;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineJoin = kCALineCapSquare;
    shapeLayer.strokeColor = [[UIColor clearColor] CGColor];
    shapeLayer.strokeEnd = 1.0f;
    self.layer.masksToBounds = NO;
}

- (void)setTableViewIndexDelegate:(id<MMTableSectionIndexViewDelegate>)tableViewIndexDelegate
{
    _tableViewIndexDelegate = tableViewIndexDelegate;
    self.letters = [self.tableViewIndexDelegate tableViewIndexTitle:self];
    startY = (self.frame.size.height - self.letters.count*self.letterHeight)/2.0;
    isLayedOut = NO;
    [self layoutSubviews];
}

- (IndexViewTipLabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[IndexViewTipLabel alloc] init];
        _tipLabel.bounds = CGRectMake(0, 0, 60, 60);
        _tipLabel.center = CGPointMake(ScreenWidth/2.0, ScreenHeight/2.0 - 30);
        
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15*ScreenScale];
        _tipLabel.textColor = [UIColor whiteColor];
    }
    
    return _tipLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setup];
    
    if (!isLayedOut){
        
        //移除子layer（高斯模糊的子layer不移除）
        for (NSInteger i = self.layer.sublayers.count - 1; i > 1; i --) {
            CALayer *tmpLayer = [self.layer.sublayers objectAtIndex:i];
            [tmpLayer removeFromSuperlayer];
        }
        
        //添加字母文字
        shapeLayer.frame = (CGRect) {.origin = CGPointZero, .size = self.layer.frame.size};
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointZero];
        [bezierPath addLineToPoint:CGPointMake(0, self.frame.size.height)];
        
        [self.letters enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
            CGFloat originY = startY + idx * self.letterHeight;
            CATextLayer *ctl = [self textLayerWithSize:fontSize
                                                string:letter
                                              andFrame:CGRectMake(0, originY, self.frame.size.width, self.letterHeight)];
            [self.layer addSublayer:ctl];
            [bezierPath moveToPoint:CGPointMake(0, originY)];
            [bezierPath addLineToPoint:CGPointMake(ctl.frame.size.width, originY)];
        }];
        
        shapeLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapeLayer];
        
        isLayedOut = YES;
    }
}

- (void)reloadLayout:(UIEdgeInsets)edgeInsets
{
    CGRect rect = self.frame;
    rect.size.height = self.indexes.count * self.letterHeight;
    rect.origin.y = edgeInsets.top + ([self superview].bounds.size.height - edgeInsets.top - edgeInsets.bottom - rect.size.height) / 2;
    self.frame = rect;
}

- (CATextLayer*)textLayerWithSize:(CGFloat)size string:(NSString*)string andFrame:(CGRect)frame{
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setFont:@"ArialMT"];
    [textLayer setFontSize:size];
    [textLayer setFrame:frame];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [textLayer setForegroundColor:[UIColor whiteColor].CGColor];
    [textLayer setString:string];
    return textLayer;
}

#pragma mark- Gesture Methods

- (void)gestureRecognizer:(UIGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView:self];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self sendEventToDelegateWithPoint:point];
            [self indexViewTouchesBegan];
            break;
        case UIGestureRecognizerStateChanged:
            [self sendEventToDelegateWithPoint:point];
            break;
        case UIGestureRecognizerStateEnded:
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                [self indexViewTouchesBegan];
                [self sendEventToDelegateWithPoint:point];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(indexViewTouchesEnd) object:nil];
                [self performSelector:@selector(indexViewTouchesEnd) withObject:nil afterDelay:1];
            }
            else {
                [self indexViewTouchesEnd];
            }
            break;
        default:
            break;
    }
}

- (void)sendEventToDelegateWithPoint:(CGPoint)point{
    
    NSInteger indx = (((NSInteger) floorf(point.y) - startY)/ self.letterHeight);
    
    if (indx< 0 || indx > self.letters.count - 1) {
        return;
    }
    
    self.tipLabel.text = [NSString stringWithFormat:@"%@",self.letters[indx]];
    [self.tableViewIndexDelegate tableViewIndex:self didSelectSectionAtIndex:indx withTitle:self.letters[indx]];
}

/**
 *  开始触摸索引
 *
 *  @param tableViewIndex 触发tableViewIndexTouchesBegan对象
 */
- (void)indexViewTouchesBegan {
    if (!self.tipLabel.superview) {
        [MMAppDelegate.window addSubview:self.tipLabel];
    }
    self.tipLabel.hidden = NO;
}


/**
 *  触摸索引结束
 *
 *  @param tableViewIndex
 */
- (void)indexViewTouchesEnd {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [self.tipLabel.layer addAnimation:animation forKey:nil];
    
    self.tipLabel.hidden = YES;
}

@end



@implementation IndexViewTipLabel

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.97].CGColor);
    
    float radius = 12;
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect) + 12, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
    
    [super drawRect:rect];
}

@end
