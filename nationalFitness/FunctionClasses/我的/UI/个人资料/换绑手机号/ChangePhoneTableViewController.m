//
//  ChangePhoneTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/4/6.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "ChangePhoneTableViewController.h"




@interface ChangePhoneTableViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ChatHandlerDelegate,MBSliderViewDelegate>

@property(nonatomic,strong)HCDTimer *timer;
@end

@implementation ChangePhoneTableViewController{
    
    
    __weak IBOutlet UITextField *phoneTextF;
    
    
    __weak IBOutlet UITextField *verificationTextF;
    
    
    NSTimer * timer_;
    //秒
    int secTime_;
    //秒 发送验证码请求倒计时【滑块滑倒右边 当发送失败时【没网、返回报错、返回超时】】
    int requestOverTime_;
    BOOL notFirstCome_;
    
    
    SocketModel * socketModel;
    UILabel *countDownLabel; //倒计时label
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.navigationItem.title =@"换绑手机号";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyBoard:)];
    
    [self.tableView addGestureRecognizer:tap];
    
    
    [self initScoket];
    
    
}

-(void)initScoket{
    //初始化
//    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
}



#pragma mark - 隐藏键盘
-(void)tapHideKeyBoard:(UITapGestureRecognizer *)recognizer{
    NSLog(@"%f",self.tableView.contentOffset.y);
    if (self.tableView.contentOffset.y > 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.contentOffset = CGPointMake(0, -20);
        }];
    }
    [self.view endEditing:YES];
}


//squ额定按钮a点击
- (IBAction)commitClick:(id)sender {
    
    [self.view endEditing:YES];
    //numberLabel
    if (phoneTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }
    if (verificationTextF.text.length < 6) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确验证码"];
        return;
    }
    
    //直接进行 换绑
    [self bingingRepeat];
    
    
}

#pragma mark -
-(void)bingingRepeat{
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
        return;
    }
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [SVProgressHUD show];
            [self bingingAccountRequewst];
        }
    }else{
        [socketModel initSocket];
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        __weak UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        __weak typeof(self)weakSelf=self;
        [socketModel returnConnectSuccedd:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (![currentVC isKindOfClass:[ForgetPassWordViewController class]]) {
                return ;
            }
            if ([strongSelf ->socketModel isConnected]) {
                [strongSelf ->socketModel ping];
            }
            if ([strongSelf ->socketModel isConnected]) {
                [SVProgressHUD show];
                [weakSelf bingingAccountRequewst];
            }
        }];
    }
}

#pragma mark -
-(void)bingingAccountRequewst{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"bindPhone_2";
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"phone"] = phoneTextF.text;
    self.parms[@"code"] = verificationTextF.text;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    //for 循环请求 当连接时候进行发送
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}



#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_RegisterVericationAlreadyBinging) {
        [SVProgressHUD showInfoWithStatus:@"该账号已经被其他账号绑定"];
        
    }else if (messageType == SecretLetterType_RegisterVerication){
        //发送验证码成功
        [_MBSlider setText:@"验证码发送成功"];
        countDownLabel.hidden = NO;
        secTime_ = 59;
        if (requestOverTime_ > 0) {
            requestOverTime_ = 0;
            [self.timer invalidate];
        }
        countDownLabel.text = [NSString stringWithFormat:@"%d",secTime_];
        __weak typeof(self)weakSelf=self;
        self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            strongSelf ->secTime_--;
            if (strongSelf ->secTime_ == 0)
            {
                [strongSelf.timer invalidate];
                [strongSelf.MBSlider setText:@"滑动发送验证码"];
                strongSelf.MBSlider.enabled = YES;
                countDownLabel.hidden = YES;
            }
            else
            {
                countDownLabel.text = [NSString stringWithFormat:@"%d",secTime_];
            }
        }];
    }else if(messageType == SecretLetterType_UserHuanBingSuccess){
        [SVProgressHUD dismiss];
        [NFUserEntity shareInstance].phoneNum = phoneTextF.text;
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"更换绑定成功" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
    }
    
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 1){
        static NSString *cellId = @"cellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cellId"];
        }
        //添加滑块
        _MBSlider = [[MBSliderView alloc] initWithFrame:CGRectMake(50.0, 10, [[UIScreen mainScreen] bounds].size.width-40-15-35, 35.0)];
        _MBSlider.tag = 0;
        //边框颜色
        _MBSlider.layer.borderWidth = 1;
        _MBSlider.layer.borderColor =  [[UIColor orangeColor] CGColor];
        //背景颜色
        _MBSlider.backgroundColor = [UIColor colorWithRed:255/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        //边角弧度
        _MBSlider.layer.cornerRadius = 3.0;
        //设置显示字体
        [_MBSlider setText:@"滑动发送验证码"];
        //滑块颜色
        [_MBSlider setThumbColor:[UIColor colorWithRed:255/255.0 green:109/255.0 blue:11/255.0 alpha:1.0]];
        //闪动字体颜色
        [_MBSlider setLabelColor:[UIColor colorWithRed:255/255.0 green:109/255.0 blue:11/255.0 alpha:1.0]];
        //设置代理
        [_MBSlider setDelegate:self];
        if (!countDownLabel) {
            countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 , 10, 25, 35.0)];
        }
        countDownLabel.font = [UIFont systemFontOfSize:17];
