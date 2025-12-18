//
//  RPFRedpacketRecordVC.m
//  NIM
//
//  Created by King on 2019/2/23.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFRedpacketRecordVC.h"
#import "UIImageView+WebCache.h"
#import "MKNetworkManager.h"
#import "UIView+Toast.h"
#import "NSArray+DLog.h"
#import "NSDictionary+DLog.h"
#import "UILabel+DiffientStyle.h"
#import "RPFRedpacketRecordCell.h"
#import "MJRefresh.h"


#import "SocketModel.h"
#import "SocketRequest.h"


@interface RPFRedpacketRecordVC ()<UITableViewDataSource,UITableViewDelegate,ChatHandlerDelegate>

@property(nonatomic, assign)BOOL recordType;
@property(nonatomic, assign)int currentOffset;

@property(nonatomic, strong)UILabel * nameLabel;

@property(nonatomic, strong)UILabel * myGrabMoney;

@property(nonatomic, strong)UILabel * redpacketCountLabel;

@property(nonatomic, strong)UILabel * bestluckCountLabel;

@property(nonatomic, strong)UILabel * redpacketCountTitle;

@property(nonatomic, strong)UILabel * bestluckCountTitle;


@property(nonatomic, strong)UIButton * changeTypeBtn;


@end

@implementation RPFRedpacketRecordVC{
    
    UILabel *titleLLabel;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    
    
    BOOL reloading_;
    BOOL needReloading_;
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recordType = YES;//YES 领取的红包，NO 发出的红包
    self.currentOffset = 0;
    
    [self buildView];
    
    self.dataArray = [NSMutableArray new];
    
    [self initScoket];
    
    
    //红包记录
   // [self checkResult];
    
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
            isRefreshLashing_ = YES;
            [socketRequest redRecordListReqquest:@{@"recordType":self.recordType?@"1":@"0",
                                                   @"offset":[NSString stringWithFormat:@"%@",@(self.dataArray.count / [PAGE_LIMIT_COUNT integerValue] + 1)],
                                                   @"limit":PAGE_LIMIT_COUNT,
                                                   @"groupId":self.groupId.length > 0?self.groupId:@"0",
                                                   }];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

-(void)refreshFromLast{
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            isRefreshLashing_ = YES;
            [socketRequest redRecordListReqquest:@{@"recordType":@"0",
                                                   @"offset":[NSString stringWithFormat:@"%@",@(self.dataArray.count / [PAGE_LIMIT_COUNT integerValue] + 1)],
                                                   @"limit":PAGE_LIMIT_COUNT,
                                                   @"groupId":@"45",
                                                   }];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
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
    
    
//    [alertV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.backV_.mas_centerX);
//        make.centerY.mas_equalTo(self.backV_.mas_centerY).offset(- SCREEN_WIDTH / 4);
//        make.size.mas_equalTo(CGSizeMake(PopFrame_.size.width, PopFrame_.size.height));
//    }];
    
    
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
    
    
    //标题
    titleLLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, navBarViewHeight)];
    if(self.recordType){
        titleLLabel.text = @"收到的红包";
        [self.changeTypeBtn setTitle:@"收到的" forState:UIControlStateNormal];
    }else{
        titleLLabel.text = @"发出的红包";
        [self.changeTypeBtn setTitle:@"发出的" forState:UIControlStateNormal];
    }
    titleLLabel.textColor = [UIColor whiteColor];
    [singleNavigationBar addSubview:titleLLabel];
    [titleLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(singleNavigationBar.mas_centerX);
        make.centerY.mas_equalTo(leftBackBtn.mas_centerY);
    }];
    
    
    MJRefreshAutoNormalFooter * theFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"mj_footer---do---block");
        
        [self initScoket];
       // [self checkResult];
        
        
    }];
    
    [theFooter setTitle:@"正在加载 ..." forState:MJRefreshStateRefreshing];
    [theFooter setTitle:@"上拉加载更多" forState:MJRefreshStatePulling];
    [theFooter setTitle:@"没有更多数据" forState:MJRefreshStateNoMoreData];
    [theFooter setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
    
    
    self.tableView.mj_footer = theFooter;
}

//刷新ui
-(void)refreshDetailInfo
{
//    NIMUserInfo * uInfo = [self findUserInfo:self.userId];
//    NSString * headUrl = uInfo.avatarUrl;
    NSString * headUrl = [NFUserEntity shareInstance].mineHeadView;
    [self.headImgView sd_setImageWithURL:[[NSURL alloc] initWithString:headUrl&&headUrl.length>0?headUrl:@""] placeholderImage:[UIImage imageNamed:@"avatar_user"]];
    
    [self refreshTableHeadViewInfo_changeType:YES];
    [self.tableView reloadData];
    
}


