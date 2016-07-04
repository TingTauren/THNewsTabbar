//
//  BottomScrollerSuperView.h
//  THTabarDemo
//
//  Created by mac on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomView.h"
#import "THTopMenuView.h"

@protocol BottomScrollerSuperViewDelegate <NSObject>

- (void)selectScrollView:(BottomView *) btmView andOldView:(BottomView *) oldView;

@end

@interface BottomScrollerSuperView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, weak) id<BottomScrollerSuperViewDelegate> bottomDelegate;

@property (nonatomic, weak) id superDelegate;

@property (nonatomic, strong) THTopMenuView *menuView;//!< 菜单视图

@property (nonatomic, retain) NSArray *viewNameArray;//!< 标题数据
@property (nonatomic, retain) NSArray<Class> *viewArray;//!< 视图数据

- (void)initWithViews;

@end
