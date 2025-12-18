//
//  TransferAccountTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2020/2/15.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "TransferAccountTableViewController.h"

#import "NFHeadImageView.h"


#import "SocketModel.h"
#import "SocketRequest.h"


#define DEFAULT_ZHUAN @"转账"



@interface TransferAccountTableViewController ()<ChatHandlerDelegate,WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,assign) BOOL isHavePayPassword;//

@property(nonatomic,copy)NSString * myAccountMoney;



@end

@implementation TransferAccountTableViewController{
    
    
    __weak IBOutlet UITextField *transferTextF;
    
    __weak IBOutlet UILabel *detailLabel;
    
    
    __weak IBOutlet UIButton *editBtn;
    
    
    __weak IBOutlet NFHeadImageView *headImageV;
    
    
    __weak IBOutlet UILabel *nickNamelabel;
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    __block NSMutableDictionary *redDicttt;
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [headImageV sd_setImageWithURL:[NSURL URLWithString:self.contactt.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    
    nickNamelabel.text = self.contactt.friend_nickname.length>0?self.contactt.friend_nickname:self.contactt.user_name;
    
    
    [self initScoket];
    
    
    
    
}

#pragma mark - 初始化socket
-(void)initScoket{
    
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            
            [socketRequest checkuserAccountWithGroupId:@""];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}


- (IBAction)backClickk:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_checkAmount) {
        
        
        NSString * myMoney =  @"0.00";
        NSDictionary *blanceDict = chatModel;
        myMoney = [NSString stringWithFormat:@"%.2f",[blanceDict[@"balance"] floatValue]/100];;
        self.myAccountMoney = [myMoney mutableCopy];
        
        self.isHavePayPassword = [blanceDict[@"issetPayPassword"] intValue]==0?NO:YES;
        
    }else if (messageType == SecretLetterType_checkGet){
        //转账 第一次返回 转账id
        NSDictionary *checkDict = chatModel;
        WKWebView *webV = [[WKWebView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT, 1, 1)];
        webV.UIDelegate = self;
        [self.view addSubview:webV];
        //[NSString stringWithFormat:@"",[dict objectForKey:@"check_value"]];
        NSString *urlll = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=redpacket",[checkDict objectForKey:@"check_value"]];
        [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlll]]];
        [redDicttt setValue:[[checkDict objectForKey:@"id"] description] forKey:@"redpacketId"];
        
    }else if (messageType == SecretLetterType_passwordError){
        //支付密码错误
        [SVProgressHUD showInfoWithStatus:@"支付密码错误"];
    }else if (messageType == SecretLetterType_sendRedFaill){
        //发送红包失败
        NSDictionary *banceDict = chatModel;
        if ([[[banceDict objectForKey:@"msg"] description] containsString:@"null"] || [[[banceDict objectForKey:@"msg"] description] length] == 0) {
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"请检查免密授权状态" sureBtn:@"确认" cancleBtn:nil];
            alertView.resultIndex = ^(NSInteger index)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            };
            [alertView showMKPAlertView];
        }else{
            [SVProgressHUD showInfoWithStatus:[[banceDict objectForKey:@"msg"] description]];
        }
    }else if (messageType == SecretLetterType_sendPacketSuccess){
            
        [self dismissViewControllerAnimated:YES completion:^{

        }];
        
    }
    
    
    
}


//编辑说明
- (IBAction)editBtnClick:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"转账说明" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"收款方可见，最多十个字";
        //textField.secureTextEntry = NO;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = [[alertController.textFields firstObject] text];
        if (text.length <= 10) {
            detailLabel.text = text;
        }else{
            detailLabel.text = [text substringToIndex:9];
        }
        
    }];
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    [alertController addAction:cancelAction];
    //id r5 = [mvc navigationController];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}




//转账点击
- (IBAction)sureClick:(id)sender {
    
    if(!self.isHavePayPassword)//未设置支付密码
    {
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"请先去钱包中设置支付密码" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
        
        return;
        
    }
    
    if([[transferTextF.text description] floatValue]*100 < 1){
        [SVProgressHUD showInfoWithStatus:@"最低不能少于0.01"];
        return;
    }
    
    // 支付 转账
    
    NSInteger totalMoney = [transferTextF.text floatValue] * 100;
    
    NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
    
    
    NSString * wishContentSec = detailLabel.text==nil || [detailLabel.text isEqualToString:@""]?DEFAULT_ZHUAN:detailLabel.text;
    
    NSDate *currentDateSec = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatterSec = [[NSDateFormatter alloc] init];
    [dateFormatterSec setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateStringSec = [dateFormatterSec stringFromDate:currentDateSec];
    NSString *AppMessageIdSec = [NSString stringWithFormat:@"%@%@",dateStringSec,[NFUserEntity shareInstance].userName];
    NSDictionary * dicFirst = @{@"title":@"红包",@"type":@"2",@"count":@"1",@"singleMoney":[NSString stringWithFormat:@"%d",totalMoney],@"totalMoney":[NSString stringWithFormat:@"%d",totalMoney],@"content":wishContentSec,@"toGroupId": @"0",@"toUserId": self.contactt.friend_userid,@"isGroup": @"0",@"payPassword":@"",@"appMsgId":AppMessageIdSec,@"device":dev_info_json};
    
    redDicttt = [NSMutableDictionary dictionaryWithDictionary:dicFirst];
    
    
//    [socketRequest transferFirst:dicFirst];
    
    
    DCPaymentView *payAlert = [[DCPaymentView alloc]init];
    payAlert.title = @"请输入支付密码";
    payAlert.detail = [NSString stringWithFormat:@"余额:%@",self.myAccountMoney];
    payAlert.amount= totalMoney/100;
    [payAlert show];
    payAlert.completeHandle = ^(NSString *inputPwd) {
        //something
        //        NSLog(@"(%d / %d)单个金额= %.2f",totalMoney,rpcount,0.01*totalMoney/rpcount);
        //
        //        if(totalMoney*0.01/rpcount > 200.0)
        //        {
        //            NSString *toast = [NSString stringWithFormat:@"单个红包最大金额200"];
        //            [SVProgressHUD showInfoWithStatus:toast];
        //            return;
        //        }
        
        [redDicttt setValue:inputPwd forKey:@"payPassword"];
        [SVProgressHUD show];
//        [socketRequest transferPacketSec:redDicttt];
        [socketRequest transferFirstNew:redDicttt];
        
        
        
        
        
        
    };
    payAlert.cancelHandle = ^{
        NSLog(@"");
    };
    
    
}






@end
