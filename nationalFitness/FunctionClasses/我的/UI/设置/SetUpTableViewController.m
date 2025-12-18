//
//  SetUpTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "SetUpTableViewController.h"
#import "NFMineEntity.h"
#import "SocketModel.h"


@interface SetUpTableViewController ()<ChatHandlerDelegate>
@property(nonatomic,strong)HCDTimer *timer;

@property(nonatomic,weak)JQFMDB *jqFmdb;

@end

@implementation SetUpTableViewController{
    //设置的tableview
    IBOutlet UITableView *SetUpTableView;
    
    __weak IBOutlet UIButton *quitBtn;
    
    //版本信息
    __weak IBOutlet UILabel *versionLabel;
    
    
//    JQFMDB *jqFmdb;
    SocketModel *socketModel;
    SocketRequest *socketRequest;
    //记录需要请求到的单聊历史人数
    NSInteger singleCount;
    //记录需要请求到的群聊count
    NSInteger groupCount;
    //记录缓存联系人数
    NSArray *contactArr;
    //参与聊天的群聊
    NSArray *groupArr;
    //需要缓存的总进度 【单聊群聊多少个】
    NSInteger serverTotalDataCount;
    //已经缓存的进度 【已经缓存 完成 单聊群聊多少个】
    NSInteger alreadyCacheTotalData;
    //是否正在恢复历史记录中
    BOOL IsRecovering;
    //是否正在显示进度
    BOOL IsSVPShowing;
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if ([NFUserEntity shareInstance].IsRecovering) {
        //如果正在恢复中 强制退回 则提示将会缓存失败
        
    }
    [self.timer invalidate];
    [NFUserEntity shareInstance].IsRecovering = NO;//界面消失 关闭限制 获取聊天历史结束
    
    // 关闭屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel = [SocketModel share];
        socketModel.delegate = self;
    }
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
//        self.navigationController.navigationBarHidden = NO;
//        self.navigationController.navigationBar.translucent = translucentBOOL;
    
    UIImageView *backImageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
    //图片名字
    NSString *backGroundImageName = [NSString new];
    if (entityy.themeSelectedIndex == 0) {
        backGroundImageName = @"底";
    }else if (entityy.themeSelectedIndex == 1){
        backGroundImageName = @"";
    }
    
    [SetUpTableView reloadData];
    
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    
    [self initColor];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置窗口亮度大小  范围是0.1 - 1.0
