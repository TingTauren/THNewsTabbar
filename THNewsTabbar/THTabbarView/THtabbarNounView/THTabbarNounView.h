//
//  THTabbarNounView.h
//  THTabarDemo
//
//  Created by mac on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BottomView;

@protocol THTabbarNounViewDelegate <NSObject>

- (void)backSelectScrollView:(BottomView *) btmView oldView:(BottomView *) oldView;

- (void)AddbuttonResponseMethod;//!< 添加按钮响应方法

@end

@interface THTabbarNounView : UIView

/**
 *  选中时的标题尺寸
 *  The title size when selected (animatable)
 */
@property (nonatomic, assign) CGFloat titleSizeSelected;

/**
 *  非选中时的标题尺寸
 *  The normal title size (animatable)
 */
@property (nonatomic, assign) CGFloat titleSizeNormal;

/**
 *  标题选中时的颜色, 颜色是可动画的.
 *  The title color when selected, the color is animatable.
 */
@property (nonatomic, strong) UIColor *titleColorSelected;

/**
 *  标题非选择时的颜色, 颜色是可动画的.
 *  The title's normal color, the color is animatable.
 */
@property (nonatomic, strong) UIColor *titleColorNormal;

/**
 *  导航栏高度
 *  The menu view's height
 */
@property (nonatomic, assign) CGFloat menuHeight;

/**
 *  导航栏背景色
 *  The background color of menu view
 */
@property (nonatomic, strong) UIColor *menuBGColor;

/**
 *  每个 MenuItem 的宽度
 *  The item width,when all are same,use this property
 */
@property (nonatomic, assign) CGFloat menuItemWidth;


@property (nonatomic, copy) NSArray<Class> *viewControllerClasses;//!< 视图数组
@property (nonatomic, copy) NSArray *titles;//!< 标题视图

@property (nonatomic, assign) BOOL isShowAddButton;//!< 是否显示添加按钮

@property (nonatomic, weak) id<THTabbarNounViewDelegate> delegate;//!< 代理

- (instancetype)initWithFrame:(CGRect)frame andTitleArr:(NSArray *) titleArr andViewArr:(NSArray<Class> *) classArr;

- (void)initviews;

- (void)selectTitleIndex:(NSInteger) index;//!< 选择某项

@end
