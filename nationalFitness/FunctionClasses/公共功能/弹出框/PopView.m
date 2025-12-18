//
//  PopView.m
//  nationalFitness
//
//  Created by 童杰 on 2016/12/19.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "PopView.h"
#import "Masonry.h"
#import "PopTableViewCell.h"
#import "MKPAlertView.h"


//带tableview 蓝色标题的高度
#define BLUETITLEH kPLUS_SCALE_X(50)

//弹框、以及上面按钮的 圆角
#define radiusWidth 5

@implementation PopView{
    
    //弹框的frame
    CGRect PopFrame_;
    
    //带图片
    NSString *_imageName;
    NSString *_message;
    BOOL isNeedCancel_;
    UILabel *messageLabel;
    UIButton *sureButton_;
    UIButton *cancelButton;
    
    //背景图片的title
    UILabel *bringBackgroundTitleLabel;
    
    //不带图片
    NSString *titleSec_;
    BOOL isNeedCancell_;
    NSString *messageSec_;
    UILabel *titleSecLabel_;
    UILabel *messageSecLabel_;
    UIButton *sureSecButton;
    UIButton *cancelSecButton;
    CGFloat secAlertVHeight_;
    
    //带tableview的
    NSArray *_CellArr;
    UITableView *tableV_;
    NSInteger index_; //选择的index 从0开始
    //记录选中的button
    UIButton *selectedBtn_;
    
    //带textfield
    UITextField *textField_;
    
    //首页功能按钮图片数组
    NSArray *funcPicArr_;
    //首页功能按钮标题数组
    NSArray *funcTitleArr_;
    HomeFuncButtonView *HomeFuncButtonView_;
    //灰色背景色
    UIView *backV;
    
    //tableview弹框属性
    //头背景
    
    //确认按钮
    UIButton *tableviewSureBtn;
    //取消按钮
    UIButton *tableviewCancelBtn;
    //头上背景 用label实现
    UILabel *tableviewHeadBackLabel;
    
}

#pragma markmark - 带图片弹出框
-(instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel sureBlock:(void(^)(BOOL sureBlock))sureBlock{
    if (self) {
        PopFrame_ = frame;
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self = [super initWithFrame:rect];
        isNeedCancel_ = isNeedCancel;
        if (_sure != sureBlock) {
            _sure = nil;
            _sure = sureBlock;
        }
        _imageName = name;
        _message = message;
        
        [self costomView];
        
    }
    return self;
}

-(void)costomView{
    backV = [[UIView alloc] initWithFrame:self.viewForLastBaselineLayout.bounds];
    backV.backgroundColor = [UIColor blackColor];
    backV.alpha = 0.3;
    [self addSubview:backV];
    
    UIView *alertV = [[UIView alloc] init];
    alertV.backgroundColor = [UIColor whiteColor];
    alertV.alpha = 1.0;
    ViewRadius(alertV, radiusWidth);
    [self addSubview:alertV];
    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH / 6);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
        
    }];
    
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.image = [UIImage imageNamed:_imageName];
    [alertV addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(alertV.mas_centerX);
        make.top.mas_equalTo(alertV.mas_top).offset(GAPB * 5);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/4, SCREEN_WIDTH/4));
    }];
    
#pragma mark - //message label
    messageLabel = [UILabel new];
    messageLabel.text = _message;
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.font = [UIFont systemFontOfSize:18];
    messageLabel.numberOfLines = 0;
    //让message居中
