//
//  RPFSendRedPacketVC.m
//  NIM
//
//  Created by King on 2019/2/2.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFSendRedPacketVC.h"
//#import "NTESLoginManager.h"
//#import "NTESDemoConfig.h"
#import "MKNetworkManager.h"
#import "UIView+Toast.h"
#import "NSArray+DLog.h"
#import "NSDictionary+DLog.h"
#import "UITextView+ZWPlaceHolder.h"
#import "DCPaymentView.h"

#import "SocketModel.h"
#import "SocketRequest.h"

#define DEFAULT_WISH @"恭喜发财，大吉大利"



@interface RPFSendRedPacketVC ()<UITextFieldDelegate, UITextViewDelegate, UITextViewDelegate,ChatHandlerDelegate,WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong) UITextField * countTextF;//红包个数
@property(nonatomic,strong) UITextField * moneyTextF;//单个金额或总金额
@property(nonatomic,strong) UIButton * changeTypeBtn;//改变红包类型的btn

@property(nonatomic,strong) UIButton * moneyWarningLabel;//money的提示语
@property(nonatomic,strong) UILabel * rpTypeLabel;//当前为拼手气红包

@property(nonatomic,strong) UITextView * contentTxt;

@property(nonatomic,strong) UIButton * sendBtn;

@property(nonatomic,strong) UILabel * memberCountLabel;

@property(nonatomic,assign) BOOL isPinType;//是拼手气模式

@property(nonatomic,strong) UILabel * totalMoneyLabel;//展示总金额

@property(nonatomic,copy)NSString * myAccountMoney;

@property(nonatomic,assign) BOOL isHavePayPassword;//



@end


@implementation RPFSendRedPacketVC{
    
    
    SocketModel * socketModel;
    
    SocketRequest *socketRequest;
    
    __block NSMutableDictionary *redDicttt;
    
    
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    // 设置左边按钮
    //    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnAction:)];
    //    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    //if 
    //
    [self initScoket];
    
    [self viewMyAccount];
    
    [self buildView];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    socketModel = [SocketModel share];
    socketModel.delegate = self;
}

-(void)backToPreviousVC:(UIButton *)btn
{
    //返回到上一页
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.title = @"发红包";
    
    //在viewWillAppear 中设置、请求
    
    if(!self.isGroup){
        self.isPinType = NO;
        self.countTextF.text = @"1";
        self.countTextF.textColor = [UIColor lightGrayColor];
        
        
        
    }
    
}

#pragma mark - 初始化socket
-(void)initScoket{
    [NFUserEntity shareInstance].isNeedRefreshChatList = NO;
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    
}


#pragma mark - 收到服务器消息
/**
 收到服务器消息
 9001
 @param chatModel 收到服务器的数据
 @param messageType 接口类型
 */
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    
    if (messageType == SecretLetterType_checkAmount) {
        NSString * myMoney =  @"0.00";
        NSDictionary *blanceDict = chatModel;
        myMoney = [NSString stringWithFormat:@"%.2f",[blanceDict[@"balance"] floatValue]/100];
        self.myAccountMoney = [myMoney mutableCopy];
        self.isHavePayPassword = [blanceDict[@"issetPayPassword"] intValue]==0?NO:YES;
        
    }else if(messageType == SecretLetterType_checkAmountFail){
        
        //NSString *toast = [NSString stringWithFormat:@"%@",chatModel];
        //[self.view makeToast:[toast mutableCopy] duration:2.0 position:CSToastPositionCenter];
        //[SVProgressHUD showInfoWithStatus:@"查询失败"];
        
    }else if(messageType == SecretLetterType_setPasswordSuccess){
        //设置支付密码成功
        
        self.isHavePayPassword = YES;
        
        NSString *toast = @"设置成功";
        //[self.view makeToast:[toast mutableCopy] duration:2.0 position:CSToastPositionCenter];
        [SVProgressHUD showInfoWithStatus:toast];
    }else if(messageType == SecretLetterType_setPasswordRepeat){
        // 重复 支付密码成功
        
        [SVProgressHUD showInfoWithStatus:@"已经设置过支付密码"];
    }else if (messageType == SecretLetterType_sendPacketSuccess){
        
        //先拿到checkvalue 然后打开网页 加载，然后等发送成功回调
        
        //红包发送成功
        if(_sendRPFinishBlock)
        {
            /*
             kjrmfStatCancel = 0,     // 取消发送，用户行为
             kjrmfStatSucess = 1,     // 红包发送成功
             kjrmfStatUnknow,         // 其他
             --------------------------------------
             0是拼手气红包
             1是普通红包
             */
            
            //红包发送成功 回调 提示发送成功吧
//            _sendRPFinishBlock(chatModel[@"redpacketId"],chatModel[@"title"],chatModel[@"content"], 1, [chatModel[@"type"] intValue]);
            
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [self dismissViewControllerAnimated:YES completion:^{

                }];
                
//            });
            
            _sendRPFinishBlock(@"1",@"1",@"1", 1, 1);
            
            
            return;
            
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
//            ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
//            //toCtrol.isShowBack = YES;
//            toCtrol.isPay = YES;
//            toCtrol.requestUrl = @"http://www.baidu.com";
//            //toCtrol.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=pay",[dict objectForKey:@"check_value"]];
//            toCtrol.isFouBack = YES;
//            if (@available(iOS 13.0, *)) {
//                toCtrol.modalPresentationStyle =UIModalPresentationFullScreen;
//            }
//            [self presentViewController:toCtrol animated:YES completion:^{
//                
//            }];
            
            //SecretLetterType_checkGet
        }
    }else if (messageType == SecretLetterType_passwordError){
        //支付密码错误
        [SVProgressHUD showInfoWithStatus:@"支付密码错误"];
    }else if (messageType == SecretLetterType_checkGet){
        NSDictionary *checkDict = chatModel;
        WKWebView *webV = [[WKWebView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT, 1, 1)];
        webV.UIDelegate = self;
        [self.view addSubview:webV];
        //[NSString stringWithFormat:@"",[dict objectForKey:@"check_value"]];
        NSString *urlll = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=redpacket",[checkDict objectForKey:@"check_value"]];
        [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlll]]];
        [redDicttt setValue:[[checkDict objectForKey:@"id"] description] forKey:@"redpacketId"];
        
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
    }
    
}





