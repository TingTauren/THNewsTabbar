//
//  OperateView.m
//  THNewsTabbar
//
//  Created by mac on 16/6/21.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "OperateView.h"
#import "UIColor+changeImage.h"
#import "TagsAddViewCell.h"

#define collectionCellHeight 50.0

@interface OperateView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *operateDataArr;//!< 操作数据

@property (nonatomic, strong) UIScrollView *backScrollView;//!< 背景滚动视图
@property (nonatomic, strong) UIButton *editButton;//!< 编辑
@property (nonatomic, strong) UIButton *closedButton;//!< 关闭
@property (nonatomic, strong) UILabel *topLable;//!< 顶部标签
@property (nonatomic, strong) UICollectionView *collectionView;//!< 标签视图

@property (nonatomic, strong) UIImageView *selectImageView;//!< 截图

@property (nonatomic, strong) UILabel *downLable;//!< 底部标签
@property (nonatomic, strong) UICollectionView *collectionViewDown;//!< 底部标签视图

@end

@implementation OperateView {
    CGRect _selfRect;//!< 显示rect
    
    NSIndexPath *_longIndex;//!< 长按选中index
    NSIndexPath *_currentIndexPath;//!< 操作选项
    BOOL _isEdit;//!< 是否编辑
}
- (void)setShowDataArr:(NSMutableArray *)showDataArr {//!< 顶部数据
    _showDataArr = showDataArr;
    
    _operateDataArr = [self setShowDataArrwidthModel];
    
    [self reloadCollectionFrame];//!< 改变frame
    [_collectionView reloadData];
    [_collectionViewDown reloadData];
}
- (void)setNotEditableArr:(NSMutableArray *)notEditableArr {//!< 不可编辑数据
    _notEditableArr = notEditableArr;
    
    if (_showDataArr) {
        [_operateDataArr removeAllObjects];
        _operateDataArr = [self setShowDataArrwidthModel];
    }
}
- (void)setSelectTitle:(NSString *)selectTitle {
    _selectTitle = selectTitle;
    
    [self closeAllModelSelect];//!< 清空所以所选
    for (TagsAddViewModel *model in _operateDataArr) {
        if ([model.TAVM_title isEqualToString:selectTitle]) {
            model.TAVM_isSelect = YES;
        }
    }
    [_collectionView reloadData];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selfRect = frame;
        _showDataArr = [NSMutableArray array];//!< 顶部显示数据
        _downDataArr = [NSMutableArray array];//!< 底部显示数据
        _operateDataArr = [NSMutableArray array];//!< 操作数据
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_backScrollView setContentSize:CGSizeMake(frame.size.width, frame.size.height+0.5)];
        [_backScrollView setShowsVerticalScrollIndicator:YES];
        [_backScrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_backScrollView];
        
        [self createView];//!< 创建视图
        [self createDownView];//!< 创建底部视图
    }
    return self;
}
#pragma mark - 创建方法
- (void)createView {
    _topLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (_selfRect.size.width-20)*2/3, 40)];
    [_topLable setText:@"自定义"];
    [_topLable setFont:[UIFont boldSystemFontOfSize:18]];
    [_backScrollView addSubview:_topLable];
    
    CGFloat width = ((_selfRect.size.width-20)*1/3 - 20)/2;
    _editButton = [self createButton:CGRectMake(CGRectGetMaxX(_topLable.frame)+10, 15, width, 30)];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_editButton setBackgroundImage:[UIColor createImageWithColor:[[UIColor redColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    [_backScrollView addSubview:_editButton];
    [_editButton addTarget:self action:@selector(editSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _closedButton = [self createButton:CGRectMake(CGRectGetMaxX(_editButton.frame)+10, 15, width, 30)];
    [_closedButton setTitle:@"关闭" forState:UIControlStateNormal];
    [_closedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_closedButton setBackgroundImage:[UIColor createImageWithColor:[[UIColor redColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    [_backScrollView addSubview:_closedButton];
    [_closedButton addTarget:self action:@selector(closedClick) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 5;
    CGSize itemSize = CGSizeMake((_selfRect.size.width-40.0)/3.0-0.05, collectionCellHeight);
    flowLayout.itemSize = itemSize;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    
    int countHeight = (int)_operateDataArr.count/3 + (_operateDataArr.count%3 > 0 ? 1 : 0);
    CGFloat collectionHeight = _operateDataArr.count > 0 ? countHeight * collectionCellHeight + (countHeight+1)*5 : 0;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_topLable.frame), _selfRect.size.width, collectionHeight) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.bounces  = YES;
    _collectionView.scrollEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tag = 1;
    [_backScrollView addSubview:_collectionView];
    // 注册 Cell
    [_collectionView registerClass:[TagsAddViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureClick:)];
    [_collectionView addGestureRecognizer:longGesture];
}
- (void)createDownView {//!< 创建底部标签视图
    _downLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_topLable.frame), CGRectGetMaxY(_collectionView.frame)+10, CGRectGetWidth(self.frame)-20, 40)];//!< 底部标签
    [_downLable setText:@"我的圈子"];
    [_downLable setFont:[UIFont boldSystemFontOfSize:18]];
    [_backScrollView addSubview:_downLable];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 5;
    CGSize itemSize = CGSizeMake((_selfRect.size.width-40.0)/3.0-0.05, collectionCellHeight);
    flowLayout.itemSize = itemSize;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    
    int countHeight = (int)_downDataArr.count/3 + (_downDataArr.count%3 > 0 ? 1 : 0);
    CGFloat collectionHeight = _downDataArr.count > 0 ? countHeight * collectionCellHeight + (countHeight+1)*5 : 0;
    _collectionViewDown = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_downLable.frame), _selfRect.size.width, collectionHeight) collectionViewLayout:flowLayout];//!< 底部标签视图
    _collectionViewDown.backgroundColor = [UIColor clearColor];
    _collectionViewDown.bounces  = YES;
    _collectionViewDown.scrollEnabled = YES;
    _collectionViewDown.showsHorizontalScrollIndicator = NO;
    _collectionViewDown.alwaysBounceVertical = YES;
    _collectionViewDown.dataSource = self;
    _collectionViewDown.delegate = self;
    _collectionViewDown.tag = 2;
    [_backScrollView addSubview:_collectionViewDown];
    // 注册 Cell
    [_collectionViewDown registerClass:[TagsAddViewCell class] forCellWithReuseIdentifier:@"collectionDownCell"];
}
#pragma mark - collectionDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1) {
        return _operateDataArr.count;
    } else {
        return _downDataArr.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
        static NSString *acell = @"collectionViewCell";
        TagsAddViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:acell forIndexPath:indexPath];
        if (!cell) {
            cell = [[TagsAddViewCell alloc] init];
        }
        
        [cell setTAVC_Model:[_operateDataArr objectAtIndex:indexPath.row]];
        
        return cell;
    } else {
        static NSString *acell = @"collectionDownCell";
        TagsAddViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:acell forIndexPath:indexPath];
        if (!cell) {
            cell = [[TagsAddViewCell alloc] init];
        }
        
        [cell setTAVC_Model:[_downDataArr objectAtIndex:indexPath.row]];
        cell.TAVC_deleteIcon.hidden = YES;
        
        return cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
        if (_isEdit) {
            if ([self selectIsEditCell:indexPath.row]) {
                return;
            }
            
            TagsAddViewModel *removeData = [_operateDataArr objectAtIndex:indexPath.row];
            [removeData RevertData];//!< 还原数据
            [_downDataArr addObject:removeData];
            [_collectionViewDown reloadData];
            
            [_operateDataArr removeObjectAtIndex:indexPath.row];
            [_collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
            
            [self reloadCollectionFrame];//!< 改变frame
        } else {//!< 选择
            [self closeAllModelSelect];//!< 清空所有选中
            TagsAddViewModel *selectModel = [_operateDataArr objectAtIndex:indexPath.row];
            selectModel.TAVM_isSelect = YES;
            [_collectionView reloadData];
            
            [self setSelfAnimation:NO];
            
            if (self.selectClickBolk) {
                _selectClickBolk(self,selectModel.TAVM_title);
            }
        }
    } else {
        TagsAddViewModel *addData = [_downDataArr objectAtIndex:indexPath.row];
        [_operateDataArr addObject:[self changeModel:addData andIsEdit:_isEdit]];
        [_collectionView reloadData];
        
        [_downDataArr removeObjectAtIndex:indexPath.row];
        [_collectionViewDown deleteItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
        
        [self reloadCollectionFrame];//!< 改变frame
    }
}
#pragma mark - set方法
- (void)setIsAnimation:(BOOL)isAnimation {
    _isAnimation = isAnimation;
    
    [self hiddenView:YES];//!< 显示控件
    [self setSelfAnimation:YES];//!< 显示视图
}

