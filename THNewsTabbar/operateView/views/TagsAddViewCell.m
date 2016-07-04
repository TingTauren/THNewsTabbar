//
//  TagsAddViewCell.m
//  THNewsTabbar
//
//  Created by mac on 16/6/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "TagsAddViewCell.h"

@implementation TagsAddViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _TAVC_title = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
        _TAVC_title.layer.borderColor = [UIColor blackColor].CGColor;
        _TAVC_title.layer.borderWidth = 0.5;
        _TAVC_title.layer.cornerRadius = 5;
        _TAVC_title.layer.masksToBounds = YES;
        _TAVC_title.textAlignment = NSTextAlignmentCenter;
        _TAVC_title.textColor = [UIColor blackColor];
        [self.contentView addSubview:_TAVC_title];
        
        _TAVC_deleteIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        _TAVC_deleteIcon.frame = CGRectMake(0, 0, 20, 20);
        _TAVC_deleteIcon.layer.cornerRadius = 10;
        _TAVC_deleteIcon.layer.masksToBounds = YES;
        _TAVC_deleteIcon.backgroundColor = [UIColor colorWithRed:0.451 green:0.451 blue:0.518 alpha:1];
        [_TAVC_deleteIcon setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:_TAVC_deleteIcon];
        _TAVC_deleteIcon.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setTAVC_Model:(TagsAddViewModel *)TAVC_Model {
    _TAVC_Model = TAVC_Model;
    
    _TAVC_title.text = _TAVC_Model.TAVM_title;
    
    _TAVC_deleteIcon.hidden = YES;
    if (_TAVC_Model.TAVM_isSelect) {
        _TAVC_title.textColor = [UIColor redColor];
        if (_TAVC_Model.TAVM_isEdit) {
            _TAVC_deleteIcon.hidden = !_TAVC_Model.TAVM_isShowDelete;
        }
    } else {
        _TAVC_title.textColor = [UIColor blackColor];
        if (_TAVC_Model.TAVM_isEdit) {
            _TAVC_deleteIcon.hidden = !_TAVC_Model.TAVM_isShowDelete;
        } else {
            _TAVC_title.textColor = [UIColor grayColor];
        }
    }
}

@end