//    if (isNeedCancel_) {
//        label.textAlignment = NSTextAlignmentCenter;
//    }else{
//    }
    [alertV addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageV.mas_bottom).offset(10);
        make.centerX.mas_equalTo(imageV.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - kPLUS_SCALE_X(50), (SCREEN_WIDTH)/4));
        
    }];
    
    if (isNeedCancel_) {
        //需要cancel按钮
        sureButton_ = [UIButton new];
        sureButton_.backgroundColor = MainColor;
        [self addSubview:sureButton_];
        [sureButton_ setTitle:@"确定" forState:(UIControlStateNormal)];
        [sureButton_ setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [sureButton_ addTarget:self action:@selector(mySignBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(sureButton_, radiusWidth);
        [sureButton_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(GAPB * 2);
            make.right.mas_equalTo(messageLabel.mas_centerX).offset(-GAPB);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 35));
            
        }];
        
        cancelButton = [UIButton new];
        cancelButton.backgroundColor = FirstGray;
        [self addSubview:cancelButton];
        [cancelButton setTitle:@"取消" forState:(UIControlStateNormal)];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [cancelButton addTarget:self action:@selector(mySignBtnCancelClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(cancelButton, radiusWidth);
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(GAPB * 2);
            make.left.mas_equalTo(messageLabel.mas_centerX).offset(GAPB);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 35));
            
        }];
    }else{
        //不需要cancel按钮
        sureButton_ = [UIButton new];
        sureButton_.backgroundColor = MainColor;
        [self addSubview:sureButton_];
        [sureButton_ setTitle:@"确定" forState:(UIControlStateNormal)];
        [sureButton_ setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [sureButton_ addTarget:self action:@selector(mySignBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(sureButton_, radiusWidth);
        [sureButton_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(GAPB * 2);
            make.centerX.mas_equalTo(messageLabel.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3*2, 35));
            
        }];
    }
}


-(void)mySignBtnClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.sure) {
        ws.sure(YES);
    }
}

-(void)mySignBtnCancelClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.sure) {
        ws.sure(NO);
    }
}

//-(instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel sureBlock:(void(^)(BOOL sureBlock))sureBlock{

#pragma markmark - 不带图片弹出框
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel isSureBlock:(void(^)(BOOL sureBlock))sureBlock{
    if (self) {
        PopFrame_ = frame;
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self = [super initWithFrame:rect];
        isNeedCancell_ = isNeedCancel;
        if (_sureSec != sureBlock) {
            _sureSec = nil;
            _sureSec = sureBlock;
        }
        messageSec_ = message;
        titleSec_ = title;
        secAlertVHeight_ = SCREEN_WIDTH/3*2;
        [self customView];
    }
    return self;
}

//0为巨左 1中。2右
-(void)setSecMessageLabelTextAlignment:(NSString *)type{
    if ([type isEqualToString:@"0"]) {
        messageSecLabel_.textAlignment = NSTextAlignmentCenter;
    }else if ([type isEqualToString:@"1"]){
        messageSecLabel_.textAlignment = NSTextAlignmentRight;
    }
}



-(void)tapBackgroundClickk{
    NSLog(@"");
}

-(void)customView{
    backV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*1.2)];
    backV.backgroundColor = [UIColor blackColor];
    backV.alpha = 0.3;
    [self addSubview:backV];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClickk)];
    [backV addGestureRecognizer:tap];
    
    
    UIView *alertV = [[UIView alloc] init];
    alertV.backgroundColor = [UIColor whiteColor];
    alertV.alpha = 1.0;
    ViewRadius(alertV, radiusWidth);
    [self addSubview:alertV];
    //alert 宽度高度 PopFrame_.size.width  PopFrame_.size.height
    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH / 6);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
    }];
    
