
//
//  RechargeTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/1/6.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "RechargeTableViewController.h"


#import "SocketModel.h"
#import "SocketRequest.h"


#import "ServiceViewController.h"
#import "RecordTableViewController.h"


#import "ZzzBankCardChoosePopView.h"




@interface RechargeTableViewController ()<UITextFieldDelegate,ChatHandlerDelegate,ZzzBankCardChoosePopViewDelegate>

@property (nonatomic, strong) ZzzBankCardChoosePopView *zzzBankCardChoosePopView;    // 银行卡选择Popview
@property (nonatomic, strong) NSMutableArray<DataBankCardInfo *> *cardInfoArr;       // 银行卡信息数组



@end

@implementation RechargeTableViewController{
    
    
    __weak IBOutlet UIButton *nextBtn;
    
    __weak IBOutlet UILabel *bankDetailLabel;
    
    
    __weak IBOutlet UITextField *amountTextF;
    
    
    
    __weak IBOutlet NFShowImageView *bankImageV;
    
    
    
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    BOOL ISKaiHu;
    
    
    NSString *bizProtocolNo;
    NSString *payProtocolNo;
    
    
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    if([amountTextF.text floatValue] > 0){
        
        nextBtn.userInteractionEnabled = YES;
        nextBtn.backgroundColor = UIColorFromRGB(0x5E7DB4);
        
    }else{
        
        nextBtn.userInteractionEnabled = NO;
        nextBtn.backgroundColor = UIColorFromRGB(0x8DA3C9);
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    amountTextF.delegate = self;
    
    nextBtn.userInteractionEnabled = NO;
    nextBtn.backgroundColor = UIColorFromRGB(0x8DA3C9);
    
    
    self.title = @"充值";
    
    [self initScoket];
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignClick)];
    [self.tableView addGestureRecognizer:tap];
    
    
    UIButton *AddBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //[AddBtn setTitle:@"子账户" forState:(UIControlStateNormal)];
    [AddBtn addTarget:self action:@selector(listClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *AddBtnItem = [[UIBarButtonItem alloc]initWithCustomView:AddBtn];
    self.navigationItem.rightBarButtonItem = AddBtnItem;
    
    
    
    
}

#pragma mark - 子账户查询接口
-(void)listClick{
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketRequest SubAccountLookRequest];
        }else{
            //设置本地数据
        }
    }
}




-(void)SetClicked{
    
    //
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
    SubAccountTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SubAccountTableViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
    
    
    
    
    return;
    
    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"是否将此账户设置为子账户" sureBtn:@"确认" cancleBtn:@"取消"];
    alertView.resultIndex = ^(NSInteger index)
    {
        if (index == 2) {
            NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
            [sendDic setObject:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userId,[NFUserEntity shareInstance].nickName] forKey:@"acct_name"];
            if (socketModel.isConnected) {
                [socketModel ping];
                if (socketModel.isConnected) {
                    [socketRequest SubAccountRequest:sendDic];
                }else{
                    //设置本地数据
                }
            }else{
                //设置本地数据
                
            }
        }
    };
    [alertView showMKPAlertView];
    
    
    
    
}


-(void)resignClick{
    [amountTextF resignFirstResponder];
}

-(void)initScoket{
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //当从登陆界面过来 需要打开下面，这时候
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            
            [socketRequest getBankCardList];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}


#pragma mark - 选择银行卡
- (IBAction)choseBankClick:(id)sender {
    
    [self.view endEditing:YES];
    
    self.zzzBankCardChoosePopView = [ZzzBankCardChoosePopView popviewWithCardBankData:self.cardInfoArr];
    self.zzzBankCardChoosePopView.delegate = self;
    [self.zzzBankCardChoosePopView showInView:[UIApplication sharedApplication].keyWindow andShowModeUpDown:YES];
    
    
}



