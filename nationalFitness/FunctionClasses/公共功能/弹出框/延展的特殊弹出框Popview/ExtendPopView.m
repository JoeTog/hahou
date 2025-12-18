//
//  ExtendPopView.m
//  nationalFitness
//
//  Created by 童杰 on 2017/4/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ExtendPopView.h"

//带tableview 蓝色标题的高度
#define BLUETITLEH kPLUS_SCALE_X(50)

@implementation ExtendPopView{
    
    //弹框的frame
    CGRect PopFrame_;
    
    
    NSString *_imageName;
    NSString *_message;
    BOOL isNeedCancel_;
    UILabel *messageLabel;
    UIButton *sureButton_;
    UIButton *cancelButton;
    
    
    //带tableview的
    NSArray *_CellArr;
    UITableView *tableV_;
    NSInteger index_; //选择的index 从0开始
    //记录选中的button
    UIButton *selectedBtn_;
    
    //带textfield
    UITextField *textField_;
    
    
    NSArray *cellTitleArr;
    NSArray *cellConatantArr;
    
    
    
}

#pragma mark - 带tableview 的选择弹窗
-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel CellTitleArr:(NSArray *)CellArr CellContantArr:(NSArray *)contantArr isSureBlock:(void(^)(BOOL sureBlock,NSInteger index))sureBlock ClickCellBlock:(void(^)(NSInteger index))clickCellBlock{
    if (self) {
        PopFrame_ = frame;
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self = [super initWithFrame:rect];
        if (_choseSure != sureBlock) {
            _choseSure = nil;
            _choseSure = sureBlock;
        }
        //
        if (_clickCell != clickCellBlock) {
            _clickCell = nil;
            _clickCell = clickCellBlock;
        }
        cellTitleArr = [NSArray arrayWithArray:CellArr];
        cellConatantArr = [NSArray arrayWithArray:contantArr];
        _message = message;
        _CellArr = [NSMutableArray arrayWithArray:CellArr];
        isNeedCancel_ = isNeedCancel;
        [self costomViewWithTableview];
        
    }
    return self;
}