#pragma mark - //message label
    
    messageSecLabel_ = [UILabel new];
    messageSecLabel_.text = messageSec_;
    messageSecLabel_.textColor = FirstGray;
    messageSecLabel_.textAlignment = NSTextAlignmentLeft;
    messageSecLabel_.font = [UIFont systemFontOfSize:18];
    messageSecLabel_.numberOfLines = 0;
    //让message居中
    //    if (isNeedCancel_) {
    //        label.textAlignment = NSTextAlignmentCenter;
    //    }else{
    //    }
    [alertV addSubview:messageSecLabel_];
    //判断是否要 头上 title
    if (titleSec_) {
        //头上title 宽高 PopFrame_.size.width kPLUS_SCALE_X(60)
        titleSecLabel_ = [UILabel new];
        [alertV addSubview:titleSecLabel_];
        titleSecLabel_.backgroundColor = UIColorFromRGB(0x33B7D4);
        titleSecLabel_.text = titleSec_;
        titleSecLabel_.textColor = [UIColor whiteColor];
        titleSecLabel_.font = [UIFont systemFontOfSize:22];
        titleSecLabel_.numberOfLines = 0;
        titleSecLabel_.textAlignment = NSTextAlignmentCenter;
        [titleSecLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(alertV.mas_top);
            make.centerX.mas_equalTo(alertV.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width / 4*3, kPLUS_SCALE_X(40)));
        }];
        
        [messageSecLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleSecLabel_.mas_bottom).offset(GAPB);
//            make.centerY.mas_equalTo(alertV.mas_centerY);
            make.centerX.mas_equalTo(alertV.mas_centerX);
            
//            CGFloat mesageLH = PopFrame_.size.height - (PopFrame_.size.height - CGRectGetMinY(sureSecButton.frame)) - CGRectGetMaxY(titleSecLabel_.frame) - GAPB*2;
            // message高度等于 alertv总高度 - 标题高度 - 按钮高度 - 按钮下面空白高度 - messagelabel与上面下面的距离
            CGFloat mesageLH = PopFrame_.size.height - kPLUS_SCALE_X(60) - 35 - 5*GAPB - 2*GAPB;
            
            make.size.mas_equalTo(CGSizeMake( PopFrame_.size.width / 4*3, mesageLH));
            
        }];
        
    }else{
        [messageSecLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(alertV.mas_top).offset(50);
            make.centerX.mas_equalTo(alertV.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - kPLUS_SCALE_X(50), (SCREEN_WIDTH)/3));
            
        }];
    }
    
    if (isNeedCancell_) {
        //需要cancel按钮
        sureSecButton = [UIButton new];
        sureSecButton.backgroundColor = MainColor;
        [self addSubview:sureSecButton];
        [sureSecButton setTitle:@"确定" forState:(UIControlStateNormal)];
        [sureSecButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [sureSecButton addTarget:self action:@selector(SignBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(sureSecButton, radiusWidth);
        
        [sureSecButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(alertV.mas_bottom).offset(-GAPB * 5);
//            make.right.mas_equalTo(messageSecLabel_.mas_centerX).offset(-GAPB);
//            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 35));
            make.bottom.mas_equalTo(alertV.mas_bottom).offset(-GAPB * 5);
            make.left.mas_equalTo(messageSecLabel_.mas_centerX).offset(GAPB);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 35));
        }];
        
        cancelSecButton = [UIButton new];
        cancelSecButton.backgroundColor = FirstGray;
        [self addSubview:cancelSecButton];
        [cancelSecButton setTitle:@"取消" forState:(UIControlStateNormal)];
        [cancelSecButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [cancelSecButton addTarget:self action:@selector(SignBtnCancelClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(cancelSecButton, radiusWidth);
        [cancelSecButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(alertV.mas_bottom).offset(-GAPB * 5);
//            make.left.mas_equalTo(messageSecLabel_.mas_centerX).offset(GAPB);
//            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 35));
            
            make.bottom.mas_equalTo(alertV.mas_bottom).offset(-GAPB * 5);
            make.right.mas_equalTo(messageSecLabel_.mas_centerX).offset(-GAPB);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 40));
        }];
    }else{
        //不需要cancel按钮
        sureSecButton = [UIButton new];
        sureSecButton.backgroundColor = MainColor;
        [self addSubview:sureSecButton];
        [sureSecButton setTitle:@"确定" forState:(UIControlStateNormal)];
        [sureSecButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [sureSecButton addTarget:self action:@selector(SignBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(sureSecButton, radiusWidth);
        [sureSecButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageSecLabel_.mas_bottom).offset(GAPB * 2);
            //alertV
            make.bottom.mas_equalTo(alertV.mas_bottom).offset(-GAPB * 5);
            make.centerX.mas_equalTo(messageSecLabel_.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/2, 40));
            
        }];
    }
}

