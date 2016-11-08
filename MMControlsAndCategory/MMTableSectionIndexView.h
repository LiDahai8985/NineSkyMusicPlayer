//
//  MMTableSectionIndexView.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/6/28.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMTableSectionIndexViewDelegate;

@interface MMTableSectionIndexView : UIToolbar

@property (nonatomic, strong) NSArray *indexes;
@property (nonatomic, weak) id <MMTableSectionIndexViewDelegate> tableViewIndexDelegate;

- (void)reloadLayout:(UIEdgeInsets)edgeInsets;

@end



@protocol MMTableSectionIndexViewDelegate <NSObject>

/**
 *  触摸到索引时触发
 *
 *  @param tableViewIndex 触发didSelectSectionAtIndex对象
 *  @param index          索引下标
 *  @param title          索引文字
 */
- (void)tableViewIndex:(MMTableSectionIndexView *)tableViewIndex didSelectSectionAtIndex:(NSInteger)index withTitle:(NSString *)title;


/**
 *  TableView中右边右边索引title
 *
 *  @param tableViewIndex 触发tableViewIndexTitle对象
 *
 *  @return 索引title数组
 */
- (NSArray *)tableViewIndexTitle:(MMTableSectionIndexView *)tableViewIndex;

@end



@interface IndexViewTipLabel : UILabel

@end