//-(NIMUserInfo *)findUserInfo:(NSString *)userId
//{
//    NIMUser * user = [[NIMSDK sharedSDK].userManager userInfo:userId];
//
//    return user.userInfo;
//}

-(UIView *)createHeadView
{
    float headHeight = 180+40+30;
    float baseTopSpace = 5.0;//控件与上个控件的间距
    UIFont * baseFont = [UIFont systemFontOfSize:13.0];
    UIView * head = [[UIView alloc] init];
    head.frame = CGRectMake(0, 0, SCREEN_WIDTH, headHeight);
    head.backgroundColor = [UIColor whiteColor];
    
    float headView_height = 50.0;
    float topSpace_headView = 20.0;
    float baseHeight_label = 30.0;
    

    
    NFHeadImageView * headImgV = [[NFHeadImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-headView_height)/2.0, topSpace_headView, headView_height, headView_height)];
    headImgV.backgroundColor = [UIColor clearColor];
    [headImgV.layer setCornerRadius:HEAD_IMG_CornerRadius];
    [headImgV.layer setMasksToBounds:YES];
    if ([NFUserEntity shareInstance].mineHeadView.length > 0) {
        [headImgV ShowHeadImageWithUrlStr:[NFUserEntity shareInstance].mineHeadView withUerId:nil completion:^(BOOL success, UIImage *image) {
            
        }];
    }
    self.headImgView = headImgV;
    
    [head addSubview:headImgV];
    
    //----------
    float widthBtn = 60.0;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"发出的" forState:UIControlStateNormal];
    btn.frame = CGRectMake((SCREEN_WIDTH-widthBtn)-10, topSpace_headView, widthBtn, 30);
    self.changeTypeBtn = btn;
    [btn addTarget:self action:@selector(changeTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [head addSubview:btn];
    
    
    
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(0, CGRectGetMaxY(headImgV.frame)+baseTopSpace, SCREEN_WIDTH, baseHeight_label);
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    nameLabel.text = @"共收到";
    self.nameLabel = nameLabel;
    [head addSubview:nameLabel];
    
    //展示领包总金额
    UILabel * myGrabMoney = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame)+baseTopSpace, SCREEN_WIDTH, 50)];
    myGrabMoney.text = @"0.00";
    myGrabMoney.font = [UIFont boldSystemFontOfSize:32.0];
    myGrabMoney.textAlignment = NSTextAlignmentCenter;
    myGrabMoney.textColor = [UIColor blackColor];
    self.myGrabMoney = myGrabMoney;
    [head addSubview:myGrabMoney];
    
    //收到红包个数
    UILabel * redpacketCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(myGrabMoney.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 30)];
    redpacketCountLabel.text = @"0";
    redpacketCountLabel.font = [UIFont boldSystemFontOfSize:24.0];
    redpacketCountLabel.textAlignment = NSTextAlignmentCenter;
    redpacketCountLabel.textColor = [UIColor blackColor];
    self.redpacketCountLabel = redpacketCountLabel;
    [head addSubview:redpacketCountLabel];
    //手气最佳次数
    UILabel * bestluckCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(myGrabMoney.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 30)];
    bestluckCountLabel.text = @"0";
    bestluckCountLabel.font = [UIFont boldSystemFontOfSize:24.0];
    bestluckCountLabel.textAlignment = NSTextAlignmentCenter;
    bestluckCountLabel.textColor = [UIColor blackColor];
    self.bestluckCountLabel = bestluckCountLabel;
    [head addSubview:bestluckCountLabel];
    
    //"收到红包"
    UILabel * redpacketCountTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(redpacketCountLabel.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 20)];
    redpacketCountTitle.text = @"收到红包";
    redpacketCountTitle.font = [UIFont boldSystemFontOfSize:18.0];
    redpacketCountTitle.textAlignment = NSTextAlignmentCenter;
    redpacketCountTitle.textColor = [UIColor blackColor];
    self.redpacketCountTitle = redpacketCountTitle;
    [head addSubview:redpacketCountTitle];
    //"手气最佳"
    UILabel * bestluckCountTitle = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(bestluckCountLabel.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 20)];
    bestluckCountTitle.text = @"手气最佳";
    bestluckCountTitle.font = [UIFont boldSystemFontOfSize:18.0];
    bestluckCountTitle.textAlignment = NSTextAlignmentCenter;
    bestluckCountTitle.textColor = [UIColor blackColor];
    self.bestluckCountTitle = bestluckCountTitle;
    [head addSubview:bestluckCountTitle];
    
    CGRect headFrame = head.frame;
    headFrame.size.height = CGRectGetMaxY(bestluckCountTitle.frame)+20;
    head.frame = headFrame;
    
    head.backgroundColor = BGCOLOR_GRAY;
    
    return head;
    
}




