//
//  ScrollViewVC.m
//  ScrollVCAndNavBar
//
//  Created by lcc on 14-3-3.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import "ScrollViewVC.h"

#define HUALABELTAG 100000

@interface ScrollViewVC() <UIScrollViewDelegate>
{
    UIScrollView *navScrollView;
    UIScrollView *vcScrollView;
    UIView *navView;
    
    //所有类型总数
    NSInteger vcCount;
    
    //标题长度
    CGFloat titleWidth;
    CGFloat sTitleWidth;
    
    //滑块
    UIView *sliderBlockView;
    
    //判断左右滑动起始点
    CGPoint beginPoint;
    //导航栏起点
    CGPoint navBeginPoint;
    
    //最后一次选中的index
    CGFloat lastSelectIndex;
    
    //总长度用于居中
    CGFloat allWidth;
    
    NSInteger nextPageIndex;//下一页
}

@property (nonatomic, assign) NSInteger currentIndex;//当前选中的index
@property (nonatomic, strong) NSMutableDictionary *vcDictionary;


@end

@implementation ScrollViewVC

- (void)dealloc
{
    self.navArray = nil;
    self.vcDictionary = nil;
    self.vcTypeDictionary = nil;
    self.sliderBlockColor = nil;
    self.loadSubviewControllerActionString = nil;

    sliderBlockView = nil;
    navScrollView = nil;
    vcScrollView = nil;
    
    vcCount = 0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        allWidth = frame.size.width;
        
        //窗体容器初始化
        self.vcDictionary = [[NSMutableDictionary alloc] init];
        
        //添加滚动窗体容器
        vcScrollView = [[UIScrollView alloc] init];
        vcScrollView.showsHorizontalScrollIndicator = NO;
        vcScrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        vcScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:vcScrollView];
        vcScrollView.delegate = self;
        vcScrollView.hidden = YES;
        vcScrollView.bounces = NO;
        vcScrollView.pagingEnabled = YES;
        navScrollView.tag = 2;
        //end
        
        //导航栏背景
        navView = [[UIView alloc] init];
        navView.frame = CGRectMake(0, 0, allWidth, _navViewHeight);
        [self addSubview:navView];
        
        //添加导航栏
        navScrollView = [[UIScrollView alloc] init];
        navScrollView.showsHorizontalScrollIndicator = NO;
        navScrollView.frame = CGRectMake(0, 0, allWidth, _navViewHeight);
        navScrollView.backgroundColor = [UIColor whiteColor];
        [navView addSubview:navScrollView];
        navScrollView.hidden = YES;
        navScrollView.bounces = NO;
        navScrollView.tag = 1;
        //end
        
        lastSelectIndex = 0;
        //end
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect navViewRect = navView.frame;
    CGRect vcScrollViewRect = vcScrollView.frame;
    
    navViewRect.origin.y = 0;
    vcScrollViewRect.origin.y = navViewRect.size.height;
    vcScrollViewRect.size.height = self.frame.size.height - navViewRect.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        navView.frame = navViewRect;
        vcScrollView.frame = vcScrollViewRect;
    }];
}

#pragma mark -
#pragma mark - custom method

