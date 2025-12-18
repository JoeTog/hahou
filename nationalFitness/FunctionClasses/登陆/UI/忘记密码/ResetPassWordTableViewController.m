


//
//  ResetPassWordTableViewController.m
//  nationalFitness
//
//  Created by joe on 2017/12/18.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ResetPassWordTableViewController.h"

@interface ResetPassWordTableViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ChatHandlerDelegate,MBSliderViewDelegate>
@property(nonatomic,strong)HCDTimer *timer;

@end

@implementation ResetPassWordTableViewController{
    
    __weak IBOutlet UITextField *phoneNumberTextF;
    
    __weak IBOutlet UITextField *verificationTextF;
    
    __weak IBOutlet UIButton *canSeebtn;
    
    __weak IBOutlet UITextField *passwordTextfield;
    
    __weak IBOutlet UITextField *surePasswordTextfield;
    
    __weak IBOutlet UIButton *codeBtn;
    
    __weak IBOutlet UIButton *commitBtn;
    
    __weak IBOutlet NSLayoutConstraint *commitBtnCenterConstaint;
    
    
    NSTimer * timer_;
    //秒 发送成功倒计时
    int secTime_;
    //秒 发送验证码请求倒计时【滑块滑倒右边 当发送失败时【没网、返回报错、返回超时】】
    int requestOverTime_;
    BOOL notFirstCome_;
    
    forgetPassHeadView *headView;
    SocketModel * socketModel;
    
    UILabel *countDownLabel; //倒计时label
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    [self initSocket];
    [self initColor];
    
//    __block id Field;
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    });
//        UIView *statusBar;
//    if ([Field isKindOfClass:[UIView class]]) {
//        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    }
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    UIView *statusBar;
    if (version.doubleValue >= 13.0) {
        //        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        //        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
        //            UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
        //            if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
        //                statusBar = [_localStatusBar performSelector:@selector(statusBar)];
        //            }
        //        }
    }else{
        __block id Field;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        });
        if ([Field isKindOfClass:[UIView class]]) {
            statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        }
    }
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor colorThemeColor];
        statusBar.backgroundColor = [UIColor colorNavigationBackground];
        //        statusBar.backgroundColor = UIColorFromRGB(0x503536);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
//    self.navigationItem.title =@"重置密码";
    
    [self initUI];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyBoard:)];
    
    [self.tableView addGestureRecognizer:tap];
    
}

-(void)initUI{
    SystemInfo *systemInfo = [SystemInfo shareSystemInfo];
    NSString *type = [[UIDevice currentDevice] model];
    if (SCREEN_WIDTH == 320) {
        commitBtnCenterConstaint.constant = -20;
    }
    if ([type isEqualToString:@"iPad"]){
        commitBtnCenterConstaint.constant = -40;
    }
    
    self.tableView.scrollEnabled = NO;
    passwordTextfield.secureTextEntry = NO;
    surePasswordTextfield.secureTextEntry = NO;
    
    phoneNumberTextF.keyboardType = UIKeyboardTypeASCIICapable;
    passwordTextfield.keyboardType = UIKeyboardTypeASCIICapable;
    surePasswordTextfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x60636a)}];
    phoneNumberTextF.keyboardType = UIKeyboardTypeASCIICapable;
    
    //需要有headview
    headView = [[[NSBundle mainBundle]loadNibNamed:@"forgetPassHeadView" owner:nil options:nil] firstObject];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    headView.backgroundColor = [UIColor colorNavigationBackground];
    headView.backimageV.image = [UIImage imageNamed:@"表头底图"];
    [headView.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    headView.titleText.text = @"重置密码";
    self.tableView.tableHeaderView = headView;
    
    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛未选中"] forState:(UIControlStateNormal)];
    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛"] forState:(UIControlStateSelected)];
    canSeebtn.selected = YES;
    
    self.firstLabel.textColor = UIColorFromRGB(0x455C8A);
    self.secondLabel.textColor = UIColorFromRGB(0x455C8A);
    self.thirdLabel.textColor = UIColorFromRGB(0x455C8A);
    self.forthLabel.textColor = UIColorFromRGB(0x455C8A);
    
    self.firstLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.secondLinelbasle.backgroundColor = UIColorFromRGB(0x455C8A);
    self.thirdLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.forthLinelabel.backgroundColor = UIColorFromRGB(0x455C8A);
    
    self.firstLabel.font = [UIFont boldSystemFontOfSize:18];
    self.secondLabel.font = [UIFont boldSystemFontOfSize:18];
    self.thirdLabel.font = [UIFont boldSystemFontOfSize:20];
    self.forthLabel.font = [UIFont boldSystemFontOfSize:20];
    commitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    //self.tableView.backgroundColor = UIColorFromRGB(0x37373c);
    self.tableView.backgroundColor= [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    
    UIImageView*imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"登录背景"]];
    self.tableView.backgroundView = imageView;
}

