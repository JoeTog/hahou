//
//  RPFRedpacketDetailVC.m
//  NIM
//
//  Created by King on 2019/2/8.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFRedpacketDetailVC.h"
#import "RPFRedpacketResultCell.h"
#import "UIImageView+WebCache.h"
#import "MKNetworkManager.h"
#import "UIView+Toast.h"
#import "NSArray+DLog.h"
#import "NSDictionary+DLog.h"
#import "UILabel+DiffientStyle.h"
#import "RPFRedpacketRecordVC.h"


@interface RPFRedpacketDetailVC ()<UITableViewDelegate, UITableViewDataSource,ChatHandlerDelegate>

@property(nonatomic,strong)NSDictionary * dataDic;

@property(nonatomic,strong)UIButton * redpacketTitle;
@property(nonatomic,strong)UILabel * rpContent;
@property(nonatomic,strong)UILabel * resultLabel;
@property(nonatomic,strong)UILabel * myGrabMoneyLabel;
@property(nonatomic,strong)UIButton * myAccount;//已存入余额

@property(nonatomic, assign)int currentOffset;


@end

@implementation RPFRedpacketDetailVC{
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD dismiss];
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

    self.currentOffset = 0;
    
   // [self checkResult];
    
    if(self.redDetailDict && [self.redDetailDict isKindOfClass:[NSDictionary class]]){
        
//        NSDictionary *dict = @{@"content":[self.redDetailDict objectForKey:@"content"],
//                               @"list":@[],
//                               @"count":[self.redDetailDict objectForKey:@"count"],
//                               @"senduserId":[self.redDetailDict objectForKey:@"senduserId"],
//                               @"totalMoney":[self.redDetailDict objectForKey:@"totalMoney"]
//                               };
        
        self.dataDic = self.redDetailDict;
        self.dataArray = [self.redDetailDict objectForKey:@"list"];
        [self buildView];
        [self refreshDetailInfo];
    }else{
        
        [self initScoket];
    }
    
    
    
}

#pragma mark - 初始化scoket
-(void)initScoket{
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    //检查红包
    if(self.groupId && self.groupId.length > 0){
        [socketRequest RedPacketDetail:@{@"groupId":self.groupId,@"redpacketId":self.redpacketId}];
    }else{
        [socketRequest RedPacketDetail:@{@"redpacketId":self.redpacketId}];
    }
    
    [self refreshDetailInfo];
    
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_lookPacket || messageType == SecretLetterType_packetCheck) {
        //红包详情
        [SVProgressHUD dismiss];
        
       // self.redDetailDict = chatModel;
        self.dataDic = chatModel;
        self.dataArray = [self.dataDic objectForKey:@"list"];
        [self buildView];
        [self refreshDetailInfo];
        
        
    }else if(messageType == SecretLetterType_RedOverdue){
        
        [SVProgressHUD dismiss];
        
        // self.redDetailDict = chatModel;
        self.isOverDue = YES;
        self.dataDic = chatModel;
        self.dataArray = [self.dataDic objectForKey:@"list"];
        [self buildView];
        [self refreshDetailInfo];
    }
    
}