-(void)SignBtnClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.sureSec) {
        ws.sureSec(YES);
    }
}

-(void)SignBtnCancelClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.sureSec) {
        ws.sureSec(NO);
    }
}

#pragma mark - 带图片 属性设置
-(void)setMessageColor:(UIColor *)messageColor{
    messageLabel.textColor = messageColor;
}



-(void)setSureColor:(UIColor *)sureColor{
    [sureButton_ setBackgroundColor:sureColor];
}

-(void)setCancelColor:(UIColor *)cancelColor{
    [cancelButton setBackgroundColor:cancelColor];
}

#pragma mark - 不带图片 属性设置

-(void)setSecTitleColor:(UIColor *)titleColor{
    titleSecLabel_.textColor = titleColor;
    titleSecLabel_.textAlignment = NSTextAlignmentLeft;
}

-(void)setSecTitleAlient:(NSTextAlignment)titleAlignment{
    titleSecLabel_.textAlignment = titleAlignment;
}


-(void)setSecSureBtnText:(NSString *)title{
    [sureSecButton setTitle:title forState:(UIControlStateNormal)];
}

-(void)setSecMessageColor:(UIColor *)messageColor{
    messageSecLabel_.textColor = messageColor;
}

-(void)setSecSureColor:(UIColor *)sureColor{
    [sureSecButton setBackgroundColor:sureColor];
}
//cancel 背景
-(void)setSecCancelColor:(UIColor *)cancelColor{
    [cancelSecButton setBackgroundColor:cancelColor];
}
//cancel 字颜色
-(void)setSecCancelTextColor:(UIColor *)cancelColor{
    [cancelSecButton setTitleColor:cancelColor forState:(UIControlStateNormal)];
}
//头 背景
-(void)setSecTitleBackColor:(UIColor *)sureColor{
    titleSecLabel_.backgroundColor = sureColor;
}
//弹出框 距离上面约束
-(void)setSecAlertViewHeight:(CGFloat)SecAlertViewHeight{
    secAlertVHeight_ = SecAlertViewHeight;
}

-(void)setCancelBoldColor:(UIColor *)color{
    ViewBorderRadius(cancelSecButton, 5, 1, color);
}

#pragma mark - 带tableview 的选择弹窗
-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message CellArrar:(NSArray *)CellArr isSureBlock:(void(^)(BOOL sureBlock,NSInteger index))sureBlock ClickCellBlock:(void(^)(NSInteger index))clickCellBlock{
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
        _message = message;
        _CellArr = [NSMutableArray arrayWithArray:CellArr];
        [self costomViewWithTableview];
        
    }
    return self;
}

-(void)costomViewWithTableview{
    backV = [[UIView alloc] initWithFrame:self.viewForLastBaselineLayout.bounds];
    backV.backgroundColor = [UIColor blackColor];
    backV.alpha = 0.3;
    [self addSubview:backV];
    
    UIView *alertV = [[UIView alloc] init];
    alertV.backgroundColor = [UIColor whiteColor];
    alertV.alpha = 1.0;
    ViewRadius(alertV, radiusWidth);
    [self addSubview:alertV];
    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH / 6);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
    }];
    //头上蓝色背景用label实现
    tableviewHeadBackLabel = [UILabel new];
    tableviewHeadBackLabel.backgroundColor = UIColorFromRGB(0x47B0EB);
    [alertV addSubview:tableviewHeadBackLabel];
    [tableviewHeadBackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.centerX.mas_equalTo(tableviewHeadBackLabel.mas_centerX);
        make.centerY.mas_equalTo(tableviewHeadBackLabel.mas_centerY);
        
    }];
    
    //tableview
    tableV_ = [[UITableView alloc] initWithFrame:CGRectMake(0, BLUETITLEH + GAPB, PopFrame_.size.width , PopFrame_.size.height - BLUETITLEH - kPLUS_SCALE_X(70)) style:UITableViewStylePlain];
    tableV_.tableFooterView = [[UIView alloc]init];
    tableV_.separatorStyle = UITableViewCellSeparatorStyleNone; //隐藏线
    tableV_.delegate = self;
    tableV_.dataSource = self;
