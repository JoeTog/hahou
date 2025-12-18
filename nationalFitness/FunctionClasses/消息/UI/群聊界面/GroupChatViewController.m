//
//  GroupChatViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/8/29.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "ChosePhoto.h"

#define kLines 20

#define rootDictionary @"result"
#define refreshCount 15
#define showTimeInterval 3*60 //目前是一分钟变化显示【当本条消息左下角时间与上一条时间不一样 就显示】message中strTime UUmessage中showTime

//群组了聊天纪录 tablename
#define groupMacroName [NSString stringWithFormat:@"qunzu%@",self.groupCreateSEntity.groupId]
//群组会话列表
//#define groupChatListName [NSString stringWithFormat:@"qunzu%@",self.groupCreateSEntity.groupId]
#define groupChatListName [NSString stringWithFormat:@"%@",self.groupCreateSEntity.groupId]



@interface GroupChatViewController ()<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,UUInputFunctionViewDelegate,ChatHandlerDelegate,UIGestureRecognizerDelegate>

//tableview
@property (weak, nonatomic) IBOutlet UITableView *GroupChatTableView;

//距离下面约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstaint;

//个人信息详情 【点击头像后的界面】
@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;

@property(nonatomic,strong)NSMutableArray *rootDataArr;
//改成cooy 会crash，copy后变成不可变数组 addobject会崩溃
@property(nonatomic,strong)NSMutableArray *dataArr;
//@property (nonatomic,assign)AppDelegate *appdelegate;
//
@property (nonatomic,strong)MessageChatEntity *chatEntity;

@end

@implementation GroupChatViewController{
    
    BOOL reloading_;
    BOOL needReloading_;
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    EGORefreshTableHeaderView * refreshHeaderView_;
    
    BOOL needCache;
    BOOL needGetCache;
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    int refreshVCountBegin;
    int refreshVCountEnd;
    //是否能够加载记录
    BOOL canRefresh;
    //逻辑记录 显示的row 开始是0 刷新后变为 refreshCount
    NSInteger showRow;
    JQFMDB *jqFmdb;
    // 取数据相关 这里是记录剩余数据的个数【比如刚进来展示了15条，缓存还有23条，那么这里就是23】
    int dataCount;
    //这里记录当剩余缓存不足15条时候 到底剩余多少条
    int leastCount;
    //记录上一个实体 用于是否显示时间逻辑判断
    MessageChatEntity *lastEntity;
    //选择照片
    ChosePhoto *AA_;
    //为了计算什么时候到达maxcount 而存在
    NSMutableArray *ExistImageArr_;
    //键盘高度
    CGFloat keyboardHeight;
    //记录是否刚刚发了消息
    BOOL sendMessageJustnow;
    //点击更多后 底部显示的菜单栏【目前只有删除】
    bottomEditMenuView *bottomEditView;
    NSMutableArray *needDeleteEntityArr;
    NSMutableArray *needDeleteIndexPathArr;
    //当长按后选中更多后 这里记录为YES，逻辑处理让其默认选中该cell 点击更多后设置为no，当取消默认选中的后设置为no，再次选中则走正常代理
    BOOL firstSelectDelete;
    //记录点击更多后选中的indexpath 用于在点击更多后 滑出界面回来cell需要为选中状态
    NSIndexPath *clickMoreIndexPath;
    //记录要撤回的消息id
    NSString *drowMessageId;
    //记录撤回的indexpath
    NSIndexPath *drowMessageIndexPath;
    //是否为原图
    BOOL isOriginalImage;
    //当长时间后断线 重连发送保存的字典
    NSDictionary *messageWaitSendDict;
    //右上角点击详情
    UIButton *lookDetailBtn;
    //编辑名字后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    //记录选中的indexpath 【点击头像后 需要取zjcontact】
    NSIndexPath *selectedIndexPath;
    //是否走了didload方法【push过来的会走 pop回来的不会走】
    BOOL IsPush;
    //标题label
    UILabel * titleViewLabel;
    //成员数字符串
    NSString *memberArrContString;
    //点击某群成员 记录该员消息实体
    UUMessageFrame *selectedUUMessage;
    //是否正在请求 消息历史
    BOOL requestingHistoryData;
    NSString *yuehouString;//阅后隐藏字符串 为某个时间、空、空字符串等
//    BOOL IsInEditing;//是否在编辑状态
    // 有新消息 下面按钮
    UIButton *newMessageBottomButton;
    //新消息 上面按钮
    UIButton *newMessageTopButton;
    //新消息总条数 读完就减去 刚走完5012是 self.dataArr - 15
    NSInteger totalNewMessageCount;
    //是否为不在群聊
    BOOL IsInGroup;
    
    BOOL IsNotNeedCash;//在pop 回去的时候 是否需要 核实 会话列表 【当被提出群后 发消息 显示被提了 不用缓存会话列表】
    
    BOOL IsNeedRefreshGroupDetail;//是否需要刷新群详情
    
    BOOL IsClickback;
    
    //左侧按钮
    UIButton *leftBackBtn;
    UIButton *leftCountBtn;
    UIBarButtonItem *leftBackBtnItem;
    UIBarButtonItem *leftCountBtnItem;
    
}

//当ret为YES【当为断线后重连成功】 直接请求消息历史，为no【当从详情等页面过来时】
-(void)requestChatHistory:(BOOL)ret{
    if ((socketModel && !IsPush && socketModel.isConnected) || ret) {
        //
        //如果这个界面没有释放 到这个界面的
        if (lastEntity) {
            //如果有数据库最后一条消息 则取最后一条消息的messageId进行请求消息历史
            self.chatEntity = lastEntity;
            [self getGroupChatData];
        }else{
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *cacheArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                int dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
                cacheArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,10]];
            }];
            //    NSArray *cacheArrr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
            if (cacheArr.count > 0) {
                self.chatEntity = [cacheArr lastObject];
                lastEntity = [cacheArr lastObject];
                if (!self.chatEntity.chatId) {
                    self.chatEntity.chatId = @"0";
                    self.chatEntity.localReceiveTimeString = @"0";
                }
            }else{
                self.chatEntity.localReceiveTimeString = @"0";
                self.chatEntity.chatId = @"0";
                lastEntity.localReceiveTimeString = @"0";
                lastEntity.chatId = @"0";
            }
            [self getGroupChatData];
        }
    }else if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]){
        //如果为点击了群聊推送进来 但是未连接 那么让它转 直到连接成功 或提示开小差
//        [SVProgressHUD show];
        NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
        if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
            titleViewLabel.text = [NSString stringWithFormat:@"%@(连接中)",title];
            dispatch_main_async_safe(^{
                self.navigationItem.titleView = titleViewLabel;
            })
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    IsPush = NO;//界面消息可能是push、pop【push后回来需要再willappear中请求消息历史的 pop了再回来会走didload】
    
    if(IsClickback){
        refreshHeaderView_ = nil;
        socketModel = nil;
        socketRequest= nil;
        
        jqFmdb= nil;
        lastEntity= nil;
        socketRequest= nil;
        bottomEditView= nil;
        needDeleteEntityArr= nil;
        needDeleteIndexPathArr= nil;
        lookDetailBtn= nil;
        
        titleViewLabel= nil;
        newMessageTopButton= nil;
        self.cacheDataRowSendStatusDict= nil;
        titleViewLabel= nil;
        self.conversationId= nil;
        
        self.groupCreateSEntity= nil;
        [self.IFView_ removeEmotionKeyboardOberser];
        self.IFView_.delegate= nil;
        self.IFView_= nil;
        self.GroupChatTableView= nil;
        self.bottomConstaint= nil;
        self.dataArr= nil;
        self.chatEntity= nil;
        self.ZJContactDetailController= nil;
        
        newMessageBottomButton = nil;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    //界面刚显示0.6秒内不给跳转
    lookDetailBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        lookDetailBtn.userInteractionEnabled = YES;
    });
    self.isCanSendMessage = NO;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.isCanSendMessage = YES;
//    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    //增加通知观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectBreak:) name:@"connectBreak" object:nil];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    [self.IFView_ AddNotification];
    //是否需要缓存
    needCache = YES;
    needGetCache = YES;
    
    //界面将要从详情等界面pop回来 进行核查本地fmdb数据是否和界面相对应
    if (!IsPush) {//如果不是push过来的 则需要检查
        [self checkUIDataIsCorrectWithFMDB];
    }
    
    
    //请求消息历史 【当刚走了didload 这里面会过滤，didload中有请求消息历史】
    [self requestChatHistory:NO];
    IsPush = NO;//走过一次didload IsPush主要为乐上面方法的执行与否 上面方法执行完了 便赋值为NO
    [self getCacheGroupDetailSetTitle];//去本地缓存设置title
    
    //进入聊天界面则设置当前聊天id
    [NFUserEntity shareInstance].currentChatId = self.groupCreateSEntity.groupId;
    [NFUserEntity shareInstance].isSingleChat = @"2";
    
    //self.GroupChatTableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    
    //    [self.chatTableView reloadData];
    //是否需要显示导航栏 【当从查看某成员头像后 到这里还是显示成员详情界面 不需要导航栏】
    if (isFromEditName) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent{
    if(parent == nil){
        IsClickback = YES;
    }
    //NSLog(@"");
}


#pragma mark - 当pop或者从相册回来时 看看界面显示与缓存是否一致
-(void)checkUIDataIsCorrectWithFMDB{
    //取界面最后一条数据
    UUMessageFrame *lastEntity = self.dataArr.count > 0 ?[self.dataArr lastObject]:nil;
    __weak typeof(self)weakSelf=self;
    __block NSArray *cacheArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
        cacheArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,10]];
    }];
    if (cacheArr.count > 0){
        MessageChatEntity *localFMDBLastEntity = [cacheArr lastObject];
        //如果z最后一条消息和本地缓存的最后一条消息不同的话 就设置已读
        if (!lastEntity || ![lastEntity.message.chatId isEqualToString:localFMDBLastEntity.chatId]) {
            //设置最后一条设置已读
            if(!lastEntity.message.chatId ){
                
            }
            [socketRequest readedRequest:localFMDBLastEntity.chatId GroupId:self.groupCreateSEntity.groupId];
            if (dataaCount <= 15) {
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    cacheArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
                }];
                [self.dataArr removeAllObjects];
                [self DealDataToLocalController:cacheArr];
                [self.GroupChatTableView reloadData];
            }else{
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    cacheArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 15,15]];
                }];
                [self.dataArr removeAllObjects];
                [self DealDataToLocalController:cacheArr];
                [self.GroupChatTableView reloadData];
                
            }
        }
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{ //
    //退出则将当前聊天id置空
    [NFUserEntity shareInstance].currentChatId = @"";
    [NFUserEntity shareInstance].isSingleChat = @"0";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectBreak" object:nil];
    
    [self.IFView_ deallocMySelf];
    
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *arsrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    
    if (IsNotNeedCash) {
        return;
    }
    //会话界面进行核实
    [self cacheConversationList];
    
    //进入  群聊聊天 将@ 艾特标记移除
    BOOL isFirst = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"qunzuAiteBool%@",self.conversationId]];
    if(isFirst){
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"qunzuAiteBool%@",self.conversationId]];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    if (![ClearManager getNetStatus]) {
        self.isCanSendMessage = YES;//当为断网 则可以发送消息 【但是肯定显示感叹号】
    }
    
    if(IsNeedRefreshGroupDetail){
        //请求群组详情
        [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
        IsNeedRefreshGroupDetail = NO;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    IsNeedRefreshGroupDetail = YES;//刷新群详情
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *arsrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
//    NSLog(@"");
    // Do any additional setup after loading the view.
    //如果存在
    if (self.groupCreateSEntity.groupName.length > 0) {
        self.navigationItem.title = self.groupCreateSEntity.groupName;
    }else{
        
    }
    [titleViewLabel removeFromSuperview];
    titleViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 100, 20)] ;
    titleViewLabel.text = @"";
    titleViewLabel.textAlignment = NSTextAlignmentCenter;
    titleViewLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleViewLabel.textColor = [UIColor whiteColor];
    titleViewLabel.font=[UIFont boldSystemFontOfSize:fontSize];
    //请求群组详情 进来就请求详情 当返回后和本地比对 变化了就更新
    
    //是否需要缓存
    needCache = YES;
    needGetCache = YES;
    needDeleteEntityArr = [[NSMutableArray alloc] initWithCapacity:5];
    needDeleteIndexPathArr = [[NSMutableArray alloc] initWithCapacity:5];
//    self.GroupChatTableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    [self initUI];
    self.GroupChatTableView.allowsSelection = YES;//允许多选
    self.GroupChatTableView.allowsMultipleSelectionDuringEditing = YES;
    self.dataArr = [NSMutableArray new];
    memberArrContString = [NSString new];
    IsNotNeedCash = NO;
    
    [self initScoket];
    
    IsPush = YES;//在didload中设置为YES 只有push过来才会走didload
    
    //当聊天请求了缓存后 记录列表需要刷新
//    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    
    // 更改会话列表缓存 去除角标 【有未读才设置未读为0】
    if (self.unreadCount > 0) {
        [self changeChatListRemoveUnReadCount];
    }
    
    if (self.memberArr.count == 0) {
        [self getCacheGroupDetailSetTitle];//去本地缓存设置title
    }else{
//        NSLog(@"%d",self.memberArr.count);
        NSString *title = self.navigationItem.title?self.navigationItem.title:self.groupCreateSEntity.groupName;
//        memberArrContString = [NSString stringWithFormat:@"%d",self.memberArr.count];
//        NSString *lastTitle = [NSString stringWithFormat:@"%@(%d)",title,self.memberArr.count];
        memberArrContString = [NSString stringWithFormat:@"%@",self.groupTotalNum];
        NSString *lastTitle = [NSString stringWithFormat:@"%@(%@)",title,self.groupTotalNum];
        if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
            titleViewLabel.text = lastTitle;
            self.navigationItem.titleView = titleViewLabel;
        }
    }
    
    self.GroupChatTableView.userInteractionEnabled = YES;
    
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    for (int i = 0; i<9999; i++) {
//        MessageChatEntity *entity = [MessageChatEntity new];
//        entity.message_content = [NSString stringWithFormat:@"这是第%d挑消息",i];
//        entity.chatId = [NSString stringWithFormat:@"%d",i];
//        entity.appMsgId = [NSString stringWithFormat:@"%d",i];
//        entity.user_name = [NFUserEntity shareInstance].userName;
//        entity.user_id = [NFUserEntity shareInstance].userId;
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            BOOL ret = [jqFmdb jq_insertTable:groupMacroName dicOrModel:entity];
//            if (ret) {
//            }
//        });
//    }
//    __block NSArray *existArr = [NSArray new];
//    [jqFmdb jq_inDatabase:^{
//        existArr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
//        NSLog(@"%d",existArr.count);
//    }];
    
    
    
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 200, 95, 50)];
    uploadButton.backgroundColor = [UIColor redColor];
    [uploadButton setTitle:@"测试" forState:UIControlStateNormal];
    [uploadButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    uploadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    uploadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [uploadButton addTarget:self action:@selector(testClickhhk) forControlEvents:UIControlEventTouchUpInside];
    //    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    //[self.view addSubview:uploadButton];
    
    
    //进入  群聊聊天 将@ 艾特标记移除
    BOOL isFirst = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"qunzuAiteBool%@",self.conversationId]];
    if(isFirst){
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"qunzuAiteBool%@",self.conversationId]];
    }
    

        leftBackBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
        [leftBackBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
        [leftBackBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
        //[leftBackBtn setTitle:[NSString stringWithFormat:@"%ld",self.unreadAllCount] forState:(UIControlStateNormal)];
        leftBackBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBackBtn];
    
        leftCountBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    leftCountBtn.width = -5;
        //[leftCountBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
        [leftCountBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
        ViewRadius(leftCountBtn, 15);
        leftCountBtn.backgroundColor = UIColorFromRGB(0xd4d4d4);
        [leftCountBtn setTitle:[NSString stringWithFormat:@"%ld",self.unreadAllCount] forState:(UIControlStateNormal)];
        if(self.unreadAllCount > 99){
            [leftCountBtn setTitle:@"99" forState:(UIControlStateNormal)];
        }
        [leftCountBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        leftCountBtnItem = [[UIBarButtonItem alloc] initWithCustomView:leftCountBtn];
    
        if (self.unreadAllCount == 0) {
            self.navigationItem.leftBarButtonItems = @[leftBackBtnItem];
        }else{
            self.navigationItem.leftBarButtonItems = @[leftBackBtnItem,leftCountBtnItem];
        }
    
    
    
}

-(void)testClickhhk{
    
//    ZJContact *contact = [self.groupCreateSEntity.groupAllUser lastObject];
//    [socketRequest rechargeWithGroupId:self.groupCreateSEntity.groupId rechargeUserId:[NFUserEntity shareInstance].userId amount:@"1000"];

    [[GCDTimerManager sharedInstance] cancelTimerWithName:@"testMessage"];
    __block NSInteger counttt = 0;
    __weak typeof(self)weakSelf=self;
    [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"testMessage"
                                                        timeInterval:3.0
                                                               queue:nil
                                                             repeats:YES
                                                        actionOption:AbandonPreviousAction
                                                              action:^{
                                                                  __strong typeof(weakSelf)strongSelf=weakSelf;
        counttt ++;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [strongSelf tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];//刚进来 强制滑到底部 这里不需要-64-50
        });
        
                                                                NSDictionary *dic = @{@"strContent": [NSString stringWithFormat:@"测试消息%ld",counttt], @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": [ClearManager getAPPMsgId]};
                                                                [strongSelf dealTheFunctionData:dic];
                                                                  
                                                              }];
    
    
    
    
}

#pragma mark - 刷新函数
-(void)refresh{
    NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
    if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
        if ([title containsString:@"("] && [title containsString:@")"]) {
            NSArray *array = [title componentsSeparatedByString:@"("];
            title = array[0];
        }
        titleViewLabel.text = [NSString stringWithFormat:@"%@(连接中)",title];
        self.navigationItem.titleView = titleViewLabel;
        //设置某些按钮不可点
        lookDetailBtn.userInteractionEnabled = NO;
        self.backBtn.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            lookDetailBtn.userInteractionEnabled = YES;//到时间详情按钮可点
            self.backBtn.userInteractionEnabled = YES;//到时间返回按钮可点
        });
    }
    requestingHistoryData = NO;//当走这里 设置正在请求为NO 可能上一次请求登录失败了
    [self getGroupChatData];
    //needDeleteEntityArr needDeleteIndexPathArr
    [needDeleteEntityArr removeAllObjects];
    [needDeleteIndexPathArr removeAllObjects];
}

#pragma mark - 取本地缓存设置名称人数
-(void)getCacheGroupDetailSetTitle{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    [jqFmdb jq_inDatabase:^{
    __block NSArray *memberArrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        memberArrs = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    
    if ([memberArrContString isEqualToString:[NSString stringWithFormat:@"%@",[self.groupTotalNum integerValue]>0?self.groupTotalNum:self.groupCreateSEntity.groupTotalNum]]) {
        //如果本地成员数和显示成员数一样 则return
        return ;
    }
    self.memberArr = memberArrs;
//    NSLog(@"%d",memberArrs.count);
    NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
    
    if (memberArrs.count != 0) {
//        NSString *lastTitle = [NSString stringWithFormat:@"%@(%d)",title,memberArrs.count];
//        memberArrContString = [NSString stringWithFormat:@"%d",memberArrs.count];
        NSString *lastTitle = [NSString stringWithFormat:@"%@(%@)",title,[self.groupTotalNum integerValue]>0?self.groupTotalNum:self.groupCreateSEntity.groupTotalNum];
        memberArrContString = [NSString stringWithFormat:@"%@",self.groupTotalNum?self.groupTotalNum:self.groupCreateSEntity.groupTotalNum];
        if (![titleViewLabel.text containsString:@"收取中"] || ![titleViewLabel.text containsString:@"接收中"]) {
            titleViewLabel.text = lastTitle;
            self.navigationItem.titleView = titleViewLabel;
        }
    }else{
        [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
    }
    //KAInuo123
//    }];
}

#pragma mark - 让tableview 动起来
- (void)loadData {
    
    NSLog(@"");
//    _cellNum = 15;
//    [self.tableView reloadData];
    [self.GroupChatTableView reloadData];
//    XSTableViewAnimationTypeMove = 0, //从左往右滑动
//    XSTableViewAnimationTypeMoveSpring = 0,
//    XSTableViewAnimationTypeAlpha,
//    XSTableViewAnimationTypeFall, //从上往下刷新
//    XSTableViewAnimationTypeShake, //从上往下刷新
//    XSTableViewAnimationTypeOverTurn,//交叉滑动
//    XSTableViewAnimationTypeToTop,//翻滚刷新
//    XSTableViewAnimationTypeSpringList, //从下往上
//    XSTableViewAnimationTypeShrinkToTop,//从上往下 跳动
//    XSTableViewAnimationTypeLayDown,
//    XSTableViewAnimationTypeRote,
//    [TableViewAnimationKit showWithAnimationType:XSTableViewAnimationTypeRote tableView:self.GroupChatTableView];
    
}

#pragma mark - 退出 pop到跟根视图 会话列表界面
-(void)backClicked:(id)sender{
    [SVProgressHUD dismiss];
    IsClickback = YES;
    UIViewController * viewVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - self.navigationController.viewControllers.count];
    [self.navigationController popToViewController:viewVC animated:YES];
    NSLog(@"%lu",self.tabBarController.selectedIndex);
    [self.IFView_ removeEmotionKeyboardOberser];
    
}

#pragma mark - 初始化scoket
-(void)initScoket{
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
    socketModel.delegate = self;
    lastEntity = nil;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *cacheArr = [NSArray new];
    __block int dataaCount = 0;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
        cacheArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,10]];
//        NSArray *arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
        NSLog(@"");
    }];
    
    if (cacheArr.count > 0) {
        self.chatEntity = [cacheArr lastObject];
        if (dataaCount > 15) {
            //如果历史消息大于15条 那么取倒数16条为lastentity 后面与取出的15条的第一条【倒数15条进行对比是否需要显示时间】
            __block NSArray *showheadTimeArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                showheadTimeArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 15 - 1,2]];
            }];
            lastEntity = [showheadTimeArr firstObject];//lastobject就是显示的第一条【15条的index0 下面判断这个index0是否需要显示时间 需要和firstObject进行对比】
        }else{
            lastEntity = nil;//如果表数据小于15条 那么lastentity为nil 这样可以显示的最上面消息有时间
        }
    }else{
        self.chatEntity.localReceiveTimeString = @"0";
        self.chatEntity.chatId = @"0";
        lastEntity.localReceiveTimeString = @"0";
        lastEntity.chatId = @"0";
    }
    //当connect时不一定通的
    if (socketModel.isConnected) {
        [socketModel ping];
    }
    if (socketModel.isConnected && [ClearManager getNetStatus]) {
        //请求历史消息之前 先讲本地缓存取出来
        //计算dataCount 从表某个位置取值
        [self countDataCount];//缓存完消息历史后 重新计算消息条数
        //取展示的缓存 包括数据库整理
        BOOL IsNeedScrollToBottom = YES;
        if (self.historyIndex > 15) {//当为查找历史消息时 不需要滚动到bottom
            IsNeedScrollToBottom = NO;
        }
        NSArray *arr = [self showHistoryData];
        [self DealDataToLocalController:arr];
        [self initLegalData];//隐藏 阅后隐藏及删除
        [self.GroupChatTableView reloadData];//单聊这里不写也没事 下面方法朝阳能到最底部，群聊就不行 必须要reloaddata
        if (self.historyIndex > 0) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.GroupChatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - self.historyIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
            
        }else{
            if (IsNeedScrollToBottom) {
                [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];//刚进来 强制滑到底部 这里不需要-64-50
            }else{
                [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:NO];//刚进来 强制滑到底部【当为搜索过来 】
            }
        }
        //请求群聊历史记录 【rquest在里面 用self调用方法是因为有界面UI的设置 否则直接sockeyRequest】
        [self getGroupChatData];
    }else if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]){
        //如果为点击了群聊推送进来 但是未连接 那么让它转 直到连接成功 或提示开小差
        [self withOutNetShowDataBase];
        [NFUserEntity shareInstance].PushQRCode = @"0";
    }else{
        [self withOutNetShowDataBase];
    }
    [NFUserEntity shareInstance].isNeedRefreshChatData = NO;//设置是否刷新会话列表为NO 【貌似作用不大】
    
}

#pragma mark - 请求群组详情

#pragma mark - 断网展示本地缓存
-(void)withOutNetShowDataBase{
    //计算dataCount 从表某个位置取值
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [self countDataCount];
    //取展示的缓存 包括数据库整理
    __weak typeof(self)weakSelf=self;
    self.dataArr = [NSMutableArray new]; //当显示本地缓存时，清一次【可能在详情中清除了表】
    NSArray *arr = [weakSelf showHistoryData];
    // 将取出的缓存 赋值到界面数组
    [self DealDataToLocalController:arr];
    [self initLegalData];
    //    [socketModel initSocket];
     
//    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.5];
    if (self.dataArr.count > 0) {
        //没有这个 会出现最后一张图片显示一半
        
//        [self.GroupChatTableView reloadData];
//        [self tableViewScrollToBottomOffSet:0 Animation:NO];
//        [self tableViewScrollToBottomOffSet:-64-50 Animation:NO];
        
        [UIView animateWithDuration:0 animations:^{
            
            [self.GroupChatTableView reloadData];
        } completion:^(BOOL finished) {
            //刷新完成
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                //[NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                   // [self tableViewScrollToBottomOffSet:-64-50 Animation:NO];
                });
            });
        }];
        return;
        
        CGFloat showHeight = 0;
        if (![self.IFView_.TextViewInput isFirstResponder]  && self.IFView_.addFaceView.hidden) {
            showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
        }
        CGFloat huanchong = 250;
        if(self.GroupChatTableView.contentSize.height - self.GroupChatTableView.contentOffset.y >= (SCREEN_HEIGHT - kTopHeight - 50 + huanchong)){
            NSLog(@"不滚到最下面");
            newMessageBottomButton.alpha = 1;
            return;
        }else{
            NSLog(@"滚到最下面");
        }
        
        if ([self.IFView_.TextViewInput isFirstResponder]) {
            showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
        }else{
            if(self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden){
                showHeight = SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + kTabBarHeight + kTopHeight);
            }else{
                showHeight = SCREEN_HEIGHT - kTopHeight - kTabBarHeight;
            }
            
        }
        
        
        [UIView animateWithDuration:0 animations:^{
            
            [self.GroupChatTableView reloadData];
        } completion:^(BOOL finished) {
            //刷新完成
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                //[NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (self.GroupChatTableView.contentSize.height > showHeight) {
                        
                        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
                    }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
                        [self tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
                    }//        });
                });
            });
        }];
        
        
        
        
//        [self.GroupChatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        //群聊下面可以没有 【没有的话 滑不到底】
//        NSIndexPath *index_ = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
//        [self.GroupChatTableView scrollToRowAtIndexPath:index_ atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
    }else{
        //清除缓存后 刷新界面
        [self.GroupChatTableView reloadData];
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self tableViewScrollToBottomOffSet:0 Animation:NO];
//    });
    
//    self.GroupChatTableView.contentOffset = CGPointMake(0, self.GroupChatTableView.contentSize.height);
    //下面一样
//    self.GroupChatTableView.contentOffset = CGPointMake(0, 1000);
    
}