-(NSMutableArray *)dataArray
{
    if(_dataArray==nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)buildView
{
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
    
    float width_rightBtn = 80.0;
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBtn setTitle:@"红包记录" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(jumpToRPRecordVC:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(SCREEN_WIDTH-spaceNavigation-width_rightBtn, singleNavigationBar.frame.size.height-spaceNavigation-backBtnHeight, width_rightBtn, backBtnHeight);
    rightBtn.backgroundColor = REDPACKET_COLOR;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [rightBtn.layer setCornerRadius:cornerRadius];
    [rightBtn.layer setMasksToBounds:YES];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[self.view addSubview:rightBtn];
    
    UITableView * tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(singleNavigationBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT-CGRectGetMaxY(singleNavigationBar.frame)-10)];
    tableV.backgroundColor = [UIColor orangeColor];
    
    UIView * hview = [self createHeadView];
    tableV.tableHeaderView = hview;
    //tableV.tableHeaderView.height
    
    tableV.backgroundColor = [UIColor whiteColor];//BGCOLOR_GRAY;
    tableV.dataSource = self;
    tableV.delegate = self;
    [self.view addSubview:tableV];
    self.tableView = tableV;
    //此处写入让其不显示下划线的代码
    self.tableView.tableFooterView = [[UIView alloc]init];
    
}

//刷新ui
-(void)refreshDetailInfo
{
//    NIMUserInfo * uInfo = [self findUserInfo:self.dataDic[@"senduserId"]];
//    NSString * headUrl = uInfo.avatarUrl;
    NSDictionary *senderDict = self.dataDic[@"senderInfo"];
        NSString * headUrl = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[senderDict objectForKey:@"photo"]];
    //[self.headImgView sd_setImageWithURL:[[NSURL alloc] initWithString:headUrl?headUrl:@""]];
    [self.headImgView sd_setImageWithURL:[[NSURL alloc] initWithString:headUrl?headUrl:@""] placeholderImage:[UIImage imageNamed:@"avatar_user"]];

    
    if(self.dataDic[@"content"]){
        self.rpContent.text = self.dataDic[@"content"];
    }else if(self.dataDic[@"redpacketInfo"]){
        NSDictionary *redpacketInfo = self.dataDic[@"redpacketInfo"];
        self.rpContent.text = [[redpacketInfo objectForKey:@"content"] description];
    }
    
//    [self.redpacketTitle setTitle:[NSString stringWithFormat:@"%@的红包",uInfo.nickName] forState:UIControlStateNormal];
    NSDictionary *sendinfo = [self.dataDic objectForKey:@"senderInfo"];
    [self.redpacketTitle setTitle:[NSString stringWithFormat:@"%@的红包",[sendinfo objectForKey:@"nickname"]] forState:UIControlStateNormal];
    [self.redpacketTitle setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"ic_pin"] forState:UIControlStateNormal];
    
    [self.redpacketTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.redpacketTitle.imageView.bounds.size.width, 0, self.redpacketTitle.imageView.bounds.size.width)];
    [self.redpacketTitle setImageEdgeInsets:UIEdgeInsetsMake(0, self.redpacketTitle.titleLabel.bounds.size.width, 0, -self.redpacketTitle.titleLabel.bounds.size.width)];
    
    NSString * title = @"";
    int grabCount = self.dataDic[@"list"]?(int)[self.dataDic[@"list"] count]:0;
    if([self.dataDic[@"count"] intValue] == grabCount)
    {
        if(self.isSingleMe){
            NSDictionary *redpacketInfo = self.dataDic[@"redpacketInfo"];
            if([[self.dataDic[@"status"] description] isEqualToString:@"0"]){
                //单聊红包 抢完走这里
                title = [NSString stringWithFormat:@"  %d个红包,%@抢完",grabCount,[self grabRPFinishSpendTime]];
            }else{
                //群红包走这里
                title = [NSString stringWithFormat:@"  红包金额%.2f元,等待对方领取",[[redpacketInfo objectForKey:@"singleMoney"] floatValue]/100];
            }
        }else{
            title = [NSString stringWithFormat:@"  %d个红包,%@抢完",grabCount,[self grabRPFinishSpendTime]];
        }
    }
    else
    {
        if(self.isOverDue){
            title = [NSString stringWithFormat:@"  该红包已过期。%d个红包,还剩%d个",[self.dataDic[@"count"] intValue],[self.dataDic[@"count"] intValue]-grabCount];
        }else{
            title = [NSString stringWithFormat:@"  %d个红包,还剩%d个",[self.dataDic[@"count"] intValue],[self.dataDic[@"count"] intValue]-grabCount];
        }
        
    }
    
    if([[NFUserEntity shareInstance].userId isEqualToString:self.dataDic[@"senduserId"]])
    {
        //我就是发包人
        title = [NSString stringWithFormat:@"  %@  共%.2f",title,[self.dataDic[@"totalMoney"] intValue]*0.01];
    }
    
    
    
    self.resultLabel.text = title;

    BOOL isSuccessGrab = NO;
    for(NSDictionary * dic in self.dataArray)
    {
        if([dic[@"getuserId"] isEqualToString:[NFUserEntity shareInstance].userId])
        {
            isSuccessGrab = YES;
            self.myGrabMoneyLabel.text = [NSString stringWithFormat:@"%.2f元",[dic[@"money"] intValue]/100.0];
            [self.myGrabMoneyLabel changeSubStrFont:[UIFont systemFontOfSize:18.0] currentText:@"元"];

            break;
        }
    }
    
    
    if(!isSuccessGrab)
    {
        self.myGrabMoneyLabel.text = [NSString stringWithFormat:@""];
        
    }
    
    [self.tableView reloadData];
    
}

