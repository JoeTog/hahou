//
//  PickerViewChose.m
//  JoeUIPickView01
//
//  Created by 童杰 on 2017/4/13.
//  Copyright © 2017年 tong. All rights reserved.
//

#import "PickerViewChose.h"

#define toolBarHeight 40
#define secToolHeight 30

#define firstToolBarBackColor UIColorFromRGB(0x40b5f8)

#define secondToolBarBackColor UIColorFromRGB(0xf3fafb)

#define textColorr UIColorFromRGB(0x1f2529)

@implementation PickerViewChose{
    
    CGRect pickerFrame_;
    BOOL isNeedCancel;
    
    NSArray *firstCompontArr;
    NSArray *secondCompontArr;
    NSArray *thirdCompontArr;
    NSArray *forthCompontArr;
    
    NSInteger compntCount;
    
    UIPickerView *pickView_;
    
    CGFloat rowHeight;
    
    NSInteger _firstRow;
    NSInteger _secondRow;
    NSInteger _thirdRow;
    NSInteger _forthRow;
    
    UILabel *firstLabel_;
    UILabel *secondLabel_;
    UILabel *thirdLabel_;
    
    UIView *toolBarV_;
    
    //背景图片
    UIImageView *backImageV;
    
    
}
//选择的从0开始
-(instancetype)initWithFrame:(CGRect)frame FirstCompontArr:(NSArray *)fisrt SecondCompont:(NSArray *)second ThirdCompont:(NSArray *)third forthCompont:(NSArray *)forth rowHeight:(CGFloat)height  ReturnEveryRowBlock:(void(^)(BOOL isSure,NSInteger firstRow,NSInteger secondRow,NSInteger thirdRow,NSInteger forthRow))Block{
    if (self) {
        self = [super initWithFrame:frame];
        pickerFrame_ = frame;
//        UIColorFromRGB(0x);
        if (fisrt.count > 0) {
            compntCount++;
            firstCompontArr = [NSArray arrayWithArray:fisrt];
            
        }
        if (second.count > 0) {
            compntCount++;
            secondCompontArr = [NSArray arrayWithArray:second];
//           
        }
        if (third.count > 0) {
            compntCount++;
            thirdCompontArr = [NSArray arrayWithArray:third];
            
        }
        if (forth.count > 0) {
            compntCount++;
            forthCompontArr = [NSArray arrayWithArray:forth];
            
        }
        if (self.ReturnEveryRowBlock != Block) {
            self.ReturnEveryRowBlock = Block;
        }
        rowHeight = height;
        isNeedCancel = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self customView];
    }
    return self;
}

-(void)setIsNeedTitleTool:(BOOL)isNeedTitleTool{
    
    if (isNeedTitleTool) {
        //第二个toolbar的背景
        UIView *secToolBarV = [UIView new];
        secToolBarV.backgroundColor = secondToolBarBackColor;
        [self addSubview:secToolBarV];
        
        [secToolBarV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(toolBarV_.mas_bottom);
            make.left.mas_equalTo(toolBarV_.mas_left);
            make.size.mas_equalTo(CGSizeMake(pickerFrame_.size.width, secToolHeight));
        }];
        
        firstLabel_ = [UILabel new];
        [secToolBarV addSubview:firstLabel_];
        firstLabel_.text = @"信息类别";
        //    firstLabel_.userInteractionEnabled = YES;
        firstLabel_.textAlignment = NSTextAlignmentCenter;
//        firstLabel_.textColor = [UIColor greenColor];
        firstLabel_.textColor = MainTextColor;
        [firstLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(secToolBarV.mas_left);
            make.top.mas_equalTo(secToolBarV.mas_top);
            make.size.mas_equalTo(CGSizeMake(pickerFrame_.size.width/compntCount, secToolHeight));
            
        }];
        
        if (secondCompontArr.count > 0) {
            secondLabel_ = [UILabel new];
            [secToolBarV addSubview:secondLabel_];
            secondLabel_.text = @"信息级别";
            secondLabel_.textAlignment = NSTextAlignmentCenter;
            secondLabel_.textColor = [UIColor blueColor];
//            secondLabel_.textColor = MainRedColor;
            [secondLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(firstLabel_.mas_right);
                make.top.mas_equalTo(secToolBarV.mas_top);
                make.size.mas_equalTo(CGSizeMake(pickerFrame_.size.width/compntCount, secToolHeight));
            }];
        }
        
        if (thirdCompontArr.count > 0) {
            thirdLabel_ = [UILabel new];
            [secToolBarV addSubview:thirdLabel_];
            thirdLabel_.text = @"信息级别";
            thirdLabel_.textAlignment = NSTextAlignmentCenter;
            thirdLabel_.textColor = [UIColor redColor];
            [thirdLabel_ mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(secondLabel_.mas_right);
                make.top.mas_equalTo(secToolBarV.mas_top);
                make.size.mas_equalTo(CGSizeMake(pickerFrame_.size.width/compntCount, secToolHeight));
                
            }];
        }
        
    }
    
}