-(void)buildView
{
    self.isPinType = YES;//默认为拼手气模式
    
    float spaceLeft = 10;
    float viewWidth = SCREEN_WIDTH - 2*spaceLeft;
    float viewHeight = 60;
    float singleWordWidth = 18;
    float labelFont = 13.0;
    float cornerRadius = 6.0;
    float spaceTopBase = 10;
    
    float spaceNavigation = 5.0;
    float backBtnHeight = 30;
    
    NSLog(@"状态栏高度= %f",STATUSBAR_HEIGHT);
    NSLog(@"导航栏高度= %f",self.navigationController.navigationBar.frame.size.height);
    float navBarViewHeight = 44;
    
    UIView * singleNavigationBar = [[UIView alloc] init];
    singleNavigationBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, STATUSBAR_HEIGHT+navBarViewHeight);
    singleNavigationBar.backgroundColor = REDPACKET_COLOR;
    [self.view addSubview:singleNavigationBar];
    
    UIButton * leftBackBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [leftBackBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBackBtn addTarget:self action:@selector(backToPreviousVC:) forControlEvents:UIControlEventTouchUpInside];
    leftBackBtn.frame = CGRectMake(spaceNavigation, singleNavigationBar.frame.size.height-spaceNavigation-backBtnHeight, 40, backBtnHeight);
    leftBackBtn.backgroundColor = REDPACKET_COLOR;
    leftBackBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [leftBackBtn.layer setCornerRadius:cornerRadius];
    [leftBackBtn.layer setMasksToBounds:YES];
    [leftBackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:leftBackBtn];
    
    float spaceTop = CGRectGetMaxY(singleNavigationBar.frame)+10;
    
    UIView * countView = [[UIView alloc] initWithFrame:CGRectMake(spaceLeft, spaceTop, viewWidth, viewHeight)];
    countView.backgroundColor = [UIColor whiteColor];
    [countView.layer setCornerRadius:cornerRadius];
    [countView.layer setMasksToBounds:YES];
    [self.view addSubview:countView];
    
    UILabel * lab1 = [[UILabel alloc] init];
    lab1.text = @"红包个数";
    lab1.frame = CGRectMake(spaceLeft, 0, viewWidth-spaceLeft, viewHeight);
    lab1.textAlignment = NSTextAlignmentLeft;
    [countView addSubview:lab1];
    
    UILabel * lab2 = [[UILabel alloc] init];
    lab2.text = @"个";
    lab2.textAlignment = NSTextAlignmentRight;
    lab2.frame = CGRectMake(0, 0, viewWidth-spaceLeft, viewHeight);
    [countView addSubview:lab2];
    
    UITextField * countTextF = [[UITextField alloc] init];
    countTextF.frame = CGRectMake(0, 0, viewWidth-spaceLeft-singleWordWidth, viewHeight);
    countTextF.delegate = self;
    countTextF.textAlignment = NSTextAlignmentRight; //水平左对齐
    countTextF.placeholder = @"填入个数";
    countTextF.keyboardType = UIKeyboardTypeNumberPad;
    if(self.isGroup){
        [countView addSubview:countTextF];
        self.countTextF = countTextF;
    }else{
        countTextF.textColor = [UIColor lightGrayColor];
        countTextF.text = @"1";
        [countView addSubview:countTextF];
        countTextF.userInteractionEnabled = NO;
        self.countTextF = countTextF;
    }
    
    float label_height = 20;
    float space_label = 15;
    float space_label_top = 2;
    UILabel * memberCountLabel = [[UILabel alloc] init];
    memberCountLabel.text = [NSString stringWithFormat:@"本群共 %@ 人",self.groupNum];
    memberCountLabel.textColor = [UIColor lightGrayColor];
    memberCountLabel.font = [UIFont systemFontOfSize:labelFont];
    memberCountLabel.frame = CGRectMake(CGRectGetMinX(countView.frame)+space_label, CGRectGetMaxY(countView.frame)+space_label_top, countView.frame.size.width-space_label*2, label_height);
    if(self.isGroup){
        self.memberCountLabel = memberCountLabel;
        [self.view addSubview:memberCountLabel];
    }
    
    UIView * moneyView = [[UIView alloc] initWithFrame:CGRectMake(spaceLeft, CGRectGetMaxY(memberCountLabel.frame)+spaceTopBase, viewWidth, viewHeight)];
    moneyView.backgroundColor = [UIColor whiteColor];
    [moneyView.layer setCornerRadius:cornerRadius];
    [moneyView.layer setMasksToBounds:YES];
    [self.view addSubview:moneyView];
    
    UIButton * moneyWarningLabel = [self createButtonWithFrame:CGRectMake(spaceLeft, 0, viewWidth-spaceLeft, viewHeight)];
    moneyWarningLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.moneyWarningLabel = moneyWarningLabel;
    [moneyView addSubview:moneyWarningLabel];
    
    
    UILabel * lab4 = [[UILabel alloc] init];
    lab4.text = @"元";
    lab4.textAlignment = NSTextAlignmentRight;
    lab4.frame = CGRectMake(0, 0, viewWidth-spaceLeft, viewHeight);
    [moneyView addSubview:lab4];
    
    UITextField * moneyTextF = [[UITextField alloc] init];
    moneyTextF.frame = CGRectMake(0, 0, viewWidth-spaceLeft-singleWordWidth, viewHeight);
    moneyTextF.delegate = self;
    moneyTextF.textAlignment = NSTextAlignmentRight; //水平左对齐
    moneyTextF.placeholder = @"0.0";
    moneyTextF.keyboardType = UIKeyboardTypeDecimalPad;
    
    [moneyView addSubview:moneyTextF];
    
    self.moneyTextF = moneyTextF;
    
    float oneWordWidth = 15;
    UILabel * rpTypeLabel = [[UILabel alloc] init];
    rpTypeLabel.text = @"当前为拼手气红包，";
    rpTypeLabel.textAlignment = NSTextAlignmentRight;
    rpTypeLabel.font = [UIFont systemFontOfSize:labelFont];
    rpTypeLabel.textColor = [UIColor lightGrayColor];
    //    rpTypeLabel.backgroundColor = [UIColor redColor];
    rpTypeLabel.frame = CGRectMake(CGRectGetMinX(countView.frame)+space_label, CGRectGetMaxY(moneyView.frame)+space_label_top, 9*oneWordWidth, label_height);
    self.rpTypeLabel = rpTypeLabel;
    if (self.isGroup) {
        [self.view addSubview:rpTypeLabel];
    }
    
    UIButton * typeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [typeBtn setTitle:@"改为普通红包" forState:UIControlStateNormal];
    [typeBtn addTarget:self action:@selector(changeRPType:) forControlEvents:UIControlEventTouchUpInside];
    typeBtn.frame = CGRectMake(CGRectGetMaxX(rpTypeLabel.frame), rpTypeLabel.frame.origin.y, moneyView.frame.size.width-rpTypeLabel.frame.size.width, label_height);
    //    typeBtn.backgroundColor = [UIColor blueColor];
    typeBtn.titleLabel.font = [UIFont systemFontOfSize:labelFont];
    typeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.changeTypeBtn = typeBtn;
    if (self.isGroup) {
        [self.view addSubview:typeBtn];
    }
    
    UITextView * contentTxt = [[UITextView alloc] init];
    contentTxt.frame = CGRectMake(moneyView.frame.origin.x, CGRectGetMaxY(typeBtn.frame)+spaceTopBase, moneyView.frame.size.width, moneyView.frame.size.height*2);
    contentTxt.delegate = self;
    [contentTxt.layer setCornerRadius:cornerRadius];
    contentTxt.font = [UIFont systemFontOfSize:17.0];
    [contentTxt.layer setMasksToBounds:YES];
    self.contentTxt = contentTxt;
    [self.view addSubview:contentTxt];
    
    //总金额展示
    float height_totalMoneyLabbel = 50;
    UILabel * totalMoneyLabel = [[UILabel alloc] init];
    totalMoneyLabel.text = @"￥0.00";
    totalMoneyLabel.font = [UIFont boldSystemFontOfSize:26.0];
    totalMoneyLabel.textAlignment = NSTextAlignmentCenter;
    totalMoneyLabel.textColor = [UIColor blackColor];
    totalMoneyLabel.frame = CGRectMake(0, CGRectGetMaxY(contentTxt.frame)+spaceTopBase, SCREEN_WIDTH, height_totalMoneyLabbel);
    self.totalMoneyLabel = totalMoneyLabel;
    [self.view addSubview:totalMoneyLabel];
    
    //发包按钮
    UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendBtn setTitle:@"塞钱进红包" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendRedpacket:) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.frame = CGRectMake(moneyView.frame.origin.x, CGRectGetMaxY(totalMoneyLabel.frame)+spaceTopBase, 9*oneWordWidth, label_height);
    sendBtn.backgroundColor = [UIColor redColor];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [sendBtn.layer setCornerRadius:cornerRadius];
    [sendBtn.layer setMasksToBounds:YES];
    
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendBtn = sendBtn;
    [self.view addSubview:sendBtn];
    
    //忘记支付密码
    UIButton * fogetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [fogetBtn setTitle:@"忘记支付密码" forState:UIControlStateNormal];
    [fogetBtn addTarget:self action:@selector(fogetPassword) forControlEvents:UIControlEventTouchUpInside];
    fogetBtn.frame = CGRectMake(space_label, CGRectGetMaxY(totalMoneyLabel.frame)+spaceTopBase, moneyView.frame.size.width, label_height);
    //    typeBtn.backgroundColor = [UIColor blueColor];
    fogetBtn.titleLabel.font = [UIFont systemFontOfSize:labelFont];
    fogetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:fogetBtn];
    
    
    
    
    //重设frame----------
    moneyView.frame = CGRectMake(spaceLeft, spaceTop, viewWidth, viewHeight);
    rpTypeLabel.frame = CGRectMake(CGRectGetMinX(countView.frame)+space_label, CGRectGetMaxY(moneyView.frame)+space_label_top, 9*oneWordWidth, label_height);
    typeBtn.frame = CGRectMake(CGRectGetMaxX(rpTypeLabel.frame), rpTypeLabel.frame.origin.y, moneyView.frame.size.width-rpTypeLabel.frame.size.width, label_height);
    
    countView.frame = CGRectMake(spaceLeft, CGRectGetMaxY(rpTypeLabel.frame)+spaceTopBase, viewWidth, viewHeight);
    memberCountLabel.frame = CGRectMake(CGRectGetMinX(countView.frame)+space_label, CGRectGetMaxY(countView.frame)+space_label_top, countView.frame.size.width-space_label*2, label_height);
    contentTxt.frame = CGRectMake(moneyView.frame.origin.x, CGRectGetMaxY(memberCountLabel.frame)+spaceTopBase, moneyView.frame.size.width,60);
    contentTxt.zw_placeHolder = DEFAULT_WISH;
    totalMoneyLabel.frame = CGRectMake(0, CGRectGetMaxY(contentTxt.frame)+spaceTopBase, SCREEN_WIDTH, height_totalMoneyLabbel);
    
    sendBtn.frame = CGRectMake(moneyView.frame.origin.x, CGRectGetMaxY(totalMoneyLabel.frame)+spaceTopBase, moneyView.frame.size.width, 40);
    
    
    
}

