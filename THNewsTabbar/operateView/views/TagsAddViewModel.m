//
//  TagsAddViewModel.m
//  THNewsTabbar
//
//  Created by mac on 16/6/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "TagsAddViewModel.h"

@implementation TagsAddViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _TAVM_title = @"";
        _TAVM_isSelect = NO;
        _TAVM_isShowDelete = NO;
        _TAVM_isEdit = YES;
    }
    return self;
}

- (void)RevertData {
    _TAVM_isSelect = NO;
    _TAVM_isShowDelete = NO;
}

-(id) initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        
    }
    return self;
}
+(id) TagsAddViewModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
