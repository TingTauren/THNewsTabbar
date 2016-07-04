//
//  THTopMenuView.m
//  THTabarDemo
//
//  Created by mac on 16/5/13.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "THTopMenuView.h"

static NSInteger const THMenuItemTagOffset = 6250;

@interface THTopMenuView ()<THTopMenuItemDelegate>
@property (nonatomic, strong) NSMutableArray *frames;//!< itemFrames
@property (nonatomic, strong) NSMutableArray *Items;//!< items
@property (nonatomic, weak) THTopMenuItem *selItem;//!< 选中的按钮
@property (nonatomic, assign) CGFloat selfHeight;//!< 高度
@property (nonatomic, strong) UIImageView *shadowImage;//!< 选择条
@end

@implementation THTopMenuView

- (NSMutableArray *)frames {
    if (_frames == nil) {
        _frames = [NSMutableArray array];
    }
    return _frames;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
//        self.backgroundColor = [UIColor grayColor];
        self.pagingEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.normalColor = [UIColor blackColor];
        self.selectedColor = [UIColor blackColor];
        self.normalSize = 15.0;
        self.selectedSize = 15.0;
        self.itemMargin = 10;
        _selfHeight = self.bounds.size.height;
        
        self.buttonWithArray = [[NSMutableArray alloc] init];
        _Items = [NSMutableArray array];
    }
    return self;
}
- (void)setTitleArray:(NSArray *)titleArray {//!< 设置标题数组
    _titleArray = titleArray;
}
- (void)initWithTitleButtons{//!< 加载title
    [self calculateItemFrames];//!< 获取标题宽度
    
    _shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake([self.frames[0] CGRectValue].origin.x - self.itemMargin, [self.frames[0] CGRectValue].size.height-1.5, [self.frames[0] CGRectValue].size.width + self.itemMargin*2, 1.5)];
    [self addSubview:_shadowImage];
    [_shadowImage setBackgroundColor:self.selectedColor];
    
    for (int i = 0; i < _titleArray.count; i++) {
        CGRect frame = [self.frames[i] CGRectValue];
        THTopMenuItem *item = [[THTopMenuItem alloc] initWithFrame:frame];
        item.tag = (i+THMenuItemTagOffset);
        item.delegate = self;
        item.text = [[_titleArray objectAtIndex:i] objectForKey:@"Name"];
        item.textAlignment = NSTextAlignmentCenter;
        item.textColor = self.normalColor;
        item.userInteractionEnabled = YES;
        if (self.fontName) {
            item.font = [UIFont fontWithName:self.fontName size:self.selectedSize];
        } else {
            item.font = [UIFont boldSystemFontOfSize:self.selectedSize];
        }
        item.backgroundColor = [UIColor clearColor];
        item.normalSize    = self.normalSize;
        item.selectedSize  = self.selectedSize;
        item.normalColor   = self.normalColor;
        item.selectedColor = self.selectedColor;
        if (i == 0) {
            [item selectedItemWithoutAnimation];
            self.selItem = item;
        } else {
            [item deselectedItemWithoutAnimation];
        }
        [self addSubview:item];
        [_Items addObject:item];
        
        [self.buttonWithArray addObject:[NSValue valueWithCGRect:frame]];
    }

}
// 计算所有item的frame值，主要是为了适配所有item的宽度之和小于屏幕宽的情况
// 这里与后面的 `-addItems` 做了重复的操作，并不是很合理
- (void)calculateItemFrames {
    CGFloat X = self.itemMargin;
    for (int i = 0,count = (int)_titleArray.count; i < count; i++) {
        NSString *titleText = [[_titleArray objectAtIndex:i] objectForKey:@"Name"];
        CGSize titleSize = [self boundingRectWithSizeOne:self.bounds.size font:[UIFont systemFontOfSize:self.selectedSize] andStr:titleText];
        CGRect Frame = CGRectMake(X, 0, titleSize.width+10, _selfHeight);
        X += CGRectGetWidth(Frame) + self.itemMargin;
        [self.frames addObject:[NSValue valueWithCGRect:Frame]];
    }
    self.contentSize = CGSizeMake(X, _selfHeight);
}

- (void)selectItems:(NSInteger) index {//!< 选择某项
    THTopMenuItem *item = [_Items objectAtIndex:index];
    [self didPressedMenuItem:item];
}