//    tableV_.showsVerticalScrollIndicator = NO;
//    tableV_.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
    [alertV addSubview:tableV_];
    
    //确定 返回按钮
    tableviewSureBtn = [UIButton new];
    [tableviewSureBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [tableviewSureBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    tableviewSureBtn.backgroundColor = UIColorFromRGB(0x47B0EB);
    
    ViewRadius(tableviewSureBtn, radiusWidth);
    //UIControlEventTouchUpInside
    [tableviewSureBtn addTarget:self action:@selector(sureClick) forControlEvents:(UIControlEventTouchUpInside)];
    [alertV addSubview:tableviewSureBtn];
    [tableviewSureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(tableV_.mas_centerX).offset(- kPLUS_SCALE_X(20));
        make.bottom.mas_equalTo(alertV.mas_bottom).offset(- kPLUS_SCALE_X(20));
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/3, 35));
    }];
    
    tableviewCancelBtn = [UIButton new];
    [tableviewCancelBtn setTitle:@"返回" forState:(UIControlStateNormal)];
    [tableviewCancelBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    tableviewCancelBtn.backgroundColor = FirstGray;
    ViewRadius(tableviewCancelBtn, radiusWidth);
    
    [tableviewCancelBtn addTarget:self action:@selector(popClick) forControlEvents:(UIControlEventTouchUpInside)];
    [alertV addSubview:tableviewCancelBtn];
    [tableviewCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tableV_.mas_centerX).offset(10);
        make.bottom.mas_equalTo(tableviewSureBtn.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/3, 35));
    }];
}
//确定
-(void)sureClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.choseSure) {
        ws.choseSure(YES,index_);
    }
}
//返回
-(void)popClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.choseSure) {
        ws.choseSure(NO,index_);
    }
}

//设置tableview确认按钮颜色
-(void)setTableviewSureBtnColor:(UIColor *)color{
    tableviewSureBtn.backgroundColor =color;
}

//设置tableview取消按钮颜色
-(void)setTableviewCancelBtnColor:(UIColor *)color{
    tableviewCancelBtn.backgroundColor =color;
}