#pragma mark - 忘记支付密码点击
-(void)fogetPassword{
    //
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
    ForgetPasswordTableViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"ForgetPasswordTableViewController"];
    toCtrol.IsShowBack = YES;
    if (@available(iOS 13.0, *)) {
                //
    //            openVC.modalPresentationStyle =UIModalPresentationOverFullScreen;
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
                if (viewcontrollers.count > 1) {
                    NSLog(@"");
                    } else {
                        //present方式
                        toCtrol.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
                    }
                
    //            openVC.modalPresentationStyle =UIModalPresentationFullScreen;//diss回去直接到登陆界面了
            }
    [self presentViewController:toCtrol animated:YES completion:^{
        
    }];
    
    
}



-(void)uploadClick{
    
    
   // [socketRequest rechargeWithGroupId:@"" rechargeUserId:@"" amount:@""];
    
}



//查看用户余额
-(void)viewMyAccount
{
    
    //
    
    [socketRequest checkuserAccountWithGroupId:@""];
    
    return;
    
    
    
    
    
    __weak typeof(self) weakSelf = self;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/chatapi/getBalanceList",BASE_URL];
    NSDictionary * uInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"lInfo"];
    
    uInfo = @{@"t":@"1",@"akey":@"2"};
    if(!uInfo[@"t"] || !uInfo[@"akey"])
    {
        [SVProgressHUD showInfoWithStatus:@"请注销并重新登录"];
        return;
    }
    
