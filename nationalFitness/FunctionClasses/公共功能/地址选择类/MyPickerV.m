//
//  MyPickerV.m
//  地址选择代码块封装
//
//  Created by 童杰 on 2016/12/16.
//  Copyright © 2016年 童杰. All rights reserved.
//

#import "MyPickerV.h"
#import "areaObject.h"

@interface MyPickerV ()

@property (strong, nonatomic) areaObject *locate;

@end

@implementation MyPickerV{
    //省份数组{@"state":@""}
    NSMutableArray *_firstArr;
    //城市列表 {@"city":@""}
    NSMutableArray *_secondArr;
    //区列表 {@"area":@""}
    NSMutableArray *_thirdArr;
    //省的宽度
    CGFloat _firstComponentW;
    //市的宽度
    CGFloat _secondComponentW;
    //区的宽度
    CGFloat _thirdComponentW;
    //需要传过去的地域
    NSString *_selectedAddress;
    
}


-(instancetype)initWithFrame:(CGRect)frame firstComponentW:(CGFloat)Weight secondComponentW:(CGFloat)SWeight thirdComponentW:(CGFloat)TWeight cancelBlock:(void (^)(NSError *error))cancelBlock sureBlock:(void(^)(NSString *areaString))sureBlock{
    if (self) {
        self = [super initWithFrame:frame];
        self.backgroundColor = ThirdGray;
        //代码块
        if (_success != sureBlock) {
            _success=nil;
            _success=sureBlock;
        }
        if (_failed != cancelBlock) {
            _failed = nil;
            _failed = cancelBlock;
        }
        //将参数设置为全局变量
        _firstComponentW = Weight;
        _secondComponentW = SWeight;
        _thirdComponentW = TWeight;
        [self prepareData];
        //刚进来 设置为默认的第一个，当从编辑进来时候，应该选中为默认的比如 江苏南京栖霞，根据实体取值
        self.locate = [areaObject new];
        self.locate.province = _firstArr[0][@"state"];
        self.locate.city = _secondArr[0][@"city"];
        if (_thirdArr.count > 0) {
            self.locate.area = _thirdArr[0][@"area"];
        }else{
            self.locate.area = @"";
        }
        //创建pickview
        UIPickerView *pickV = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, frame.size.height - 30)];
        pickV.delegate = self;
        pickV.dataSource = self;
        [self addSubview:pickV];
        //创建pickview上面的取消 确认按钮 的view
        UIView *chooseV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        chooseV.backgroundColor = [UIColor whiteColor];
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 50, 30)];
        [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:(UIControlEventTouchDown)];
        [chooseV addSubview:cancelBtn];
        
        UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 55, 0, 50, 30)];
        [sureBtn setTitle:@"确定" forState:(UIControlStateNormal)];
        sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sureBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:(UIControlEventTouchDown)];
        [chooseV addSubview:sureBtn];
        
        [self addSubview:chooseV];
        
    }
    return self;
}
//取消按钮
-(void)cancelBtnClick{
    __weak MyPickerV *ws=self;
    NSError *error;
    if (ws.failed) {
        ws.failed(error);
    }
}
//确定按钮
-(void)sureBtnClick{
    __weak MyPickerV *ws=self;
    if (self.locate.area.length > 0) {
        _selectedAddress = [NSString stringWithFormat:@"%@-%@- %@",self.locate.province,self.locate.city,self.locate.area];
    }else{
        _selectedAddress = [NSString stringWithFormat:@"%@-%@",self.locate.province,self.locate.city];
    }
    if (ws.success) {
        ws.success(_selectedAddress);
    }
}
//取数据
-(void)prepareData{
    //    _firstArr = [[NSMutableArray alloc]init];
    //    _secondArr = [[NSMutableArray alloc]init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"];
    _firstArr = [[NSMutableArray alloc]initWithContentsOfFile:path];
    _secondArr = [_firstArr[0] objectForKey:@"cities"];
    _thirdArr = [_secondArr[0] objectForKey:@"areas"];
    //    NSLog(@"%@",_thirdArr);
}



//列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

//列行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component==0) {
        return _firstArr.count;
    }else if (component==1){
        return _secondArr.count;
    }else {
        return _thirdArr.count;
    }
    
}
//每一列宽度
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (_firstComponentW != 0) {
        if (component == 0) {
            return _firstComponentW;
        }else if (component == 1){
            return _secondComponentW;
        }else{
            return _thirdComponentW;
        }
    }else{
        return self.frame.size.width/3.0;
    }
    
}

//显示
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component==0) {
        return [_firstArr[row] objectForKey:@"state"];
    }else if (component==1){
        return [_secondArr[row] objectForKey:@"city"];
    }
    return _thirdArr[row];
    
}

//选中后
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component==0) {
        _secondArr = [_firstArr[row] objectForKey:@"cities"];
        _thirdArr = [_secondArr[0] objectForKey:@"areas"];
        
        self.locate.province = [_firstArr[row] objectForKey:@"state"];
        if (_secondArr.count > 0) {
            self.locate.city = [_secondArr[0] objectForKey:@"city"];
        }
        if (_thirdArr.count > 0) {
            self.locate.area = _thirdArr[0];
        }else{
            self.locate.area = @"";
        }
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }else if (component==1){
        _thirdArr = [_secondArr[row] objectForKey:@"areas"];
        self.locate.city = [_secondArr[row] objectForKey:@"city"];
        if (_thirdArr.count > 0) {
            self.locate.area = _thirdArr[0];
        }else{
            self.locate.area = @"";
        }
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }else{
        if (_thirdArr.count > 0) {
            self.locate.area = _thirdArr[row];
        }
    }
}

//每一列每一行的图view
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    _selectedAddress = [NSMutableString new];
    UILabel *label = [[UILabel alloc]init];
    if (component == 0) {
        label.text = [_firstArr[row] objectForKey:@"state"];
    }else if (component==1){
        label.text =  [_secondArr[row] objectForKey:@"city"];
    }else{
        label.text =  _thirdArr[row];
    }
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}






@end