//设置tableview头上背景label颜色
-(void)setTableviewHeadBackLabelColor:(UIColor *)color{
    tableviewHeadBackLabel.backgroundColor =color;
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
    return 50;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //PopTableViewCell
    static NSString* cellIdentifier = @"PopTableViewCell";
    PopTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PopTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.titleLabel.text = _CellArr[indexPath.row];
    if (self.isOnlyOne && index_ == indexPath.row) {
        cell.selectBtn.selected = YES;//默认选中第一个网址
    }else{
        //多选 有一个数组
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isOnlyOne) {
        for (int i = 0; i < _CellArr.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            PopTableViewCell *cell = (PopTableViewCell *)[tableView cellForRowAtIndexPath:index];
            cell.selectBtn.selected = NO;
        }
        PopTableViewCell *cell = (PopTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selectBtn.selected = YES;
        index_ = indexPath.row;
    }else{
        PopTableViewCell *cell = (PopTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selectBtn.selected = !cell.selectBtn.selected;
    }
    //clickCell
    __weak PopView *ws=self;
    if (ws.clickCell) {
        ws.clickCell(indexPath.row);
    }
}

#pragma mark - 带textfield 的输入弹窗
-(instancetype)initWithFrame:(CGRect)frame message:(NSString *)message isSureBlock:(void(^)(NSString *textBlock))textBlock{
    if (self) {
        PopFrame_ = frame;
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self = [super initWithFrame:rect];
        _message = message;
        if (_inputText != textBlock) {
            _inputText = nil;
            _inputText = textBlock;
        }
        [self costomTextFieldView];
    }
    
    return self;
}

- (void)tapGesturedDetected:(UITapGestureRecognizer *)recognizer
{
    // do something
    [textField_ resignFirstResponder];
}

-(void)costomTextFieldView{
    backV = [[UIView alloc] initWithFrame:self.viewForLastBaselineLayout.bounds];
    backV.backgroundColor = [UIColor blackColor];
    backV.alpha = 0.3;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturedDetected:)]; // 手势类型随你喜欢。
    tapGesture.delegate = self;
    [backV addGestureRecognizer:tapGesture];
    [self addSubview:backV];
    
    UIView *alertV = [[UIView alloc] init];
    alertV.backgroundColor = [UIColor whiteColor];
    alertV.alpha = 1.0;
    ViewRadius(alertV, radiusWidth);
    [self addSubview:alertV];
    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH/6);
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
    titleLabel.font = [UIFont systemFontOfSize:15];
    [alertV addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(blueLabel.mas_centerX);
        make.centerY.mas_equalTo(blueLabel.mas_centerY);
        
    }];
    
    //textfield
    textField_ = [UITextField new];
    [alertV addSubview:textField_];
    ViewBorderRadius(textField_, 3, 1, UIColorFromRGB(0x47B0EB));
    [textField_ mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(alertV.mas_centerX);
        make.centerY.mas_equalTo(alertV.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/2, 40));
    }];
    textField_.keyboardType = UIKeyboardTypeNumberPad;
    //确定 返回按钮
    UIButton *sureButton = [UIButton new];
    [sureButton setTitle:@"确定" forState:(UIControlStateNormal)];
    [sureButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    sureButton.backgroundColor = UIColorFromRGB(0x47B0EB);
    ViewRadius(sureButton, radiusWidth);
    [sureButton addTarget:self action:@selector(textSureClick) forControlEvents:(UIControlEventTouchUpInside)];
    [alertV addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(alertV.mas_centerX).offset(-10);
        make.bottom.mas_equalTo(alertV.mas_bottom).offset(-30);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/3, 35));
    }];
    
    UIButton *popButton = [UIButton new];
    [popButton setTitle:@"返回" forState:(UIControlStateNormal)];
    [popButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    popButton.backgroundColor = FirstGray;
    ViewRadius(popButton, radiusWidth);
    
    [popButton addTarget:self action:@selector(textPopClick) forControlEvents:(UIControlEventTouchUpInside)];
    [alertV addSubview:popButton];
    [popButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(alertV.mas_centerX).offset(10);
        make.bottom.mas_equalTo(alertV.mas_bottom).offset(-30);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width/3, 35));
    }];
}

-(void)textSureClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.inputText) {
        ws.inputText(textField_.text);
    }
}

-(void)textPopClick{
    __weak PopView *ws=self;
    [self removeFromSuperview];
    if (ws.inputText) {
        ws.inputText(@"0");
    }
}


-(instancetype)initWithFrame:(CGRect)frame PicPathArr:(NSArray *)picArr titleArr:(NSArray *)titleArr clickBlock:(void(^)(NSInteger index))clickIndex{
    if (self) {
        PopFrame_ = frame;
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self = [super initWithFrame:rect];
        
        if (_functionButtonindex != clickIndex) {
            _functionButtonindex = nil;
            _functionButtonindex = clickIndex;
        }
        funcPicArr_ = picArr;
        funcTitleArr_ = titleArr;
        [self customFunctionButton];
    }
    return self;
}

//点击空白取消选择功能界面
-(void)cancelFunctionView{
    [self removeFromSuperview];
}