//    NSString * myUserId = [NIMSDK sharedSDK].loginManager.currentAccount;
    NSString * myUserId = @"";
    NSDictionary * dic = @{@"userId":myUserId,@"thirdToken":uInfo[@"t"],@"bundleId":[[NSBundle mainBundle]bundleIdentifier],@"appId":uInfo[@"akey"],@"groupId":self.toGroupId};
    
    NSLog(@"viewMyAccount--redpacket--dic= %@",dic);
    
    [SVProgressHUD show];
    
    __block NSString * myMoney =  @"0.00";
    
    [[MKNetworkManager sharedInstance] requestNetWithParams:dic andMethod:@"POST" andURL:urlStr andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        [SVProgressHUD dismiss];
        NSLog(@"viewMyAccount--responseDict= %@",responseDict);
        if (error == nil)
        {
            if([responseDict[@"errcode"] intValue]==0)
            {
                /*
                 
                 */
                NSArray * dataArray = responseDict[@"list"];
                
                for(NSDictionary * data in dataArray)
                {
                    if([weakSelf.toGroupId isEqualToString:data[@"groupId"]])
                    {
                        myMoney = [NSString stringWithFormat:@"%.2f",[data[@"total"] intValue]/100.0];
                        NSLog(@"myAccount= %@",myMoney);
                        break;
                    }
                }
                
                weakSelf.myAccountMoney = [myMoney mutableCopy];
                weakSelf.isHavePayPassword = [responseDict[@"issetPayPassword"] intValue]==0?NO:YES;
                
            }
            else
            {
                NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
                //[self.view makeToast:[toast mutableCopy] duration:2.0 position:CSToastPositionCenter];
                [SVProgressHUD showInfoWithStatus:toast];
            }
            
            
        }
        else
        {
            NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
            //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
            [SVProgressHUD showInfoWithStatus:toast];
            
        }
        
        
        
    }];
}

