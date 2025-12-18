//
//  SubAccountTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2020/2/29.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "SubAccountTableViewController.h"


#import "SocketModel.h"
#import "SocketRequest.h"


@interface SubAccountTableViewController ()<ChatHandlerDelegate,UITextFieldDelegate>
@property(nonatomic,strong)HCDTimer *timer;

@end

@implementation SubAccountTableViewController{
    
    
    __weak IBOutlet UITextField *nameTextF;
    
    __weak IBOutlet UITextField *cardNumTextF;
    
    __weak IBOutlet UITextField *phoneTextF;
    
    //验证码输入框
    __weak IBOutlet UITextField *codeTextF;
    
    
    __weak IBOutlet UIButton *codeBtn;
    
    __weak IBOutlet UIButton *sureBtn;
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    
    NSTimer * timer_;
    //秒
    int secTime_;
    //秒 发送验证码请求倒计时【滑块滑倒右边 当发送失败时【没网、返回报错、返回超时】】
    int requestOverTime_;
    BOOL notFirstCome_;
    
    
    NSString *codeorderId;
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.title = @"实名认证";
    
    nameTextF.delegate = self;
    cardNumTextF.delegate = self;
    phoneTextF.delegate = self;
    
    
    [self initScoket];
    
    
    
    UIButton *AddBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //[AddBtn setTitle:@"列表" forState:(UIControlStateNormal)];
    [AddBtn addTarget:self action:@selector(ListClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *AddBtnItem = [[UIBarButtonItem alloc]initWithCustomView:AddBtn];
    self.navigationItem.rightBarButtonItem = AddBtnItem;
    
    
}

-(void)ListClicked{
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketRequest SubAccountLookRequest];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
        
    }
    
    
}


-(void)initScoket{
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
}


#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_OpenAmountSuccess) {
        NSDictionary *dict = chatModel;
        if ([[[dict objectForKey:@"resp_desc"] description] containsString:@"成功"]) {
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"认证成功" sureBtn:@"确认" cancleBtn:nil];
            alertView.resultIndex = ^(NSInteger index)
            {
                
                [self.navigationController popViewControllerAnimated:YES];
            };
            [alertView showMKPAlertView];
        }else{
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:[[dict objectForKey:@"resp_desc"] description] sureBtn:@"确认" cancleBtn:nil];
            alertView.resultIndex = ^(NSInteger index)
            {
                
                
            };
            [alertView showMKPAlertView];
        }
        
    }else if (messageType == SecretLetterType_OpenAmountSuccess) {
           //发送 验证码 成功
           NSDictionary *dict = chatModel;
           if(![dict isKindOfClass:[NSDictionary class]]){
               [SVProgressHUD showInfoWithStatus:@"服务器返回空"];
               return;
           }
           if ([dict objectForKey:@"resp_desc"]) {
               [SVProgressHUD showInfoWithStatus:[[dict objectForKey:@"resp_desc"] description]];
               
           }
           
           if([dict objectForKey:@"order_id"]){
               codeorderId = [[dict objectForKey:@"order_id"] description];
               
           }
           
    }else if(messageType == SecretLetterType_RegisterVericationAlreadyError){
        [SVProgressHUD showInfoWithStatus:@"验证码错误"];
    }
    
    
}

//点击验证码按钮
- (IBAction)codeClick:(UIButton *)sender {
    
    secTime_ = 59;
    [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
    codeBtn.backgroundColor = [UIColor lightGrayColor];
    __weak typeof(self)weakSelf=self;
    self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf ->secTime_--;
        if (strongSelf ->secTime_ == 0)
        {
            [strongSelf.timer invalidate];
            [codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
            codeBtn.backgroundColor = UIColorFromRGB(0x5D81E0);
            
        }
        else
        {
            [codeBtn setTitle:[NSString stringWithFormat:@"%dS",secTime_] forState:UIControlStateNormal];
        }
    }];
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            //
            [socketRequest shimingSendCode:phoneTextF.text];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}


//确定
- (IBAction)sureClick:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if(nameTextF.text.length == 0 || cardNumTextF.text.length == 0 || phoneTextF.text.length == 0 || codeTextF.text.length == 0){
        [SVProgressHUD showInfoWithStatus:@"信息填写不完整"];
        return;
    }
    
    if(![KeepAppBox isValidatePhone:phoneTextF.text]){
        [SVProgressHUD showInfoWithStatus:@"请输入合法手机号"];
        return;
    }
    
    if(codeTextF.text.length != 6){
        [SVProgressHUD showInfoWithStatus:@"请输入合法验证码"];
        return;
    }
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketRequest OpenAccountRequest:@{@"user_name":nameTextF.text,@"id_card":cardNumTextF.text,@"user_mobile":phoneTextF.text,@"code":codeTextF.text}];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
    if(phoneTextF.text.length > 10 && cardNumTextF.text.length > 14 && nameTextF.text.length > 0){
        
        sureBtn.backgroundColor = UIColorFromRGB(0x5D81E0);
        
    }
    
}












@end