-(void)customFunctionButton{
    
    backV = [[UIView alloc] initWithFrame:self.viewForLastBaselineLayout.bounds];
    backV.backgroundColor = [UIColor blackColor];
    backV.alpha = 0.3;
    [self addSubview:backV];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFunctionView)];
    tapGesture.delegate = self;
    [backV addGestureRecognizer:tapGesture];
    
//    UIView *alertV = [[UIView alloc] init];
//    alertV.backgroundColor = [UIColor whiteColor];
//    alertV.alpha = 1.0;
//    [self addSubview:alertV];
//    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.mas_centerX);
//        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH / 4);
//        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
//    }];
    
    //HomeFuncButtonView
    HomeFuncButtonView_ = [[[NSBundle mainBundle]loadNibNamed:@"HomeFuncButtonView" owner:nil options:nil] firstObject];
    HomeFuncButtonView_.frame = CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44);
    for (int i = 0; i < 8; i++) {
        UIButton *btn = (UIButton *)[HomeFuncButtonView_ viewWithTag:i + 1];
        [btn addTarget:self action:@selector(functionClick:) forControlEvents:(UIControlEventTouchUpInside)];
        UILabel *lab = (UILabel *)[HomeFuncButtonView_ viewWithTag:i + 11];
        if (i < funcPicArr_.count) {
            lab.text = funcTitleArr_[i];
            [btn sd_setImageWithURL:[NSURL URLWithString:funcPicArr_[i]] forState:UIControlStateNormal];
            [btn sd_setImageWithURL:[NSURL URLWithString:funcPicArr_[i]] forState:UIControlStateHighlighted];
            btn.hidden = NO;
            lab.hidden = NO;
            
        }else
        {
            btn.hidden = YES;
            lab.hidden = YES;
        }
        
    }
//    [alertV addSubview:HomeFuncButtonView_];
    
    [self addSubview:HomeFuncButtonView_];
    [HomeFuncButtonView_ mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH / 6);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
    }];
    
}

//功能按钮点击
-(void)functionClick:(UIButton *)sender{
    self.functionButtonindex(sender.tag);
    
}

#pragma mark - 凯诺弹出框带背景图片
-(instancetype)initWithFrame:(CGRect)frame backgroundImageName:(NSString *)name message:(NSString *)message isNeedCancel:(BOOL)isNeedCancel sureBlock:(void(^)(BOOL sureBlock))sureBlock{
    if (self) {
        PopFrame_ = frame;
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self = [super initWithFrame:rect];
        isNeedCancel_ = isNeedCancel;
        if (_sure != sureBlock) {
            _sure = nil;
            _sure = sureBlock;
        }
        _imageName = name;
        _message = message;
        
        [self costomViewWithBackgroundImage];
        
    }
    return self;
}
    

-(void)costomViewWithBackgroundImage{
    
    backV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*1.2)];
    backV.backgroundColor = [UIColor blackColor];
    backV.userInteractionEnabled = NO;
    backV.alpha = 0.3;
    [self addSubview:backV];
    
    UIView *alertV = [[UIView alloc] init];
//    alertV.backgroundColor = [UIColor whiteColor];
    alertV.alpha = 1.0;
    ViewRadius(alertV, radiusWidth);
    [self addSubview:alertV];
    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
//        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH / 4);
        make.centerY.mas_equalTo(self.mas_centerY).offset(- SCREEN_WIDTH / 6);
        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
        
    }];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PopFrame_.size.width, PopFrame_.size.height)];
    imageV.image = [UIImage imageNamed:_imageName];
    [alertV addSubview:imageV];
//    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(alertV.mas_centerX);
//        make.top.mas_equalTo(alertV.mas_top).offset(GAPB * 5);
//        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/4, SCREEN_WIDTH/4));
//    }];
    
