//
//  CashOutTableViewController.m



//  nationalFitness
//
//  Created by joe on 2020/1/6.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "CashOutTableViewController.h"

#import "SocketModel.h"
#import "SocketRequest.h"

#import "NFShowImageView.h"

#import "ZzzBankCardChoosePopView.h"

@interface CashOutTableViewController ()<ChatHandlerDelegate,UITextFieldDelegate,ZzzBankCardChoosePopViewDelegate>
@property (nonatomic, strong) ZzzBankCardChoosePopView *zzzBankCardChoosePopView;    // 银行卡选择Popview

@property (nonatomic, strong) NSMutableArray<DataBankCardInfo *> *cardInfoArr;       // 银行卡信息数组

@end

@implementation CashOutTableViewController{
    
    __weak IBOutlet UITextField *amountTextF;
    
    
    __weak IBOutlet UILabel *leftMoneyLabel;
    
    
    
    __weak IBOutlet UIButton *nextBtn;
    
    
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    NSString *amountMoneyString;
    
    
    __weak IBOutlet NFShowImageView *bankImageV;
    
    __weak IBOutlet UILabel *bankDetailLabel;
    
    __weak IBOutlet UILabel *arriveTimeLabel;
    
    NSString *bind_card_id;
    
    NSString *bizProtocolNo;
    NSString *payProtocolNo;
    NSString *selectedCardId;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if([amountTextF.text floatValue] > 0){
        
        nextBtn.userInteractionEnabled = YES;
        nextBtn.backgroundColor = UIColorFromRGB(0x5E7DB4);
        
    }else{
        
        nextBtn.userInteractionEnabled = NO;
        nextBtn.backgroundColor = UIColorFromRGB(0x8DA3C9);
    }
    
    [self initScoket];
    
    amountTextF.delegate = self;
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
            
            [socketRequest getBankCardList];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_checkGet) {
        
        
    }else if (messageType == SecretLetterType_checkAmount) {
        
        NSString * myMoney =  @"0.00";
        NSDictionary *blanceDict = chatModel;
        amountMoneyString = [NSString stringWithFormat:@"0"];
        if(blanceDict && [blanceDict isKindOfClass:[NSDictionary class]]){
            myMoney = [NSString stringWithFormat:@"¥%.2f",[blanceDict[@"balance"] floatValue]/100];
            leftMoneyLabel.text = [NSString stringWithFormat:@"零钱余额%@",myMoney];
            amountMoneyString = [NSString stringWithFormat:@"%.2f",[blanceDict[@"balance"] floatValue]/100];
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
                selectedCardId = [[dict objectForKey:@"cardId"] description];
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
        
    }else if(messageType == SecretLetterType_passwordError){
        [SVProgressHUD showInfoWithStatus:@"支付密码错误"];
    }else if(messageType == SecretLetterType_cardNotExist){
        [SVProgressHUD dismiss];
        //提现结果
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"银行卡不存在" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
    }else if(messageType == SecretLetterType_tixianFail){
        [SVProgressHUD dismiss];
        //提现结果
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"提现失败" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
    }else if(messageType == SecretLetterType_tixianShenhezhong){
        [SVProgressHUD dismiss];
        //提现结果
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"已提交审核" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"提现";
    
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignClick)];
    [self.tableView addGestureRecognizer:tap];
    
    
}

-(void)resignClick{
    [amountTextF resignFirstResponder];
}


#pragma mark - 选择银行
- (IBAction)choseBankClick:(UIButton *)sender {
    
    self.zzzBankCardChoosePopView = [ZzzBankCardChoosePopView popviewWithCardBankData:self.cardInfoArr];
    self.zzzBankCardChoosePopView.delegate = self;
    [self.zzzBankCardChoosePopView showInView:[UIApplication sharedApplication].keyWindow andShowModeUpDown:YES];
    
}






#pragma mark - 全部提现
- (IBAction)cashoutAllClick:(UIButton *)sender {
    if ([amountMoneyString floatValue] > 0) {
        
        amountTextF.text = amountMoneyString;
        
        nextBtn.userInteractionEnabled = YES;
        nextBtn.backgroundColor = UIColorFromRGB(0x5E7DB4);
        
        
    }
}



#pragma mark - 下一步点击

- (IBAction)nextBtnClick:(UIButton *)sender {
    
    if([amountTextF.text floatValue] <= 0){
        [SVProgressHUD showInfoWithStatus:@"请输入有效金额"];
        return;
    }else if(self.cardInfoArr.count == 0){
        [SVProgressHUD showInfoWithStatus:@"请先添加银行卡"];
        return;
    }else if([amountTextF.text floatValue] < 50){
        [SVProgressHUD showInfoWithStatus:@"最低提现50元"];
        return;
    }else if([amountTextF.text floatValue] > [amountMoneyString floatValue]){
        
        [SVProgressHUD showInfoWithStatus:@"可用余额不足"];
        return;
        
    }
//    else if ([amountTextF.text floatValue] < 5){
//        [SVProgressHUD showInfoWithStatus:@"最低提现5元"];
//        return;
    
//    }
    
//    if (![NFUserEntity shareInstance].isTiXianPassWord) {
//        //用户没有设置支付密码
//        [SVProgressHUD showInfoWithStatus:@"请先修改支付密码"];
//        return;
//    }
    //
    DCPaymentView *payAlert = [[DCPaymentView alloc]init];
    payAlert.title = @"请输入支付密码";
    CGFloat fellMoney = 0;
//    if([amountTextF.text floatValue] < 250){
//        fellMoney = 2.00;
//    }else{
//        fellMoney = [amountTextF.text floatValue]*0.008;
//    }
    fellMoney = [amountTextF.text floatValue]*0.008 + 1;
    payAlert.detail = [NSString stringWithFormat:@"手续费:%.2f",fellMoney];
    payAlert.amount= [amountTextF.text floatValue];
    [payAlert show];
    payAlert.completeHandle = ^(NSString *inputPwd) {
        [SVProgressHUD show];
        //[socketRequest checkPayPasswordWithPassword:inputPwd];
        [self cashOut:[NSString stringWithFormat:@"%.2f",[amountTextF.text floatValue]] AndPassword:inputPwd];
        
    };
    payAlert.cancelHandle = ^{
        NSLog(@"");
    };
    
    
    
    //[self cashOut:[NSString stringWithFormat:@"%.2f",[amountTextF.text floatValue]]];
    
    
    
}

//提现获取 checkvalue
- (void)cashOut:(NSString *)inputInfo AndPassword:(NSString *)password
{
    [SVProgressHUD show];
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
    
//    NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
//    [sendDic setObject:dev_info_json forKey:@"dev_info_json"];

    [sendDic setObject:inputInfo.length>0?inputInfo:@"1.00" forKey:@"tranAmt"];
    [sendDic setObject:selectedCardId forKey:@"cardId"];
    [sendDic setObject:password forKey:@"payPassword"];
    
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
        selectedCardId = model.cardID;
        
        
    }else{
        [SVProgressHUD showInfoWithStatus:@"未知错误"];
    }
    
    
}

-(void) setLogText:(NSString *) text
{
    NSLog(@"text = %@",text);
}
































@end
