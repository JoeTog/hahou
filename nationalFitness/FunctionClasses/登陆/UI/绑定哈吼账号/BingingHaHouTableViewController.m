

//
//  BingingHaHouTableViewController.m
//  nationalFitness
//
//  Created by joe on 2017/12/26.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "BingingHaHouTableViewController.h"

@interface BingingHaHouTableViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ChatHandlerDelegate,MBSliderViewDelegate>
@property(nonatomic,strong)HCDTimer *timer;
@end

@implementation BingingHaHouTableViewController{
    
    __weak IBOutlet UITextField *phoneNumberTextF;//手机号
    
    __weak IBOutlet UITextField *verificationTextF;//验证码
    
    __weak IBOutlet UITextField *numberLabel;//账户
    
    __weak IBOutlet UITextField *passwordTextfield;//密码
    
    __weak IBOutlet UIButton *commitBtn;//确定
    
    __weak IBOutlet UIButton *canSeebtn;
    
    __weak IBOutlet NSLayoutConstraint *commitCenterCinstaint;
    
    NSTimer * timer_;
    //秒
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
        //statusBar.backgroundColor = [UIColor colorThemeColor];
        //statusBar.backgroundColor = [UIColor colorNavigationBackground];
        //        statusBar.backgroundColor = UIColorFromRGB(0x503536);
        statusBar.backgroundColor = [UIColor clearColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
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
        statusBar.backgroundColor = [UIColor clearColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationItem.title =@"绑定多信账号";
    
    [self initUI];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyBoard:)];
    
    [self.tableView addGestureRecognizer:tap];
    
    
    
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
    
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    int a = [self.myManage checkIsHaveNumAndLetter:string];
    if (textField.tag == 11) {
        if (textField.text.length + string.length - range.length >20) {
            [SVProgressHUD showInfoWithStatus:@"账号不得超过20位"];
            return NO;
        }
        if (a != 4) {
            return YES;
        }else{
            [SVProgressHUD showInfoWithStatus:@"请输入合法帐号"];
            return NO;
        }
    }
    if (textField.text.length + string.length - range.length > 20) {
        [SVProgressHUD showInfoWithStatus:@"密码过长"];
        return NO;
    }
    if (a != 4) {
        return YES;
    }else{
        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
        return NO;
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    //直接进行绑定
//    [self bingingRepeat];
    
    return YES;
}

-(void)initColor{
    
    passwordTextfield.textColor = [UIColor whiteColor];
    
    ViewRadius(commitBtn, 3);
    
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


-(void)initUI{
    SystemInfo *systemInfo = [SystemInfo shareSystemInfo];
    NSString *type = [[UIDevice currentDevice] model];
    if (SCREEN_WIDTH == 320 || [type isEqualToString:@"iPad"]) {
        commitCenterCinstaint.constant = -40;
    }
    
    self.tableView.scrollEnabled = NO;
    passwordTextfield.secureTextEntry = NO;
    
    phoneNumberTextF.keyboardType = UIKeyboardTypeNumberPad;
    passwordTextfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x60636a)}];
    numberLabel.keyboardType = UIKeyboardTypeASCIICapable;
    
    //需要有headview
    headView = [[[NSBundle mainBundle]loadNibNamed:@"forgetPassHeadView" owner:nil options:nil] firstObject];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    //headView.backgroundColor = [UIColor colorNavigationBackground];;
//    [headView.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    headView.backBtn.hidden = YES;
    [headView.passBtn addTarget:self action:@selector(passClick) forControlEvents:UIControlEventTouchUpInside];
    headView.titleText.text = @"用户注册";
//    self.tableView.tableHeaderView = headView;
    
    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛未选中"] forState:(UIControlStateNormal)];
    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛"] forState:(UIControlStateSelected)];
    canSeebtn.selected = YES;
    //    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛未选中"] forState:(UIControlStateSelected)];
    
    self.firstLabel.textColor = UIColorFromRGB(0x455C8A);
    self.secondlabel.textColor = UIColorFromRGB(0x455C8A);
    self.thirdLabel.textColor = UIColorFromRGB(0x455C8A);
    self.forthLabel.textColor = UIColorFromRGB(0x455C8A);
    
    self.firstLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.secondLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.thirdLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.forthLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    
    self.firstLabel.font = [UIFont boldSystemFontOfSize:18];
    self.secondlabel.font = [UIFont boldSystemFontOfSize:18];
    self.thirdLabel.font = [UIFont boldSystemFontOfSize:20];
    self.forthLabel.font = [UIFont boldSystemFontOfSize:20];
    commitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
//    self.tableView.backgroundColor = UIColorFromRGB(0x37373c);
    
    self.tableView.backgroundColor= [UIColor clearColor];
    UIImageView*imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"登录背景"]];
    self.tableView.backgroundView = imageView;
    
}

-(void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 跳过
-(void)passClick{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
}


#pragma mark - 是否显示明文
- (IBAction)isLookPasswordClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        passwordTextfield.secureTextEntry = NO;
    }else{
        passwordTextfield.secureTextEntry = YES;
    }
}

#pragma mark - 真确定检验
- (IBAction)commit:(id)sender {
    [self.view endEditing:YES];
    //numberLabel
    if (phoneNumberTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }
    if (verificationTextF.text.length < 6) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确验证码"];
        return;
    }
    if (numberLabel.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
        return;
    }
    if (numberLabel.text.length < 6) {
        [SVProgressHUD showInfoWithStatus:@"账号长度不得低于6位"];
        return;
    }
    if (passwordTextfield.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
        return;
    }
    if ([[NFMyManage new] checkIsHaveNumAndLetter:passwordTextfield.text] != 3) {
        [SVProgressHUD showInfoWithStatus:@"请输入数字字母组合密码"];
        return;
    }
    if ([self.myManage checkIsHaveNumAndLetter:numberLabel.text] == 4) {
        [SVProgressHUD showInfoWithStatus:@"账号不能含有特殊符号"];
        return ;
    }
    if ([self.myManage checkIsHaveNumAndLetter:passwordTextfield.text] == 4) {
        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
        return ;
    }
    //直接进行绑定
    [self bingingRepeat];
    