#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_checkGet) {
        NSDictionary *dict = chatModel;
        //myAmountLabel.text = [dict objectForKey:@""];
        if ([[[dict objectForKey:@"type"] description] isEqualToString:@"pay"]) {
            //充值 跳转到充值
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
            ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
            //toCtrol.isShowBack = YES;
            toCtrol.isPay = YES;
            toCtrol.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=pay",[dict objectForKey:@"check_value"]];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if(messageType == SecretLetterType_checkAmount){
        
        NSString * myMoney =  @"0.00";
        NSDictionary *blanceDict = chatModel;
        if(blanceDict && [blanceDict isKindOfClass:[NSDictionary class]]){
            
            myMoney = [NSString stringWithFormat:@"¥%.2f",[blanceDict[@"balance"] floatValue]/100];
            //myAmountLabel.text = myMoney;
        }
        
    }else if(messageType == SecretLetterType_checkAmountFail){
        
        //NSString *toast = [NSString stringWithFormat:@"%@",chatModel];
        //[self.view makeToast:[toast mutableCopy] duration:2.0 position:CSToastPositionCenter];
        // [SVProgressHUD showInfoWithStatus:@"查询失败"];
        
    }
    else if (messageType == SecretLetterType_SubAmountOpenSuccess) {
        //子账户
        NSDictionary *dict = chatModel;
        //myAmountLabel.text = [dict objectForKey:@""];
        if ([[[dict objectForKey:@"type"] description] isEqualToString:@"pay"]) {
            //无权限
//            "mer_cust_id" = 6666000016947268;
//            "resp_code" = C00101;
//            "resp_desc" = "\U5546\U6237\U65e0\U6b64\U63a5\U53e3\U6743\U9650";
            
            
            
            
        }
    }else if (messageType == SecretLetterType_BankCardList) {
    //        NSDictionary *bankCardDict = chatModel;
    //        NSString *card_list = [bankCardDict objectForKey:@"card_list"];
    //        NSArray *card_listArr = [self ArrWithJsonString:card_list];
            NSArray *card_listArr = [NSArray arrayWithArray:chatModel];
            
            self.cardInfoArr = [NSMutableArray new];
            int i = 0 ;
            for (NSDictionary *dict in card_listArr) {
                DataBankCardInfo *model = [DataBankCardInfo new];
                NSString *str = [[[dict objectForKey:@"cardNo"] description] substringFromIndex:[[[dict objectForKey:@"cardNo"] description] length]-4];
                model.bankName = [[dict objectForKey:@"bankName"] description];
                //[NSString stringWithFormat:@"%@ (%@)",[[dict objectForKey:@"bankName"] description],str]
                model.cardLastNumber = str;
                if ([[[dict objectForKey:@"bankName"] description] containsString:@"中国银行"]) {
                    model.logoNamed = @"中国银行";
                }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"建设银行"]){
                    model.logoNamed = @"建设银行";
                }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"农业银行"]){
                    model.logoNamed = @"农业银行";
                }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"工商银行"]){
                    model.logoNamed = @"工商银行";
                }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"民生银行"]){
                    model.logoNamed = @"民生银行";
                }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"浦发银行"]){
                    model.logoNamed = @"浦发银行";
                }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"招商银行"]){
                    model.logoNamed = @"招商银行";
                }
                model.phoneNumber = [[dict objectForKey:@"mobileNo"] description];
                model.bizProtocolNo = [[dict objectForKey:@"bizProtocolNo"] description];
                model.payProtocolNo = [[dict objectForKey:@"payProtocolNo"] description];
                if (i == 0) {
                    model.isSelected = YES;
                    bankImageV.image = [UIImage imageNamed:model.logoNamed];
                    bankDetailLabel.text = [NSString stringWithFormat:@"%@ (%@)",model.bankName,model.cardLastNumber];
                    bizProtocolNo = model.bizProtocolNo;
                    payProtocolNo = model.payProtocolNo;
                    
                }else{
                    model.isSelected = NO;
                }
                model.bankCardNumber = [[dict objectForKey:@"cardNo"] description];
                model.cardID = [[dict objectForKey:@"cardId"] description];
    //            if([[[dict objectForKey:@"cashFlag"] description] isEqualToString:@"1"]){
                    [self.cardInfoArr addObject:model];
    //            }
                i++;
            }
            
    }else if(messageType == SecretLetterType_chagemoneySendcode){
        NSDictionary *resultDict = chatModel;
        //弹框 输入6位数验证码
        
        [WASVerifyCodeView showVerifyCodeViewOnView:self.view accountId:@"13123123123" verifyCodeBlock:^(NSString *code) {
             
            //验证充值验证码
            if (socketModel.isConnected) {
                [socketModel ping];
                if (socketModel.isConnected) {
                    [socketRequest chargeMoneyCheckCodeAndBind:@{@"merOrderId":[[resultDict objectForKey:@"merOrderId"] description],@"hnapayOrderId":[[resultDict objectForKey:@"hnapayOrderId"] description],@"smsCode":code,@"merUserIp":[NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses}];
                }
            }
            
            
        }];
        
        
        
//                DCPaymentView *payAlert = [[DCPaymentView alloc]init];
//                payAlert.title = @"请输入验证码";
//                payAlert.detail = [NSString stringWithFormat:@"请输入6位数字"];
//                payAlert.amount= [amountTextF.text floatValue];
//                [payAlert setAmountLabelHidden:NO];
//                [payAlert show];
//                payAlert.completeHandle = ^(NSString *inputPwd) {
//                    //验证充值验证码
//                    if (socketModel.isConnected) {
//                        [socketModel ping];
//                        if (socketModel.isConnected) {
//                            [socketRequest chargeMoneyCheckCodeAndBind:@{@"merOrderId":[[resultDict objectForKey:@"merOrderId"] description],@"hnapayOrderId":[[resultDict objectForKey:@"hnapayOrderId"] description],@"smsCode":inputPwd,@"merUserIp":[NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses}];
//                        }
//                    }
//                };
    }else if (messageType == SecretLetterType_chagemoneyCheckcode){
        NSDictionary *resultDict =chatModel;
        if([[[resultDict objectForKey:@"resultCode"] description] isEqualToString:@"9999"]){
//            [SVProgressHUD showInfoWithStatus:@"处理中"];
            [SVProgressHUD showWithStatus:@"处理中"];
        }else if ([[[resultDict objectForKey:@"resultCode"] description] isEqualToString:@"0000"]){
            [SVProgressHUD showInfoWithStatus:@"充值成功"];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                [NSThread sleepForTimeInterval:2];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
            
        }else if ([[[resultDict objectForKey:@"resultCode"] description] isEqualToString:@"4444"]){
            [SVProgressHUD showInfoWithStatus:@"充值失败"];
            
        }
        
        
    }
    
    
}











