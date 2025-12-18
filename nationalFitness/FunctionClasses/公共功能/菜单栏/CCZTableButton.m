//
//  CCZTableButton.m
//  CCZTableButton
//
//  Created by 金峰 on 2016/11/19.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import "CCZTableButton.h"
#import "CCZBringImageTableViewCell.h"

//#define CCZROW_HEIGHT    30
#define CCZARROW_VHEIGHT 10 // 箭头垂直高度

NSTimeInterval const duration = 0.15;

typedef void(^indexHandle)(NSUInteger, NSString *);


@interface CCZTableButton ()
<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray *itemsArr;
@property (nonatomic, copy)   indexHandle handle;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, copy)   NSString *exceptItemName;
@property (nonatomic, assign) BOOL isMutableTable;

@end

@implementation CCZTableButton{
    
    NSInteger _selectedIndex;
    BOOL _selected;
    
    CGFloat cellHeight;
    
}

- (UITapGestureRecognizer *)tap {
    
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickBackground)];
        
        [self.backgroundView addGestureRecognizer:_tap];
    }
    return _tap;
    
}

- (CAShapeLayer *)arrowLayer {
    if (!_arrowLayer) {
        
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.fillColor = [UIColor whiteColor].CGColor;
        _arrowLayer.fillColor = UIColorFromRGB(0xd8e3f5).CGColor;
        [self.layer addSublayer:_arrowLayer];
    }
    return _arrowLayer;
    
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _backgroundView.backgroundColor = [UIColor colorWithHue:0
                                                    saturation:0
                                                    brightness:0 alpha:0.1];
    }
    return _backgroundView;
}

#pragma mark -- init

- (instancetype)initWithFrame:(CGRect)frame CellHeight:(CGFloat)height{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.topHeight = frame.origin.y;
    //cell的高度
    cellHeight = height;
    _size = frame.size;
    //小三角
    //    self.offsetXOfArrow = 0;
    self.wannaToClickTempToDissmiss = YES;
    self.layer.anchorPoint = CGPointMake(0.5, 0);
    
    [self tableButtonSetting];
    return self;
}

-(void)AfterClickDismiss:(AfterDismiss)block{
    if (self.afterDismissBlock != block) {
        self.afterDismissBlock = nil;
        self.afterDismissBlock = block;
    }
}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (!self) {
//        return nil;
//    }
//    
//    _size = frame.size;
//    //小三角
////    self.offsetXOfArrow = 0;
//    self.wannaToClickTempToDissmiss = YES;
//    self.layer.anchorPoint = CGPointMake(0.5, 0);
//    
//    [self tableButtonSetting];
//    return self;
//}

- (void)tableButtonSetting {
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(2, CCZARROW_VHEIGHT, _size.width - 4, _size.height - CCZARROW_VHEIGHT)];
    NSLog(@"%f",_size.height);
    //self.mainTableView.backgroundColor = [UIColor whiteColor];
    self.mainTableView.backgroundColor = [UIColor clearColor];
    [self.mainTableView setSeparatorColor:UIColorFromRGB(0x6982bd)];
    //[self.mainTableView setSeparatorColor:[UIColor redColor]];
//    self.mainTableView.separatorInset = UIEdgeInsetsMake(0,300, 0, 300); //在xib中设置距离左右距离
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    self.mainTableView.bounces = NO;
//    self.mainTableView.pagingEnabled = YES;
    self.mainTableView.layer.cornerRadius = 3;
//    self.mainTableView.scrollEnabled = NO;
//    self.mainTableView.clipsToBounds = YES;
    
    //设置边框的颜色
    [self.mainTableView.layer setBorderColor:UIColorFromRGB(0x6982bd).CGColor];
    //[self.mainTableView.layer setBorderColor:[UIColor redColor].CGColor];
    //设置边框的粗细
    [self.mainTableView.layer setBorderWidth:1.0];
    
    [self addSubview:self.mainTableView];
}

- (void)addItems:(NSArray<NSString *> *)itemsName {
    self.itemsArr = [NSMutableArray arrayWithArray:itemsName];
    self.isMutableTable = NO;
    
    [self updateTableAndFrame];
}

- (void)addItems:(NSArray<NSString *> *)itemsName exceptItem:(NSString *)itemName {
    
    self.itemsArr = [NSMutableArray arrayWithArray:itemsName];
    
    if ([itemsName containsObject:itemName]) {
        [self.itemsArr removeObject:itemName];
    }
    
    self.exceptItemName = itemName;
    self.isMutableTable = YES;
    
    [self updateTableAndFrame];
}