-(void)refreshFromFMDB{
    [needDeleteIndexPathArr removeAllObjects];//刷新后 清除选中的indexpath
    totalNewMessageCount -= refreshCount;//每次刷新
    if (totalNewMessageCount > 0) {
        [newMessageTopButton setTitle:[NSString stringWithFormat:@"%d条未读消息",totalNewMessageCount] forState:(UIControlStateNormal)];
        newMessageTopButton.alpha = 1;
    }else{
        newMessageTopButton.alpha = 0;
    }
    
    NSArray *array = [NSArray arrayWithArray:needDeleteIndexPathArr];
    for (NSIndexPath *indexpath in array) {
//        UUMessageFrame *UMessage = self.dataArr.count>indexpath.row?self.dataArr[indexpath.row]:nil;
//        UMessage.message.IsSelected = NO;//设置数据选中状态为NO
//        MessageTableViewCell  * cell = (MessageTableViewCell *)[self.GroupChatTableView cellForRowAtIndexPath:indexpath];
//        [cell setSelected:NO animated:YES];
//        [self tableView:self.GroupChatTableView didDeselectRowAtIndexPath:indexpath];
//        [self tableView:self.GroupChatTableView didSelectRowAtIndexPath:indexpath];
        
//         [self.GroupChatTableView ]
        
        
        
    }
    
    //当下拉刷新时，将记录的实体 置空 因为这个实体不是之前的消息记录的，而是后面10条的第一个记录
    lastEntity = nil;
    //逻辑记录当剩余数据少于10条的具体个数
    leastCount = 0;
    //判断剩余的数据有没有10条
    if (dataCount > refreshCount) {
        dataCount -= refreshCount;
        //设置为可以下拉加载
        canRefresh = YES;
    }else{
        //记录剩余数据
        leastCount = dataCount;
        dataCount = 0;
        canRefresh = NO;
    }
    //还有剩余数据 则正常刷新
    __block NSArray *arr = [NSArray new];
    if (dataCount > 0) {
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,refreshCount]];
        }];
    }else{
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{__weak typeof(self)weakSelf=self;
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //剩余数据不足刷新时 拉出所有剩余数据
            arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,strongSelf ->leastCount]];
        }];
    }
    
    //取15条缓存之前一条
    __weak typeof(self)weakSelf=self;
    if (arr.count >= 2) {
        lastEntity = arr[arr.count - 2];
    }else{
        lastEntity = nil;
    }
    for (int i = arr.count-1; i>= 0 ; i--) {
        MessageChatEntity *entity = arr[i];
        //当第一条数据为隐藏的话 逻辑判定之前的数据都是已经隐藏了的 显示暂无刷新
        if ([entity.yuehouYinCang isEqualToString:@"1"] && ![yuehouString isEqualToString:@"不隐藏"] && yuehouString.length != 0) {
            canRefresh = NO;
        }
        //在和lastEntity比对之前 先取到上一个entity
        if (i>0) {
            lastEntity = arr[i-1];
        }else if (i == 0 && arr.count < 15){
            lastEntity = nil;
        }
        //收到消息
        UUMessageFrame *messageFrame = [self MessageChatEntityToUUMessageFrame:entity];//将取出来的实转成UUMessage消息实体
        lastEntity = entity;
        [self.dataArr insertObject:messageFrame atIndex:0];
        __block NSArray *tableLastEntityArr = [NSArray new];
        if (i == 0) {//当遍历完 设置lastEntity为数据库最后一个实体
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                int allCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
                tableLastEntityArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
            }];
            lastEntity = [tableLastEntityArr lastObject];//这里取到数据库的最后一条消息
        }
    }
    
    [self initLegalData];
    [self.GroupChatTableView reloadData];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //如果下拉刷新到 剩余数据还大于10时候，否则直接显示在
        if (strongSelf ->dataCount > 0){
            //将最上面第一条还显示在最上面
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:refreshCount - 1 inSection:0];
            [weakSelf.GroupChatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }else{
            //leastCount
            //将最上面第一条还显示在最上面
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:leastCount - 1 inSection:0];
            [weakSelf.GroupChatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        [weakSelf doneLoadingTableViewData];
    });
}

#pragma mark - 请求群聊消息 GroupCreateSuccessEntity
-(void)getGroupChatData{
    if (requestingHistoryData) {
        //如果正在请求群消息 则不尽兴请求
        return;
    }
    NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
    if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
        if ([title containsString:@"("] && [title containsString:@")"]) {
            NSArray *array = [title componentsSeparatedByString:@"("];
            title = array[0];
        }
        titleViewLabel.text = [NSString stringWithFormat:@"%@(收取中)",title];
        self.navigationItem.titleView = titleViewLabel;
        
        //设置某些按钮不可点
        lookDetailBtn.userInteractionEnabled = NO;
        self.backBtn.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            lookDetailBtn.userInteractionEnabled = YES;//到时间详情按钮可点
            self.backBtn.userInteractionEnabled = YES;//到时间返回按钮可点
        });
    }
    requestingHistoryData = YES;
    if (self.groupCreateSEntity) {
        if ([socketModel isConnected]) {//当连接状态才进行请求
            [socketRequest getGroupChatData:self.groupCreateSEntity AndChatEntity:self.chatEntity];
        }else{//否则设置为不再请求中
            requestingHistoryData = NO;
        }
    }else{
        self.groupCreateSEntity.groupId = self.conversationId;
        self.groupCreateSEntity.groupName = self.groupName;
        //GroupCreateSuccessEntity *entity 的groupId和groupName  MessageChatEntity*entity的
        [socketRequest getGroupChatData:self.groupCreateSEntity AndChatEntity:self.chatEntity];//
    }
}

#pragma mark - 请求撤回

#pragma mark - 请求已读
//readedRequest

#pragma mark - 请求已收到

#pragma mark - 为了重新建立服务器链接
//-(void)getAddFriendList{

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    
    if (messageType == SecretLetterType_SocketConnectChanged) {
        //重新连接通知界面刷新
        //请求消息历史 【当刚走了didload 这里面会过滤，didload中有请求消息历史】
        
        [self requestChatHistory:YES];
    }else if (messageType == SecretLetterType_ReceiveGroupMessage){//5003 返回uumessage
        messageWaitSendDict = nil; //当收到消息 设置重发数据为nil
        
        //防止错误崩溃 一般不会走
        if (![chatModel isKindOfClass:[UUMessageFrame class]]) {
            return;
        }
        UUMessageFrame *messageFrame = chatModel;
//        UUMessageTypeText     = 0 , // 文字
//        UUMessageTypePicture  = 1 , // 图片
//        UUMessageTypeVoice    = 2 ,  // 语音
        //收到web端消息
        if (messageFrame.message.IsFromWeb && messageFrame.message.from == UUMessageFromMe) {
            messageFrame.message.failStatus = @"0";
            if (messageFrame.message.type == UUMessageTypeText) {
                NSDictionary *dic = @{@"strContent": messageFrame.message.strContent, @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": @"",@"IsServer":@"1"};
                [self addSpecifiedItem:dic];
                [self.GroupChatTableView reloadData];
                CGFloat showHeight = 0;
                if ([self.IFView_.TextViewInput isFirstResponder]) {
                    showHeight = SCREEN_HEIGHT - keyboardHeight ;
                }else{
                    showHeight = self.IFView_.btnSendMessage.selected | !self.IFView_.addFaceView.hidden?SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50):SCREEN_HEIGHT;
                }
                if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50) {
                    [self tableViewScrollToBottomOffSet:-64-50 IsStrongToBottom:YES];
                }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
                    [self tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
                }
                
            }else if (messageFrame.message.type == UUMessageTypePicture){
                
            }else if (messageFrame.message.type == UUMessageTypeVoice){
                
            }
            return;
        }
        
        //收到app消息
        //将收到的消息直接插入当前界面并展示 UUMessageFrame 转 UUMessageFrame 但是新增了参数 与上一个消息进行了比较
        UUMessage *messagee = [UUMessage new];
        messagee = messageFrame.message;
        //如果是自己的文字消息 则只是进行更改chatid 并通知cell 刷新 成功
        if (messagee.invitor.length == 0 && messagee.appMsgId.length > 1 && [[messagee.userId description] isEqualToString:[NFUserEntity shareInstance].userId]) {
            BOOL isExist = NO;
            for (int i = self.dataArr.count - 1; i>=0; i--) {
                UUMessageFrame *findEntity = self.dataArr[i];
                if ([findEntity.message.appMsgId isEqualToString:messagee.appMsgId]) {
                    isExist = YES;
                    NSIndexPath *freshIndexPath=[NSIndexPath indexPathForRow:i inSection:0];
                    GroupMessageTableViewCell  * cell = (GroupMessageTableViewCell *)[self.GroupChatTableView cellForRowAtIndexPath:freshIndexPath];
                    UUMessageFrame *uuMessageF = self.dataArr[freshIndexPath.row];
                    uuMessageF.message.failStatus = @"0";//接收到服务器给的chatid 将这个row的实体设置为成功发送
                    uuMessageF.message.chatId = messagee.chatId;
                    uuMessageF.message.fileId = messagee.fileId;
                    [cell.timer invalidate];
                    break;
                }
            }
            if(isExist){
                //如果本地没有这条消息，那么就应该进行展示m，【自己发红包 但是不显示红包消息】
                //如果是yes，那么说明本地有了这条消息 就不需要再次展示了
                //能到这里的 都在自己发的 并且已经在缓存了的所以直接return
                return;
            }
        }
#warning 这里需要与服务器核实 注释了又能如何
        
        //当收到服务器消息 在缓存中根据chatId查找是否有数据 如果有则不进行缓存和add到界面
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
//        __block NSArray *existArr = [NSArray new];
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            existArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",messagee.chatId];
//        }];
//        if (existArr.count > 0) {
//            //如果缓存中存在该id记录 则return不用再进行缓存了
//            return;
//        }
        
        self.GroupChatTableView.userInteractionEnabled = YES;
        //将此时的实体与上一个实体做比较，看时间是否超过三分钟，如果超过三分钟则展示时间
        if (lastEntity) {
            //如果该条信息的 日期和上一条不一样转额显示，否则隐藏
            if (![messagee.strTimeHeader isEqualToString:lastEntity.create_time_head] && lastEntity.create_time_head.length > 0 && messagee.strTimeHeader.length > 0) {
                messageFrame.showTimeHead = YES;
            }else{
                //不超过久不显示时间
                messageFrame.showTimeHead = NO;
            }
            if (![messagee.strTime isEqualToString:lastEntity.create_time]) {
                messageFrame.showTime = YES;
            }else{
                //不超过久不显示时间
                messageFrame.showTime = NO;
            }
        }else{
            //如果这条数据上面还有其它缓存没展示 则取出来进行比较是否需要显示时间
            //这里要么datacount大于0 要么leastCount大于0
            if (dataCount > 0 || leastCount >0) {
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                __block NSArray *arr = [NSArray new];
                __weak typeof(self)weakSelf=self;
                if (dataCount > 0) {
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount - 1,1]];
                    }];
                }else if (leastCount >0){
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->leastCount - 1,1]];
                    }];
                }
                //能到这里 一般只有一条
                if (arr.count == 1) {
                    MessageChatEntity *hideLastChatEntity = [arr firstObject];
                    if (![messagee.strTimeHeader isEqualToString:hideLastChatEntity.create_time_head]) {
                        messageFrame.showTimeHead = YES;
                    }else{
                        messageFrame.showTimeHead = NO;
                    }
                    if (![messagee.strTime isEqualToString:hideLastChatEntity.create_time]) {
                        messageFrame.showTime = YES;
                    }else{
                        //不超过久不显示时间
                        messageFrame.showTime = NO;
                    }
                }
            }else{
                //这里 这条数据为和该人聊天的第一条数据 显示时间
                messageFrame.showTimeHead = YES;
                messageFrame.showTime = YES;
            }
        }
        //如果是拉人 则不现实时间
        if (messagee.invitor.length > 0 || messagee.type == UUMessageTypeRedRobRecord) {
            messageFrame.showTimeHead = NO;
            messageFrame.showTime = NO;
        }
        //set一下 不然showtimeheader会为空
        [messageFrame setMessage:messagee];
        //群聊消息 单个插入并显示 在最下面插入
//        [self.dataArr addObject:messageFrame];
        
//        UUMessageFrame *messa = [UUMessageFrame new];
//        UUMessage *messaa = [UUMessage new];
//        messaa.type = UUMessageTypeRecommendCard;
//        messaa.from =UUMessageFromOther;
//        [messa setMessage:messaa];
//        [self.dataArr addObject:messa];
        
        if (messagee.invitor.length > 0) {
            //缓存 谁谁进群
            MessageChatEntity *GroupEntity = [MessageChatEntity new];
            GroupEntity.invitor = messageFrame.message.invitor;
            GroupEntity.localReceiveTime = messageFrame.message.localReceiveTime;
            GroupEntity.localReceiveTimeString = messageFrame.message.localReceiveTimeString;
            GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
            GroupEntity.pullType = messageFrame.message.pullType;
            GroupEntity.fileId = messageFrame.message.fileId;
            
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //userId = userId order by id desc limit 5
                dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
                lastArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                
            }];
            //重复消息
            if(lastArr.count == 1){
                MessageChatEntity *lastEntity = [lastArr firstObject];
                if ([GroupEntity.pulledMemberString isEqualToString:lastEntity.pulledMemberString] && GroupEntity.pulledMemberString.length > 0 && [GroupEntity.pullType isEqualToString:lastEntity.pullType]) {
                    //如果有相同消息 则return
                    return;
                }
            }
            
            //插入数据
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:groupMacroName dicOrModel:GroupEntity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
            //如果是拉人 则请求群详情更改名字
            [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
        }else if(messagee.type == UUMessageTypeRedRobRecord){
            //红包领取记录
            MessageChatEntity *GroupEntity = [MessageChatEntity new];
            GroupEntity.user_name = messageFrame.message.userName;
            GroupEntity.localReceiveTime = messageFrame.message.localReceiveTime;
            GroupEntity.localReceiveTimeString = messageFrame.message.localReceiveTimeString;
            GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
            GroupEntity.type = @"5";
            GroupEntity.redpacketString = @"";
            if (GroupEntity.pulledMemberString.length == 0 || GroupEntity.user_name.length == 0) {
                return;//如果领取红包 为空 则不缓存
            }
            //插入数据
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:groupMacroName dicOrModel:GroupEntity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
        }else{
            //用于fmdb缓存 正常群聊消息
            MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
            //新收到的消息设置为最后一个实体
            lastEntity = entity;
            //这里进行缓存 tongxun.sqlite
//            NSArray *MessageChatList = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
            //插入数据
            __weak typeof(self)weakSelf=self;
            
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //userId = userId order by id desc limit 5
                dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
                lastArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                
            }];
            //重复消息
            if(lastArr.count == 1){
                MessageChatEntity *lastEntity = [lastArr firstObject];
                if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
                    //如果有相同消息 则return
                    return;
                }
            }
            
            
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:groupMacroName dicOrModel:entity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
        }
//        dispatch_queue_t mainQueue = dispatch_get_main_queue();
//        dispatch_async(mainQueue, ^{
            //收到消息 更新界面
        
        [self.dataArr addObject:messageFrame];
        
//        [self.GroupChatTableView reloadData];
        
        CGFloat showHeight = 0;
        if (![self.IFView_.TextViewInput isFirstResponder]  && self.IFView_.addFaceView.hidden) {
            showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
        }
        CGFloat huanchong = 250;
        if(self.GroupChatTableView.contentSize.height - self.GroupChatTableView.contentOffset.y >= (SCREEN_HEIGHT - kTopHeight - 50 + huanchong)){
            NSLog(@"不滚到最下面");
            newMessageBottomButton.alpha = 1;
            return;
        }else{
            NSLog(@"滚到最下面");
        }
        
        if ([self.IFView_.TextViewInput isFirstResponder]) {
            showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
        }else{
            showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
        }
        if (self.GroupChatTableView.contentSize.height > showHeight) {
            
            [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
        }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
            [self tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
        }else{
            [self.GroupChatTableView reloadData];
        }
        
        
        
        
    }else if (messageType == SecretLetterType_GroupChatHistory){ //5012
        //群聊历史消息
        //@{@"groupId":[[firstD objectForKey:@"group_id"] description],@"groupArr":chatContantArr};
        //s收到群组消息 设置为no
        requestingHistoryData = NO;
        
        if (![chatModel isKindOfClass:[NSDictionary class]]) {
            return;
        }
        chatModel = (NSDictionary *)chatModel;
        NSMutableArray *getArr = [NSMutableArray arrayWithArray:[chatModel objectForKey:@"groupArr"]];
        [NFUserEntity shareInstance].PushQRCode = @"0";//设置app跳转状态为正常
        //当为pop或选照片等过来的时候 判断是否有新历史消息 有则继续刷新界面 否则直接return
        if (!IsPush && getArr.count == 0 && self.dataArr.count > 0) {
            
            CGFloat showHeight = 0;
            if ([self.IFView_.TextViewInput isFirstResponder]) {
                showHeight = SCREEN_HEIGHT - keyboardHeight ;
            }else{
                showHeight = self.IFView_.btnSendMessage.selected | !self.IFView_.addFaceView.hidden?SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50):SCREEN_HEIGHT;
            }
            if(![self.IFView_.TextViewInput isFirstResponder] && !self.IFView_.btnSendMessage.selected && !self.IFView_.btnChangeVoiceState.selected && !self.IFView_.emojiBtn.selected){
                //如果输入控件不是第一响应者 则不做任何处理
                
                if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50) {
                    [self tableViewScrollToBottomRequestHistoryAnimation:NO];
                }
            }
            //收到消息为nil 显示完整标题
            titleViewLabel.text = [NSString stringWithFormat:@"%@(%@)",self.groupCreateSEntity.groupName,[self.groupTotalNum integerValue]>0?self.groupTotalNum:self.groupCreateSEntity.groupTotalNum];
            dispatch_main_async_safe(^{
                self.navigationItem.titleView = titleViewLabel;
            })
            if ([NFUserEntity shareInstance].isNeedRefreshChatData) {
                [self withOutNetShowDataBase];//当转发 需要加载最新数据
            }
            if(self.IsHaveNotRead){
                UUMessageFrame *uuMessage = [self.dataArr lastObject];
#pragma msrk - 如果有未读 则强制设置消息已读
                [socketRequest readedRequest:uuMessage.message.chatId GroupId:self.groupCreateSEntity.groupId];
            }
            [self showUnreadedMessageCount:getArr];//显示xx条消息未读【就算请求到的消息历史count为0 可能在会话列表缓存了】
            [self receivedServerAndInit];//收到数据 初始化逻辑设置为正常
            
            return;
        }
        //设置已读和已收到 取最后一个
        MessageChatEntity *setReaded = [getArr lastObject];
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        //这里进行缓存
//        __block BOOL IsExistHistory = NO;
        //收到历史消息 缓存处理   【检查表存在、过滤无用数据】remove掉的数据后面也同样不会再有
        
        [self dealHistoryChatData:getArr];
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            sleep(5);
            __block NSArray *errorArr = [NSArray new];
            if (!self) {
                NSLog(@"self is missing");
            }
            if (getArr.count > 0) {
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    errorArr = [strongSelf ->jqFmdb jq_insertTable:groupMacroName dicOrModelArray:getArr];
                }];
                if (errorArr.count > 0) {
                    [SVProgressHUD showInfoWithStatus:@"有部分消息缓存失败"];
                }
            }
            //耗时的操作都放多线程执行吧
            //            [self countDataCount];//缓存完消息历史后 重新计算消息条数
            //            NSArray *afterCacheArr = [self showHistoryData];//
            //            [self DealDataToLocalController:afterCacheArr];
            //            NSLog(@"%d",self.dataArr.count);
            //            [self initLegalData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self DealDataToLocalController:getArr];
                if (self.dataArr.count > 15) {
                    //                    dataCount -= (self.dataArr.count - 15);
                    dataCount  = dataCount + (self.dataArr.count - 15);
                    canRefresh = YES;
                    [self.dataArr removeObjectsInRange:NSMakeRange(0, self.dataArr.count - 15)];
                }
            });

            
//            NSLog(@"%d",self.dataArr.count);
        });
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //数据收取、处理完毕，进行更新界面 receivedServerAndInit在里面
            [self receivedChatArrDataReloadUIWith:getArr setReadedEntity:setReaded];
        });
        [self showUnreadedMessageCount:getArr];//显示xx条消息未读
    }else if (messageType == SecretLetterType_GroupBreak){
        IsInGroup = YES;
        //清除缓存
        //删除本地该群组
//        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//        __block NSArray *arr = [NSArray new];
//        [jqFmdb jq_inDatabase:^{
//            arr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where conversationId = '%@' and IsSingleChat = '0'",self.groupCreateSEntity.groupId];
//        }];
//        NSArray *arrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
        BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:self.groupCreateSEntity.groupId SecondKeyName:@"IsSingleChat" SecondValueName:@"0"];
        if (ret) {
            NSLog(@"删除成功");
        }
        dispatch_group_t group = dispatch_group_create();
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            dispatch_group_enter(group);
            //清除缓存
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:groupMacroName IsDelete:YES];
            if (rett) {
                //NSLog(@"");
            }
            dispatch_group_leave(group);
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        //回去需要更新会话列表
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        GroupCreateSuccessEntity *createSEntity = chatModel;
        if ([createSEntity.exit_group isEqualToString:@"1"]) {
            [SVProgressHUD showInfoWithStatus:@"你已不在该群聊"];
        }else{
            [SVProgressHUD showInfoWithStatus:@"该群已解散"];
        }
        IsNotNeedCash = YES;
        [self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
    }else if (messageType == SecretLetterType_GroupMessageDrowSuccess){
        //撤回成功 数据库删除
        [SVProgressHUD showSuccessWithStatus:@"撤回成功"];
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        __block NSArray *arrs = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //qunzu
            arrs = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",drowMessageId]];
//                    arrs = [strongSelf ->jqFmdb jq_lookupTable:[resulyDict objectForKey:@"userId"] dicOrModel:[MessageChatEntity class] whereFormat:@""];
        }];
        if(arrs.count == 0){
            [SVProgressHUD showInfoWithStatus:@"出现错误：4016"];
            return;
        }
        MessageChatEntity *changeEntity = [arrs lastObject];
        changeEntity.type = @"7";
        changeEntity.pulledMemberString = @"你撤回了一条消息";
        [self.myManage changeFMDBData:changeEntity KeyWordKey:@"chatId" KeyWordValue:drowMessageId FMDBID:@"tongxun.sqlite" TableName:groupMacroName];
        
        
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",drowMessageId]];
//        }];
        
        //判断删除sdwebimage缓存在磁盘里面的图片
        if (self.dataArr.count > drowMessageIndexPath.row) {
            UUMessageFrame *entity = self.dataArr[drowMessageIndexPath.row];
            if (entity.message.cachePicPath.length > 0) {
                [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
            }
        }
        
        UUMessageFrame *messageFrameReplace = [weakSelf MessageChatEntityToUUMessageFrame:changeEntity];
        [self.dataArr replaceObjectAtIndex:drowMessageIndexPath.row withObject:messageFrameReplace];
        
//        [self.dataArr removeObjectAtIndex:drowMessageIndexPath.row];
//        [self.GroupChatTableView   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:drowMessageIndexPath]withRowAnimation:UITableViewRowAnimationBottom];
        [self.GroupChatTableView   reloadRowsAtIndexPaths:[NSMutableArray arrayWithObject:drowMessageIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.GroupChatTableView reloadData];
    }else if (messageType == SecretLetterType_GroupMessageDrowFailed){
        //撤回失败 dissmiss
        [SVProgressHUD showInfoWithStatus:@"撤回失败"];
    }else if (messageType == SecretLetterType_LoginReceipt){
        //如果到这里 说明某条消息发送失败 不管它 倒计时完了会变成未发送 重新发送即可
//        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//        if ([currentVC isKindOfClass:[GroupChatViewController class]] && messageWaitSendDict) {
//            [self dealTheFunctionData:messageWaitSendDict];
//        }
        NSLog(@"");
    }else if (messageType == SecretLetterType_GroupDetail){//5005
        BOOL IsFromFibbenToOpen = NO;
        GroupCreateSuccessEntity *GroupCreateSuccessEntityChatModel = chatModel;
        if ([GroupCreateSuccessEntityChatModel.isMsgForbidden isEqualToString:@"0"] && [self.groupCreateSEntity.isMsgForbidden isEqualToString:@"1"]) {
            IsFromFibbenToOpen = YES;
        }
        self.groupCreateSEntity = chatModel;
        self.memberArr = self.groupCreateSEntity.groupAllUser;
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *memberArrs = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            memberArrs = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
        }];
//        NSLog(@"%d",memberArrs.count);
        NSString *title = self.navigationItem.title?self.navigationItem.title:self.groupCreateSEntity.groupName;
//        NSString *lastTitle = [NSString stringWithFormat:@"%@(%d)",title,memberArrs.count];
        NSString *lastTitle = [NSString stringWithFormat:@"%@(%@)",title,[self.groupTotalNum integerValue]>0?self.groupTotalNum:self.groupCreateSEntity.groupTotalNum];
        NSArray *array = [lastTitle componentsSeparatedByString:@"("];
