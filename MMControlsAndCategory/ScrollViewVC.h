//
//  ScrollViewVC.h
//  ScrollVCAndNavBar
//
//  Created by lcc on 14-3-3.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollViewVCDelegate;

@interface ScrollViewVC : UIView

@property (nonatomic, copy)   NSMutableArray      *navArray;
@property (nonatomic, strong) NSMutableDictionary *vcTypeDictionary;

//加载子vc时，需要子vc执行的方法
@property (nonatomic, strong) NSString *loadSubviewControllerActionString;


//navView在y轴方向的坐标变化时，发出对应的通知和执行的相关方法名
@property (nonatomic, strong) NSString *navHeightOffsetChangedNotificationActionString;

/**
 *  //让子vc执行某一动作的方法
 */
@property (nonatomic, strong) NSString *subVcActionString;

//滑块颜色
@property (nonatomic, strong) UIColor *sliderBlockColor;

//标题默认颜色
@property (nonatomic, strong) UIColor *defaultTitleColor;

//标题选中颜色
@property (nonatomic, strong) UIColor *selectedTitleColor;


//导航栏背景颜色
@property (nonatomic, strong) UIColor *navbackcolor;

//滑块的高度
@property (nonatomic, assign) CGFloat huaHeight;

//默认需要偏移的最大高度
@property (nonatomic, assign) CGFloat initialOffsetHeight;

//navView当前偏移的高度
@property (nonatomic, assign) CGFloat currentOffsetHeight;

/**
 *  是否要提前加载,允许则当scroll稍微偏向下一页或上一页时即会加载subVc
 */
@property (assign, nonatomic) BOOL isAllowEarlyLoadSubVc;

/**
 *  顶部滑动栏目高度，默认是30
 */
@property (nonatomic, assign) CGFloat navViewHeight;


/**
 *  代理
 */
@property (nonatomic, weak) id<ScrollViewVCDelegate> s_delegate;


/**
 *  添加导航栏，此方法应为设置参数后最后调用
 *
 *  @param defaultIndex 默认的页码index
 */
- (void)addNavViewWithDefaultIndex:(NSInteger)defaultIndex;


/**
 *  改变相关偏移
 *
 *  @param offset 子view中的scroll偏移
 *  @param vcId   子view的判断标志
 */
- (void)setNavViewOffset:(CGPoint)offset withVcId:(NSString *)vcId;


/**
 *  选中某一栏目
 *
 *  @param index 对应栏目的index
 */
- (void)selectAtIndex:(NSInteger) index;


/**
 *  状态栏点击事件
 */
- (void)statusBarTappedAction;


@end




@protocol ScrollViewVCDelegate <NSObject>

@optional

/**
 *  栏目切换时候调用
 *
 *  @param scrollViewVC scrollViewVC
 *  @param currentIndex 新的index
 */
- (void) scrollViewVCColumnChange:(ScrollViewVC *)scrollViewVC
                     currentIndex:(NSInteger)currentIndex;


/**
 *  当子vc上面navview上下有移动时调用此方法改变子view中相关坐标
 *
 *  @param offset 当前偏移量
 */
- (void)scrollViewVcNavOffsetChanged:(CGFloat)offset;

@end



@interface ScrollViewObject : NSObject

@property (strong, nonatomic) NSString *s_id;
@property (strong, nonatomic) NSString *s_titleWidth;
@property (strong, nonatomic) NSString *s_title;
//枚举类型
@property (strong, nonatomic) NSString *s_vcType;

//自定义扩展属性
@property (strong, nonatomic) NSString *s_outLink;
@property (strong, nonatomic) NSString *s_imgUrl;
@property (strong, nonatomic) NSString *s_typed;

@property (strong, nonatomic) NSString *s_isShow;

@property (strong, nonatomic) NSString *s_cellString;

@end

