//
//  OperateView.h
//  THNewsTabbar
//
//  Created by mac on 16/6/21.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OperateView : UIView

@property (nonatomic, strong) NSMutableArray *showDataArr;//!< 顶部显示数据
@property (nonatomic, strong) NSMutableArray *notEditableArr;//!< 不可编辑数据
@property (nonatomic, readonly) NSMutableArray *downDataArr;//!< 底部显示数据
@property (nonatomic, assign) BOOL isAnimation;//!< 是否动画

@property (nonatomic, strong) NSString *selectTitle;//!< 选择项

@property (nonatomic, copy) void(^closedClickBolk)(OperateView *, NSString *);//!< bolk
@property (nonatomic, copy) void(^selectClickBolk)(OperateView *, NSString *);//!< bolk

- (BOOL)dataIsChange;//!< 数据是否改变
- (NSMutableArray *)getMyOperateDataArr;//!< 获取操作后数据
- (void)showView;//!< 显示视图
- (void)hiddenView;//!< 隐藏视图

@end