//    [[UIScreen mainScreen] setBrightness:0.5];
    //设置屏幕常亮
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //    //NSCachesDirectory  NSDocumentDirectory
//    NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
//    NSLog(@"\n\n%@\n\n",cachPath);
    
    self.title = @"设置";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    singleCount = 0; //需要缓存的单聊个数
    groupCount = 0;//需要缓存的群聊个数
    
    alreadyCacheTotalData = 0;
    serverTotalDataCount = 0;//需要缓存的总条数
    
    //展示缓存
    self.jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *friendArrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [self.jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        friendArrs = [strongSelf.jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    contactArr = [NSArray arrayWithArray:friendArrs];
    
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    //版本号
    versionLabel.text = [NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    
    
    
    
    
}

-(void)initUI{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    [button setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [button setTitle:@"恢复聊天记录" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(requestAllData) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *ButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
//    self.navigationItem.rightBarButtonItems = @[ButtonItem];;
    
    
    self.tableView.tableFooterView = [UIView new];
    
    ViewRadius(quitBtn, 3);
//    quitBtn.backgroundColor = [UIColor colorThemeColor];
    //receive_user_id  user_id msg_type audio
    
    
}

/**
 *  将数组拆分成固定长度的子数组
 *
 *  @param array 需要拆分的数组
 *
 *  @param subSize 指定长度
 *
 */
- (NSArray *)splitArray: (NSArray *)array withSubSize : (int)subSize{
    //  数组将被拆分成指定长度数组的个数
    unsigned long count = array.count % subSize == 0 ? (array.count / subSize) : (array.count / subSize + 1);
    //  用来保存指定长度数组的可变数组对象
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    //利用总个数进行循环，将指定长度的元素加入数组
    for (int i = 0; i < count; i ++) {
        //数组下标
        int index = i * subSize;
        //保存拆分的固定长度的数组元素的可变数组
        NSMutableArray *arr1 = [[NSMutableArray alloc] init];
        //移除子数组的所有元素
        [arr1 removeAllObjects];
        int j = index;
        //将数组下标乘以1、2、3，得到拆分时数组的最大下标值，但最大不能超过数组的总大小
        while (j < subSize*(i + 1) && j < array.count) {
            [arr1 addObject:[array objectAtIndex:j]];
            j += 1;
        }
        //将子数组添加到保存子数组的数组中
        [arr addObject:[arr1 copy]];
    }
    return [arr copy];
}

#pragma mark - 9001
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_ChatAllHistory) {//4012 获取所有单聊历史返回
        [self.timer invalidate];
        NSDictionary *chatDataDict = chatModel;
        self.jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        NSArray *singleChatArr = [chatDataDict objectForKey:@"singleArr"];
        __block MessageChatEntity *serverLastEntity = [singleChatArr lastObject];//记录每次请求到的呃最后一条数据，当换个人请求时 这个设置nil
        if (singleChatArr.count == 80) {
            NSLog(@"");
        }
        
        if(contactArr.count <= singleCount){
            return;
        }
        
        __block NSInteger singleAlreadyCache = 0;
        dispatch_group_t group = dispatch_group_create();
//        if (singleChatArr.count > 100) {
//            NSArray *arr = [self splitArray:singleChatArr withSubSize:100];
//            for (NSArray *intervalArr in arr) {//去100ge
                dispatch_group_async(group, dispatch_queue_create("JoeThread", DISPATCH_QUEUE_SERIAL), ^{
                    __weak ZJContact *singleContact = contactArr[singleCount]; //friend_username friend_userid
                    __block CGFloat startPercent = (CGFloat)alreadyCacheTotalData/serverTotalDataCount;//已经缓存了的百分比
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([rootViewController isKindOfClass:[SetUpTableViewController class]]) {
                        [self.timer invalidate];
                        return ;
                    }
                    [SVProgressHUD showProgress:startPercent status:[NSString stringWithFormat:@"正在恢复'%@'",singleContact.friend_nickname]];
                    for (MessageChatEntity *entity in singleChatArr) {
                        [weakSelf.jqFmdb jq_inDatabase:^{
                            BOOL ret = [weakSelf.jqFmdb jq_insertTable:singleContact.friend_userid dicOrModel:entity];
                            //                    MessageChatEntity *entityy = [MessageChatEntity new];
                            //                    entity.chatId = @"1";
                            //                    BOOL ret = [weakSelf.jqFmdb jq_insertTable:@"6" dicOrModel:entityy];
                            if (!ret) {
                                [SVProgressHUD showInfoWithStatus:@"部分消息缓存失败"];
                            }else{
                            }
                        }];
                        
                        singleAlreadyCache ++;
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            if (singleAlreadyCache == singleChatArr.count) {
                                // 已完成进度条设置
//                                alreadyCacheTotalData ++;
                                startPercent = (CGFloat)alreadyCacheTotalData/serverTotalDataCount;//已经缓存了的百分比
                                
                                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                                if ([rootViewController isKindOfClass:[SetUpTableViewController class]]) {
                                    [self.timer invalidate];
                                    return ;
                                }
                                [SVProgressHUD showProgress:startPercent status:@"恢复准备中"];
//                                self.timer = [HCDTimer repeatingTimerWithTimeInterval:25 block:^{
//                                    [SVProgressHUD showProgress:startPercent status:@"恢复准备中"];
//                                }];
                            }else{
                                if (!IsSVPShowing) {//
                                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                                    if ([rootViewController isKindOfClass:[SetUpTableViewController class]]) {
                                        [self.timer invalidate];
                                        return ;
                                    }
                                    [SVProgressHUD showProgress:startPercent status:[NSString stringWithFormat:@"正在恢复'%@' %ld/%ld",singleContact.friend_nickname,singleAlreadyCache,singleChatArr.count]];
                                    IsSVPShowing = YES;
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        IsSVPShowing = NO;
                                    });
                                }
                                
                            }
                        });
                    }
                    // 已完成进度条设置
                    //            alreadyCacheTotalData ++;
                    if (singleChatArr.count < [limitCount integerValue] || singleChatArr.count == 0) {
                        alreadyCacheTotalData ++;
                        singleCount ++; //缓存完一个++ 下面请求后面一个 【如果为最后一个 则进行群聊记录恢复】
                        serverLastEntity = nil;//当 当前的对象聊天记录请求完毕 则设置最后一条消为nil 后面再根据singleCount取联系人数组中的人后 请求该人的第0条数据
                    }
                });
