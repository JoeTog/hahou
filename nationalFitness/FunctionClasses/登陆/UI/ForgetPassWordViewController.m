
//  ForgetPassWordViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/4/27.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ForgetPassWordViewController.h"


@interface ForgetPassWordViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ChatHandlerDelegate,MBSliderViewDelegate>
@property(nonatomic,strong)HCDTimer *timer;
@end

@implementation ForgetPassWordViewController{
    
    IBOutlet UITableView *forgetPassTableV;
    //手机号码 hiden
    __weak IBOutlet UITextField *phoneTextFidld;
    //账号 使用中
    __weak IBOutlet UITextField *numberLabel;
    
    //获取验证码按钮 hiden
    __weak IBOutlet UIButton *getCodeBtn;
    
    //密码
    __weak IBOutlet UITextField *passwordTextfield;
    
    //确认密码密码 使用中
    __weak IBOutlet UITextField *surePasswordTextfield;
    
    //确认按钮
    __weak IBOutlet UIButton *commitBtn;
    
    //是否明文显示按钮
    __weak IBOutlet UIButton *canSeebtn;
    //获取验证码
    __weak IBOutlet UIButton *codeBtn;
    //手机号
    __weak IBOutlet UITextField *phoneNumberTextF;
    //验证码
    __weak IBOutlet UITextField *verificationTextF;
    
    __weak IBOutlet NSLayoutConstraint *commitCenterCinstaint;
    
    
    
    NSTimer * timer_;
    //秒
    int secTime_;
    //秒 发送验证码请求倒计时【滑块滑倒右边 当发送失败时【没网、返回报错、返回超时】】
    int requestOverTime_;
    BOOL notFirstCome_;
    
    forgetPassHeadView *headView;
    
    duoliaoView *duoliaoHeadView;
    
    SocketModel * socketModel;
    
    UILabel *countDownLabel; //倒计时label
    
    
    BOOL noticeRet;
    
    
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
        statusBar.backgroundColor = [UIColor colorNavigationBackground];
//        statusBar.backgroundColor = UIColorFromRGB(0x503536);
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    self.navigationItem.title =@"用户注册";
    
    [self initUI];
    
    noticeRet = NO;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyBoard:)];
    
    [self.tableView addGestureRecognizer:tap];
    
}