#pragma mark - 点击方法
- (void)editSelectClick:(UIButton *) sender {
    sender.selected = !sender.isSelected;
    
    if (sender.isSelected) {//!< 编辑状态
        [_editButton setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    _isEdit = sender.isSelected;
    [self setModelIsEdit:_isEdit];
}
- (void)closedClick {
    if (self.closedClickBolk) {
        _closedClickBolk(self,[self selectTilte]);
    }
    if (_isEdit) {//!< 是否编辑
        [self editSelectClick:_editButton];//!< 点击编辑按钮
    }
    [self setSelfAnimation:NO];//!< 显示视图
}
- (void)longGestureClick:(UIGestureRecognizer *) gesture {
    if (!_isEdit) {//!< 非编辑状态
        return;
    }
    CGPoint location = [gesture locationInView:_collectionView];
    // 当手指的位置不在collectionView的cell范围内时为nil
    NSIndexPath *notSureIndexPath = [_collectionView indexPathForItemAtPoint:location];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {//!< 长按开始
        if (notSureIndexPath != nil) {
            if ([self selectIsEditCell:notSureIndexPath.row]) {
                return;
            }
            _longIndex = notSureIndexPath;
            _currentIndexPath = notSureIndexPath;
            
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:_currentIndexPath];
            cell.alpha = 0.0;
            
            [self setShowImageView:cell];
            [self addSubview:_selectImageView];
            
            [self hiddenDownView:YES];//!< 是否隐藏底部视图
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {//!< 交换
        [self setImageViewFrame:CGRectMake(location.x - _selectImageView.frame.size.width/2, location.y - _selectImageView.frame.size.height/2, _selectImageView.frame.size.width, _selectImageView.frame.size.height)];
        
        if (notSureIndexPath != nil) {
            if ([self selectIsEditCell:notSureIndexPath.row]) {
                return;
            }
            NSIndexPath *newIndexPath = notSureIndexPath;
            NSIndexPath *oldIndexPath = _currentIndexPath;
            if (newIndexPath != oldIndexPath && newIndexPath.section == oldIndexPath.section ){// 只在同一组中移动
                [_collectionView moveItemAtIndexPath:oldIndexPath toIndexPath:newIndexPath];// 更新dataSource
                
                UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:newIndexPath];
                cell.alpha = 0.0;
                
                _currentIndexPath = newIndexPath;
            }
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {//!< 结束
        NSIndexPath *oldIndexPath = _currentIndexPath;
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:oldIndexPath];
        if (oldIndexPath != nil) {
            id selctObject = [_operateDataArr objectAtIndex:_longIndex.row];
            [_operateDataArr removeObjectAtIndex:_longIndex.row];
            [_operateDataArr insertObject:selctObject atIndex:oldIndexPath.row];
            
            [UIView animateWithDuration:0.25 animations:^{
                _selectImageView.transform = CGAffineTransformIdentity;
                _selectImageView.frame = CGRectMake(cell.frame.origin.x+CGRectGetMinX(_collectionView.frame), cell.frame.origin.y+CGRectGetMinY(_collectionView.frame), cell.frame.size.width, cell.frame.size.height);
            } completion:^(BOOL finished) {
                [_selectImageView removeFromSuperview];
                cell.alpha = 1.0;
                [self hiddenDownView:NO];//!< 是否隐藏底部视图
            }];
        }
    }
}

#pragma mark - 功能方法
- (void)setSelfAnimation:(BOOL) isShow {//!< 动画
    if (isShow) {//!< 显示
        self.hidden = NO;
        if (_isAnimation) {
            self.frame = CGRectMake(_selfRect.origin.x, _selfRect.origin.y, _selfRect.size.width, 0);
            [UIView animateWithDuration:0.4 animations:^{
                self.frame = _selfRect;
            } completion:^(BOOL finished) {
                [self hiddenView:NO];//!< 显示控件
            }];
        } else {
            [self hiddenView:NO];//!< 显示控件
        }
    } else {//!< 隐藏
        if (_isAnimation) {//!< 是否动画
            [UIView animateWithDuration:0.4 animations:^{
                CGRect rect = self.frame;
                rect.size.height = 0;
                self.frame = rect;
                
                [self hiddenView:YES];//!< 显示控件
            } completion:^(BOOL finished) {
                self.hidden = YES;
//                [self removeFromSuperview];
            }];
        } else {
            self.hidden = YES;
//            [self removeFromSuperview];
        }
    }
}
- (void)hiddenView:(BOOL) isHidden {//!< 隐藏视图
    _backScrollView.hidden = isHidden;//!< 背景滚动视图
    _editButton.hidden = isHidden;//!< 编辑
    _closedButton.hidden = isHidden;//!< 关闭
    _topLable.hidden = isHidden;//!< 顶部标签
    _collectionView.hidden = isHidden;//!< 标签视图
}
- (UIButton *)createButton:(CGRect) rect {//!< 创建按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:rect];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [UIColor redColor].CGColor;
    button.layer.cornerRadius = 2;
    button.layer.masksToBounds = YES;
    
    return button;
}
- (void)setShowImageView:(UICollectionViewCell *) cell {//!< 截取图片
    //此处的CGSizeMake是根据需要制定截取图片的宽、高；NO/YES表示是否透明
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0.0);
    //NO，YES 控制是否透明
    [cell.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _selectImageView = [[UIImageView alloc] init];
    [self setImageViewFrame:cell.frame];
    _selectImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    _selectImageView.image = image;
}
- (void)setImageViewFrame:(CGRect) rect {//!< 改变截图位置
    CGRect imageviewFrame = _selectImageView.frame;
    imageviewFrame.origin.x = rect.origin.x + CGRectGetMinX(_collectionView.frame);
    imageviewFrame.origin.y = rect.origin.y + CGRectGetMinY(_collectionView.frame);
    imageviewFrame.size.width = rect.size.width;
    imageviewFrame.size.height = rect.size.height;
    _selectImageView.frame = imageviewFrame;
}
- (NSMutableArray *)setShowDataArrwidthModel {//!< 转换数据为model
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0,count=(int)_showDataArr.count; i<count; i++) {
        TagsAddViewModel *model = [[TagsAddViewModel alloc] init];
        NSString *string = [_showDataArr objectAtIndex:i];
        model.TAVM_title = string;
        for (int j=0; j<_notEditableArr.count; j++) {
            NSString *notEditableString = [_notEditableArr objectAtIndex:j];
            if ([string isEqualToString:notEditableString]) {//!< 如果是不可操作数据
                model.TAVM_isEdit = NO;
            }
        }
        [arr addObject:model];
    }
    return arr;
}
- (void)setModelIsEdit:(BOOL) isEdit {//!< 是否显示删除按钮
    for (int i=0,count=(int)_operateDataArr.count; i<count; i++) {
        TagsAddViewModel *model = [_operateDataArr objectAtIndex:i];
        model.TAVM_isShowDelete = isEdit;
    }
    [_collectionView reloadData];
}
- (TagsAddViewModel *)changeModel:(TagsAddViewModel *) model andIsEdit:(BOOL) isEdit {//!< 改变model
    TagsAddViewModel *backModel = model;
    backModel.TAVM_isShowDelete = isEdit;
    return model;
}
- (void)reloadCollectionFrame {//!< 改变frame
    int countHeight = (int)_operateDataArr.count/3 + (_operateDataArr.count%3 > 0 ? 1 : 0);
    CGFloat collectionHeight = _operateDataArr.count > 0 ? countHeight * collectionCellHeight + (countHeight+1)*5 : 0;
    CGRect collectionFrame = _collectionView.frame;
    collectionFrame.size.height = collectionHeight;
    [UIView animateWithDuration:0.25 animations:^{
        _collectionView.frame = collectionFrame;
    }];
    
    [self reloadDownCollectionViewFrame];//!< 改变底部视图frame
}
- (void)reloadDownCollectionViewFrame {//!< 改变底部视图frame
    [UIView animateWithDuration:0.25 animations:^{
        [_downLable setFrame:CGRectMake(CGRectGetMinX(_topLable.frame), CGRectGetMaxY(_collectionView.frame)+10, CGRectGetWidth(self.frame), 40)];
    }];
    
    int countHeight = (int)_downDataArr.count/3 + (_downDataArr.count%3 > 0 ? 1 : 0);
    CGFloat collectionHeight = _downDataArr.count > 0 ? countHeight * collectionCellHeight + (countHeight+1)*5 : 0;
    CGRect collectionFrame = _collectionViewDown.frame;
    collectionFrame.origin.y = CGRectGetMaxY(_downLable.frame);
    collectionFrame.size.height = collectionHeight;
    [UIView animateWithDuration:0.25 animations:^{
        _collectionViewDown.frame = collectionFrame;
    }];
}
- (void)hiddenDownView:(BOOL) isHidden {//!< 是否隐藏底部视图
    _downLable.hidden = isHidden;
    _collectionViewDown.hidden = isHidden;
}
- (BOOL)selectIsEditCell:(NSInteger) index {
    BOOL selectIsEdit = NO;
    TagsAddViewModel *model = [_operateDataArr objectAtIndex:index];
    for (int i=0,count=(int)_notEditableArr.count; i<count; i++) {
        NSString *notString = [_notEditableArr objectAtIndex:i];
        if ([model.TAVM_title isEqualToString:notString]) {
            selectIsEdit = YES;
        }
    }
    return selectIsEdit;
}
- (NSMutableArray *)changeModelWidthString {//!< 转换model为数据
    NSMutableArray *titleArr = [NSMutableArray array];
    for (int i=0,count=(int)_operateDataArr.count; i<count; i++) {
        TagsAddViewModel *model = [_operateDataArr objectAtIndex:i];
        [titleArr addObject:model.TAVM_title];
    }
    return titleArr;
}
- (BOOL)dataIsChange {//!< 数据是否改变
    BOOL isChange = NO;
    if (_operateDataArr.count != _showDataArr.count) {
        isChange = YES;
        return isChange;
    }
    for (int i=0,count=(int)_operateDataArr.count; i<count; i++) {
        TagsAddViewModel *mode = [_operateDataArr objectAtIndex:i];
        NSString *string = [_showDataArr objectAtIndex:i];
        if (![mode.TAVM_title isEqualToString:string]) {
            isChange = YES;
            return isChange;
        }
    }
    return isChange;
}
- (NSMutableArray *)getMyOperateDataArr {//!< 获取操作后数据
    [_showDataArr removeAllObjects];
    _showDataArr = [self changeModelWidthString];//!< 重新赋值
    return [self changeModelWidthString];
}
- (void)closeAllModelSelect {//!< 清空所有选中
    for (TagsAddViewModel *model in _operateDataArr) {
        model.TAVM_isSelect = NO;
    }
}
- (NSString *)selectTilte {//!< 选中的title
    NSString *selectString = [_showDataArr objectAtIndex:0];
    for (TagsAddViewModel *model in _operateDataArr) {
        if (model.TAVM_isSelect) {
            selectString = model.TAVM_title;
        }
    }
    return selectString;
}
- (void)showView {//!< 显示视图
    [self hiddenView:YES];//!< 显示控件
    [self setSelfAnimation:YES];//!< 显示视图
}
- (void)hiddenView {//!< 隐藏视图
    [self setSelfAnimation:NO];//!< 显示视图
}

@end
