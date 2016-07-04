//
//  THTopMenuItem.h
//  THTabarDemo
//
//  Created by mac on 16/5/13.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class THTopMenuItem;

@protocol THTopMenuItemDelegate <NSObject>
@optional
- (void)didPressedMenuItem:(THTopMenuItem *)menuItem;
@end

@interface THTopMenuItem : UILabel

/** 设置rate,并刷新标题状态 */
@property (nonatomic, assign) CGFloat rate;

/** normal状态的字体大小，默认大小为15 */
@property (nonatomic, assign) CGFloat normalSize;

/** selected状态的字体大小，默认大小为18 */
@property (nonatomic, assign) CGFloat selectedSize;

/** normal状态的字体颜色，默认为黑色 (可动画) */
@property (nonatomic, strong) UIColor *normalColor;

/** selected状态的字体颜色，默认为红色 (可动画) */
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, assign, getter=isSelected) BOOL selected;//!< 设置选中未选中

@property (nonatomic, weak) id<THTopMenuItemDelegate> delegate;

- (void)selectedItemWithoutAnimation;//!< 设置选中动画
- (void)deselectedItemWithoutAnimation;//!< 设置未选中动画

@end