//        memberArrContString = [NSString stringWithFormat:@"%d",memberArrs.count];
        memberArrContString = [NSString stringWithFormat:@"%@",[self.groupTotalNum integerValue]>0?self.groupTotalNum:self.groupCreateSEntity.groupTotalNum];
        //是否开启禁言
        
        UUMessageFrame *sssss = [self.dataArr lastObject];
        NSLog(@"IsIsSystemPush = %@",sssss.message.IsIsSystemPush);
        NSLog(@"strContent = %@",sssss.message.strContent);
        
        if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && [self.groupCreateSEntity.isMsgForbidden isEqualToString:@"1"]) {
            //如果不是管理员 则
            self.IFView_.userInteractionEnabled = NO;
            self.IFView_.TextViewInput.text = @"全员禁言";
            self.IFView_.TextViewInput.textColor = [UIColor lightGrayColor];
            self.IFView_.TextViewInput.textAlignment = NSTextAlignmentCenter;
            
            //插入一条消息 禁言消息
            UUMessageFrame *messageFrame = [UUMessageFrame new];
            UUMessage *message = [UUMessage new];
            message.IsIsSystemPush = @"1";
            message.strContent = @" 管理员设置了全员禁言 ";
            [messageFrame setMessage:message];
            [self.dataArr addObject:messageFrame];
            [self.GroupChatTableView reloadData];
            
            
        }else if([self.groupCreateSEntity.is_admin isEqualToString:@"1"] && [self.groupCreateSEntity.isMsgForbidden isEqualToString:@"1"]){
            
            //插入一条消息 禁言消息
            UUMessageFrame *messageFrame = [UUMessageFrame new];
            UUMessage *message = [UUMessage new];
            message.IsIsSystemPush = @"1";
            message.strContent = @" 管理员设置了全员禁言 ";
            [messageFrame setMessage:message];
            [self.dataArr addObject:messageFrame];
            [self.GroupChatTableView reloadData];
            
            
        }else if (IsFromFibbenToOpen){
            //插入一条消息 禁言消息
            UUMessageFrame *messageFrame = [UUMessageFrame new];
            UUMessage *message = [UUMessage new];
            message.IsIsSystemPush = @"1";
            message.strContent = @" 管理员解除了全员禁言 ";
            [messageFrame setMessage:message];
            [self.dataArr addObject:messageFrame];
            [self.GroupChatTableView reloadData];
            
        }
        
        CGFloat showHeight = 0;
        if ([self.IFView_.TextViewInput isFirstResponder]) {
            showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
        }else{
            showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
        }
        
        
        if([self.IFView_.TextViewInput isFirstResponder] || self.IFView_.btnSendMessage.selected || self.IFView_.btnChangeVoiceState.selected || self.IFView_.emojiBtn.selected){
            //如果输入控件不是第一响应者 则不做任何处理
            
//            if (self.GroupChatTableView.contentSize.height > showHeight) {
//
//                [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
//            }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
//                [self tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
//            }
        }
        
        if ([lastTitle isEqualToString:titleViewLabel.text]) {
            //如果请求到的名字和本地显示一样 则不改变
            return;
        }
        if (![titleViewLabel.text containsString:@"收取中"] || ![titleViewLabel.text containsString:@"接收中"]) {
            titleViewLabel.text = lastTitle;
            dispatch_main_async_safe(^{
                self.navigationItem.titleView = titleViewLabel;
            })
        }
    }else if (messageType == SecretLetterType_GroupDetailChanged){
        //群信息改变 请求群详情
        [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
    }
    else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }else if (messageType == SecretLetterType_PersonalInfoDetail){
        //请求到个人信息详情 与展示的比对看看是否有变化
//        selectedUUMessage
        PersonalInfoDetailEntity *personEntity = chatModel;
        if (![personEntity.nick_name isEqualToString:selectedUUMessage.message.nickName] || ![personEntity.userHeadPicPath isEqualToString:selectedUUMessage.message.strIcon]) {
            [self.ZJContactDetailController.nfHeadImageV ShowHeadImageWithUrlStr:personEntity.userHeadPicPath withUerId:nil completion:^(BOOL success, UIImage *image) {
            }];
            [self.ZJContactDetailController.nameEditBtn setTitle:personEntity.nick_name forState:(UIControlStateNormal)];
            //将缓存中的记录变过来
            __block NSArray *existArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                existArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@"where user_id = '%@'",personEntity.userId];
            }];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                for (MessageChatEntity *cacheEntity in existArr) {
                    cacheEntity.headPicPath = personEntity.userHeadPicPath;
                    cacheEntity.nickName = personEntity.nick_name;
                    [self.myManage changeFMDBData:cacheEntity KeyWordKey:@"user_id" KeyWordValue:cacheEntity.user_id FMDBID:@"tongxun.sqlite" TableName:groupMacroName];
                }
                //更改界面的数据
                for (UUMessageFrame *showEntity in self.dataArr) {
                    if ([[showEntity.message.userId description] isEqualToString:personEntity.userId]) {
                        showEntity.message.nickName = personEntity.nick_name;
                        showEntity.message.strIcon = personEntity.userHeadPicPath;
                    }
                }
                dispatch_group_leave(group);
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
            [self.GroupChatTableView reloadData];
            
            NSLog(@"");
        }
    }else if (messageType == SecretLetterType_ChatAlreadyRead){
        //群消息已读
        requestingHistoryData = NO;
    }else if(messageType == SecretLetterType_RedOverdue){
        //红包过期 跳转到详情
        
        
    }else if(messageType == SecretLetterType_RobredPacketRecord){
        //红包 抢 推送
        
        NSLog(@"");
        
    }else if(messageType == SecretLetterType_yanzhengOver){
        [SVProgressHUD showInfoWithStatus:@"申请已过期"];
    }else if(messageType == SecretLetterType_yanzhengReject){
        [SVProgressHUD showInfoWithStatus:@"拒绝成功"];
    }else if(messageType == SecretLetterType_yanzhengAccept){
        [SVProgressHUD showInfoWithStatus:@"操作成功"];
    }else if (messageType == SecretLetterType_GroupSetForbid){
        //群管理设置了群禁言
        //如果不是管理员 则
        self.IFView_.userInteractionEnabled = NO;
        self.IFView_.TextViewInput.text = @"全员禁言";
        self.IFView_.TextViewInput.textColor = [UIColor lightGrayColor];
        self.IFView_.TextViewInput.textAlignment = NSTextAlignmentCenter;
        [self.IFView_.TextViewInput resignFirstResponder];
        
        //插入一条消息 禁言消息
        UUMessageFrame *messageFrame = [UUMessageFrame new];
        UUMessage *message = [UUMessage new];
        message.IsIsSystemPush = @"1";
        message.strContent = @" 管理员设置了全员禁言 ";
        [messageFrame setMessage:message];
        [self.dataArr addObject:messageFrame];
        [self.GroupChatTableView reloadData];
        
        CGFloat showHeight = 0;
        showHeight = SCREEN_HEIGHT - kTopHeight - 50 ;
        if(SCREEN_HEIGHT > 736){
            showHeight -= 34;
        }
        if (self.GroupChatTableView.contentSize.height > showHeight) {
            [self tableViewScrollToBottomRequestHistoryAnimation:NO];
        }
        
    }else if (messageType == SecretLetterType_GroupDelForbid){
        //群管理取消了群禁言
        self.IFView_.userInteractionEnabled = YES;
        self.IFView_.TextViewInput.text = @"";
        self.IFView_.TextViewInput.textColor = [UIColor blackColor];
        self.IFView_.TextViewInput.textAlignment = NSTextAlignmentLeft;
        
        //插入一条消息 禁言消息
        UUMessageFrame *messageFrame = [UUMessageFrame new];
        UUMessage *message = [UUMessage new];
        message.IsIsSystemPush = @"1";
        message.strContent = @" 管理员解除了全员禁言 ";
        [messageFrame setMessage:message];
        [self.dataArr addObject:messageFrame];
        [self.GroupChatTableView reloadData];
    }else if(messageType == SecretLetterType_notifyRefreshChatSessionList){
        self.unreadAllCount++;
        [leftCountBtn setTitle:[NSString stringWithFormat:@"%ld",self.unreadAllCount] forState:(UIControlStateNormal)];
        if(self.unreadAllCount > 99){
            [leftCountBtn setTitle:@"99" forState:(UIControlStateNormal)];
        }
        self.navigationItem.leftBarButtonItems = @[leftBackBtnItem,leftCountBtnItem];
    }else if(messageType == SecretLetterType_ReceiveGroupMessage){
        self.unreadAllCount++;
        [leftCountBtn setTitle:[NSString stringWithFormat:@"%ld",self.unreadAllCount] forState:(UIControlStateNormal)];
        if(self.unreadAllCount > 99){
            [leftCountBtn setTitle:@"99" forState:(UIControlStateNormal)];
        }
        self.navigationItem.leftBarButtonItems = @[leftBackBtnItem,leftCountBtnItem];
    }else if(messageType == SecretLetterType_GroupAllMemberId){
        __block NSMutableArray *existMemberIdArr = [NSMutableArray new];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            NSArray *contactArr = [self.fmdbServicee getLianxirenList];
            NSArray *arr= [NSArray arrayWithArray:[chatModel objectForKey:@"groupAllUser"]];
            for (NSDictionary *dict in arr) {
                for (ZJContact *contact in contactArr) {
                    if ([[[dict objectForKey:@"user_id"] description] isEqualToString:contact.friend_userid]) {
                        [existMemberIdArr addObject:contact];
                        break;
                    }
                }
                //NSLog(@"内部for执行完毕");
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [SVProgressHUD dismiss];
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
                //将已经存在的人员传过去
                toCtrol.alreadlyExistMemberArr = existMemberIdArr;
                toCtrol.SourceType = SourceTypeFromGroupChatAdd;
                toCtrol.groupCreateSEntity = self.groupCreateSEntity;
                [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
                    //完成后在 添加成员界面进行跳转 不会再回去
                }];
                
                
                [self.navigationController pushViewController:toCtrol animated:YES];
            });
        });
        
    }else if (messageType == SecretLetterType_GroupSetManageSucess){
        //设置管理员成功
        [SVProgressHUD showInfoWithStatus:@"设置成功"];
        //[self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
    }else if(messageType == SecretLetterType_receiveBackMessage){
        NSDictionary *dicc = chatModel;
        if([[[dicc objectForKey:@"userId"] description] isEqualToString:[NFUserEntity shareInstance].userId]){
            //如果自己收到自己撤回的消息 则不做任何改变
            
        }else{
            self.dataArr = [NSMutableArray new];
            [self initScoket];
        }
        
    }
    
    
    //    else if (messageType == SecretLetterType_FriendAddRequest){//当收到申请与通知时候将tabbar下标设置为红点 并设置申请与通知cell
    //        UITabBarItem *tabBarItemWillBadge = self.navigationController.tabBarController.tabBar.items[1];
    //        //设置单例 提醒申请与通知有红点
    //        [NFUserEntity shareInstance].IsApplyAndNotify = YES;
    //        dispatch_queue_t mainQueue = dispatch_get_main_queue();
    //        dispatch_async(mainQueue, ^{
    //            [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
    //        });
    //    }
}

#pragma mark - 处理9001
//收到群聊历史消息、处理完毕后更新UI
-(void)receivedChatArrDataReloadUIWith:(NSArray *)getArr setReadedEntity:(MessageChatEntity *)setReaded{
    [self.GroupChatTableView reloadData];
    //收到历史消息后 标题恢复正常
    titleViewLabel.text = [NSString stringWithFormat:@"%@(%@)",self.groupCreateSEntity.groupName,[self.groupTotalNum integerValue]>0?self.groupTotalNum:self.groupCreateSEntity.groupTotalNum];
    self.navigationItem.titleView =  titleViewLabel;
    //当为清除数据到这里 请求到消息加本地消息为空时候 设置lastentity为nil
    if (self.dataArr.count == 0) {
        lastEntity = nil;
    }
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight ;
    }else{
        showHeight = self.IFView_.btnSendMessage.selected | !self.IFView_.addFaceView.hidden?SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50):SCREEN_HEIGHT;
    }
    if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50) {
        [self tableViewScrollToBottomRequestHistoryAnimation:NO];
    }
    
    //等到界面展示完毕了再 设置已读 防止消息丢失
    if (getArr.count > 0) {
#pragma msrk - 设置已收到
        //            [self haveReceived:setReaded.chatId];
#pragma msrk - 设置消息已读
        [socketRequest readedRequest:setReaded.chatId GroupId:self.groupCreateSEntity.groupId];
    }else if(self.IsHaveNotRead){
        for (int i = self.dataArr.count-1; i>=0; i--) {
            UUMessageFrame *uuMessage = self.dataArr[i];
            if (uuMessage.message.chatId && uuMessage.message.chatId.length > 0) {
#pragma msrk - 设置消息已读
                [socketRequest readedRequest:uuMessage.message.chatId GroupId:self.groupCreateSEntity.groupId];
                break;
            }
        }
    }
//    else{
//        for (int i = self.dataArr.count-1; i>=0; i--) {
//            UUMessageFrame *uuMessage = self.dataArr[i];
//            if (uuMessage.message.chatId && uuMessage.message.chatId.length > 0) {
//#pragma msrk - 设置消息已读
//                [socketRequest readedRequest:uuMessage.message.chatId GroupId:self.groupCreateSEntity.groupId];
//                break;
//            }
//        }
//    }
    [self receivedServerAndInit];//收到数据 初始化逻辑设置为正常
}

//显示xx条消息未读
-(void)showUnreadedMessageCount:(NSArray *)getArr{
    //记录剩余未读消息条数
    //设置右上角 有多少新消息 newMessageTopButton
    //是否需要显示右上角 未读消息条数
    NSInteger count = getArr.count - refreshCount;
    if (self.unreadCount - refreshCount > 0) {
        totalNewMessageCount = self.unreadCount - refreshCount;
        self.unreadCount = 0;
    }else if (count > 0){
        totalNewMessageCount = count;
    }else{
        totalNewMessageCount = 0;
    }
    if (totalNewMessageCount > 0) {
        [newMessageTopButton setTitle:[NSString stringWithFormat:@"%d条未读消息",totalNewMessageCount] forState:(UIControlStateNormal)];
        newMessageTopButton.alpha = 1;
    }else{
        newMessageTopButton.alpha = 0;
    }
}

//收到历史消息 缓存处理   【检查表存在、过滤无用数据】
-(void)dealHistoryChatData:(NSMutableArray *)getArr{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    //检查是否有该表
    [self.fmdbServicee IsExistGroupChatHistory:groupMacroName ISNeedAppend:NO];
    //取数据库最后一条消息
    __block NSArray *arr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        int allCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
        arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
    }];
    __block MessageChatEntity *lastChatEntity = [arr lastObject];
    NSArray * copyArr = [NSArray arrayWithArray:getArr];
    //取服务器返回的历史消息最后一条 与本地最后一条进行对比 如果本地有 则不需要再缓存了 直接展示
    MessageChatEntity *serverLastEntity = [copyArr lastObject];
    if ([serverLastEntity.chatId integerValue] <= [lastChatEntity.chatId integerValue]) {
        //最最后一条设置已读
        [socketRequest readedRequest:serverLastEntity.chatId GroupId:self.groupCreateSEntity.groupId];
        [getArr removeAllObjects];//一般都是走这里 因为在会话列表界面已经都缓存了 除非当该会话的消息特别多 而用户点击过快 会话界面来不及缓存 则会走下面
    }else{
        for (MessageChatEntity *repeatChatEntity in copyArr) {
            //从服务器返回的历史消息第0条在数据库查 如果本地有了这条数据 则从getArr中remove，一旦遇到没有的 说明后面的都没有 直接break
            //假设 给的消息历史中 某一条消息已读了 那么 这条消息之前的消息都肯定是已读的，从0开始遍历是对的
            __block NSArray *ifExistHistoryArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                ifExistHistoryArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",repeatChatEntity.chatId];//取最后一条消息的chatId在本地数据库查找是否已经存在
            }];
            if (ifExistHistoryArr.count > 0) {//如果本地数据库存在该条消息 那么remove
                [getArr removeObject:repeatChatEntity];
            }else if ([repeatChatEntity.chatId integerValue] >                                                                             [lastChatEntity.chatId integerValue]){//如果从本地查不到该条数据 并且该消息id 大于等于
                break;
            }
        }
    }
//    __block NSArray *errorArr = [NSArray new];
//    if (getArr.count > 0) {
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            errorArr = [strongSelf ->jqFmdb jq_insertTable:groupMacroName dicOrModelArray:getArr];
//        }];
//        if (errorArr.count > 0) {
//            [SVProgressHUD showInfoWithStatus:@"有部分消息缓存失败"];
//        }
//    }
    
}

//收到服务器回应 基础设置相关
-(void)receivedServerAndInit{
    [NFUserEntity shareInstance].isNeedRefreshChatData = NO;
    requestingHistoryData = NO;
    self.historyIndex = 0;
    self.IsHaveNotRead = NO;
    self.isCanSendMessage = YES;//连接成功 可以发送消息
    lookDetailBtn.userInteractionEnabled = YES;//到时间详情按钮可点
    self.backBtn.userInteractionEnabled = YES;//到时间返回按钮可点
    [SVProgressHUD dismiss];
}

-(void)popToRootViewController{
    //pop回根视图
    UIViewController * viewVC = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:viewVC animated:YES];
}

#pragma mark - 将取出的缓存 赋值到界面数组
-(void)DealDataToLocalController:(NSArray *)arr{
    int a = 0;
    for (MessageChatEntity *entity in arr) {
        if(!entity.type && !entity.pullType){
            BOOL rett = [jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where pkid = '%@'",entity.pkid]];
            if(rett){
                
            }
        }else{
            a++;
            //收到消息
            __weak typeof(self)weakSelf=self;
            
            UUMessageFrame *messageFrame = [weakSelf MessageChatEntityToUUMessageFrame:entity];
    //        UUMessageFrame *messageFrame = [UUMessageFrame new]; //这样也不能解决循环引用
            
            //执行完最后 将实体保存起来
            lastEntity = entity;
            [self.dataArr addObject:messageFrame];
        }
        
//        if (a == 1) {
//            break;
//        }
    }
}

#pragma mark - 计算最后一个datacount
-(void)countDataCount{
    //从数据库里面取数据
    dataCount = 0;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        dataCount =  [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
    }];
    //判断count 是否大于refreshCount 否则从0到refreshCount
    if (dataCount > refreshCount) {
        //当来自搜索历史
        UUMessageFrame *messageU = [self.dataArr lastObject];
        if (self.historyIndex > 15) {
            dataCount -= self.historyIndex;
            canRefresh = YES?dataCount>0:NO;
        }else{
            dataCount -= refreshCount;
            //设置为可以下拉加载
            canRefresh = YES;
        }
    }else{
        dataCount = 0;
        canRefresh = NO;
    }
}

#pragma mark - 断网展示缓存
-(NSArray *)showHistoryData{
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *keyArr = [NSArray new];
    __block NSArray *arr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    if (self.historyIndex>15) {//当为查找消息 并且条数载倒数15条以上
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            keyArr = [strongSelf ->jqFmdb jq_columnNameArray:groupMacroName];
            arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,strongSelf.historyIndex]];//取出 查找的目标数据及其以后的所有数据进行展示
        }];
    }else{
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            keyArr = [strongSelf ->jqFmdb jq_columnNameArray:groupMacroName];
            arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,refreshCount]];//取出并展示倒数十五条
        }];
    }
//    dispatch_queue_t queue = dispatch_queue_create("JoeQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^(void) {
        //取出来后判断第一个数据是否失效
        if (arr.count == 0) {
            return @[];
        }
//        MessageChatEntity *IsYinCangEntity = arr[0];
        MessageChatEntity *IsYinCangEntity = [arr lastObject];
        //yes可以显示 no需要隐藏
        BOOL IsYinCangRet = [NFbaseViewController compaTodayDateWithDate:IsYinCangEntity.localReceiveTime];
        //取出最后一条消息 如果需要隐藏 则将之前所有数据都设置隐藏
        if (!IsYinCangRet) {
            //如果将之前的数据都隐藏了 则不能够刷新了
            canRefresh = NO;
//            NSArray *yincangArr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit 0,%d",dataCount]];
            __block NSArray *yincangArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                yincangArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
            }];
            //从最近的消息开始遍历隐藏
            for (int i = yincangArr.count - 1; i >= 0; i--) {
                MessageChatEntity *entity = yincangArr[i];
                //懒加载逻辑 当for循环到已经隐藏的数据 则不再进行隐藏，之前的肯定也隐藏了 break结束循环
                if ([entity.yuehouYinCang isEqualToString:@"1"]) {
                    break;
                }
                //如果没隐藏则一直循环遍历隐藏
                entity.yuehouYinCang = @"1";
                //更改缓存
                [self.myManage changeFMDBData:entity KeyWordKey:@"chatId" KeyWordValue:entity.chatId FMDBID:@"tongxun.sqlite" TableName:groupMacroName];
            }
        }
        //取出来第一个数据是否删除
//        BOOL IsShanChuRet = [NFbaseViewController compaTodayDateReturnDeleteWithDate:IsYinCangEntity.localReceiveTime];
//        //如果需要删除 则将之前所有数据都设置删除
//        if (!IsShanChuRet) {
////            NSArray *yincangArr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit 0,%d",dataCount]];
//            NSArray *yincangArr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
//            //从最近的消息开始遍历隐藏
//            for (int i = yincangArr.count - 1; i >= 0; i--) {
//                MessageChatEntity *entity = yincangArr[i];
//                //懒加载逻辑 当for循环到已经隐藏的数据 则不再进行隐藏，之前的肯定也隐藏了
//                if ([entity.guanjiShanChu isEqualToString:@"1"]) {
//                    break;
//                }
//                //如果没隐藏则一直循环遍历隐藏
//                entity.guanjiShanChu = @"1";
//                //更改缓存
//                if ([NFUserEntity shareInstance].isGuanjiClear) {
//                    [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:groupMacroName DataKind:[MessageChatEntity class] KeyName:@"chatId" ValueName:entity.chatId];
//                }else{
//                    [self.myManage changeFMDBData:entity KeyWordKey:@"chatId" KeyWordValue:entity.chatId FMDBID:@"tongxun.sqlite" TableName:groupMacroName];
//                }
//            }
//        }
//    });
    
    return arr;
}


    

#pragma mark - 隐藏 阅后隐藏及删除
-(void)initLegalData{
    //如果未设置隐藏或设置了为不隐藏 则 直接add【懒加载】
    if ([yuehouString isEqualToString:@"不隐藏"] || yuehouString.length == 0) {
        return;
    }
    //判断是否能够 下拉加载刷新缓存
    if (canRefresh && self.dataArr.count > 0) {
        UUMessageFrame *entity = self.dataArr[0];
        UUMessage *message = entity.message;
        if ([message.yuehouYinCang isEqualToString:@"1"]) {
            canRefresh = NO;
        }
    }
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    NSMutableArray *arr =[NSMutableArray new];
    for (UUMessageFrame *entity in self.dataArr) {
        UUMessage *message = entity.message;
        message.localReceiveTime = [message.localReceiveTimeString integerValue];
        //如果为不隐藏或 未设置隐藏 则continue
        NSString *yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
        if ([yuehouString isEqualToString:@"不隐藏"] || !yuehouString) {
            [arr addObject:entity];
            continue;
        }
        if (![message.yuehouYinCang isEqualToString:@"1"]) {
            BOOL ret = [NFbaseViewController compaTodayDateWithDate:message.localReceiveTime];
            //如果是yes 说明消息没有过期 如果为0 则需要修改缓存里面的数据 或参数为1
            if (!ret) {
                //懒加载 【当该条信息需要背隐藏时，判断一下它是否已经是隐藏状态 已经隐藏则不进行更新缓存的隐藏标记】
                if (![message.yuehouYinCang isEqualToString:@"1"]) {
                    message.yuehouYinCang = @"1";
                    [entity setMessage:message];
                    //并更改缓存的值
                     MessageChatEntity *chatEntity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:entity];
                    //关键修改这个 隐藏属性
                    chatEntity.yuehouYinCang = @"1";
                    
//                    NSArray *arr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:groupMacroName dicOrModel:chatEntity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
                        if (rett) {
                            NSLog(@"更新success");
                        }
                    }];
                }
            }
        }
        [arr addObject:entity];
    }
    //下面处理最后需要显示的数据【剔除隐藏的数据】
    NSMutableArray *lastArr = [NSMutableArray new];
    for (UUMessageFrame *uuEntity in arr) {
        //如果为不隐藏或 未设置隐藏 则return
        NSString *yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
        if ([yuehouString isEqualToString:@"不隐藏"] || !yuehouString) {
            [lastArr addObject:uuEntity];
            continue;
        }
        UUMessage *message =uuEntity.message;
        //限免判断 是否被清除
        if (![message.yuehouYinCang isEqualToString:@"1"] ) {
            [lastArr addObject:uuEntity];
        }else if ([NFUserEntity shareInstance].showHidenMessage) {
            [lastArr addObject:uuEntity];//不隐藏 显示所有
        }
    }
    self.dataArr = [NSMutableArray arrayWithArray:lastArr];
}

-(void)initUI{
    self.GroupChatTableView.backgroundColor = UIColorFromRGB(0xf2f9ff);
    if (kTabBarHeight > 69) {
        self.bottomConstaint.constant = 50 + kTabbarMoreHeight;
    }
    lookDetailBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [lookDetailBtn setImage:[UIImage imageNamed:@"群聊详情"] forState:UIControlStateNormal];
    [lookDetailBtn addTarget:self action:@selector(GrouplookDtailClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *lookDtailButtonItem = [[UIBarButtonItem alloc]initWithCustomView:lookDetailBtn];
    self.navigationItem.rightBarButtonItem = lookDtailButtonItem;
    
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.GroupChatTableView.bounds.size.height, self.GroupChatTableView.frame.size.width, self.GroupChatTableView.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        [self.GroupChatTableView addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
    //下面再创建其他例如tableview，topview等，不然刷新将会无效
    self.IFView_ = [[UUInputFunctionView alloc]initWithSuperVC:self];
    self.IFView_.delegate = self;
    self.IFView_.isNeedBlock = NO;
    self.IFView_.backgroundColor = UIColorFromRGB(0xededed);
    //点中编辑后
    __weak typeof(self)weakSelf=self;
    [self.IFView_ EditTextview:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
//                [self.chatTableView scrollToBottomWithAnimation:YES];
        CGFloat offSet = strongSelf ->sendMessageJustnow==YES?45:0;
        offSet = 0;
//        offSet = 0;
//        [strongSelf tableViewScrollToBottomOffSet:offSet- 64 - 50 IsStrongToBottom:YES];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            [strongSelf tableViewScrollToBottomOffSet:offSet- 64 - 50 IsStrongToBottom:YES];
        });
        
        strongSelf ->sendMessageJustnow = NO;
        weakSelf.historyIndex = 0;
        
    }];
    
    [self.IFView_ clickRedpacket:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //点击了红包按钮
        //发红包
        [strongSelf tapTableView];
        ZJContact *contact = [ZJContact new];
        if(self.groupCreateSEntity.groupAllUser && self.groupCreateSEntity.groupAllUser.count > 0){
            contact = [self.groupCreateSEntity.groupAllUser lastObject];
        }
        [[NTESRedPacketManager sharedManager] sendRedPacket:@{@"groupId":self.groupCreateSEntity.groupId,@"groupNum":[NSString stringWithFormat:@"%ld",self.groupCreateSEntity.groupAllUser.count>0?self.groupCreateSEntity.groupAllUser.count:0]}];
        
    }];
    
    [self.IFView_ iinputAiTe:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //输入了@ 跳转到 艾特界面
        [strongSelf tapTableView];
        
        __block NSArray *mamberArr = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelfff=weakSelf;
            mamberArr = [strongSelfff ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"groupmemberlist%@",strongSelfff.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
        }];
        
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
        //将已经存在的人员传过去
        toCtrol.alreadlyExistMemberArr = [NSArray arrayWithArray:mamberArr];
        self.groupCreateSEntity.groupAllUser = [NSArray arrayWithArray:mamberArr];
        toCtrol.SourceType = SourceTypeFromGroupChatAite;
        toCtrol.groupCreateSEntity = self.groupCreateSEntity;
        [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
            //完成后传过来 @数组
            NSMutableString *string = [NSMutableString stringWithFormat:@"%@",@"@"];
            for (ZJContact *contact in memberArr) {
                ZJContact *contactt = [self.fmdbServicee checkContactIsHaveCommmentname:contact];
                [string appendString:[NSString stringWithFormat:@"%@ ",contactt.friend_originalnickname.length>0?contactt.friend_originalnickname:contactt.friend_nickname]];
            }
            self.IFView_.TextViewInput.text = [NSString stringWithFormat:@"%@",string];
        }];
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }];
    
    //推送名片按钮
    [self.IFView_ setClickCard:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //点击了名片
        [strongSelf tapTableView];
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        toCtrol.SourceType = SourceTypeFromRecommendGroupCard;
        toCtrol.groupCreateSEntity = strongSelf.groupCreateSEntity;
        toCtrol.contentType = @"4";
        [strongSelf.navigationController pushViewController:toCtrol animated:YES];
        
    }];
    
    //邀请群成员按钮
    [self.IFView_ ClickInvite:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //点击了邀请群成员
        [strongSelf tapTableView];
        

        [SVProgressHUD showWithStatus:@"加载中"];
        //获取群成员id
        [socketRequest requestGroupAllMemberIdWithGroup:self.groupCreateSEntity.groupId];
        
        return;
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
        //将已经存在的人员传过去
        toCtrol.alreadlyExistMemberArr = self.memberArr;
        toCtrol.SourceType = SourceTypeFromGroupChatAdd;
        toCtrol.groupCreateSEntity = self.groupCreateSEntity;
        [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
            //完成后在 添加成员界面进行跳转 不会再回去
        }];
        [strongSelf.navigationController pushViewController:toCtrol animated:YES];
        
        
    }];
    
    //删除收藏的图片
    [self.IFView_ deleteCollectPicture:^(NSString *fileId) {
        socketRequest = [SocketRequest share];
        [socketRequest deleteCollectEmoji:@{@"file_id":fileId}];
    }];
    
    [self.view addSubview:self.IFView_];
    //add notification
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTableView)];
    tap.delegate = self;
    tap.numberOfTouchesRequired = 1;
    [self.GroupChatTableView addGestureRecognizer:tap];
    self.GroupChatTableView.tableFooterView = [[UIView alloc]init];
    //底部编辑菜单【删除】
    bottomEditView = [[[NSBundle mainBundle]loadNibNamed:@"bottomEditMenuView" owner:nil options:nil] firstObject];
    bottomEditView.frame = CGRectMake(0, SCREEN_HEIGHT - kTopHeight - kTabBarHeight , SCREEN_WIDTH, 50);
    [bottomEditView.deleteBtn addTarget:self action:@selector(deleteCommitClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    //初始化 新消息按钮底部 newMessageBottomButton
    newMessageBottomButton = [UIButton new];
    [newMessageBottomButton setTitle:@"有新消息" forState:(UIControlStateNormal)];
    newMessageBottomButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [newMessageBottomButton setTitleColor:UIColorFromRGB(0x39a86b) forState:(UIControlStateNormal)];
    //    newMessageBottomButton = [UIColor yellowColor];
    [newMessageBottomButton setBackgroundImage:[UIImage imageNamed:@"有新消息半圆角矩形"] forState:(UIControlStateNormal)];
    [newMessageBottomButton addTarget:self action:@selector(scrollToBottom) forControlEvents:(UIControlEventTouchUpInside)];
    newMessageBottomButton.alpha = 0;
    [self.view addSubview:newMessageBottomButton];
    //    [self.view addSubview: newMessageBottomButton];
    [newMessageBottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        if (SCREEN_HEIGHT >= 736) {
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        }else{
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-75);
        }
    }];
    
    //初始化 新消息按钮 头部 newMessageTopButton
    totalNewMessageCount = 0;
    newMessageTopButton = [UIButton new];
    [newMessageTopButton setTitle:@"有新消息" forState:(UIControlStateNormal)];
    newMessageTopButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [newMessageTopButton setTitleColor:UIColorFromRGB(0x39a86b) forState:(UIControlStateNormal)];
    //    newMessageBottomButton = [UIColor yellowColor];
    [newMessageTopButton setBackgroundImage:[UIImage imageNamed:@"有新消息半圆角矩形"] forState:(UIControlStateNormal)];
    [newMessageTopButton addTarget:self action:@selector(scrollToNewTop) forControlEvents:(UIControlEventTouchUpInside)];
    newMessageTopButton.alpha = 0;
    [self.view addSubview:newMessageTopButton];
    //    [self.view addSubview: newMessageBottomButton];
    [newMessageTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        if (SCREEN_HEIGHT >= 736) {
            make.bottom.mas_equalTo(self.view.mas_top).offset(50);
        }else{
            make.bottom.mas_equalTo(self.view.mas_top).offset(50);
        }
    }];
}