#pragma mark - 获取验证码点击 socket
- (IBAction)getCodeBtnClick:(id)sender {
    [self.view endEditing:YES];
    if (phoneNumberTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }
    
    if (numberLabel.text.length == 0) {
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
    if (textField.tag == 12 || textField.tag == 13) {
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
    return YES;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(textField.tag == 11 && !noticeRet){
        noticeRet = YES;
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"您可以使用英文字母、数字组合设置多信号，并且不能与手机号重复！" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
        };
        [alertView showMKPAlertView];
    }
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
//    if (numberLabel.text.length == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
//        return YES;
//    }
//    if (passwordTextfield.text.length == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
//        return YES;
//    }
//    if (textField.tag == 11) {
//        if (textField.text.length >20) {
//            [SVProgressHUD showInfoWithStatus:@"账号不得超过20位"];
//            return YES;
//        }else if (textField.text.length < 6){
//            [SVProgressHUD showInfoWithStatus:@"账号不得低于6位"];
//            return YES;
//        }
//        if ([self.myManage checkIsHaveNumAndLetter:textField.text] == 4) {
//            [SVProgressHUD showInfoWithStatus:@"账号不能含有特殊符号"];
//            return YES;
//        }
//    }
//    
//    if (textField.text.length >20) {
//        [SVProgressHUD showInfoWithStatus:@"密码设置过长"];
//        return YES;
//    }
//    if ([self.myManage checkIsHaveNumAndLetter:textField.text] == 4) {
//        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
//        return YES;
//    }
//    
//    [self zhuceClick];
    
    return YES;
}

-(void)initColor{
    phoneTextFidld.textColor = [UIColor whiteColor];
//    numberLabel.textColor = [UIColor colorMainTextColor];
    passwordTextfield.textColor = [UIColor whiteColor];
    
//    [commitBtn setTitleColor:[UIColor colorThemeColor] forState:(UIControlStateNormal)];
    
    ViewBorderRadius(codeBtn, 3, 1, [UIColor colorMainTextColor]);
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
    
    forgetPassTableV.scrollEnabled = NO;
    passwordTextfield.secureTextEntry = NO;
    surePasswordTextfield.secureTextEntry = NO;
    
    phoneNumberTextF.keyboardType = UIKeyboardTypeNumberPad;
    passwordTextfield.keyboardType = UIKeyboardTypeASCIICapable;
    surePasswordTextfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x60636a)}];
    numberLabel.keyboardType = UIKeyboardTypeASCIICapable;
    
    //需要有headview
    duoliaoHeadView = [[[NSBundle mainBundle]loadNibNamed:@"duoliaoView" owner:nil options:nil] firstObject];
    duoliaoHeadView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 170);
    //duoliaoHeadView.backgroundColor = [UIColor colorNavigationBackground];;
    [duoliaoHeadView.backBtnn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    duoliaoHeadView.titleLabell.text = @"用户注册";
    forgetPassTableV.tableHeaderView = duoliaoHeadView;
    
    
//    headView = [[[NSBundle mainBundle]loadNibNamed:@"forgetPassHeadView" owner:nil options:nil] firstObject];
//    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
//    headView.backgroundColor = [UIColor colorNavigationBackground];;
//    [headView.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
//    headView.titleText.text = @"用户注册";
//    forgetPassTableV.tableHeaderView = headView;
    
    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛未选中"] forState:(UIControlStateNormal)];
    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛"] forState:(UIControlStateSelected)];
    canSeebtn.selected = YES;
//    [canSeebtn setImage:[UIImage imageNamed:@"登陆眼睛未选中"] forState:(UIControlStateSelected)];
    
    self.firstLabel.textColor = UIColorFromRGB(0x455C8A);
    self.secondlabel.textColor = UIColorFromRGB(0x455C8A);
    self.thirdLabel.textColor = UIColorFromRGB(0x455C8A);
    self.forthLabel.textColor = UIColorFromRGB(0x455C8A);
    self.fifthLabel.textColor = UIColorFromRGB(0x455C8A);
    
    self.firstLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.secondLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.thirdLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.forthLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    self.fifthLineLabel.backgroundColor = UIColorFromRGB(0x455C8A);
    
    self.firstLabel.font = [UIFont boldSystemFontOfSize:20];
    self.secondlabel.font = [UIFont boldSystemFontOfSize:20];
    self.thirdLabel.font = [UIFont boldSystemFontOfSize:20];
    self.forthLabel.font = [UIFont boldSystemFontOfSize:18];
    self.fifthLabel.font = [UIFont boldSystemFontOfSize:18];
    commitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    //self.tableView.backgroundColor = UIColorFromRGB(0x37373c);
    self.tableView.backgroundColor= [UIColor clearColor];
    UIImageView*imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"登录背景"]];
    self.tableView.backgroundView = imageView;
    
    
}