-(void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initSocket{
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            
        }else{
            //            [socketModel initSocket];
        }
    }else{
        //        [socketModel initSocket];
    }
}

-(void)initColor{
    phoneNumberTextF.textColor = [UIColor whiteColor];
    //    numberLabel.textColor = [UIColor colorMainTextColor];
    passwordTextfield.textColor = [UIColor whiteColor];
    //    [commitBtn setTitleColor:[UIColor colorThemeColor] forState:(UIControlStateNormal)];
    ViewBorderRadius(codeBtn, 3, 1, [UIColor colorMainTextColor]);
    ViewRadius(commitBtn, 3);
}

#pragma mark - 发送验证码
- (IBAction)getCodeBtnClick:(id)sender {
    [self.view endEditing:YES];
    if (phoneNumberTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }
    if (phoneNumberTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
        return;
    }
    [self verificationRequest];
}

#pragma mark - 验证码请求
-(void)verificationRequest{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"regPhoneVerify";
    self.parms[@"phone"] = phoneNumberTextF.text;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    //for 循环请求 当连接时候进行发送
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
//    secTime_ = 59;
//    [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
//    __weak typeof(self)weakSelf=self;
//    self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
//        __strong typeof(weakSelf)strongSelf=weakSelf;
//        strongSelf ->secTime_--;
//        if (strongSelf ->secTime_ == 0)
//        {
//            [strongSelf.timer invalidate];
//            [codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
//
//        }
//        else
//        {
//            [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
//        }
//    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
//    if (phoneNumberTextF.text.length == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
//        return YES;
//    }
//    if (passwordTextfield.text.length == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
//        return YES;
//    }
//    if (phoneNumberTextF.text.length < 6) {
//        [SVProgressHUD showInfoWithStatus:@"账号长度不得低于6位"];
//        return YES;
//    }
//    if (passwordTextfield.text.length == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
//        return YES;
//    }
//    int a = [[NFMyManage new] checkIsHaveNumAndLetter:passwordTextfield.text];
//    if (a!=3) {
//        [SVProgressHUD showInfoWithStatus:@"请输入数字、字母组合密码"];
//        return YES;
//    }
//    //surePasswordTextfield passwordTextfield
//    if (![passwordTextfield.text isEqualToString:surePasswordTextfield.text]) {
//        [SVProgressHUD showInfoWithStatus:@"密码输入不一致"];
//        return YES;
//    }
//
//    if ([self.myManage checkIsHaveNumAndLetter:phoneNumberTextF.text] == 4) {
//        [SVProgressHUD showInfoWithStatus:@"账号不能含有特殊符号"];
//        return YES;
//    }
//    if ([self.myManage checkIsHaveNumAndLetter:passwordTextfield.text] == 4) {
//        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
//        return YES;
//    }
    
    return YES;
}

#pragma mark - 真重置校验
- (IBAction)commitBtnClick:(id)sender {
    [self.view endEditing:YES];
    //numberLabel
    if (phoneNumberTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }
    if (verificationTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入验证码"];
        return;
    }
    if (passwordTextfield.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
        return;
    }
    int a = [[NFMyManage new] checkIsHaveNumAndLetter:passwordTextfield.text];
    if (a!=3) {
        [SVProgressHUD showInfoWithStatus:@"请输入数字、字母组合密码"];
        return;
    }
    //surePasswordTextfield passwordTextfield
    if (![passwordTextfield.text isEqualToString:surePasswordTextfield.text]) {
        [SVProgressHUD showInfoWithStatus:@"密码输入不一致"];
        return;
    }
    
    if ([self.myManage checkIsHaveNumAndLetter:phoneNumberTextF.text] == 4) {
        [SVProgressHUD showInfoWithStatus:@"账号不能含有特殊符号"];
        return ;
    }
    if ([self.myManage checkIsHaveNumAndLetter:passwordTextfield.text] == 4) {
        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
        return ;
    }
    
    [self zhuceClick];
}

#pragma mark - 是否显示明文
- (IBAction)isLookPasswordClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        passwordTextfield.secureTextEntry = NO;
        surePasswordTextfield.secureTextEntry = NO;
    }else{
        passwordTextfield.secureTextEntry = YES;
        surePasswordTextfield.secureTextEntry = YES;
    }
}