#pragma mark - 点击有新消息 滑到底部
-(void)scrollToBottom{
    newMessageBottomButton.alpha = 0;
    
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
    }else{
        showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
    }
    if (self.GroupChatTableView.contentSize.height > showHeight) {
        
        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
    }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
        [self tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
    }//        });
    
    
    
}
#pragma mark - 点击有新消息  滑到未读消息顶部
-(void)scrollToNewTop{
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        [self.IFView_.TextViewInput resignFirstResponder];
    }
    newMessageTopButton.alpha = 0;
    NSInteger a = self.dataArr.count + totalNewMessageCount;//需要显示的总条数
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block NSArray *arr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        NSInteger totalCount =  [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
        arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",totalCount - a,totalCount - 1]];
    }];
    
    totalNewMessageCount = 0;
    self.dataArr = [NSMutableArray new];
    [self DealDataToLocalController:arr];
    [self.GroupChatTableView reloadData];
    [self.GroupChatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] && self.GroupChatTableView.editing) {
        CGPoint currentTouchPosition = [touch locationInView:self.GroupChatTableView];
        NSIndexPath *indexPath = [self.GroupChatTableView indexPathForRowAtPoint:currentTouchPosition];
        MessageTableViewCell  * cell = (MessageTableViewCell *)[self.GroupChatTableView cellForRowAtIndexPath:indexPath];
//        if (cell.selected && firstSelectDelete  && clickMoreIndexPath == indexPath) {
        if (cell.selected) {//当点击的cell为cell的selected状态 不走diddeselected方法
            [cell setSelected:NO animated:YES];
            firstSelectDelete = NO;
            //储存起来
            UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
            entity.message.IsSelected = NO;//当取消选中时，设置数据选中状态为NO
            [needDeleteEntityArr removeObject:entity];
            [needDeleteIndexPathArr removeObject:indexPath];
            if (clickMoreIndexPath == indexPath) {
                clickMoreIndexPath = nil;
            }
            return  YES;
        }
        return NO;
    }
    return  YES;
}

#pragma mark -右侧按钮
-(void)GrouplookDtailClick:(UIButton *)sender{
    
    
    
    //群组
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    GroupChatDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatDetailTableViewController"];
    toCtrol.memberArr = self.memberArr;
    toCtrol.groupCreateSEntity = self.groupCreateSEntity;
    __weak typeof(self)weakSelf=self;
    [toCtrol returnEditedName:^(NSString *enitedName) {
        weakSelf.title = enitedName;
    }];
    [toCtrol setReturnDeleteBlock:^(BOOL IsDelete) {
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf.dataArr = [NSMutableArray new];
        strongSelf ->lastEntity = nil;
        strongSelf.unreadCount = 0;
        strongSelf ->dataCount = 0;
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            [strongSelf.GroupChatTableView reloadData];
//        });
    }];
    [self.navigationController pushViewController:toCtrol animated:YES];
//    [socketModel disConnect];
}

#pragma mark - 点击tableview
-(void)tapTableView{
    //收起更多菜单
     if ( self.IFView_.btnSendMessage.selected) {
        if ([self.IFView_ respondsToSelector:@selector(hidenMoreBtn)]) {
            [self.IFView_ performSelector:@selector(hidenMoreBtn) withObject:nil afterDelay:0];
        }
        return;
    }else if(self.IFView_.emojiBtn.selected){
        if ([self.IFView_ respondsToSelector:@selector(hidenEmoji)]) {
            [self.IFView_ performSelector:@selector(hidenEmoji) withObject:nil afterDelay:0];
        }
        return;
    }
    else if ([self.IFView_.TextViewInput isFirstResponder]){
        if ([self.IFView_ respondsToSelector:@selector(hideninputView)]) {
            [self.IFView_ performSelector:@selector(hideninputView) withObject:nil afterDelay:0];
        }
        [self.view endEditing:YES];
        return;
    }
    
}

-(void)takeCameraAbout{
}
-(void)emojiClick{
}
//adjust UUInputFunctionView's height 适配键盘高度
-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    CGFloat animationTime = 1;
    if (self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected) {
        animationTime = 0.01;
    }
    __weak typeof(self)weakSelf=self;
        __strong typeof(weakSelf)strongSelf=weakSelf;
        if (notification.name == UIKeyboardWillShowNotification) {
            keyboardHeight = keyboardEndFrame.size.height;
            //btnSendMessage emojiBtn
            if(self.GroupChatTableView.frame.origin.y != 0){
                self.GroupChatTableView.frame = CGRectMake(0, 0, self.GroupChatTableView.frame.size.width, self.GroupChatTableView.frame.size.height);
            }
            
            CGRect frame = self.GroupChatTableView.frame;
            if (!self.IFView_.btnSendMessage.selected && !self.IFView_.emojiBtn.selected) {//当tableview的frame的y大于0 才让tableview上移 【表情、更多弹出时除外】
                
                
                CGFloat showHeight = 0;
                if ([self.IFView_.TextViewInput isFirstResponder]) {
                    showHeight = SCREEN_HEIGHT - keyboardEndFrame.size.height - 64 - 50;
                }else{
                    
                    showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + 64):SCREEN_HEIGHT - kTopHeight - 50;
                }
                //当tabbar高于49 则显示高度需要 再减去32
                if (kTabBarHeight > 49) {
                    showHeight -= kTabbarMoreHeight;
                }
                
                CGFloat offset = 0.0;
                if (self.GroupChatTableView.contentSize.height > showHeight) {
                    offset = self.GroupChatTableView.contentSize.height - showHeight;
                }
                NSLog(@"y = %f",self.GroupChatTableView.frame.origin.y);
                //[self.GroupChatTableView setContentOffset:CGPointMake(0, offset)];
                //[self.GroupChatTableView SendMessageLetTableScrollToBottomBegin:YES offset:offset];
                [self.GroupChatTableView SendMessageLetTableScrollToBottom:YES offset:offset];
                
                
                
                
//                CGRect rectInTableView;
//                if (self.dataArr.count > 0) {
//                    rectInTableView = [self.GroupChatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
//                }else{
//                    rectInTableView = CGRectMake(0, 0, 0, 0);
//                }
//                NSInteger IsX = 0;
//                if (kTabBarHeight > 69){
//                    IsX = kTabbarMoreHeight+ kStatusBarMoreHeight;
//                }
//                if (CGRectGetMaxY(rectInTableView) + 64 < SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - IsX) {
//                    //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
//                    NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - IsX));
//                }else{
//                    CGFloat changeHeight = (CGRectGetMaxY(rectInTableView) + 64 + keyboardEndFrame.size.height + 50) - SCREEN_HEIGHT;
//                    if (kTabBarHeight > 69){
//                        changeHeight += kTabbarMoreHeight;
//                    }
//                    if (changeHeight > keyboardEndFrame.size.height) {
//                        changeHeight = keyboardEndFrame.size.height;
//                    }
//                    //当tableview的 frame的y大于0 才让tableview上移 【表情、更多弹出时除外】
//                    //                    frame.origin.y -= keyboardEndFrame.size.height;
//                    frame.origin.y -= changeHeight;
//                    if (kTabBarHeight > 69 && changeHeight >= keyboardEndFrame.size.height){
//                        //因为当键盘弹起来的时候 tabbar高出的35 被去掉了 所以这里需要减去35
//                        frame.origin.y += kTabbarMoreHeight;
//                    }
//                    [UIView animateWithDuration:animationTime animations:^{
//                        dispatch_async(dispatch_get_main_queue(), ^(void) {
//                            self.GroupChatTableView.frame = frame;
//                        });
//                    }];
//                }
//                if (self.dataArr.count > 0) {//键盘弹起 tableview滑到底部
//                    [self.GroupChatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
//                }
            }else if (self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected){
                //当表情或更多弹出时 点击键盘 应该喝上面一样的逻辑 看看界面是否会被遮挡
                CGRect rectInTableView;
                if (self.dataArr.count > 0) {
                    rectInTableView = [self.GroupChatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
                }else{
                    rectInTableView = CGRectMake(0, 0, 0, 0);
                }
                
                CGFloat showHeight = 0;
                if ([self.IFView_.TextViewInput isFirstResponder]) {
                    showHeight = SCREEN_HEIGHT - keyboardEndFrame.size.height - 64 - 50;
                }else{
                    
                    showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + 64):SCREEN_HEIGHT - kTopHeight - 50;
                }
                //当tabbar高于49 则显示高度需要 再减去32
                if (kTabBarHeight > 49) {
                    showHeight -= kTabbarMoreHeight;
                }
                
                if (self.GroupChatTableView.contentSize.height < showHeight) {
                    //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
                    //NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - 10));
                }else{
                    CGFloat offset = 0.0;
                    if (self.GroupChatTableView.contentSize.height > showHeight) {
                        offset = self.GroupChatTableView.contentSize.height - showHeight;
                    }
                   // NSLog(@"y = %f",self.GroupChatTableView.frame.origin.y);
                    //[self.GroupChatTableView setContentOffset:CGPointMake(0, offset)];
                    //[self.GroupChatTableView SendMessageLetTableScrollToBottomBegin:YES offset:offset];
                    [self.GroupChatTableView SendMessageLetTableScrollToBottom:YES offset:offset];
                    
                    
                }
            }
//            else{
//                CGRect frame = self.GroupChatTableView.frame;
//                frame.origin.y = 0;
//                self.GroupChatTableView.frame = frame;
//            }
            
//            if (kTabBarHeight > 49) {
//                self.bottomConstaint.constant = keyboardEndFrame.size.height+10;
//            }else{
//                self.bottomConstaint.constant = keyboardEndFrame.size.height+50;
//            }
        }else{
            //收起键盘 可能是惦点击了表情、更多、语音按钮
            if ([self.IFView_ respondsToSelector:@selector(hideninputView)] && !self.IFView_.emojiBtn.selected && !self.IFView_.btnSendMessage.selected && !self.IFView_.btnChangeVoiceState.selected) {
                [self.IFView_ performSelector:@selector(hideninputView) withObject:nil afterDelay:0];
            }
            
            CGRect frame = self.GroupChatTableView.frame;
            frame.origin.y = 0;
            [UIView animateWithDuration:AnimationTime animations:^{
                self.GroupChatTableView.frame = frame;
            }];
            [self.IFView_.TextViewInput resignFirstResponder];
            [self.view endEditing:YES];
            
            [self.GroupChatTableView groupScrollToBottomWithAnimation:YES offset:0];
            
            keyboardHeight = 0;
            
            
        }
    
    //如果 这里tableview最大Y不对则进行更改 【当上面动画还未执行时候 这里已经修改了】 这里的40设置小于50就可以了 底部约束要到view
//    if (notification.name == UIKeyboardWillShowNotification && CGRectGetMaxY(self.GroupChatTableView.frame) < SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - 64 - 40) {
//        CGRect rect = self.GroupChatTableView.frame;
//        rect.size.height += 50;
//        self.GroupChatTableView.frame = rect;
//    }else if(notification.name == UIKeyboardWillHideNotification && CGRectGetMaxY(self.GroupChatTableView.frame) < SCREEN_HEIGHT - 64 - 50 - 40){
//        CGRect rect = self.GroupChatTableView.frame;
//        rect.size.height += 50;
//        self.GroupChatTableView.frame = rect;
//    }
}

#pragma mark - InputFunctionViewDelegate
//发送文字
-(void)UUInputFunctionView:(UUInputFunctionView *)funcView showMessage:(NSString *)message SendMessage:(NSString *)sendMessage{
}
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    //发送前检查
    if (![self beforeSendMessageCheck]) {
        return;//如果为No 则return
    }
    sendMessageJustnow = YES;//发过消息 点击输入框 会有遮挡 这里记录下发过信息
    //这里记录发送了消息
    //    sendMessage = YES;
    NSDictionary *dic = @{@"strContent": message, @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": [ClearManager getAPPMsgId]};
    //不能发送空或 全是空格
    if (funcView.TextViewInput.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"不可发送空消息"];
        return;
    }
    NSString *str = [dic objectForKey:@"strContent"];
    if (str.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
        return;
    }
//    NSString*temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if ([temp length] ==0) {
//        [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
//        return;
//    }
    if (funcView.TextViewInput.text.length > 20000) {
        [SVProgressHUD showInfoWithStatus:@"消息过长"];
        return;
    }
    //如果能发送 则将发送的内容置空
    //    if (socketModel.isConnected) {
    funcView.TextViewInput.text = @"";
    //        [funcView changeSendBtnWithPhoto:YES];
    //    }
//    if (![ClearManager getNetStatus]) {
//        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
//        return;
//    }
//    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
//        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
//        return;
//    }
    //发送消息给服务器
    [socketModel ping];
    if ([SocketModel share].isConnected || YES){
//    if ([SocketModel share].isConnected){
//        [SVProgressHUD show];
        funcView.TextViewInput.text = @"";
        [self dealTheFunctionData:dic];
    }else{
//        [SVProgressHUD showWithStatus:@"正在重连"];
        __weak typeof(self)weakSelf=self;
//        __strong NSDictionary *dict = dic;
        messageWaitSendDict = dic;
        [socketModel initSocket];
        [socketModel returnConnectSuccedd:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if (![currentVC isKindOfClass:[GroupChatViewController class]]) {
                    return ;
                }
//                [SVProgressHUD showSuccessWithStatus:@"重连成功"];
//                [socketRequest getIsExistUnReadApply]; //检测到底有没有重连成功
                [strongSelf dealTheFunctionData:dic];
            });
        }];
    }
}

//发送图片
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image IsselectedOrginalImage:(BOOL)ret
{
    if (image.imageOrientation == 3) {
        image = [image rotate:UIImageOrientationRight];
    }
    NSDictionary *dic = @{@"picture": image, @"type":@(UUMessageTypePicture)};
    BOOL netRet = [self beforeSendMessageCheck];//查看是否能发送
    [SVProgressHUD dismiss];//第一次检查 直接消失
    if (netRet) {
        isOriginalImage = ret;
        //判断图片是否被旋转过 如果旋转过 则向右旋转90度
        //进行http请求 上传图片
//        [self uploadPictureImage:image IsselectedOrginalImage:ret];
        [self aliyunUploadPictureImage:image IsselectedOrginalImage:ret];
        
        
        [self tapTableView];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self beforeSendMessageCheck]) {//这时候如果还是未连接 则提示
                isOriginalImage = ret;
                //判断图片是否被旋转过 如果旋转过 则向右旋转90度
                NSDictionary *dic = @{@"picture": image, @"type":@(UUMessageTypePicture)};
                //进行http请求 上传图片
//                [self uploadPictureImage:image IsselectedOrginalImage:ret];
                [self aliyunUploadPictureImage:image IsselectedOrginalImage:ret];
                [self tapTableView];
            }else{
                //return
            }
        });
    }
    return;
    //发送消息给服务器
    [socketModel ping];
    if ([SocketModel share].isConnected){
        [self dealTheFunctionData:dic];
        //发送图片时候 超时计算取消
        [NFUserEntity shareInstance].timeOutCountBegin = NO;
    }else{
        [SVProgressHUD showWithStatus:@"正在重连"];
        [socketModel initSocket];
        __weak typeof(self)weakSelf=self;
        __weak NSDictionary *dict = dic;
        messageWaitSendDict = dic;
        [socketModel returnConnectSuccedd:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if (![currentVC isKindOfClass:[GroupChatViewController class]]) {
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                [weakSelf dealTheFunctionData:dic];
                //发送图片时候 超时计算取消
                [NFUserEntity shareInstance].timeOutCountBegin = NO;
            });
        }];
    }
}

#pragma mark -   //发送收藏的图片
-(void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPictureDict:(NSDictionary *)dictt{
    
    NSString *fileExt = @"jpeg";
    NSString *fileMime = @"image/jpeg";
    NSString *fileName = @"photo.jpeg";
    NSArray *arr = [[dictt objectForKey:@"picpath"] componentsSeparatedByString:@"/"];
    NSString *filePath = arr.count>1?[NSString stringWithFormat:@"%@/%@",arr[arr.count - 2],[arr lastObject]]:@"";
    NSString *fileUniqueName = [[dictt objectForKey:@"picpath"] description].lastPathComponent;
    NSDictionary *dic = @{@"url": [dictt objectForKey:@"picpath"], @"type":@(UUMessageTypePicture),@"fileExt":fileExt,@"fileMime":fileMime,@"fileName":fileName,@"filePath":filePath,@"fileSize":@"500000",@"fileUniqueName":fileUniqueName,@"imgHeight":@"",@"imgRatio":[[dictt objectForKey:@"scale"] floatValue]>0?[dictt objectForKey:@"scale"]:@"1",@"imgWidth":@"",@"appMsgId":[ClearManager getAPPMsgId]};
    [socketModel ping];
    if ([SocketModel share].isConnected || YES){
        [self dealTheFunctionData:dic];
        //发送图片时候 超时计算取消 【用http进行上传图片了 这里发的图片就是一个地址 和文字消息一样】
        //                    [NFUserEntity shareInstance].timeOutCountBegin = NO;
    }
    
}

//发送语音
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    //发送前检查
    if (![self beforeSendMessageCheck]) {
        return;//如果为No 则return
    }
    NSDictionary *dic = @{@"voice": voice, @"strVoiceTime":[NSString stringWithFormat:@"%d",(int)second], @"type":@(UUMessageTypeVoice),@"appMsgId": [ClearManager getAPPMsgId]};
    //发送消息给服务器
    [socketModel ping];
    if ([SocketModel share].isConnected){
        [self dealTheFunctionData:dic];
        //发送图片时候 超时计算取消
        [NFUserEntity shareInstance].timeOutCountBegin = NO;
    }else{
        [SVProgressHUD showWithStatus:@"正在重连"];
        [socketModel initSocket];
        __weak typeof(self)weakSelf=self;
        __weak NSDictionary *dict = dic;
        messageWaitSendDict = dic;
        [socketModel returnConnectSuccedd:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if (![currentVC isKindOfClass:[GroupChatViewController class]]) {
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                [weakSelf dealTheFunctionData:dic];
                //发送图片时候 超时计算取消
                [NFUserEntity shareInstance].timeOutCountBegin = NO;
            });
        }];
    }
}

#pragma mark - 阿里云上传图片
-(void)aliyunUploadPictureImage:(UIImage *)image IsselectedOrginalImage:(BOOL)ret{
    
    NSData *imageData;
    //imageData = UIImageJPEGRepresentation(image, 1);
    if (ret) {
    //        imageData = UIImageJPEGRepresentation(image, 0.9);
            imageData = UIImageJPEGRepresentation(image, 1);
        }else{
            
            imageData = [ClearManager imageDataScale:image scale:1];
    }
    image = [UIImage imageWithData:imageData];
    CGSize size = image.size;
    [[AliyunOSSUpload aliyunInit] uploadImage:@[image] success:^(NSArray<NSString *> * _Nonnull nameArray) {
            if(nameArray.count == 0){
                [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
                return;
            }
            NSDictionary *dic = @{@"url": [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[nameArray firstObject]], @"type":@(UUMessageTypePicture),@"fileExt":@"jpeg",@"fileMime":@"image/jpeg",@"fileName":@"photo.jpeg",@"filePath":[nameArray firstObject],@"fileSize":[NSString stringWithFormat:@"%.0f",size.height*size.width],@"fileUniqueName":[nameArray firstObject],@"imgHeight":[NSString stringWithFormat:@"%.2f",size.height],@"imgRatio":[NSString stringWithFormat:@"%.2f",size.width/size.height],@"imgWidth":[NSString stringWithFormat:@"%.2f",size.width],@"appMsgId":[ClearManager getAPPMsgId]};
            //发送消息给服务器
                [socketModel ping];
                if ([SocketModel share].isConnected){
                    [self dealTheFunctionData:dic];
                    //发送图片时候 超时计算取消 【用http进行上传图片了 这里发的图片就是一个地址 和文字消息一样】
//                    [NFUserEntity shareInstance].timeOutCountBegin = NO;
                }else{
                    [SVProgressHUD showWithStatus:@"正在重连"];
                    [socketModel initSocket];
                    __weak typeof(self)weakSelf=self;
                    __weak NSDictionary *dict = dic;
                    messageWaitSendDict = dic;
                    [socketModel returnConnectSuccedd:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                            if (![currentVC isKindOfClass:[MessageChatViewController class]]) {
                                return ;
                            }
                            [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                            [socketRequest getIsExistUnReadApply];
                            //发送图片时候 超时计算取消 【用http进行上传图片了 这里发的图片就是一个地址 和文字消息一样】
//                            [NFUserEntity shareInstance].timeOutCountBegin = NO;
                        });
                    }];
                }
        }];
    
}



#pragma mark - http上传图片
-(void)uploadPictureImage:(UIImage *)image IsselectedOrginalImage:(BOOL)ret{
//    [SVProgressHUD show];
    MBProgressHUD *hud = [MBProgressHUD showOnlyLoadToView:self.view];
    //上传头像
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSData *imageData;
    if (ret) {
        //        imageData = UIImageJPEGRepresentation(image, 0.9);
        imageData = UIImageJPEGRepresentation(image, 1);
    }else{
        imageData = [ClearManager imageDataScale:image scale:1];
//        if (imageData.length > 1200000) {
//            imageData = UIImageJPEGRepresentation(image, 0.3);
//        }
//        if (imageData.length > 1200000) {
//            imageData = UIImageJPEGRepresentation(image, 0.1);
//        }
    }
    
    NSString *type = [LoginManager typeForImageData:imageData];
    [sendDic setObject:type forKey:@"imgaeType"];
    [LoginManager execute:@selector(changeHeadPicpathManager) target:self callback:@selector(uploadPictureImageManagerCallBack:) args:sendDic,imageData,nil];
    
}



- (void)uploadPictureImageManagerCallBack:(id)data
{
    if (data)
    {
        [MBProgressHUD hideHUDForView:self.view];
        if ([data objectForKey:@"error"]) {
            [SVProgressHUD showInfoWithStatus:[data objectForKey:@"error"]];
            return;
        }else if ([data objectForKey:@"kWrong_Dlog"]){
            [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        }else{
            [SVProgressHUD dismiss];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *backDict = data;
                NSDictionary *dic = @{@"url": [data objectForKey:@"url"], @"type":@(UUMessageTypePicture),@"fileExt":[[data objectForKey:@"fileExt"] description],@"fileMime":[[data objectForKey:@"fileMime"] description],@"fileName":[[data objectForKey:@"fileName"] description],@"filePath":[[data objectForKey:@"filePath"] description],@"fileSize":[[data objectForKey:@"fileSize"] description],@"fileUniqueName":[[data objectForKey:@"fileUniqueName"] description],@"imgHeight":[[data objectForKey:@"imgHeight"] description],@"imgRatio":[[data objectForKey:@"imgRatio"] description],@"imgWidth":[[data objectForKey:@"imgWidth"] description],@"appMsgId":[ClearManager getAPPMsgId]};
                //发送消息给服务器
                [socketModel ping];
                if ([SocketModel share].isConnected){
                    [self dealTheFunctionData:dic];
                    //发送图片时候 超时计算取消 【用http进行上传图片了 这里发的图片就是一个地址 和文字消息一样】
//                    [NFUserEntity shareInstance].timeOutCountBegin = NO;
                }else{
                    [SVProgressHUD showWithStatus:@"正在重连"];
                    [socketModel initSocket];
                    __weak typeof(self)weakSelf=self;
                    __weak NSDictionary *dict = dic;
                    messageWaitSendDict = dic;
                    [socketModel returnConnectSuccedd:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                            if (![currentVC isKindOfClass:[MessageChatViewController class]]) {
                                return ;
                            }
                            [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                            [socketRequest getIsExistUnReadApply];
                            //发送图片时候 超时计算取消 【用http进行上传图片了 这里发的图片就是一个地址 和文字消息一样】
//                            [NFUserEntity shareInstance].timeOutCountBegin = NO;
                        });
                    }];
                }
            }
        }
    }
    else
    {
        //        [SVProgressHUD showErrorWithStatus:kWrongMessage];
        [SVProgressHUD showInfoWithStatus:@"上传失败"];
    }
}

#pragma mark - 发送消息给服务器
- (void)dealTheFunctionData:(NSDictionary *)dic
{
    //检查是否有该表
    [self.fmdbServicee IsExistGroupChatHistory:groupMacroName ISNeedAppend:NO];
    __weak typeof(self)weakSelf=self;
    dispatch_group_t group = dispatch_group_create();
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_group_enter(group);
        [weakSelf addSpecifiedItem:dic];
        dispatch_group_leave(group);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    [self.GroupChatTableView reloadData];
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
    }else{
        showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
    }
    if (self.GroupChatTableView.contentSize.height > showHeight) {
        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
    }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
        [self tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
    }
    //将消息发送给服务器
    //type 0文本消息 1图片消息 2语音消息
    if ([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"type"] description]] isEqualToString:@"0"]) {
        //无论有没有网络 都可以发送消息展示
//        __weak typeof(self)weakSelf=self;
//        dispatch_group_t group = dispatch_group_create();
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//            dispatch_group_enter(group);
//            [weakSelf addSpecifiedItem:dic];
//            dispatch_group_leave(group);
//        });
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//        [self.GroupChatTableView reloadData];
//        CGFloat showHeight = 0;
//        if ([self.IFView_.TextViewInput isFirstResponder]) {
//            showHeight = SCREEN_HEIGHT - keyboardHeight ;
//        }else{
//            showHeight = self.IFView_.btnSendMessage.selected | !self.IFView_.addFaceView.hidden?SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50):SCREEN_HEIGHT;
//        }
//        if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50) {
//            __weak typeof(self)weakSelf=self;
//            [UIView animateWithDuration:0.25 animations:^{
//                [weakSelf tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
//            }];
//        }
        if ([socketModel isConnected]) {
            [socketModel ping];
        }
        if ([SocketModel share].isConnected) {
            //判断链接正常再更新ui
            //处理缓存相关
            //            [self addSpecifiedItem:dic];
            //            [self.chatTableView reloadData];
            //发送到服务器
            NSString *createTime = [NFMyManage getCurrentTimeStamp];
            //发送消息
            [self sendMesageFrom:[NFUserEntity shareInstance].userName To:self.groupCreateSEntity.groupId Content:[dic objectForKey:@"strContent"] Createtime:createTime AppMsgId:[dic objectForKey:@"appMsgId"]];
        }else{
            //链接不上 提示
//            [SVProgressHUD showErrorWithStatus:kWrongMessage];
        }
    }else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"type"]] isEqualToString:@"1"]){
        //发送图片 展示到界面 无论有没有网络 都展示
//        __weak typeof(self)weakSelf=self;
//        dispatch_group_t group = dispatch_group_create();
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//            dispatch_group_enter(group);
//            [weakSelf addSpecifiedItem:dic];
//            dispatch_group_leave(group);
//        });
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//        [self.GroupChatTableView reloadData];
//        CGFloat showHeight = 0;
//        if ([self.IFView_.TextViewInput isFirstResponder]) {
//            showHeight = SCREEN_HEIGHT - keyboardHeight ;
//        }else{
//            showHeight = self.IFView_.btnSendMessage.selected | !self.IFView_.addFaceView.hidden?SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50):SCREEN_HEIGHT;
//        }
//        if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50) {
//            __weak typeof(self)weakSelf=self;
//            [UIView animateWithDuration:0.25 animations:^{
//                [weakSelf tableViewScrollToBottomOffSet:20 IsStrongToBottom:NO];
//            }];
//        }
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        NSInteger time = interval;
        NSString *createTime = [NSString stringWithFormat:@"%ld",time];
        //发送到服务器
//        NSString *encodedImageStr = [ClearManager UIImageToBase64Str:dic[@"picture"] IsOriginalImage:isOriginalImage];
        NSString *encodedImageStr = dic[@"url"];
         isOriginalImage = NO;
        //发送到服务器
        [self sendMesageFrom:[NFUserEntity shareInstance].userName To:self.groupCreateSEntity.groupId ImageContent:encodedImageStr Createtime:createTime pictureInfo:dic APPMsgId:[dic objectForKey:@"appMsgId"]];
    }else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"type"]] isEqualToString:@"2"]){
        //语音 展示到界面 无论有没有网络 都展示
//        __weak typeof(self)weakSelf=self;
//        dispatch_group_t group = dispatch_group_create();
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//            dispatch_group_enter(group);
//            [weakSelf addSpecifiedItem:dic];
//            dispatch_group_leave(group);
//        });
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//        [self.GroupChatTableView reloadData];
//        CGFloat showHeight = 0;
//        if ([self.IFView_.TextViewInput isFirstResponder]) {
//            showHeight = SCREEN_HEIGHT - keyboardHeight ;
//        }else{
//            showHeight = self.IFView_.btnSendMessage.selected | !self.IFView_.addFaceView.hidden?SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50):SCREEN_HEIGHT;
//        }
//        if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50) {
//            __weak typeof(self)weakSelf=self;
//            [UIView animateWithDuration:0.25 animations:^{
//                [weakSelf tableViewScrollToBottomOffSet:20 IsStrongToBottom:NO];
//            }];
//        }
        //发送到服务器
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        NSInteger time = interval;
        NSString *createTime = [NSString stringWithFormat:@"%ld",time];
        //发送到服务器
        NSString *encodedVoiceStr = [dic[@"voice"] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [self sendMesageFrom:[NFUserEntity shareInstance].userName To:self.groupCreateSEntity.groupId VoiceContent:encodedVoiceStr Createtime:createTime VoiceTimeLength:[dic objectForKey:@"strVoiceTime"] AppMsgId:[dic objectForKey:@"appMsgId"]];
    }
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *arrs = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
//    NSArray *arr = [jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:@""];
}

