//
//  RPFMyWalletVCSec.m
//  nationalFitness
//
//  Created by joe on 2019/11/23.
//  Copyright © 2019年 chenglong. All rights reserved.
//



#import "RPFMyWalletVCSec.h"

#import "SocketModel.h"
#import "SocketRequest.h"


@interface RPFMyWalletVCSec ()<ChatHandlerDelegate>

@end

@implementation RPFMyWalletVCSec{
    
    __weak IBOutlet UILabel *myAmountLabel;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    
    [self initScoket];
    
    
    //如果提现密码没有设置 则请求一下提现密码设置状态
    if(![NFUserEntity shareInstance].isTiXianPassWord){
        if (socketModel.isConnected) {
            [socketModel ping];
            if (socketModel.isConnected) {
                [socketRequest tixianPwdCheck];
            }
        }
    }
    
    //如果授权免密没有设置 则请求一下 授权免密 设置状态
    if(![NFUserEntity shareInstance].isShouquanCancelPwd || YES){
        if (socketModel.isConnected) {
            [socketModel ping];
            if (socketModel.isConnected) {
                [socketRequest mianmiPayCheck];
            }
        }
    }
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [@"" containsString:@""];
    self.title = @"钱包";
    
//    [self initScoket];
    
    
    UIButton *recordBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
//    [recordBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [recordBtn setTitle:@"记录" forState:(UIControlStateNormal)];
    [recordBtn addTarget:self action:@selector(recordClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *recordButtonItem = [[UIBarButtonItem alloc]initWithCustomView:recordBtn];
    self.navigationItem.rightBarButtonItem = recordButtonItem;
    
    
}

-(void)recordClicked{
    
    //
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
    RecordTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RecordTableViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
    
    
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
            //余额查询
            [socketRequest accountDetail];
            
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}


//免密授权
- (IBAction)shouquanClick:(id)sender {
    
    if(![NFUserEntity shareInstance].isShouquanCancelPwd){
        
        if (socketModel.isConnected) {
            [socketModel ping];
            if (socketModel.isConnected) {
                [socketRequest shouquanOut:@{}];
            }else{
                //设置本地数据
            }
        }
        
    }
    
    
}


//充值
- (IBAction)payClick:(id)sender {
    
    //
    BOOL ret = NO;
    if (![NFUserEntity shareInstance].clientId || [NFUserEntity shareInstance].clientId.length == 0) {
        ret = YES;
    }
    
    if (![NFUserEntity shareInstance].isShouquanCancelPwd && !ret){
        
        if (socketModel.isConnected) {
            [socketModel ping];
            if (socketModel.isConnected) {
                [socketRequest shouquanOut:@{}];
            }else{
                //设置本地数据
            }
        }
        
        return;
    }
    
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
        [sendDic setObject:[NSString stringWithFormat:@"%@%ld",dateString,a] forKey:@"order_id"];
        [sendDic setObject:[NFUserEntity shareInstance].clientId forKey:@"user_cust_id"];
        //[sendDic setObject:@"6666000000150915" forKey:@"user_cust_id"];
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


#pragma mark - 提现
- (IBAction)tixianClick:(id)sender {
    //弃用了
    if (![NFUserEntity shareInstance].isTiXianPassWord) {
        //如果没有设置password，那么请求个情信息 看看是否真的没有设置
        [socketRequest requestPersonalInfoWithID:[NFUserEntity shareInstance].userId];
        return;
    }
    
    
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alt addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"请输入提现金额";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *inputInfo = alt.textFields.firstObject;
        NSLog(@"inputInfo = %@",inputInfo.text);
        [self cashOut:[NSString stringWithFormat:@"%.2f",[inputInfo.text floatValue]]];
        
    }];
    [alt addAction:cancelAction];
    [alt addAction:okAction];
    
    [self presentViewController:alt animated:YES completion:nil];
    
    
    
    
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
        }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"cash"]){
            //提现 跳转到提现
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
            ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
            //toCtrol.isShowBack = YES;3
            toCtrol.isCash = YES;
            toCtrol.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=cash",[dict objectForKey:@"check_value"]];
            [self.navigationController pushViewController:toCtrol animated:YES];
            
        }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"pwd"]){
            //设置密码  没有设置密码 跳转到设置密码界面
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
            ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
            //toCtrol.isShowBack = YES;
            toCtrol.isPassword = YES;
            toCtrol.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=pwd",[dict objectForKey:@"check_value"]];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"nopwd"]){
            //授权免密
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
            ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
            //toCtrol.isShowBack = YES;
            toCtrol.isCancelPwd = YES;
            toCtrol.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=nopwd",[dict objectForKey:@"check_value"]];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
        
    }else if(messageType == SecretLetterType_PersonalInfoDetail){
        //个人详情、获取密码是否设置
        PersonalInfoDetailEntity *personalinfo = chatModel;
        if (personalinfo.isSetPwd) {
            
            [NFUserEntity shareInstance].isTiXianPassWord = YES;
            
            //设置过密码 弹出输入框
            UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alt addTextFieldWithConfigurationHandler:^(UITextField *textField){
                textField.placeholder = @"请输入提现金额";
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *inputInfo = alt.textFields.firstObject;
                NSLog(@"inputInfo = %@",inputInfo.text);
                [self cashOut:[NSString stringWithFormat:@"%.2f",[inputInfo.text floatValue]]];
                
            }];
            [alt addAction:cancelAction];
            [alt addAction:okAction];
            
            [self presentViewController:alt animated:YES completion:nil];
        }else if(!personalinfo.isSetPwd){
            //没设置支付密码 跳转到网页设置密码
            if (socketModel.isConnected) {
                [socketModel ping];
                if (socketModel.isConnected) {
                    [socketRequest cashPassword];
                }else{
                    //设置本地数据
                }
            }
        }
    }else if(messageType == SecretLetterType_cashResult){
        
        NSDictionary *backDict = chatModel;
        
        [SVProgressHUD showInfoWithStatus:[[backDict objectForKey:@"resp_desc"] description]];
        
    }else if(messageType == SecretLetterType_checkAmount){
        
        NSString * myMoney =  @"0.00";
        NSDictionary *blanceDict = chatModel;
        if(blanceDict && [blanceDict isKindOfClass:[NSDictionary class]]){
            
            myMoney = [NSString stringWithFormat:@"%.2f",[blanceDict[@"balance"] floatValue]/100];
            myAmountLabel.text = myMoney;
        }
        
    }else if(messageType == SecretLetterType_checkAmountFail){
        
        //NSString *toast = [NSString stringWithFormat:@"%@",chatModel];
        //[self.view makeToast:[toast mutableCopy] duration:2.0 position:CSToastPositionCenter];
       // [SVProgressHUD showInfoWithStatus:@"查询失败"];
        
    }