//            }
//        }
        
        
        
        dispatch_group_notify(group, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            if (singleCount < contactArr.count) {//小于index为 contactArr.count
                ZJContact *contact = contactArr[singleCount];
                [self.fmdbServicee IsExistSingleChatHistory:contact.friend_userid];
                
                [socketRequest getAllDataOfSingleChatWithFriendId:contact.friend_userid FriendName:contact.friend_username LastMessageId:serverLastEntity.chatId];//请求 某一个单聊所有历史
            }else if (singleCount == contactArr.count){
                if (groupArr.count > 0) {
                    ZJContact *groupContact = [groupArr firstObject];//请求第一条群聊历史
                    [self.fmdbServicee IsExistGroupChatHistory:[NSString stringWithFormat:@"qunzu%@",groupContact.friend_userid] ISNeedAppend:NO];
                    [socketRequest getAllDataOfGroupChatWithGroupId:groupContact.friend_userid GroupName:groupContact.friend_username LastMessageId:@"0"];//请求 某一个群聊所有历史
                    
                }
            }
        });
    }else if (messageType == SecretLetterType_AllGroupList){//得到 所有参与群聊聊天的数组 5029
        [self.timer invalidate];
        //接收到 所有参与群聊的信息
        if (![chatModel isKindOfClass:[NSDictionary class]]) {
            return;
        }
        groupArr = [chatModel objectForKey:@"groupArr"];
        serverTotalDataCount = 0;//恢复所有数据 第一步会走到这里 初始化总个数
        serverTotalDataCount += contactArr.count;
        serverTotalDataCount += groupArr.count;// 记录返回的群组个数
        
        [self requestAllData];//开始恢复数据 【先恢复单聊】
        
    }else if (messageType == SecretLetterType_GroupChatAllHistory){//获取所有群聊历史返回 5030
        [self.timer invalidate];
        NSDictionary *chatDataDict = chatModel;
        self.jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        
        NSArray *groupChatArr = [chatDataDict objectForKey:@"groupArr"];
        __block MessageChatEntity *serverLastEntity = [groupChatArr lastObject];//记录每次请求到的呃最后一条数据，当换个人请求时 这个设置nil
        
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, dispatch_queue_create("JoeThread", DISPATCH_QUEUE_SERIAL), ^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            ZJContact *groupContact = groupArr[groupCount];//获取群组信息 friend_username friend_userid
            
            __block CGFloat startPercent = (CGFloat)alreadyCacheTotalData/serverTotalDataCount;//已经缓存了的百分比
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            if ([rootViewController isKindOfClass:[SetUpTableViewController class]]) {
                [self.timer invalidate];
                return ;
            }
            [SVProgressHUD showProgress:startPercent status:[NSString stringWithFormat:@"正在恢复'%@'",groupContact.friend_nickname]];
            
            __block NSInteger groupAlreadyCache = 0;
            for (MessageChatEntity *entity in groupChatArr) {
                [weakSelf.jqFmdb jq_inDatabase:^{
                    BOOL ret = [weakSelf.jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",groupContact.friend_userid] dicOrModel:entity];
                    if (!ret) {
                        [SVProgressHUD showInfoWithStatus:@"部分消息缓存失败"];
                    }else{
                        groupAlreadyCache ++;
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (groupAlreadyCache == groupChatArr.count) {
                        // 已完成进度条设置
//                        alreadyCacheTotalData ++;
                        startPercent = (CGFloat)alreadyCacheTotalData/serverTotalDataCount;//已经缓存了的百分比
                        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                        if ([rootViewController isKindOfClass:[SetUpTableViewController class]]) {
                            [self.timer invalidate];
                            return ;
                        }
                        [SVProgressHUD showProgress:startPercent status:@"恢复准备中"];
                        //不需要 因为做了屏幕还是会暗
//                        self.timer = [HCDTimer repeatingTimerWithTimeInterval:25 block:^{
//                            [SVProgressHUD showProgress:startPercent status:@"恢复准备中"];
//                        }];
                    }else{
                        if (!IsSVPShowing) {
                            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                            if ([rootViewController isKindOfClass:[SetUpTableViewController class]]) {
                                [self.timer invalidate];
                                return ;
                            }
                            [SVProgressHUD showProgress:startPercent status:[NSString stringWithFormat:@"正在恢复'%@' %ld/%ld",groupContact.friend_nickname,groupAlreadyCache,groupChatArr.count]];
                            IsSVPShowing = YES;
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                IsSVPShowing = NO;
                            });
                        }
                    }
                });
            }
            // 已完成进度条设置
            if (groupChatArr.count < [limitCount integerValue] || groupChatArr.count == 0) {
                alreadyCacheTotalData ++;
                groupCount ++;//缓存完一个 ++ 后面请求后面一个 【如果等于groupArr.count 则说明缓存完毕】
                serverLastEntity = nil;//当 当前的对象聊天记录请求完毕 则设置最后一条消为nil 后面再根据singleCount取联系人数组中的人后 请求该人的第0条数据
            }
        });
        dispatch_group_notify(group, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            if (groupCount < groupArr.count) {
                ZJContact *groupContact = groupArr[groupCount];//请求群聊历史
                [self.fmdbServicee IsExistGroupChatHistory:[NSString stringWithFormat:@"qunzu%@",groupContact.friend_userid] ISNeedAppend:NO];
                [socketRequest getAllDataOfGroupChatWithGroupId:groupContact.friend_userid GroupName:groupContact.friend_username LastMessageId:serverLastEntity.chatId];//请求 某一个群聊所有历史
            }else if (groupCount == groupArr.count){
                [self.timer invalidate];
                [SVProgressHUD dismiss];//移除svp
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [NFUserEntity shareInstance].IsRecovering = NO;//获取成功 关闭限制
                    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"恢复消息成功" sureBtn:@"确认" cancleBtn:nil];
                    alertView.resultIndex = ^(NSInteger index)
                    {
                    };
                    [alertView showMKPAlertView];
                });
            }
        });
    }else if(messageType == SecretLetterType_logoffSuccess){

                    [socketRequest clearJPUSHServiceId];//关闭推送 设置推送id为nil
        //            [NFUserEntity shareInstance].appStatus = NO;//这里设置为后台 为的是在登录界面不接受消息 【退出登录 等于就是到后台】
                    [NFUserEntity shareInstance].userId = @"";
                    [KeepAppBox keepVale:@"" forKey:kLoginPassWord];
                    [KeepAppBox keepVale:@"" forKey:kLoginWeixinUserName];
                    [NFUserEntity shareInstance].userName = @"";
                    [NFUserEntity shareInstance].JPushId = @"";
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_LgoinHome];
                    //退出登录 销毁定时请求
                    [[GCDTimerManager sharedInstance] cancelTimerWithName:@"checkHeartTuikuan"];
                    [NFUserEntity shareInstance].isTiXianPassWord = NO;
                    [NFUserEntity shareInstance].isTiXianPassWord = NO;
                    [NFUserEntity shareInstance].isShouquanCancelPwd = NO;
    }
}

