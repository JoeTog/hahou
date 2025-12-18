
//
//  WalletTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/1/6.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "WalletTableViewController.h"


#import "SocketModel.h"
#import "SocketRequest.h"


#import "ServiceViewController.h"
#import "RecordTableViewController.h"



@interface WalletTableViewController ()<ChatHandlerDelegate,Zzz6NumberInputPopViewDelegate>

@property(nonatomic,assign) BOOL isHavePayPassword;//
@property (nonatomic, strong) NSMutableArray<DataBankCardInfo *> *cardInfoArr;       // 银行卡信息数组


@end

@implementation WalletTableViewController{
    
    //零钱 余额
    __weak IBOutlet UILabel *accountLabel;
    
    
    __weak IBOutlet UIView *backView;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    BOOL IsMianmiopen;//绵密支付是否开启 没有开启 则需要跳转免密开启
    BOOL ISKaiHu;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    
    [self initScoket];
    
    
    //如果提现密码没有设置 则请求一下提现密码设置状态
//    if(![NFUserEntity shareInstance].isTiXianPassWord){
//        if (socketModel.isConnected) {
//            [socketModel ping];
//            if (socketModel.isConnected) {
//                //[socketRequest tixianPwdCheck];
//            }
//        }
//    }
    
    //如果授权免密没有设置 则请求一下 授权免密 设置状态
//    if(![NFUserEntity shareInstance].isShouquanCancelPwd || YES){
//        if (socketModel.isConnected) {
//            [socketModel ping];
//            if (socketModel.isConnected) {
//                [socketRequest mianmiPayCheck];
//            }
//        }
//    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //真钱包
    self.title = @"钱包";
    
    self.tableView.tableFooterView = [UIView new];
    
    
    ViewRadius(backView, 5);
    
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
            //查询银行卡列表
            [socketRequest getBankCardList];
            //支付密码设置查询
            //[socketRequest tixianPwdCheck];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_checkAmount) {
        
        NSString * myMoney =  @"0.00";
        NSDictionary *blanceDict = chatModel;
        if(blanceDict && [blanceDict isKindOfClass:[NSDictionary class]]){
            myMoney = [NSString stringWithFormat:@"¥%.2f",[blanceDict[@"balance"] floatValue]/100];
            accountLabel.text = myMoney;
            ISKaiHu = YES;//能到这
            self.isHavePayPassword = [blanceDict[@"issetPayPassword"] intValue]==0?NO:YES;
        }
        
    }else if(messageType == SecretLetterType_checkGet) {
        NSDictionary *dict = chatModel;
        if ([[[dict objectForKey:@"type"] description] isEqualToString:@"pwd"]){
            //设置密码  没有设置密码 跳转到设置密码界面
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
            ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
            //toCtrol.isShowBack = YES;
            toCtrol.isPassword = YES;
            
            toCtrol.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=pwd",[dict objectForKey:@"check_value"]];
            
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
        
    }else if(messageType == SecretLetterType_HuifuPasswordSeted){
//        NSDictionary *dict = [chatModel objectForKey:@"result"];
//        [NFUserEntity shareInstance].isTiXianPassWord = YES;
    }else if(messageType == SecretLetterType_HuifuPasswordNOSeted){
//        NSDictionary *dict = [chatModel objectForKey:@"result"];
//        [NFUserEntity shareInstance].isTiXianPassWord = NO;
    }else if(messageType == SecretLetterType_mianmiPayCheck){
        //免密查询
        if([chatModel isKindOfClass:[NSDictionary class]]){
            NSDictionary *dict =chatModel;
            if ([[[dict objectForKey:@"cash_free_pwd_flag"] description] isEqualToString:@"1"] && [[[dict objectForKey:@"pay_free_pwd_flag"] description] isEqualToString:@"1"]) {
                IsMianmiopen = YES;
            }else{
                IsMianmiopen = NO;
            }
            
            if ([dict objectForKey:@"user_cust_id"] && [[[dict objectForKey:@"user_cust_id"] description] length] > 10) {
                [NFUserEntity shareInstance].clientId = [[dict objectForKey:@"user_cust_id"] description];
            }
        }
       
    }else if (messageType == SecretLetterType_UserNotOpenHuiFu){
        ISKaiHu = NO;
    }else if (messageType == SecretLetterType_UserOpenHuiFued){
        ISKaiHu = YES;
    }else if (messageType == SecretLetterType_BankCardList) {
        if(!chatModel || [chatModel isKindOfClass:[NSNull class]] || ![chatModel isKindOfClass:[NSArray class]]){
            return;
        }
        NSDictionary *bankCardDict = chatModel;
//        NSString *card_list = [bankCardDict objectForKey:@"card_list"];
//        NSArray *card_listArr = [self ArrWithJsonString:card_list];
        NSArray *card_listArr = [NSArray arrayWithArray:chatModel];
        self.cardInfoArr = [NSMutableArray new];
        for (NSDictionary *dict in card_listArr) {
            DataBankCardInfo *model = [DataBankCardInfo new];
            model.bizProtocolNo = [[dict objectForKey:@"bizProtocolNo"] description];
            model.payProtocolNo = [[dict objectForKey:@"payProtocolNo"] description];
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
            model.bankCardNumber = [[dict objectForKey:@"cardNo"] description];
            model.cardID = [[dict objectForKey:@"cardId"] description];
            
            //卡类型，0借记卡，1信用卡
//            if ([[[dict objectForKey:@"dcFlag"] description] isEqualToString:@"D"]) {
                model.cardType = @"0";
//            }else{
//                model.cardType = @"1";
//            }
//            if([[[dict objectForKey:@"cashFlag"] description] isEqualToString:@"1"]){
                [self.cardInfoArr addObject:model];
//            }
        }
        
        [self.tableView reloadData];
        
        
    }else if(messageType == SecretLetterType_setPasswordSuccess){
        //设置支付密码成功
        self.isHavePayPassword = YES;
        NSString *toast = @"设置成功";
        //[self.view makeToast:[toast mutableCopy] duration:2.0 position:CSToastPositionCenter];
        [SVProgressHUD showInfoWithStatus:toast];
    }else if(messageType == SecretLetterType_setPasswordRepeat){
        // 重复 支付密码成功
        [SVProgressHUD showInfoWithStatus:@"已经设置过支付密码"];
    }else if (messageType == SecretLetterType_CheckPasswordSuccess){
        //验证 支付密码成功
        DCPaymentView *payAlert = [[DCPaymentView alloc]init];
        payAlert.title = @"修改支付密码";
        payAlert.detail = [NSString stringWithFormat:@"请输入6位数字"];
        payAlert.amount= 0;
        [payAlert setAmountLabelHidden:YES];
        [payAlert show];
        payAlert.completeHandle = ^(NSString *inputPwd) {
            //请求网络，设置支付密码
            [self setMyPayPassword:inputPwd];
        };
    }else if (messageType == SecretLetterType_CheckPasswordFail){
        //验证 支付密码失败
        
        [SVProgressHUD showErrorWithStatus:@"验证失败"];
        
    }
    
    
    
}

