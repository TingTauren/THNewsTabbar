//
//  THTabbarNounView.m
//  THTabarDemo
//
//  Created by mac on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "THTabbarNounView.h"

#import "UIColor+changeImage.h"

#import "THTopMenuView.h"
#import "BottomScrollerSuperView.h"
#import "BottomView.h"

//  标题的颜色(选中/非选中) (P.S.标题颜色是可动画的)
#define THTitleColorSelected [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1]
#define THTitleColorNormal   [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
//  导航菜单栏的背景颜色
#define THMenuBGColor        [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0]
//  添加按钮width
#define THAddWidth           50.0


//  标题的尺寸(选中/非选中)
static CGFloat const THTitleSizeSelected = 15.0f;
static CGFloat const THTitleSizeNormal   = 15.0f;
//  导航菜单栏的高度
static CGFloat const THMenuHeight        = 30.0f;
//  导航菜单栏每个item的宽度
static CGFloat const THMenuItemWidth     = 65.0f;

@interface THTabbarNounView()<THTopMenuViewDelegate,BottomScrollerSuperViewDelegate>
@end

@implementation THTabbarNounView {
    THTopMenuView *_topView;
    UIButton *_addButton;//!< 加号按钮视图
    UIImageView *_addIcon;//!< 加号按钮图标
    BottomScrollerSuperView *_bottomScrollerView;
}
- (void)setViewControllerClasses:(NSArray<Class> *)viewControllerClasses {
    _viewControllerClasses = viewControllerClasses;
}
- (void)setTitles:(NSArray *)titles {
    _titles = titles;
}
- (instancetype)initWithFrame:(CGRect)frame andTitleArr:(NSArray *) titleArr andViewArr:(NSArray<Class> *) classArr{
    self = [super initWithFrame:frame];
    if (self) {
        NSParameterAssert(classArr.count == titleArr.count);//!< 断言
        _viewControllerClasses = [NSArray arrayWithArray:classArr];
        _titles = [NSArray arrayWithArray:titleArr];
        
        [self setup];//!< 初始化数据
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}
// 初始化一些参数，在init中调用
- (void)setup {
    _titleSizeSelected  = THTitleSizeSelected;
    _titleColorSelected = THTitleColorSelected;
    _titleSizeNormal    = THTitleSizeNormal;
    _titleColorNormal   = THTitleColorNormal;
    
    _menuBGColor   = THMenuBGColor;
    _menuHeight    = THMenuHeight;
    _menuItemWidth = THMenuItemWidth;
}

- (void)initviews {
    [_topView removeFromSuperview];
    [_addButton removeFromSuperview];
    [_addIcon removeFromSuperview];
    [_bottomScrollerView removeFromSuperview];
    
    _topView = [[THTopMenuView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-THAddWidth, _menuHeight)];
    _topView.selectedSize = THTitleSizeSelected;
    _topView.normalSize = _titleSizeNormal;
    _topView.selectedColor = _titleColorSelected;
    _topView.normalColor = _titleColorNormal;
    _topView.backgroundColor = _menuBGColor;
    _topView.thTopMenuDelegate = self;
    [self addSubview:_topView];
    
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addButton setFrame:CGRectMake(CGRectGetMaxX(_topView.frame), 0, THAddWidth, _menuHeight)];
    [_addButton setBackgroundColor:_menuBGColor];//[UIColor colorWithRed:0.769 green:0.769 blue:0.769 alpha:1]
    _addButton.layer.shadowOpacity = 0.05;
    _addButton.layer.shadowOffset = CGSizeMake(-1.0f, -0.0f);
    [_addButton setBackgroundImage:[UIColor createImageWithColor:[UIColor colorWithRed:0.784 green:0.776 blue:0.800 alpha:1]] forState:UIControlStateHighlighted];
    [self addSubview:_addButton];
    [_addButton addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside];
    
    _addIcon = [[UIImageView alloc] initWithFrame:CGRectMake((THAddWidth-(_menuHeight-10))/2, 5, _menuHeight-10, _menuHeight-10)];
    [_addIcon setImage:[UIImage imageNamed:@"add.png"]];
    [_addButton addSubview:_addIcon];
    
    if (_isShowAddButton) {//!< 是否显示添加按钮
        _addButton.hidden = NO;
        _addIcon.hidden = NO;
        
        [_topView setFrame:CGRectMake(0, 0, self.bounds.size.width-THAddWidth, _menuHeight)];
    } else {
        _addButton.hidden = YES;
        _addIcon.hidden = YES;
        
        [_topView setFrame:CGRectMake(0, 0, self.bounds.size.width, _menuHeight)];
    }
    
    _bottomScrollerView = [[BottomScrollerSuperView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(_topView.frame))];
    [self addSubview:_bottomScrollerView];
    
    _bottomScrollerView.menuView = _topView;//!< 代理

    _topView.titleArray = _titles;
    [_topView initWithTitleButtons];
    
    _bottomScrollerView.viewNameArray = _titles;
    _bottomScrollerView.viewArray = _viewControllerClasses;
    _bottomScrollerView.menuView = _topView;
    _bottomScrollerView.bottomDelegate = self;
    _bottomScrollerView.superDelegate = _delegate;
    [_bottomScrollerView initWithViews];
}

- (void)selectTitleIndex:(NSInteger) index {//!< 选择某项
    [_topView selectItems:index];//!< 选择某项
}
- (void)clickPlay {
    if ([_delegate respondsToSelector:@selector(AddbuttonResponseMethod)]) {
        [_delegate AddbuttonResponseMethod];
    }
}

#pragma mark - topDelegate
- (void)menuView:(THTopMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    CGPoint targetP = CGPointMake(self.bounds.size.width*index, 0);
    [_bottomScrollerView setContentOffset:targetP animated:YES];
}
#pragma mark - bottomDelegate
- (void)selectScrollView:(BottomView *) btmView andOldView:(BottomView *)oldView {
    if ([_delegate respondsToSelector:@selector(backSelectScrollView:oldView:)]) {
        [_delegate backSelectScrollView:btmView oldView:oldView];
    }
}

@end