#pragma mark -  充值 下一步
- (IBAction)nextBtnClick:(UIButton *)sender {
    [amountTextF resignFirstResponder];
    if([amountTextF.text floatValue] <= 0){
        [SVProgressHUD showInfoWithStatus:@"请输入合法金额"];
        return;
    }
    
    //开户
//    if (![NFUserEntity shareInstance].clientId || [NFUserEntity shareInstance].clientId.length == 0) {
//        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"请选择开户类型" otherButtonTitles:[NSArray arrayWithObjects:@"第一次开户",@"开子账户", nil] btnClickBlock:^(NSInteger buttonIndex) {
//            if (buttonIndex == 0) {
//                //充值
//                [self openAccountManager:[NSString stringWithFormat:@"%.2f",[amountTextF.text floatValue]]];
//            }else if (buttonIndex == 1){
//
//                NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
//                [sendDic setObject:[NSString stringWithFormat:@"%.2f",[amountTextF.text floatValue]] forKey:@"trans_amt"];
//                [sendDic setObject:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userId,[NFUserEntity shareInstance].nickName] forKey:@"acct_name"];
//                NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
//                [sendDic setObject:dev_info_json forKey:@"dev_info_json"];
//
//                if (socketModel.isConnected) {
//                    [socketModel ping];
//                    if (socketModel.isConnected) {
//                        [socketRequest SubAccountRequest:sendDic];
//                    }else{
//                        //设置本地数据
//                    }
//                }else{
//                    //设置本地数据
//
//                }
//            }
//        }];
//        [sheet show];
//        return;
//    }
    
//    BOOL ret = NO;
//    if (![NFUserEntity shareInstance].clientId || [NFUserEntity shareInstance].clientId.length == 0) {
//        ret = YES;
//    }
    
    
    //充值 发送验证码
    if(payProtocolNo.length == 0 || bizProtocolNo.length == 0){
        [SVProgressHUD showErrorWithStatus:@"bizProtocolNo或payProtocolNo为空"];
        return;
    }
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketRequest chargeMoneySendCode:@{@"tranAmt":[NSString stringWithFormat:@"%.2f",[amountTextF.text floatValue]],@"bizProtocolNo":bizProtocolNo,@"payProtocolNo":payProtocolNo,@"merUserIp":[NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses}];
        }
        
    }
    
    
    
    return ;
    //充值
    [self openAccountManager:[NSString stringWithFormat:@"%.2f",[amountTextF.text floatValue]]];
    
    
    
    