-(void)costomViewWithTableview{
    self.backV_ = [[UIView alloc] initWithFrame:self.viewForLastBaselineLayout.bounds];
    self.backV_.backgroundColor = [UIColor clearColor];
    self.backV_.alpha = 1;
     UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    [win addSubview:self.backV_];
    
    //因为alertV的俯视图不能为友透明度 所以
    UIView *secBackV = [[UIView alloc] initWithFrame:self.viewForLastBaselineLayout.bounds];
    secBackV.backgroundColor = [UIColor blackColor];
    secBackV.alpha = 0.5;
    [self.backV_ addSubview:secBackV];
    
    UIView *alertV = [[UIView alloc] init];
    alertV.backgroundColor = [UIColor whiteColor];
    alertV.alpha = 1.0;
    ViewRadius(alertV, 20);
    [self.backV_ addSubview:alertV];
    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backV_.mas_centerX);
        make.centerY.mas_equalTo(self.backV_.mas_centerY).offset(- SCREEN_WIDTH / 4);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
    }];
    //头上蓝色背景用label实现
    UILabel *blueLabel = [UILabel new];
    blueLabel.backgroundColor = UIColorFromRGB(0x47B0EB);
    [alertV addSubview:blueLabel];
    [blueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.left.mas_equalTo(alertV_.mas_left);
        //        make.right.mas_equalTo(alertV_.mas_right);
        make.top.mas_equalTo(alertV.mas_top);
        make.left.mas_equalTo(alertV.mas_left);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, BLUETITLEH));
        
    }];
    
    //title
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = _message;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    [alertV addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(blueLabel.mas_centerX);
        make.centerY.mas_equalTo(blueLabel.mas_centerY);
        
    }];
    
    //tableview
    tableV_ = [[UITableView alloc] initWithFrame:CGRectMake(0, BLUETITLEH + GAPB, PopFrame_.size.width , PopFrame_.size.height - BLUETITLEH - kPLUS_SCALE_X(70)) style:UITableViewStylePlain];
    tableV_.tableFooterView = [[UIView alloc]init];
    tableV_.separatorStyle = UITableViewCellSeparatorStyleNone; //隐藏线
    tableV_.delegate = self;
    tableV_.dataSource = self;
    tableV_.showsVerticalScrollIndicator = NO;
    //    tableV_.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
    [alertV addSubview:tableV_];
    
    if (isNeedCancel_) {
        //确定 返回按钮
        UIButton *sureButton = [UIButton new];
        [sureButton setTitle:@"返回" forState:(UIControlStateNormal)];
        [sureButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        sureButton.backgroundColor = UIColorFromRGB(0x47B0EB);
        ViewRadius(sureButton, 5);
        [sureButton addTarget:self action:@selector(sureClick) forControlEvents:(UIControlEventTouchDown)];
        [alertV addSubview:sureButton];
        [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(tableV_.mas_centerX).offset(- kPLUS_SCALE_X(20));
            make.bottom.mas_equalTo(alertV.mas_bottom).offset(- kPLUS_SCALE_X(20));
            make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/3, 35));
        }];
        
        UIButton *popButton = [UIButton new];
        [popButton setTitle:@"返回" forState:(UIControlStateNormal)];
        [popButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        popButton.backgroundColor = FirstGray;
        ViewRadius(popButton, 5);
        
        [popButton addTarget:self action:@selector(popClick) forControlEvents:(UIControlEventTouchDown)];
        [alertV addSubview:popButton];
        [popButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(tableV_.mas_centerX).offset(10);
            make.bottom.mas_equalTo(sureButton.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/3, 35));
        }];
    }else{
        UIButton *sureButton = [UIButton new];
        [sureButton setTitle:@"确定" forState:(UIControlStateNormal)];
        [sureButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        sureButton.backgroundColor = UIColorFromRGB(0x47B0EB);
        ViewRadius(sureButton, 5);
        [sureButton addTarget:self action:@selector(sureClick) forControlEvents:(UIControlEventTouchDown)];
        [alertV addSubview:sureButton];
        [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(alertV.mas_centerX);
            make.bottom.mas_equalTo(alertV.mas_bottom).offset(- kPLUS_SCALE_X(20));
            make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/3*2, 35));
        }];
    }
    
}
//确定
-(void)sureClick{
    __weak ExtendPopView *ws=self;
    [self.backV_ removeFromSuperview];
    if (ws.choseSure) {
        ws.choseSure(YES,index_);
    }
}
//返回
-(void)popClick{
    __weak ExtendPopView *ws=self;
    [self.backV_ removeFromSuperview];
    if (ws.choseSure) {
        ws.choseSure(NO,index_);
    }
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _CellArr.count;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if (_CellArr.count < 4) {
    //        return (PopFrame_.size.height - BLUETITLEH - kPLUS_SCALE_X(75))/_CellArr.count;
    //    }
    return 30;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //PopTableViewCell
    static NSString* cellIdentifier = @"ExtendPopTableTableViewCell";
    ExtendPopTableTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ExtendPopTableTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.tailImageV.hidden = YES;
    if (indexPath.row == 2) {
        //下面是button
        cell.tailImageV.hidden = NO;
        cell.midContantTextF.userInteractionEnabled = NO;
    }
    cell.leadTextLabel.text = cellTitleArr[indexPath.row];
    cell.midContantTextF.text = cellConatantArr[indexPath.row];
    if (!self.isCanEdit) {
        cell.midContantTextF.userInteractionEnabled = NO;
    }
//    cell.titleLabel.text = _CellArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isOnlyOne) {
//        for (int i = 0; i < _CellArr.count; i++) {
//            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
//            PopTableViewCell *cell = (PopTableViewCell *)[tableView cellForRowAtIndexPath:index];
//            cell.selectBtn.selected = NO;
//        }
//        PopTableViewCell *cell = (PopTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//        cell.selectBtn.selected = YES;
//        index_ = indexPath.row;
    }else{
//        ExtendPopTableTableViewCell *cell = (ExtendPopTableTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//        cell.selectBtn.selected = !cell.selectBtn.selected;
    }
    //clickCell
    __weak ExtendPopView *ws=self;
    if (ws.clickCell) {
        ws.clickCell(indexPath.row);
    }
}


@end