-(void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 获取验证码
- (IBAction)getCodeClick:(id)sender {
    [self.view endEditing:YES];
    if (phoneTextFidld.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }
    
    if (numberLabel.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
        return;
    }
    [self verificationManager];
    
    
}

#pragma mark - 获取验证码请求
/**
 *  获取验证码请求
 */
- (void)verificationManager
{
    [SVProgressHUD show];
    //    NSMutableDictionary *userId = [[NSMutableDictionary alloc] initWithCapacity:2];
    //    [userId setObject:[NFUserEntity shareInstance].mobile forKey:@"mobileNumber"];
    //    [userId setObject:@"3" forKey:@"flag"];;
    
    NSMutableDictionary *senDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [senDic setObject:phoneTextFidld.text forKey:@"phoneNo"];
    [senDic setObject:numberLabel.text forKey:@"account"];
    //    [senDic setObject:@"2" forKey:@"flag"];
    
    [LoginManager execute:@selector(gotVerificationManager) target:self callback:@selector(gotVerificationCallBack:) args:senDic,nil];
}

- (void)gotVerificationCallBack :(id)data
{
    NSDictionary *dict = data;
    NSLog(@"验证码：%@",[dict objectForKey:@"identityNo"]);
    if (data) {
        if ([data objectForKey:kWrongDlog]) {
            [SVProgressHUD showErrorWithStatus:[data objectForKey:kWrongDlog]];
            
        }else{
            [SVProgressHUD dismiss];
            //日后进行请求 下面定时器放在callback中
            secTime_ = 59;
            [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
            __weak typeof(self)weakSelf=self;
            self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                strongSelf ->secTime_--;
                if (strongSelf ->secTime_ == 0)
                {
                    [strongSelf.timer invalidate];
                    [codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
                    
                }
                else
                {
                    [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
                }
            }];
        }
        
    }else
    {
        [SVProgressHUD showErrorWithStatus:kDefaultMsg];
    }
    
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


#pragma mark - 真确定检验
- (IBAction)commit:(id)sender {
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
    int a = [[NFMyManage new] checkIsHaveNumAndLetter:passwordTextfield.text];
    if (a!=3) {
        [SVProgressHUD showInfoWithStatus:@"请输入数字字母组合密码"];
        return;
    }
    //surePasswordTextfield passwordTextfield
    if (![passwordTextfield.text isEqualToString:surePasswordTextfield.text]) {
        [SVProgressHUD showInfoWithStatus:@"密码输入不一致"];
        return;
    }
    
    if ([self.myManage checkIsHaveNumAndLetter:numberLabel.text] == 4) {
        [SVProgressHUD showInfoWithStatus:@"账号不能含有特殊符号"];
        return;
    }
    
    if (passwordTextfield.text.length >20) {
        [SVProgressHUD showInfoWithStatus:@"密码设置过长"];
        return;
    }
    
    if ([phoneNumberTextF.text isEqualToString:numberLabel.text]) {
        [SVProgressHUD showInfoWithStatus:@"账号不能与手机号相同"];
        return;
    }
    
//    if ([self.myManage checkIsHaveNumAndLetter:passwordTextfield.text] == 4) {
//        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
//        return;
//    }
    
    [self zhuceClick];
    
//    [self changePassWord];
    
//    [self sendRequest:nil];
    
}

#pragma mark - 真注册重连
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

#pragma mark - 真注册请求
-(void)registerNewAccount{
    [self.parms removeAllObjects];
    self.parms[@"username"] = numberLabel.text;
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:passwordTextfield.text];
    NSLog(@"上传服务器验证的密码:%@",pwd);
    self.parms[@"password"] = pwd;
    self.parms[@"regCode"] = verificationTextF.text;
    self.parms[@"phone"] = phoneNumberTextF.text;
    self.parms[@"action"] = @"registerUser";
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
        [SVProgressHUD showInfoWithStatus:@"注册成功"];
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
    }else if(messageType == SecretLetterType_RegisterVericationOften){
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
    }else if (messageType == SecretLetterType_RegisterVericationAlreadyBinging){
        //该手机号已经被某某某绑定
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *backDict =chatModel;
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"该手机号已被%@绑定",[backDict objectForKey:@"user_name"]]];
        }
    }else if (messageType == SecretLetterType_RegisterVericationAlreadyError){
        [SVProgressHUD showInfoWithStatus:@"验证码错误"];
    }
}

- (void)sendRequest:(id)sender
{
    /* Configure session, choose between:
     * defaultSessionConfiguration
     * ephemeralSessionConfiguration
     * backgroundSessionConfigurationWithIdentifier:
     And set session-wide properties, such as: HTTPAdditionalHeaders,
     HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
     */
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    /* Create session, and optionally set a NSURLSessionDelegate. */
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    
    /* Create the Request:
     Request (POST http://116.62.6.189:7999/Web/index.php)
     */
    
    NSURL* URL = [NSURL URLWithString:@"http://116.62.6.189:7999/Web/index.php"];
    NSDictionary* URLParams = @{
                                @"m": @"app",
                                @"c": @"user",
                                @"a": @"register",
                                };
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    // Headers
    
    [request addValue:@"PHPSESSID=uppokf7ijr59lif2hg679qtuk2" forHTTPHeaderField:@"Cookie"];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Form URL-Encoded Body
    
    NSDictionary* bodyParameters = @{
                                     @"username": @"222",
                                     @"password": @"eee",
                                     };
    request.HTTPBody = [NSStringFromQueryParameters(bodyParameters) dataUsingEncoding:NSUTF8StringEncoding];
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *parserDict = [parser objectWithString:aStr];
            // Success
            NSLog(@"URL Session Task Succeeded: HTTP %ld", ((NSHTTPURLResponse*)response).statusCode);
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

/*
 * Utils: Add this section before your class implementation
 */

/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
 */
static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

/**
 Creates a new URL by adding the given query parameters.
 @param URL The input URL.
 @param queryParameters The query parameter dictionary to add.
 @return A new NSURL.
 */
static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
                           [URL absoluteString],
                           NSStringFromQueryParameters(queryParameters)
                           ];
    return [NSURL URLWithString:URLString];
}





//注册http
- (IBAction)httpRequest:(id)sender {
    [self changePassWord];
}

//登陆http
- (IBAction)loginRequest:(id)sender {
    [self loginManage];
}