#pragma mark - Menu item delegate
- (void)didPressedMenuItem:(THTopMenuItem *)menuItem {
    if (self.selItem == menuItem) return;
    
    CGFloat progress = menuItem.tag - THMenuItemTagOffset;
    CGRect progressFrame = [_frames[(int)progress] CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect shadowFrame = _shadowImage.frame;
        shadowFrame.origin.x = progressFrame.origin.x - self.itemMargin;
        shadowFrame.size.width = progressFrame.size.width + self.itemMargin*2;
        [_shadowImage setFrame:shadowFrame];
    } completion:^(BOOL finished) {
        if(finished) {
            if ([_thTopMenuDelegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
                [_thTopMenuDelegate menuView:self didSelesctedIndex:menuItem.tag - THMenuItemTagOffset currentIndex:self.selItem.tag - THMenuItemTagOffset];
            }
        }
    }];
    
    //!< 改变item选中状态
    menuItem.selected = YES;
    self.selItem.selected = NO;
    self.selItem = menuItem;
    
    [self refreshContenOffset];//!< 让item位于中间
}
// 让选中的item位于中间
- (void)refreshContenOffset {
    CGRect frame = self.selItem.frame;
    CGFloat itemX = frame.origin.x;
    CGFloat width = self.frame.size.width;
    CGSize contentSize = self.contentSize;
    if (itemX > width/2) {
        CGFloat targetX;
        if ((contentSize.width-itemX) <= width/2) {
            targetX = contentSize.width - width;
        } else {
            targetX = frame.origin.x - width/2 + frame.size.width/2;
        }
        // 应该有更好的解决方法
        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self setContentOffset:CGPointMake(targetX, 0) animated:YES];
    } else {
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    // MARK: 暂时解决多选中问题 (需要复现并找到根本原因 see#67)
    [self deselectedItemsIfNeeded];
}
- (void)deselectedItemsIfNeeded {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[THTopMenuItem class]]) {
            THTopMenuItem *item = (THTopMenuItem *)obj;
            if (item != self.selItem) {
                [item deselectedItemWithoutAnimation];
            }
        }
    }];
}
- (void)slideMenuAtProgress:(CGFloat)progress {
    if (_shadowImage) {
        int index = (int)progress;
        index = (index <= self.buttonWithArray.count - 1) ? index : (int)self.buttonWithArray.count - 1;
        CGFloat rate = progress - index;
        CGRect currentFrame = [self.buttonWithArray[index] CGRectValue];
        CGFloat currentWidth = currentFrame.size.width + self.itemMargin*2;//!< 当前item宽度
        int nextIndex = index + 1 < self.buttonWithArray.count ? index + 1 : index;
        CGFloat nextWidth = [self.buttonWithArray[nextIndex] CGRectValue].size.width + self.itemMargin*2;
        CGFloat currentX = currentFrame.origin.x - self.itemMargin;
        CGFloat nextX = [self.buttonWithArray[nextIndex] CGRectValue].origin.x - self.itemMargin;
        CGFloat startX = currentX + (nextX - currentX) * rate;
        
        CGRect shadowFrame = _shadowImage.frame;
        shadowFrame.origin.x = startX;
        shadowFrame.size.width = currentWidth + (nextWidth - currentWidth)*rate;
        [_shadowImage setFrame:shadowFrame];
    }
    NSInteger tag = (NSInteger)progress + THMenuItemTagOffset;
    CGFloat rate = progress - tag + THMenuItemTagOffset;
    THTopMenuItem *currentItem = (THTopMenuItem *)[self viewWithTag:tag];
    THTopMenuItem *nextItem = (THTopMenuItem *)[self viewWithTag:tag+1];
    if (rate == 0.0) {
        rate = 1.0;
        [self.selItem deselectedItemWithoutAnimation];
        self.selItem = currentItem;
        [self.selItem selectedItemWithoutAnimation];
        [self refreshContenOffset];
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}






































/**
 *  @brief  根据字符串的宽(或高)和字体的大小计算字符串的size
 *  @param  size 给定字符串的宽或高
 *  @param  font 字体属性
 *  @return 字符串的宽和高
 */
- (CGSize)boundingRectWithSizeOne:(CGSize)size font:(UIFont *)font andStr:(NSString *) str {
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    CGSize reSize = [str boundingRectWithSize:size
                                      options:
                     NSStringDrawingTruncatesLastVisibleLine |
                     NSStringDrawingUsesLineFragmentOrigin |
                     NSStringDrawingUsesFontLeading
                                   attributes:attribute
                                      context:nil].size;
    if (reSize.width <= 0 && reSize.height <= 0) {
        reSize = size;
    }
    return reSize;
}

/**
 *  @brief  根据字符串字体的大小(和最大宽度)计算字符串的size
 *  @param  size        给定字符串的(最小)高
 *  @param  font        字体属性
 *  @param  maxWidth    字符串最大的宽度
 *  @return 字符串的宽和高
 */
- (CGSize)boundingRectWithSizeOne:(CGSize)size font:(UIFont *)font maxWidth:(CGFloat)maxWidth andStr:(NSString *) str {
    NSArray *array = [str componentsSeparatedByString:@"/n"];
    array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *str1 = obj1;
        NSString *str2 = obj2;
        
        NSComparisonResult result;
        
        if (str1.length > str2.length)
        {
            result = NSOrderedAscending;
        }
        else if (str1.length < str2.length)
        {
            result = NSOrderedDescending;
        }
        else
        {
            result = NSOrderedSame;
        }
        
        return result;
    }];
    
    CGSize reSize = [self boundingRectWithSizeOne:size font:font andStr:array[0]];
    
    if (reSize.width > maxWidth)
    {
        reSize = [self boundingRectWithSizeOne:CGSizeMake(maxWidth, MAXFLOAT) font:font andStr:str];
    }
    else
    {
        reSize = [self boundingRectWithSizeOne:CGSizeMake(reSize.width, MAXFLOAT) font:font andStr:str];
    }
    
    return reSize;
}

@end
