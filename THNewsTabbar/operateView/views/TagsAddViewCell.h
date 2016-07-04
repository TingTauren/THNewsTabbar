//
//  TagsAddViewCell.h
//  THNewsTabbar
//
//  Created by mac on 16/6/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagsAddViewModel.h"

@protocol TagsAddViewCellDelegate <NSObject>

- (void)deleteButtonClick:(int) index;

@end

@interface TagsAddViewCell : UICollectionViewCell

@property (nonatomic,strong) UILabel *TAVC_title;//!< 标题

@property (nonatomic,strong) UIButton *TAVC_deleteIcon;//!< 删除按钮

@property (nonatomic,strong) TagsAddViewModel *TAVC_Model;//!< 数据源

@property (nonatomic, weak) id<TagsAddViewCellDelegate> TAVC_Delegate;//!< cell代理

@end