-(void)loginManage{
    [SVProgressHUD show];
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:passwordTextfield.text];
    [sendDic setObject:passwordTextfield.text forKey:@"email"];//906335709@qq.com
    [sendDic setObject:numberLabel.text forKey:@"user_pwd"];
    [sendDic setObject:@"1" forKey:@"auto_login"];
    [sendDic setObject:@"1" forKey:@"ajax"];
    
    [LoginManager execute:@selector(loginRequestManager) target:self callback:@selector(loginRequestManagerCallBack:) args:sendDic,nil];
    
}

- (void)loginRequestManagerCallBack :(id)data
{
    if (data)
    {
        NSDictionary *infoDict = data;
        if ([infoDict isKindOfClass:[NSDictionary class]]) {
            NSString *status = [infoDict objectForKey:@"status"];
            if ([status isEqualToString:@"1"]) {
                //成功
                [SVProgressHUD dismiss];
                
            }else if([status isEqualToString:@"0"]){
                [SVProgressHUD showInfoWithStatus:[data objectForKey:kWrongDlog]];
            }
        }else{
            [SVProgressHUD showInfoWithStatus:@"发生异常"];
        }
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:kWrongMessage];
    }
}

#pragma mark - //修改密码／注册
- (void)changePassWord
{
    [SVProgressHUD show];
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
//    [sendDic setObject:phoneTextFidld.text forKey:@"phoneNo"];
//    [sendDic setObject:codeTextField.text forKey:@"identityNo"];
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:passwordTextfield.text];
    [sendDic setObject:passwordTextfield.text forKey:@"user_pwd"];
    [sendDic setObject:numberLabel.text forKey:@"user_name"];
    [sendDic setObject:passwordTextfield.text forKey:@"confirm_user_pwd"];
    [sendDic setObject:[NSString stringWithFormat:@"%@,qq.com",numberLabel.text] forKey:@"email"];
    [sendDic setObject:@"" forKey:@"ajax"];
    [sendDic setObject:@"" forKey:@"user_verify"];
    
//    UIImage *image = [UIImage imageNamed:@"密聊logo"];
//    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
//    NSLog(@"%@",[self typeForImageData:imageData]);
    
//    NSData *imageData = UIImagePNGRepresentation(image);
    
//    NSLog(@"%@",[self typeForImageData:imageData]);
    [LoginManager execute:@selector(changePassWordManager) target:self callback:@selector(changePassWordManagerCallBack:) args:sendDic,nil];
    
}

- (void)changePassWordManagerCallBack :(id)data
{
    if (data)
    {
        NSDictionary *infoDict = data;
        if ([infoDict isKindOfClass:[NSDictionary class]]) {
            NSString *status = [infoDict objectForKey:@"status"];
            if ([status isEqualToString:@"1"]) {
                //成功
                [SVProgressHUD dismiss];
            }else if([status isEqualToString:@"0"]){
                [SVProgressHUD showInfoWithStatus:[data objectForKey:kWrongDlog]];
            }
        }else{
            [SVProgressHUD showInfoWithStatus:@"发生异常"];
        }
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:kWrongMessage];
    }
}


- (NSString *)typeForImageData:(NSData *)data {
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"image/jpeg";
            
        case 0x89:
            
            return @"image/png";
            
        case 0x47:
            
            return @"image/gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"image/tiff";
            
    }
    
    return nil;
    
}

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
//    cell.backgroundColor = [UIColor whiteColor];
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
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
            return 10;
        }else if(indexPath.row == 7){
            
            if (SCREEN_WIDTH < 414) {
                return 100;
            }
        }
//        else if (indexPath.row == 2){
//            return 0.1;
//        }
    }
    return [super tableView:forgetPassTableV heightForRowAtIndexPath:indexPath];
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
//        _MBSlider.layer.borderColor =  [[UIColor orangeColor] CGColor];
        _MBSlider.layer.borderColor =  [[UIColor clearColor] CGColor];
        //背景颜色
//        _MBSlider.backgroundColor = [UIColor colorWithRed:255/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        _MBSlider.backgroundColor = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:244/255.0 alpha:1.0];
        //边角弧度
        _MBSlider.layer.cornerRadius = 3.0;
        //设置显示字体
        [_MBSlider setText:@"滑动发送验证码"];
        //滑块颜色
        [_MBSlider setThumbColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:153/255.0 alpha:1.0]];
        //闪动字体颜色
//        [_MBSlider setLabelColor:[UIColor colorWithRed:255/255.0 green:109/255.0 blue:11/255.0 alpha:1.0]];
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
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
    
}



@end