//添加导航栏
- (void) addNavViewWithDefaultIndex:(NSInteger)defaultIndex
{
    [self dealDefaultValue];
    
    vcCount = [self.navArray count];

    if (vcCount > 0)
    {
        navScrollView.hidden = NO;
        vcScrollView.hidden = NO;
        
        //设置窗体容器一些属性
        vcScrollView.contentSize = CGSizeMake(ScreenWidth*vcCount, 0);
    }
    
    //nav长度计算值
    CGFloat navWidth = 0;
    
    //判断是否居中和均分
    BOOL isCenter = NO;
    CGFloat maxValue = 0;
    if (vcCount < 6)
    {
        for (NSInteger i = 0; i < vcCount; i ++)
        {
            ScrollViewObject *tmpObj = [self.navArray objectAtIndex:i];
            //计算每个标题大小
            //NSAssert([tmpObj conformsToProtocol:@protocol(MMScrollViewObjectProtocol)], @"ScrollViewVC --- navArray的数组不包含符合 MMScrollViewObjectProtocol协议的object");
            CGSize wordSize = [tmpObj.s_title sizeWithFont:[UIFont systemFontOfSize:16.5] constrainedToSize:CGSizeMake(ScreenWidth, _navViewHeight) lineBreakMode:NSLineBreakByTruncatingTail];
            if (wordSize.width > maxValue)
            {
                maxValue = wordSize.width;
            }
        }
        
        maxValue = (maxValue + 30)*vcCount;
        
        if (maxValue <= ScreenWidth)
        {
            isCenter = YES;
            
            allWidth = ScreenWidth;
            maxValue = ScreenWidth;
            
            CGRect atRect = navScrollView.frame;
            atRect.size.width = allWidth;
            atRect.origin.x = (ScreenWidth - allWidth)/2;
            navScrollView.frame = atRect;
        }
        
    }
    //end
    
    //动态添加具体类型导航内容
    for (NSInteger i = 0; i < vcCount; i ++)
    {
        ScrollViewObject *tmpObj = [self.navArray objectAtIndex:i];
        //计算每个标题大小
        CGSize wordSize = [tmpObj.s_title sizeWithFont:[UIFont systemFontOfSize:16.5] constrainedToSize:CGSizeMake(ScreenWidth, _navViewHeight) lineBreakMode:NSLineBreakByTruncatingTail];
        if (isCenter)
        {
            tmpObj.s_titleWidth = [NSString stringWithFormat:@"%f",maxValue/vcCount - 30];
        }
        else
        {
            tmpObj.s_titleWidth = [NSString stringWithFormat:@"%f",wordSize.width];
        }
        
        //end
        
        //添加类型标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(navWidth + 15, 0, [tmpObj.s_titleWidth floatValue], _navViewHeight)];
        titleLabel.font = [UIFont systemFontOfSize:16.5];
        titleLabel.text = tmpObj.s_title;
        titleLabel.tag = 20 + i;
        [navScrollView addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = self.defaultTitleColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        //end
        
        //添加透明按钮
        UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpBtn.frame = CGRectMake(navWidth, 0, [tmpObj.s_titleWidth floatValue] + 30, _navViewHeight);
        [navScrollView addSubview:tmpBtn];
        tmpBtn.tag = 200 + i;
        [tmpBtn addTarget:self action:@selector(titleTapped:) forControlEvents:UIControlEventTouchUpInside];
        //end
        
        //左右字各控 ---15px title 15px----
        navWidth += ([tmpObj.s_titleWidth floatValue] + 30);
        
        //添加第一个窗体
        if (i == defaultIndex)
        {
            //动态创建滚动窗体--单每个窗体格式是一样的
            [self createVcWithIndex:defaultIndex];
            
            [vcScrollView setContentOffset:CGPointMake(defaultIndex * ScreenWidth, vcScrollView.contentOffset.y) animated:NO];
            
            //添加滑块
            sliderBlockView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tmpObj.s_titleWidth floatValue] + 30, _navViewHeight)];
            [navScrollView addSubview:sliderBlockView];
            sliderBlockView.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.1 alpha:0.3];
            
            [navScrollView sendSubviewToBack:sliderBlockView];
            
            //添加下划线
            UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.navViewHeight -  self.huaHeight, [tmpObj.s_titleWidth floatValue]+20, self.huaHeight)];
            lineImgView.backgroundColor = self.sliderBlockColor;
            lineImgView.tag = HUALABELTAG;
            [sliderBlockView addSubview:lineImgView];
            lineImgView.hidden = YES;
            
            if (self.huaHeight != 0)
            {
                lineImgView.hidden = NO;
            }
            //end
            //默认选中第一个
            titleLabel.textColor = self.selectedTitleColor;
        }
    }
    
    //设置导航栏的contentsize
    navScrollView.contentSize = CGSizeMake(navWidth, _navViewHeight);
}

