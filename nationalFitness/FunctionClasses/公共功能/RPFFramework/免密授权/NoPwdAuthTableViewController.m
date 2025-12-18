

//
//  NoPwdAuthTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/1/6.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "NoPwdAuthTableViewController.h"

@interface NoPwdAuthTableViewController ()<ChatHandlerDelegate,UITextFieldDelegate>
@property(nonatomic,strong)HCDTimer *timer;

@property(nonatomic,assign) BOOL isHavePayPassword;//是否设置了  发红包 支付密码
@end

@implementation NoPwdAuthTableViewController{
    
    
    __weak IBOutlet UISwitch *switchBtn;
    
    __weak IBOutlet UITextField *codeTextF;
    
    
    __weak IBOutlet UIButton *codeBtn;
    
    
    
    
    NSTimer * timer_;
    //秒
    int secTime_;
    //秒 发送验证码请求倒计时【滑块滑倒右边 当发送失败时【没网、返回报错、返回超时】】
    int requestOverTime_;
    BOOL notFirstCome_;
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    NSString *codeorderId;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isChange){
        self.title = @"修改支付密码";
    }else{
        self.title = @"设置支付密码";
    }
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
    [self initScoket];
    
    codeTextF.delegate = self;
    [codeTextF resignFirstResponder];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignClick)];
    [self.tableView addGestureRecognizer:tap];
    
    //忘记支付密码需要短信确认，验证码已发送至手机，请按提示操作。
    self.codeNoticeLabel.text = [NSString stringWithFormat:@"忘记支付密码需要短信确认，验证码已发送至手机%@，请按提示操作。",self.phoneNumString];
    
    
}

-(void)resignClick{
    [codeTextF resignFirstResponder];
}


#pragma mark - 初始化socket
-(void)initScoket{
    
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            //授权查询
            [socketRequest mianmiPayCheck];
            
            [socketRequest checkuserAccountWithGroupId:@""];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}

-(void)initUI{
    
    self.tableView.tableFooterView = [UIView new];
    
    
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        return 0.1;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - 收到服务器消息
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
        
        if([dict objectForKey:@"order_id"]){
            codeorderId = [[dict objectForKey:@"order_id"] description];
            
        }
        
    }else if (messageType == SecretLetterType_NoPasswordSetSuccess){
        //修改成功
        [codeTextF resignFirstResponder];
        NSDictionary *dict = [NSDictionary new];
        if([chatModel isKindOfClass:[NSDictionary class]] && [dict objectForKey:@"result"]){
            dict = [chatModel objectForKey:@"result"];
        }else{
            dict = chatModel;
        }
        if ([dict objectForKey:@"resp_desc"] && [[[dict objectForKey:@"resp_desc"] description] containsString:@"成功"]) {
            
            DCPaymentView *payAlert = [[DCPaymentView alloc]init];
            payAlert.title = self.isChange?@"修改支付密码":@"设置支付密码";
            payAlert.detail = [NSString stringWithFormat:@"请输入6位数字"];
            payAlert.amount= 0;
            [payAlert setAmountLabelHidden:YES];
            [payAlert show];
            payAlert.completeHandle = ^(NSString *inputPwd) {
                //请求网络，设置支付密码
                [self setMyPayPassword:inputPwd];
                //setpasswordWithPassword
            };
            
            
//            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"开启成功" sureBtn:@"确认" cancleBtn:nil];
//            alertView.resultIndex = ^(NSInteger index)
//            {
//                //[self.navigationController popViewControllerAnimated:YES];
//            };
//            [alertView showMKPAlertView];
            
//            [SVProgressHUD showInfoWithStatus:[[dict objectForKey:@"resp_desc"] description]];
//            if ([[[dict objectForKey:@"resp_desc"] description] containsString:@"成功"]) {
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//                    [NSThread sleepForTimeInterval:1];
//                    dispatch_async(dispatch_get_main_queue(), ^(void) {
//                        [self.navigationController popViewControllerAnimated:YES];
//                    });
//                });
//            }
        }
        
        if([[[dict objectForKey:@"resp_desc"] description] containsString:@"验证码不正确"]){
            codeTextF.text = @"";
            [SVProgressHUD showInfoWithStatus:@"验证码不正确"];
        }
        
    }else if(messageType == SecretLetterType_mianmiPayCheck){
        //免密查询
        NSDictionary *dict =chatModel;
        if ([[[dict objectForKey:@"cash_free_pwd_flag"] description] isEqualToString:@"1"] && [[[dict objectForKey:@"pay_free_pwd_flag"] description] isEqualToString:@"1"]) {
            switchBtn.on = YES;
        }else{
            switchBtn.on = NO;
        }
        
    }else if(messageType == SecretLetterType_NoPasswordCancelSuccess){
        NSDictionary *dict = chatModel;
        if ([dict objectForKey:@"resp_desc"] && [[[dict objectForKey:@"resp_desc"] description] containsString:@"成功"]) {
            
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"关闭成功" sureBtn:@"确认" cancleBtn:nil];
            alertView.resultIndex = ^(NSInteger index)
            {
                [self.navigationController popViewControllerAnimated:YES];
            };
            [alertView showMKPAlertView];
        }
    }else if (messageType == SecretLetterType_setPasswordSuccess){
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:self.isChange?@"修改支付密码成功":@"设置支付密码成功" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            //设置密码成功
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
    }else if (messageType == SecretLetterType_checkAmount) {
//        NSString * myMoney =  @"0.00";
//        NSDictionary *banceDict = chatModel[@"balance"];
//        myMoney = [NSString stringWithFormat:@"%@",banceDict[@"balance"]];
//        self.myAccountMoney = [myMoney mutableCopy];
        self.isHavePayPassword = [chatModel[@"issetPayPassword"] intValue]==0?NO:YES;
        
    }
    
}


#pragma mark - 免密按钮点击
- (IBAction)switchClick:(UISwitch *)sender {
    
    if(!sender.isOn){
        
    }
    
}




//发送验证码
- (IBAction)codeClick:(id)sender {
    
//    if (!switchBtn.isOn) {
//        [SVProgressHUD showInfoWithStatus:@"关闭授权不需要验证码"];
//        return;
//    }
    
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
            [socketRequest noPasswordSendCode:@{}];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}


//确定点击
- (IBAction)sureClick:(UIButton *)sender {
    
    if (codeTextF.text.length != 6) {
            [SVProgressHUD showInfoWithStatus:@"请输入合法验证码"];
            return;
    }else if (!codeorderId || codeorderId.length == 0){
        [SVProgressHUD showInfoWithStatus:@"验证码编号为空"];
            return;
    }
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            //
            
            [socketRequest noPasswordOpenCode:@{@"sms_code":codeTextF.text,@"order_id":codeorderId}];
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
    
    [socketRequest setpasswordWirhPassword:newPWD];
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [codeTextF resignFirstResponder];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
//    if (!switchBtn.isOn) {
//        [SVProgressHUD showInfoWithStatus:@"关闭授权不需要验证码"];
//        return NO;
//    }
    
    return YES;
    
}



@end









