//
//  BottomScrollerSuperView.m
//  THTabarDemo
//
//  Created by mac on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "BottomScrollerSuperView.h"

//#define ButtomCONTENTSIZEX [UIScreen mainScreen].bounds.size.width
#define ButtomCONTENTSIZEX self.frame.size.width
#define ButtomBUTTONGAP 20
#define ButtomPOSITION (int)(scrollView.contentOffset.x/ButtomCONTENTSIZEX)

@interface BottomScrollerSuperView()
// 用于记录子控制器view的frame，用于 scrollView 上的展示的位置
@property (nonatomic, strong) NSMutableArray *childViewFrames;
// 用于缓存加载过的控制器
@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) BottomView *selectView;
@end

@implementation BottomScrollerSuperView {
    BOOL _isScroll;//!< 是否是滚动
}
@synthesize viewNameArray;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.pagingEnabled = YES;
        self.userInteractionEnabled = YES;
        self.bounces = NO;//!< 回弹效果
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        _childViewFrames = [NSMutableArray array];//!< 记录所有视图frame
        _memCache = [[NSCache alloc] init];//!< 初始化缓存
        
        _isScroll = NO;//!< 是否是滚动
    }
    return self;
}
- (void)initWithViews {
    [_memCache removeAllObjects];
    
    for(int i = 0; i < [_viewArray count]; i++) {
        BottomView *myView = (BottomView *)[_viewArray objectAtIndex:i];
        CGRect frame = CGRectMake(ButtomCONTENTSIZEX*i, 0, ButtomCONTENTSIZEX, self.bounds.size.height);
        myView.frame = frame;
        [myView setBottomDict:[viewNameArray objectAtIndex:i]];
        myView.tag = 200 + i;
        myView.superController = _superDelegate;
        if (i == 0) {
            myView.isShow = YES;
            [myView loadViewData];
            _selectView = myView;//!< 当前视图
            if ([_bottomDelegate respondsToSelector:@selector(selectScrollView:andOldView:)]) {
                [_bottomDelegate selectScrollView:myView andOldView:nil];
            }
            [self addSubview:myView];
            [_memCache setObject:myView forKey:@(i)];
        }
        if (i == 1) {
            myView.isShow = YES;
            [myView loadViewData];
            [self addSubview:myView];
            [_memCache setObject:myView forKey:@(i)];
        }
        [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
    
    self.contentSize = CGSizeMake(ButtomCONTENTSIZEX*[_viewArray count], CGRectGetHeight(self.bounds));
}
#pragma mark - scrollerView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isScroll = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isScroll) {//!< 滚动时响应标签滚动
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        if (contentOffsetX < 0) {
            contentOffsetX = 0;
        }
        if (contentOffsetX > scrollView.contentSize.width - self.bounds.size.width) {
            contentOffsetX = scrollView.contentSize.width - self.bounds.size.width;
        }
        CGFloat rate = contentOffsetX / self.bounds.size.width;
        if (self.menuView) {
            [self.menuView slideMenuAtProgress:rate];
        }
    }
    int currentPage = (int)self.contentOffset.x / self.bounds.size.width;
    int start = currentPage == 0 ? currentPage : (currentPage - 1);
    int end = (currentPage == self.viewArray.count - 1) ? currentPage : (currentPage + 1);
    for (int i = start; i <= end; i++) {
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        BottomView *vi = [_memCache objectForKey:@(i)];
        if ([self isInScreen:frame]) {
            if (vi == nil) {
                [self initializedControllerWithIndexIfNeeded:i];
            }
        } else {
            if (vi) {
                // vc不在视野中且存在，移除他
                [self removeViewControllerIndex:i];
            }
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self banckScrollViewDelegate];
    [self loadData];
    _isScroll = NO;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self banckScrollViewDelegate];
    [self loadData];
}
#pragma mark - 功能方法
- (void)loadData {
    int currentPage = (int)self.contentOffset.x / self.bounds.size.width;
    int start = currentPage == 0 ? currentPage : (currentPage - 1);
    int end = (currentPage == _viewArray.count - 1) ? currentPage : (currentPage + 1);
    for (int i = start; i <= end; i++) {
        [self initializedControllerWithIndexIfNeeded:i];
    }
    _selectView = (BottomView *)[_viewArray objectAtIndex:currentPage];//!< 记录当前视图
}
// 创建或从缓存中获取控制器并添加到视图上
- (void)initializedControllerWithIndexIfNeeded:(NSInteger)index {
    // 先从 cache 中取
    BottomView *vi = [self.memCache objectForKey:@(index)];
    if (vi) {
        // cache 中存在，添加到 scrollView 上，并放入display
        [self addSubview:vi];
    } else {
        // cache 中也不存在，创建并添加到display
        [self addViewControllerAtIndex:(int)index];
    }
}
// 创建并添加子控制器
- (void)addViewControllerAtIndex:(int)index {
    BottomView *myView = (BottomView *)[_viewArray objectAtIndex:index];
    myView.frame = [[_childViewFrames objectAtIndex:index] CGRectValue];
    [myView setBottomDict:[viewNameArray objectAtIndex:index]];
    myView.tag = 200 + index;
    myView.isShow = YES;
    myView.superController = _superDelegate;
    [myView loadViewData];
    [self addSubview:myView];
    [_memCache setObject:myView forKey:@(index)];
}
- (BOOL)isInScreen:(CGRect)frame {
    CGFloat x = frame.origin.x;
    CGFloat ScreenWidth = self.frame.size.width;
    
    CGFloat contentOffsetX = self.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x-contentOffsetX < ScreenWidth) {
        return YES;
    } else {
        return NO;
    }
}
// 移除控制器，且从display中移除
- (void)removeViewControllerIndex:(NSInteger)index {
    BottomView *vi = [self viewWithTag:index + 200];
    [vi removeFromSuperview];
}
- (void)banckScrollViewDelegate {
    CGFloat pageWidth = self.frame.size.width;
    int page = floor((self.contentOffset.x - pageWidth/viewNameArray.count)/pageWidth) + 1;
    
//    BottomView *myView = (BottomView *)[self viewWithTag:page + 200];
    BottomView *myView = [_memCache objectForKey:@(page)];
    if ([_bottomDelegate respondsToSelector:@selector(selectScrollView:andOldView:)]) {
        [_bottomDelegate selectScrollView:myView andOldView:_selectView];
    }
}





- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // iOS横向滚动的scrollView和系统pop手势返回冲突的解决办法:     http://blog.csdn.net/hjaycee/article/details/49279951
    
    // 兼容系统pop手势 / FDFullscreenPopGesture / 如有自定义手势，需自行在此处判断
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //MARK: UITableViewCell 自定义手势可能要在此处自行定义
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UITableViewWrapperView")] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