//设置支付密码
-(void)setMyPayPassword:(NSString *)newPWD
{
    
    [socketRequest setpasswordWirhPassword:newPWD];
    
    
    
    return;
    
    __weak typeof(self) weakSelf = self;
    NSString * urlStr = [NSString stringWithFormat:@"%@/chatapi/modifyPayPassword",BASE_URL];
    NSDictionary * uInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"lInfo"];
    uInfo = @{@"t":@"1",@"akey":@"2"};
    if(!uInfo[@"t"] || !uInfo[@"akey"])
    {
        [SVProgressHUD showInfoWithStatus:@"请注销并重新登录"];
        return;
    }
    
//    NSString * myUserId = [NIMSDK sharedSDK].loginManager.currentAccount;
    NSString * myUserId = @"";
    NSDictionary * dic = @{@"userId":myUserId,@"thirdToken":uInfo[@"t"],@"bundleId":[[NSBundle mainBundle]bundleIdentifier],@"appId":uInfo[@"akey"],@"newpayPassword":newPWD};
    
    NSLog(@"setMyPayPassword--redpacket--dic= %@",dic);
    
    [SVProgressHUD show];
    
    __block NSString * myMoney =  @"0.00";
    
    [[MKNetworkManager sharedInstance] requestNetWithParams:dic andMethod:@"POST" andURL:urlStr andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        [SVProgressHUD dismiss];
        NSLog(@"setMyPayPassword--responseDict= %@",responseDict);
        if (error == nil)
        {
            if([responseDict[@"errcode"] intValue]==0)
            {
                
                self.isHavePayPassword = YES;
            }
            
            NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
            //[self.view makeToast:[toast mutableCopy] duration:2.0 position:CSToastPositionCenter];
            [SVProgressHUD showInfoWithStatus:toast];
            
            
            
        }
        else
        {
            NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
            //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
            [SVProgressHUD showInfoWithStatus:toast];
            
        }
        
        
        
    }];
}


//改变红包模式
-(void)changeRPType:(UIButton *)btn
{
    [self.view endEditing:YES];
    
    if(self.isPinType)
    {
        self.isPinType = NO;
        [self.moneyWarningLabel setTitle:@"单个金额" forState:UIControlStateNormal];
        [self.moneyWarningLabel setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"ic_pin"] forState:UIControlStateNormal];
        self.moneyWarningLabel.imageView.hidden = YES;
        self.rpTypeLabel.text = @"当前为普通红包";
        [self.changeTypeBtn setTitle:@"改为拼手气红包" forState:UIControlStateNormal];
        
        int count = [self.countTextF.text intValue];
        float money = [self.moneyTextF.text floatValue];
        self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",count*money];
        
    }
    else
    {
        self.isPinType = YES;
        [self.moneyWarningLabel setTitle:@"总金额" forState:UIControlStateNormal];
        [self.moneyWarningLabel setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"ic_pin"] forState:UIControlStateNormal];
        self.moneyWarningLabel.imageView.hidden = NO;
        
        self.rpTypeLabel.text = @"当前为拼手气红包";
        [self.changeTypeBtn setTitle:@"改为普通红包" forState:UIControlStateNormal];
        
        self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[self.moneyTextF.text floatValue]];
        
    }
}