//    else if(messageType == SecretLetterType_tixianPwdCheck){
//        NSDictionary *dict = chatModel;
////        [NFUserEntity shareInstance].isTiXianPassWord = NO;
//    }
    else if(messageType == SecretLetterType_mianmiPayCheck){
        NSDictionary *dict = [chatModel objectForKey:@"result"];
        if ([dict objectForKey:@"pay_free_pwd_flag"] && [[[dict objectForKey:@"pay_free_pwd_flag"] description] isEqualToString:@"1"]) {
            [NFUserEntity shareInstance].isShouquanCancelPwd = YES;
        }
        if ([dict objectForKey:@"user_cust_id"] && [[[dict objectForKey:@"user_cust_id"] description] length] > 10) {
            [NFUserEntity shareInstance].clientId = [[dict objectForKey:@"user_cust_id"] description];
        }
        
//                [NFUserEntity shareInstance].isShouquanCancelPwd = NO;
    }else if(messageType == SecretLetterType_HuifuPasswordSeted){
        NSDictionary *dict = [chatModel objectForKey:@"result"];
        [NFUserEntity shareInstance].isTiXianPassWord = YES;
    }else if(messageType == SecretLetterType_HuifuPasswordNOSeted){
        NSDictionary *dict = [chatModel objectForKey:@"result"];
        [NFUserEntity shareInstance].isTiXianPassWord = NO;
    }
    
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

//提现获取 checkvalue
- (void)cashOut:(NSString *)inputInfo
{
    [SVProgressHUD show];
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    [sendDic setObject:inputInfo.length>0?inputInfo:@"1.00" forKey:@"trans_amt"];
    NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];

    [sendDic setObject:dev_info_json forKey:@"dev_info_json"];
    
    //@"{'ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}"
    
    //当从登陆界面过来 需要打开下面，这时候
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [socketRequest cashOut:sendDic];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
        
    }
    //[PayManager execute:@selector(openAccountManager) target:self callback:@selector(openAccountManagerCallBack:) args:sendDic,nil];
    
}



@end