//动态创建窗体
- (void) createVcWithIndex:(NSInteger) index
{
    ScrollViewObject *tmpObj = [self.navArray objectAtIndex:index];
    //判读vc是否被创建
    if (![self.vcDictionary.allKeys containsObject:tmpObj.s_id])
    {
        UIViewController *tmpVc = nil;
        
        NSAssert([self.navArray count] > 0, @"scrollVC中的子vc不能为空");
        
        NSString *tmpVcString = (NSString *)[self.vcTypeDictionary objectForKey:tmpObj.s_vcType];
        tmpVc = [[NSClassFromString(tmpVcString) alloc] init];
        tmpVc.view.frame = CGRectMake(ScreenWidth*index, 0, ScreenWidth, CGRectGetHeight(vcScrollView.bounds));
        [self.vcDictionary setObject:tmpVc forKey:tmpObj.s_id];
        [[NSNotificationCenter defaultCenter] addObserver:tmpVc
                                                 selector:NSSelectorFromString(self.navHeightOffsetChangedNotificationActionString)
                                                     name:[NSString stringWithFormat:@"NotificationName_%p",self]
                                                   object:nil];
        
        //根据返回的方法明动态调用
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:",self.loadSubviewControllerActionString]);
        if ([tmpVc respondsToSelector:selector])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [tmpVc performSelector:selector withObject:tmpObj];
#pragma clang diagnostic pop
        }
        
        [vcScrollView addSubview:tmpVc.view];
    }
}

//默认值处理
- (void) dealDefaultValue
{
    if (self.huaHeight == 0)
    {
        self.huaHeight = _navViewHeight;
    }
    
    if (self.initialOffsetHeight == 0)
    {
        self.initialOffsetHeight = _navViewHeight;
    }
    
    if (self.defaultTitleColor == nil)
    {
        self.defaultTitleColor = [UIColor grayColor];
    }
    
    if (self.selectedTitleColor == nil)
    {
        self.selectedTitleColor = [UIColor whiteColor];
    }
    
    if (self.sliderBlockColor == nil)
    {
        self.sliderBlockColor = self.selectedTitleColor;
    }
    
    if (self.navbackcolor == nil)
    {
        self.navbackcolor = [UIColor whiteColor];
    }
    
    navScrollView.backgroundColor = self.navbackcolor;
    navView.backgroundColor = self.navbackcolor;
}

- (void)setNavViewHeight:(CGFloat)navViewHeight
{
    _navViewHeight = navViewHeight;
    navView.frame = CGRectMake(0, 0, allWidth, _navViewHeight);
    navScrollView.frame = CGRectMake(0, 0, allWidth, _navViewHeight);
    vcScrollView.frame = CGRectMake(0, _navViewHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - _navViewHeight);
}

- (void) setCurrentIndex:(NSInteger)currentIndex
{
    if (_currentIndex != currentIndex)
    {
        if (_s_delegate && [_s_delegate respondsToSelector:@selector(scrollViewVCColumnChange:currentIndex:)]) {
            [_s_delegate scrollViewVCColumnChange:self currentIndex:currentIndex];
        }
    }
    _currentIndex = currentIndex;
}



#pragma mark -
#pragma mark - 控件事件

- (void) titleTapped:(UIButton *) sender
{
    //如果选择的是当前选择的，返回
    if (sender.tag - 200 == self.currentIndex)
    {
        [self adjustNavScrollViewContentOffset:self.currentIndex];
        return;
    }
    self.currentIndex = sender.tag - 200;

    //获取titleLabel
    UILabel *lastTitleLabel = (UILabel *)[navScrollView viewWithTag:20 + lastSelectIndex];
    lastTitleLabel.textColor = self.defaultTitleColor;
    UILabel *currentTitleLabel = (UILabel *)[navScrollView viewWithTag:20 + self.currentIndex];
    currentTitleLabel.textColor = self.selectedTitleColor;
    
    lastSelectIndex = self.currentIndex;
    
    [vcScrollView setContentOffset:CGPointMake(ScreenWidth*self.currentIndex, 0) animated:NO];
    
    [self createVcWithIndex:self.currentIndex];
    
    //移动滑块到点击位置
    CGRect rect = sliderBlockView.frame;
    sliderBlockView.frame = (CGRect){sender.frame.origin.x, rect.origin.y, sender.frame.size};
    
    [self adjustNavScrollViewContentOffset:self.currentIndex];
}

- (void) selectAtIndex:(NSInteger) index
{
    UIButton *sender = (UIButton *)[navScrollView viewWithTag:200 + index];
    [self titleTapped:sender];
}