-(void)changeTypeBtnClick:(UIButton*)btn
{
    self.recordType = !self.recordType;
    if(self.recordType)//收到的
    {
        [self.changeTypeBtn setTitle:@"收到的" forState:UIControlStateNormal];
        titleLLabel.text = @"收到的红包";
        self.nameLabel.text = @"共收到";
    }
    else//发出的
    {
        [self.changeTypeBtn setTitle:@"发出的" forState:UIControlStateNormal];
        titleLLabel.text = @"发出的红包";
        self.nameLabel.text = @"共发出";
        
    }
    
//    [self.dataArray removeAllObjects];
//    self.currentOffset = 0;
    
    //[self refreshTableHeadViewInfo_changeType:YES];
    
    self.dataArray = [NSMutableArray new];
    [self initScoket];
   // [self checkResult];
    
    
}

-(void)refreshTableHeadViewInfo_changeType:(BOOL)changeType
{
    if(!self.dataDict)
        return;
    
//    NIMUserInfo * uInfo = [self findUserInfo:self.userId];
//    NSString * headUrl = uInfo.avatarUrl;
    NSString * headUrl = [NFUserEntity shareInstance].mineHeadView;
    
    [self.headImgView sd_setImageWithURL:[[NSURL alloc] initWithString:headUrl?headUrl:@""] placeholderImage:[UIImage imageNamed:@"avatar_user"]];
    
    if(self.dataDict[@"totalMoney"] && self.dataDict[@"totalMoney"] != [NSNull null])
    {
        self.myGrabMoney.text = [NSString stringWithFormat:@"%.2f",[self.dataDict[@"totalMoney"] intValue]/100.0];
    }
    else
    {
        self.myGrabMoney.text = [NSString stringWithFormat:@"%.2f",0/100.0];
    }
//    self.nameLabel.text = uInfo.nickName;
    //self.nameLabel.text = @"";
//    self.bestluckCountLabel.text = [NSString stringWithFormat:@"%@",self.dataDict[@"bestLuckCount"]!=[NSNull null]?self.dataDict[@"bestLuckCount"]:@"0"];
    self.bestluckCountLabel.text = @"0";
    
    if(self.recordType)
    {
        //领取记录
        self.redpacketCountLabel.text = [NSString stringWithFormat:@"%@",self.dataDict[@"totalCount"]];

    }
    else
    {
        //发红包记录
        self.redpacketCountLabel.text = [NSString stringWithFormat:@"发出红包 %@ 个",self.dataDict[@"totalCount"]];

    }
    
    float baseTopSpace = 5.0;
    if(changeType && self.recordType)
    {
        self.redpacketCountLabel.hidden = NO;
        self.redpacketCountLabel.frame = CGRectMake(0, CGRectGetMaxY(self.myGrabMoney.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 30);
        self.redpacketCountTitle.hidden = NO;
        self.redpacketCountTitle.frame = CGRectMake(0, CGRectGetMaxY(self.redpacketCountLabel.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 20);
        self.bestluckCountLabel.hidden = NO;
        self.bestluckCountLabel.frame = CGRectMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(self.myGrabMoney.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 30);
        self.bestluckCountTitle.hidden = NO;
        self.bestluckCountTitle.frame= CGRectMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(self.bestluckCountLabel.frame)+baseTopSpace, SCREEN_WIDTH/2.0, 20);
        
    }
    
    if(changeType && !self.recordType)
    {
        self.redpacketCountLabel.hidden = NO;
        self.redpacketCountLabel.frame = CGRectMake(0, CGRectGetMaxY(self.myGrabMoney.frame)+baseTopSpace, SCREEN_WIDTH, 30);
        self.redpacketCountTitle.hidden = YES;
        self.bestluckCountLabel.hidden = YES;
        self.bestluckCountTitle.hidden = YES;

    }
    
    
    
}


-(void)backToPreviousVC:(UIButton *)btn
{
    //返回到上一页
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}




- (void)checkResult {
    
    
    
    
    
    
    
    
    
    return;
    
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/chatapi/QueryUserRedPacket",BASE_URL];
    
    NSDictionary * dic = @{@"userId":self.userId,@"thirdToken":self.thirdToken,@"bundleId":[[NSBundle mainBundle] bundleIdentifier],@"appId":self.appkey,@"redpacketRecordType":self.recordType?@"1":@"0",@"offset":[NSString stringWithFormat:@"%d",self.currentOffset],@"limit":PAGE_LIMIT_COUNT,@"groupId":self.groupId?self.groupId:@""};
    
    NSLog(@"QueryUserRedPacket---dic= %@",dic);
    
    [[MKNetworkManager sharedInstance] requestNetWithParams:dic andMethod:@"POST" andURL:urlStr andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        [self.tableView.mj_footer endRefreshing];
        
        NSLog(@"checkResult--responseDict= %@",responseDict);
        
        if (error == nil)
        {
            if([responseDict[@"errcode"] intValue]==0)
            {
                /*
                 grabId 为1时，是最后一个红包
                 */
                self.dataDict = responseDict;
                self.currentOffset += [PAGE_LIMIT_COUNT intValue];
                
                if(!responseDict[@"list"] || [responseDict[@"list"] count]<1)
                {
//                    NSString *toast = [NSString stringWithFormat:@"没有更多数据了"];
//                    [SVProgressHUD showInfoWithStatus:toast];
                }
                
               for(NSDictionary * dic in responseDict[@"list"])
               {
                   [self.dataArray addObject:dic];
               }
                
                [self refreshDetailInfo];
                
            }
            else
            {
                NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
                [SVProgressHUD showInfoWithStatus:toast];
                
            }
        }
        else
        {
            NSString *toast = [NSString stringWithFormat:@"%@",responseDict[@"msg"]];
            [SVProgressHUD showInfoWithStatus:toast];
            
        }
        
        
        
    }];
    
}