#pragma mark - 请求所有单聊数据
-(void)requestAllData{
//    if ([NFUserEntity shareInstance].IsRecovering) {//正在恢复聊天数据 限制操作
//        return;
//    }
    self.jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    NSArray *contentsss = [self.jqFmdb jq_selectedAllTableName];
    __block BOOL IsClear = YES;
    for (NSString *qunzuChatTable in contentsss) {
        if (![qunzuChatTable containsString:@"keepBoxEntity"]&&![qunzuChatTable containsString:@"xinxiaoxiTongzhi"]&&![qunzuChatTable containsString:@"yinsiSet"]&&![qunzuChatTable containsString:@"groupDetailliebiao"]&&![qunzuChatTable containsString:@"groupMenberliebiao"]&&![qunzuChatTable containsString:@"lianxirenliebiao"]&&![qunzuChatTable containsString:@"qunzuliebiao"]){
            __weak typeof(self)weakSelf=self;
            [self.jqFmdb jq_inDatabase:^{
               int dataaCount = [self.jqFmdb jq_tableItemCount:qunzuChatTable];
                if (dataaCount > 0) {
                    IsClear = NO;
                }
            }];
        }
        if (!IsClear) {
            break;//如果已经未 未清除 则直接break
        }
    }
    if (!IsClear) {
        [SVProgressHUD showInfoWithStatus:@"请先清除本地缓存!"];
        return;
    }
//    [SVProgressHUD show];
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络"];
        return;
    }
    
    //初始化进度
//    alreadyCacheTotalData = 0;
//    serverTotalDataCount = 8518;//需要缓存的总条数
    
    [SVProgressHUD dismiss];
    //用户提示
    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"请保持网络畅通，不要离开此界面" sureBtn:@"确认" cancleBtn:@"取消"];
    alertView.resultIndex = ^(NSInteger index)
    {
        if (index == 1) {
            //取消 不做任何操作
//            return ;
        }else{
            [SVProgressHUD showProgress:0 status:@"正在恢复中"];
            [NFUserEntity shareInstance].IsRecovering = YES;//正在恢复
            //    [jqFmdb jq_inDatabase:^{
            
//            serverTotalDataCount += contactArr.count; //当记录完群组个数后 到这里记录所有单聊个数 即将开始请求单聊历史
            if (contactArr.count > 0) {
                ZJContact *contact = [contactArr firstObject];
                [self.fmdbServicee IsExistSingleChatHistory:contact.friend_userid];
//                [socketRequest getAllDataOfSingleChatWithFriendId:contact.friend_userid FriendName:contact.friend_username];//请求 某一个单聊所有历史
                [socketRequest getAllDataOfSingleChatWithFriendId:contact.friend_userid FriendName:contact.friend_username LastMessageId:@"0"];
            }else{
                [SVProgressHUD showWithStatus:@"请先刷新联系人列表，确保至少有一个联系人"];
//                [SVProgressHUD showInfoWithStatus:@"请先刷新联系人列表，确保至少有一个联系人"];
            }
        }
    };
    [alertView showMKPAlertView];
    
   
}