#pragma mark - 充值
- (IBAction)chongzhiClick:(UIButton *)sender {
    
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
//    RechargeTableViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"RechargeTableViewController"];
//    [self.navigationController pushViewController:qrcodeScanVC animated:YES];
//
//    return;
    
    
    if (self.self.cardInfoArr.count > 0) {
        
        //开户并且绑卡了 可以充值
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
        RechargeTableViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"RechargeTableViewController"];
        [self.navigationController pushViewController:qrcodeScanVC animated:YES];
    }else{
        
        [SVProgressHUD showInfoWithStatus:@"请先绑定银行卡"];
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // 跳转绑定银行卡
                
                //AddCardTableViewController
                //去实名开户 添加银行卡
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
                AddCardTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddCardTableViewController"];
                [self.navigationController pushViewController:toCtrol animated:YES];
                
            });
        });
        
        
    }
}


#pragma mark - 提现
- (IBAction)tixianClick:(UIButton *)sender {
    
//     if(![NFUserEntity shareInstance].isTiXianPassWord){
         //[SVProgressHUD showInfoWithStatus:@"请先设置修改充值提现密码"];
         //return;
//    }
    
    if(self.cardInfoArr.count == 0){
        [SVProgressHUD showInfoWithStatus:@"请先添加银行卡"];
        return;
    }
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
    CashOutTableViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"CashOutTableViewController"];
    [self.navigationController pushViewController:qrcodeScanVC animated:YES];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 7) {
        return 0.1;//隐藏 设置提现密码
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
    }else if (indexPath.row == 1){
        //我的红包记录
        
        RPFRedpacketRecordVC * vc = [[RPFRedpacketRecordVC alloc] init];
        //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.userId = [NFUserEntity shareInstance].userId;
//        vc.thirdToken = self.thirdToken;
//        vc.redpacketId = self.redpacketId;
//        vc.appkey = self.appkey;
        vc.groupId = self.groupId;
        if (@available(iOS 13.0, *)) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            //这里不设置 就会出现菜单模式
//            if (viewcontrollers.count > 1) {
//            NSLog(@"");
//            } else {
//                //present方式
//                vc.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
//            }
        }
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
//        [SVProgressHUD showInfoWithStatus:@"功能暂未开放"];
    }else if (indexPath.row == 2){
        //充值记录
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
        RecordTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RecordTableViewController"];
        toCtrol.isChongzhi = YES;
        [self.navigationController pushViewController:toCtrol animated:YES];
    }else if (indexPath.row == 3){
        //提现记录
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
        RecordTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RecordTableViewController"];
        toCtrol.isChongzhi = NO;
        [self.navigationController pushViewController:toCtrol animated:YES];
    }else if (indexPath.row == 4){
        //账单
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
        BillListTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BillListTableViewController"];
        [self.navigationController pushViewController:toCtrol animated:YES];
//        [SVProgressHUD showInfoWithStatus:@"功能暂未开放"];
    }
    else if (indexPath.row == 5){
        //银行卡
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
        CardTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"CardTableViewController"];
        [self.navigationController pushViewController:toCtrol animated:YES];
    }else if (indexPath.row == 6){
        
    }else if (indexPath.row == 7){
        //提现 充值密码 设置 修改
        if (socketModel.isConnected) {
            [socketModel ping];
            if (socketModel.isConnected) {
                [socketRequest cashPassword];
            }else{
                //设置本地数据
            }
        }
        
    }else if (indexPath.row == 8){
        
        
        if(self.isHavePayPassword){
            //修改
            //先验证支付密码
            
            DCPaymentView *payAlert = [[DCPaymentView alloc]init];
            payAlert.title = @"请输入旧密码";
            payAlert.detail = [NSString stringWithFormat:@"请输入6位数字"];
            payAlert.amount= 0;
            [payAlert setAmountLabelHidden:YES];
            [payAlert show];
            payAlert.completeHandle = ^(NSString *inputPwd) {
                //请求网络，验证支付密码
                [socketRequest checkPayPasswordWithPassword:inputPwd];
            };
            
        }else{
            //设置
            //如果没设置过 发红包密码 则立马设置
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
        }
        
        
//        if (socketModel.isConnected) {
//            [socketModel ping];
//            if (socketModel.isConnected) {
//                [socketRequest SubAccountLookRequest];
//            }else{
//
//            }
//        }
        
        
        return;
        
        
        //设置或修改支付密码
        //1 第一次登录 点击进去后需要设置免密，免密设置完 跳转到设置 红包支付密码
        //2 已经设置过支付密码，再次点击跳转到修改支付密码界面
//        if(!IsMianmiopen){
//            //当没有设置过免密支付
//        }else{
//            //忘记支付密码
//            if (!self.isHavePayPassword) {
//                //如果没设置过 发红包密码 则立马设置
//                DCPaymentView *payAlert = [[DCPaymentView alloc]init];
//                payAlert.title = @"设置支付密码";
//                payAlert.detail = [NSString stringWithFormat:@"请输入6位数字"];
//                payAlert.amount= 0;
//                [payAlert setAmountLabelHidden:YES];
//                [payAlert show];
//                payAlert.completeHandle = ^(NSString *inputPwd) {
//                    //请求网络，设置支付密码
//                    [self setMyPayPassword:inputPwd];
//                };
//                return;
//            }
//            if([NFUserEntity shareInstance].phoneNum.length > 0){
//                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
//                ForgetPasswordTableViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"ForgetPasswordTableViewController"];
//                [self.navigationController pushViewController:qrcodeScanVC animated:YES];
//                //            [self presentViewController:qrcodeScanVC animated:YES completion:^{
//                //
//                //            }];
//            }else{
//
//                MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"请先绑定手机号" sureBtn:@"确认" cancleBtn:@"取消"];
//                alertView.resultIndex = ^(NSInteger index)
//                {
//                    if (index == 2) {
//                        //跳转绑定手机号
//                        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
//                        BingingHaHouTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BingingHaHouTableViewController"];
//                        [self.navigationController pushViewController:toCtrol animated:YES];
//                    }
//                };
//                [alertView showMKPAlertView];
//
//            }
//        }
        
    }else if (indexPath.row == 9){
        //免密支付 不会走到这里了
//        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
//        NoPwdAuthTableViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"NoPwdAuthTableViewController"];
//        [self.navigationController pushViewController:qrcodeScanVC animated:YES];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (@available(iOS 13.0, *)) {
        if(indexPath.row == 0 || indexPath.row == 6 || indexPath.row == 7){
            
        }else{
            
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
        }
        
    }
    return cell;
    
}

#pragma mark - NumberInputLength6PopView Delegate

-(void) Zzz6NumberInputPopViewClickConfirmBtnWithMSG:(NSString *)msg
{
    NSLog(@"input number is %@:" ,msg);
}

-(void) Zzz6NumberInputPopViewClickCancelBtn
{
    NSLog(@"NumberInputLength6PopViewClickCancelBtn");
}




//设置支付密码
-(void)setMyPayPassword:(NSString *)newPWD
{
    
    [socketRequest setpasswordWirhPassword:newPWD];
    
    
}


-(NSArray *)ArrWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}



@end
