//
//  TEXTView.m
//  THNewsTabbar
//
//  Created by mac on 16/6/24.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "TEXTView.h"

@implementation TEXTView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)loadViewData {
    UITableView *table = [[UITableView alloc] initWithFrame:self.bounds];
    [self addSubview:table];
}//!< 加载数据
- (void)clearViewData {
    
}//!< 清除数据

@end