#pragma mark - //message label
    bringBackgroundTitleLabel = [UILabel new];
    bringBackgroundTitleLabel.text = @"温馨提示";
    bringBackgroundTitleLabel.textColor = UIColorFromRGB(0x5ecdd0);
    bringBackgroundTitleLabel.textAlignment = NSTextAlignmentCenter;
    if (SCREEN_WIDTH == 320) {
        bringBackgroundTitleLabel.font = [UIFont systemFontOfSize:26];
    }else{
        bringBackgroundTitleLabel.font = [UIFont systemFontOfSize:30];
    }
    [bringBackgroundTitleLabel sizeToFit];
    [alertV addSubview:bringBackgroundTitleLabel];
    [bringBackgroundTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageV.mas_top).offset(30);
        make.centerX.mas_equalTo(imageV.mas_centerX);
//        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - kPLUS_SCALE_X(50), (SCREEN_WIDTH)/4));
        
    }];
    
    messageLabel = [UILabel new];
    messageLabel.text = _message;
    messageLabel.textColor = UIColorFromRGB(0xef8be7);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont boldSystemFontOfSize:18];
    messageLabel.numberOfLines = 0;
    //让message居中
    //    if (isNeedCancel_) {
    //        label.textAlignment = NSTextAlignmentCenter;
    //    }else{
    //    }
    [alertV addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bringBackgroundTitleLabel.mas_top).offset(10);
        make.centerX.mas_equalTo(bringBackgroundTitleLabel.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - kPLUS_SCALE_X(50), (SCREEN_WIDTH)/4));
    }];
    
    if (isNeedCancel_) {
        //需要cancel按钮
        sureButton_ = [UIButton new];
//        sureButton_.backgroundColor = MainColor;
        [self addSubview:sureButton_];
//        [sureButton_ setTitle:@"确定" forState:(UIControlStateNormal)];
//        [sureButton_ setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [sureButton_ setImage:[UIImage imageNamed:@"确定"] forState:(UIControlStateNormal)];
        [sureButton_ setImage:[UIImage imageNamed:@"确定（选中）"] forState:(UIControlStateHighlighted)];
        [sureButton_ addTarget:self action:@selector(mySignBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(sureButton_, radiusWidth);
        [sureButton_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(GAPB * 2);
            make.right.mas_equalTo(messageLabel.mas_centerX).offset(-GAPB);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 35));
        }];
        
        cancelButton = [UIButton new];
//        cancelButton.backgroundColor = FirstGray;
        [self addSubview:cancelButton];
//        [cancelButton setTitle:@"取消" forState:(UIControlStateNormal)];
//        [cancelButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [cancelButton setImage:[UIImage imageNamed:@"取消"] forState:(UIControlStateNormal)];
        [cancelButton setImage:[UIImage imageNamed:@"取消（选中）"] forState:(UIControlStateHighlighted)];
        [cancelButton addTarget:self action:@selector(mySignBtnCancelClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(cancelButton, radiusWidth);
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(GAPB * 2);
            make.left.mas_equalTo(messageLabel.mas_centerX).offset(GAPB);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3, 35));
        }];
    }else{
        //不需要cancel按钮
        sureButton_ = [UIButton new];
//        sureButton_.backgroundColor = MainColor;
        [self addSubview:sureButton_];
        [sureButton_ setImage:[UIImage imageNamed:@"确定"] forState:(UIControlStateNormal)];
        [sureButton_ setImage:[UIImage imageNamed:@"确定（选中）"] forState:(UIControlStateHighlighted)];
//        [sureButton_ setTitle:@"确定" forState:(UIControlStateNormal)];
//        [sureButton_ setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [sureButton_ addTarget:self action:@selector(mySignBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        ViewRadius(sureButton_, radiusWidth);
        [sureButton_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(GAPB * 2);
            make.centerX.mas_equalTo(messageLabel.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/3*2, 35));
            
        }];
    }
}

-(void)setBackValpha:(CGFloat)alpha{
    backV.alpha = alpha;
    
}

    
@end