#pragma mark - 真重置密码重连
-(void)zhuceClick{
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
        return;
    }
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [SVProgressHUD show];
            [self registerNewAccount];
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
                [weakSelf registerNewAccount];
            }
        }];
    }
}

#pragma mark - 真重置密码请求
-(void)registerNewAccount{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"resetPassword";
    self.parms[@"phone"] = phoneNumberTextF.text;
    self.parms[@"regCode"] = verificationTextF.text;
//    self.parms[@"regCode"] = verfication;
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:passwordTextfield.text];
    self.parms[@"password"] = pwd;
    
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
    if (messageType == SecretLetterType_RegisterReceipt) {
        [SVProgressHUD showInfoWithStatus:@"修改成功"];
        __weak typeof(self)weakSelf=self;
        [[NFbaseViewController new] createDispatchWithDelay:1 block:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }];//
    }else if(messageType == SecretLetterType_RegisterVerication){
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
    }else if (messageType == SecretLetterType_RegisterVericationOften){
        if (![chatModel isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *backDict = chatModel;
        //发送验证码频繁
        [_MBSlider setText:@"验证码发送频繁"];
        countDownLabel.hidden = NO;
        secTime_ = [[NFMyManage getCurrentTimeStamp] intValue] - [[backDict objectForKey:@"last_time"] intValue];
        secTime_ = 60 - secTime_;
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
    }else if (messageType == SecretLetterType_RegisterVericationRetSuccess){
//        [SVProgressHUD showInfoWithStatus:@"修改成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([chatModel isKindOfClass:[NSDictionary class]]) {
                NSDictionary *backDict = chatModel;
                __weak typeof(self)weakSelf=self;
                MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"您账号为%@的密码已经变更，请知晓！",[backDict objectForKey:@"name"]] sureBtn:@"确认" cancleBtn:nil];
                alertView.resultIndex = ^(NSInteger index)
                {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                };
                [alertView showMKPAlertView];
            }
        });
        
    }else if (messageType == SecretLetterType_RegisterVericationAlreadyError){
        [SVProgressHUD showInfoWithStatus:@"验证码错误"];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    //    cell.backgroundColor = [UIColor whiteColor];
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            SystemInfo *systemInfo = [SystemInfo shareSystemInfo];
            NSString *type = [[UIDevice currentDevice] model];
            if ([type isEqualToString:@"iPad"]) {
                return 10;
            }
            return 60;
        }
        //        else if (indexPath.row == 2){
        //            return 0.1;
        //        }
    }
    return [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 2){
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
        _MBSlider.backgroundColor = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:244/255.0 alpha:1.0];
        //边角弧度
        _MBSlider.layer.cornerRadius = 3.0;
        //设置显示字体
        [_MBSlider setText:@"滑动发送验证码"];
        //滑块颜色
        [_MBSlider setThumbColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:153/255.0 alpha:1.0]];
        //闪动字体颜色
        [_MBSlider setLabelColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:153/255.0 alpha:1.0]];
        //设置代理
        [_MBSlider setDelegate:self];
        
        if (!countDownLabel) {
            countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 , 10, 25, 35.0)];
        }
        countDownLabel.font = [UIFont systemFontOfSize:17];
        countDownLabel.textColor = [UIColor whiteColor];
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

#pragma mark - 滑动成功发送验证码
- (void) sliderDidSlide:(MBSliderView *)slideView {
    if (![KeepAppBox isValidatePhone:phoneNumberTextF.text]) {
        [SVProgressHUD showInfoWithStatus:@"请输入合法手机号"];
        return;
    }
    switch ((long)slideView.tag) {
        case 0:{
            NSLog(@"Happy New Year!");
            [_MBSlider setText:@"验证码发送中"];
            _MBSlider.enabled = NO;
            //进行网络请求
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
            
            
//            countDownLabel.hidden = NO;
//            secTime_ = 59;
//            countDownLabel.text = [NSString stringWithFormat:@"%d",secTime_];
////            __weak typeof(self)weakSelf=self;
//            self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
//                __strong typeof(weakSelf)strongSelf=weakSelf;
//                strongSelf ->secTime_--;
//                if (strongSelf ->secTime_ == 0)
//                {
//                    [strongSelf.timer invalidate];
//                    [weakSelf.MBSlider setText:@"滑动发送验证码"];
//                    weakSelf.MBSlider.enabled = YES;
//                    countDownLabel.hidden = YES;
//                }
//                else
//                {
//                    countDownLabel.text = [NSString stringWithFormat:@"%d",secTime_];
//                }
//            }];
        }
    }
}

#pragma mark - 隐藏键盘
-(void)tapHideKeyBoard:(UITapGestureRecognizer *)recognizer{
    
    [self.view endEditing:YES];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