- (void)updateTableAndFrame {
    // 重新布局tableview
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _size.width, cellHeight * self.itemsArr.count + CCZARROW_VHEIGHT);
    self.mainTableView.frame = CGRectMake(0, CCZARROW_VHEIGHT, _size.width, cellHeight * self.itemsArr.count);
    
    if (cellHeight * self.itemsArr.count > SCREEN_HEIGHT - self.topHeight) {
        self.mainTableView.frame = CGRectMake(0, CCZARROW_VHEIGHT, _size.width, SCREEN_HEIGHT - self.topHeight - 64 + 49);
    }
    
    [self.mainTableView reloadData];
    
    self.transform = CGAffineTransformMakeScale(0, 0);
}

- (void)selectedAtIndexHandle:(void (^)(NSUInteger, NSString *))indexHandle {
    if (indexHandle) {
        self.handle = indexHandle;
    }
}

- (void)didClickBackground {
    [self dismiss];
    if (self.afterDismissBlock) {
        self.afterDismissBlock(YES);
    }
}

#pragma mark -- set
//相对于弹窗中间 向右偏移
- (void)setOffsetXOfArrow:(CGFloat)offsetXOfArrow {
    _offsetXOfArrow = offsetXOfArrow;
    
    self.layer.anchorPoint = CGPointMake(0.5 + offsetXOfArrow / _size.width, 0);
    self.frame = CGRectMake(self.frame.origin.x + offsetXOfArrow, self.frame.origin.y, _size.width, self.frame.size.height);
    
    CGFloat l_ = CCZARROW_VHEIGHT / tan(M_PI / 3);
    CGPoint p1 = CGPointMake(_size.width / 2 + offsetXOfArrow, 0);
    CGPoint p2 = CGPointMake(p1.x - l_, p1.y + CCZARROW_VHEIGHT);
    CGPoint p3 = CGPointMake(p1.x + l_, p1.y + CCZARROW_VHEIGHT);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    
    self.arrowLayer.path = path.CGPath;
}

- (void)setWannaToClickTempToDissmiss:(BOOL)wannaToClickTempToDissmiss {
    _wannaToClickTempToDissmiss = wannaToClickTempToDissmiss;
    
    if (_wannaToClickTempToDissmiss && !self.tap) {
        [self.backgroundView addGestureRecognizer:self.tap];
    }
    if (!_wannaToClickTempToDissmiss && self.tap) {
        [self.backgroundView removeGestureRecognizer:self.tap];
    }
}

#pragma mark -- tag

- (void)show {
    
    NSEnumerator *windowEnnumtor = [UIApplication sharedApplication].windows.reverseObjectEnumerator;
    for (UIWindow *window in windowEnnumtor) {
        BOOL isOnMainScreen = window.screen == [UIScreen mainScreen];
        BOOL isVisible      = !window.hidden && window.alpha > 0;
        BOOL isLevelNormal  = window.windowLevel == UIWindowLevelNormal;
        
        if (isOnMainScreen && isVisible && isLevelNormal) {
            [window addSubview:self.backgroundView];
            [window addSubview:self];
            [self showAnimation];
        }
    }
}

- (void)dismiss {
    [self dismissAnimation];
}

- (void)showAnimation {
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)dismissAnimation {
    
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];

}

#pragma mark -- UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.TitleImageArr.count > 0) {
        static NSString* cellIdentifier = @"CCZBringImageTableViewCell";
        CCZBringImageTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"CCZBringImageTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.titleLabel.text = self.itemsArr[indexPath.row];
        cell.titleLabel.font = [UIFont systemFontOfSize:15];
        cell.titleImageV.image = [UIImage imageNamed:self.TitleImageArr[indexPath.row]];
        
        cell.backgroundColor = self.CellBackColor;
         cell.titleLabel.textColor = self.CellTextColor;
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        return cell;
    }else{
        NSString *cellId = @"ccz_cell_id";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        cell.textLabel.textColor = [UIColor blackColor];
        if (_selectedIndex == indexPath.row && _selected) {
            //        cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textColor = MainColor;
        }
        cell.textLabel.text = self.itemsArr[indexPath.row];
        //判断TitleImageArr数组是否有值，有值代表需要有图片
        if (self.TitleImageArr.count > 0) {
            cell.imageView.image = [UIImage imageNamed:self.TitleImageArr[indexPath.row]];
        }
        cell.backgroundColor = self.CellBackColor;
        cell.textLabel.textColor = self.CellTextColor;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    if (self.handle) {
        self.handle(indexPath.row, self.itemsArr[indexPath.row]);
    }
    
//    if (self.isMutableTable) {
//        NSString *selString = self.itemsArr[indexPath.row];
//        [self.itemsArr removeObjectAtIndex:indexPath.row];
//        [self.itemsArr insertObject:self.exceptItemName atIndex:indexPath.row];
//        self.exceptItemName = selString;
//        [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }
    _selected = YES;
    _selectedIndex = indexPath.row;
    [self.mainTableView reloadData];
    [self dismiss];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"");
}

@end