-(void)initColor{
    
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secondLabel.textColor = [UIColor colorMainTextColor];
    self.thirdLabel.textColor = [UIColor colorMainTextColor];
    self.forthlabel.textColor = [UIColor colorMainTextColor];
    self.fifthLabel.textColor = [UIColor colorMainTextColor];
    self.sixthLabel.textColor = [UIColor colorMainTextColor];
    self.seventhLasbel.textColor = [UIColor colorMainTextColor];
    self.eightthLabel.textColor = [UIColor colorMainTextColor];
    self.ninthLabel.textColor = [UIColor colorMainTextColor];
    self.tenthLabel.textColor = [UIColor colorMainTextColor];
    self.eleventhLabel.textColor = [UIColor colorMainTextColor];
    self.TwelvetnLabel.textColor = [UIColor colorMainTextColor];
    self.thirTeenthLabel.textColor = [UIColor colorMainTextColor];

    
    
    self.firstLabel.font = [UIFont fontMainText];
    self.secondLabel.font = [UIFont fontMainText];
    self.thirdLabel.font = [UIFont fontMainText];
    self.forthlabel.font = [UIFont fontMainText];
    self.fifthLabel.font = [UIFont fontMainText];
    self.sixthLabel.font = [UIFont fontMainText];
    self.seventhLasbel.font = [UIFont fontMainText];
    self.eightthLabel.font = [UIFont fontMainText];
    self.ninthLabel.font = [UIFont fontMainText];
    self.tenthLabel.font = [UIFont fontMainText];
    self.eleventhLabel.font = [UIFont fontMainText];
    self.TwelvetnLabel.font = [UIFont fontMainText];
    self.thirTeenthLabel.font = [UIFont fontMainText];

}

- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}


//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        return;
    }
    cell.backgroundColor = [UIColor whiteColor];
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 4) {
        return 0.1;
    }
    return 10;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    if (section == 1) {
//        return 3;
        return 2;
    }else if (section == 3){
//        return 2;
        return 3; //注销账号cell
//        return 0;
    }
//    else if (section == 4){
//            return 3;
//
//    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}


//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([NFUserEntity shareInstance].IsRecovering) {//正在恢复聊天数据 限制操作
        return;
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //修改密码
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
//            PassWordChangeTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PassWordChangeTableViewController"];
//            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            //消息通知
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            NewMessageNotificateTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"NewMessageNotificateTableViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 1){
            //好友设置 FriendSetTableViewController
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            FriendSetTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"FriendSetTableViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
        else if (indexPath.row == 2){
            //隐私
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            PrivacySetTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PrivacySetTableViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 3){
            //黑名单
            
        }else if (indexPath.row == 4){
            //主题设置
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            themeSetViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"themeSetViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
            
        }
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            //意见反馈
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
            OpinionRequestViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"OpinionRequestViewController"];
            
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 1){
            //恢复历史记录
            [SVProgressHUD showWithStatus:@"正在检查网络及本地环境"];
            [socketRequest requestAllGroupArr];
            
        }else if (indexPath.row == 2){
            //清除缓存
            [self clearCache];
        }
    }else if (indexPath.section == 3){
        
        if(indexPath.row == 0){
            //
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            HelpTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"HelpTableViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
            
        }else if(indexPath.row == 1){
            //检查版本更新
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
            NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
            CCAppVersionModel *versionModel =[CCAppManager sharedInstance].versionInfo;
            if (versionModel.version && [versionModel.version floatValue] > 1) {
                if ([currentVersion floatValue] < [versionModel.version floatValue])
                {
                    NSString *cancelString = @"取消";
                    if (IsForceUpdate) {
                        cancelString = nil;
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",versionModel.version] delegate:self cancelButtonTitle:cancelString otherButtonTitles:@"更新",nil];
                    [alert show];
                }else{
                    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"当前已经是最新版本！" sureBtn:@"确认" cancleBtn:nil];
                    alertView.resultIndex = ^(NSInteger index)
                    {
                    };
                    [alertView showMKPAlertView];
                }
            }else{
                //先取三方库的检查更新 取不到走自己的
                [self checkAppUpdate];
            }
        }else if(indexPath.row == 2){
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            //注销账号
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"该操作不可逆，请谨慎操作!" sureBtn:@"确认" cancleBtn:@"取消"];
            alertView.resultIndex = ^(NSInteger index)
            {
                if (index == 1) {
                    
                }else if (index == 2){
                    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"执行后，您的账号将从多信系统完全删除，您确认执行么?" sureBtn:@"确认" cancleBtn:@"取消"];
                    alertView.resultIndex = ^(NSInteger index)
                    {
                        if (index == 1) {
                            //取消
                        }else if (index == 2){
                            //确定，请求注销请求
                            [socketRequest logoffDuoxinRequest];
                        }
                    };
                    [alertView showMKPAlertView];
                }
            };
            [alertView showMKPAlertView];
            
            
        }
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (@available(iOS 13.0, *)) {
        if ( indexPath.section != 4) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
        }
    }   
    return cell;
    
}

#pragma mark - 检查版本更新
-(void)checkAppUpdate{
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    //3从网络获取appStore版本号
    NSError *error;
    //https://itunes.apple.com/cn/app/多信-聊天/id1286622976?mt=8
    NSString *appStoreString = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",STOREAPPID];
    NSData *response = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",STOREAPPID]]] returningResponse:nil error:nil];
    if (response == nil) {
        NSLog(@"你没有连接网络哦");
        return;
    }
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"hsUpdateAppError:%@",error);
        return;
    }
    NSArray *array = appInfoDic[@"results"];
    NSDictionary *dic = array[0];
    NSString *appStoreVersion = dic[@"version"];
    //打印版本号
    NSLog(@"\n当前版本号:%@\n商店版本号:%@",currentVersion,appStoreVersion);
    NSString *cancelString = @"取消";
    if (IsForceUpdate) {
        cancelString = nil;
    }
    if ([currentVersion floatValue] < [appStoreVersion floatValue])
