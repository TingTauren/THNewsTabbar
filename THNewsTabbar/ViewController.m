//
//  ViewController.m
//  THNewsTabbar
//
//  Created by mac on 16/6/20.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ViewController.h"
#import "THTabbarNounView.h"//!< 滚动视图
#import "BottomView.h"//!< 滚动视图
#import "OperateView.h"//!< 功能视图
#import "TEXTView.h"

@interface ViewController ()<THTabbarNounViewDelegate>

@end

@implementation ViewController {
    THTabbarNounView *_thTbbarView;//!< 滚动视图
    OperateView *_operateView;//!< 操作视图
    
    NSString *_selectString;//!< string
    
    NSMutableArray *_dataArr;//!< 数据
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor cyanColor];
    _dataArr = [NSMutableArray arrayWithObjects:@"热门",@"朋友圈",@"表演",@"空乘",@"美术",@"播音",@"舞蹈",@"书法",@"音乐",@"编导", nil];
    
    [self createTabbarView];
}

#pragma mark - 创建
- (void)createTabbarView {//!< 创建tabbarView
    NSMutableArray *titleArr = [NSMutableArray array];
    NSMutableArray *viewArr = [NSMutableArray array];
    for (int i=0,count=(int)_dataArr.count; i<count; i++) {
        NSString *string = [_dataArr objectAtIndex:i];
        NSString *type = [NSString stringWithFormat:@"%d",i];
        [titleArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:string,@"Name",type,@"key", nil]];
        TEXTView *btomView = [[TEXTView alloc] init];
        [btomView setBackgroundColor:[UIColor colorWithRed:0.07*i+0.05 green:0.05*i+0.05 blue:0.09*i+0.05 alpha:1.0]];
        [viewArr addObject:btomView];
    }
    
    _thTbbarView = [[THTabbarNounView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20) andTitleArr:titleArr andViewArr:viewArr];
    _thTbbarView.isShowAddButton = YES;
    _thTbbarView.menuHeight = 40;
    _thTbbarView.titleColorSelected = [UIColor colorWithRed:0.902 green:0.012 blue:0.267 alpha:1];
    _thTbbarView.titleColorNormal = [UIColor colorWithRed:0.412 green:0.404 blue:0.404 alpha:1];
    _thTbbarView.menuBGColor = [UIColor colorWithRed:0.969 green:0.973 blue:0.973 alpha:1];
    _thTbbarView.delegate = self;
    [self.view addSubview:_thTbbarView];
    [_thTbbarView initviews];
}

- (void)getTHTabbarNounView:(NSMutableArray *) arr {//!< 设置tabbar数据
    NSMutableArray *titleArr = [NSMutableArray array];
    NSMutableArray *viewArr = [NSMutableArray array];
    for (int i=0,count=(int)arr.count; i<count; i++) {
        NSString *string = [arr objectAtIndex:i];
        NSString *type = [NSString stringWithFormat:@"%d",i];
        [titleArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:string,@"Name",type,@"key", nil]];
        TEXTView *btomView = [[TEXTView alloc] init];
        [btomView setBackgroundColor:[UIColor colorWithRed:0.07*i+0.05 green:0.05*i+0.05 blue:0.09*i+0.05 alpha:1.0]];
        [viewArr addObject:btomView];
    }
    
    _thTbbarView.titles = titleArr;
    _thTbbarView.viewControllerClasses = viewArr;
    [_thTbbarView initviews];
}

#pragma mark - delegate
- (void)backSelectScrollView:(BottomView *) btmView oldView:(BottomView *) oldView {
    _selectString = [btmView.bottomDict objectForKey:@"Name"];
    NSLog(@"%@",_selectString);
}
- (void)AddbuttonResponseMethod {//!< 添加按钮响应事件
    if (!_operateView) {
        _operateView = [[OperateView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20)];
        _operateView.isAnimation = YES;
        _operateView.showDataArr = _dataArr;
        _operateView.notEditableArr = [NSMutableArray arrayWithObjects:@"热门",@"朋友圈", nil];
        _operateView.selectTitle = _selectString;
        [self.view addSubview:_operateView];
        __weak ViewController *mySelf = self;THTabbarNounView *myTabbar = _thTbbarView;
        [_operateView setClosedClickBolk:^(OperateView *myOperateView, NSString *selectString) {
            if ([myOperateView dataIsChange]) {
                [mySelf getTHTabbarNounView:[myOperateView getMyOperateDataArr]];
                
                NSInteger index = [myOperateView.showDataArr indexOfObject:selectString];
                [myTabbar selectTitleIndex:index];
            }
        }];
        [_operateView setSelectClickBolk:^(OperateView *myOperateView, NSString *title) {
            NSInteger index = [myOperateView.showDataArr indexOfObject:title];
            [myTabbar selectTitleIndex:index];
        }];
    } else {
        _operateView.selectTitle = _selectString;
        [_operateView showView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
