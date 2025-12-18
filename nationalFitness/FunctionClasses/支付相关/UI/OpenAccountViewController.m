
//
//  OpenAccountViewController.m
//  nationalFitness
//
//  Created by joe on 2019/11/15.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "OpenAccountViewController.h"

#import "PayEntity.h"
#import "PayManager.h"


@interface OpenAccountViewController ()<ChatHandlerDelegate>

@end

@implementation OpenAccountViewController{
    
    __weak IBOutlet UITextField *amountTextF;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initScoket];
    
}


-(void)initScoket{
    
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
}



#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    
    if (messageType == SecretLetterType_PersonalInfoDetail) {
        
    }
    
}


#pragma mark - 确认开户确定开户

- (IBAction)sureClick:(id)sender {
    
    [self openAccountManager];
    
}

//version
//tranCode
//merId
//merOrderId
//submitTime
//msgCiphertext
//signType
//signValue
//merAttach
//charset

//msgCiphertext 【密文】
//tranAmt
//payType
//auditFlag
//payeeName
//payeeAccount
//note
//remark
//bankCode
//payeeType
//notifyUrl
//paymentTermi nalInfo
//deviceInfo



//开户请求
- (void)openAccountManager
{
    [SVProgressHUD show];
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
#pragma mark - 分页1
    //区域类型 0：所有 其他的由筛选条件接口下发
//    [sendDic setObject:nameTextF.text forKey:@"user_name"];
//    [sendDic setObject:cardIdTextF.text forKey:@"id_card"];
//    [sendDic setObject:@"" forKey:@"user_mobile"];
    [sendDic setObject:@"10" forKey:@"version"];
    [sendDic setObject:@"6666000000134024" forKey:@"mer_cust_id"];
    [sendDic setObject:@"20191119" forKey:@"order_date"];
    NSInteger a = arc4random()%899999+1000000;
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
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
    [sendDic setObject:amountTextF.text.length>0?amountTextF.text:@"1.00" forKey:@"divAmt"];
    [sendDic setObject:amountTextF.text.length>0?amountTextF.text:@"1.00" forKey:@"trans_amt"];
    NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC:'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
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

- (void)openAccountManagerCallBack:(id)data
{
    if (data)
    {
        [SVProgressHUD dismiss];
        
        NSDictionary *result = data;
         
    }
    else
    {
        
        [SVProgressHUD showErrorWithStatus:kWrongMessage];
        
    }
    
}


@end