//    if (![currentVersion isEqualToString:appStoreVersion])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",appStoreVersion] delegate:self cancelButtonTitle:cancelString otherButtonTitles:@"更新",nil];
        [alert show];
    }else{
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"当前已经是最新版本！" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
        };
        [alertView showMKPAlertView];
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //5实现跳转到应用商店进行更新
    if(buttonIndex==1 || IsForceUpdate)
    {
        NSString *strB = [@"多信" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //默认的下载地址
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/%@/id%@?mt=8",strB,STOREAPPID]];
        //https://itunes.apple.com/cn/app/%E5%93%88%E5%90%BC/id1286622976?mt=8
        [[UIApplication sharedApplication] openURL:url];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
        else
        {
            NSLog(@"升级失败－－－－－");
        }
    }
}

#pragma mark - 退出
- (IBAction)quitBtnClick:(UIButton *)sender {
    if ([NFUserEntity shareInstance].IsRecovering) {//正在恢复聊天数据 限制操作
        return;
    }
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"退出登录不会删除任何历史记录 , 下次登录仍可以使用本账号。" otherButtonTitles:[NSArray arrayWithObjects:@"确认退出", nil] btnClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            //退出登录请求 不需要收到退出消息
            
            [socketRequest clearJPUSHServiceId];//关闭推送 设置推送id为nil
            
            [socketRequest quitSocketRequest];
//            [NFUserEntity shareInstance].appStatus = NO;//这里设置为后台 为的是在登录界面不接受消息 【退出登录 等于就是到后台】
            [NFUserEntity shareInstance].userId = @"";
            [KeepAppBox keepVale:@"" forKey:kLoginPassWord];
            [KeepAppBox keepVale:@"" forKey:kLoginWeixinUserName];
            [NFUserEntity shareInstance].userName = @"";
            [NFUserEntity shareInstance].JPushId = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_LgoinHome];
            //退出登录 销毁定时请求
            [[GCDTimerManager sharedInstance] cancelTimerWithName:@"checkHeartTuikuan"];
            [NFUserEntity shareInstance].isTiXianPassWord = NO;
            [NFUserEntity shareInstance].isTiXianPassWord = NO;
            [NFUserEntity shareInstance].isShouquanCancelPwd = NO;
            
        }
    }];
    [sheet show];
}



#pragma mark - 退出登录 不需要收到退出消息

#pragma mark - 收到服务器消息


- (void)clearCache
{
//    self.tableView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf=self;
//    PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:@"清除缓存" message:@"确认清除？" isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
//        //设置可点
//        if (sureBlock) {
//            [weakSelf performSelector:@selector(NFDatabaseQueueClearCache) withObject:nil afterDelay:0.3];
//        }else{
//            //            self.tableView.userInteractionEnabled = YES;
//            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
//        }
//    }];
//    [popV setSecTitleBackColor:[UIColor colorThemeColor]];
//    [popV setSecSureColor:[UIColor colorThemeColor]];
//    [popV setSecMessageColor:UIColorFromRGB(0x666666)];
//    [popV setSecMessageLabelTextAlignment:@"0"];
//    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
//    [win addSubview:popV];
    
    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"确认清除？" sureBtn:@"确认" cancleBtn:@"取消"];
    alertView.resultIndex = ^(NSInteger index)
    {
        if (index == 2) {
            [weakSelf performSelector:@selector(NFDatabaseQueueClearCache) withObject:nil afterDelay:0.3];
        }else{
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
    };
    [alertView showMKPAlertView];
}

#pragma mark - //弹出框提示清除成功
-(void)NFDatabaseQueueClearCache{
    self.jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    BOOL ret = [jqFmdb jq_deleteAllDataBase:@"tongxun.sqlite"];
    [self clearAllData];
    [self createDispatchWithDelay:0.5 block:^{
        //清除完 设置角标为0
        [NFUserEntity shareInstance].badgeCount = 0;
        [[NFbaseViewController new] setBadgeCountWithCount:0 AndIsAdd:YES];
//        PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:@"清除缓存" message:@"清除缓存成功" isNeedCancel:NO isSureBlock:^(BOOL sureBlock) {
//            [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
//            //        self.tableView.userInteractionEnabled = YES;
//        }];
//        [popV setBackValpha:0.5];
//        [popV setSecTitleBackColor:[UIColor colorThemeColor]];
//        [popV setSecSureColor:[UIColor colorThemeColor]];
//        [popV setSecMessageColor:UIColorFromRGB(0x666666)];
//        [popV setSecMessageLabelTextAlignment:@"0"];
//        UIWindow *win = [[[UIApplication sharedAppliJcation] windows] firstObject];
//        [win addSubview:popV];
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"清除缓存成功" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        };
        [alertView showMKPAlertView];
    }];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - 延迟n秒调用主线程
