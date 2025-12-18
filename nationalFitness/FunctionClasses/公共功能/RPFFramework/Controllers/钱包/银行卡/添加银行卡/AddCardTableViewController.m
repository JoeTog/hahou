
//
//  AddCardTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/1/11.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "AddCardTableViewController.h"

#import "SocketModel.h"
#import "SocketRequest.h"
#import "HCDTimer.h"


@interface AddCardTableViewController ()<ChatHandlerDelegate,UITextFieldDelegate>
@property(nonatomic,strong)HCDTimer *timer;

@end

@implementation AddCardTableViewController{
    
    __weak IBOutlet UITextField *nameTextF;
    
    __weak IBOutlet UITextField *cardIDTextF;
    
    __weak IBOutlet UITextField *phoneTextF;
    
    __weak IBOutlet UITextField *cardTypeTextF;
    
    __weak IBOutlet UITextField *cardNumTextF;
    
    __weak IBOutlet UITextField *codeTextF;
    
    
    __weak IBOutlet UIButton *codeBtn;
    
    
    __weak IBOutlet UIButton *sureBtn;
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    NSString *codeorderId;//验证码 orderid
    NSString *order_date; //订单时间
    
    
    
    NSTimer * timer_;
    //秒
    int secTime_;
    //秒 发送验证码请求倒计时【滑块滑倒右边 当发送失败时【没网、返回报错、返回超时】】
    int requestOverTime_;
    BOOL notFirstCome_;
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加银行卡";
    
    [self initColor];
    
    self.tableView.tableFooterView = [UIView new];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturedDetected)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    codeBtn.backgroundColor = UIColorFromRGB(0x5D81E0);
    
    [self initScoket];
    
//    phoneTextF.text = self.cardBank.phoneNumber;
    
    
    
}

-(void)initScoket{
    
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}


#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_NoPasswordSendSuccess) {
        //发送 验证码 成功
        NSDictionary *dict = chatModel;
        
        if(![dict isKindOfClass:[NSDictionary class]]){
            [SVProgressHUD showInfoWithStatus:@"服务器返回空"];
            return;
        }
        if ([dict objectForKey:@"resp_desc"]) {
            [SVProgressHUD showInfoWithStatus:[[dict objectForKey:@"resp_desc"] description]];
        }
        if([dict objectForKey:@"hnapayOrderId"]){
            codeorderId = [[dict objectForKey:@"hnapayOrderId"] description];
        }
//        if([dict objectForKey:@"sms_order_id"]){
//            order_date = [[dict objectForKey:@"sms_order_date"] description];
//        }
    }else if(messageType == SecretLetterType_BankCardBindResult){
        //修改成功
        [self.view endEditing:YES];
        
        NSDictionary *dict = chatModel;
        if ([dict objectForKey:@"resultCode"] && [[[dict objectForKey:@"resultCode"] description] isEqualToString:@"0000"]) {
            
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"绑定成功" sureBtn:@"确认" cancleBtn:nil];
            alertView.resultIndex = ^(NSInteger index)
            {
                [self.navigationController popViewControllerAnimated:YES];
            };
            [alertView showMKPAlertView];
            //            [SVProgressHUD showInfoWithStatus:[[dict objectForKey:@"resp_desc"] description]];
            //            if ([[[dict objectForKey:@"resp_desc"] description] containsString:@"成功"]) {
            //                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            //                    [NSThread sleepForTimeInterval:1];
            //                    dispatch_async(dispatch_get_main_queue(), ^(void) {
            //                        [self.navigationController popViewControllerAnimated:YES];
            //                    });
            //                });
            //            }
        }else if([[[dict objectForKey:@"resultCode"] description] isEqualToString:@"4444"]){
            
            [SVProgressHUD showInfoWithStatus:[[dict objectForKey:@"errorMsg"] description]];
        }
        
        if([[[dict objectForKey:@"resp_desc"] description] containsString:@"验证码不正确"]){
            codeTextF.text = @"";
        }
        if([[[dict objectForKey:@"resp_desc"] description] containsString:@"验证码不正确"]){
            codeTextF.text = @"";
            [SVProgressHUD showInfoWithStatus:@"验证码不正确"];
        }
        
        
    }
}

#pragma mark - 选择银行
- (IBAction)chooseBankClick:(UIButton *)sender {
    
}


#pragma mark - 发送验证码
- (IBAction)codeClick:(UIButton *)sender {
    
    if (cardNumTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入银行卡号"];
        return;
    }else if (phoneTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }else if (nameTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入姓名"];
        return;
    }else if (cardIDTextF.text.length < 10) {
        [SVProgressHUD showInfoWithStatus:@"请输入银行卡"];
        return;
    }else if (cardTypeTextF.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请选择银行卡类型"];
        return;
    }
    
    secTime_ = 59;
    codeBtn.userInteractionEnabled = NO;
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
            [socketRequest bindCardSendCode:@{@"holderName":nameTextF.text,@"mobileNo":phoneTextF.text,@"cardNo":cardNumTextF.text,@"identityCode":cardIDTextF.text,@"merUserIp":[NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses,@"bankName":cardTypeTextF.text}];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

- (IBAction)sureClick:(UIButton *)sender {
    
    if (codeTextF.text.length < 6) {
        [SVProgressHUD showInfoWithStatus:@"请输入验证码"];
        return;
    }
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketRequest bindCardCheckCodeAndBind:@{@"smsCode":codeTextF.text,@"merUserIp":[NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses,@"hnapayOrderId":codeorderId}];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}


-(void)tapGesturedDetected{
    [self.view endEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.tag == 8 && textField.text.length > 14) {
        BankShareManager *manager = [BankShareManager shareManager];
        BankModel *model = [manager getBankInfo:cardNumTextF.text];
        cardTypeTextF.text = model.bankName;
        if(!model){
            [SVProgressHUD showInfoWithStatus:@"无法识别银行卡号"];
        }else if(![model.bankType isEqualToString:@"DC"]){
            [SVProgressHUD showInfoWithStatus:@"目前仅支持借记卡"];
        }
    }
    
    if(phoneTextF.text.length > 10 && cardNumTextF.text.length > 14){
        
        sureBtn.backgroundColor = UIColorFromRGB(0x5D81E0);
        
    }
    
}












-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}



-(void)initColor{
    
    self.nameabel.textColor = [UIColor colorMainTextColor];
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secondLabel.textColor = [UIColor colorMainTextColor];
    self.thirdLabel.textColor = [UIColor colorMainTextColor];
    self.forthLabel.textColor = [UIColor colorMainTextColor];
    self.fifithLabelk.textColor = [UIColor colorMainTextColor];
    self.sixthlabel.textColor = [UIColor colorMainTextColor];
    
//    self.firstLabel.font = [UIFont fontMainText];
//    self.secondLabel.font = [UIFont fontMainText];
//    self.thirdLabel.font = [UIFont fontMainText];
//    self.forthLabel.font = [UIFont fontMainText];
//    self.fifithLabelk.font = [UIFont fontMainText];
//    self.sixthlabel.font = [UIFont fontMainText];
    
}

@end