#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_RedRecordList) {
        NSDictionary *dict = chatModel;
        self.dataDict = @{@"totalMoney":[[dict objectForKey:@"totalMoney"] description],
                          @"totalCount":[[dict objectForKey:@"totalCount"] description],
                          };
        NSArray *arr = [dict objectForKey:@"redPacketList"];
        for (NSDictionary *dictt in arr) {
            RecordMoneyEntity *entity = [RecordMoneyEntity new];
            entity.redId = [[dictt objectForKey:@"redpacketId"] description];
            entity.titleDsc = [[[dictt objectForKey:@"type"] description] isEqualToString:@"0"]?@"拼手气红包":@"普通红包";
            entity.IsPin = [[[dictt objectForKey:@"type"] description] isEqualToString:@"0"]?YES:NO;
            entity.account = [NSString stringWithFormat:@"%.2f元",[[[dictt objectForKey:@"totalMoney"] description] floatValue]/100];
            entity.time = [[dictt objectForKey:@"sendtimes"] description];
            if([dictt objectForKey:@"groupId"]){
                entity.groupId = [[dictt objectForKey:@"groupId"] description];
            }else if ([dictt objectForKey:@"toGroupId"]){
                entity.groupId = [[dictt objectForKey:@"toGroupId"] description];
            }
                
            if([[[dictt objectForKey:@"isend"] description] isEqualToString:@"1"]){
                entity.detail = [NSString stringWithFormat:@"已领完 %@/%@个",[[dictt objectForKey:@"count"] description],[[dictt objectForKey:@"count"] description]];
            }else{
                NSString *sendTime = [[dictt objectForKey:@"sendtimes"] description];
                NSDate *currentDate = [NSDate date];//获取当前时间，日期
                NSTimeInterval interval = [currentDate timeIntervalSince1970];
                NSInteger timeInter = interval;
                NSString *nowTime = [NSString stringWithFormat:@"%ld",timeInter];
                if ([nowTime integerValue] - [sendTime integerValue] >= 86400) {
                    entity.detail = [NSString stringWithFormat:@"已退还 %@/%@个",[[dictt objectForKey:@"getCount"] description],[[dictt objectForKey:@"count"] description]];
                }else{
                    entity.detail = [NSString stringWithFormat:@"%@/%@个",[[dictt objectForKey:@"getCount"] description],[[dictt objectForKey:@"count"] description]];
                }
            }
            [self.dataArray addObject:entity];
        }
        
        if ([self.dataArray count] < [[dict objectForKey:@"totalCount"] integerValue])
        {
            self.tableView.mj_footer.state = MJRefreshStateIdle;
            canRefreshLash_ = YES;
        }
        else
        {
            self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
            canRefreshLash_ = NO;
        }
        [self refreshDetailInfo];
    }else if(messageType == SecretLetterType_RedRecordAcceptList){
        NSDictionary *dict = chatModel;
        self.dataDict = @{@"totalMoney":[[dict objectForKey:@"totalMoney"] description],
                          @"totalCount":[[dict objectForKey:@"totalCount"] description],
                          };
        NSArray *arr = [dict objectForKey:@"redPacketList"];
        for (NSDictionary *dictt in arr) {
            RecordMoneyEntity *entity = [RecordMoneyEntity new];
            entity.redId = [[dictt objectForKey:@"redpacketId"] description];
//            entity.titleDsc = [[dictt objectForKey:@"userName"] description];
//            entity.titleDsc = @"xxx的红包";
            entity.titleDsc = [NSString stringWithFormat:@"红包%@",[[dictt objectForKey:@"redpacketId"] description]];
            entity.IsPin = NO;
            entity.account = [NSString stringWithFormat:@"%.2f元",[[[dictt objectForKey:@"money"] description] floatValue]/100];
            entity.time = [[dictt objectForKey:@"gettimes"] description];
            entity.detail = @"";
            entity.groupId = [[dictt objectForKey:@"groupId"] description];
            
            [self.dataArray addObject:entity];
        }
        
        if ([self.dataArray count] < [[dict objectForKey:@"totalCount"] integerValue])        {
            self.tableView.mj_footer.state = MJRefreshStateIdle;
            canRefreshLash_ = YES;
        }
        else
        {
            self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
            canRefreshLash_ = NO;
        }
        [self refreshDetailInfo];
    }
    
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
    static NSString* cellIdentifier = @"NoMoreCellTableViewCell";
    if (self.dataArray.count == indexPath.row) {
        static NSString* cellIdentifier = nil;
        //分页相关
        cellIdentifier = @"cell_more";
        NoMoreCellTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"NoMoreCellTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //分页请求数据
        if (canRefreshLash_ && !isRefreshLashing_)
        {
            cell.titleLabel.text = @"加载更多...";
            [self performSelector:@selector(initScoket) withObject:nil afterDelay:0.2f];
        }
        else if (!canRefreshLash_)
        {
            cell.titleLabel.text = @"没有更多了";
        }
        return cell;
    }
    cellIdentifier = @"RedRecordTableViewCell";
    RedRecordTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"RedRecordTableViewCell" owner:nil options:nil]firstObject];
    }
    RecordMoneyEntity *entity= self.dataArray[indexPath.row];
    cell.nickNameLabel.text = entity.titleDsc;
    cell.nickNameLabel.text = @"红包";
    NSDate *date;
    if (entity.time.length > 0) {
        date = [NSDate dateWithTimeIntervalSince1970:[entity.time integerValue]];
    }else{
        date = [NSDate dateWithTimeIntervalSince1970:[entity.time integerValue]];
    }
    if ([date isThisYear]) {
        NSString *aa = [[NFbaseViewController new] timestampSwitchTime:[entity.time.length > 0?entity.time:entity.time integerValue] anddFormatter:@"MM-dd HH:mm:ss"];
        cell.timeLabel.text = aa;
        
    }else{
        if (entity.time.length > 0) {
            cell.timeLabel.text = [[NFbaseViewController new] timestampSwitchTime:[entity.time integerValue] anddFormatter:@"yyyy-MM-dd HH:mm:ss"];
        }else{
            cell.timeLabel.text = entity.time;
        }
    }
    cell.amountlabel.text = entity.account;
    if(!entity.IsPin){
        cell.imageV.hidden = YES;
    }
    if(entity.detail.length > 0){
        cell.detailLabelll.text = entity.detail;
    }else{
        cell.detailLabelll.hidden = YES;
    }
    return cell;
    //获取绑定标识的cell
//    RPFRedpacketRecordCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RPFRedpacketRecordCell"];
//    if (cell == nil)
//    {
//        cell = [RPFRedpacketRecordCell xibTableViewCell];
//    }
//    [cell refreshData:self.dataArray[(int)indexPath.row] type:self.recordType];
//    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 55.0;//高度模型内已经计算。
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    RecordMoneyEntity *entity = self.dataArray[indexPath.row];
    
    RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
    //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.groupId = entity.groupId;
    vc.redpacketId = entity.redId;
    //红包过期
    if(vc)
    {if (@available(iOS 13.0, *)) {
            vc.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
    }
    
}




@end
