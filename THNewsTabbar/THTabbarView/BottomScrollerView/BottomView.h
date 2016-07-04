//
//  BottomView.h
//  THTabarDemo
//
//  Created by mac on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BottomView;
@interface BottomView : UIView

@property (nonatomic, weak) id superController;//!< navgation

@property (nonatomic, copy) void(^block)(BottomView *);//一个参数，没有返回值的block

@property (nonatomic, strong) NSDictionary *bottomDict;//!< 数据
@property (nonatomic, assign) BOOL isShow;//!< 数据

- (void)loadViewData;//!< 加载数据
- (void)clearViewData;//!< 清除数据

@end