-(void)createDispatchWithDelay:(CGFloat)time block:(void(^)(void))block{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        sleep(time);
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
}

//清除缓存 即单聊群聊聊天记录
-(void)clearAllData{
//    NSError *error;
//    [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //NSCachesDirectory  NSDocumentDirectory
    NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
//    NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachPath error:NULL];
//    for (NSString *path in contents) {
//        NSString *tongxunhuihua = [NSString stringWithFormat:@"%@tongxun.sqlite",[NFUserEntity shareInstance].userName];
//        NSString *tongxun = [NSString stringWithFormat:@"%@tongxun.sqlite",[NFUserEntity shareInstance].userName];
//        NSString *qunliaotongxun = [NSString stringWithFormat:@"%@qunzutongxun.sqlite",[NFUserEntity shareInstance].userName];
//        if ([path isEqualToString:tongxunhuihua] || [path isEqualToString:tongxun]  || [path isEqualToString:qunliaotongxun]) {
//            NSString *reallyPath = [NSString stringWithFormat:@"%@/%@",cachPath,path];
//            if([fileManager fileExistsAtPath:reallyPath]){
//                [jqFmdb close];
//                long long size=[fileManager attributesOfItemAtPath:reallyPath error:nil].fileSize;
//                BOOL success = [fileManager removeItemAtPath:reallyPath error:&error];
////                BOOL create = [fileManager createDirectoryAtPath:reallyPath withIntermediateDirectories:NO attributes:nil error:&error];
//                long long sizee=[fileManager attributesOfItemAtPath:reallyPath error:nil].fileSize;
//                [jqFmdb open];
//                NSLog(@"");
//            }
//        }
//    }
//    NSArray *contentss = [fileManager contentsOfDirectoryAtPath:cachPath error:NULL];
//    NSLog(@"clear");
    
    self.jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    NSArray *contentsss = [ self.jqFmdb jq_selectedAllTableName];
    for (NSString *qunzuChatTable in contentsss) {
        if (![qunzuChatTable containsString:@"keepBoxEntity"]&&![qunzuChatTable containsString:@"xinxiaoxiTongzhi"]&&![qunzuChatTable containsString:@"yinsiSet"]&&![qunzuChatTable containsString:@"groupDetailliebiao"]&&![qunzuChatTable containsString:@"groupMenberliebiao"]&&![qunzuChatTable containsString:@"lianxirenliebiao"]&&![qunzuChatTable containsString:@"qunzuliebiao"]){
            __block NSArray *keyArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [self.jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                keyArr = [ weakSelf.jqFmdb jq_columnNameArray:qunzuChatTable];
            }];
//            NSLog(@"%d",keyArr.count);
//            if (keyArr.count >= 26 ){
                [ self.jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL ret = [ weakSelf.jqFmdb jq_deleteAllDataFromTable:qunzuChatTable];
                    if (ret) {
                    }
                }];
//            }
        }
    }
    //删除图片缓存
    //NSInteger b = [[SDImageCache sharedImageCache] getSize];
    //NSInteger c = [[SDImageCache sharedImageCache] getDiskCount];
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    //NSInteger a = [[SDImageCache sharedImageCache] getSize];
    //删除完立马创建空的
    [self setChatListAbout];
    
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    //删除会话数据库数据
//    BOOL huihualiebiao = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:@"huihualiebiao" IsDelete:NO];
////    BOOL shenqingtongzhi = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:@"shenqingtongzhi" IsDelete:NO];
////    BOOL lianxirenliebiao = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:@"lianxirenliebiao" IsDelete:NO];
//    //删除f各联系人的缓存聊天
//    NSArray *arrs = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[FriendListEntity class] whereFormat:@""];
//    
//    for (FriendListEntity *entity in arrs) {
//        int a = [[NFMyManage new] checkIsHaveNumAndLetter:entity.friend_username];
//        if (a ==1 || a == 3) {
//            entity.friend_username = [[NFMyManage new] NumToString:entity.friend_username];
//        }
//        BOOL rett = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:entity.friend_username IsDelete:YES];
//        if (rett) {
//            NSLog(@"");
//        }
//    }
    
}


#pragma mark - 懒加载建立会话列表数据库
-(void)setChatListAbout{
    //检查表存在
    [self.fmdbServicee IsExistHuihualiebiao];
    [self.fmdbServicee IsExistGroupDetailTable];
    [self.fmdbServicee IsExistGroupMemberTable];
    
    [self setMineSetAbout];
    
    
}

