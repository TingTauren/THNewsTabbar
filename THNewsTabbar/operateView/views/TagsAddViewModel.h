//
//  TagsAddViewModel.h
//  THNewsTabbar
//
//  Created by mac on 16/6/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsAddViewModel : NSObject

@property (nonatomic, copy) NSString *TAVM_title;//!< 标题

@property (nonatomic, assign) BOOL TAVM_isShowDelete;//!< 是否显示删除按钮(默认NO)

@property (nonatomic, assign) BOOL TAVM_isSelect;//!< 是否选中(默认NO)

@property (nonatomic, assign) BOOL TAVM_isEdit;//!< 是否可以操作(默认YES)

- (void)RevertData;//!< 还原选项

-(id) initWithDict:(NSDictionary *)dict;
+(id) TagsAddViewModelWithDict:(NSDictionary *)dict;

@end
