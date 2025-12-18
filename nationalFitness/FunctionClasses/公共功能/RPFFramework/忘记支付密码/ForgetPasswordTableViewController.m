//
//  ForgetPasswordTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/1/4.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "ForgetPasswordTableViewController.h"

@interface ForgetPasswordTableViewController ()<ChatHandlerDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)HCDTimer *timer;


@end

@implementation ForgetPasswordTableViewController{
    
    __weak IBOutlet UITextField *phonetextF;
    
    __weak IBOutlet UITextField *codeTextF;
    
    __weak IBOutlet UITextField *payPasswordTextF;
    
    __weak IBOutlet UIButton *codeBtn;
    
    
    
    
    __weak IBOutlet UIButton *sureBtn;
    
    
    __weak IBOutlet UIButton *backBtn;
    
    
    NSTimer * timer_;
    //秒
    int secTime_;
    //秒 发送验证码请求倒计时【滑块滑倒右边 当发送失败时【没网、返回报错、返回超时】】
    int requestOverTime_;
    BOOL notFirstCome_;
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    NSString *sms_codee;
    
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    
    [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleDefault;
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    
    [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleLightContent;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
    [self initScoket];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignClick)];
    [self.tableView addGestureRecognizer:tap];
    
    
    phonetextF.text = [NFUserEntity shareInstance].phoneNum;
    phonetextF.userInteractionEnabled = NO;
    
}

-(void)resignClick{
    [phonetextF resignFirstResponder];
    [codeTextF resignFirstResponder];
    [payPasswordTextF resignFirstResponder];
    
}


#pragma mark - 初始化socket
-(void)initScoket{
    
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    
}

-(void)initUI{
    
    self.tableView.tableFooterView = [UIView new];
    
    if(self.IsShowBack){
        backBtn.hidden = NO;
    }else{
        backBtn.hidden = YES;
    }
    
    
}


#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_RegisterVerication) {
        //发送成功
        [SVProgressHUD showInfoWithStatus:@"验证码发送成功"];
    }else if(messageType == SecretLetterType_RegisterVericationFail){
        //发送失败
        [SVProgressHUD showInfoWithStatus:@"验证码发送失败"];
    }else if(messageType == SecretLetterType_checkPayCodeSuccess){
        //验证 验证码成功 设置支付密码
        
        DCPaymentView *payAlert = [[DCPaymentView alloc]init];
        payAlert.title = @"设置支付密码";
        payAlert.detail = [NSString stringWithFormat:@"请输入6位数字"];
        payAlert.amount= 0;
        [payAlert setAmountLabelHidden:YES];
        [payAlert show];
        payAlert.completeHandle = ^(NSString *inputPwd) {
            //请求网络，设置支付密码
            [self setMyPayPassword:inputPwd];
        };
        
    }else if (messageType == SecretLetterType_setPasswordSuccess){
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"修改成功" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            //设置密码成功
            [self.navigationController popViewControllerAnimated:YES];
            
        };
        [alertView showMKPAlertView];
        
    }
    
}

- (IBAction)backClick:(id)sender {
    
    //返回到上一页
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    
    
}



- (IBAction)getCodeClick:(UIButton *)sender {
    
    
    if (![KeepAppBox isValidatePhone:phonetextF.text]) {
        [SVProgressHUD showInfoWithStatus:@"请输入合法手机号"];
        return;
    }
    
    secTime_ = 59;
    [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
    codeBtn.backgroundColor = [UIColor lightGrayColor];
    codeBtn.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf=self;
    self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf ->secTime_--;
        if (strongSelf ->secTime_ == 0)
        {
            [strongSelf.timer invalidate];
            [codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
            codeBtn.backgroundColor = UIColorFromRGB(0x5D81E0);
            codeBtn.userInteractionEnabled = YES;
            
        }
        else
        {
            [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
        }
    }];
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            //定时检查 是否有退回
            [socketRequest forgetPayPasswordSendCode:phonetextF.text];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}

//确定
- (IBAction)sureClick:(UIButton *)sender {
    
    if (![KeepAppBox isValidatePhone:phonetextF.text]) {
        [SVProgressHUD showInfoWithStatus:@"请输入合法手机号"];
        return;
    }
    
    if (codeTextF.text.length != 6) {
        
        [SVProgressHUD showInfoWithStatus:@"验证码格式错误"];
        return;
    }
    
//    if (codeTextF.text.length != 6) {
//
//        [SVProgressHUD showInfoWithStatus:@"请输入六位支付密码"];
//        return;
//    }
    
    sms_codee = [NSString stringWithFormat:@"%@",codeTextF.text];
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            //
            [socketRequest changePayPasswordSendCode:@{@"sms_code":codeTextF.text}];
            //[SVProgressHUD showInfoWithStatus:@"功能暂未开放"];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
    
}



//设置支付密码
-(void)setMyPayPassword:(NSString *)newPWD
{
    
    [socketRequest setpasswordWirhPassword:newPWD AndCode:sms_codee.length>0?sms_codee:@""];
    
    
}




-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [phonetextF resignFirstResponder];
    [codeTextF resignFirstResponder];
    [payPasswordTextF resignFirstResponder];
    
    
}



@end