#pragma mark - //发送文本消息
- (void)sendMesageFrom:(NSString *)from To:(NSString *)to Content:(NSString *)content Createtime:(NSString *)createtime AppMsgId:(NSString *)msgId
{
    
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"normal";
    newsDic[@"userName"] = from;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"groupId"] = to;
//    BOOL ret = [ClearManager stringContainsEmoji:content];
//    if (ret) {
//        content = [EmojiShift emojiShiftstring:content];
//    }
    newsDic[@"msgContent"] = content;
    newsDic[@"msgTime"] = createtime;
    newsDic[@"action"] = @"sendGroupMsg";
    newsDic[@"appMsgId"] = msgId;
    newsDic[@"groupMsgClient"] = @"app";
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
    
    //    else if ([content isKindOfClass:[NSData class]]){
    //        NSData *data =    [NSJSONSerialization dataWithJSONObject:newsDic options:NSJSONWritingPrettyPrinted error:nil];
    //        if (socketModel.isConnected) {
    //            [socketModel sendMsg:data];
    //        }
    //    }
    
}

#pragma mark - //发送语音消息
- (void)sendMesageFrom:(NSString *)from To:(NSString *)to VoiceContent:(NSString *)content Createtime:(NSString *)createtime VoiceTimeLength:(NSString *)timeLength AppMsgId:(NSString *)msgId
{
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"audio";
    newsDic[@"userName"] = from;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"groupId"] = to;
//    if ([content isKindOfClass:[NSString class]]) {
//        content = [EmojiShift emojiShiftstring:content];
//    }
    newsDic[@"msgContent"] = content;
    newsDic[@"msgTime"] = createtime;
    newsDic[@"action"] = @"sendGroupMsg";
    newsDic[@"audioTime"] = timeLength;
    newsDic[@"appMsgId"] = msgId;
    newsDic[@"groupMsgClient"] = @"app";
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
    //    else if ([content isKindOfClass:[NSData class]]){
    //        NSData *data =    [NSJSONSerialization dataWithJSONObject:newsDic options:NSJSONWritingPrettyPrinted error:nil];
    //        if (socketModel.isConnected) {
    //            [socketModel sendMsg:data];
    //        }
    //    }
}

#pragma mark - //发送图片消息
- (void)sendMesageFrom:(NSString *)from To:(NSString *)to ImageContent:(NSString *)content Createtime:(NSString *)createtime pictureInfo:(NSDictionary *)info APPMsgId:(NSString *)APPMsgId
{
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"image";
    newsDic[@"userName"] = from;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"groupId"] = to;
//    if ([content isKindOfClass:[NSString class]]) {
//        content = [EmojiShift emojiShiftstring:content];
//    }
    newsDic[@"msgContent"] = @"[图片]";
    newsDic[@"msgTime"] = createtime;
    newsDic[@"action"] = @"sendGroupMsg";
    newsDic[@"appMsgId"] = APPMsgId;
    newsDic[@"groupMsgClient"] = @"app";
    //图片信息
    NSMutableDictionary *pictureInfo = [NSMutableDictionary new];
    pictureInfo[@"fileExt"] = [[info objectForKey:@"fileExt"] description];
    pictureInfo[@"fileMime"] = [[info objectForKey:@"fileMime"] description];
    pictureInfo[@"fileName"] = [[info objectForKey:@"fileName"] description];
    pictureInfo[@"filePath"] = [[info objectForKey:@"filePath"] description];
    pictureInfo[@"fileSize"] = [[info objectForKey:@"fileSize"] description];
    pictureInfo[@"fileUniqueName"] = [[info objectForKey:@"fileUniqueName"] description];
    pictureInfo[@"imgHeight"] = [[info objectForKey:@"imgHeight"] description];
    pictureInfo[@"imgRatio"] = [[info objectForKey:@"imgRatio"] description];
    pictureInfo[@"imgWidth"] =[[info objectForKey:@"imgWidth"] description];
    newsDic[@"fileInfo"] = pictureInfo;
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
    //    else if ([content isKindOfClass:[NSData class]]){
    //        NSData *data =    [NSJSONSerialization dataWithJSONObject:newsDic options:NSJSONWritingPrettyPrinted error:nil];
    //        if (socketModel.isConnected) {
    //            [socketModel sendMsg:data];
    //        }
    //    }
}

#pragma mark - 发红包
-(void)UUInputFunctionView:(UUInputFunctionView *)funcView sendRed:(RedEntity *)redEntity{
    NSLog(@"发送群组红包");
    if (self.IFView_.btnSendMessage.selected) {
        self.IFView_.btnSendMessage.selected = NO;
    }
    //type为3 是红包
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat: @"yyyyMMddhhmmssSS"];
    NSString *identifier = [dateFormatter stringFromDate:[NSDate date]];
    NSString *groupName;
    if (self.groupName.length > 0) {
        groupName = self.groupName;
    }else if (self.groupCreateSEntity.groupName.length > 0){
        groupName = self.groupCreateSEntity.groupName;
    }
    
    //红包消息 显示
    //toname toid
    NSDictionary *returnDcit = @{@"chatId":[NSString stringWithFormat:@"%@%@",identifier,[NFUserEntity shareInstance].userId],@"strContent":@"恭喜发财，大吉大利",@"type":@"3",@"userName":groupName,@"userId":self.groupCreateSEntity.groupId,@"groupRed":redEntity.redPacketTotalPrice,@"groupRedCount":@"3"};
    [self addSpecifiedItem:returnDcit];
    [self.GroupChatTableView reloadData];
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight ;
    }else{
        showHeight = SCREEN_HEIGHT ;
    }
    //        NSLog(@"%f",self.chatTableView.contentOffset.y);
    //当内容cell总高度大于contentheight 或 有表情view存在时
    if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50 || !self.IFView_.addFaceView.hidden) {
        
        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
    }
}



#pragma mark - 将数据展示到界面
- (void)addSpecifiedItem:(NSDictionary *)dic
{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    URLStr = @"";
    [dataDic setObject:@1 forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
    if ([dic objectForKey:@"userName"]) {
        [dataDic setObject:[dic objectForKey:@"userName"] forKey:@"userName"];
    }
    if ([dic objectForKey:@"strIcon"]) {
        [dataDic setObject:URLStr forKey:@"strIcon"];
    }
    //设置消息内容数据
    [message setWithDict:dataDic];
    message.chatId = [dataDic objectForKey:@"chatId"];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    message.localReceiveTime = interval;
    message.localReceiveTimeString = [NSString stringWithFormat:@"%.0f",interval];
    message.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"HH:mm"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
    if (![confromTimesp isThisYear]) {
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"YYYY年MM月dd日"];
    }else{
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"MM月dd日"];
    }
    //将此时的实体与上一个实体做比较，看时间是否超过三分钟，如果超过三分钟则展示时间
    if (lastEntity) {
        //如果该条信息的 日期和上一条不一样转额显示，否则隐藏
        if (![message.strTimeHeader isEqualToString:lastEntity.create_time_head]) {
            messageFrame.showTimeHead = YES;
        }else{
            //不超过久不显示时间
            messageFrame.showTimeHead = NO;
        }
        if (![message.strTime isEqualToString:lastEntity.create_time]) {
            messageFrame.showTime = YES;
        }else{
            //不超过久不显示时间
            messageFrame.showTime = NO;
        }
    }
    else{
        //如果这条数据上面还有其它缓存没展示 则取出来进行比较是否需要显示时间
        //这里要么datacount大于0 要么leastCount大于0
        if (dataCount > 0 || leastCount >0) {
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *arr = [NSArray new];
            if (dataCount > 0) {
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount - 1,1]];
                }];
            }else if (leastCount >0){
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    arr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->leastCount - 1,1]];
                }];
            }
            //能到这里 一般只有一条
            if (arr.count == 1) {
                MessageChatEntity *hideLastChatEntity = [arr firstObject];
                if (![message.strTimeHeader isEqualToString:hideLastChatEntity.create_time_head]) {
                    messageFrame.showTimeHead = YES;
                }else{
                    messageFrame.showTimeHead = NO;
                }
                if (![message.strTime isEqualToString:hideLastChatEntity.create_time]) {
                    messageFrame.showTime = YES;
                }else{
                    //不超过久不显示时间
                    messageFrame.showTime = NO;
                }
            }
        }else{
            //这里 这条数据为和该人聊天的第一条数据 显示时间
            messageFrame.showTimeHead = YES;
            messageFrame.showTime = YES;
        }
    }
    //    messageFrame.showTime = message.showDateLabel;
    //    messageFrame.showTime = YES;
    [messageFrame setMessage:message];
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
//    [self.dataArr addObject:messageFrame];
    //缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    entity.appMsgId = [dic objectForKey:@"appMsgId"];//本地消息id
    lastEntity = entity;
    __weak typeof(self)weakSelf=self;
    
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:groupMacroName];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:groupMacroName dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
    }];
    //重复消息
    if(lastArr.count == 1){
        MessageChatEntity *lastEntity = [lastArr firstObject];
        if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
            //如果有相同消息 则return
            return;
        }
    }
    
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:groupMacroName dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            return;
        }
    }];
    
    
    [self.dataArr addObject:messageFrame];
    
    //    NSArray *arrss = [jqFmdb jq_lookupTable:self.singleEntity.id dicOrModel:[MessageChatEntity class] whereFormat:@""];
}

static NSString *previousTime = nil;

#pragma mark - MessageChatEntity转 UUMessageFrame
-(UUMessageFrame *)MessageChatEntityToUUMessageFrame:(MessageChatEntity *)entity{
    __weak typeof(self)weakSelf=self;
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *messagee = [UUMessage new];
    messagee.strIcon = entity.headPicPath;//头像
    messagee.appMsgId = entity.appMsgId;
    messagee.failStatus = entity.failStatus;
    //从缓存取出来后 将收到的时间与本地时间比对 无效则标记 【yes为能显示】
    if (![entity.yuehouYinCang isEqualToString:@"1"] && ![yuehouString isEqualToString:@"不隐藏"] && yuehouString.length > 0) {
        BOOL ret = [NFbaseViewController compaTodayDateWithDate:entity.localReceiveTime];
        if (![entity.yuehouYinCang isEqualToString:@"1"]) {
            if (!ret) {
                entity.yuehouYinCang = @"1";
            }
        }else{
            //当已经隐藏 设置为yes 不需要再次隐藏
            ret = YES;
        }
        if (!ret) {
            //更改缓存
            [self.myManage changeFMDBData:entity KeyWordKey:@"strId" KeyWordValue:entity.chatId FMDBID:@"tongxun.sqlite" TableName:groupMacroName];
        }
    }
    messagee.chatId = entity.chatId;
    messagee.userId = entity.user_id;
    messagee.userName = entity.user_name;
    messagee.nickName = entity.nickName;
    messagee.originalNickName = entity.originalNickName;
    //判断内容的username是否为自己
    messagee.from = [entity.isSelf isEqualToString:@"0"]?UUMessageFromMe:UUMessageFromOther;
    messagee.yuehouYinCang = entity.yuehouYinCang;
//    messagee.guanjiShanChu = entity.guanjiShanChu;
    messagee.localReceiveTime = entity.localReceiveTime;
    messagee.localReceiveTimeString = entity.localReceiveTimeString;
    messagee.strTime = entity.create_time;
    messagee.strTimeHeader = entity.create_time_head;
    messagee.strContent = entity.message_content;
    if (entity.voiceData) {
        messagee.voice = entity.voiceData;
    }
    if (entity.strVoiceTime) {
        messagee.strVoiceTime = entity.strVoiceTime;
    }
    if (entity.invitor.length > 0) {
        messagee.invitor = entity.invitor;
        messagee.pulledMemberString = entity.pulledMemberString;
        messagee.fileId = entity.fileId;
        messagee.pullType = entity.pullType;
    }
    if ([entity.type isEqualToString:@"0"]) {
        messagee.type = UUMessageTypeText;
    }else if ([entity.type isEqualToString:@"2"]){
        messagee.type = UUMessageTypeVoice;
    }else if ([entity.type isEqualToString:@"1"]){
        messagee.type = UUMessageTypePicture;
        if (entity.pictureScale > 0) {
            messagee.pictureUrl = entity.pictureUrl;
            messagee.pictureScale = entity.pictureScale;
            messagee.fileId = entity.fileId;
        }else{
            messagee.pictureScale = 1;
            messagee.pictureUrl = entity.pictureUrl;
        }
    }else if ([entity.type isEqualToString:@"3"]){
        messagee.type = UUMessageTypeRed;
        //红包id
        messagee.fileId = entity.fileId;
        messagee.redpacketString = entity.redpacketString;
        messagee.redIsTouched = entity.redIsTouched;
        //还需要设置红包参数
    }else if ([entity.type isEqualToString:@"4"]){
        messagee.type = UUMessageTypeRecommendCard;
        messagee.strId = entity.redpacketString;//名片用户id
        messagee.strVoiceTime = entity.strVoiceTime;//名片用户名
        messagee.pictureUrl = entity.pictureUrl;//名片昵称
        messagee.fileId = entity.fileId;//名片头像
    }else if([entity.type isEqualToString:@"5"]){
        messagee.type = UUMessageTypeRedRobRecord;
        messagee.pulledMemberString = entity.pulledMemberString;
    }else if([entity.type isEqualToString:@"7"]){
        messagee.type = UUMessageTypeSystem;
        messagee.pulledMemberString = entity.pulledMemberString;
    }
    //将此时的实体与上一个实体做比较，看时间是否超过三分钟，如果超过三分钟则展示时间
    if (lastEntity) {
        //如果该条信息的 日期和上一条不一样转额显示，否则隐藏
        if (![messagee.strTimeHeader isEqualToString:lastEntity.create_time_head]) {
            messageFrame.showTimeHead = YES;
        }else{
            //不超过久不显示时间
            messageFrame.showTimeHead = NO;
        }
        if (![messagee.strTime isEqualToString:lastEntity.create_time]) {
            messageFrame.showTime = YES;
        }else{
            //不超过久不显示时间
            messageFrame.showTime = NO;
        }
    }else{
        //这里 这条数据为和该人聊天的第一条数据 显示时间
        messageFrame.showTimeHead = YES;
        messageFrame.showTime = YES;
    }
    //设置 //set一下 不然在cell展示中showtimeheader会为空
    [messageFrame setMessage:messagee];
    return messageFrame;
    
}


//tableview滑倒最底部 是否强制滑到最底部
- (void)tableViewScrollToBottomOffSet:(CGFloat)height IsStrongToBottom:(BOOL)ret
{
    //当界面数据为0条或显示的contentSize高度大于2倍屏幕高
    //当界面数据大于15条【刚进来是15跳】 这时候不管界面contentsize多高【图片很高 不好考虑】 都需要到底部
    //是否强制到底部ret
    if (self.dataArr.count==0   && ![self.IFView_.TextViewInput isFirstResponder] && self.dataArr.count > 15 && !ret)
        return;
    
    //设置tableview的frame 不能让遮挡住
    
    CGRect rectInTableView;
    CGRect rectInTableViewSec = CGRect(0, 0, 0, 0);
    if (self.dataArr.count > 0) {
        rectInTableView = [self.GroupChatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
        CGRect rectInTableViewSec = self.dataArr.count>2?[self.GroupChatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 2 inSection:0]]:rectInTableView;
//        rectInTableViewSEC = [self.GroupChatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
        //CGRect aaaa = [self.GroupChatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 2 inSection:0]];
//        rectInTableView = aaaa;
        
        if (@available(iOS 13.0, *) || rectInTableView.size.width == 0) {//ios13 消息刷新的时候 最新的消息 尺寸不能及时加到tableview上面去
            if(self.dataArr.count>2){
                UUMessageFrame *messageFrame = [self.dataArr lastObject];
                if ([messageFrame.message.chatId isEqualToString:@"x"]) {
                    rectInTableViewSec.origin.y += 50;
                }
                else if (messageFrame.message.type == 3){
                    //红包
                    if (messageFrame.message.from == UUMessageFromMe) {
                    rectInTableViewSec.origin.y +=  100;
                }else{
                    rectInTableViewSec.origin.y +=  125;
                }
                }else if(messageFrame.message.type == 4){
                    rectInTableViewSec.origin.y +=  95;
                }else if ( messageFrame.message.pulledMemberString.length > 0) {
                    //领取记录
                    rectInTableViewSec.origin.y +=  30;
                }else{
                    rectInTableViewSec.origin.y +=  [messageFrame cellHeight];
                }
            }
            rectInTableView = rectInTableViewSec;
        }
        
    }else{
        rectInTableView = CGRectMake(0, 0, 0, 0);
    }
    
    //NSLog(@"CGRectGetMaxY(rectInTableView) + 64 + IsX = %f",CGRectGetMaxY(rectInTableView) + 64);
   // NSLog(@"SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - 50  = %f",SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - 50);
    //计算cell显示的位置 和
    
    CGFloat a = 0;//弹出的是键盘还是表情、更多
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        a = keyboardHeight ;
    }else if (self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected){
        a=EMOJI_VIEW_HEIGHT ;
    }
    
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
        
    }else{
//        showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + kTabBarHeight + kTopHeight):SCREEN_HEIGHT - kTopHeight - kTabBarHeight;
        //NSLog(@"kTopHeight = %d",kStatusBarHeight + kNavBarHeight);
        //NSLog(@"kTabBarHeight = %d",kTabBarHeight);
        if(self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden){
            showHeight = SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + kTabBarHeight + kTopHeight);
        }else{
            showHeight = SCREEN_HEIGHT - kTopHeight - kTabBarHeight;
        }
    }
    
    if (CGRectGetMaxY(rectInTableView) < showHeight) {
        //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
        //NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - a - 50));
        
    }else{
        
        if(self.GroupChatTableView.frame.origin.y != 0){
            self.GroupChatTableView.frame = CGRectMake(0, 0, self.GroupChatTableView.frame.size.width, self.GroupChatTableView.frame.size.height);
        }
        
        CGFloat offset = 0.0;
        if (self.GroupChatTableView.contentSize.height > showHeight) {
            offset = self.GroupChatTableView.contentSize.height - showHeight;
            if (@available(iOS 13.0, *) || rectInTableView.size.width == 0) {//ios13 消息刷新的时候 最新的消息 尺寸不能及时加到tableview上面去
            }
            UUMessageFrame *messageFrame = [self.dataArr lastObject];
            if ([messageFrame.message.chatId isEqualToString:@"x"]) {
                offset += 50;
            }
            else if (messageFrame.message.type == 3){
                //红包
                if (messageFrame.message.from == UUMessageFromMe) {
                offset +=  100;
            }else{
                offset +=  125;
            }
            }else if(messageFrame.message.type == 4){
                offset +=  95;
            }else if ( messageFrame.message.pulledMemberString.length > 0) {
                //领取记录
                offset +=  30;
            }else{
                offset +=  [messageFrame cellHeight];
            }
            
        }
        //以上计算完 但是显示有误差 中和误差 这里膝盖以下
        offset += 20;
        
        
        //NSLog(@"y = %f",self.GroupChatTableView.frame.origin.y);
        //[self.GroupChatTableView setContentOffset:CGPointMake(0, offset)];
        //[self.GroupChatTableView SendMessageLetTableScrollToBottomBegin:YES offset:offset];
        
        //NSLog(@"self.GroupChatTableView.contentOffset = %f",self.GroupChatTableView.contentOffset);
        
        if(self.GroupChatTableView.contentSize.height > showHeight){
//            [self.GroupChatTableView setContentOffset:CGPointMake(0, offset - 44)];
        }
        [UIView animateWithDuration:0 animations:^{
            
            [self.GroupChatTableView reloadData];
        } completion:^(BOOL finished) {
            //刷新完成
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                //[NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.GroupChatTableView SendMessageLetTableScrollToBottom:YES offset:offset];
                });
            });
        }];
        
        
    }
    
}


- (void)tableViewScrollToBottomRequestHistoryAnimation:(BOOL)ret{
    //当界面数据为0条或显示的contentSize高度大于2倍屏幕高
    
    //当界面数据大于15条【刚进来是15跳】 这时候不管界面contentsize多高【图片很高 不好考虑】 都需要到底部
    if ((self.dataArr.count==0 || self.dataArr.count > 15 || self.historyIndex > 0) && ![self.IFView_.TextViewInput isFirstResponder])
        return;
    [self.GroupChatTableView groupScrollToBottomWithAnimation:ret offset:0];
}

- (void)tableViewScrollToBottomOffSet:(CGFloat)height Animation:(BOOL)ret
{
    if (SCREEN_WIDTH == 320) {
    }
    
    if ((self.dataArr.count==0 || self.dataArr.count > 15 || self.historyIndex > 0) && ![self.IFView_.TextViewInput isFirstResponder])
        return;
//    [self.GroupChatTableView scrollToBottomWithAnimation:ret offset:- 64 - 50 + height];
    //这里不需要 -64 - 50 【只在第一次进来 会走这里 只是获取本地数据 这里应该是didload中】
    //[self.GroupChatTableView scrollToBottomWithAnimation:ret offset:height];
   [self.GroupChatTableView groupScrollToBottomWithAnimation:ret offset:height];
}

//专门为键盘设置的 将tableview下滑到底部
- (void)tableViewScrollToBottomOffSetUseByMoreView
{
    if (self.dataArr.count == 0) {
        return;
    }
    // emojiBtn   btnSendMessage
    if (self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected) {//弹出表情
        CGRect frame = self.GroupChatTableView.frame;
        CGRect rectInTableView;
        if (self.dataArr.count > 0) {
            rectInTableView = [self.GroupChatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
        }else{
            rectInTableView = CGRectMake(0, 0, 0, 0);
        }
        
        CGFloat showHeight = 0;
        if ([self.IFView_.TextViewInput isFirstResponder] && !self.IFView_.emojiBtn.selected && !self.IFView_.btnSendMessage.selected) {
            
            showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - (kTopHeight > 69?kTabbarMoreHeight:0);
        }else{
            
            showHeight = self.IFView_.btnSendMessage.selected || self.IFView_.emojiBtn.selected? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + kTopHeight + 50 - (kTopHeight > 69?kTabbarMoreHeight:0)):SCREEN_HEIGHT - kTopHeight - 50;
        }
        
        if (CGRectGetMaxY(rectInTableView) < showHeight) {
            //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
            NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - 50 ));
        }else{
            
            CGFloat changeHeight = (CGRectGetMaxY(rectInTableView) + kTopHeight + EMOJI_VIEW_HEIGHT + 50 + (kTopHeight > 69?kTabbarMoreHeight:0)) - SCREEN_HEIGHT;
            
            if (changeHeight > EMOJI_VIEW_HEIGHT - kTabbarMoreHeight && kTopHeight > 69) {
                changeHeight = EMOJI_VIEW_HEIGHT ;
            }else if (changeHeight > EMOJI_VIEW_HEIGHT ){
                changeHeight = EMOJI_VIEW_HEIGHT;
            }
            //当tableview的frame的y大于0 才让tableview上移 【表情、更多弹出时除外】
            //                    frame.origin.y -= keyboardEndFrame.size.height;
            if(frame.origin.y >= 0){
                frame.origin.y -= changeHeight;
            }else{
                frame.origin.y = 0;
                frame.origin.y -= changeHeight;
            }
            if (kTabBarHeight > 69 ){
                //因为当键盘弹起来的时候 tabbar高出的35 被去掉了 所以这里需要减去35
               // frame.origin.y -= kTabbarMoreHeight;
            }
            
            
            if(self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected ){
                
                [UIView animateWithDuration:AnimationTime animations:^{
                    self.GroupChatTableView.frame = frame;
                } completion:^(BOOL finished) {
                }];
                
            }
            
        }
        
        
        if (self.dataArr.count > 0){
            [self.GroupChatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count > 0?self.dataArr.count - 1:0 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
        }
        
        
    }else if (!self.IFView_.emojiBtn.selected && !self.IFView_.btnSendMessage.selected){//收起表情【没点更多】
        if ([self.IFView_.TextViewInput isFirstResponder]) {
            NSLog(@"");
            CGRect frame = self.GroupChatTableView.frame;
            frame.origin.y -= keyboardHeight;
            [UIView animateWithDuration:AnimationTime animations:^{
                self.GroupChatTableView.frame = frame;
            }];
//            [self.GroupChatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count > 0?self.dataArr.count - 1:0 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
        }else{
            [self.GroupChatTableView reloadData];
            CGRect frame = self.GroupChatTableView.frame;
            frame.origin.y = 0;
            [UIView animateWithDuration:AnimationTime animations:^{
                self.GroupChatTableView.frame = frame;
            }];
//            [self.GroupChatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count > 0?self.dataArr.count - 1:0 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
        }
    }
    
}

#pragma 相机相关
- (void)takeCameral
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:NO];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (@available(iOS 13.0, *)) {
            imagePicker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        [SVProgressHUD showInfoWithStatus:@"相机不可用"];
    }
}

- (void)searchLibrary{
    if (!ExistImageArr_) {
        ExistImageArr_ = [[NSMutableArray alloc] initWithCapacity:9];
    }
    SGPhotoPickerViewController *photoPickerViewController = [[SGPhotoPickerViewController alloc] initWithPicCount:(PIC_SELECET_COUNT)(9 - ExistImageArr_.count)];
    photoPickerViewController.pickerDelegate = self;
    [self.navigationController pushViewController:photoPickerViewController animated:YES];
}

-(void)photoPickerFinishSelected:(NSArray *)selectedArray{
    if (selectedArray.count > 0) {
        if (!ExistImageArr_) {
            ExistImageArr_  = [[NSMutableArray alloc] initWithCapacity:9];
        }
        [ExistImageArr_ addObjectsFromArray:selectedArray];
        //        SGPhoto *photo = selectedArray[0];
        //        self.imageBack(selectedArray);
        for (SGPhoto *sgImage in ExistImageArr_) {
            UIImage *image = sgImage.thumbnail;
            NSDictionary *dic = @{@"picture": image, @"type":@(UUMessageTypePicture)};
            [self dealTheFunctionData:dic];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        //将选择的照片储存起来，用于后面的点击查看详情
#pragma mark - 请求时候修改 进行上传
        //        [ImageArr addObject:@""];
        //        [CollectionV_ reloadData];
        //        NSArray *imgArr = @[portraitImg];
        NSDictionary *dic = @{@"picture": portraitImg, @"type":@(UUMessageTypePicture)};
        [self dealTheFunctionData:dic];
    }];
}

#pragma mark - Image Scale Utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < SCREEN_WIDTH * 2) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = SCREEN_WIDTH * 2;
        btWidth = sourceImage.size.width * (SCREEN_WIDTH * 2 / sourceImage.size.height);
    } else {
        btWidth = SCREEN_WIDTH * 2;
        btHeight = sourceImage.size.height * (SCREEN_WIDTH * 2 / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 数据
-(void)initDataSource{
}

#pragma mark - 移除该群组 会话列表未读count
-(void)changeChatListRemoveUnReadCount{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    NSString *firstKey = @"conversationId";
    NSString *firstValue = groupChatListName;
    NSString *secondKey = @"IsSingleChat";
    NSString *secondValue = @"0";
//    NSArray *arrds = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatEntity class] whereFormat:@""];
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",firstKey,firstValue,secondKey,secondValue]];
    }];
    if (arrs.count > 0) {
        //一般为一条数据
        MessageChatListEntity *chatListEntity = [arrs lastObject];
        //移除tabbar角标
        if (!chatListEntity.IsDisturb) {
            [[NFbaseViewController new] setBadgeCountWithCount:[chatListEntity.unread_message_count integerValue] AndIsAdd:NO];
        }
        chatListEntity.unread_message_count = @"0";
        [self.myManage changeFMDBData:chatListEntity KeyWordKey:firstKey KeyWordValue:firstValue FMDBID:@"tongxun.sqlite" secondKeyWordKey:secondKey secondKeyWordValue:secondValue TableName:@"huihualiebiao"];
    }
    
}



#pragma mark - tableViewDelegate & tableViewDateSource
//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = UIColorFromRGB(0xf2f9ff);
//    if (clickMoreIndexPath && indexPath.row == clickMoreIndexPath.row) {
//        [cell setSelected:YES animated:YES];
//    }
    //当cell快要显示的时候，看看是否需要设置成选中状态【需要add到删除数组再进行add】
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if (self.GroupChatTableView.editing) {
        cell.editing = YES;
        if (entity.message.IsSelected) {
            [cell setSelected:YES animated:YES];
            if (![needDeleteEntityArr containsObject:entity]) {//当数组里面没有该元素 再add
                [needDeleteEntityArr addObject:entity];
            }
            if (![needDeleteIndexPathArr containsObject:indexPath]) {//当数组里面没有该元素 再add
                [needDeleteIndexPathArr addObject:indexPath];
            }
        }else{
        }
    }
}