//    [self zhuCeRepeat];
}

#pragma mark - 这里不走了
//-(void)zhuCeRepeat{
//    if (![ClearManager getNetStatus]) {
//        [SVProgressHUD showInfoWithStatus:@"网络异常"];
//        return;
//    }
//    if (socketModel.isConnected) {
//        [socketModel ping];
//        if (socketModel.isConnected) {
//            [SVProgressHUD show];
//            [self registerNewAccount];
//        }
//    }else{
//        [socketModel initSocket];
//        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        __weak UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//        __weak typeof(self)weakSelf=self;
//        [socketModel returnConnectSuccedd:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            if (![currentVC isKindOfClass:[BingingHaHouTableViewController class]]) {
//                return ;
//            }
//            if ([strongSelf ->socketModel isConnected]) {
//                [strongSelf ->socketModel ping];
//            }
//            if ([strongSelf ->socketModel isConnected]) {
//                [SVProgressHUD show];
//                [weakSelf registerNewAccount];
//            }
//        }];
//    }
//}

#pragma mark - 真注册请求 这里不走了
//-(void)registerNewAccount{
//    [self.parms removeAllObjects];
//    self.parms[@"username"] = numberLabel.text;
//    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:passwordTextfield.text];
//    NSLog(@"上传服务器验证的密码:%@",pwd);
//    self.parms[@"password"] = pwd;
//    self.parms[@"regCode"] = verificationTextF.text;
//    self.parms[@"phone"] = phoneNumberTextF.text;
//    self.parms[@"action"] = @"registerUser";
//    NSString *Json = [JsonModel convertToJsonData:self.parms];
//    //for 循环请求 当连接时候进行发送
//    [socketModel ping];
//    if ([socketModel isConnected]) {
//        [socketModel sendMsg:Json];
//    }else{
//        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
//    }
//}


#pragma mark - 真绑定多信账号操作 重连
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

#pragma mark - 真绑定请求
-(void)bingingAccountRequewst{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"bangAccount";
    self.parms[@"bangUserName"] = numberLabel.text;
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:passwordTextfield.text];
    self.parms[@"bangUserPwd"] = pwd;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"phone"] = phoneNumberTextF.text;
    self.parms[@"regCode"] = verificationTextF.text;
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
    if (messageType == SecretLetterType_RegisterVericationBingingSuccess) {
        if (![chatModel isKindOfClass:[NSDictionary class]]) {
            [SVProgressHUD showErrorWithStatus:@"服务器返回错误"];
            return;
        }
        NSDictionary *backDict = chatModel;
        [SVProgressHUD showSuccessWithStatus:@"绑定成功,身份已经过期!"];
        NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
        //将原来的数据库名修改成绑定后返回的username
        NSFileManager * manager = [NSFileManager defaultManager];
        //NSString *oldPath = [NSString stringWithFormat:@"%@/%@%@",cachPath,[NFUserEntity shareInstance].userName,@"tongxun.sqlite"];
        NSString *newPath = [NSString stringWithFormat:@"%@/%@%@",cachPath,[backDict objectForKey:@"userName"],@"tongxun.sqlite"];
        if ([manager fileExistsAtPath:newPath]) {
            BOOL ret = [manager removeItemAtPath:newPath error:nil];
            if (ret) {
                NSLog(@"");
            }
        }
        //    [manager createFileAtPath:[NSString stringWithFormat:@"%@/%@%@",cachPath,@"newPath",@"tongxun"] contents:nil attributes:nil];
        NSError *error;
        BOOL ret =  [manager moveItemAtPath:[NSString stringWithFormat:@"%@/%@%@",cachPath,[NFUserEntity shareInstance].userName,@"tongxun.sqlite"] toPath:[NSString stringWithFormat:@"%@/%@%@",cachPath,[backDict objectForKey:@"userName"],@"tongxun.sqlite"] error:&error];
        if (!ret) {
            NSLog(@"%@",error);
        }
        
        //绑定成功 提示身份过期 请重新登录
        [NFUserEntity shareInstance].userId = @"";
        [KeepAppBox keepVale:[backDict objectForKey:@"userName"] forKey:kLoginUserName];
        [KeepAppBox keepVale:@"" forKey:kLoginPassWord];
        [KeepAppBox keepVale:@"" forKey:kLoginWeixinUserName];
        [self  performSelector:@selector(popToRoot) withObject:nil afterDelay:2];
        
    }else if (messageType == SecretLetterType_RegisterReceipt){
        //注册成功 立马进行绑定多信账号
        [self bingingRepeat];
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
    }else if (messageType == SecretLetterType_RegisterVericationAlreadyBinging){
        [SVProgressHUD showInfoWithStatus:@"该手机号已经被绑定"];
    }
}

-(void)popToRoot{
    [NFUserEntity shareInstance].userId = @"";
    [KeepAppBox keepVale:@"" forKey:kLoginPassWord];
    [KeepAppBox keepVale:@"" forKey:kLoginWeixinUserName];
    socketModel = [SocketModel share];
//    [socketModel disConnect];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_LgoinHome];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
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

#pragma mark - 滑动完发送验证码
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