#pragma mark - 我的设置建立数据库 有则忽略
-(void)setMineSetAbout{
    //缓存设置属性字段相关
     self.jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [ self.jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [ strongSelf.jqFmdb jq_isExistTable:@"keepBoxEntity"];
    }];
    if (!ret) {
        __block BOOL keepBoxEntityRet = NO;
        [ self.jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            keepBoxEntityRet = [ strongSelf.jqFmdb jq_createTable:@"keepBoxEntity" dicOrModel:[CacheKeepBoxEntity class]];
        }];
        if (keepBoxEntityRet) {
            CacheKeepBoxEntity *entity = [CacheKeepBoxEntity new];
            entity.keepBoxId = @"keepBoxId";
            entity.themeSelectedIndex = 1;
            entity.themeSelectedImageName = @"";
            __weak typeof(self)weakSelf=self;
            [ self.jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [ strongSelf.jqFmdb jq_insertTable:@"keepBoxEntity" dicOrModel:entity];
                if (rett) {
                }
            }];
            
        }
    }
    
    __block BOOL rettt = NO;
    [ self.jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rettt = [ strongSelf.jqFmdb jq_createTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class]];
        
    }];
    __block NSArray *arrs = [NSArray new];
    [ self.jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [ strongSelf.jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@""];
    }];
    if (ret) {
        __weak typeof(self)weakSelf=self;
        //如果没有缓存 新建三个数据
        for (int i = 0; i < 4; i++) {
            if (i == 0) {
                NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                entity.setId = @"jieshouxiaoxiTongzhi";
                entity.receiveNewMessageNotify = YES;
                [ self.jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL ret = [ strongSelf.jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                    if (ret) {
                        NSLog(@"newjieshouxiaoxiTongzhi");
                    }
                }];
                
            }else if (i == 1){
                NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                entity.setId = @"sound";
                entity.soundNotify = YES;
                [ self.jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL ret = [ strongSelf.jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                    if (ret) {
                        NSLog(@"newsound");
                    }
                }];
                
            }else if (i == 2){
                NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                entity.setId = @"shake";
                entity.ShakeNotify = YES;
                [ self.jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL ret = [ strongSelf.jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                    if (ret) {
                        NSLog(@"newshake");
                    }
                }];
                
            }else if (i == 3){
                NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                entity.setId = @"lingshengshezhi";
//                entity.voiceName = @"katalk2";
                entity.voiceName = @"katalk";
                [ self.jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL ret = [ strongSelf.jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                    if (ret) {
                        NSLog(@"lingshengshezhi");
                    }
                }];
            }
        }
    }
    
    //    }];
    
    //    [jqFmdb jq_inDatabase:^{
    //是否能建表
    __block BOOL rett;
    [ self.jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rett = [ strongSelf.jqFmdb jq_createTable:@"yinsiSet" dicOrModel:[PrivacySetEntity class]];
    }];
    
    if (rett) {
        for (int i = 0; i < 2; i++) {
            if (i == 0) {
                //
                PrivacySetEntity *entity = [PrivacySetEntity new];
                entity.setId = @"xuyaoYanzheng";
                entity.needVerificate = YES;
                __block BOOL ret = NO;
                __weak typeof(self)weakSelf=self;
                [ self.jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    ret = [ strongSelf.jqFmdb jq_insertTable:@"yinsiSet" dicOrModel:entity];
                }];
                if (ret) {
                    NSLog(@"newyinsiSet");
                }
            }else if (i == 1){
                PrivacySetEntity *entity = [PrivacySetEntity new];
                entity.setId = @"tuijiantongxunluHaoyou";
                entity.recommendMailList = YES;
                __block BOOL ret = NO;
                __weak typeof(self)weakSelf=self;
                [ self.jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    ret = [ strongSelf.jqFmdb jq_insertTable:@"yinsiSet" dicOrModel:entity];
                }];
                if (ret) {
                    NSLog(@"newyinsiSet");
                }
            }
        }
    }else{
//        NSArray *arr = [jqFmdb jq_lookupTable:@"yinsiSet" dicOrModel:[PrivacySetEntity class] whereFormat:@""];
        NSLog(@"");
    }
    //    }];
}


//- (void)cleanCache
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
//        NSArray *files = [[ NSFileManager defaultManager ]  subpathsAtPath:cachPath];
//        
//        NSLog ( @"files :%ld" ,[files  count ]);
//        
//        for ( NSString *p  in files) {
//            
//            NSError *error;
//            
//            NSString *path = [cachPath  stringByAppendingPathComponent :p];
//            //            NSLog(@"%@",path);
//            if ([[ NSFileManager defaultManager ]  fileExistsAtPath :path]) {
//                
//                [[ NSFileManager defaultManager ]  removeItemAtPath :path  error :&error];
//            }
//        }
//        //        [ self performSelectorOnMainThread : @selector (clearCacheSuccess)  withObject : nil waitUntilDone : YES ];
//    });
//    
//}
//
//-(float)fileSizeAtPath{
//    
//    NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
//    
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    if([fileManager fileExistsAtPath:cachPath]){
//        long long size=[fileManager attributesOfItemAtPath:cachPath error:nil].fileSize;
//        return size/1024.0/1024.0;
//    }
//    return 0;
//}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