//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

//脚高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 18;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageFrame *messageFrame = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if (messageFrame.message.invitor.length > 0 || messageFrame.message.pulledMemberString.length > 0) {
        //当为谁邀请了谁  高度为30
        return 30;
    }
    else if (messageFrame.message.type == 3){
        //红包
        if (messageFrame.message.from == UUMessageFromMe) {
            return 100;
        }else{
            return 125;
        }
    }else if(messageFrame.message.type == 4){
        return 95;
    }
    //    messageFrame.showTime = YES;
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
//    NSLog(@"%f",[messageFrame cellHeight]);
    if (entity.message.from == UUMessageFromMe) {
        return [messageFrame cellHeight];
    }else if (entity.message.from == UUMessageFromOther){
        return [messageFrame cellHeight] + 20;
    }else if (entity.message.from == UUMessageFromInvite){
        return 25;
    }
    return [messageFrame cellHeight] + 20;
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 18)];
    [headerView addSubview:label];
    if (canRefresh) {
        label.text = @"下拉加载更多";
    }else{
        label.text = @"暂无更多记录";
    }
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontSectionHeader];
    return headerView;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //
    static NSString *cellIdentifier;
    __block UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if (indexPath.row >= self.dataArr.count - 3 && newMessageBottomButton.alpha == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            newMessageBottomButton.alpha = 0;//当滑到界面所有数据倒数第两三个数据 滑到底部的按钮设置隐藏
        }];
    }
//    NSLog(@"%@",entity.message.appMsgId);
    if (entity.message.appMsgId.length > 0) {
//        [self.cacheDataRowSendStatus setObject:entity.message.appMsgId forKey:[NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row]];
//        [self.cacheDataRowSendStatus setObject:[NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row] forKey:entity.message.appMsgId];
    }
    if (entity.message.invitor.length > 0) {
        //如果是拉人进群
        cellIdentifier = @"GroupShowInviteTableViewCell";
        GroupShowInviteTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupShowInviteTableViewCell" owner:nil options:nil]firstObject];
        }

        cell.ClickBtnn.hidden = YES;
        //拉了%@是进入群聊
        if ([entity.message.pullType isEqualToString:@"1"]) {
            //【扫的人】通过扫描【出示二维码的人】分享的二维码加入群聊
            cell.GroupShowMessageLabel.text = [NSString stringWithFormat:@"  %@通过扫描%@的分享的二维码加入群聊  ",entity.message.pulledMemberString,entity.message.invitor];
//            cell.GroupShowMessageLabel.text = [NSString stringWithFormat:@"  %@通过%@的二维码扫描进入群聊  ",entity.message.invitor,entity.message.pulledMemberString];
        }else if([entity.message.pullType isEqualToString:@"9"]){
            //系统通知
            
        }else if([entity.message.pullType isEqualToString:@"0"]){
            cell.GroupShowMessageLabel.text = [NSString stringWithFormat:@"  %@邀请了%@进入群聊  ",entity.message.invitor,entity.message.pulledMemberString];
        }else if([entity.message.pullType isEqualToString:@"3"]){
            cell.GroupShowMessageLabel.font = [UIFont systemFontOfSize:15];
            cell.GroupShowMessageLabel.text = [NSString stringWithFormat:@"  %@想邀请%@进入群聊 ，去确认 ",entity.message.invitor,entity.message.pulledMemberString];
            [cell.GroupShowMessageLabel addClickText:@"去确认" attributeds:@{NSForegroundColorAttributeName : UIColorFromRGB(0x2EBBF0)} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
                NSLog(@"");
            }];
            cell.ClickBtnn.hidden = NO;
            [cell.ClickBtnn obsersverEvents:(UIControlEventTouchUpInside) withBlock:^(id obj) {
                
                MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@想邀请%@进入群聊 ，请确认",entity.message.invitor,entity.message.pulledMemberString] sureBtn:@"同意" cancleBtn:@"拒绝"];
                alertView.resultIndex = ^(NSInteger index)
                {
                    if (index == 2) {
                        //同意
                        [socketRequest requestAcceptJoinGroupWithInfo:entity.message.fileId];
                    }else if(index == 1){
                        //拒绝
                        [socketRequest requestRefuseJoinGroupWithInfo:entity.message.fileId];
                    }
                };
                [alertView showMKPAlertView];
                
            }];
            
            
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (entity.message.type == UUMessageTypeRedRobRecord){
        cellIdentifier = @"GroupShowInviteTableViewCell";
        GroupShowInviteTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupShowInviteTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.GroupShowMessageLabel.text = entity.message.pulledMemberString;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (entity.message.type == UUMessageTypeSystem){
        cellIdentifier = @"GroupShowInviteTableViewCell";
        GroupShowInviteTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupShowInviteTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.GroupShowMessageLabel.text = entity.message.pulledMemberString;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (entity.message.type == UUMessageTypeRed){
        if (entity.message.from == UUMessageFromMe) {
            cellIdentifier = @"RedPacketTableViewCell";
            RedPacketTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RedPacketTableViewCell" owner:nil options:nil]firstObject];
            }
            //[cell.tapGesture addTarget:self action:@selector(clickRedImageMe:)];
            
            cell.messageFrame = entity;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRedImageMe:)];
            [cell.hbbackImageV addGestureRecognizer:tap];
            
            __weak typeof(self)weakSelf=self;
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            [cell returnDelete:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
                if (entity.message.cachePicPath.length > 0) {
                    if (entity.message.cachePicPath.length > 0) {
                        [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                    }
                }
                [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
                //        [self.dataArr removeObjectsAtIndexes:nil];
                [strongSelf.GroupChatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                //        [self.GroupChatTableView];
                [strongSelf.GroupChatTableView reloadData];
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if(entity.message.from == UUMessageFromOther){
            cellIdentifier = @"RedPacketOtherTableViewCell";
            RedPacketOtherTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RedPacketOtherTableViewCell" owner:nil options:nil]firstObject];
            }
//                [cell.RedClickOther addTarget:self action:@selector(clickRedImageOther:)];
            
            cell.messageFrame = entity;
            
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __weak typeof(self)weakSelf=self;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRedImageOther:)];
            [cell.hbbackImageV addGestureRecognizer:tap];
            
            [cell returnDelete:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
                if (entity.message.cachePicPath.length > 0) {
                    if (entity.message.cachePicPath.length > 0) {
                        [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                    }
                }
                [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
                //        [self.dataArr removeObjectsAtIndexes:nil];
                [strongSelf.GroupChatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                //        [self.GroupChatTableView];
                [strongSelf.GroupChatTableView reloadData];
            }];
            //长按对方头像。艾特某人
            [cell returnLong:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                NSMutableString *text = [NSMutableString stringWithString:strongSelf.IFView_.TextViewInput.text];
                [text appendString:[NSString stringWithFormat:@"@%@",entity.message.nickName]];
                strongSelf.IFView_.TextViewInput.text = text;
                
            }];
            
            [cell.headImageV afterClickHeadImage:^{
                if (!self.backBtn.userInteractionEnabled || self.GroupChatTableView.editing) {
                    //如果返回按钮不可点 则正在收取数据 或 tableview正在编辑中 不可操作
                    return;
                }
                
                __strong typeof(weakSelf)strongSelf=weakSelf;
                strongSelf ->selectedIndexPath = indexPath;
                [strongSelf showContactDetailWithUUmessageFrame:entity];
                return;

//                //看看是否是好友关系 是好友跳转到聊天，不是好友跳转到加好友界面
//                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//                __block NSMutableArray *contacts = [NSMutableArray new];
//                //这里重新去缓存联系人
//                __weak typeof(self)weakSelf=self;
//                [jqFmdb jq_inDatabase:^{
//                    __strong typeof(weakSelf)strongSelf=weakSelf;
//                    contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
//                }];
//                BOOL ISFriend = NO;
//                for (ZJContact *contactSearch in contacts) {
//                    if ([contactSearch.friend_userid isEqualToString:entity.message.userId]) {
//                        ISFriend  = YES;
//                        break;
//                    }
//                }
//                if(!ISFriend && ![self.groupCreateSEntity.groupSecret isEqualToString:@"1"]){
//                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
//                    toCtrol.addFriendId = entity.message.userId;
//                    toCtrol.addFriendName = entity.message.userName;
//                    toCtrol.headPicpath = entity.message.strIcon;
//                    [self.navigationController pushViewController:toCtrol animated:YES];
//                    return;
//                }else if(!ISFriend && ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.is_creator isEqualToString:@"1"])){
//                    //当为群主管理 群隐私打开的时候 可以直接跳转到添加好友界面
//                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
//                    toCtrol.addFriendId = entity.message.userId;
//                    toCtrol.addFriendName = entity.message.userName;
//                    toCtrol.headPicpath = entity.message.strIcon;
//                    [self.navigationController pushViewController:toCtrol animated:YES];
//                    return;
//                }
//                //请求群成员详情
//                [strongSelf->socketRequest requestPersonalInfoWithID:entity.message.userId];
//                strongSelf->selectedUUMessage = entity;
//                [strongSelf.IFView_.TextViewInput resignFirstResponder];
//                strongSelf ->selectedIndexPath = indexPath;
//                //ZJContactDetailController
//                strongSelf.GroupChatTableView.scrollEnabled = NO;
//                strongSelf.ZJContactDetailController.view  = nil;
//                strongSelf.ZJContactDetailController  = nil;
//                if (strongSelf.ZJContactDetailController == nil) {
//                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
//                    strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
//                    //设置单聊详情数据
//                    //            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
//                    ZJContact *contact = [ZJContact new];
//                    contact.friend_userid = entity.message.userId;
//                    contact.friend_username = entity.message.userName;
//                    contact.friend_nickname  = entity.message.nickName;
//                    contact.friend_originalnickname  = entity.message.originalNickName;
//                    if (![entity.message.nickName isEqualToString:entity.message.originalNickName]) {
//                        contact.friend_comment_name = entity.message.nickName;
//                    }
//                    contact.in_group_name  = entity.message.nickName?entity.message.nickName:entity.message.userName;
//                    contact.iconUrl = entity.message.strIcon;//头像
//                    //对于详情页面的赋值
//                    strongSelf.ZJContactDetailController.contant = contact;
//                    strongSelf.ZJContactDetailController.SourceFrom = @"1";
//                    [strongSelf addChildViewController:strongSelf.ZJContactDetailController];
//                    strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
//                    if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
//                        if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
//                            strongSelf.ZJContactDetailController.userNameLabel.hidden = YES;
//                            strongSelf.ZJContactDetailController.freeChatBtn.hidden = YES;
//                            strongSelf.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//                        }
//                    }
//                    //点击了headview上面的事件
//                    strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
//                        __strong typeof(weakSelf)strongSelf=weakSelf;
//                        if (index == 0 || index == 10) {
//                            //移除ZJContactDetailController
//                            [UIView animateWithDuration:0.2 animations:^{
//                                self.GroupChatTableView.scrollEnabled = YES;
//                                self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
//                            } completion:^(BOOL finished) {
//                                __strong typeof(weakSelf)strongSelf=weakSelf;
//                                [self.ZJContactDetailController.view removeFromSuperview];
//                                //当移除界面后 设置来自编辑名字为no
//                                isFromEditName = NO;
//                            }];
//                            strongSelf.navigationController.navigationBarHidden = NO;
//                        }else if (index == 1){
//
//                            [self showMoreClickWithContact:contact];
//
//
//
//
//
////                            //相册
////                            strongSelf ->isFromEditName = YES;
////                            SGPhoto *temp = [[SGPhoto alloc] init];
////                            temp.identifier = @"";
////                            temp.thumbnail = [UIImage imageNamed:@"图片"];
////                            temp.fullResolutionImage = [UIImage imageNamed:@"图片"];
////                            HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
////                            if (contact.iconUrl.length > 10) {
////                                showImageViewCtrol.imageUrlList = @[contact.iconUrl];
////                            }else{
////                                showImageViewCtrol.imageUrlList = @[temp];
////                            }
////                            showImageViewCtrol.mainImageIndex = 0;
////                            showImageViewCtrol.isLuoYang = YES;
////                            showImageViewCtrol.isNeedNavigation = NO;
////                            [strongSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
//                        }else if (index == 2){
//
//                        }
//                    };
//                    //如果点击了自己 则
//                    if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
//                        self.ZJContactDetailController.freeChatBtn.hidden = YES;
//                        self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//                    }
//                    //设置编辑名字、免费聊天
//                    //            [weakSelf.ZJContactDetailController.nameEditBtn addTarget:weakSelf action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
//                    [weakSelf.ZJContactDetailController.freeChatBtn addTarget:weakSelf action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
//                    //设置头像
//                    self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80/2, -65, 90, 90)];
//                    //            ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
//                    ViewRadius(self.ZJContactDetailController.nfHeadImageV, 3);
//                    [self.ZJContactDetailController.nfHeadImageV ShowHeadImageWithUrlStr:contact.iconUrl withUerId:nil completion:^(BOOL success, UIImage *image) {
//                    }];
//                    //点击头像后
//                    [self.ZJContactDetailController.nfHeadImageV afterClickHeadImage:^{
//                        [weakSelf.IFView_.TextViewInput resignFirstResponder];
//                        __strong typeof(weakSelf)strongSelf=weakSelf;
//                        strongSelf ->isFromEditName = YES;
//                        SGPhoto *temp = [[SGPhoto alloc] init];
//                        temp.identifier = @"";
//                        temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
//                        temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
//                        HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//                        if (contact.iconUrl.length > 10) {
//                            showImageViewCtrol.imageUrlList = @[contact.iconUrl];
//                        }else{
//                            showImageViewCtrol.imageUrlList = @[temp];
//                        }
//                        showImageViewCtrol.mainImageIndex = 0;
//                        showImageViewCtrol.isLuoYang = YES;
//                        showImageViewCtrol.isNeedNavigation = NO;
//                        [self.navigationController pushViewController:showImageViewCtrol animated:YES];
//                    }];
//                    [weakSelf.ZJContactDetailController.tableView addSubview:weakSelf.ZJContactDetailController.nfHeadImageV];
//                    [weakSelf.view addSubview:weakSelf.ZJContactDetailController.view];
//                    [UIView animateWithDuration:0.2 animations:^{
//                        self.navigationController.navigationBarHidden = YES;
//                        self.tabBarController.tabBar.hidden = YES;
//                        self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//                    } completion:^(BOOL finished) {
//                    }];
//                }
            }];
            
            
                //
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
        }
    }else if (entity.message.type == 4){
        if (entity.message.from == UUMessageFromMe) {
            //我的推荐好友
            cellIdentifier = @"RecommendFriendTableViewCell";
            RecommendFriendTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RecommendFriendTableViewCell" owner:nil options:nil]firstObject];
            }
            if(entity.message.fileId.length < 10){
                //说明 头像为空 在本地查联系人头像
                __weak typeof(self)weakSelf=self;
                __block NSMutableArray *contacts = [NSMutableArray new];
                //这里重新去缓存联系人
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    if (entity.message.strId.length > 0) {
                        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",entity.message.strId]];
                    }else if(entity.message.strVoiceTime.length > 0){
                        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_username = '%@'",entity.message.strVoiceTime]];
                    }
                }];
                if (contacts.count > 0) {
                    ZJContact *contttt = [contacts firstObject];
                    [cell.recommendheadV sd_setImageWithURL:[NSURL URLWithString:contttt.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
                }
            }else{
                [cell.recommendheadV sd_setImageWithURL:[NSURL URLWithString:entity.message.fileId] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
            }
            cell.titileNameLabel.text = entity.message.pictureUrl;
//            cell.nickNameLabel.text = entity.message.strVoiceTime;
            cell.nickNameLabel.text = @"";
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRecommendImage:)];
            [cell.clickBtn addGestureRecognizer:tap];
            
            //[cell.clickBtn addTarget:self action:@selector(clickRecommendImage:) forControlEvents:(UIControlEventTouchUpInside)];
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            //对方的推荐好友
            cellIdentifier = @"RecommendFridOtherTableViewCell";
            RecommendFridOtherTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RecommendFridOtherTableViewCell" owner:nil options:nil]firstObject];
            }
            [cell.recommendHeadImageV sd_setImageWithURL:[NSURL URLWithString:entity.message.fileId] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
            [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:entity.message.strIcon] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
            cell.titleNameLabel.text = entity.message.pictureUrl;
//            cell.nicknameLabel.text = entity.message.strVoiceTime;
            cell.nicknameLabel.text = @"";
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRecommendImage:)];
            [cell.clickBtn addGestureRecognizer:tap];
            
            __weak typeof(self)weakSelf=self;
            //为什么注释，因为之前在cell、中没有写 删除、长按头像方法
            [cell returnDelete:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
                if (entity.message.cachePicPath.length > 0) {
                    if (entity.message.cachePicPath.length > 0) {
                        [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                    }
                }
                [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
                //        [self.dataArr removeObjectsAtIndexes:nil];
                [strongSelf.GroupChatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                //        [self.GroupChatTableView];
                [strongSelf.GroupChatTableView reloadData];
            }];
            //长按对方头像。艾特某人
            [cell returnLong:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                NSMutableString *text = [NSMutableString stringWithString:strongSelf.IFView_.TextViewInput.text];
                [text appendString:[NSString stringWithFormat:@"@%@",entity.message.originalNickName]];
                strongSelf.IFView_.TextViewInput.text = text;

            }];
            [cell.headImageV afterClickHeadImage:^{
                if (!self.backBtn.userInteractionEnabled || self.GroupChatTableView.editing) {
                    //如果返回按钮不可点 则正在收取数据 或 tableview正在编辑中 不可操作
                    return;
                }
                
                __strong typeof(weakSelf)strongSelf=weakSelf;
                strongSelf ->selectedIndexPath = indexPath;
                [strongSelf showContactDetailWithUUmessageFrame:entity];
                return;
                
//                //看看是否是好友关系 是好友跳转到聊天，不是好友跳转到加好友界面
//                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//                __block NSMutableArray *contacts = [NSMutableArray new];
//                //这里重新去缓存联系人
//                __weak typeof(self)weakSelf=self;
//                [jqFmdb jq_inDatabase:^{
//                    __strong typeof(weakSelf)strongSelf=weakSelf;
//                    contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
//                }];
//                BOOL ISFriend = NO;
//                for (ZJContact *contactSearch in contacts) {
////                    NSLog(@"contactSearch user_name =%@",contactSearch.user_name);
////                    NSLog(@"contactSearch friend_userid=%@",contactSearch.friend_userid);
////                    NSLog(@"contactSearch friend_nickname=%@ ",contactSearch.friend_nickname);
//                    if ([[contactSearch.friend_userid description] isEqualToString:[entity.message.userId description]]) {
//                        ISFriend  = YES;
//                        break;
//                    }
//                }
//                if(!ISFriend && ![self.groupCreateSEntity.groupSecret isEqualToString:@"1"]){
//                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
//                    toCtrol.addFriendId = entity.message.userId;
//                    toCtrol.addFriendName = entity.message.userName;
//                    toCtrol.headPicpath = entity.message.strIcon;
//                    [self.navigationController pushViewController:toCtrol animated:YES];
//                    return;
//                }else if(!ISFriend && ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.is_creator isEqualToString:@"1"])){
//                    //当为群主管理 群隐私打开的时候 可以直接跳转到添加好友界面
//                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
//                    toCtrol.addFriendId = entity.message.userId;
//                    toCtrol.addFriendName = entity.message.userName;
//                    toCtrol.headPicpath = entity.message.strIcon;
//                    [self.navigationController pushViewController:toCtrol animated:YES];
//                    return;
//                }
////                __strong typeof(weakSelf)strongSelf=weakSelf;
//                //请求群成员详情
//                [strongSelf->socketRequest requestPersonalInfoWithID:entity.message.userId];
//                strongSelf->selectedUUMessage = entity;
//                [strongSelf.IFView_.TextViewInput resignFirstResponder];
//                strongSelf ->selectedIndexPath = indexPath;
//                //ZJContactDetailController
//                strongSelf.GroupChatTableView.scrollEnabled = NO;
//                strongSelf.ZJContactDetailController.view  = nil;
//                strongSelf.ZJContactDetailController  = nil;
//                if (strongSelf.ZJContactDetailController == nil) {
//                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
//                    strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
//                    //设置单聊详情数据
//                    //            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
//                    ZJContact *contact = [ZJContact new];
//                    contact.friend_userid = entity.message.userId;
//                    contact.friend_username = entity.message.userName;
//                    contact.friend_nickname  = entity.message.nickName;
//                    contact.friend_originalnickname  = entity.message.originalNickName;
//                    if (![entity.message.nickName isEqualToString:entity.message.originalNickName]) {
//                        contact.friend_comment_name = entity.message.nickName;
//                    }
//                    contact.in_group_name  = entity.message.nickName?entity.message.nickName:entity.message.userName;
//                    contact.iconUrl = entity.message.strIcon;//头像
//                    //对于详情页面的赋值
//                    strongSelf.ZJContactDetailController.contant = contact;
//                    strongSelf.ZJContactDetailController.SourceFrom = @"1";
//                    [strongSelf addChildViewController:strongSelf.ZJContactDetailController];
//                    strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
//                    if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
//                        if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
//                            strongSelf.ZJContactDetailController.userNameLabel.hidden = YES;
//                            strongSelf.ZJContactDetailController.freeChatBtn.hidden = YES;
//                            strongSelf.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//                        }
//                    }
//                    //点击了headview上面的事件
//                    strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
//                        __strong typeof(weakSelf)strongSelf=weakSelf;
//                        if (index == 0 || index == 10) {
//                            //移除ZJContactDetailController
//                            [UIView animateWithDuration:0.2 animations:^{
//                                self.GroupChatTableView.scrollEnabled = YES;
//                                self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
//                            } completion:^(BOOL finished) {
//                                __strong typeof(weakSelf)strongSelf=weakSelf;
//                                [self.ZJContactDetailController.view removeFromSuperview];
//                                //当移除界面后 设置来自编辑名字为no
//                                isFromEditName = NO;
//                            }];
//                            strongSelf.navigationController.navigationBarHidden = NO;
//                        }else if (index == 1){
//                            //相册
//                            strongSelf ->isFromEditName = YES;
//                            SGPhoto *temp = [[SGPhoto alloc] init];
//                            temp.identifier = @"";
//                            temp.thumbnail = [UIImage imageNamed:@"图片"];
//                            temp.fullResolutionImage = [UIImage imageNamed:@"图片"];
//                            HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//                            if (contact.iconUrl.length > 10) {
//                                showImageViewCtrol.imageUrlList = @[contact.iconUrl];
//                            }else{
//                                showImageViewCtrol.imageUrlList = @[temp];
//                            }
//                            showImageViewCtrol.mainImageIndex = 0;
//                            showImageViewCtrol.isLuoYang = YES;
//                            showImageViewCtrol.isNeedNavigation = NO;
//                            [strongSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
//                        }else if (index == 2){
//                        }
//                    };
//                    //如果点击了自己 则
//                    if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
//                        self.ZJContactDetailController.freeChatBtn.hidden = YES;
//                        self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//                    }
//                    //设置编辑名字、免费聊天
//                    //            [weakSelf.ZJContactDetailController.nameEditBtn addTarget:weakSelf action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
//                    [weakSelf.ZJContactDetailController.freeChatBtn addTarget:weakSelf action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
//                    //设置头像
//                    self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80/2, -65, 90, 90)];
//                    //            ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
//                    ViewRadius(self.ZJContactDetailController.nfHeadImageV, 3);
//                    [self.ZJContactDetailController.nfHeadImageV ShowHeadImageWithUrlStr:contact.iconUrl withUerId:nil completion:^(BOOL success, UIImage *image) {
//                    }];
//                    //点击头像后
//                    [self.ZJContactDetailController.nfHeadImageV afterClickHeadImage:^{
//                        [weakSelf.IFView_.TextViewInput resignFirstResponder];
//                        __strong typeof(weakSelf)strongSelf=weakSelf;
//                        strongSelf ->isFromEditName = YES;
//                        SGPhoto *temp = [[SGPhoto alloc] init];
//                        temp.identifier = @"";
//                        temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
//                        temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
//                        HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//                        if (contact.iconUrl.length > 10) {
//                            showImageViewCtrol.imageUrlList = @[contact.iconUrl];
//                        }else{
//                            showImageViewCtrol.imageUrlList = @[temp];
//                        }
//                        showImageViewCtrol.mainImageIndex = 0;
//                        showImageViewCtrol.isLuoYang = YES;
//                        showImageViewCtrol.isNeedNavigation = NO;
//                        [self.navigationController pushViewController:showImageViewCtrol animated:YES];
//                    }];
//                    [weakSelf.ZJContactDetailController.tableView addSubview:weakSelf.ZJContactDetailController.nfHeadImageV];
//                    [weakSelf.view addSubview:weakSelf.ZJContactDetailController.view];
//                    [UIView animateWithDuration:0.2 animations:^{
//                        self.navigationController.navigationBarHidden = YES;
//                        self.tabBarController.tabBar.hidden = YES;
//                        self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//                    } completion:^(BOOL finished) {
//                    }];
//                }
            }];
//            [cell.backImageV addGestureRecognizer:tap];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else if (entity.message.IsIsSystemPush){
        //系统消息
        cellIdentifier = @"GroupShowInviteTableViewCell";
        GroupShowInviteTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupShowInviteTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.GroupShowMessageLabel.text = entity.message.strContent.length > 0?entity.message.strContent:@" 管理员设置了全员禁言 ";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    //否则普通记录
    cellIdentifier = @"GroupMessageTableViewCell";
     GroupMessageTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        //崩溃
        cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupMessageTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.messageFrame = entity;
    cell.GroupId = groupMacroName;
//    if ([entity.message.failStatus isEqualToString:@"1"]) {
    //重新发送失败消息
        [cell.reSendBtn addTarget:self action:@selector(reSendBtnClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
//    }
    cell.meName = [NFUserEntity shareInstance].userName;
    cell.otherName = self.groupCreateSEntity.groupName;
    cell.selectedIndexPath = indexPath;
    cell.groupTableV = self.GroupChatTableView;
    cell.dataArr = self.dataArr;
    //groupMacroName
    cell.groupChatTableName = groupMacroName;
    cell.singleViewController = self;
    __weak typeof(self)weakSelf=self;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [cell returnDelete:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
        if (entity.message.cachePicPath.length > 0) {
            if (entity.message.cachePicPath.length > 0) {
                [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
            }
        }
        [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
//        [self.dataArr removeObjectsAtIndexes:nil];
        [strongSelf.GroupChatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        [self.GroupChatTableView];
        [strongSelf.GroupChatTableView reloadData];
    }];
    [cell returnDrow:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //撤回请求
        strongSelf ->drowMessageId = entity.message.chatId;
        strongSelf ->drowMessageIndexPath = indexPath;
        [strongSelf->socketRequest drowGroupRequest:entity.message];
    }];
    [cell returnRegisterResponder:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //放弃响应者
//        [self.IFView_.TextViewInput resignFirstResponder];
        //有更多菜单 隐藏更多菜单 先让输入框称为第一响应者，再让其放弃第一响应者 用已经存在的代码实现想要的界面效果。
        //当键盘或更多按钮界面 在显示时 让其收起键盘和更多界面
        if ([strongSelf.IFView_.TextViewInput isFirstResponder] || strongSelf.IFView_.btnSendMessage.selected) {
            [strongSelf.IFView_.TextViewInput becomeFirstResponder];
            [strongSelf.IFView_.TextViewInput resignFirstResponder];
        }
    }];
    //点击更多 批量删除
    [cell returnEdit:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [cell setSelected:YES animated:YES];
        strongSelf ->firstSelectDelete = YES;
        strongSelf ->clickMoreIndexPath = indexPath;
        entity.message.IsSelected = YES;
        [strongSelf tableView:tableView didSelectRowAtIndexPath:indexPath];
        strongSelf.navigationItem.rightBarButtonItem.customView.hidden =YES;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 40, 30);
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(cancelEditClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: button];
        strongSelf.navigationItem.leftBarButtonItem = item;
        strongSelf.IFView_.hidden = YES;
        [strongSelf.view addSubview:strongSelf->bottomEditView];
    }];
    //点击群成员头像
    [cell.youImageView afterClickHeadImage:^{
        if (!self.backBtn.userInteractionEnabled || self.GroupChatTableView.editing) {
            //如果返回按钮不可点 则正在收取数据 或 tableview正在编辑中 不可操作
            return;
        }
        

        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf ->selectedIndexPath = indexPath;
        [strongSelf showContactDetailWithUUmessageFrame:entity];
        return;
        
        
//        //看看是否是好友关系 是好友跳转到聊天，不是好友跳转到加好友界面
//        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//        __block NSMutableArray *contacts = [NSMutableArray new];
//        //这里重新去缓存联系人
//        __weak typeof(self)weakSelf=self;
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",entity.message.userId]];
//        }];
//        BOOL ISFriend = NO;
//        if (contacts.count > 0) {
//            ISFriend = YES;
//        }
////        for (ZJContact *contactSearch in contacts) {
////            if ([[contactSearch.friend_userid description] isEqualToString:[entity.message.userId description]]) {
////                ISFriend  = YES;
////                break;
////            }
////        }
//        if(!ISFriend && ![self.groupCreateSEntity.groupSecret isEqualToString:@"1"]){
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//            AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
//            toCtrol.addFriendId = entity.message.userId;
//            toCtrol.addFriendName = entity.message.userName;
//            toCtrol.headPicpath = entity.message.strIcon;
//            [self.navigationController pushViewController:toCtrol animated:YES];
//            return;
//        }else if(!ISFriend && ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.is_creator isEqualToString:@"1"])){
//            //当为群主管理 群隐私打开的时候 可以直接跳转到添加好友界面
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//            AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
//            toCtrol.addFriendId = entity.message.userId;
//            toCtrol.addFriendName = entity.message.userName;
//            toCtrol.headPicpath = entity.message.strIcon;
//            [self.navigationController pushViewController:toCtrol animated:YES];
//            return;
//        }
//
//        __strong typeof(weakSelf)strongSelf=weakSelf;
//        //请求群成员详情
//        [strongSelf->socketRequest requestPersonalInfoWithID:entity.message.userId];
//        strongSelf->selectedUUMessage = entity;
//        [strongSelf.IFView_.TextViewInput resignFirstResponder];
//        strongSelf ->selectedIndexPath = indexPath;
//        //ZJContactDetailController
//        strongSelf.GroupChatTableView.scrollEnabled = NO;
//        strongSelf.ZJContactDetailController.view  = nil;
//        strongSelf.ZJContactDetailController  = nil;
//        if (strongSelf.ZJContactDetailController == nil) {
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
//            strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
//            //设置单聊详情数据
////            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
//            ZJContact *contact = [ZJContact new];
//            contact.friend_userid = entity.message.userId;
//            contact.friend_username = entity.message.userName;
//            contact.friend_nickname  = entity.message.nickName;
//            contact.friend_originalnickname  = entity.message.originalNickName;
//            if (![entity.message.nickName isEqualToString:entity.message.originalNickName]) {
//                contact.friend_comment_name = entity.message.nickName;
//            }
//            contact.in_group_name  = entity.message.nickName?entity.message.nickName:entity.message.userName;
//            contact.iconUrl = entity.message.strIcon;//头像
//            //对于详情页面的赋值
//            strongSelf.ZJContactDetailController.contant = contact;
//            strongSelf.ZJContactDetailController.SourceFrom = @"1";
//            [strongSelf addChildViewController:strongSelf.ZJContactDetailController];
//            strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
//            if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
//                if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
//                    strongSelf.ZJContactDetailController.userNameLabel.hidden = YES;
//                    strongSelf.ZJContactDetailController.freeChatBtn.hidden = YES;
//                    strongSelf.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//                }
//            }
//            //点击了headview上面的事件
//            strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
//                __strong typeof(weakSelf)strongSelf=weakSelf;
//                if (index == 0 || index == 10) {
//                    //移除ZJContactDetailController
//                    [UIView animateWithDuration:0.2 animations:^{
//                        self.GroupChatTableView.scrollEnabled = YES;
//                        self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
//                    } completion:^(BOOL finished) {
//                        __strong typeof(weakSelf)strongSelf=weakSelf;
//                        [self.ZJContactDetailController.view removeFromSuperview];
//                        //当移除界面后 设置来自编辑名字为no
//                        isFromEditName = NO;
//                    }];
//                    strongSelf.navigationController.navigationBarHidden = NO;
//                }else if (index == 1){
//                    //相册
//                    strongSelf ->isFromEditName = YES;
//                    SGPhoto *temp = [[SGPhoto alloc] init];
//                    temp.identifier = @"";
//                    temp.thumbnail = [UIImage imageNamed:@"图片"];
//                    temp.fullResolutionImage = [UIImage imageNamed:@"图片"];
//                    HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//                    if (contact.iconUrl.length > 10) {
//                        showImageViewCtrol.imageUrlList = @[contact.iconUrl];
//                    }else{
//                        showImageViewCtrol.imageUrlList = @[temp];
//                    }
//                    showImageViewCtrol.mainImageIndex = 0;
//                    showImageViewCtrol.isLuoYang = YES;
//                    showImageViewCtrol.isNeedNavigation = NO;
//                    [strongSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
//                }else if (index == 2){
//                }
//            };
//            //如果点击了自己 则
//            if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
//                self.ZJContactDetailController.freeChatBtn.hidden = YES;
//                self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//            }
//            //设置编辑名字、免费聊天
////            [weakSelf.ZJContactDetailController.nameEditBtn addTarget:weakSelf action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
//            [weakSelf.ZJContactDetailController.freeChatBtn addTarget:weakSelf action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
//            //设置头像
//            self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80/2, -65, 90, 90)];
////            ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
//            ViewRadius(self.ZJContactDetailController.nfHeadImageV, 3);
//            [self.ZJContactDetailController.nfHeadImageV ShowHeadImageWithUrlStr:contact.iconUrl withUerId:nil completion:^(BOOL success, UIImage *image) {
//            }];
//            //点击头像后
//            [self.ZJContactDetailController.nfHeadImageV afterClickHeadImage:^{
//                [weakSelf.IFView_.TextViewInput resignFirstResponder];
//                __strong typeof(weakSelf)strongSelf=weakSelf;
//                strongSelf ->isFromEditName = YES;
//                SGPhoto *temp = [[SGPhoto alloc] init];
//                temp.identifier = @"";
//                temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
//                temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
//                HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//                if (contact.iconUrl.length > 10) {
//                    showImageViewCtrol.imageUrlList = @[contact.iconUrl];
//                }else{
//                    showImageViewCtrol.imageUrlList = @[temp];
//                }
//                showImageViewCtrol.mainImageIndex = 0;
//                showImageViewCtrol.isLuoYang = YES;
//                showImageViewCtrol.isNeedNavigation = NO;
//                [self.navigationController pushViewController:showImageViewCtrol animated:YES];
//            }];
//            [weakSelf.ZJContactDetailController.tableView addSubview:weakSelf.ZJContactDetailController.nfHeadImageV];
//            [weakSelf.view addSubview:weakSelf.ZJContactDetailController.view];
//            [UIView animateWithDuration:0.2 animations:^{
//                self.navigationController.navigationBarHidden = YES;
//                self.tabBarController.tabBar.hidden = YES;
//                self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//            } completion:^(BOOL finished) {
//            }];
//        }
    }];
    //长按对方头像。艾特某人
    [cell returnLong:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        NSMutableString *text = [NSMutableString stringWithString:strongSelf.IFView_.TextViewInput.text];
        [text appendString:[NSString stringWithFormat:@"@%@",entity.message.originalNickName.length>0?entity.message.originalNickName:entity.message.nickName]];
        strongSelf.IFView_.TextViewInput.text = text;
        
    }];