-(void)customView{
    
    backImageV = [[UIImageView alloc] initWithFrame:self.bounds];
//    backImageV.image = [UIImage imageNamed:@"底图3"];
    [self addSubview:backImageV];
    
    //secToolHeight toolBarHeight
    //第一个toolbar的背景
    toolBarV_ = [UIView new];
    toolBarV_.backgroundColor = firstToolBarBackColor;
    toolBarV_.backgroundColor = SecondGray;
    [self addSubview:toolBarV_];
    [toolBarV_ mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self.mas_left);
        make.size.mas_equalTo(CGSizeMake(pickerFrame_.size.width, toolBarHeight));
    }];
    
    UIButton *cancelBtn = [UIButton new];
    [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancelBtn setTitleColor:UIColorFromRGB(0x157efb) forState:(UIControlStateNormal)];
    [cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:(UIControlEventTouchDown)];
    [toolBarV_ addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(toolBarV_.mas_left).offset(10);
        make.centerY.mas_equalTo(toolBarV_.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    UIButton *sureBtn = [UIButton new];
    [toolBarV_ addSubview:sureBtn];
    [sureBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [sureBtn setTitleColor:UIColorFromRGB(0x157efb) forState:(UIControlStateNormal)];
    [sureBtn addTarget:self action:@selector(sureClick) forControlEvents:(UIControlEventTouchDown)];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(toolBarV_.mas_right).offset(-10);
        make.centerY.mas_equalTo(toolBarV_.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    pickView_ = [[UIPickerView alloc]initWithFrame:CGRectMake(0, toolBarHeight, pickerFrame_.size.width, pickerFrame_.size.height - toolBarHeight)];
    pickView_.delegate = self;
    pickView_.dataSource = self;
    pickView_.backgroundColor = [UIColor whiteColor];
//    [pickView_ selectRow:1 inComponent:0 animated:YES];
//    [pickView_ selectRow:1 inComponent:1 animated:YES];
    
//    [pickView setTextAlignment: NSTextAlignmentCenter];
//    [pickView setBackgroundColor:[UIColor clearColor]];
//    [pickView setTextColor:_pickerViewTextColor];
//    [pickView setFont:_pickerViewFont];
    
    [self addSubview:pickView_];
    
//    if (firstCompontArr.count >2) {
//        [pickView_ selectRow:1 inComponent:0 animated:NO];
//    }
//    if (secondCompontArr.count >2) {
//        [pickView_ selectRow:1 inComponent:1 animated:NO];
//    }
//    if (thirdCompontArr.count >2) {
//        [pickView_ selectRow:1 inComponent:2 animated:NO];
//    }
//    if (forthCompontArr.count >2) {
//        [pickView_ selectRow:1 inComponent:3 animated:NO];
//    }
}

-(void)setBackImageView:(NSString *)picName{
    backImageV.image = [UIImage imageNamed:picName];
}

#pragma mark - sureClick
-(void)sureClick{
    [self removeFromSuperview];
    self.ReturnEveryRowBlock(YES,_firstRow,_secondRow,_thirdRow,_forthRow);
}

#pragma mark - cancelClick
-(void)cancelClick{
    [self removeFromSuperview];
    self.ReturnEveryRowBlock(NO,_firstRow,_secondRow,_thirdRow,_forthRow);
}

#pragma mark  - pickVoew---->dataSource & delegate


//pickView 返回的列数
//参数表示遵循代理协议的pickView
//
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return compntCount;
}

//表示每一列有多少行
//参数一：表示遵循协议代理的pickView
//参数二：表示列数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return firstCompontArr.count;
    }else if (component == 1){
        return secondCompontArr.count;
    }else if (component == 2){
        return thirdCompontArr.count;
    }
    return forthCompontArr.count;
}

//每一行的内容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return firstCompontArr[row];
    }else if (component == 1){
        return secondCompontArr[row];
    }else if (component == 2){
        return thirdCompontArr[row];
    }
    return forthCompontArr[row];
    
}
//每一列中每一行的宽度
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    NSLog(@"%f",pickerFrame_.size.width / compntCount);
    return pickerFrame_.size.width / compntCount;
    
}

//设置每一行的高度，实际都显示最高列的高度
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return rowHeight;
}

//void(^ReturnEveryRowBlock)(NSInteger firstRow,NSInteger secondRow,NSInteger thirdRow)
//监听选中的行数和列数
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //如果需要选中一个 后面层级的row跟着变。就在这里进行刷新赋值
    if (component == 0) {
        _firstRow = row;
    }else if (component == 1){
        _secondRow = row;
    }else if (component == 2){
        _thirdRow = row;
    }else if (component == 3){
        _forthRow = row;
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc]init];
    if (component == 0) {
        label.text = firstCompontArr[row];
    }else if (component==1){
        label.text = secondCompontArr[row];
    }else if (component==2){
        label.text = thirdCompontArr[row];
    }
    else{
        label.text = forthCompontArr[row];
    }
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor colorMainTextColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"11");
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"22");
}


- (BOOL)anySubViewScrolling:(UIView *)view{
    
    if ([view isKindOfClass:[UIScrollView class]]) {
        
        UIScrollView *scrollView = (UIScrollView *)view;
        
        if (scrollView.dragging || scrollView.decelerating) {
            
            return YES;
            
        }
        
    }
    
    for (UIView *theSubView in view.subviews) {
        
        if ([self anySubViewScrolling:theSubView]) {
            
            return YES;
            
        }
        
    }
    
    return NO;
    
}





@end