-(UIButton *)createButtonWithFrame:(CGRect)frame
{
    UIButton * redpacketTitle = [[UIButton alloc] init];
    
    redpacketTitle.frame = frame;
    [redpacketTitle setTitle:@"总金额" forState:UIControlStateNormal];
    [redpacketTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [redpacketTitle setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"ic_pin"] forState:UIControlStateNormal];
    
    [redpacketTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, -redpacketTitle.imageView.bounds.size.width, 0, redpacketTitle.imageView.bounds.size.width)];
    [redpacketTitle setImageEdgeInsets:UIEdgeInsetsMake(0, redpacketTitle.titleLabel.bounds.size.width, 0, -redpacketTitle.titleLabel.bounds.size.width)];
    
    return redpacketTitle;
    
}

//꧁情菲💕得已꧂ᶫᵒᵛᵉᵧₒᵤ.
//情菲💕得已
#pragma mark - 塞红包
-(void)sendRedpacket:(UIButton *)btn
{
    ////countTextF moneyTextF
    if ([self.countTextF.text floatValue] == 0 || [self.moneyTextF.text floatValue] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入合法金额或个数"];
        return;
    }else if([self.countTextF.text floatValue] > 100){
        [SVProgressHUD showErrorWithStatus:@"最多发100包"];
        return;
    }else if(!self.isPinType && [self.moneyTextF.text floatValue] > 200){
        [SVProgressHUD showErrorWithStatus:@"单个金额最多200"];
        return;
    }
    
    if (self.isPinType) {
        //拼手气
        if (1000 < [self.moneyTextF.text floatValue]) {
            [SVProgressHUD showErrorWithStatus:@"总金额不能超过1000"];
            return;
        }else if ([self.moneyTextF.text floatValue]/[self.countTextF.text floatValue]*100 < 1){
            [SVProgressHUD showErrorWithStatus:@"最小单个金额为0.01"];
            return;
        }else if ([self.moneyTextF.text floatValue]/[self.countTextF.text floatValue] > 200) {
            [SVProgressHUD showErrorWithStatus:@"最大单个金额为200"];
            return;
        }else if ([self.myAccountMoney floatValue] < [self.moneyTextF.text floatValue]) {
            [SVProgressHUD showErrorWithStatus:@"余额不足"];
            return;
        }
    }else{
        if (1000 < [self.moneyTextF.text floatValue]*[self.countTextF.text floatValue]) {
            [SVProgressHUD showErrorWithStatus:@"总金额不能超过1000"];
            return;
        }else if ([self.moneyTextF.text floatValue]*100 < 1){
            [SVProgressHUD showErrorWithStatus:@"最小单个金额为0.01"];
            return;
        }else if ([self.moneyTextF.text floatValue] > 200){
            [SVProgressHUD showErrorWithStatus:@"最大单个金额为200"];
            return;
        }else if ([self.myAccountMoney floatValue] < [self.moneyTextF.text floatValue]*[self.countTextF.text floatValue]) {
            [SVProgressHUD showErrorWithStatus:@"余额不足"];
            return;
        }
        
    }
    
    if(!self.isHavePayPassword)//未设置支付密码
    {
        
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"请先在钱包中设置支付密码" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
        
        return;
        
//        DCPaymentView *payAlert = [[DCPaymentView alloc]init];
//        payAlert.title = @"设置支付密码";
//        payAlert.detail = [NSString stringWithFormat:@"请输入6位数字"];
//        payAlert.amount= 0;
//        [payAlert setAmountLabelHidden:YES];
//        [payAlert show];
//        payAlert.completeHandle = ^(NSString *inputPwd) {
//
//            //请求网络，设置支付密码
//
//            [self setMyPayPassword:inputPwd];
//
//        };
//        return;
    }
    
    //发红包
    
    __weak typeof(self) weakSelf = self;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/chatapi/sendRedPacket",BASE_URL];
    
    int singleMoney = self.isPinType?0:(int)(100*[self.moneyTextF.text floatValue]);
//    int singleMoney = self.isPinType?0:(int)[self.moneyTextF.text floatValue];
    
    int totalMoney = (int)([[self.totalMoneyLabel.text stringByReplacingOccurrencesOfString:@"￥" withString:@""] doubleValue]*100);
    int rpcount = [self.countTextF.text intValue];
    
    if(rpcount >100 || rpcount <1 || totalMoney <1 || totalMoney> rpcount*200*100)
    {
        NSString *toast = @"";
        if(rpcount >100 || rpcount <1)
        {
            toast = [NSString stringWithFormat:@"一次最多发100个红包"];
        }
        else
        {
            toast = [NSString stringWithFormat:@"单个红包金额不超过200"];
        }
        
        [SVProgressHUD showInfoWithStatus:toast];
        return;
    }
    
    //发红包请求
    
    NSString * wishContentSec = self.contentTxt.text==nil || [self.contentTxt.text isEqualToString:@""]?DEFAULT_WISH:self.contentTxt.text;
    NSDate *currentDateSec = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatterSec = [[NSDateFormatter alloc] init];
    [dateFormatterSec setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateStringSec = [dateFormatterSec stringFromDate:currentDateSec];
    NSString *AppMessageIdSec = [NSString stringWithFormat:@"%@%@",dateStringSec,[NFUserEntity shareInstance].userName];
    
    NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];

    NSDictionary * dicFirst = @{@"title":@"红包",@"type":self.isPinType?@"0":@"1",@"count":[NSString stringWithFormat:@"%d",[self.countTextF.text intValue]],@"singleMoney":[NSString stringWithFormat:@"%d",singleMoney],@"totalMoney":[NSString stringWithFormat:@"%d",totalMoney],@"content":wishContentSec,@"toGroupId": self.toGroupId.length>0?self.toGroupId:@"0",@"toUserId": self.toUserId,@"isGroup": self.isGroup?@"1":@"0",@"payPassword":@"",@"appMsgId":AppMessageIdSec,@"device":dev_info_json};
    
    if(!self.isGroup){
        dicFirst = @{@"title":@"红包",@"type":@"1",@"count":@"1",@"singleMoney":[NSString stringWithFormat:@"%d",totalMoney],@"totalMoney":[NSString stringWithFormat:@"%d",totalMoney],@"content":wishContentSec,@"toGroupId":@"0",@"toUserId": self.toUserId,@"isGroup": @"0",@"payPassword":@"",@"appMsgId":AppMessageIdSec,@"device":dev_info_json};
    }
    
    redDicttt = [NSMutableDictionary dictionaryWithDictionary:dicFirst];
    
    
    
    DCPaymentView *payAlert = [[DCPaymentView alloc]init];
    payAlert.title = @"请输入支付密码";
    payAlert.detail = [NSString stringWithFormat:@"余额:%@",self.myAccountMoney];
    payAlert.amount= totalMoney/100.0;
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
//        [socketRequest sendredPacket:redDicttt];
        
        if (self.isGroup) {
        //        [socketRequest sendredPacketFirst:dicFirst];
                [socketRequest sendredPacketNew:redDicttt];
                
            }else{
                //单聊红包
        //        [socketRequest sendredPacketFirst:dicFirst];
                [socketRequest sendredPacketNew:redDicttt];
            }
        
        
        
    };
    payAlert.cancelHandle = ^{
        NSLog(@"");
    };
    //
        return ;
        
        NSString * wishContent = self.contentTxt.text==nil || [self.contentTxt.text isEqualToString:@""]?DEFAULT_WISH:self.contentTxt.text;
        
        [SVProgressHUD show];
        
        //发红包操作
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
        