//        countDownLabel.textColor = [UIColor whiteColor];
        countDownLabel.textColor = [UIColor blackColor];
        if (secTime_ <= 0) {
            countDownLabel.hidden = YES;
        }
        [cell addSubview:_MBSlider];
        [cell addSubview:countDownLabel];
        if (secTime_ >0) {
            _MBSlider.enabled = NO;
            __weak typeof(self)weakSelf=self;
            self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                strongSelf ->secTime_--;
                if (strongSelf ->secTime_ == 0)
                {
                    [strongSelf.timer invalidate];
                    [strongSelf.MBSlider setText:@"滑动发送验证码"];
                    strongSelf.MBSlider.enabled = YES;
                    countDownLabel.hidden = YES;
                }
                else
                {
                    countDownLabel.text = [NSString stringWithFormat:@"%d",secTime_];
                }
            }];
        }
        //        [_MBSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.centerY.mas_equalTo(cell.centerY);
        //        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
}







#pragma mark - 滑动完发送验证码
- (void) sliderDidSlide:(MBSliderView *)slideView {
    if (![KeepAppBox isValidatePhone:phoneTextF.text]) {
        [SVProgressHUD showInfoWithStatus:@"请输入合法手机号"];
        return;
    }
    switch ((long)slideView.tag) {
        case 0:{
            NSLog(@"Happy New Year!");
            [_MBSlider setText:@"验证码发送中"];
            _MBSlider.enabled = NO;
            
            //进行网络请求 //需要考虑断线重连
            if (socketModel.isConnected) {
                [socketModel ping];
                if (socketModel.isConnected) {
                    [SVProgressHUD show];
                    [self verificationRequest];
                }
            }else{
                [socketModel initSocket];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                __weak UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                __weak typeof(self)weakSelf=self;
                [socketModel returnConnectSuccedd:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    if (![currentVC isKindOfClass:[ForgetPassWordViewController class]]) {
                        return ;
                    }
                    if ([strongSelf ->socketModel isConnected]) {
                        [strongSelf ->socketModel ping];
                    }
                    if ([strongSelf ->socketModel isConnected]) {
                        [SVProgressHUD show];
                        [weakSelf verificationRequest];
                    }
                }];
            }
            
            //            [self verificationRequest];
            requestOverTime_ = 10;//倒计时五秒
            __weak typeof(self)weakSelf=self;
            self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                strongSelf ->requestOverTime_--;
                if (strongSelf ->requestOverTime_ == 0)
                {
                    [strongSelf.timer invalidate];
                    [strongSelf.MBSlider setText:@"重新发送验证码"];
                    strongSelf.MBSlider.enabled = YES;
                }
            }];
        }
            break;
        case 1:
            NSLog(@"滑动来解锁");
            break;
        case 2:
            NSLog(@"滑动来获取验证码");
            break;
        case 3:
            NSLog(@"滑动来获取红包");
            break;
        default:
            break;
    }
}

//懒加载
-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}


#pragma mark - 验证码请求
-(void)verificationRequest{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"bindPhone_1";
    self.parms[@"phone"] = phoneTextF.text;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    //for 循环请求 当连接时候进行发送
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
    
}



@end