- (void)setNavViewOffset:(CGPoint)offset withVcId:(NSString *)vcId {
    ScrollViewObject *tmpObject = [self.navArray objectAtIndex:self.currentIndex];
    if ([tmpObject.s_id integerValue] == [vcId integerValue]) {
        CGRect navViewRect = navView.frame;
        navViewRect.origin.y = offset.y>(-_navViewHeight)?0:(-offset.y);
        navView.frame = navViewRect;
    }
}

/**
 *  状态栏点击事件
 */
- (void)statusBarTappedAction
{
    [vcScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *objView = (UIView *)obj;
        if ((NSInteger)objView.frame.origin.x == (NSInteger)self.currentIndex*ScreenWidth) {
            [objView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([(UIView *)obj isKindOfClass:[UIScrollView class]]) {
                    [(UIScrollView *)obj setContentOffset:CGPointMake(0, -self.initialOffsetHeight) animated:YES];
                    *stop = YES;
                }
            }];
            *stop = YES;
        }
    }];
}


- (void)adjustNavScrollViewContentOffset:(NSInteger)currentPage
{
    //NSAssert(currentPage >= 0, @"adjustNavScrollViewContentOffset currentPage 不能小于0");
    NSInteger allPage = [self.navArray count];
    NSInteger frontPage = MAX(0, currentPage - 1);
    NSInteger nextPage = MIN(allPage, currentPage + 1);
    
    UILabel *frontTitleLabel = (UILabel *)[navScrollView viewWithTag:20 + frontPage];
    UILabel *currentTitleLabel = (UILabel *)[navScrollView viewWithTag:20 + currentPage];
    UILabel *nextTitleLabel = (UILabel *)[navScrollView viewWithTag:20 + nextPage];
    
    float leftTitleLabel_x = CGRectGetMinX(frontTitleLabel.frame);
    float rightTitleLabel_x = CGRectGetMaxX(nextTitleLabel.frame);
    
    float allDisplayWidth = rightTitleLabel_x - leftTitleLabel_x;
    float contentOffset_x = leftTitleLabel_x + (allDisplayWidth/2 - CGRectGetWidth(navScrollView.frame)/2);
    if (frontTitleLabel == currentTitleLabel || frontPage == 0) {
        contentOffset_x = 0;
    }
    else if (nextTitleLabel == currentTitleLabel || nextPage == allPage) {
        contentOffset_x = navScrollView.contentSize.width - CGRectGetWidth(navScrollView.frame);
    }
    else {
        //当前选择界面不是最两端时，防止滑倒超过最大能滑动距离
        contentOffset_x = MIN(navScrollView.contentSize.width - CGRectGetWidth(navScrollView.frame), contentOffset_x);
        if (contentOffset_x < 0)
        {
            contentOffset_x = 0;
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        navScrollView.contentOffset = CGPointMake(contentOffset_x, 0);
    }];
}