//        CGFloat totalMoneyy = totalMoney/100;
//        NSString *aaa = [NSString stringWithFormat:@"%.2f",totalMoneyy];
        
        NSDictionary * dic = @{@"title":@"红包",@"type":self.isPinType?@"0":@"1",@"count":[NSString stringWithFormat:@"%d",[self.countTextF.text intValue]],@"singleMoney":[NSString stringWithFormat:@"%d",singleMoney],@"totalMoney":[NSString stringWithFormat:@"%d",totalMoney],@"content":wishContent,@"toGroupId": self.toGroupId,@"toUserId": self.toUserId,@"isGroup": self.isGroup?@"1":@"0",@"payPassword":@"",@"appMsgId":AppMessageId};
//        NSDictionary * dic = @{@"title":@"红包",@"type":self.isPinType?@"0":@"1",@"count":[NSString stringWithFormat:@"%d",[self.countTextF.text intValue]],@"singleMoney":[NSString stringWithFormat:@"%.2f",singleMoney],@"totalMoney":aaa,@"content":wishContent,@"toGroupId": self.toGroupId,@"toUserId": self.toUserId,@"isGroup": self.isGroup?@"1":@"0",@"payPassword":inputPwd,@"appMsgId":AppMessageId};
        
        NSLog(@"sendRedpacket--dic= %@",dic);
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
               // [socketRequest sendredPacket:dic];
            });
        });
        
        return ;
        /*
         senduserId    是    string    无
         thirdToken    是    string    无
         bundleId    是    string    无
         appId    是    string    无
         title    是    string    红包标题，由app设置
         type    是    int    类型，默认0为拼手气红包，1为普通红包
         count    是    int    本次发红包的总个数
         singleMoney    是    int    单个红包的金额(普通红包需要，随机红包不需要)
         totalMoney    是    int    红包总金额,单位分
         sessionId    否    string    本地回话id，单位分
         content    否    string    红包文字内容，由用户填写
         */
        