//红包被抢完所用的时间
-(NSString *)grabRPFinishSpendTime
{
    long long maxTime = 0;
    for(NSDictionary * dic in self.dataArray)
    {
        if([dic[@"gettimes"] longLongValue] > maxTime)
        {
            maxTime = [dic[@"gettimes"] longLongValue];
        }
    }
    
    long long spendTime = maxTime - [self.dataDic[@"sendtimes"] longLongValue];
    int hours = (int)spendTime/60/60;
    int minutes = (int)(spendTime-60*60*hours)/60;
    int seconds = spendTime%60;
    
    return [NSString stringWithFormat:@"%@%@%@",hours>0?[NSString stringWithFormat:@"%d时",hours]:@"",minutes>0?[NSString stringWithFormat:@"%d分",minutes]:@"",[NSString stringWithFormat:@"%d秒",seconds]];
    
}


//-(NIMUserInfo *)findUserInfo:(NSString *)userId
//{
//    NIMUser * user = [[NIMSDK sharedSDK].userManager userInfo:userId];
//
//    return user.userInfo;
//
//}

-(UIView *)createHeadView
{
    float headHeight = 180+40+30;
    
    float baseTopSpace = 5.0;//控件与上个控件的间距
    
    UIFont * baseFont = [UIFont systemFontOfSize:13.0];
    
    UIView * head = [[UIView alloc] init];
    head.frame = CGRectMake(0, 0, SCREEN_WIDTH, headHeight);
    UIImageView * imgV = [[UIImageView alloc] initWithImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"ic_circle"]];
    float imgV_height = headHeight*0.4;
    imgV.frame = CGRectMake(0, 0, SCREEN_WIDTH, imgV_height);
    [head addSubview:imgV];
    
    head.backgroundColor = [UIColor whiteColor];
    
    UIImageView * headImgV = [[UIImageView alloc] initWithImage:[BaseRPFViewController findImgFromBundle:@"NIMKitResource" andImgName:@"avatar_user"]];
    float headView_height = 50.0;
    headImgV.frame = CGRectMake((SCREEN_WIDTH-headView_height)/2.0, imgV_height-headView_height/2.0, headView_height, headView_height);
    headImgV.backgroundColor = [UIColor clearColor];
    [headImgV.layer setCornerRadius:HEAD_IMG_CornerRadius];
    [headImgV.layer setMasksToBounds:YES];
    self.headImgView = headImgV;
    
    [head addSubview:headImgV];
    
    UIButton * redpacketTitle = [[UIButton alloc] init];
    redpacketTitle.frame = CGRectMake(0, CGRectGetMaxY(headImgV.frame), SCREEN_WIDTH, 30);
    [redpacketTitle setTitle:@"" forState:UIControlStateNormal];
    [redpacketTitle.titleLabel setFont:baseFont];
    [redpacketTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [redpacketTitle setImage:[BaseRPFViewController findImgFromBundle:@"JResource" andImgName:@"ic_pin"] forState:UIControlStateNormal];

    [redpacketTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, -redpacketTitle.imageView.bounds.size.width, 0, redpacketTitle.imageView.bounds.size.width)];
    [redpacketTitle setImageEdgeInsets:UIEdgeInsetsMake(0, redpacketTitle.titleLabel.bounds.size.width, 0, -redpacketTitle.titleLabel.bounds.size.width)];
    self.redpacketTitle = redpacketTitle;
    [head addSubview:redpacketTitle];
    
    float x_contentLabel = 15.0;
    UILabel * content = [[UILabel alloc] initWithFrame:CGRectMake(x_contentLabel, CGRectGetMaxY(redpacketTitle.frame), SCREEN_WIDTH-x_contentLabel*2, 24)];
    content.text = @"恭喜发财，大吉大利！";
    content.textAlignment = NSTextAlignmentCenter;
    content.textColor = BASE_GRAY;
    //content.backgroundColor = [UIColor blueColor];
    content.font = [UIFont systemFontOfSize:14.0];
    self.rpContent = content;
    [head addSubview:content];
    
    
    //展示领包金额
    UILabel * myGrabMoney = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(content.frame)+baseTopSpace, SCREEN_WIDTH, 50)];
    myGrabMoney.text = @"0.00元";
    myGrabMoney.font = [UIFont boldSystemFontOfSize:32.0];
    myGrabMoney.textAlignment = NSTextAlignmentCenter;
    myGrabMoney.textColor = [UIColor blackColor];
    //[myGrabMoney changeSubStrFont:[UIFont systemFontOfSize:18.0] currentText:@"元"];
    self.myGrabMoneyLabel = myGrabMoney;
    [head addSubview:myGrabMoney];
    
    //已存入余额