//    if (![NFUserEntity shareInstance].isShouquanCancelPwd && !ret){
//
//        if (socketModel.isConnected) {
//            [socketModel ping];
//            if (socketModel.isConnected) {
//                [socketRequest shouquanOut:@{}];
//            }else{
//                //设置本地数据
//            }
//        }
//
//        return;
//    }
    
    //跳转到h5
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alt addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"请输入充值金额";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *inputInfo = alt.textFields.firstObject;
        NSLog(@"inputInfo = %@",inputInfo.text);
        //这边可添加网络请求的代码。
        
        [self openAccountManager:[NSString stringWithFormat:@"%.2f",[inputInfo.text floatValue]]];
        
        
        
        return ;
        
        
        
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
        ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
        toCtrol.isShowBack = YES;
        toCtrol.isPay = YES;
        
        NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
#pragma mark - 分页1
        //区域类型 0：所有 其他的由筛选条件接口下发
        //    [sendDic setObject:nameTextF.text forKey:@"user_name"];
        //    [sendDic setObject:cardIdTextF.text forKey:@"id_card"];
        //    [sendDic setObject:@"" forKey:@"user_mobile"];
        [sendDic setObject:@"10" forKey:@"version"];
        [sendDic setObject:@"6666000000134024" forKey:@"mer_cust_id"];
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatterDate = [[NSDateFormatter alloc] init];
        [dateFormatterDate setDateFormat:@"YYYYMMdd"];
        [sendDic setObject:[dateFormatterDate stringFromDate:currentDate] forKey:@"order_date"];
        NSInteger a = arc4random()%899999+100000;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
         [sendDic setObject:@"P" forKey:@"biz_trans_type"];
        //    [sendDic setObject:@"" forKey:@"in_cust_id"];
        //    [sendDic setObject:@"" forKey:@"in_acct_id"];
        [sendDic setObject:@"6666000000134024" forKey:@"in_cust_id"];
        [sendDic setObject:@"6666000000134024" forKey:@"divCustId"];
        [sendDic setObject:@"B00024928" forKey:@"divAcctId"];
        [sendDic setObject:inputInfo.text.length>0?inputInfo.text:@"1.00" forKey:@"divAmt"];
        [sendDic setObject:inputInfo.text.length>0?inputInfo.text:@"1.00" forKey:@"trans_amt"];
        
        NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];

        [sendDic setObject:dev_info_json forKey:@"dev_info_json"];
        
        toCtrol.payDict = sendDic;
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }];
    [alt addAction:cancelAction];
    [alt addAction:okAction];
    [self presentViewController:alt animated:YES completion:nil];
    
    
}