//    if (self.GroupChatTableView.editing) {
////        cell.editing = YES;
//        if (entity.message.IsSelected) {
//            [cell setSelected:YES animated:YES];
//            if (![needDeleteEntityArr containsObject:entity]) {//当数组里面没有该元素 再add
//                [needDeleteEntityArr addObject:entity];
//            }
//            if (![needDeleteIndexPathArr containsObject:indexPath]) {//当数组里面没有该元素 再add
//                [needDeleteIndexPathArr addObject:indexPath];
//            }
//        }else{
//        }
//    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.separatorInset =UIEdgeInsetsMake(0,0, 0, cell.bounds.size.width-15);
    return cell;
}

#pragma mark - 发送前检查
-(BOOL)beforeSendMessageCheck{
//    if (![ClearManager getNetStatus]) {
//        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
//        return NO;
//    }
//    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
//        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
//        return NO;
//    }
    if (!self.isCanSendMessage) {
        //如果不能发送 则提示
        [SVProgressHUD showInfoWithStatus:@"连接中请稍后发送"];
        return NO;
    }
    if (!self.backBtn.userInteractionEnabled) {
        [SVProgressHUD showInfoWithStatus:@"收取中请稍后发送"];
        return NO;
    }
    return YES;
}

#pragma mark - 重新发送，发送失败的消息
- (void)reSendBtnClick:(UIButton *)button event:(UIEvent *)event
{
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        [self.IFView_.TextViewInput resignFirstResponder];
    }
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.GroupChatTableView];
//    NSIndexPath *indexPath = [self.GroupChatTableView indexPathForRowAtPoint:currentTouchPosition];
    //根据cell中的button 获取到cell的indexpath
    GroupMessageTableViewCell *groupMessageCell = (GroupMessageTableViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [self.GroupChatTableView indexPathForCell:groupMessageCell];
    //重新发送消息
    UUMessageFrame *reSendEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    
    __weak typeof(self)weakSelf=self;
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"重新发送", nil] btnClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if (reSendEntity.message.type == UUMessageTypePicture) {
                //从数据库删除这条消息
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                UUMessageFrame *needDeleteEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;//根据记录的重新发送的indexpath。取到appMsgId删除数据库的数据
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where appMsgId = '%@'",needDeleteEntity.message.appMsgId]];
                    NSLog(@"重新发送 删除感叹号那条消息");
                }];
                [self.dataArr removeObjectAtIndex:indexPath.row];
                [self.GroupChatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                //发送图片之前先缓存
                NSDictionary *dic = @{@"appMsgId":reSendEntity.message.appMsgId,@"chatId":@"",@"strContent":@"[图片]",@"type":@"1",@"userName":[NFUserEntity shareInstance].userName,@"nickName":[NFUserEntity shareInstance].nickName,@"imgRatio":[NSString stringWithFormat:@"%.2f",reSendEntity.message.pictureScale],@"fileId":reSendEntity.message.fileId};
                [self addSpecifiedItemToGroup:reSendEntity AndDict:dic];
                
            }else if (reSendEntity.message.type == UUMessageTypeText){
                NSDictionary *dic = @{@"strContent": reSendEntity.message.strContent, @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": AppMessageId};
                //从数据库删除这条消息
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                UUMessageFrame *needDeleteEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;//根据记录的重新发送的indexpath。取到appMsgId删除数据库的数据
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where appMsgId = '%@'",needDeleteEntity.message.appMsgId]];
                    NSLog(@"重新发送 删除感叹号那条消息");
                }];
                [self.dataArr removeObjectAtIndex:indexPath.row];
                [self.GroupChatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                [weakSelf dealTheFunctionData:dic];
            }else if (reSendEntity.message.type == UUMessageTypeVoice){
                //从数据库删除这条消息
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                UUMessageFrame *needDeleteEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;//根据记录的重新发送的indexpath。取到appMsgId删除数据库的数据
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where appMsgId = '%@'",needDeleteEntity.message.appMsgId]];
                    NSLog(@"重新发送 删除感叹号那条消息");
                }];
                [self.dataArr removeObjectAtIndex:indexPath.row];
                [self.GroupChatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                
                NSDictionary *dic = @{@"voice": reSendEntity.message.voice, @"strVoiceTime":reSendEntity.message.strVoiceTime, @"type":@(UUMessageTypeVoice),@"appMsgId": reSendEntity.message.appMsgId};
                [self dealTheFunctionData:dic];
                //发送图片时候 超时计算取消
                [NFUserEntity shareInstance].timeOutCountBegin = NO;
                
            }
        }
    }];
    [sheet show];
    
}

#pragma mark - 发送消息后展示、缓存 【只能是群聊】
- (void)addSpecifiedItemToGroup:(UUMessageFrame *)reSendEntity AndDict:(NSDictionary *)dic
{
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    ZJContact *contant = [ZJContact new];
    contant.friend_username = self.groupCreateSEntity.groupName;
    contant.groupId = self.groupCreateSEntity.groupId;
    
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    //头像
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    URLStr = @"";
    [dataDic setObject:@1 forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
    if ([dic objectForKey:@"userName"]) {
        [dataDic setObject:[dic objectForKey:@"userName"] forKey:@"userName"];
    }
    if ([dic objectForKey:@"strIcon"]) {
        [dataDic setObject:URLStr forKey:@"strIcon"];
    }
    //设置消息内容数据
    [message setWithDict:dataDic];
    if (message.type == UUMessageTypePicture) {
        
        NSDictionary *dic = @{@"appMsgId":reSendEntity.message.appMsgId,@"chatId":@"",@"strContent":@"[图片]",@"type":@"1",@"userName":[NFUserEntity shareInstance].userName,@"nickName":[NFUserEntity shareInstance].nickName,@"imgRatio":[NSString stringWithFormat:@"%.2f",reSendEntity.message.pictureScale],@"fileId":reSendEntity.message.fileId};
        
        message.pictureUrl = reSendEntity.message.pictureUrl;
        message.pictureScale = reSendEntity.message.pictureScale;
        message.fileId = reSendEntity.message.fileId;
    }
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    message.localReceiveTime = interval;
    NSInteger time = interval;
    message.localReceiveTimeString = [NSString stringWithFormat:@"%ld",time];
    message.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
    if (![confromTimesp isThisYear]) {
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"YYYY年MM月dd日"];
    }else{
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"MM月dd日"];
    }
    message.chatId = dataDic[@"chatId"];
    //将此时的实体与上一个实体做比较，看时间是否超过三分钟，如果超过三分钟则展示时间
    //    messageFrame.showTime = message.showDateLabel;
    //    messageFrame.showTime = YES;
    [messageFrame setMessage:message];
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    
    //缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    entity.IsSingleChat = YES;
    entity.appMsgId = messageFrame.message.appMsgId;//客户端本地数据库 缓存id【用于取服务器返回的chatid】
    //缓存消息到群聊历史
    __weak typeof(self)weakSelf=self;
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",contant.groupId]];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",contant.groupId] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
    }];
    //重复消息
    if(lastArr.count == 1){
        MessageChatEntity *lastEntity = [lastArr firstObject];
        if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
            //如果有相同消息 则return
            return;
        }
    }
    
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",contant.groupId] dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            return;
        }
    }];
    
    //后add 到界面刷新
    [self.dataArr addObject:messageFrame];
    [self.GroupChatTableView reloadData];//刷新数据
    //滑到底部
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight ;
    }else{
        showHeight = self.IFView_.btnSendMessage.selected | !self.IFView_.addFaceView.hidden?SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50):SCREEN_HEIGHT;
    }
    if (self.GroupChatTableView.contentSize.height > showHeight - 64 - 50) {
        [self tableViewScrollToBottomOffSet:-64-50 IsStrongToBottom:YES];
    }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
        [self tableViewScrollToBottomOffSet:20 IsStrongToBottom:YES];
    }
    
    
}

//当tableview进入编辑状态，是否允许进入编辑状态。
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
//    IsInEditing = YES;
    //当为系统通知 比如 某人拉某人进群，该消息不能够进行编辑
    if (entity.message.invitor.length > 0) {
        return NO;
    }
    return YES;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    NSArray *subviews = [[tableView cellForRowAtIndexPath:indexPath] subviews];
    GroupMessageTableViewCell  * cell = (GroupMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    for (id obj in subviews) {
        if ([obj isKindOfClass:[UIControl class]]) {
            for (id subview in [obj subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageV = subview;
                    //                    imageV.backgroundColor = [UIColor yellowColor];
                    imageV.tintColor = [UIColor clearColor];
                    //                    cell.selected = !cell.selected;
                    if (cell.isSelected) {
                        imageV.image=[UIImage imageNamed:@"CellButtonSelected"];
                        entity.message.IsSelected = YES;
                        //添加到待删除数组中
                        if (![needDeleteEntityArr containsObject:entity]) {//当数组里面没有该元素 再add
                            [needDeleteEntityArr addObject:entity];
                        }
                        if (![needDeleteIndexPathArr containsObject:indexPath]) {//当数组里面没有该元素 再add
                            [needDeleteIndexPathArr addObject:indexPath];
                        }
                    }else{
                        imageV.image=[UIImage imageNamed:@"CellButton"];
                        entity.message.IsSelected = NO;
                        [needDeleteEntityArr removeObject:entity];
                        [needDeleteIndexPathArr removeObject:indexPath];
                    }
                    break;
                }
            }
        }
    }
}


#pragma mark - 拆红包 或者查看详情 领红包
-(void)clickRedImageMe:(UITapGestureRecognizer *)recognizer{
    
//    if (![NFUserEntity shareInstance].clientId || [[NFUserEntity shareInstance].clientId containsString:@"null"] || [NFUserEntity shareInstance].clientId.length == 0 ) {
//        [SVProgressHUD showInfoWithStatus:@"请先开户"];
//        return;
//    }
    
    //点击的时候根据红包实体进行请求
    CGPoint point = [recognizer locationInView:self.GroupChatTableView];
    NSIndexPath *indexPath = [self.GroupChatTableView indexPathForRowAtPoint:point];
    //    NSLog(@"%ld",indexPath.section);
    UUMessageFrame *messageF = self.dataArr[indexPath.row];
    [MessageChatEntity new];
    
    MessageChatEntity *chatEntity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageF];
    chatEntity.redIsTouched = @"1";
    __weak typeof(self)weakSelf=self;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:groupMacroName dicOrModel:chatEntity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
    
    //拆红包 如果拆过 后面处理跳转到详情
    [SVProgressHUD show];
    [[NTESRedPacketManager sharedManager] openRedPacket:messageF.message.redpacketString from:@{@"name":messageF.message.nickName,@"headurl":messageF.message.strIcon} session:self.conversationId];
    
    
    [NFUserEntity shareInstance].currentChatId = @"";
    [NFUserEntity shareInstance].isSingleChat = @"0";
    
    
//    if (messageF.message.type == UUMessageTypeRed && [messageF.message.pictureUrl isEqualToString:@""]) {
//        return;
//    }
    
    
    //红包详情
    //RedDetailViewController
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//    RedDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RedDetailTableViewController"];
//    toCtrol.redMessage = messageF;
//    [self.navigationController pushViewController:toCtrol animated:YES];
    
}


#pragma mark - 拆红包 或者查看详情  领红包
-(void)clickRedImageOther:(UITapGestureRecognizer *)recognizer{
    //点击的时候根据红包实体进行请求
    CGPoint point = [recognizer locationInView:self.GroupChatTableView];
    NSIndexPath *indexPath = [self.GroupChatTableView indexPathForRowAtPoint:point];
    //    NSLog(@"%ld",indexPath.section);
    UUMessageFrame *messageF = self.dataArr[indexPath.row];
    messageF.message.redIsTouched = @"1";
    MessageChatEntity *chatEntity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageF];
    __weak typeof(self)weakSelf=self;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:groupMacroName dicOrModel:chatEntity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
    
    RedPacketOtherTableViewCell  * cell = [self.GroupChatTableView cellForRowAtIndexPath:indexPath];
    [cell.hbbackImageV setHighlighted:YES];
    
    //拆红包
    [SVProgressHUD show];
    [[NTESRedPacketManager sharedManager] openRedPacket:messageF.message.redpacketString from:@{@"name":messageF.message.nickName,@"headurl":messageF.message.strIcon} session:self.conversationId];
    
    
    [NFUserEntity shareInstance].currentChatId = @"";
    [NFUserEntity shareInstance].isSingleChat = @"0";
    
    
    if (messageF.message.type == UUMessageTypeRed && [messageF.message.pictureUrl isEqualToString:@""]) {
        
        return;
    }
    return;
    
    
    
    //红包详情
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    RedDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RedDetailTableViewController"];
    toCtrol.redMessage = messageF;
    [self.navigationController pushViewController:toCtrol animated:YES];
    
    
}


#pragma mark - 点击推荐好友 我的
-(void)clickRecommendImage:(UITapGestureRecognizer *)recognizer{
    
    CGPoint point = [recognizer locationInView:self.GroupChatTableView];
    NSIndexPath *indexPath = [self.GroupChatTableView indexPathForRowAtPoint:point];
    //    NSLog(@"%ld",indexPath.section);
    UUMessageFrame *messageF = self.dataArr[indexPath.row];
    //跳转到详情
    
    if (!self.backBtn.userInteractionEnabled || self.GroupChatTableView.editing) {
        //如果返回按钮不可点 则正在收取数据 或 tableview正在编辑中 不可操作
        return;
    }
    selectedUUMessage = messageF;
    [self.IFView_.TextViewInput resignFirstResponder];
    selectedIndexPath = indexPath;
    //ZJContactDetailController
    
    //跳转到详情
    ZJContact *contact = [ZJContact new];
    contact.friend_userid = messageF.message.strId;
    contact.friend_username = messageF.message.strVoiceTime;
    contact.friend_nickname  = messageF.message.pictureUrl;
    contact.in_group_name  = messageF.message.pictureUrl?messageF.message.pictureUrl:messageF.message.strVoiceTime;
    contact.iconUrl = messageF.message.fileId;//头像
    
    
    UIStoryboard * sbb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    SingleChatDetailTableViewController *toCtrolll = [sbb instantiateViewControllerWithIdentifier:@"SingleChatDetailTableViewController"];
    //singleEntity
    //        toCtrol.singleEntity = self.singleEntity;
    toCtrolll.singleContactEntity = contact;
    toCtrolll.conversationId = contact.friend_userid;
    toCtrolll.IsFromCard = YES;
    [self.navigationController pushViewController:toCtrolll animated:YES];
    
    
    
}

#pragma mark - 点击推荐好友 对方的
-(void)clickRecommendImageOther:(UITapGestureRecognizer *)recognizer{
    
    CGPoint point = [recognizer locationInView:self.GroupChatTableView];
    NSIndexPath *indexPath = [self.GroupChatTableView indexPathForRowAtPoint:point];
    //    NSLog(@"%ld",indexPath.section);
    UUMessageFrame *messageF = self.dataArr[indexPath.row];
    //跳转到详情
    
}


//用gestureRecognizer 方法将didDeselectRowAtIndexPath逻辑替换掉
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    entity.message.IsSelected = NO;
    //移除选中的
    [needDeleteEntityArr removeObject:entity];
    [needDeleteIndexPathArr removeObject:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //于十月九日收到亚特兰郡110钥匙。
    //返还押金5000元，综合扣除水电费用共计三千余元
//    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    return indexPath;
    
}

//不执行
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleNone;
//}

#pragma mark - 取消编辑 编辑取消
-(void)cancelEditClick{
    [self.GroupChatTableView setEditing:NO animated:YES];
    for (NSIndexPath *indexpath in needDeleteIndexPathArr) {
        UUMessageFrame *UMessage = self.dataArr.count>indexpath.row?self.dataArr[indexpath.row]:nil;
        UMessage.message.IsSelected = NO;//设置数据选中状态为NO
        MessageTableViewCell  * cell = (MessageTableViewCell *)[self.GroupChatTableView cellForRowAtIndexPath:indexpath];
        [cell setSelected:NO animated:YES];
    }
    //显示输入框
    self.IFView_.hidden = NO;
    [bottomEditView removeFromSuperview];
    needDeleteEntityArr = [[NSMutableArray alloc] initWithCapacity:2];
    needDeleteIndexPathArr = [[NSMutableArray alloc] initWithCapacity:2];
    
    self.navigationItem.rightBarButtonItem.customView.hidden =NO;
    
//    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
//    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
////    backBtn.timeInterval = 2;
//    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
//    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    if (self.unreadAllCount == 0) {
        self.navigationItem.leftBarButtonItems = @[leftBackBtnItem];
    }else{
        self.navigationItem.leftBarButtonItems = @[leftBackBtnItem,leftCountBtnItem];
    }
    
    //    self.singleViewController.navigationItem.rightBarButtonItem
    
}

#pragma mark - 点击群成员详情 右上角更多按钮
-(void)showMoreClickWithContact:(ZJContact *)contact{
    if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
        if ([contact.is_creator isEqualToString:@"1"]) {
//            self.groupClick(indexPath);
            //[self showContactDetailWithZJContact:contact];
            [SVProgressHUD showInfoWithStatus:@"您不能对自己进行操作"];
        }else if ([contact.is_admin isEqualToString:@"1"]){
            LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"转让群主",@"取消管理员",@"加好友",@"踢出群聊", nil] btnClickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 999) {
                    return ;
                }else if(buttonIndex == 0){
//                    self.groupClick(indexPath);
//                    [self showContactDetailWithZJContact:contact];
                    //转让群主

                    //转让群主
                    //groupZhuanrang
                    SocketRequest *socketRequest = [SocketRequest share];
                    [socketRequest groupZhuanrang:contact.friend_userid groupId:self.groupCreateSEntity.groupId];
//                    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"您确定转让群主么？" sureBtn:@"确认" cancleBtn:@"取消"];
//                    alertView.resultIndex = ^(NSInteger index)
//                    {
//                        if(index == 2){
//
//                            //转让群主
//                            //groupZhuanrang
//                            SocketRequest *socketRequest = [SocketRequest share];
//                            [socketRequest groupZhuanrang:contact.friend_userid groupId:self.groupCreateSEntity.groupId];
//                        }
//                    };
//                    [alertView showMKPAlertView];
                }else if(buttonIndex == 1){

                    SocketRequest *socketRequest = [SocketRequest share];
                    [socketRequest manageGroup:NO GroupId:self.groupCreateSEntity.groupId AndContact:contact];
//                    contact.is_admin = @"0";
//                    [GroupChatDetailTableV reloadItemsAtIndexPaths:@[indexPath]];
                    
                }else if(buttonIndex == 2){
                    //移除ZJContactDetailController
                    __weak typeof(self)weakSelf=self;
                    [UIView animateWithDuration:0.2 animations:^{
                        self.GroupChatTableView.scrollEnabled = YES;
                        self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                    } completion:^(BOOL finished) {
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        [self.ZJContactDetailController.view removeFromSuperview];
                        //当移除界面后 设置来自编辑名字为no
                        isFromEditName = NO;
                    }];
                    weakSelf.navigationController.navigationBarHidden = NO;
                    
                    //加好友
                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                    toCtrol.addFriendId = contact.friend_userid;
                    toCtrol.addFriendName = contact.friend_username;
                    toCtrol.headPicpath = contact.iconUrl;
                    [self.navigationController pushViewController:toCtrol animated:YES];
                }else if (buttonIndex == 3){
                    //踢人
                    if(!self.groupCreateSEntity.groupId || self.groupCreateSEntity.groupId.length == 0){
                        [SVProgressHUD showInfoWithStatus:@"错误10001"];
                        return;
                    }
                    [socketRequest groupOwnerOutMember:@[@{@"dropId":contact.friend_userid,@"dropName":contact.friend_username}] GroupId:self.groupCreateSEntity.groupId];
                }
            }];
            [sheet show];
        }else{
            LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"转让群主",@"设置管理员",@"取消管理员",@"加好友",@"踢出群聊", nil] btnClickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 999) {
                    return ;
                }else if(buttonIndex == 0){
//                    self.groupClick(indexPath);
                    //[self showContactDetailWithZJContact:contact];

                    //转让群主
                    //groupZhuanrang
                    SocketRequest *socketRequest = [SocketRequest share];
                    [socketRequest groupZhuanrang:contact.friend_userid groupId:self.groupCreateSEntity.groupId];
//                    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"您确定转让群主么？" sureBtn:@"确认" cancleBtn:@"取消"];
//                    alertView.resultIndex = ^(NSInteger index)
//                    {
//                        if(index == 2){
//
//                            //转让群主
//                            //groupZhuanrang
//                            SocketRequest *socketRequest = [SocketRequest share];
//                            [socketRequest groupZhuanrang:contact.friend_userid groupId:self.groupCreateSEntity.groupId];
//                        }
//                    };
//                    [alertView showMKPAlertView];
                }else if(buttonIndex == 1){
                    
                    SocketRequest *socketRequest = [SocketRequest share];
                    [socketRequest manageGroup:YES GroupId:self.groupCreateSEntity.groupId AndContact:contact];
//                    contact.is_admin = @"1";
//                    [GroupChatDetailTableV reloadItemsAtIndexPaths:@[indexPath]];
                }else if(buttonIndex == 2){
                    //取消管理员
                    SocketRequest *socketRequest = [SocketRequest share];
                    [socketRequest manageGroup:NO GroupId:self.groupCreateSEntity.groupId AndContact:contact];
                }else if (buttonIndex == 3){
                    //加好友
                    //移除ZJContactDetailController
                    __weak typeof(self)weakSelf=self;
                    [UIView animateWithDuration:0.2 animations:^{
                        self.GroupChatTableView.scrollEnabled = YES;
                        
                        self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                    } completion:^(BOOL finished) {
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        [self.ZJContactDetailController.view removeFromSuperview];
                        //当移除界面后 设置来自编辑名字为no
                        isFromEditName = NO;
                    }];
                    weakSelf.navigationController.navigationBarHidden = NO;
                    
                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                    toCtrol.addFriendId = contact.friend_userid;
                    toCtrol.addFriendName = contact.friend_username;
                    toCtrol.headPicpath = contact.iconUrl;
                    [self.navigationController pushViewController:toCtrol animated:YES];
                }else if (buttonIndex == 4){
                    //踢人
                    if(!self.groupCreateSEntity.groupId || self.groupCreateSEntity.groupId.length == 0){
                        [SVProgressHUD showInfoWithStatus:@"错误10001"];
                        return;
                    }
                    [socketRequest groupOwnerOutMember:@[@{@"dropId":contact.friend_userid,@"dropName":contact.friend_username}] GroupId:self.groupCreateSEntity.groupId];
                }
            }];
            [sheet show];
        }
    }else if ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.groupSecret isEqualToString:@"0"]){
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"加好友",@"踢出群聊", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 999) {
                return ;
            }else if(buttonIndex == 0){
//                self.groupClick(indexPath);
                //[self showContactDetailWithZJContact:contact];

                //移除ZJContactDetailController
                __weak typeof(self)weakSelf=self;
                [UIView animateWithDuration:0.2 animations:^{
                    self.GroupChatTableView.scrollEnabled = YES;
                    self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    [self.ZJContactDetailController.view removeFromSuperview];
                    //当移除界面后 设置来自编辑名字为no
                    isFromEditName = NO;
                }];
                weakSelf.navigationController.navigationBarHidden = NO;
                
                //加好友
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                toCtrol.addFriendId = contact.friend_userid;
                toCtrol.addFriendName = contact.friend_username;
                toCtrol.headPicpath = contact.iconUrl;
                [self.navigationController pushViewController:toCtrol animated:YES];
            }else if(buttonIndex == 1){
                //踢人
                if(!self.groupCreateSEntity.groupId || self.groupCreateSEntity.groupId.length == 0){
                    [SVProgressHUD showInfoWithStatus:@"错误10001"];
                    return;
                }
                [socketRequest groupOwnerOutMember:@[@{@"dropId":contact.friend_userid,@"dropName":contact.friend_username}] GroupId:self.groupCreateSEntity.groupId];
            }
        }];
        [sheet show];
    }
    else{

        [SVProgressHUD showInfoWithStatus:@"抱歉，您不是本群管理员"];
//        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料", nil] btnClickBlock:^(NSInteger buttonIndex) {
//            if (buttonIndex == 999) {
//                return ;
//            }else if(buttonIndex == 0){
////                self.groupClick(indexPath);
//                [self showContactDetailWithZJContact:contact];
//            }
//
//        }];
//        [sheet show];
    }
}