//    UIButton * myAccount = [UIButton buttonWithType:UIButtonTypeSystem];
//    myAccount.frame = CGRectMake(0, CGRectGetMaxY(myGrabMoney.frame)+baseTopSpace, SCREEN_WIDTH, 30);
//    [myAccount setTitle:@"已存入余额，可用于发红包" forState:UIControlStateNormal];
//    [myAccount.titleLabel setFont:baseFont];
//    //[myAccount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.myAccount = myAccount;
//    [head addSubview:myAccount];
    
    //i提示红包数量和金额，例如：已领取2/3个，共0.03/0.06元    (未领完)
    UILabel * resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(myGrabMoney.frame)+baseTopSpace, SCREEN_WIDTH, 30)];
    resultLabel.text = @"  ";
    resultLabel.font = [UIFont systemFontOfSize:14.0];
    resultLabel.textAlignment = NSTextAlignmentLeft;
    resultLabel.textColor = BASE_GRAY;
    resultLabel.backgroundColor = BGCOLOR_GRAY;
    self.resultLabel = resultLabel;
    [head addSubview:resultLabel];
    
    
    
    CGRect headFrame = head.frame;
    headFrame.size.height = CGRectGetMaxY(resultLabel.frame);
    
    head.frame = headFrame;
    
    
    return head;
}


-(void)backToPreviousVC:(UIButton *)btn
{
    //返回到上一页
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//这里不走了
-(void)jumpToRPRecordVC:(UIButton *)btn
{
    RPFRedpacketRecordVC * vc = [[RPFRedpacketRecordVC alloc] init];
    //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.thirdToken = self.thirdToken;
    vc.userId = [NFUserEntity shareInstance].userId;
    vc.redpacketId = self.redpacketId;
    vc.appkey = self.appkey;
    vc.groupId = self.groupId;
    if (@available(iOS 13.0, *)) {
        vc.modalPresentationStyle =UIModalPresentationFullScreen;
    }
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

- (void)checkResult {
    
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/chatapi/getRedPacketInfo",BASE_URL];
    
    NSDictionary * dic = @{@"userId":[NFUserEntity shareInstance].userId,@"thirdToken":self.thirdToken,@"bundleId":[[NSBundle mainBundle]bundleIdentifier],@"appId":self.appkey,@"redpacketId":self.redpacketId,@"offset":[NSString stringWithFormat:@"%d",self.currentOffset],@"limit":PAGE_LIMIT_COUNT};
    //[[NSBundle mainBundle]bundleIdentifier]
    NSLog(@"checkResult--redpacket--dic= %@",dic);
    /*
     userId    是    string    无
     thirdToken    是    string    无
     bundleId    是    string    无
     appId    是    string    无
     redpacketId    是    string    无
     */
    
    [[MKNetworkManager sharedInstance] requestNetWithParams:dic andMethod:@"POST" andURL:urlStr andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        [SVProgressHUD dismiss];
        NSLog(@"checkResult--responseDict= %@",responseDict);
        if (error == nil)
        {
            if([responseDict[@"errcode"] intValue]==0)
            {
                /*
                 grabId 为1时，是最后一个红包
                 */
                NSDictionary * dataDic = responseDict[@"data"];
                NSLog(@"checkResult--dataDic= %@",dataDic);
                self.dataDic = [NSDictionary dictionaryWithDictionary:dataDic];
                
                if(self.dataDic[@"list"])
                {
                    for(NSDictionary * dic in self.dataDic[@"list"])
                    {
                        [self.dataArray addObject:dic];
                    }
                    
                    self.currentOffset += [PAGE_LIMIT_COUNT intValue];
                }
                
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
        
        [self buildView];
        [self refreshDetailInfo];

//        [self dismissViewControllerAnimated:YES completion:^{
//
//        }];
        
    }];
    
}


//---------------tableview-delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取绑定标识的cell
    RPFRedpacketResultCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RPFRedpacketResultCell"];
    if (cell == nil)
    {
        cell = [RPFRedpacketResultCell xibTableViewCell];
    }

    [cell refreshData:self.dataArray[(int)indexPath.row]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.0;//高度模型内已经计算。
}


@end
