//
//  THTopMenuView.h
//  THTabarDemo
//
//  Created by mac on 16/5/13.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THTopMenuItem.h"

@class THTopMenuView;

@protocol THTopMenuViewDelegate <NSObject>
@optional
- (void)menuView:(THTopMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;
@end

@interface THTopMenuView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, retain) NSArray *titleArray;//!< 标题数据

@property (nonatomic, retain) NSMutableArray *buttonWithArray;//!< 按钮位置数据

@property (nonatomic, assign) CGFloat selectedSize;//!< 选中时标题大小
@property (nonatomic, assign) CGFloat normalSize;//!< 未选中时标题大小
@property (nonatomic, strong) UIColor *selectedColor;//!< 选中时标题颜色
@property (nonatomic, strong) UIColor *normalColor;//!< 未选中时标题颜色

@property (nonatomic, copy) NSString *fontName;//!< 字体名称
@property (nonatomic, assign) CGFloat itemMargin;//!< 间距

@property (nonatomic, weak) id<THTopMenuViewDelegate> thTopMenuDelegate;

//加载顶部标题
- (void)initWithTitleButtons;

- (void)slideMenuAtProgress:(CGFloat)progress;//!< 跟新位置

- (void)selectItems:(NSInteger) index;//!< 选择某项

@end