#pragma mark - 根据ZJContact向上弹出好友详情
-(void)showContactDetailWithZJContact:(ZJContact *)contactttt{
    //看看是否是好友关系 是好友跳转到聊天，不是好友跳转到加好友界面
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSMutableArray *contacts = [NSMutableArray new];
            __block UUMessageFrame *entity = [UUMessageFrame new];
            UUMessage *message = [UUMessage new];
            message.userId = contactttt.friend_userid;
            message.userName = contactttt.friend_username;
            message.nickName = contactttt.friend_nickname;
            message.originalNickName = contactttt.friend_originalnickname;
            message.strIcon = contactttt.iconUrl;
            [entity setMessage:message];
            //这里重新去缓存联系人
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",entity.message.userId]];
            }];
            BOOL ISFriend = NO;
            if (contacts.count > 0) {
                ISFriend = YES;
            }
    //        for (ZJContact *contactSearch in contacts) {
    //            if ([[contactSearch.friend_userid description] isEqualToString:[entity.message.userId description]]) {
    //                ISFriend  = YES;
    //                break;
    //            }
    //        }
            if(!ISFriend && ![self.groupCreateSEntity.groupSecret isEqualToString:@"1"]){
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                toCtrol.addFriendId = entity.message.userId;
                toCtrol.addFriendName = entity.message.userName;
                toCtrol.headPicpath = entity.message.strIcon;
                [self.navigationController pushViewController:toCtrol animated:YES];
                return;
            }else if(!ISFriend && ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.is_creator isEqualToString:@"1"])){
                //当为群主管理 群隐私打开的时候 可以直接跳转到添加好友界面
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                toCtrol.addFriendId = entity.message.userId;
                toCtrol.addFriendName = entity.message.userName;
                toCtrol.headPicpath = entity.message.strIcon;
                [self.navigationController pushViewController:toCtrol animated:YES];
                return;
            }
            
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //请求群成员详情
            [strongSelf->socketRequest requestPersonalInfoWithID:entity.message.userId];
            strongSelf->selectedUUMessage = entity;
            [strongSelf.IFView_.TextViewInput resignFirstResponder];
            //strongSelf ->selectedIndexPath = indexPath;
            //ZJContactDetailController
            strongSelf.GroupChatTableView.scrollEnabled = NO;
            strongSelf.ZJContactDetailController.view  = nil;
            strongSelf.ZJContactDetailController  = nil;
            if (strongSelf.ZJContactDetailController == nil) {
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
                strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
                //设置单聊详情数据
    //            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
                ZJContact *contact = [ZJContact new];
                contact.friend_userid = entity.message.userId;
                contact.friend_username = entity.message.userName;
                contact.friend_nickname  = entity.message.nickName;
                contact.friend_originalnickname  = entity.message.originalNickName;
                if (![entity.message.nickName isEqualToString:entity.message.originalNickName]) {
                    contact.friend_comment_name = entity.message.nickName;
                }
                contact.in_group_name  = entity.message.nickName?entity.message.nickName:entity.message.userName;
                contact.iconUrl = entity.message.strIcon;//头像
                //对于详情页面的赋值
                strongSelf.ZJContactDetailController.contant = contact;
                strongSelf.ZJContactDetailController.SourceFrom = @"1";
                [strongSelf addChildViewController:strongSelf.ZJContactDetailController];
                strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
                    if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
                        strongSelf.ZJContactDetailController.userNameLabel.hidden = YES;
                        strongSelf.ZJContactDetailController.freeChatBtn.hidden = YES;
                        strongSelf.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                    }
                }
                //点击了headview上面的事件
                strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    if (index == 0 || index == 10) {
                        //移除ZJContactDetailController
                        [UIView animateWithDuration:0.2 animations:^{
                            self.GroupChatTableView.scrollEnabled = YES;
                            self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                        } completion:^(BOOL finished) {
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            [self.ZJContactDetailController.view removeFromSuperview];
                            //当移除界面后 设置来自编辑名字为no
                            isFromEditName = NO;
                        }];
                        strongSelf.navigationController.navigationBarHidden = NO;
                    }else if (index == 1){
                        [strongSelf showMoreClickWithContact:contact];
//                        //相册
//                        strongSelf ->isFromEditName = YES;
//                        SGPhoto *temp = [[SGPhoto alloc] init];
//                        temp.identifier = @"";
//                        temp.thumbnail = [UIImage imageNamed:@"图片"];
//                        temp.fullResolutionImage = [UIImage imageNamed:@"图片"];
//                        HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//                        if (contact.iconUrl.length > 10) {
//                            showImageViewCtrol.imageUrlList = @[contact.iconUrl];
//                        }else{
//                            showImageViewCtrol.imageUrlList = @[temp];
//                        }
//                        showImageViewCtrol.mainImageIndex = 0;
//                        showImageViewCtrol.isLuoYang = YES;
//                        showImageViewCtrol.isNeedNavigation = NO;
//                        [strongSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
                    }else if (index == 2){
                    }
                };
                //如果点击了自己 则
                if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
                    self.ZJContactDetailController.freeChatBtn.hidden = YES;
                    self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                }
                //设置编辑名字、免费聊天
    //            [weakSelf.ZJContactDetailController.nameEditBtn addTarget:weakSelf action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
                [weakSelf.ZJContactDetailController.freeChatBtn addTarget:weakSelf action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
                //设置头像
                self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80/2, -65, 90, 90)];
    //            ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
                ViewRadius(self.ZJContactDetailController.nfHeadImageV, 3);
                [self.ZJContactDetailController.nfHeadImageV ShowHeadImageWithUrlStr:contact.iconUrl withUerId:nil completion:^(BOOL success, UIImage *image) {
                }];
                //点击头像后
                [self.ZJContactDetailController.nfHeadImageV afterClickHeadImage:^{
                    [weakSelf.IFView_.TextViewInput resignFirstResponder];
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    strongSelf ->isFromEditName = YES;
                    SGPhoto *temp = [[SGPhoto alloc] init];
                    temp.identifier = @"";
                    temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
                    temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
                    HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
                    if (contact.iconUrl.length > 10) {
                        showImageViewCtrol.imageUrlList = @[contact.iconUrl];
                    }else{
                        showImageViewCtrol.imageUrlList = @[temp];
                    }
                    showImageViewCtrol.mainImageIndex = 0;
                    showImageViewCtrol.isLuoYang = YES;
                    showImageViewCtrol.isNeedNavigation = NO;
                    [self.navigationController pushViewController:showImageViewCtrol animated:YES];
                }];
                [weakSelf.ZJContactDetailController.tableView addSubview:weakSelf.ZJContactDetailController.nfHeadImageV];
                [weakSelf.view addSubview:weakSelf.ZJContactDetailController.view];
                [UIView animateWithDuration:0.2 animations:^{
                    self.navigationController.navigationBarHidden = YES;
                    self.tabBarController.tabBar.hidden = YES;
                    self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                }];
            }
}


#pragma mark - 根据UUmessageFrame向上弹出好友详情
-(void)showContactDetailWithUUmessageFrame:(UUMessageFrame *)entity{
    //看看是否是好友关系 是好友跳转到聊天，不是好友跳转到加好友界面
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSMutableArray *contacts = [NSMutableArray new];
            //这里重新去缓存联系人
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",entity.message.userId]];
            }];
            BOOL ISFriend = NO;
            if (contacts.count > 0) {
                ISFriend = YES;
            }
    //        for (ZJContact *contactSearch in contacts) {
    //            if ([[contactSearch.friend_userid description] isEqualToString:[entity.message.userId description]]) {
    //                ISFriend  = YES;
    //                break;
    //            }
    //        }
            if(!ISFriend && ![self.groupCreateSEntity.groupSecret isEqualToString:@"1"]){
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                toCtrol.addFriendId = entity.message.userId;
                toCtrol.addFriendName = entity.message.userName;
                toCtrol.headPicpath = entity.message.strIcon;
                [self.navigationController pushViewController:toCtrol animated:YES];
                return;
            }else if(!ISFriend && ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.is_creator isEqualToString:@"1"])){
                //当为群主管理 群隐私打开的时候 可以直接跳转到添加好友界面
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                toCtrol.addFriendId = entity.message.userId;
                toCtrol.addFriendName = entity.message.userName;
                toCtrol.headPicpath = entity.message.strIcon;
                [self.navigationController pushViewController:toCtrol animated:YES];
                return;
            }
            
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //请求群成员详情
            [strongSelf->socketRequest requestPersonalInfoWithID:entity.message.userId];
            strongSelf->selectedUUMessage = entity;
            [strongSelf.IFView_.TextViewInput resignFirstResponder];
            //strongSelf ->selectedIndexPath = indexPath;
            //ZJContactDetailController
            strongSelf.GroupChatTableView.scrollEnabled = NO;
            strongSelf.ZJContactDetailController.view  = nil;
            strongSelf.ZJContactDetailController  = nil;
            if (strongSelf.ZJContactDetailController == nil) {
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
                strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
                //设置单聊详情数据
    //            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
                ZJContact *contact = [ZJContact new];
                contact.friend_userid = entity.message.userId;
                contact.friend_username = entity.message.userName;
                contact.friend_nickname  = entity.message.nickName;
                contact.friend_originalnickname  = entity.message.originalNickName;
                if (![entity.message.nickName isEqualToString:entity.message.originalNickName]) {
                    contact.friend_comment_name = entity.message.nickName;
                }
                contact.in_group_name  = entity.message.nickName?entity.message.nickName:entity.message.userName;
                contact.iconUrl = entity.message.strIcon;//头像
                //对于详情页面的赋值
                strongSelf.ZJContactDetailController.contant = contact;
                strongSelf.ZJContactDetailController.SourceFrom = @"1";
                [strongSelf addChildViewController:strongSelf.ZJContactDetailController];
                strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
                    if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
                        strongSelf.ZJContactDetailController.userNameLabel.hidden = YES;
                        strongSelf.ZJContactDetailController.freeChatBtn.hidden = YES;
                        strongSelf.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                    }
                }
                //点击了headview上面的事件
                strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    if (index == 0 || index == 10) {
                        //移除ZJContactDetailController
                        [UIView animateWithDuration:0.2 animations:^{
                            self.GroupChatTableView.scrollEnabled = YES;
                            self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                        } completion:^(BOOL finished) {
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            [self.ZJContactDetailController.view removeFromSuperview];
                            //当移除界面后 设置来自编辑名字为no
                            isFromEditName = NO;
                        }];
                        strongSelf.navigationController.navigationBarHidden = NO;
                    }else if (index == 1){
                        [strongSelf showMoreClickWithContact:contact];
                        
//                        //相册
//                        strongSelf ->isFromEditName = YES;
//                        SGPhoto *temp = [[SGPhoto alloc] init];
//                        temp.identifier = @"";
//                        temp.thumbnail = [UIImage imageNamed:@"图片"];
//                        temp.fullResolutionImage = [UIImage imageNamed:@"图片"];
//                        HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//                        if (contact.iconUrl.length > 10) {
//                            showImageViewCtrol.imageUrlList = @[contact.iconUrl];
//                        }else{
//                            showImageViewCtrol.imageUrlList = @[temp];
//                        }
//                        showImageViewCtrol.mainImageIndex = 0;
//                        showImageViewCtrol.isLuoYang = YES;
//                        showImageViewCtrol.isNeedNavigation = NO;
//                        [strongSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
                    }else if (index == 2){
                    }
                };
                //如果点击了自己 则
                if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
                    self.ZJContactDetailController.freeChatBtn.hidden = YES;
                    self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                }
                //设置编辑名字、免费聊天
    //            [weakSelf.ZJContactDetailController.nameEditBtn addTarget:weakSelf action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
                [weakSelf.ZJContactDetailController.freeChatBtn addTarget:weakSelf action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
                //设置头像
                self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80/2, -65, 90, 90)];
    //            ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
                ViewRadius(self.ZJContactDetailController.nfHeadImageV, 3);
                [self.ZJContactDetailController.nfHeadImageV ShowHeadImageWithUrlStr:contact.iconUrl withUerId:nil completion:^(BOOL success, UIImage *image) {
                }];
                //点击头像后
                [self.ZJContactDetailController.nfHeadImageV afterClickHeadImage:^{
                    [weakSelf.IFView_.TextViewInput resignFirstResponder];
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    strongSelf ->isFromEditName = YES;
                    SGPhoto *temp = [[SGPhoto alloc] init];
                    temp.identifier = @"";
                    temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
                    temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
                    HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
                    if (contact.iconUrl.length > 10) {
                        showImageViewCtrol.imageUrlList = @[contact.iconUrl];
                    }else{
                        showImageViewCtrol.imageUrlList = @[temp];
                    }
                    showImageViewCtrol.mainImageIndex = 0;
                    showImageViewCtrol.isLuoYang = YES;
                    showImageViewCtrol.isNeedNavigation = NO;
                    [self.navigationController pushViewController:showImageViewCtrol animated:YES];
                }];
                [weakSelf.ZJContactDetailController.tableView addSubview:weakSelf.ZJContactDetailController.nfHeadImageV];
                [weakSelf.view addSubview:weakSelf.ZJContactDetailController.view];
                [UIView animateWithDuration:0.2 animations:^{
                    self.navigationController.navigationBarHidden = YES;
                    self.tabBarController.tabBar.hidden = YES;
                    self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                }];
            }
}

#pragma mark - 编辑名字
//-(void)EditNameClick{
//    //    self.navigationController.navigationBarHidden = NO;
//    //名字
//    isFromEditName = YES;
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
//    PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
//    toCtrol.editType = EditNameType;
//    [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
//        if (type == EditNameType) {
//            [self.ZJContactDetailController.nameEditBtn setTitle:info forState:(UIControlStateNormal)];
//        }
//    }];
//    [self.navigationController pushViewController:toCtrol animated:YES];
//}

#pragma mark - 免费聊天
-(void)freeChatClick:(UIButton *)button event:(UIEvent *)event{
    
    isFromEditName = NO;
    //    self.navigationController.navigationBarHidden = NO;
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.GroupChatTableView];
//    NSIndexPath *indexPath = [self.GroupChatTableView indexPathForRowAtPoint:currentTouchPosition];
    NSIndexPath *indexPath = selectedIndexPath;
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
    //    NSInteger index = [_sectionIndexs[selectedIndexPath.section - 1] integerValue];
    //    NSArray *temp = _data[index];
    //    ZJContact *contact = (ZJContact *)temp[selectedIndexPath.row];
//    NSLog(@"%ld",selectedIndexPath.row);
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    ZJContact *contact = [ZJContact new];
    contact.friend_userid = entity.message.userId;
    contact.friend_username = entity.message.userName;
    contact.friend_nickname  = entity.message.nickName;
    contact.in_group_name  = entity.message.nickName?entity.message.nickName:entity.message.userName;
    contact.iconUrl = entity.message.strIcon;//
    
    if (contact.iconUrl.length == 0) {
        //当头像为空 取缓存头像 【当该人为好友时 才能有用】
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *existContactArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            existContactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",@"18"];
        }];
        
        if (existContactArr.count == 1) {
            ZJContact *cacheContact = [existContactArr firstObject];
            //取需要的数据
            contact.iconUrl = cacheContact.iconUrl;
        }
    }
    if (contact.friend_nickname.length > 0) {
        toCtrol.titleName = contact.friend_nickname;
    }else{
        toCtrol.titleName = contact.friend_username;
    }
    toCtrol.conversationId = contact.friend_userid;
    //toCtrol.chatType = @"0";
    toCtrol.singleContactEntity = contact;
    [self.navigationController pushViewController:toCtrol animated:YES];
}

-(void)backClicked{
    [self.navigationController popViewControllerAnimated:YES];
    [self.IFView_ removeEmotionKeyboardOberser];
}

//懒加载
-(NSMutableDictionary *)cacheDataRowSendStatus{
    if (!_cacheDataRowSendStatusDict) {
        _cacheDataRowSendStatusDict = [[NSMutableDictionary alloc] init];
    }
    return _cacheDataRowSendStatusDict;
}

//懒加载
-(MessageChatEntity *)chatEntity{
    if (!_chatEntity) {
        _chatEntity = [[MessageChatEntity alloc] init];
    }
    return _chatEntity;
}

-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}
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


#pragma mark - for删除数据库中选中的消息
-(void)deleteCommitClick{
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"是否删除" otherButtonTitles:[NSArray arrayWithObjects:@"确定", nil] btnClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 999) {
            return ;
        }
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        for (int i = 0; i<needDeleteEntityArr.count; i++) {
            UUMessageFrame *entity = needDeleteEntityArr[i];
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:groupMacroName whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
            }];
            
            if (entity.message.cachePicPath.length > 0) {
                if (entity.message.cachePicPath.length > 0) {
                    [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                }
            }
            //        NSIndexPath *indexPath = needDeleteIndexPathArr[i];
            //        [self.dataArr removeObjectAtIndex:indexPath.row];
            //        [self.GroupChatTableView   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationBottom];
        }
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *index in needDeleteIndexPathArr) {
            [indexSet addIndex:index.row];
        }
        [self.dataArr removeObjectsAtIndexes:indexSet];
        [self.self.GroupChatTableView   deleteRowsAtIndexPaths:needDeleteIndexPathArr withRowAnimation:UITableViewRowAnimationBottom];
        //等于点击了取消的效果
        [self performSelector:@selector(cancelEditClick)];
        [self.GroupChatTableView reloadData];
        //                [self.singleTableV endUpdates];
    }];
    [sheet show];
    
}

#pragma mark - 界面消失缓存会话列表
-(void)cacheConversationList{
    //会话列表在会话界面进行核实
    //查看数据库有没有该会话 有的话就return 在会话劣币哦啊界面进行核实 没有则在这里创建
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *arr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
//    NSArray *conversationExistArr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",self.groupCreateSEntity.groupId,@"IsSingleChat",@"0"];
//    if (conversationExistArr.count == 1 || IsInGroup) {
//        //如果表里面有一条数据 则return 在会话列表界面进行核实 但是如果大于一条 需要在下面进行删除
//        return;
//    }
    
    NSDictionary *dic = [NSDictionary new];
    //隐藏的话
    UUMessageFrame *lastE = [self.dataArr lastObject];
    MessageChatEntity *last = [MessageChatEntity new];
    last.yuehouYinCang = lastE.message.yuehouYinCang;
    last.localReceiveTimeString = lastE.message.localReceiveTimeString;
    last.localReceiveTime = [lastE.message.localReceiveTimeString integerValue];
    last.message_content = lastE.message.strContent;
    if (lastE.message.type == 0) {
        last.type = @"0";
    }else if (lastE.message.type == 1){
        last.type = @"1";
    }else if (lastE.message.type == 2){
        last.type = @"2";
    }else if (lastE.message.type == 3){
        last.type = @"3";
        last.message_content = @"[多信红包]恭喜发财，大吉大利";
    }else if (lastE.message.type == 4){
        last.type = @"4";
        last.message_content = @"名片消息";
    }else if (lastE.message.type == 5){
        last.type = @"5";
        last.message_content = lastE.message.pulledMemberString;
    }else if (lastE.message.type == 7){
        last.type = @"7";
        last.message_content = @"[系统消息]";
    }
    if (last && [last.yuehouYinCang isEqualToString:@"1"] && last.localReceiveTimeString.length > 0) {
        if (last.message_content.length == 0) {
            last.message_content = @"图片";
        }
        if (self.navigationItem.title.length > 0) {
            dic = @{@"group_id":self.conversationId,@"group_msg_content":@"",@"last_message_id":last.chatId?last.chatId:@"",@"group_msg_time":last.localReceiveTimeString,@"group_name":self.navigationItem.title,@"group_msg_type":@"normal"};
        }else if (self.groupName.length > 0){
            dic = @{@"group_id":self.conversationId,@"group_msg_content":@"",@"last_message_id":last.chatId?last.chatId:@"",@"group_msg_time":last.localReceiveTimeString,@"group_name":self.groupName,@"group_msg_type":@"normal",@"photo":self.groupCreateSEntity.groupHeadPic?self.groupCreateSEntity.groupHeadPic:@""};
        }
        [self.fmdbServicee receiveGroupMessageChangeChatListCache:dic];
    }else{
        NSString *type = @"";
        if ((last && last.localReceiveTimeString.length > 0) || [last.message_content containsString:@"系统消息"] ) {
            if ([last.type isEqualToString:@"0"]) {
                type = @"normal";
            }else if ([last.type isEqualToString:@"1"]){
                last.message_content = @"[图片]";
                type = @"image";
            }else if ([last.type isEqualToString:@"2"]){
                last.message_content = @"[语音]";
                type = @"audio";
            }else if ([last.type isEqualToString:@"3"]){
                last.message_content = lastE.message.strContent;
                last.message_content = @"[多信红包]恭喜发财，大吉大利";
                type = @"red";
            }else if ([last.type isEqualToString:@"4"]){
                last.message_content = lastE.message.strContent;
                last.message_content = @"名片消息";
                type = @"card";
            }else if ([last.type isEqualToString:@"5"]){
                last.message_content = lastE.message.pulledMemberString;
                type = @"redRecord";
            }else if ([last.type isEqualToString:@"7"]){
                last.message_content = @"[系统消息]";
                type = @"system";
            }
            if ((self.conversationId || self.groupCreateSEntity.groupId) && last.localReceiveTimeString && (self.groupCreateSEntity.groupName || self.groupName)) {
                dic = @{@"group_id":self.conversationId?self.conversationId:self.groupCreateSEntity.groupId,@"group_msg_content":last.message_content.length >0?last.message_content:@"",@"last_message_id":last.chatId?last.chatId:@"",@"group_msg_time":last.localReceiveTimeString,@"group_name":self.groupName?self.groupName:self.groupCreateSEntity.groupName,@"group_msg_type":type,@"photo":self.groupCreateSEntity.groupHeadPic?self.groupCreateSEntity.groupHeadPic:@""};
                [self.fmdbServicee receiveGroupMessageChangeChatListCache:dic];
            }
        }else{
            __block NSArray *arrss = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                arrss = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.conversationId?strongSelf.conversationId:strongSelf.groupCreateSEntity.groupId,@"IsSingleChat",@"0"]];
            }];
            if (arrss.count > 0) {
                if ((self.conversationId || self.groupCreateSEntity.groupId) && (self.groupCreateSEntity.groupName || self.groupName)) {
                    dic = @{@"group_id":self.conversationId?self.conversationId:self.groupCreateSEntity.groupId,@"group_msg_content":@"",@"last_message_id":last.chatId?last.chatId:@"",@"group_msg_time":@"",@"group_name":self.groupName?self.groupName:self.groupCreateSEntity.groupName,@"group_msg_type":@"normal",@"photo":self.groupCreateSEntity.groupHeadPic?self.groupCreateSEntity.groupHeadPic:@""};
                    [self.fmdbServicee receiveGroupMessageChangeChatListCache:dic];
                }
            }
        }
    }
}


#pragma mark - //收到网络变化通知
- (void)connectBreak:(NSNotification *)notifi{
    NSDictionary *nitification = notifi.object;
    if ([[nitification objectForKey:@"connectStatus"] isEqualToString:@"1"]) {
        // 服务器断了
        titleViewLabel.text = [NSString stringWithFormat:@"%@(未连接)",self.groupCreateSEntity.groupName];
        NSLog(@"当前任务所在线程%@是否在主线程%d",[NSThread currentThread],[NSThread isMainThread]);
        dispatch_main_async_safe(^{
            NSLog(@"当前任务所在线程%@是否在主线程%d",[NSThread currentThread],[NSThread isMainThread]);
            self.navigationItem.titleView = titleViewLabel;
        })
        
    }else if ([[nitification objectForKey:@"connectStatus"] isEqualToString:@"0"]) {
        [self refresh];
        // 显示完整标题   刷新成功后 再显示完整标题
//        titleViewLabel.text = [NSString stringWithFormat:@"%@(%d)",self.groupCreateSEntity.groupName,self.memberArr.count>0?self.memberArr.count:self.groupCreateSEntity.groupAllUser.count];
//        dispatch_main_async_safe(^{
//            NSLog(@"当前任务所在线程%@是否在主线程%d",[NSThread currentThread],[NSThread isMainThread]);
//            self.navigationItem.titleView = titleViewLabel;
//        })
    }
    
}

#pragma mark - 下拉刷新4
#pragma mark - scrollView Delegate
// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView_ egoRefreshScrollViewDidEndDragging:scrollView];
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distance = scrollView.contentSize.height - height;
    if (distance- contentYoffset<=0) {
        NSLog(@"您已经滑到底部了");
        //以后再做 滑到底部 隐藏上面的消息
        //        if (self.dataArr.count > 8) {
        //            NSRange range ;
        //            range.location = 0;
        //            range.length = self.dataArr.count - 8;
        //            [self.dataArr removeObjectsInRange:range];
        //            [self.chatTableView reloadData];
        //            //移除数据
        //            canRefresh = YES;
        //        }
    }
    
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [refreshHeaderView_ egoRefreshScrollViewDidScroll:scrollView];
//    [self.view endEditing:YES];
//    [self performSelector:@selector(tapTableView)];
//}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [refreshHeaderView_ egoRefreshScrollViewDidScroll:scrollView];
    [self.view endEditing:YES];
    [self performSelector:@selector(tapTableView)];
    //    [self.chatKeyBoard keyboardDown];
//    [TableViewAnimationKit showWithAnimationType:XSTableViewAnimationTypeRote tableView:self.GroupChatTableView];
}

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
    reloading_ = YES;
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    reloading_ = NO;
#pragma mark - 下拉刷新5
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:self.self.GroupChatTableView];
}

#pragma mark - 下拉刷新委托回调

//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
#pragma mark - 下拉刷新6
    
    if (canRefresh) {
        [self refreshFromFMDB];
    }else{
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [self doneLoadingTableViewData];
        });
    }
    //    if (canRefresh) {
    //        //此处刷新接口数据
    //        [self initDataSource];
    //    }else{
    //        dispatch_queue_t mainQueue = dispatch_get_main_queue();
    //        dispatch_async(mainQueue, ^{
    //            [self doneLoadingTableViewData];
    //        });
    //    }
}

// should return if data source model is reloading
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return reloading_;
}

// should return date data source was last changed
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
}

-(void)dealloc{
    
    NSLog(@"%@",[NSString stringWithFormat:@"\n\n%@\n\n",@"dealloc"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end