//充值获取 checkvalue
- (void)openAccountManager:(NSString *)inputInfo
{
    //[SVProgressHUD show];
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
#pragma mark - 分页1
    //区域类型 0：所有 其他的由筛选条件接口下发
    //    [sendDic setObject:nameTextF.text forKey:@"user_name"];
    //    [sendDic setObject:cardIdTextF.text forKey:@"id_card"];
    //    [sendDic setObject:@"" forKey:@"user_mobile"];
    //    [sendDic setObject:@"10" forKey:@"version"];
    //    [sendDic setObject:@"6666000000134024" forKey:@"mer_cust_id"];
    //    [sendDic setObject:@"20191119" forKey:@"order_date"];
    //    NSInteger a = arc4random()%899999+100000;
    //    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    //    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    //    [sendDic setObject:[NSString stringWithFormat:@"%@%ld",dateString,a] forKey:@"order_id"];
    //    [sendDic setObject:[NFUserEntity shareInstance].clientId forKey:@"user_cust_id"];
    //    //[sendDic setObject:@"6666000000150915" forKey:@"user_cust_id"];
    //    [sendDic setObject:@"P" forKey:@"biz_trans_type"];
    //    //    [sendDic setObject:@"" forKey:@"in_cust_id"];
    //    //    [sendDic setObject:@"" forKey:@"in_acct_id"];
    //    [sendDic setObject:@"6666000000134024" forKey:@"in_cust_id"];
    //    [sendDic setObject:@"6666000000134024" forKey:@"divCustId"];
    //    [sendDic setObject:@"B00024928" forKey:@"divAcctId"];
    //    [sendDic setObject:inputInfo.length>0?inputInfo:@"1.00" forKey:@"divAmt"];
    
    [sendDic setObject:inputInfo.length>0?inputInfo:@"1.00" forKey:@"trans_amt"];
    NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
    [sendDic setObject:dev_info_json forKey:@"dev_info_json"];
    
    //当从登陆界面过来 需要打开下面，这时候
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketRequest SignsRequest:sendDic];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
        
    }
    //[PayManager execute:@selector(openAccountManager) target:self callback:@selector(openAccountManagerCallBack:) args:sendDic,nil];
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    [amountTextF resignFirstResponder];
    
    
}




-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.text.length + string.length - range.length > 6) {
        return NO;
    }
    
    if (textField.text.length + string.length - range.length > 0) {
        nextBtn.userInteractionEnabled = YES;
        nextBtn.backgroundColor = UIColorFromRGB(0x5E7DB4);
    }else if (textField.text.length + string.length - range.length == 0){
        nextBtn.userInteractionEnabled = NO;
        nextBtn.backgroundColor = UIColorFromRGB(0x8DA3C9);
    }
    
    return YES;
    
}


#pragma mark - ZzzBankCardChoosePopView Delegate
- (void) zzzBankCardChoosePopViewClickConfirmBtn
{
    [self setLogText:@"zzzBankCardChoosePopViewClickConfirmBtn"];
}

- (void) zzzBankCardChoosePopViewClickCancelBtn
{
    [self setLogText:@"zzzBankCardChoosePopViewClickCancelBtn"];
}

-(void) zzzBankCardChoosePopViewSelectedBankCard:(NSInteger) index
{
    [self setLogText:[NSString stringWithFormat:@"zzzBankCardChoosePopViewSelectedBankCard itemIndex is :%ld", (long)index]];
    
    if (self.cardInfoArr.count > index) {
        DataBankCardInfo *model = self.cardInfoArr[index];
        
        bankImageV.image = [UIImage imageNamed:model.logoNamed];
        bankDetailLabel.text = [NSString stringWithFormat:@"%@ (%@)",model.bankName,model.cardLastNumber];
        
        
        bizProtocolNo = model.bizProtocolNo;
        payProtocolNo = model.payProtocolNo;
        
        
        
    }else{
        [SVProgressHUD showInfoWithStatus:@"未知错误"];
    }
    
    
}

-(void) setLogText:(NSString *) text
{
    NSLog(@"text = %@",text);
}



























@end