#pragma mark -
#pragma mark - scroll delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.window endEditing:YES];
    
    if (fabs(scrollView.contentOffset.x - beginPoint.x) > 0 && fabs(scrollView.contentOffset.x - beginPoint.x) < 30  && self.isAllowEarlyLoadSubVc)
    {
        //往左滑，还是往右滑
        BOOL isLeftScroll = scrollView.contentOffset.x - beginPoint.x > 0 ?YES:NO;
        NSInteger tmpNextPage = beginPoint.x/scrollView.frame.size.width + (isLeftScroll?1:(-1));
        
        if (tmpNextPage >= 0 && tmpNextPage < self.navArray.count + 1 && tmpNextPage != nextPageIndex) {
            [self createVcWithIndex:tmpNextPage];
            nextPageIndex = tmpNextPage;
        }
    }
    
    
    if (scrollView.contentOffset.y != 0)
    {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
    CGPoint secondPoint = scrollView.contentOffset;
    
    //当滑动超过一页时候，重新设置相关参数
    if (fabs((secondPoint.x - beginPoint.x))/ScreenWidth > 1) {
        [self scrollViewWillBeginDragging:scrollView];
        return;
    }
    
    //联动导航栏
    CGRect rect = sliderBlockView.frame;
    
    if (secondPoint.x - beginPoint.x > 0 && (self.currentIndex + 1) < vcCount)
    {
        //向左滑动
        rect.origin.x = (scrollView.contentOffset.x - self.currentIndex*ScreenWidth)*(titleWidth + 30)/ScreenWidth + navBeginPoint.x;
        ScrollViewObject *sTmpObj = [self.navArray objectAtIndex:self.currentIndex + 1];
        
        //动态变化长度
        CGFloat secWidth = [sTmpObj.s_titleWidth floatValue];
        secWidth = secWidth - titleWidth;
        rect.size.width = (scrollView.contentOffset.x - self.currentIndex*ScreenWidth)*secWidth/ScreenWidth + titleWidth + 30;
    }
    
    if (secondPoint.x - beginPoint.x < 0 && (self.currentIndex - 1) >= 0)
    {
        ScrollViewObject *sTmpObj = [self.navArray objectAtIndex:self.currentIndex - 1];
        CGFloat secWidth = [sTmpObj.s_titleWidth floatValue];
        
        //向右滑动 动态变化长度
        rect.origin.x = (scrollView.contentOffset.x - self.currentIndex*ScreenWidth)*(sTitleWidth + 30)/ScreenWidth + navBeginPoint.x;
        secWidth = secWidth - titleWidth;
        rect.size.width = (self.currentIndex*ScreenWidth - scrollView.contentOffset.x)*secWidth/ScreenWidth + titleWidth + 30;
    }
    
    sliderBlockView.frame = rect;
    
    if (self.huaHeight != 0)
    {
        //调整下划线
        UIImageView *lineImgView = (UIImageView *)[navScrollView viewWithTag:HUALABELTAG];
        CGRect lRect = lineImgView.frame;
        lRect.size.width = rect.size.width - 30;
        lineImgView.frame = lRect;
    }
    
    //调整标题滑动中的颜色值和大小
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginPoint = scrollView.contentOffset;
    navBeginPoint = sliderBlockView.frame.origin;
    
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    self.currentIndex = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
    
    
    ScrollViewObject *tmpObj = [self.navArray objectAtIndex:self.currentIndex];
    titleWidth = [tmpObj.s_titleWidth floatValue];
    
    if (self.currentIndex > 0)
    {
        ScrollViewObject *sTmpObj = [self.navArray objectAtIndex:self.currentIndex - 1];
        sTitleWidth = [sTmpObj.s_titleWidth floatValue];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView createNewVC:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
                         createNewVC:(BOOL)createNewVC
{
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
    self.currentIndex = currentPage;
    
    if (createNewVC) {
        [self createVcWithIndex:currentPage];
    }
    
    //获取titleLabel
    UILabel *lastTitleLabel = (UILabel *)[navScrollView viewWithTag:20 + lastSelectIndex];

    UILabel *currentTitleLabel = (UILabel *)[navScrollView viewWithTag:20 + currentPage];

    //NSLog(@"=========bili:01=========curr:%f=========next:%f",currentTitleLabel.transform.a,lastTitleLabel.transform.a);
    
    [UIView animateWithDuration:0.3 animations:^{
        lastTitleLabel.textColor = self.defaultTitleColor;
        lastTitleLabel.transform = CGAffineTransformMakeScale( 1, 1);
        
        currentTitleLabel.textColor = self.selectedTitleColor;
    } completion:^(BOOL finished) {
        //NSLog(@"=========bili:02=========curr:%f=========next:%f",currentTitleLabel.transform.a,lastTitleLabel.transform.a);
    }];

    lastSelectIndex = currentPage;
    
    //移动滑块到点击位置
    CGRect rect = sliderBlockView.frame;
    UIButton *tmpBtn = (UIButton *)[navScrollView viewWithTag:200 + currentPage];
    sliderBlockView.frame = (CGRect){tmpBtn.frame.origin.x, rect.origin.y, tmpBtn.frame.size};
    
    if (self.huaHeight != 0)
    {
        //调整下划线
        UIImageView *lineImgView = (UIImageView *)[navScrollView viewWithTag:HUALABELTAG];
        CGRect lRect = lineImgView.frame;
        lRect.size.width = rect.size.width - 30;
        lineImgView.frame = lRect;
    }
    
    [self adjustNavScrollViewContentOffset:currentPage];
}

@end



@implementation ScrollViewObject

@end