//        [[MKNetworkManager sharedInstance] requestNetWithParams:dic andMethod:@"POST" andURL:urlStr andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
//
//            [SVProgressHUD dismiss];
//            NSLog(@"sendRedpacket--responseDict= %@",responseDict);
//            if (error == nil)
//            {
//                if([responseDict[@"errcode"] intValue]==0)
//                {
//                    NSDictionary * dataDic = responseDict[@"data"];
//                    NSLog(@"sendRedpacket--dataDic= %@",dataDic);
//                    if(_sendRPFinishBlock)
//                    {
//                        /*
//                         kjrmfStatCancel = 0,     // 取消发送，用户行为
//                         kjrmfStatSucess = 1,     // 红包发送成功
//                         kjrmfStatUnknow,         // 其他
//                         --------------------------------------
//                         0是拼手气红包
//                         1是普通红包
//                         */
//                        _sendRPFinishBlock(dataDic[@"redpacketId"],dataDic[@"title"],dataDic[@"content"], 1, [dic[@"type"] intValue]);
//
//                        [self dismissViewControllerAnimated:YES completion:^{
//
//                        }];
//                    }
//                }
//                else
//                {
//                    NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
//                    //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
//                    [SVProgressHUD showInfoWithStatus:toast];
//                }
//            }
//            else
//            {
//                NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
//                //[self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
//                [SVProgressHUD showInfoWithStatus:toast];
//            }
//        }];
    
}


//-------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField==self.moneyTextF)
    {
        BOOL isRight = [self validateMoneyNumber:string andCurretStr:textField.text];
        NSString * resultStr = textField.text;
        
        if ([string isEqualToString:@""])
        {
            int i = (int)resultStr.length;
            NSString *str = [resultStr substringToIndex:i-1];
            resultStr = str;
        }
        
        if(isRight)
        {
            resultStr = [resultStr stringByAppendingString:string];
        }
        
        if(self.isPinType)
        {
            if([resultStr isEqualToString:@""])
            {
                self.totalMoneyLabel.text = @"￥0.00";
            }
            else
            {
                self.totalMoneyLabel.text = [@"￥" stringByAppendingString:resultStr];
            }
        }
        else
        {
            int count = self.countTextF.text?[self.countTextF.text intValue]:0;
            if(count>0)
            {
                float singleMoney = [resultStr floatValue];
                
                self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",((int)(singleMoney*100)*count)/100.0];
            }
            else
            {
                self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥0.00"];
                
            }
            
        }
        
        return isRight;
        
    }
    else if(textField==self.countTextF)
    {
        BOOL result = [self validateCountNumber:string andCurretStr:textField.text];
        if([string isEqualToString:@""])
        {
            //删除一个字符
            if(self.countTextF.text && [self.countTextF.text length]>0)
            {
                int i = (int)self.countTextF.text.length;
                NSString *strCount = [self.countTextF.text substringToIndex:i-1];
                
                self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",(strCount&&![strCount isEqualToString:@""]?[strCount intValue]:0)*[self.moneyTextF.text floatValue]];
            }
            else
            {
                self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥0.00"];
                
            }
            
        }
        
        if(!self.isPinType && result && ![string isEqualToString:@""])
        {
            int count = [[self.countTextF.text stringByAppendingString:string] intValue];
            float money = [self.moneyTextF.text floatValue];
            self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",count*money];
        }
        
        if(self.isPinType)
        {
            if(!self.moneyTextF.text || [self.moneyTextF.text isEqualToString:@""])
            {
                self.totalMoneyLabel.text = @"￥0.00";
            }
            else
            {
                self.totalMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[self.moneyTextF.text floatValue]];
            }
        }
        
        
        return result;
        
    }
    
    
    return YES;
}
//

// 限制字数
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        return YES;
    }
    if (textView.text.length > 25) {
        return NO;
    }
    return YES;
}



- (BOOL)validateCountNumber:(NSString*)number andCurretStr:(NSString *)curStr{
    
    if((!curStr || [curStr isEqualToString:@""]) && [number isEqualToString:@"0"])
    {
        return NO;
    }
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (BOOL)validateMoneyNumber:(NSString*)number andCurretStr:(NSString *)curStr {
    BOOL res = YES;
    
    if([curStr isEqualToString:@"0"] && [number isEqualToString:@"0"])
    {
        return NO;
    }
    
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    
    if([number isEqualToString:@"."])
    {
        if([curStr containsString:@"."] || (!curStr || [curStr length]==0))
            return NO;
    }
    else
    {
        if([curStr length]>=4 && ![number isEqualToString:@""])
        {
            NSRange range = [curStr rangeOfString:@"."];
            
            NSLog(@"position=(%d,%d)",range.length,range.location);
            if (range.location != NSNotFound && (range.location == [curStr length]-2-1))
            {
                return NO;
            }
            
        }
    }
    
    
    
    
    
    while (i < number.length)
    {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}




@end
