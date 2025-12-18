//
//  MessageChatViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/6/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MessageChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "ChosePhoto.h"

#define kLines 20

#define rootDictionary @"result"
#define refreshCount 15
#define showTimeInterval 3*60

@interface MessageChatViewController ()<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,UUInputFunctionViewDelegate,ChatHandlerDelegate,UIGestureRecognizerDelegate,UIGestureRecognizerDelegate>
//
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@property(nonatomic,strong)NSMutableArray *rootDataArr;
@property(nonatomic,strong)NSMutableArray *dataArr;
//@property(nonatomic,weak)NSMutableArray *dataArr;
@property (nonatomic,assign)AppDelegate *appdelegate;

@property (nonatomic,strong)MessageChatEntity *chatEntity;//用于请求 取最后一个字段进行请求

//每次发送的消息 暂时储存在这 当对方不是好友 则移除
@property(nonatomic,strong)UUMessageFrame *sendedMessage;
//声明一个全局线程组
@property (nonatomic, strong, nullable) dispatch_group_t completionGroup;
//个人信息详情 【点击头像后的界面】
@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;

@end

@implementation MessageChatViewController{
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
    // 取数据相关 这里是记录剩余数据的个数【比如刚进来展示了15条，缓存还有23条，那么这里就是23,总共为15+23】
    int dataCount;
    //这里记录当剩余缓存不足15条时候 到底剩余多少条
    int leastCount;
    //记录上一个实体 用于是否显示时间逻辑判断
    MessageChatEntity *lastEntity;
    //选择照片
    ChosePhoto *AA_;
    //为了计算什么时候到达maxcount 而存在
    NSMutableArray *ExistImageArr_;
    //记录正在输入状态 yes正在输入 no结束输入
    //只在服务器返回里面进行 修改、设置 yes 正在输入 no没有 【根据对方输入与否设置】 我这里显示是否中正在输入
    BOOL enteringStatus;
    //对方时候显示你正在输入中
    BOOL IsShowEntering;
    //根据我这里是否正在编辑设置 【当输入长度大于10，则进行网络请求正在输入】
    NSInteger enteringLength;
    //键盘高度 当界面发生调整时 需要考虑到键盘高度 【没有键盘弹出就是0，其实可以判断是否有键盘显示】
    CGFloat keyboardHeight;
    //记录是否刚刚发了消息
    BOOL sendMessageJustnow;
    //点击更多后 底部显示的菜单栏【目前只有删除】
    bottomEditMenuView *bottomEditView;
    //需要删除的实体和indexpath数组
    NSMutableArray *needDeleteEntityArr;
    NSMutableArray *needDeleteIndexPathArr;
    //当长按后选中更多后 这里记录为YES，逻辑处理让其默认选中该cell 点击更多后设置为no，当取消默认选中的后设置为no，再次选中则走正常代理
    BOOL firstSelectDelete;
    //记录点击更多后选中的indexpath 用于在点击更多后 滑出界面回来cell需要为选中状态
    NSIndexPath *clickMoreIndexPath;
    //记录要撤回的消息id 用于撤回请求
    NSString *drowMessageId;
    //记录撤回的indexpath 撤回成功后 删除dataArr数据和数据库
    NSIndexPath *drowMessageIndexPath;
    //是否为长按导致的放弃输入框第一响应着 【解决长按后内容一闪的bug】
    BOOL IsFromLongTap;
    //是否为原图 用户发送图片时 是否进行大幅度压缩
    BOOL isOriginalImage;
    //当长时间后断线 重连发送保存的字典
    NSDictionary *messageWaitSendDict;
    //刷新前数据个数
    NSInteger oldCount;
    //右上角点击详情
    UIButton *lookDetailBtn;
    //编辑名字后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    //是否走了didload方法【push过来的会走 pop回来的不会走】
    BOOL IsPush;
    NSString *lastMessageId;
    NSString *yuehouString;//阅后隐藏字符串 为某个时间、空、空字符串等
    //标题label
    UILabel * titleViewLabel;
    // 有新消息 下面按钮
    UIButton *newMessageBottomButton;
    //新消息 上面按钮
    UIButton *newMessageTopButton;
    //新消息总条数 读完就减去 刚走完5012是 self.dataArr - 15
    NSInteger totalNewMessageCount;
    
    BOOL IsClickback;
    
    
    //记录选中的indexpath 【点击头像后 需要取zjcontact】
    NSIndexPath *selectedIndexPath;
    
    //左侧按钮
    UIButton *leftBackBtn;
    UIButton *leftCountBtn;
    UIBarButtonItem *leftBackBtnItem;
    UIBarButtonItem *leftCountBtnItem;
    
    
}

//当ret为YES【当为断线后重连成功】 直接请求消息历史，为no【当从详情等页面过来时】
-(void)requestChatHistory:(BOOL)ret{
#pragma mark - 22
    //当socketmodel存在 说明该界面已经存在 是pop回到这里的 则进行请求消息历史
    //当不是push过来 push过来会在didiload中请求消息历史
    // 并且是连接状态
    if ((socketModel && !IsPush && socketModel.isConnected) || ret) {
        if (lastEntity) {
            //如果有数据库最后一条消息 则取最后一条消息的messageId进行请求消息历史
            self.chatEntity = lastEntity;
            [self getSingelChatData];
        }else{
            //没有数据库最后一条消息 则从数据库查出最后一条消息
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            
            //一般下面arr只有一条
            __block NSArray *cacheArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                int dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
                cacheArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,2]];
            }];
            if (cacheArr.count > 0) {
                //有则取出最后一条消息进行请求消息历史
                self.chatEntity = [cacheArr lastObject];
                lastEntity = [cacheArr lastObject];
                if (!self.chatEntity.chatId) {
                    self.chatEntity.chatId = @"0";
                    self.chatEntity.localReceiveTimeString = @"0";
                }
                [self getSingelChatData];
            }else{
                //如果数据库没有消息 则请求该好友所有未读消息
                self.chatEntity.localReceiveTimeString = @"0";
                self.chatEntity.chatId = @"0";
                lastEntity.localReceiveTimeString = @"0";
                lastEntity.chatId = @"0";
                self.chatEntity = lastEntity;
            }
            [self getSingelChatData];
        }
    }else if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"]){
        //如果为点击了群聊推送进来 但是未连接 那么让它转 直到连接成功 或提示开小差
        //        [SVProgressHUD show];
        NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
        if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
            titleViewLabel.text = [NSString stringWithFormat:@"%@(连接中)",title];
            self.navigationItem.titleView = titleViewLabel;
        }
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
    self.isCanSendMessage = NO;//刚进来设置不可发送消息
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.isCanSendMessage = YES;//这里不应该有 因为当收取中时 不可以发送消息
//    });
    
//    [self.view layoutIfNeeded];
//    [self.view layoutSubviews];
    
    //当界面出来时 右上角按钮设置为可点
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteringEndRequest) name:@"enteringEndRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteringRequesst) name:@"enteringRequesst" object:nil];
    //增加通知观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectBreak:) name:@"connectBreak" object:nil];
    [self.IFView_ AddNotification];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
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
    //进入聊天界面则设置当前聊天id
    [NFUserEntity shareInstance].currentChatId = self.singleContactEntity.friend_userid;
    [NFUserEntity shareInstance].isSingleChat = @"1";
    //self.chatTableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
//    [self.chatTableView reloadData];
    if (isFromEditName) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
    
    
//    self.IFView_ = [[UUInputFunctionView alloc] initWithSuperVC:self];
//    self.IFView_.delegate = self;
//    self.IFView_.superTableview = self.chatTableView;
    
    CGRect rect =  self.IFView_.frame;
    
    NSLog(@"");
}

#pragma mark - 当pop或者从相册回来时 看看界面显示与缓存是否一致
-(void)checkUIDataIsCorrectWithFMDB{
    //取界面最后一条数据
    UUMessageFrame *lastEntity = self.dataArr.count > 0 ?[self.dataArr lastObject]:nil;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block NSArray *cacheArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
        cacheArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,2]];
    }];
    if (cacheArr.count > 0) {
        MessageChatEntity *localFMDBLastEntity = [cacheArr lastObject];
        if (!lastEntity || ![lastEntity.message.chatId isEqualToString:localFMDBLastEntity.chatId]) {
            //设置最后一条设置已读
            [self readedRequest:localFMDBLastEntity.chatId];
             if (dataaCount <= 15) {
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    cacheArr = [strongSelf ->jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
                }];
                [self.dataArr removeAllObjects];
                [self DealDataToLocalController:cacheArr];
                [self.chatTableView reloadData];
            }else{
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    cacheArr = [strongSelf ->jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 15,15]];
                }];
                [self.dataArr removeAllObjects];
                [self DealDataToLocalController:cacheArr];
                [self.chatTableView reloadData];
            }
        }
    }
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
//    NSLog(@"%lu",(unsigned long)self.dataArr.count);
    if (self.dataArr.count > 0) {
        NSIndexPath *index_ = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
//        NSLog(@"%ld",self.chatTableView.sectionIndexMinimumDisplayRowCount);
//        if (self.chatTableView.sectionIndexMinimumDisplayRowCount > 0) {
//            [self.chatTableView scrollToRowAtIndexPath:index_ atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        }
    }
    if (![ClearManager getNetStatus]) {
        self.isCanSendMessage = YES;//当为断网 则可以发送消息 【但是肯定显示感叹号】
    }
    
    [self.fmdbServicee IsExistSingleChatHistory:self.conversationId];
    
    //请求个人信息 获取信息
    [socketRequest requestPersonalInfoWithID:self.singleContactEntity.friend_userid];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    //退出则将当前聊天id置空
    [NFUserEntity shareInstance].currentChatId = @"";
    [NFUserEntity shareInstance].isSingleChat = @"0";
    self.IFView_.isNeedBlock = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enteringEndRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enteringRequesst" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectBreak" object:nil];
    [self.IFView_ deallocMySelf];
    
    [self cacheConversationList];//将要消失 缓存会话列表
    
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
        self.titleName= nil;
        self.conversationId= nil;
        //self.chatType= nil;
        
        self.singleContactEntity= nil;
        [self.IFView_ removeEmotionKeyboardOberser];
        self.IFView_.delegate= nil;
        self.IFView_= nil;
        self.chatTableView= nil;
        self.bottomConstraint= nil;
        self.dataArr= nil;
        self.chatEntity= nil;
        self.ZJContactDetailController= nil;
        
        newMessageBottomButton = nil;
    }
    
    
}

- (void)willMoveToParentViewController:(UIViewController *)parent{
    if(parent == nil){
        IsClickback = YES;
    }
    //NSLog(@"");
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
   // NSLog(@"");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //为何要设置下面的
//    self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    self.navigationItem.title = self.titleName.length > 0?self.titleName:self.singleContactEntity.friend_username;
    
    [titleViewLabel removeFromSuperview];
    titleViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 100, 20)];
    titleViewLabel.text = @"";
    titleViewLabel.textAlignment = NSTextAlignmentCenter;
    titleViewLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleViewLabel.textColor = [UIColor whiteColor];
    titleViewLabel.font=[UIFont boldSystemFontOfSize:fontSize];
    //是否需要缓存
    needCache = YES;
    needGetCache = YES;
    needDeleteEntityArr = [[NSMutableArray alloc] initWithCapacity:5];
    needDeleteIndexPathArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    self.dataArr = [[NSMutableArray alloc] init];
    [self initUI];
    self.chatTableView.allowsSelection = YES;//允许多选
    self.chatTableView.allowsMultipleSelectionDuringEditing = YES;
    self.dataArr = [NSMutableArray new];
    [self initScoket];
    
    
    self.chatTableView.estimatedRowHeight = 0;
    self.chatTableView.estimatedSectionHeaderHeight = 0;
    self.chatTableView.estimatedSectionFooterHeight = 0;
    
    
    IsPush = YES;//在didload中设置为YES 只有push过来才会走didload
    
    //当聊天请求了缓存后 记录列表需要刷新
//    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    
//    self.chatTableView.userInteractionEnabled = YES;
    
    
    leftBackBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [leftBackBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [leftBackBtn addTarget:self action:@selector(backClickeddd:) forControlEvents:UIControlEventTouchUpInside];
    //[leftBackBtn setTitle:[NSString stringWithFormat:@"%ld",self.unreadAllCount] forState:(UIControlStateNormal)];
    leftBackBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBackBtn];
    
    leftCountBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    leftCountBtn.width = -5;
    //[leftCountBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [leftCountBtn addTarget:self action:@selector(backClickeddd:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - 请求某人的个人信息

#pragma mark - 刷新函数
-(void)refresh{
    NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
    if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
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
    [self getSingelChatData];
}

#pragma mark - 退出 返回
-(void)backClickeddd:(id)sender{
    [SVProgressHUD dismiss];
    
    IsClickback = YES;
    
    if (self.IsFromAdd) {
//        NSLog(@"%lu",self.navigationController.viewControllers.count);
        UIViewController * viewVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - self.navigationController.viewControllers.count];
        [self.navigationController popToViewController:viewVC animated:YES];
        self.view = nil;
    }else{
        UIViewController * viewVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - self.navigationController.viewControllers.count];
        [self.navigationController popToViewController:viewVC animated:YES];
        self.view = nil;
    }
//    NSLog(@"%lu",self.tabBarController.selectedIndex);
//    [self createDispatchWithDelay:0.5 block:^{
//        self.tabBarController.selectedIndex = 0;
//    }];
    
    
    [self.IFView_ removeEmotionKeyboardOberser];
    
    NSLog(@"aaa = %@",self.view);
    
    
    
}

-(void)refreshFromFMDB{
    [needDeleteIndexPathArr removeAllObjects]; //刷新后 清除选中的indexpath
    totalNewMessageCount -= refreshCount;//每次刷新
    if (totalNewMessageCount > 0) {
        [newMessageTopButton setTitle:[NSString stringWithFormat:@"%d条未读消息",totalNewMessageCount] forState:(UIControlStateNormal)];
        newMessageTopButton.alpha = 1;
    }else{
        newMessageTopButton.alpha = 0;
    }
    //当下拉刷新时，将记录的实体 置空 因为这个实体不是之前的消息记录的，而是后面10条的第一个记录
    lastEntity = nil;
    //逻辑记录当剩余数据少于10条的具体个数
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
            arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,refreshCount]];
        }];
    }else{
        //剩余数据不足刷新时 拉出所有剩余数据
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,strongSelf ->leastCount]];
        }];
    }
    //取顶部第一条缓存之前一条数据
    __weak typeof(self)weakSelf=self;
    if (arr.count >= 2) {
        lastEntity = arr[arr.count - 2];// 后面是取最后一条数据 所以要取最后一条数据前一条味lastEntity
    }else{
        lastEntity = nil;
    }
    //按正顺序从index0开始计算是否需要显示时间，一般index0时，需要从缓存里面取上一条数据的时间 进行比较
    for (int i = arr.count - 1; i>= 0; i--) {
        MessageChatEntity *entity = arr[i];
        //当第一条数据为隐藏的话 逻辑判定之前的数据都是呗隐藏的 显示暂无刷新
        if ([entity.yuehouYinCang isEqualToString:@"1"] && ![yuehouString isEqualToString:@"不隐藏"] && yuehouString.length != 0) {
            canRefresh = NO;
        }
        //在和lastEntity比对之前 先取到上一个entity
        if (i>0) {
            lastEntity = arr[i-1];
        }else if (i == 0 && arr.count < 15){
            lastEntity = nil;
        }
        UUMessageFrame *messageFrame = [self MessageChatEntityToUUMessageFrame:entity];//将取出来的实转成UUMessage消息实体
        lastEntity = entity;
        [self.dataArr insertObject:messageFrame atIndex:0];
        __block NSArray *tableLastEntityArr = [NSArray new];
        if (i == 0) {//当遍历完 设置lastEntity为数据库最后一个实体
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                int allCount = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
                tableLastEntityArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
            }];
            lastEntity = [tableLastEntityArr lastObject];//这里取到数据库的最后一条消息
        }
    }
    [self initLegalData];
    [self.chatTableView reloadData];
    //oldCount
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        if (strongSelf ->dataCount > 0){
            //将最上面第一条还显示在最上面
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:refreshCount - 1 inSection:0];
            [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }else{
            //leastCount
            //将最上面第一条还显示在最上面
            if (leastCount > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:leastCount - 1 inSection:0];
                [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
        [weakSelf doneLoadingTableViewData];
    });
}

#pragma mark - 添加好友
-(void)addFriendRequest{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"action"] = @"addFriend";
    dict[@"userName"] = [NFUserEntity shareInstance].userName;
    dict[@"userId"] = [NFUserEntity shareInstance].userId;
    dict[@"addTime"] = [NFMyManage getCurrentTimeStamp];
    dict[@"addUserName"] = self.singleContactEntity.friend_username;
    if ([self.singleContactEntity.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
        [SVProgressHUD showInfoWithStatus:@"不可以添加自己喔"];
        return;
    }
    if (![SVProgressHUD isVisible]) {//当界面没有svphud时，可以进行添加好友
        NSString *Json = [JsonModel convertToJsonData:dict];
        if (socketModel.isConnected) {
            [socketModel sendMsg:Json];
        }else{
            //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
        }
    }
    
}

#pragma mark - 请求单聊消息历史
-(void)getSingelChatData{
#warning 拉黑
    //判断该人是否为拉黑 拉黑则不需要请求聊天记录 localReceiveTime localReceiveTimeString
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    __block NSArray *contactArr = [NSArray new];
//    __weak typeof(self)weakSelf=self;
//    [jqFmdb jq_inDatabase:^{
//        __strong typeof(weakSelf)strongSelf=weakSelf;
//        contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
//    }];
//    if (contactArr.count > 0) {
//        ZJContact *contact = [contactArr firstObject];
//        if (contact.IsShield) {
//            return;
//        }
//    }
    NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
    if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
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
    
    [socketRequest getSingleChatDataWithFriendEntity:self.singleContactEntity LastChatEntity:self.chatEntity];
    
}

#pragma mark - 请求撤回

#pragma mark - 请求已读
-(void)readedRequest:(NSString *)messageId{
    __weak typeof(self)weakSelf=self;
    [weakSelf.parms removeAllObjects];
    weakSelf.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    weakSelf.parms[@"action"] = @"setMessageRead";
    weakSelf.parms[@"messageId"] = messageId;
    weakSelf.parms[@"receiveName"] = self.singleContactEntity.friend_username;
    NSString *Json = [JsonModel convertToJsonData:weakSelf.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
//        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 请求已收到
-(void)haveReceived:(NSString *)messageId{
    __weak typeof(self)weakSelf=self;
    [weakSelf.parms removeAllObjects];
    weakSelf.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    weakSelf.parms[@"typing"] = @"";
    weakSelf.parms[@"action"] = @"setMessageReceived";
    weakSelf.parms[@"messageId"] = messageId;
    weakSelf.parms[@"receiveName"] = self.singleContactEntity.friend_username;
    NSString *Json = [JsonModel convertToJsonData:weakSelf.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
//        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


#pragma mark - 请求正在输入
-(void)enteringRequesst{
    IsShowEntering = YES;
    ZJContact *contact = [ZJContact new];
    contact.friend_userid = self.singleContactEntity.friend_userid;
    contact.friend_username = self.singleContactEntity.friend_username;
    [socketRequest enteringRequesst:contact];
}

#pragma mark - 请求结束正在输入
-(void)enteringEndRequest{
    IsShowEntering = NO;
    ZJContact *contact = [ZJContact new];
    contact.friend_userid = self.singleContactEntity.friend_userid;
    contact.friend_username = self.singleContactEntity.friend_username;
    [socketRequest enteringEndRequest:contact];
}

#pragma mark - 为了重新建立服务器链接

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_SocketConnectChanged) {
        //重新连接通知界面刷新
        //请求消息历史 【当刚走了didload 这里面会过滤，didload中有请求消息历史】
        [self requestChatHistory:YES];
    }else if (messageType == SecretLetterType_ChatHistory){//4003
        if (![chatModel isKindOfClass:[NSDictionary class]]) {
            return;
        }
        chatModel = (NSDictionary *)chatModel;
        if ([self.navigationItem.title containsString:@"连接中"] || [self.navigationItem.title containsString:@"收取中"]) {
            self.navigationItem.title = self.titleName;//重连成功请求到消息历史 设置界面标题为好友名字
        }
        [NFUserEntity shareInstance].PushQRCode = @"0";//设置app跳转状态为正常
        //进来初始化 数据 【将收到的所有未读消息缓存，然后】
        NSMutableArray *getArr = [NSMutableArray arrayWithArray:[chatModel objectForKey:@"singleArr"]];
        //如果不是push过来的 看看是否请求到了历史消息 有则进行展示 没有酒return
        if (!IsPush && getArr.count == 0 && self.dataArr.count > 0) {
            [self tableViewScrollToBottomOffSet:0 IsNeedAnimal:NO];
            //收到消息为nil 显示完整标题
            titleViewLabel.text = self.titleName;
            dispatch_main_async_safe(^{
                self.navigationItem.titleView = titleViewLabel;
            })
            if ([NFUserEntity shareInstance].isNeedRefreshChatData) {
                //如果为转发到自己 那么需要刷新本地缓存 走断网展示本地数据逻辑
                //计算dataCount 从表某个位置取值
                [self countDataCount];
                //取展示的缓存 包括数据库整理
                lastEntity = nil;
                //拉取本地缓存 进行初始化数据 防止为清除过缓存
                self.dataArr = [NSMutableArray new];
                NSArray *arr = [self showHistoryData];
                // 将取出的缓存 赋值到界面数组
                [self DealDataToLocalController:arr];
                [self initLegalData];
                //        [socketModel initSocket];
                [self.chatTableView reloadData];
                if (self.dataArr.count > 0) {
                    //没有这个 会出现最后一张图片显示一半
                    [self tableViewScrollToBottomOffSet:0 IsNeedAnimal:NO];
                    //没有这个会有tableview从顶到底一闪
                    //iOS13
//                    NSIndexPath *index_ = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
//                    [self.chatTableView scrollToRowAtIndexPath:index_ atScrollPosition:(UITableViewScrollPositionBottom) animated:NO];
                    
                }else{
                    [self.chatTableView reloadData];
                }
            }
            //当外面有未读时候 这里需要设置一下已读 规避未读bug
            if(self.IsHaveNotRead){
                UUMessageFrame *uuMessage = [self.dataArr lastObject];
#pragma msrk - 设置消息已读
                [self readedRequest:uuMessage.message.chatId];
                self.IsHaveNotRead = 0;
            }
            [self showUnreadedMessageCount:getArr];//显示xx条消息未读【就算请求到的消息历史count为0 可能在会话列表缓存了】
            [self receivedServerAndInit];
            return;
        }else{
            //当为push过来的 将缓存中的消息add到self.dataarr
        }
        //设置已读和已收到 取最后一个
        MessageChatEntity *setReaded = [getArr lastObject];
        //这里进行缓存
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        //取数据库最后一条消息 为的是 核实给的消息历史的准确性【当收到的消息chat大于本地的最后一条消息 则都是新消息】
        __block NSArray *arr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            int allCount = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
            arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
        }];
        __block MessageChatEntity *lastChatEntity = [arr lastObject];//这里取到数据库的最后一条消息
        NSArray * copyArr = [NSArray arrayWithArray:getArr];
        if ([setReaded.chatId integerValue] <= [lastChatEntity.chatId integerValue]) {
            [getArr removeAllObjects];//一般都是走这里 因为在会话列表界面已经都缓存了 除非当该会话的消息特别多 而用户点击过快 会话界面来不及缓存 则会走下面
        }else{
            for (MessageChatEntity *repeatChatEntity in copyArr) {
                //从服务器返回的历史消息第0条在数据库查 如果本地有了这条数据 则从getArr中remove，一旦遇到没有的 说明后面的都没有 直接break
                //假设 给的消息历史中 某一条消息已读了 那么 这条消息之前的消息都肯定是已读的，从0开始遍历是对的
                __block NSArray *ifExistHistoryArr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    ifExistHistoryArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",repeatChatEntity.chatId];//取最后一条消息的chatId在本地数据库查找是否已经存在
                }];
                if (ifExistHistoryArr.count > 0) {//如果本地数据库存在该条消息 那么remove
                    [getArr removeObject:repeatChatEntity];
                }else if ([repeatChatEntity.chatId integerValue] >                                                                             [lastChatEntity.chatId integerValue]){//如果从本地查不到该条数据 并且该消息id 大于等于
                    break;
                }
            }
        }
        //判断是否为本人发的消息 如果是 则由于对方已经删除好友 否则只展示本地缓存
        dispatch_group_t group = dispatch_group_create();
//            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            dispatch_group_async(group, dispatch_queue_create("JoeThread", DISPATCH_QUEUE_SERIAL), ^{
//                sleep(5);
            __block NSArray *errorArr = [NSArray new];
            if (!self) {
                NSLog(@"self is missing");
            }
            if (getArr.count > 0) {
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    NSLog(@"strongSelf====2");
                    errorArr = [strongSelf ->jqFmdb jq_insertTable:strongSelf.singleContactEntity.friend_userid dicOrModelArray:getArr];
                }];
                if (errorArr.count > 0) {
                    [SVProgressHUD showInfoWithStatus:@"有部分消息缓存失败"];
                }
            }
            //耗时的操作都放多线程执行吧
            //                [self countDataCount];//缓存完消息历史后 重新计算消息条数
            //                NSArray *afterCacheArr = [self showHistoryData];//
            //                [self DealDataToLocalController:afterCacheArr];
            //                [self initLegalData];
            [self DealDataToLocalController:getArr];
            if (self.dataArr.count > 15) {
                //                    dataCount -= (self.dataArr.count - 15);
                dataCount  = dataCount + (self.dataArr.count - 15);
                canRefresh = YES;
                [self.dataArr removeObjectsInRange:NSMakeRange(0, self.dataArr.count - 15)];
            }
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{//这里的block 就算界面消失 也会执行
            titleViewLabel.text = self.titleName;
            self.navigationItem.titleView = titleViewLabel;
            [self.chatTableView reloadData];
            [self tableViewScrollToBottomOffSet:0 IsNeedAnimal:NO];
            //等到界面展示完毕了再 设置已读 防止消息丢失
            if (getArr.count > 0) {
#pragma msrk - 设置已收到
//                [self haveReceived:setReaded.chatId];
                [self readedRequest:setReaded.chatId];
            }else if(self.IsHaveNotRead){
                UUMessageFrame *uuMessage = [self.dataArr lastObject];
                [self readedRequest:setReaded.chatId];
                self.IsHaveNotRead= 0;
            }
            [self showUnreadedMessageCount:getArr];//显示xx条消息未读【就算请求到的消息历史count为0 可能在会话列表缓存了】
            [self receivedServerAndInit];
        }); 
        
//        });
    }else if (messageType == SecretLetterType_Normal){//4002
        //防止错误崩溃 一般不会走
        if (![chatModel isKindOfClass:[UUMessageFrame class]]) {
            return;
        }

        //将收到的消息直接插入当前界面并展示 UUMessageFrame 转 UUMessageFrame 但是新增了参数 与上一个消息进行了比较
        UUMessageFrame *messageFrame = chatModel;
        //收到消息 根据chatId在数据库里面搜索 搜索到有重复id 则return 不进行缓存
#warning 这里需要与服务器核实 注释了又能如何
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
//        __block NSArray *existArr = [NSArray new];
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            existArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",messageFrame.message.chatId];
//        }];
//        if (existArr.count > 0) {
//            //如果有重复的消息则return 不进行缓存【一般没有 有只有一条，有说明消息...】
//            return;
//        }
        UUMessage *messagee = [UUMessage new];
        messagee = messageFrame.message;
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
        }
        else{
            messageFrame.showTimeHead = YES;
            messageFrame.showTime = YES;
        }
        //set一下 不然showtimeheader会为空
        [messageFrame setMessage:messagee];
//        [self.dataArr addObject:messageFrame];
        //用于fmdb缓存
        MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
        //新收到的消息设置为最后一个实体
        if(entity.chatId.length > 0){
            lastEntity = entity;
        }
//        entity.redpacketDict = @{@"a":@"a",@"s":@"s",@"q":@"q",@"w":@"w",@"e":@"e"};
//        NSDictionary *aaa = @{@"a":@"a",@"s":@"s",@"q":@"q",@"w":@"w",@"e":@"e"};
        [self.fmdbServicee IsExistSingleChatHistory:self.singleContactEntity.friend_userid];
        //这里进行缓存
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *lastArr = [NSArray new];
        __block int dataaCount = 0;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //userId = userId order by id desc limit 5
            dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
            lastArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
            
        }];
        //重复消息 单聊
        if(lastArr.count == 1){
            MessageChatEntity *lastEntity = [lastArr firstObject];
            if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
                //如果有相同消息 则return
                return;
            }
        }
        //插入数据
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            BOOL rett = [strongSelf ->jqFmdb jq_insertTable:strongSelf.singleContactEntity.friend_userid dicOrModel:entity];
            if (!rett) {
                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
//                return;
            }
        }];
        
        
        [self.dataArr addObject:messageFrame];
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //收到消息 更新界面 需要刷新 当设置了阅后隐藏 需要这样做【可否做个判断 设置了安全设置再这样刷新。否则为插入】
            [strongSelf initLegalData];
            //[strongSelf.chatTableView reloadData];
//            [strongSelf.chatTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:(UITableViewRowAnimationNone)];
            
            //[strongSelf.chatTableView layoutIfNeeded];
//            return ;
            CGFloat showHeight = 0;
            if (![self.IFView_.TextViewInput isFirstResponder]  && self.IFView_.addFaceView.hidden) {
                showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
            }
            CGFloat huanchong = 250;
            if(self.chatTableView.contentSize.height - self.chatTableView.contentOffset.y >= (SCREEN_HEIGHT - kTopHeight - 50 + huanchong)){
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
            //        NSLog(@"%f",self.chatTableView.contentOffset.y);
            //当内容cell总高度大于contentheight 或 有表情view存在时
            if (self.chatTableView.contentSize.height > showHeight - kTopHeight - kTabBarHeight || !self.IFView_.addFaceView.hidden) {
                [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
            }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
                [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
            }else{
                [self.chatTableView reloadData];
            }
            
            
        });
    }else if (messageType == SecretLetterType_ChatEntering){
        //对方正在输入
        //如果到这里时候就是正在输入 则什么都不做
        if (!enteringStatus) {
//            enteringStatus = YES;
            [self navigationTitleAnimalThree];
        }
    }else if (messageType == SecretLetterType_ChatEndEnter){
        //对方结束正在输入
        //当到这里 是正在输入中 则改变状态 否则什么都不做
//        if (enteringStatus) {
            enteringStatus = NO;
            self.navigationItem.title = self.titleName;
//        }
    }else if (messageType == SecretLetterType_FriendNotExist){//不是好友【被删除、群聊临时会话】
        UUMessageFrame *messageFrame = chatModel;
        [self.dataArr removeObject:self.sendedMessage];
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//        NSArray *arrs = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
        //删除刚发出的一条消息
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            int num = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
            BOOL deleteRet = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"limit %d,1",num - 1]];
            //一般这里是没有消息数据的，因为是等服务器返回后 才缓存.
            if (deleteRet) {
                NSLog(@"success");
            }
        }];
        //会话列表的最后一条消息设置为空 changeFMDBData
        __block NSArray *arrs = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.singleContactEntity.friend_userid,@"IsSingleChat",@"1"]];
        }];
        if (arrs.count > 0) {
            MessageChatListEntity *chatListEntity = [arrs lastObject];
            chatListEntity.last_send_message = @"";
            [self.myManage changeFMDBData:chatListEntity KeyWordKey:@"conversationId" KeyWordValue:chatListEntity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
            __block NSArray *arrs = [NSArray new];
            __strong typeof(weakSelf)strongSelf=weakSelf;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:@"huihualiebiao" whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.singleContactEntity.friend_userid,@"receive_user_name",strongSelf.singleContactEntity.friend_username]];
                if (ret) {
                }
            }];
        }
//        NSArray *ardrs = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
        [self.dataArr addObject:messageFrame];
        [self.chatTableView reloadData];
        [self performSelector:@selector(tableViewScrollToBottomOffSet:IsNeedAnimal:)];
    }else if (messageType == SecretLetterType_NormalReceipt){//4001 返回resultDict
        //单聊消息发送回执
        messageWaitSendDict = nil;
        //检查缓存字段 在socketModel中已经做了
        
        //只进行更改缓存chatid 当为文字消息 修改后 return //因为已经在界面显示了
        NSDictionary *infoDict = chatModel;
        //消息来自网页端
        if ([[infoDict objectForKey:@"IsServer"] isEqualToString:@"1"]) {
            NSDictionary *dic = @{@"strContent": [infoDict objectForKey:@"strContent"], @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"chatId":@"",@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": @"",@"IsServer":@"1"};
            [self addSpecifiedItem:dic];
            [self.chatTableView reloadData];
            //动画下滑到底部
            CGFloat showHeight = 0;
            if ([self.IFView_.TextViewInput isFirstResponder]) {
                showHeight = SCREEN_HEIGHT - keyboardHeight;
            }else{
                showHeight = SCREEN_HEIGHT ;
            }
            //        NSLog(@"%f",self.chatTableView.contentOffset.y);
            //如果上滑超过半个屏幕高度 有新消息不让它到底部 
            if (self.chatTableView.contentSize.height > showHeight - kTopHeight - kTabBarHeight && ((self.chatTableView.contentOffset.y + CGRectGetMaxY(self.chatTableView.frame)) >= self.chatTableView.contentSize.height - 100 || [self.IFView_.TextViewInput isFirstResponder]  || self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected)) {
                [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
            }else if(self.chatTableView.contentSize.height > SCREEN_HEIGHT){
                //在tableview 右侧放一个按钮 点击滑动到底部
                newMessageBottomButton.alpha = 1;
            }
            return;
        }
        //消息来自app端
        //不像群聊 单聊没有【某人加群】通知 所有回执都需要从数据库更新chatid
        NSLog(@"******\n收到服务器的appmessageId:%@\n******",[infoDict objectForKey:@"appMsgId"]);
        if (![lastMessageId isEqualToString:[infoDict objectForKey:@"appMsgId"]]) {
//            NSLog(@"*****%@&%@*****",lastMessageId,[infoDict objectForKey:@"appMsgId"]);
        }
        //刷新这条cell 不让它再继续计时发送失败
        NSIndexPath *freshIndexPath;
//        NSLog(@"\nself.dataArr.count:%d\n",self.dataArr.count);
        //当受到服务器的消息时 根据服务器带来的本地appmessageId在本地查找这个indexpath 进行停止定时器
        for (int i = self.dataArr.count - 1; i>=0; i--) {
            UUMessageFrame *findEntity = self.dataArr[i];
            if ([findEntity.message.appMsgId isEqualToString:[[infoDict objectForKey:@"appMsgId"] description]]) {
                freshIndexPath=[NSIndexPath indexPathForRow:i inSection:0];
                MessageTableViewCell  * cell = (MessageTableViewCell *)[self.chatTableView cellForRowAtIndexPath:freshIndexPath];
                UUMessageFrame *entity = self.dataArr[freshIndexPath.row];
                entity.message.chatId = [[infoDict objectForKey:@"chatId"] description];
                entity.message.failStatus = @"0";//接收到服务器给的chatid 将这个row的实体设置为成功发送
                entity.message.fileId = [[infoDict objectForKey:@"fileId"] description];;
                [cell.timer invalidate];
                cell.timer = nil;
                //                    [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:freshIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }else if (messageType == SecretLetterType_GroupMessageDrowSuccess){
        //撤回成功 数据库删除
        [SVProgressHUD showSuccessWithStatus:@"撤回成功"];
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        __block NSArray *arrs = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arrs = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",strongSelf ->drowMessageId];
        }];
        if(arrs.count == 0){
            [SVProgressHUD showInfoWithStatus:@"出现错误：4016"];
            return;
        }
        MessageChatEntity *changeEntity = [arrs lastObject];
        changeEntity.type = @"7";
        changeEntity.pulledMemberString = @"你撤回了一条消息";
        [self.myManage changeFMDBData:changeEntity KeyWordKey:@"chatId" KeyWordValue:drowMessageId FMDBID:@"tongxun.sqlite" TableName:self.singleContactEntity.friend_userid];
        
        
//        [jqFmdb jq_inDatabase:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",strongSelf ->drowMessageId]];
//        }];
        
        //判断删除sdwebimage缓存在磁盘里面的图片
        if (self.dataArr.count > drowMessageIndexPath.row) {
            UUMessageFrame *entity = self.dataArr[drowMessageIndexPath.row];
            if (entity.message.cachePicPath.length > 0) {
                [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
            }
        }
//        [self.dataArr removeObjectAtIndex:drowMessageIndexPath.row];
        UUMessageFrame *messageFrameReplace = [self MessageChatEntityToUUMessageFrame:changeEntity];
        [self.dataArr replaceObjectAtIndex:drowMessageIndexPath.row withObject:messageFrameReplace];
//        [self.chatTableView   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:drowMessageIndexPath]withRowAnimation:UITableViewRowAnimationBottom];
        [self.chatTableView   reloadRowsAtIndexPaths:[NSMutableArray arrayWithObject:drowMessageIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.chatTableView reloadData];
        
    }else if (messageType == SecretLetterType_GroupMessageDrowFailed){
        //撤回失败 dissmiss
        [SVProgressHUD showInfoWithStatus:@"撤回失败"];
    }else if (messageType == SecretLetterType_LoginReceipt){
        //登录成功不做任何操作 有重发按钮控制
        //断线重连成功 不需要inirsocket 界面消息数据保持不变 单纯重新发送一条
//        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//        if ([currentVC isKindOfClass:[MessageChatViewController class]] && messageWaitSendDict) {
//            [self dealTheFunctionData:messageWaitSendDict IsConnected:YES];
//        }
        
    }else if (messageType == SecretLetterType_FriendAddSendSuccess) {
        //当点击提示添加好友 发送好友请求成功时
        [SVProgressHUD showInfoWithStatus:@"发送请求成功"];
    }else if (messageType == SecretLetterType_PersonalInfoDetail){
        //如果得不到聊天对象的名字 则从服务器请求到并设置
        PersonalInfoDetailEntity *detailInfoEntity = chatModel;
        self.titleName = detailInfoEntity.nick_name;
        if (![titleViewLabel.text containsString:@"收取中"] && ![titleViewLabel.text containsString:@"连接中"]) {
            if ([detailInfoEntity.nick_name isEqualToString:titleViewLabel.text]) {
                return;
            }else{
                titleViewLabel.text = detailInfoEntity.nick_name;
                dispatch_main_async_safe(^{
                    self.navigationItem.titleView = titleViewLabel;
                })
            }
        }
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }else if (messageType == SecretLetterType_systemMessage){
        
        [self.dataArr addObject:chatModel];
        __weak typeof(self)weakSelf=self;
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    CGFloat showHeight = 0;
                    if (![self.IFView_.TextViewInput isFirstResponder]  && self.IFView_.addFaceView.hidden) {
                        showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
                    }
                    CGFloat huanchong = 250;
                    if(self.chatTableView.contentSize.height - self.chatTableView.contentOffset.y >= (SCREEN_HEIGHT - kTopHeight - 50 + huanchong)){
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
                    //        NSLog(@"%f",self.chatTableView.contentOffset.y);
                    //当内容cell总高度大于contentheight 或 有表情view存在时
                    if (self.chatTableView.contentSize.height > showHeight - kTopHeight - kTabBarHeight || !self.IFView_.addFaceView.hidden) {
                        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
                    }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
                        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
                    }else{
                        [self.chatTableView reloadData];
                    }
                    
                    
                });
        
        
    }else if (messageType == SecretLetterType_RedOverdue){

        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        SendTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SendTableViewController"];
        toCtrol.isOverDue = YES;
        toCtrol.type = @"0";
        toCtrol.redDetailDict = chatModel;
        toCtrol.singleContactEntity = self.singleContactEntity;
        if (@available(iOS 13.0, *)) {
            toCtrol.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:toCtrol animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
        
        
    }else if(messageType == SecretLetterType_packetCheck){
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        SendTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SendTableViewController"];
        toCtrol.isOverDue = NO;
        NSDictionary *dict = [chatModel objectForKey:@"redpacketInfo"];
        if([[dict objectForKey:@"senduserId"] isEqualToString:[NFUserEntity shareInstance].userId] && ![dict objectForKey:@"list"]){
            toCtrol.type = @"0";
        }else if ([[dict objectForKey:@"senduserId"] isEqualToString:[NFUserEntity shareInstance].userId] && [dict objectForKey:@"list"]){
            toCtrol.type = @"1";
        }else if (![[dict objectForKey:@"senduserId"] isEqualToString:[NFUserEntity shareInstance].userId] && ![dict objectForKey:@"list"]){
            toCtrol.type = @"2";
        }
        toCtrol.redDetailDict = dict;
        toCtrol.redpacketId = [dict objectForKey:@"redpacketId"];
        toCtrol.singleContactEntity = self.singleContactEntity;
        if (@available(iOS 13.0, *)) {
            toCtrol.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:toCtrol animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
        }];
    }else if(messageType == SecretLetterType_lookPacket){
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        SendTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SendTableViewController"];
        toCtrol.isOverDue = NO;
        //NSDictionary *dict = [chatModel objectForKey:@"redpacketInfo"];
        if([[chatModel objectForKey:@"senduserId"] isEqualToString:[NFUserEntity shareInstance].userId] && [chatModel objectForKey:@"list"]){
            toCtrol.type = @"1";
        }else if(![[chatModel objectForKey:@"senduserId"] isEqualToString:[NFUserEntity shareInstance].userId] && [chatModel objectForKey:@"list"]){
            toCtrol.type = @"3";
        }
//        else if ([[dict objectForKey:@"senduserId"] isEqualToString:[NFUserEntity shareInstance].userId] && [dict objectForKey:@"list"]){
//            toCtrol.type = @"1";
//        }
        toCtrol.redDetailDict = chatModel;
        toCtrol.singleContactEntity = self.singleContactEntity;
        if (@available(iOS 13.0, *)) {
            toCtrol.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:toCtrol animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
        }];
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
    }else if(messageType == SecretLetterType_receiveBackMessage){
        self.dataArr = [NSMutableArray new];
        [self initScoket];
    }
    
    
    
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

//9001
//显示xx条消息未读
-(void)showUnreadedMessageCount:(NSArray *)getArr{
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

//收到服务器回应 基础设置相关
-(void)receivedServerAndInit{
    //请求成功后 就不再进行请求了
    [NFUserEntity shareInstance].isNeedRefreshChatData = NO;
    self.historyIndex = 0;
    self.IsHaveNotRead = NO;
    self.isCanSendMessage = YES;//连接成功 可以发送消息
    lookDetailBtn.userInteractionEnabled = YES;
    self.backBtn.userInteractionEnabled = YES;
    [SVProgressHUD dismiss];
}

-(void)navigationTitleAnimalFirst{
    if (enteringStatus) {
        self.navigationItem.title = @"对方正在输入.";
        [self performSelector:@selector(navigationTitleAnimalSecond) withObject:nil afterDelay:0.5];
    }
}

-(void)navigationTitleAnimalSecond{
    if (enteringStatus) {
        self.navigationItem.title = @"对方正在输入..";
        [self performSelector:@selector(navigationTitleAnimalThree) withObject:nil afterDelay:0.5];
    }
}

-(void)navigationTitleAnimalThree{
//    if (enteringStatus) {
    enteringStatus = YES;
        self.navigationItem.title = @"对方正在输入...";
//        [self performSelector:@selector(navigationTitleAnimalFirst) withObject:nil afterDelay:0.5];
//    }
}

#pragma mark - 将取出的实体转成messageFrame
-(void)DealDataToLocalController:(NSArray *)arr{
    for (MessageChatEntity *entity in arr) {
        //收到消息
        UUMessageFrame *messageFrame = [self MessageChatEntityToUUMessageFrame:entity];
        //执行完最后 将实体保存起来
        lastEntity = entity;
        [self.dataArr addObject:messageFrame];
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
        strongSelf ->dataCount =  [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
    }];
    //判断count 是否大于10 否则从0到10
    if (dataCount > refreshCount) {
        //当来自搜索历史
//        if (self.historyIndex > 15) {
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
    __block NSArray *arr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    if (self.historyIndex>15) {
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,strongSelf.historyIndex]];
        }];
    }else{
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount,refreshCount]];
        }];
    }
    
//    dispatch_queue_t queue = dispatch_queue_create("JoeQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^(void) {
        //取出来后判断第一个数据是否失效
        if (arr.count == 0) {
            return @[];
        }
//        MessageChatEntity *IsYinCangEntity = arr[arr.count - 1];
    MessageChatEntity *IsYinCangEntity = [arr lastObject];
        BOOL IsYinCangRet = [NFbaseViewController compaTodayDateWithDate:IsYinCangEntity.localReceiveTime];
        //如果需要隐藏 则将之前所有数据都设置隐藏
        if (!IsYinCangRet && ![IsYinCangEntity.yuehouYinCang isEqualToString:@"1"]) {
            //如果将之前的数据都隐藏了 则不能够刷新了
            canRefresh = NO;
//            NSArray *yincangArr = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit 0,%d",dataCount]];
            __block NSArray *yincangArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                yincangArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
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
                [self.myManage changeFMDBData:entity KeyWordKey:@"chatId" KeyWordValue:entity.chatId FMDBID:@"tongxun.sqlite" TableName:self.singleContactEntity.friend_userid];
            }
        }
        //取出来第一个数据是否删除
//        BOOL IsShanChuRet = [NFbaseViewController compaTodayDateReturnDeleteWithDate:IsYinCangEntity.localReceiveTime];
//        //如果需要隐藏 则将之前所有数据都设置隐藏
//        if (!IsShanChuRet) {
//            NSArray *yincangArr = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit 0,%d",dataCount]];
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
//                    [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:self.singleContactEntity.friend_userid DataKind:[MessageChatEntity class] KeyName:@"chatId" ValueName:entity.chatId];
//                }else{
//                    [self.myManage changeFMDBData:entity KeyWordKey:@"chatId" KeyWordValue:entity.chatId FMDBID:@"tongxun.sqlite" TableName:self.singleContactEntity.friend_userid];
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
    NSMutableArray *arr =[NSMutableArray new];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    for (UUMessageFrame *entity in self.dataArr) {
        UUMessage *message = entity.message;
        //获取消息的时间戳
        message.localReceiveTime = [message.localReceiveTimeString integerValue];
        //看看是否设置了隐藏
//        NSString *yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
        //如果未设置隐藏或设置了为不隐藏 则 直接add【懒加载】
        if ([yuehouString isEqualToString:@"不隐藏"] || !yuehouString) {
            [arr addObject:entity];
            continue;
        }
        //判断该消息是否已经隐藏
        if (![message.yuehouYinCang isEqualToString:@"1"]) {
            //如果没有隐藏 则判断是否需要隐藏
            BOOL ret = [NFbaseViewController compaTodayDateWithDate:message.localReceiveTime];
            //            NSLog(@"%d",ret);
            //如果是yes 说明消息没有过期 如果为0 则需要修改缓存里面的数据 或参数为1
            if (!ret) {
                //懒加载 【当该条信息需要背隐藏时，判断一下它是否已经是隐藏状态 已经隐藏则不进行更新缓存的隐藏标记】
                if (![message.yuehouYinCang isEqualToString:@"1"]) {
                    message.yuehouYinCang = @"1";
                    [entity setMessage:message];
                    //并更改缓存的值  UUMessageFrame转 MessageChatEntity
                    MessageChatEntity *chatEntity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:entity];
                    //关键修改这个 隐藏属性
                    chatEntity.yuehouYinCang = @"1";
//                    NSArray *arr = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:strongSelf.singleContactEntity.friend_userid dicOrModel:chatEntity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
                        if (rett) {
                            NSLog(@"更新success");
                        }
                    }];
                }
            }
        }
        [arr addObject:entity];
    }
    //如果为显示隐藏消息 则显示所有隐藏消息
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
        if (![message.yuehouYinCang isEqualToString:@"1"] && ![message.guanjiShanChu isEqualToString:@"1"]) {
            [lastArr addObject:uuEntity];
        }else{
//            NSLog(@"ss");
            if ([NFUserEntity shareInstance].showHidenMessage) {
                [lastArr addObject:uuEntity];
            }
        }
    }
    //先不考虑 阅后隐藏
    self.dataArr = [NSMutableArray arrayWithArray:lastArr];
//    [self.dataArr addObjectsFromArray:lastArr];
}

//懒加载
-(NSMutableDictionary *)cacheDataRowSendStatusDict{
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

-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

//懒加载
-(dispatch_group_t)completionGroup{
    if (!_completionGroup) {
        _completionGroup = dispatch_group_create();
    }
    return _completionGroup;
}

#pragma mark - 初始化scoket
-(void)initScoket{
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
    //取最后一条消息实体
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block int dataaCount = 0;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
    }];
//    NSArray *arrs = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
    //一般下面arr只有一条
    __block NSArray *cacheArr = [NSArray new];
    dispatch_group_t group = dispatch_group_create();
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_group_enter(group);
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            cacheArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,2]];
        }];
        dispatch_group_leave(group);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
//    NSArray *cacheArr = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
    
    if (cacheArr.count > 0) {
        self.chatEntity = [cacheArr lastObject];
        
        MessageChatEntity *entit = [cacheArr lastObject];
        entit.redpacketDict = [self dictionaryWithJsonString:entit.redpacketString];
        NSLog(@"redpacketDict = %@",entit.redpacketDict);
        if (!self.chatEntity.chatId) {
            self.chatEntity.chatId = @"0";
        }
        
        if (dataaCount > 15) {
            //如果历史消息大于15条 那么取倒数16条为lastentity 后面与取出的15条的第一条【倒数15条进行对比是否需要显示时间】
            __block NSArray *showheadTimeArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                showheadTimeArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 15 - 1,2]];
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
    //连接状态并且为可请求
//    if (socketModel.isConnected && [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory && [ClearManager getNetStatus]) {
    if (socketModel.isConnected  && [ClearManager getNetStatus]) {
        //只有didload走这里 到这里将缓存中的消息 add到界面
        [self countDataCount];
        NSArray *arr = [self showHistoryData];
        [self DealDataToLocalController:arr];
        [self initLegalData];
        [self.chatTableView reloadData];//单聊这里不写也没事 下面方法朝阳能到最底部，群聊就不行 必须要reloaddata
        if (self.historyIndex > 0) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - self.historyIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }else{
            [self tableViewScrollToBottomOffSet:0 IsNeedAnimal:NO];
        }
        
        if(!self.IsFromCard){
            //请求聊天内容消息历史
            [self getSingelChatData];
        }
        
    }else{
        //计算dataCount 从表某个位置取值
        [self countDataCount];
        //取展示的缓存 包括数据库整理
        lastEntity = nil;
        //拉取本地缓存 进行初始化数据 防止为清除过缓存
        self.dataArr = [NSMutableArray new];
        NSArray *arr = [self showHistoryData];
        // 将取出的缓存 赋值到界面数组
        [self DealDataToLocalController:arr];
        [self initLegalData];
//        [socketModel initSocket];
        [self.chatTableView reloadData];
        if (self.dataArr.count > 0) {
            //没有这个 会出现最后一张图片显示一半
            [self tableViewScrollToBottomOffSet:0 IsNeedAnimal:NO];
            //没有这个会有tableview从顶到底一闪
            NSIndexPath *index_ = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:index_ atScrollPosition:(UITableViewScrollPositionBottom) animated:NO];
        }else{
            [self.chatTableView reloadData];
        }
    }
}

-(void)initUI{
    self.chatTableView.backgroundColor = UIColorFromRGB(0xf2f9ff);
    if (kTabBarHeight > 69) {
        self.bottomConstraint.constant = 50 + kTabbarMoreHeight;
    }
    lookDetailBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    lookDetailBtn.tag = 2;
    [lookDetailBtn setImage:[UIImage imageNamed:@"单聊详情"] forState:UIControlStateNormal];
    [lookDetailBtn addTarget:self action:@selector(GrouplookDtailClick:) forControlEvents:UIControlEventTouchUpInside];
    //防止按钮事件重复执行
//    lookDetailBtn.timeInterval = 2;
    UIBarButtonItem *lookDtailButtonItem = [[UIBarButtonItem alloc]initWithCustomView:lookDetailBtn];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [button setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [button setTitle:@"断线" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(GrouplookDtailClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *ButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
//    self.navigationItem.rightBarButtonItems = @[lookDtailButtonItem,ButtonItem];;
    self.navigationItem.rightBarButtonItem = lookDtailButtonItem;
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - _chatTableView.bounds.size.height, _chatTableView.frame.size.width, _chatTableView.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        
        [_chatTableView addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
    //下面再创建其他例如tableview，topview等，不然刷新将会无效
    self.IFView_ = [[UUInputFunctionView alloc] initWithSuperVC:self];
    self.IFView_.delegate = self;
    self.IFView_.isNeedBlock = YES;
    self.IFView_.superTableview = self.chatTableView;
    self.IFView_.backgroundColor = UIColorFromRGB(0xededed);
    CGRect rect =  self.IFView_.frame;
    __weak typeof(self)weakSelf = self;
    //点中编辑后
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    __weak UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    [self.IFView_ EditTextview:^{
        if ([currentVC isKindOfClass:[weakSelf class]]) {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //
            CGFloat offSet = strongSelf ->sendMessageJustnow==YES?45:0;
//            offSet = 0;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                [weakSelf tableViewScrollToBottomOffSet:offSet IsStrongToBottom:YES];
            });
            
            
//            MessageTableViewCell *cell = (MessageTableViewCell *)[strongSelf.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
//            NSLog(@"%f",CGRectGetMaxY(cell.frame));
//            [self.chatTableView scrollToBottomWithAnimation:YES offset:0];
//            if (keyboardHeight + CGRectGetMaxY(self.chatTableView.frame) + 64 + 50 != SCREEN_HEIGHT) {
//                self.chatTableView.frame = CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50 - keyboardHeight);
//                [self.chatTableView layoutIfNeeded];
//            }
            strongSelf ->sendMessageJustnow = NO;
            //正在输入请求
            [weakSelf enteringRequesst];
            weakSelf.historyIndex = 0;
        }
    }];
    
//    //结束编辑后
    [self.IFView_ EndEditBlock:^{
        //结束正在输入请求
        if ([currentVC isKindOfClass:[weakSelf class]]) {
            [weakSelf tableViewScrollToBottomOffSet:0 IsStrongToBottom:NO];
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (!strongSelf -> IsFromLongTap) {
                [weakSelf enteringEndRequest];
            }else{
                //跳过后，初始化出处为no 不干预正常结束编辑
                strongSelf -> IsFromLongTap = NO;
            }
        }
    }];
////    //正在编辑时
    [self.IFView_ textEditingBlock:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf -> enteringLength++;
        if (strongSelf -> enteringLength>=10) {
            strongSelf -> enteringLength = 0;
            [weakSelf enteringRequesst];
        }
    }];
    //删除收藏的图片
    [self.IFView_ deleteCollectPicture:^(NSString *fileId) {
        socketRequest = [SocketRequest share];
        [socketRequest deleteCollectEmoji:@{@"file_id":fileId}];
    }];
    //删除 self
//    [self.IFView_ destorySelfClick:^{
//        //IFView_.de
//
//    }];
    
    
    [self.view addSubview:self.IFView_];
    
    //单机版 - (void)moreViewType:(YTMoreViewTypeAction)type{
    //发红包 按钮
    [self.IFView_ clickRedpacket:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //点击了红包按钮
        //发红包
        if([strongSelf.singleContactEntity.friend_username isEqualToString:@"duoxinkefu"]){
            [SVProgressHUD showInfoWithStatus:@"不允许发红包给客服"];
            return ;
        }
        [strongSelf tapTableView];
//        ZJContact *contact = [self.groupCreateSEntity.groupAllUser lastObject];
        [[NTESRedPacketManager sharedManager] sendRedPacket:@{@"groupId":@"",@"receiveId":self.singleContactEntity.friend_userid}];
        
    }];
    
    //转账按钮
    [self.IFView_ clickTransferAccont:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //点击了红包按钮
        //[SVProgressHUD showInfoWithStatus:@"暂未开放"];
       // return ;
        
        if([strongSelf.singleContactEntity.friend_username isEqualToString:@"duoxinkefu"]){
            [SVProgressHUD showInfoWithStatus:@"不允许给客服转账"];
            return ;
        }
        [strongSelf tapTableView];
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"HuiFuPayStoryboard" bundle:nil];
        TransferAccountTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"TransferAccountTableViewController"];
        toCtrol.contactt = self.singleContactEntity;
        if (@available(iOS 13.0, *)) {
            toCtrol.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:toCtrol animated:YES completion:^{
            NSLog(@"in--SendRedPacketVC");
        }];
    }];
    
    //推送名片按钮
    [self.IFView_ setClickCard:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //点击了名片
        if([strongSelf.singleContactEntity.friend_username isEqualToString:@"duoxinkefu"]){
            [SVProgressHUD showInfoWithStatus:@"不允许推送名片给客服"];
            return ;
        }
        [strongSelf tapTableView];
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        toCtrol.SourceType = SourceTypeFromRecommendCard;
        toCtrol.chatContact = strongSelf.singleContactEntity;
        toCtrol.contentType = @"4";
        [strongSelf.navigationController pushViewController:toCtrol animated:YES];
        
    }];
    
    //add notification
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTableView)];
    tap.delegate = self;
    tap.numberOfTouchesRequired = 1;
    [_chatTableView addGestureRecognizer:tap];
    _chatTableView.tableFooterView = [UIView new];
    //底部编辑菜单【删除】
    bottomEditView = [[[NSBundle mainBundle]loadNibNamed:@"bottomEditMenuView" owner:nil options:nil] firstObject];
    bottomEditView.frame = CGRectMake(0, SCREEN_HEIGHT - kTopHeight - kTabBarHeight, SCREEN_WIDTH, 50);
    [bottomEditView.deleteBtn addTarget:self action:@selector(deleteCommitClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    //初始化 新消息按钮 newMessageBottomButton
    newMessageBottomButton = [UIButton new];
    [newMessageBottomButton setTitle:@"有新消息" forState:(UIControlStateNormal)];
    newMessageBottomButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [newMessageBottomButton setTitleColor:UIColorFromRGB(0x39a86b) forState:(UIControlStateNormal)];
//    newMessageBottomButton = [UIColor yellowColor];
    [newMessageBottomButton setBackgroundImage:[UIImage imageNamed:@"有新消息半圆角矩形"] forState:UIControlStateNormal];
    [newMessageBottomButton addTarget:self action:@selector(scrollToBottom) forControlEvents:(UIControlEventTouchUpInside)];
    newMessageBottomButton.alpha = 0;
    [self.view addSubview:newMessageBottomButton];
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
    [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
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
        NSInteger totalCount =  [strongSelf ->jqFmdb jq_tableItemCount:self.singleContactEntity.friend_userid];
        arr = [strongSelf ->jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",totalCount - a,totalCount - 1]];
    }];
    totalNewMessageCount = 0;
    self.dataArr = [NSMutableArray new];
    [self DealDataToLocalController:arr];
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press{
    NSLog(@"");
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] && self.chatTableView.editing) {
        CGPoint currentTouchPosition = [touch locationInView:self.chatTableView];
        NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:currentTouchPosition];
        MessageTableViewCell  * cell = (MessageTableViewCell *)[self.chatTableView cellForRowAtIndexPath:indexPath];
//        if (cell.selected && firstSelectDelete && clickMoreIndexPath == indexPath) {
        if (cell.selected) {//当点击的cell为cell的selected状态 不走diddeselected方法
            [cell setSelected:NO animated:YES];
            firstSelectDelete = NO;
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

#pragma mark - 右侧按钮
-(void)GrouplookDtailClick:(UIButton *)sender{
    
    
    [SVProgressHUD dismiss];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    SingleChatDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SingleChatDetailTableViewController"];
    //singleEntity
    //        toCtrol.singleEntity = self.singleEntity;
    toCtrol.singleContactEntity = self.singleContactEntity;
    toCtrol.conversationId = self.conversationId;
    __weak typeof(self)weakSelf=self;
    [toCtrol setReturnDeleteBlock:^(BOOL IsDelete) {
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf->lastEntity = nil;
        strongSelf.unreadCount = 0;
        strongSelf.dataArr = [NSMutableArray new];
        strongSelf->dataCount = 0;
        [strongSelf.chatTableView reloadData];
    }];
    [self cacheConversationList];
    [self.navigationController pushViewController:toCtrol animated:YES];
    
//        [socketModel disConnect];
    
}

//测试
-(void)GrouplookDtailClick{
    [SVProgressHUD dismiss];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    SingleChatDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SingleChatDetailTableViewController"];
    //singleEntity
    //        toCtrol.singleEntity = self.singleEntity;
    toCtrol.singleContactEntity = self.singleContactEntity;
    toCtrol.conversationId = self.conversationId;
    
    [socketModel disConnect];
    
    //    [self.navigationController pushViewController:toCtrol animated:YES];
    
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
    CGFloat animationTime = AnimationTime;
    animationTime = 2;
    if (self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected) {
        animationTime = 0.01;
    }
    __weak typeof(self)weakSelf=self;
    if(self.chatTableView.frame.origin.y != 0){
        self.chatTableView.frame = CGRectMake(0, 0, self.chatTableView.frame.size.width, self.chatTableView.frame.size.height);
    }
     CGRect frame = self.chatTableView.frame;
        __strong typeof(weakSelf)strongSelf=weakSelf;
        if (notification.name == UIKeyboardWillShowNotification) {
            keyboardHeight = keyboardEndFrame.size.height;
            
            //当为x 键盘输入的时候 tableview约束不用加50
            if ( !self.IFView_.btnSendMessage.selected && !self.IFView_.emojiBtn.selected) {
                
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
                    if (self.chatTableView.contentSize.height > showHeight) {
                        offset = self.chatTableView.contentSize.height - showHeight;
                    }
                    
                    
                    NSLog(@"y = %f",self.chatTableView.frame.origin.y);
                    //[self.GroupChatTableView setContentOffset:CGPointMake(0, offset)];
                    //[self.GroupChatTableView SendMessageLetTableScrollToBottomBegin:YES offset:offset];
                    [self.chatTableView SendMessageLetTableScrollToBottom:YES offset:offset];
                    
                
//                //当界面显示的数据不会被键盘遮挡 则不让frame发生变化
//                CGRect rectInTableView;
//                NSLog(@"height = %f",self.chatTableView.contentSize.height);
//                NSLog(@"height = %f",self.chatTableView.frame.size.height);
//
//                if (self.dataArr.count > 0) {
//                    rectInTableView = [self.chatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
//                }else{
//                    rectInTableView = CGRectMake(0, 0, 0, 0);
//                }
//                NSInteger IsX = 0;
//                if (kTabBarHeight > 69){
//                    IsX = kTabbarMoreHeight+ kStatusBarMoreHeight;
//                }
//                //聊天记录高度低于tableview高度
//                if (CGRectGetMaxY(rectInTableView) + 64 < SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - IsX) {
//                    //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
//                    NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - 10));
//                }else{
//                    CGFloat changeHeight = (CGRectGetMaxY(rectInTableView) + 64 + keyboardEndFrame.size.height + 50) - SCREEN_HEIGHT;
//                    if (kTabBarHeight > 69){
//                        changeHeight += kTabbarMoreHeight;
//                    }
//                    if (changeHeight > keyboardEndFrame.size.height ) {
//                        changeHeight = keyboardEndFrame.size.height ;
//
//                    }
//
//                    //当tableview的 frame的y大于0 才让tableview上移 【表情、更多弹出时除外】
////                    frame.origin.y -= keyboardEndFrame.size.height;
//                    frame.origin.y -= changeHeight;
//                    //
//                    if (kTabBarHeight > 69 && changeHeight >= keyboardEndFrame.size.height){
//                        //因为当键盘弹起来的时候 tabbar高出的35 被去掉了 所以这里需要减去35
//                        frame.origin.y += kTabbarMoreHeight;
//                    }
//                    self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
////                    frame.origin.y -= 30;
////                    frame.size.height += 30;
//
//                    [UIView animateWithDuration:animationTime animations:^{
//                        dispatch_async(dispatch_get_main_queue(), ^(void) {
//                            self.chatTableView.frame = frame;
//                        });
//                    }];
//
//                }
//                if (self.dataArr.count > 0) {//键盘弹起 tableview滑到底部
//                    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
//                }
//                if (self.chatTableView.contentSize.height > self.chatTableView.frame.size.height) {
//                    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
//                }
                
                
            }else if (self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected){
                //当表情或更多弹出时 点击键盘 应该喝上面一样的逻辑 看看界面是否会被遮挡
                CGRect rectInTableView;
                if (self.dataArr.count > 0) {
                    rectInTableView = [self.chatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
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
                
                if (self.chatTableView.contentSize.height < showHeight) {
                    //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
                    NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - 10));
                }else{
                    CGFloat offset = 0.0;
                    if (self.chatTableView.contentSize.height > showHeight) {
                        offset = self.chatTableView.contentSize.height - showHeight;
                    }
                    NSLog(@"y = %f",self.chatTableView.frame.origin.y);
                    //[self.GroupChatTableView setContentOffset:CGPointMake(0, offset)];
                    //[self.GroupChatTableView SendMessageLetTableScrollToBottomBegin:YES offset:offset];
                    [self.chatTableView SendMessageLetTableScrollToBottom:YES offset:offset];
                    
                    
                }
            }
//            else{
//                CGRect frame = self.chatTableView.frame;
//                frame.origin.y = 0;
//                self.chatTableView.frame = frame;
//            }
            
//            if (kTabBarHeight > 49) {
//                self.bottomConstraint.constant = keyboardEndFrame.size.height+10;
//            }else{
//                self.bottomConstraint.constant = keyboardEndFrame.size.height+50;
//            }
            strongSelf -> keyboardHeight = keyboardEndFrame.size.height;
        }else{
            CGRect frame = self.chatTableView.frame;
            frame.origin.y = 0;
            
            [UIView animateWithDuration:animationTime animations:^{
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    self.chatTableView.frame = frame;
                });
            }];
            
            
            keyboardHeight = 0;
        }
        //[self.view layoutIfNeeded];
    
    //如果 这里tableview最大Y不对则进行更改 【当上面动画还未执行时候 这里已经修改了】 底部约束要到view
//    if (notification.name == UIKeyboardWillShowNotification && CGRectGetMaxY(self.chatTableView.frame) < SCREEN_HEIGHT - keyboardEndFrame.size.height - 50 - 64 - 40) {
//        CGRect rect = self.chatTableView.frame;
//        rect.size.height += 50;
//        self.chatTableView.frame = rect;
//    }else if(notification.name == UIKeyboardWillHideNotification && CGRectGetMaxY(self.chatTableView.frame) < SCREEN_HEIGHT - 64 - 50 - 40){
//        CGRect rect = self.chatTableView.frame;
//        rect.size.height += 50;
//        self.chatTableView.frame = rect;
//    }
    
}

#pragma mark - 键盘高度
-(CGFloat)heightOfkeyboard:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    return keyboardEndFrame.size.height;
}

#pragma mark - InputFunctionViewDelegate 1 发送消息、图片、语音
-(void)UUInputFunctionView:(UUInputFunctionView *)funcView showMessage:(NSString *)message SendMessage:(NSString *)sendMessage{
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    
    if (![self beforeSendMessageCheck]) {
        return;//如果为No 则return
    }
    //这里记录发送了消息
//    sendMessage = YES;
    //生成chatid
    sendMessageJustnow = YES;//发过消息 点击输入框 会有遮挡 这里记录下发过信息
    NSString *AppMessageId = [ClearManager getAPPMsgId];
    NSDictionary *dic = @{@"strContent": message, @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"chatId":@"",@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": AppMessageId};
    
    if (funcView.TextViewInput.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"不可发送空消息"];
        return;
    }
    
//    NSString*temp = [funcView.TextViewInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if ([temp length] ==0) {
//        [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
//        return;
//    }
    //如果能发送 则将发送的内容置空
//    if (socketModel.isConnected) {
//        [funcView changeSendBtnWithPhoto:YES];
//    }
    //发送消息给服务器
//    if (![ClearManager getNetStatus]) {
//        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
//        return;
//    }
//    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
//        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
//        return;
//    }
    
    if (funcView.TextViewInput.text.length > 20000) {
        [SVProgressHUD showInfoWithStatus:@"消息过长"];
        return;
    }
    [socketModel ping];
    if (![socketModel isConnected]) {
        //缓存消息 等待发送
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSArray *messageArr = [defaults objectForKey:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userId,@"SingleSend"]];
//        NSMutableArray *messageMutableArr = [NSMutableArray arrayWithArray:messageArr];
//        [messageMutableArr addObject:dic];
//        messageArr = [NSArray arrayWithArray:messageMutableArr];
//        [defaults setObject:messageArr forKey:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userId,@"SingleSend"]];
    }
    if ([SocketModel share].isConnected || YES){
//        [SVProgressHUD show];
        funcView.TextViewInput.text = @"";
        [self dealTheFunctionData:dic IsConnected:YES];
    }else{
        if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
            return;
        }
        [SVProgressHUD showWithStatus:@"正在重连"];
        //连上后先请求消息历史
        [socketModel initSocket];
        __weak typeof(self)weakSelf=self;
        __weak NSDictionary *dict = dic;
        messageWaitSendDict = dic;
        [socketModel returnConnectSuccedd:^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if (![currentVC isKindOfClass:[MessageChatViewController class]]) {
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory = YES;
                
                //下面等同于一个任意请求 这时候该账号是断线状态 服务器会返回1003，然后自动登陆重连，再在didreceive中的登陆成功里面请求消息历史和发送单聊
//                [weakSelf dealTheFunctionData:messageWaitSendDict IsConnected:NO];
                [socketRequest getIsExistUnReadApply];
//                [socketModel sendhert];
                funcView.TextViewInput.text = @"";
//                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                NSArray *messageArr = [defaults objectForKey:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userId,@"SingleSend"]];
//                for (NSDictionary *messageDict in messageArr) {
//                    [self dealTheFunctionData:messageDict IsConnected:NO];
//                }
//                [defaults removeObjectForKey:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userId,@"SingleSend"]];
            });
        }];
    }
}

//IsselectedOrginalImage
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image IsselectedOrginalImage:(BOOL)ret{
    if (image.imageOrientation == 3) {
        image = [image rotate:UIImageOrientationRight];
    }
    BOOL netRet = [self beforeSendMessageCheck];//查看是否能发送
    [SVProgressHUD dismiss];//第一次检查 直接消失
    if (netRet) {
        isOriginalImage = ret;
        //判断图片是否被旋转过 如果旋转过 则向右旋转90度
        NSString *current = [NFMyManage getCurrentTimeStamp];
        //    NSString *chatId = [NSString stringWithFormat:@"%@%@",current,[NFUserEntity shareInstance].userId];
        NSString *chatId = @"";
        NSDictionary *dic = @{@"picture": image, @"type":@(UUMessageTypePicture),@"chatId":chatId};
        
        //进行http请求 先上传图片 然后根据服务器返回的url进行发送图片
//        [self uploadPictureImage:image IsselectedOrginalImage:ret];
        
        [self aliyunUploadPictureImage:image IsselectedOrginalImage:ret];
        
        [self tapTableView];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self beforeSendMessageCheck]) {//这时候如果还是未连接 则提示
                isOriginalImage = ret;
                //判断图片是否被旋转过 如果旋转过 则向右旋转90度
                
                NSString *current = [NFMyManage getCurrentTimeStamp];
                //    NSString *chatId = [NSString stringWithFormat:@"%@%@",current,[NFUserEntity shareInstance].userId];
                NSString *chatId = @"";
                NSDictionary *dic = @{@"picture": image, @"type":@(UUMessageTypePicture),@"chatId":chatId};
                
                //进行http请求 先上传图片 然后根据服务器返回的url进行发送图片
                [self tapTableView]; //
                [self uploadPictureImage:image IsselectedOrginalImage:ret];
                
            }else{
                
            }
        });
    }
    
    
    
    
    
    return;
    
    //发送消息给服务器
//    [socketModel ping];
//    if ([SocketModel share].isConnected){
//        [self dealTheFunctionData:dic IsConnected:YES];
//        //发送图片时候 超时计算取消
//        [NFUserEntity shareInstance].timeOutCountBegin = NO;
//    }else{
//        [SVProgressHUD showWithStatus:@"正在重连"];
//        [socketModel initSocket];
//        __weak typeof(self)weakSelf=self;
//        __weak NSDictionary *dict = dic;
//        messageWaitSendDict = dic;
//        [socketModel returnConnectSuccedd:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//                if (![currentVC isKindOfClass:[MessageChatViewController class]]) {
//                    return ;
//                }
//                [SVProgressHUD showSuccessWithStatus:@"重连成功"];
//                [weakSelf dealTheFunctionData:dict IsConnected:YES];
//                //发送图片时候 超时计算取消
//                [NFUserEntity shareInstance].timeOutCountBegin = NO;
//            });
//        }];
//    }
}

//{
//    appMsgId = 2020031803303830a111111;
//    fileExt = jpeg;
//    fileMime = "image/jpeg";
//    fileName = "photo.jpeg";
//    filePath = "2020-03-18/5e71ce17ab3ba.jpeg";
//    fileSize = 569876;
//    fileUniqueName = "5e71ce17ab3ba.jpeg";
//    imgHeight = 550;
//    imgRatio = "1.51000000000000000888178419700125232338";
//    imgWidth = 828;
//    type = 1;
//    url = "http://121.43.116.159:7999/web_file/Public/uploads/2020-03-18/5e71ce17ab3ba.jpeg";
//}

#pragma mark -   //发送收藏的图片
-(void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPictureDict:(NSDictionary *)dictt{
    
    NSString *fileExt = @"jpeg";
    NSString *fileMime = @"image/jpeg";
    NSString *fileName = @"photo.jpeg";
    NSArray *arr = [[dictt objectForKey:@"picpath"] componentsSeparatedByString:@"/"];
    NSString *filePath = arr.count>1?[NSString stringWithFormat:@"%@/%@",arr[arr.count - 2],[arr lastObject]]:@"";
    NSString *fileUniqueName = [[dictt objectForKey:@"picpath"] description].lastPathComponent;
    NSDictionary *dic = @{@"url": [dictt objectForKey:@"picpath"], @"type":@(UUMessageTypePicture),@"fileExt":fileExt,@"fileMime":fileMime,@"fileName":fileName,@"filePath":filePath,@"fileSize":@"500000",@"fileUniqueName":fileUniqueName,@"imgHeight":@"",@"imgRatio":[[dictt objectForKey:@"scale"] floatValue]>0?[dictt objectForKey:@"scale"]:@"1",@"imgWidth":@"",@"appMsgId":[ClearManager getAPPMsgId],@"file_id":[dictt objectForKey:@"fileId"]};
    [socketModel ping];
    if ([SocketModel share].isConnected || YES){
        [self dealTheFunctionData:dic IsConnected:YES];
        //发送图片时候 超时计算取消 【用http进行上传图片了 这里发的图片就是一个地址 和文字消息一样】
        //                    [NFUserEntity shareInstance].timeOutCountBegin = NO;
    }
    
}




- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    if (![self beforeSendMessageCheck]) {
        return;//如果为No 则return
    }
    NSString *current = [NFMyManage getCurrentTimeStamp];
//    NSString *chatId = [NSString stringWithFormat:@"%@%@",current,[NFUserEntity shareInstance].userId];
    NSString *chatId = @"";
    NSString *AppMessageId = [ClearManager getAPPMsgId];
    NSDictionary *dic = @{@"voice": voice, @"strVoiceTime":[NSString stringWithFormat:@"%d",(int)second], @"type":@(UUMessageTypeVoice),@"chatId":chatId,@"appMsgId": AppMessageId};
    
    //http请求 上传语音
    
    //发送消息给服务器
    [socketModel ping];
    if ([SocketModel share].isConnected || YES){
        [self dealTheFunctionData:dic IsConnected:YES];
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
                if (![currentVC isKindOfClass:[MessageChatViewController class]]) {
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                [weakSelf dealTheFunctionData:dict IsConnected:YES];
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
            if ([SocketModel share].isConnected || YES){
                [self dealTheFunctionData:dic IsConnected:YES];
                //发送图片时候 超时计算取消 【用http进行上传图片了 这里发的图片就是一个地址 和文字消息一样】
    //                    [NFUserEntity shareInstance].timeOutCountBegin = NO;
            }
        }];
    
}


#pragma mark - http上传图片
-(void)uploadPictureImage:(UIImage *)image IsselectedOrginalImage:(BOOL)ret{
    //[SVProgressHUD show];
//    [PHProgressHUD showSingeWheelWithMsg:@"上传中" view:self.chatTableView];
   MBProgressHUD *hud = [MBProgressHUD showOnlyLoadToView:self.view];
//    hud.tintColor = [UIColor redColor];
//    hud.backgroundColor = [UIColor redColor];
    
//    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    hud.bezelView.color = [UIColor lightGrayColor];
    
    //上传头像
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSData *imageData;
    if (ret) {
//        imageData = UIImageJPEGRepresentation(image, 0.9);
        imageData = UIImageJPEGRepresentation(image, 1);
    }else{
        imageData = [ClearManager imageDataScale:image scale:1];
//        imageData = UIImageJPEGRepresentation(image, 0.5);
//        if (imageData.length > 1200000) {
//            imageData = UIImageJPEGRepresentation(image, 0.3);
//        }
//        if (imageData.length > 1200000) {
//            imageData = UIImageJPEGRepresentation(image, 0.1);
//        }
    }
    //    imageData = UIImagePNGRepresentation(image);
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
                if ([SocketModel share].isConnected || YES){
                    [self dealTheFunctionData:dic IsConnected:YES];
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



#pragma mark - 发送消息给服务器2
- (void)dealTheFunctionData:(NSDictionary *)dic IsConnected:(BOOL)ret
{
    //进行更改数据库字段
    [self.fmdbServicee IsExistSingleChatHistory:self.singleContactEntity.friend_userid];
    __weak typeof(self)weakSelf=self;
    dispatch_group_t group = dispatch_group_create();
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_group_enter(group);
        [weakSelf addSpecifiedItem:dic];
        dispatch_group_leave(group);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    [self.chatTableView reloadData];
    //动画下滑到底部
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
    }else{
        showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
    }
    //        NSLog(@"%f",self.chatTableView.contentOffset.y);
    //当内容cell总高度大于contentheight 或 有表情view存在时
    if (self.chatTableView.contentSize.height > showHeight - kTopHeight - kTabBarHeight || !self.IFView_.addFaceView.hidden) {
        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
    }else if (self.IFView_.btnSendMessage.selected){//如果在选图片按钮selected时
        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
    }
    
    //将消息发送给服务器
    
    //type 0文本消息 1图片消息 2语音消息
    if ([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"type"] description]] isEqualToString:@"0"]) {
        //无论有没有网络 都可以发送消息展示
        //不能发送空或 全是空格
        NSString *str = [dic objectForKey:@"strContent"];
        if (str.length == 0) {
            [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
            return;
        }
//        NSString*temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        if ([temp length] ==0) {
//            [SVProgressHUD showInfoWithStatus:@"不能发送空消息"];
//            return;
//        }
        if ([socketModel isConnected]) {
            [socketModel ping];
        }
        if ([SocketModel share].isConnected || YES) {
            //判断链接正常再更新ui
            //处理缓存相关
//            __weak typeof(self)weakSelf=self;
//            dispatch_group_t group = dispatch_group_create();
//            dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//                dispatch_group_enter(group);
//                [weakSelf addSpecifiedItem:dic];
//                dispatch_group_leave(group);
//            });
//            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//            [self.chatTableView reloadData];
//            //动画下滑到底部
//            CGFloat showHeight = 0;
//            if ([self.IFView_.TextViewInput isFirstResponder]) {
//                showHeight = SCREEN_HEIGHT - keyboardHeight;
//            }else{
//                showHeight = SCREEN_HEIGHT ;
//            }
//            //        NSLog(@"%f",self.chatTableView.contentOffset.y);
//            //当内容cell总高度大于contentheight 或 有表情view存在时
//            if (self.chatTableView.contentSize.height > showHeight - 64 - 50 || !self.IFView_.addFaceView.hidden) {
//                [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:YES];
//            }
            
            //发送到服务器
//            NSDate *currentDate = [NSDate date];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"MMddhhmmss"];
            if (![ClearManager getNetStatus]) {
                //没网布发送消息
                return;
            }
            NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
            NSInteger time = interval;
            NSString *createTime = [NSString stringWithFormat:@"%ld",time];
            lastMessageId = [dic objectForKey:@"appMsgId"];
//            NSLog(@"******\n发给服务器的appmessageId:%@\n******",[dic objectForKey:@"appMsgId"]);
            //发送消息
            [self sendMesageFrom:[NFUserEntity shareInstance].userName To:self.singleContactEntity.friend_username Content:[dic objectForKey:@"strContent"] Createtime:createTime AppMsgId:[dic objectForKey:@"appMsgId"]];
        }else{
            //链接不上 提示
//            [SVProgressHUD showErrorWithStatus:kWrongMessage];
        }
    }else if ([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"type"] description]] isEqualToString:@"1"]){
//        //发送图片 展示到界面 无论有没有网络 都展示
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        //joeAvoid
//        if ([currentVC isKindOfClass:[MessageChatViewController class]]) {
////            self.chatTableView.userInteractionEnabled = NO;
//            [self addSpecifiedItem:dic];
//        }else{
//            return;
//        }
//        if (self.dataArr.count > 0) {
//            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.dataArr.count-1 inSection:0];
//            [self.chatTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showSuccessWithStatus:@"发送/成功"];
////                [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//                [self performSelector:@selector(tableViewScrollToBottomOffSet:IsNeedAnimal:) withObject:nil afterDelay:0.25];
////                [self tableViewScrollToBottomOffSet:0 IsNeedAnimal:YES];
//                self.chatTableView.userInteractionEnabled = YES;
//            });
//        }
//        [self.chatTableView reloadData];
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        NSInteger time = interval;
        NSString *createTime = [NSString stringWithFormat:@"%ld",time];
        //发送到服务器
//        NSString *encodedImageStr = [ClearManager UIImageToBase64Str:dic[@"picture"] IsOriginalImage:isOriginalImage];
        NSString *encodedImageStr = dic[@"url"];
        isOriginalImage = NO;
        [self sendMesageFrom:[NFUserEntity shareInstance].userName To:self.singleContactEntity.friend_username ImageContent:encodedImageStr Createtime:createTime pictureInfo:dic APPMsgId:[dic objectForKey:@"appMsgId"]];
    }else if ([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"type"] description]] isEqualToString:@"2"]){
        //语音 展示到界面 无论有没有网络 都展示
//        [self addSpecifiedItem:dic];
//        [self.chatTableView reloadData];
        //发送到服务器
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        NSInteger time = interval;
        NSString *createTime = [NSString stringWithFormat:@"%ld",time];
        //发送到服务器
        NSString *encodedVoiceStr = [dic[@"voice"] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//        NSLog(@"%ld",encodedVoiceStr.length);
        [self sendMesageFrom:[NFUserEntity shareInstance].userName To:self.singleContactEntity.friend_username VoiceContent:encodedVoiceStr Createtime:createTime VoiceTimeLength:[dic objectForKey:@"strVoiceTime"] AppMsgId:[dic objectForKey:@"appMsgId"]];
    }
//    [self tableViewScrollToBottomOffSet:0];
//    NSArray *arrs = [jqFmdb jq_lookupTable:self.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
//    NSLog(@"");
    
}

#pragma mark - 发送文本消息3
- (void)sendMesageFrom:(NSString *)from To:(NSString *)to Content:(NSString *)content Createtime:(NSString *)createtime AppMsgId:(NSString *)msgId{
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"normal";
    newsDic[@"fromName"] = from;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"appMsgId"] = msgId;
    newsDic[@"toName"] = to;
    newsDic[@"toId"] = self.singleContactEntity.friend_userid;
    newsDic[@"content"] = content;
    newsDic[@"createTime"] = createtime;
    newsDic[@"action"] = @"sendMessage";
    newsDic[@"msgClient"] = @"app";
    
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
}

#pragma mark - //发送图片消息
- (void)sendMesageFrom:(NSString *)from To:(NSString *)to ImageContent:(NSString *)content Createtime:(NSString *)createtime pictureInfo:(NSDictionary *)info APPMsgId:(NSString *)appMsgId
{
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"image";
    newsDic[@"fromName"] = from;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"toName"] = to;
    newsDic[@"toId"] = self.singleContactEntity.friend_userid;
//    if ([content isKindOfClass:[NSString class]]) {
//        content = [EmojiShift emojiShiftstring:content];
//    }
    newsDic[@"content"] = @"[图片]";
    newsDic[@"contentType"] = @"1";
    newsDic[@"createTime"] = createtime;
    newsDic[@"action"] = @"sendMessage";
    newsDic[@"appMsgId"] = appMsgId;
    newsDic[@"msgClient"] = @"app";
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
}

#pragma mark - //发送语音消息
- (void)sendMesageFrom:(NSString *)from To:(NSString *)to VoiceContent:(NSString *)content Createtime:(NSString *)createtime VoiceTimeLength:(NSString *)timeLength AppMsgId:(NSString *)msgId
{
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"audio";
    newsDic[@"fromName"] = from;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"toName"] = to;
    newsDic[@"toId"] = self.singleContactEntity.friend_userid;
//    if ([content isKindOfClass:[NSString class]]) {
//        content = [EmojiShift emojiShiftstring:content];
//    }
    newsDic[@"content"] = content;
    newsDic[@"contentType"] = @"2";
    newsDic[@"createTime"] = createtime;
    newsDic[@"action"] = @"sendMessage";
    newsDic[@"audioTime"] = timeLength;
    newsDic[@"appMsgId"] = msgId;
    newsDic[@"msgClient"] = @"app";
    
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
}

#pragma mark - 发红包
-(void)UUInputFunctionView:(UUInputFunctionView *)funcView sendRed:(RedEntity *)redEntity{
    NSLog(@"发送单聊红包");
    [self tapTableView];
    //更过按钮选中取消
    if (self.IFView_.btnSendMessage.selected) {
        self.IFView_.btnSendMessage.selected = NO;
    }
    //type为3 是红包
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat: @"yyyyMMddhhmmssSS"];
    NSString *identifier = [dateFormatter stringFromDate:[NSDate date]];
    //toname toid
    NSDictionary *returnDcit = @{@"chatId":[NSString stringWithFormat:@"%@%@",identifier,[NFUserEntity shareInstance].userId],@"strContent":@"恭喜发财，大吉大利",@"type":@"3",@"userName":self.singleContactEntity.friend_username,@"userId":self.singleContactEntity.friend_userid,@"singleRed":redEntity.redPacketTotalPrice};
    [self addSpecifiedItem:returnDcit];
    [self.chatTableView reloadData];
    CGFloat showHeight = 0;
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        showHeight = SCREEN_HEIGHT - keyboardHeight ;
    }else{
        showHeight = SCREEN_HEIGHT ;
    }
    //        NSLog(@"%f",self.chatTableView.contentOffset.y);
    //当内容cell总高度大于contentheight 或 有表情view存在时
    if (self.chatTableView.contentSize.height > showHeight - 64 - 50 || !self.IFView_.addFaceView.hidden) {
        
        [self tableViewScrollToBottomOffSet:0 IsStrongToBottom:NO];
    }
    
}

#pragma mark - 发送消息后展示、缓存 【执行完后会reloaddata】 ret是否需要add到 界面数组 dataArr上去
- (void)addSpecifiedItem:(NSDictionary *)dic{
#warning 这里需要与服务器核实
    //当收到服务器消息 在缓存中根据chatId查找是否有数据 如果有则不进行缓存和add到界面
//    if ([dic isKindOfClass:[NSDictionary class]] && ![[dic objectForKey:@"userName"] isEqualToString:[NFUserEntity shareInstance].userName]) {
//        NSString *chatId = [[dic objectForKey:@"chatId"] description];
//        if (chatId.length > 0) {
//            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//            __block NSArray *existArr = [NSArray new];
//            __weak typeof(self)weakSelf=self;
//            [jqFmdb jq_inDatabase:^{
//                __strong typeof(weakSelf)strongSelf=weakSelf;
//                existArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",chatId];
//            }];
//            if (existArr.count > 0) {
//                //如果缓存中存在该id记录 则return不用再进行缓存了
//                return;
//            }
//        }
//    }
    
    //记录刷新会话列表 放到最后执行
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    //    [self.fmdbServicee cacheChatListWithZJContact:self.singleContactEntity AndDic:dic];
    
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
    message.chatId = dataDic[@"chatId"];//当自己发的消息 这里没有
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
    }else{
        //如果这条数据上面还有其它缓存没展示 则取出来进行比较是否需要显示时间
        //这里要么datacount大于0 要么leastCount大于0
        if (dataCount > 0 || leastCount >0) {
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *arr = [NSArray new];
            if (dataCount > 0) {
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_username dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->dataCount - 1,1]];
                }];
            }else if (leastCount >0){
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_username dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",strongSelf ->leastCount - 1,1]];
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
    self.sendedMessage = messageFrame;
//    [self.dataArr addObject:messageFrame];
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    entity.IsSingleChat = YES;
    entity.appMsgId = messageFrame.message.appMsgId;//客户端本地数据库 缓存id【用于取服务器返回的chatid】
    lastEntity = entity;
    __weak typeof(self)weakSelf=self;
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:strongSelf.singleContactEntity.friend_userid];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
    }];
    //重复消息 单聊
    if(lastArr.count == 1){
        MessageChatEntity *lastEntity = [lastArr firstObject];
        if ([entity.message_content isEqualToString:lastEntity.message_content] && [entity.localReceiveTimeString isEqualToString:lastEntity.localReceiveTimeString]) {
            //如果有相同消息 则return
            return;
        }
    }
    
    [self.dataArr addObject:messageFrame];
    
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //NSLog(@"strongSelf ->");
        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:strongSelf.singleContactEntity.friend_userid dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            return;
        }
        //        NSArray *arr = [weakSelf showHistoryData];
    }];
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    //这里需不需要刷新？
    //    [self.fmdbServicee cacheChatListWithZJContact:self.singleContactEntity AndDic:dic];
    
}

static NSString *previousTime = nil;

#pragma mark - MessageChatEntity转 UUMessageFrame
-(UUMessageFrame *)MessageChatEntityToUUMessageFrame:(MessageChatEntity *)entity{
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
            [self.myManage changeFMDBData:entity KeyWordKey:@"chatId" KeyWordValue:entity.chatId FMDBID:@"tongxun.sqlite" TableName:self.singleContactEntity.friend_userid];
        }
    }
    messagee.chatId = entity.chatId;
    messagee.userId = entity.user_id;//取了没用 为了和群聊保持一致解析
    messagee.userName = entity.user_name;//取了没用
    messagee.nickName = entity.nickName;//取了没用
    //判断内容的username是否为自己
    messagee.from = [entity.isSelf isEqualToString:@"0"]?UUMessageFromMe:UUMessageFromOther;
    messagee.yuehouYinCang = entity.yuehouYinCang;
    messagee.guanjiShanChu = entity.guanjiShanChu;
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
//    if (entity.invitor.length > 0) {
//        messagee.invitor = entity.invitor;
//        messagee.pulledMemberString = entity.pulledMemberString;
//        messagee.pullType = entity.pullType;
//    }
    if ([entity.type isEqualToString:@"0"]) {
        messagee.type = UUMessageTypeText;
    }else if ([entity.type isEqualToString:@"2"]){
        messagee.type = UUMessageTypeVoice;
    }else if ([entity.type isEqualToString:@"1"]){
        messagee.type = UUMessageTypePicture;
        //当为图片 获取图片名字和比例
        if (entity.pictureScale > 0) {
            messagee.pictureScale = entity.pictureScale;
            messagee.pictureUrl = entity.pictureUrl;
            messagee.fileId = entity.fileId;
        }else{
            messagee.pictureScale = 1;
            messagee.pictureUrl = entity.pictureUrl;
        }
    }else if ([entity.type isEqualToString:@"3"]){
        messagee.type = UUMessageTypeRed;
        messagee.fileId = entity.fileId;
        messagee.redpacketString = entity.redpacketString;
        messagee.redIsTouched = entity.redIsTouched;
    }else if ([entity.type isEqualToString:@"4"]){
        messagee.type = UUMessageTypeRecommendCard;
        messagee.strId = entity.redpacketString;//名片用户id
        messagee.strVoiceTime = entity.strVoiceTime;//名片用户名
        messagee.pictureUrl = entity.pictureUrl;//名片昵称
        messagee.fileId = entity.fileId;//名片头像
    }else if([entity.type isEqualToString:@"5"]){
        messagee.type = UUMessageTypeRedRobRecord;
        messagee.pulledMemberString = entity.pulledMemberString;
        messagee.redpacketString = entity.redpacketString;
        messagee.priceAccount = entity.headPicPath;
    }else if([entity.type isEqualToString:@"6"]){
        messagee.type = UUMessageTypeTransfer;
        messagee.fileId = entity.fileId;
        messagee.redpacketString = entity.redpacketString;
        messagee.priceAccount = entity.headPicPath;
    }else if([entity.type isEqualToString:@"7"]){
        messagee.type = UUMessageTypeSystem;
        messagee.pulledMemberString = entity.pulledMemberString;
    }
    
    //判断内容的username是否为自己
    messagee.from = [entity.isSelf isEqualToString:@"0"]?UUMessageFromMe:UUMessageFromOther;
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


//是否强制scroller到bottom
- (void)tableViewScrollToBottomOffSet:(CGFloat)height IsStrongToBottom:(BOOL)ret{
    
    //当界面数据为0条或显示的contentSize高度大于2倍屏幕高
    //当界面数据大于15条【刚进来是15跳】 这时候不管界面contentsize多高【图片很高 不好考虑】 都需要到底部
    //是否强制到底部ret
    if (self.dataArr.count==0){
        return;
    }
    if (self.dataArr.count==0  && ![self.IFView_.TextViewInput isFirstResponder] && self.dataArr.count > 15 && !ret){
        return;
    }
    //设置tableview的frame 不能让遮挡住
    CGRect frame = self.chatTableView.frame;
    //rectInTableView 这个参数只是为了下面校验。消息是不是很少 不用移动tableview的y
    CGRect rectInTableView = [self.chatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
    CGRect rectInTableViewSec = self.dataArr.count>2?[self.chatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 2 inSection:0]]:rectInTableView;
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
    CGFloat a = 0;//弹出的是键盘还是表情、更多
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        a = keyboardHeight;
    }else if (self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected){
        a=EMOJI_VIEW_HEIGHT;
    }
    
    
    if (CGRectGetMaxY(rectInTableView) + 64 + kTabbarMoreHeight < SCREEN_HEIGHT - a - 50 - kTabBarHeight && NO) {
        //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
        //NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - a - 50));
        
    }else{
        
        if(self.chatTableView.frame.origin.y != 0){
            self.chatTableView.frame = CGRectMake(0, 0, self.chatTableView.frame.size.width, self.chatTableView.frame.size.height);
        }
        CGFloat showHeight = 0;
        if ([self.IFView_.TextViewInput isFirstResponder]) {
            //键盘高度可能已经包括了tabbar高度
            showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - 50;
        }else{
//            showHeight = self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + 50 + kTopHeight):SCREEN_HEIGHT;
            //NSLog(@"kTopHeight = %d",kStatusBarHeight + kNavBarHeight);
            //NSLog(@"kTabBarHeight = %d",kTabBarHeight);
            if(self.IFView_.btnSendMessage.selected || !self.IFView_.addFaceView.hidden){
                showHeight = SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + kTabBarHeight + kTopHeight);
            }else{
                showHeight = SCREEN_HEIGHT - kTopHeight - kTabBarHeight;
            }
            
        }
        CGFloat offset = 0.0;
        if (self.chatTableView.contentSize.height > showHeight) {
            offset = self.chatTableView.contentSize.height - showHeight;
//            if (@available(iOS 13.0, *) || rectInTableView.size.width == 0) {//ios13 消息刷新的时候 最新的消息 尺寸不能及时加到tableview上面去
//            }
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
        
        
       // NSLog(@"y = %f",self.chatTableView.frame.origin.y);
        //[self.GroupChatTableView setContentOffset:CGPointMake(0, offset)];
        //[self.GroupChatTableView SendMessageLetTableScrollToBottomBegin:YES offset:offset];
        
        if(self.chatTableView.contentSize.height > showHeight){
//            [self.chatTableView setContentOffset:CGPointMake(0, offset - 44)];
//            [self.chatTableView setContentOffset:CGPointMake(0, offset)];
           // NSLog(@"self.chatTableView.contentSize.height = %f",self.chatTableView.contentSize.height);
           // NSLog(@"offset = %f",offset);
            
        }
       // NSLog(@"self.chatTableView.contentOffset = %f",self.chatTableView.contentOffset);
        [UIView animateWithDuration:0 animations:^{
//            [self.chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArr.count-1 inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
            [self.chatTableView reloadData];
        } completion:^(BOOL finished) {
            //刷新完成
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                //[NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.chatTableView SendMessageLetTableScrollToBottom:YES offset:offset];
                });
            });
        }];
        
        
        
        
//    CGFloat IsMax = 0;
//    if (CGRectGetMaxY(rectInTableView) + 64 + kTabbarMoreHeight < SCREEN_HEIGHT - a - 50 - kTabBarHeight) {
//        //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
//        NSLog(@"%f",CGRectGetMaxY(rfectInTableView) + 64 - (SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - 50 - 10));
//    }else{
//        CGFloat xxx = 0;
//        if(kTabBarHeight > 69){
//            xxx = 64;
//        }
//
//        CGFloat changeHeight = CGRectGetMaxY(rectInTableView) + a + 50 - (SCREEN_HEIGHT - 64) - xxx;
//        if(kTabBarHeight > 69){
//            changeHeight = CGRectGetMaxY(rectInTableView) + a+ kTabBarHeight + 50 - (SCREEN_HEIGHT - 64) - xxx;
//        }
////        if (kTabBarHeight > 49){
////            changeHeight += kTabbarMoreHeight;
////        }
//        if (CGRectGetMaxY(rectInTableView) > self.chatTableView.frame.size.height) {
//            changeHeight = self.chatTableView.frame.size.height + a + 50 - (SCREEN_HEIGHT - 64) - xxx;
//            if(kTabBarHeight > 69){
//                changeHeight = self.chatTableView.frame.size.height + a+ kTabBarHeight + 50 - (SCREEN_HEIGHT - 64) - xxx;
//            }
//            IsMax = kTabbarMoreHeight - 10;
//        }
//        frame.origin.y = 0;//先设置0
////        frame.origin.y -= a;//再设置上移
//        if (![self.IFView_.TextViewInput isFirstResponder] && !self.IFView_.emojiBtn.selected && !self.IFView_.btnSendMessage.selected){
//            changeHeight = 0;//当
//        }
//        frame.origin.y -= changeHeight;//再设置上移
////        if (kTabBarHeight > 49 && changeHeight >= a){
////            //因为当键盘弹起来的时候 tabbar高出的35 被去掉了 所以这里需要减去35
////            frame.origin.y += kTabbarMoreHeight;
////        }
//
//        [UIView animateWithDuration:AnimationTime animations:^{
//
//            self.chatTableView.frame = frame;
//
//        }];
    
    }
    
//    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count > 0?self.dataArr.count - 1:0 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
    
    //    [self.chatTableView scrollToBottomWithAnimation:YES offset:-64 - 50 + 10];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.chatTableView scrollToBottomWithAnimation:YES offset:-64 - 50 - IsMax];
////        [self.chatTableView scrollToBottomWithAnimation:YES offset:10 + height];
//    });
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottomOffSet:(CGFloat)height IsNeedAnimal:(BOOL)ret
{
    //当界面数据为0条或显示的contentSize高度大于2倍屏幕高
    //当界面数据大于15条【刚进来是15跳】 这时候不管界面contentsize多高【图片很高 不好考虑】 都需要到底部
    if ((self.dataArr.count==0 || self.dataArr.count > 15 || self.historyIndex > 0) && ![self.IFView_.TextViewInput isFirstResponder]){
        return;
    }
    
    //    [self.chatTableView scrollToBottomWithAnimation:YES offset:-64 - 50 + 10];
//    dispatch_main_async_safe(^{
//
//    })
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatTableView groupScrollToBottomWithAnimation:ret offset:0];
//        [self.chatTableView scrollToBottomWithAnimation:YES offset:10 + height];
    });
}

//专门为键盘设置的 将tableview下滑到底部
-(void)tableViewScrollToBottomOffSetUseByMoreView{
    if (self.dataArr.count == 0) {
        return;
    }
    if ((self.IFView_.emojiBtn.selected || self.IFView_.btnSendMessage.selected)) {//弹出表情或弹出更多
        CGRect frame = self.chatTableView.frame;
//        if(frame.origin.y != 0){
//            frame.origin.y = 0;
//        }
        CGRect rectInTableView;//获取cell的frame
        if (self.dataArr.count > 0) {
            rectInTableView = [self.chatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0]];
        }else{
            rectInTableView = CGRectMake(0, 0, 0, 0);
        }
        
        CGFloat showHeight = 0;
        if ([self.IFView_.TextViewInput isFirstResponder]) {
            showHeight = SCREEN_HEIGHT - keyboardHeight - kTopHeight - (kTopHeight > 69?kTabbarMoreHeight:0);
        }else{
            
            showHeight = self.IFView_.btnSendMessage.selected || self.IFView_.emojiBtn.selected? SCREEN_HEIGHT -(EMOJI_VIEW_HEIGHT + kTopHeight + 50 - (kTopHeight > 69?kTabbarMoreHeight:0)):SCREEN_HEIGHT - kTopHeight - 50;
            
        }
        
        if (CGRectGetMaxY(rectInTableView) < showHeight) {
            //如果键盘弹出不会遮挡tableview 则不改变tableview的frame
            //NSLog(@"%f",CGRectGetMaxY(rectInTableView) + 64 - (SCREEN_HEIGHT - EMOJI_VIEW_HEIGHT - 50 - 10));
        }else{
            
            //当tableview的frame的y大于0 才让tableview上移 【表情、更多弹出时除外】
            //                    frame.origin.y -= keyboardEndFrame.size.height;
            CGFloat changeHeight = (CGRectGetMaxY(rectInTableView) + kTopHeight + EMOJI_VIEW_HEIGHT + 50 + (kTopHeight > 69?kTabbarMoreHeight:0)) - SCREEN_HEIGHT;
            
            if (changeHeight > EMOJI_VIEW_HEIGHT- kTabbarMoreHeight && kTopHeight > 69) {
                changeHeight = EMOJI_VIEW_HEIGHT;
            }else if (changeHeight > EMOJI_VIEW_HEIGHT ){
                changeHeight = EMOJI_VIEW_HEIGHT;
            }
            //当
            if(frame.origin.y >= 0){
                frame.origin.y -= changeHeight;
            }else{
                frame.origin.y = 0;
                frame.origin.y -= changeHeight;
            }
            //frame.origin.y -= 15;
            if (kTabBarHeight > 69 ){
                //因为当键盘弹起来的时候 tabbar高出的35 被去掉了 所以这里需要减去35
                //frame.origin.y -= kTabbarMoreHeight;
            }
            [UIView animateWithDuration:AnimationTime animations:^{
                self.chatTableView.frame = frame;
            }];
        }
//        frame.origin.y -= EMOJI_VIEW_HEIGHT;
//        [UIView animateWithDuration:AnimationTime animations:^{
//            self.chatTableView.frame = frame;
//        }];
        if (self.dataArr.count > 0) {
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
        }
    }else if (!self.IFView_.emojiBtn.selected && !self.IFView_.btnSendMessage.selected){//收起表情【没点更多】
        if ([self.IFView_.TextViewInput isFirstResponder]) {
            //NSLog(@"");
            CGRect frame = self.chatTableView.frame;
            frame.origin.y -= keyboardHeight;
            frame.origin.y = 0;
            [UIView animateWithDuration:AnimationTime animations:^{
                self.chatTableView.frame = frame;
            }];
            
            [self.chatTableView reloadData];
//            if (self.dataArr.count > 0) {
//                [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
//            }
        }else{
            CGRect frame = self.chatTableView.frame;
            frame.origin.y = 0;
            [UIView animateWithDuration:AnimationTime animations:^{
                self.chatTableView.frame = frame;
            }];
            [self.chatTableView reloadData];
//            if (self.dataArr.count > 0) {
//                [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count > 0?self.dataArr.count - 1:0 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
//            }
        }
    }
    
}

#pragma 相机相关 废弃
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
            [self dealTheFunctionData:dic IsConnected:YES];
        }
    }
}
//
//


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
        [self dealTheFunctionData:dic IsConnected:YES];
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

//cell设置成透明

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
    if (self.chatTableView.editing) {
        cell.editing = YES;
        NSArray *subviews = [cell subviews];
        for (id obj in subviews) {
            if ([obj isKindOfClass:[UIControl class]]) {
                for (id subview in [obj subviews]) {
                    if ([subview isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageV = subview;
                        imageV.tintColor = [UIColor clearColor];
                        if (entity.message.IsSelected) {//判断该cell是否为选中状态
                            [cell setSelected:YES animated:YES];
                            if (![needDeleteEntityArr containsObject:entity]) {//当数组里面没有该元素 再add
                                [needDeleteEntityArr addObject:entity];
                            }
                            if (![needDeleteIndexPathArr containsObject:indexPath]) {//当数组里面没有该元素 再add
                                [needDeleteIndexPathArr addObject:indexPath];
                            }
                        }else{
                            NSLog(@"");//将要显示 手动设置tableview选中状态为NO
                            [cell setSelected:NO animated:YES];
//                            [cell setSelected:NO animated:NO];
                            //                            [needDeleteEntityArr removeObject:entity];//这里不需要删除
                            //                            [needDeleteIndexPathArr removeObject:indexPath];
                        }
                        break;
                    }
                }
            }
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

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageFrame *messageFrame = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
//    messageFrame.showTime = YES;
    //当为提示
    if ([messageFrame.message.chatId isEqualToString:@"x"]) {
        return 50;
    }
    else if (messageFrame.message.type == 3 || messageFrame.message.type == 6 ){
        //红包
        if (messageFrame.message.from == UUMessageFromMe) {
            return 100;
        }else{
            return 125;
        }
    }else if(messageFrame.message.type == 4){
        return 95;
    }else if ( messageFrame.message.pulledMemberString.length > 0 && messageFrame.message.redpacketString.length > 0) {
        if (messageFrame.message.from == UUMessageFromMe) {
            return 100;
        }else{
            return 125;
        }
    }
    else if ( messageFrame.message.pulledMemberString.length > 0) {
        //领取记录
        return 30;
    }
    return [messageFrame cellHeight];
}

//脚高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 18;
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
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if (indexPath.row >= self.dataArr.count - 3 && newMessageBottomButton.alpha == 1) {
        [UIView animateWithDuration:AnimationTime animations:^{
            newMessageBottomButton.alpha = 0;//当滑到界面所有数据倒数第两三个数据 滑到底部的按钮设置隐藏
        }];
    }
    
    if (entity.message.appMsgId.length > 0) {
        //        [self.cacheDataRowSendStatus setObject:entity.message.appMsgId forKey:[NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row]];
        NSDictionary * dict = self.cacheDataRowSendStatusDict;
        [self.cacheDataRowSendStatusDict setObject:[NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row] forKey:entity.message.appMsgId];
    }
//    if (indexPath.row == self.dataArr.count - 1) {
//        NSLog(@"******\n最后一个cell的appmessageId:%@\n******",entity.message.appMsgId);
//        if (![lastMessageId isEqualToString:entity.message.appMsgId]) {
//            NSLog(@"*****%@&%@*****",lastMessageId,entity.message.appMsgId);
//        }
//    }
    static NSString *cellIdentifier;
    //当chatid为x时候 你已不是对方好友
    if ([entity.message.chatId isEqualToString:@"x"]) {
        cellIdentifier = @"NotExistFriendListTableViewCell";
        NotExistFriendListTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"NotExistFriendListTableViewCell" owner:nil options:nil]firstObject];
        }
        //点击进行好友请求
        [cell.fmLinkClickBtn addTarget:self action:@selector(addFriendRequest) forControlEvents:(UIControlEventTouchUpInside)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (entity.message.type == UUMessageTypeRedRobRecord && entity.message.redpacketString.length == 0){
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
    }else if (entity.message.type == UUMessageTypeTransfer || (entity.message.redpacketString.length > 0 && entity.message.type == UUMessageTypeRedRobRecord)){
        //转账
        if (entity.message.from == UUMessageFromMe) {
            RedPacketTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RedPacketTableViewCell" owner:nil options:nil]firstObject];
            }
            cell.messageFrame = entity;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicktransferImageMe:)];
            [cell.hbbackImageV addGestureRecognizer:tap];
            __weak typeof(self)weakSelf=self;
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            [cell returnDelete:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
//                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
//                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where from = '%@' and redpacketString = '%@'",entity.message.from,entity.message.redpacketString]];//UUMessageFromMe  UUMessageFromOther 101
                NSArray *arr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:entity whereFormat:[NSString stringWithFormat:@"where localReceiveTimeString = '%@' and redpacketString = '%@'",entity.message.localReceiveTimeString,entity.message.redpacketString]];
                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where localReceiveTimeString = '%@' and redpacketString = '%@'",entity.message.localReceiveTimeString,entity.message.redpacketString]];//UUMessageFromMe  UUMessageFromOther 101
                if (entity.message.cachePicPath.length > 0) {
                    if (entity.message.cachePicPath.length > 0) {
                        [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                    }
                }
                [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
                //        [self.dataArr removeObjectsAtIndexes:nil];
                [strongSelf.chatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                //        [self.GroupChatTableView];
                [strongSelf.chatTableView reloadData];
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            cellIdentifier = @"RedPacketOtherTableViewCell";
            RedPacketOtherTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RedPacketOtherTableViewCell" owner:nil options:nil]firstObject];
            }
            //                [cell.RedClickOther addTarget:self action:@selector(clickRedImageOther:)];
            entity.message.strIcon = self.singleContactEntity.iconUrl;
            cell.messageFrame = entity;
            
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __weak typeof(self)weakSelf=self;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicktransferImageMe:)];
            [cell.hbbackImageV addGestureRecognizer:tap];
            [cell returnDelete:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where localReceiveTimeString = '%@' and redpacketString = '%@'",entity.message.localReceiveTimeString,entity.message.redpacketString]];//UUMessageFromMe  UUMessageFromOther 101
                if (entity.message.cachePicPath.length > 0) {
                    if (entity.message.cachePicPath.length > 0) {
                        [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                    }
                }
                [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
                //        [self.dataArr removeObjectsAtIndexes:nil];
                [strongSelf.chatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                //        [self.GroupChatTableView];
                [strongSelf.chatTableView reloadData];
            }];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else if (entity.message.type == UUMessageTypeRed){
        //红包
        if (entity.message.from == UUMessageFromMe) {
            RedPacketTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RedPacketTableViewCell" owner:nil options:nil]firstObject];
            }
            cell.messageFrame = entity;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRedImageMe:)];
            [cell.hbbackImageV addGestureRecognizer:tap];
            __weak typeof(self)weakSelf=self;
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            [cell returnDelete:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where localReceiveTimeString = '%@' and redpacketString = '%@'",entity.message.localReceiveTimeString,entity.message.redpacketString]];
                if (entity.message.cachePicPath.length > 0) {
                    if (entity.message.cachePicPath.length > 0) {
                        [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                    }
                }
                [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
                //        [self.dataArr removeObjectsAtIndexes:nil];
                [strongSelf.chatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                //        [self.GroupChatTableView];
                [strongSelf.chatTableView reloadData];
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            cellIdentifier = @"RedPacketOtherTableViewCell";
            RedPacketOtherTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"RedPacketOtherTableViewCell" owner:nil options:nil]firstObject];
            }
            //                [cell.RedClickOther addTarget:self action:@selector(clickRedImageOther:)];
            entity.message.strIcon = self.singleContactEntity.iconUrl;
            cell.messageFrame = entity;
            
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __weak typeof(self)weakSelf=self;
            [cell returnDelete:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where localReceiveTimeString = '%@' and redpacketString = '%@'",entity.message.localReceiveTimeString,entity.message.redpacketString]];
                if (entity.message.cachePicPath.length > 0) {
                    if (entity.message.cachePicPath.length > 0) {
                        [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
                    }
                }
                [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
                //        [self.dataArr removeObjectsAtIndexes:nil];
                [strongSelf.chatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                //        [self.GroupChatTableView];
                [strongSelf.chatTableView reloadData];
            }];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRedImageMe:)];
            [cell.hbbackImageV addGestureRecognizer:tap];
            
            
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
            [cell.recommendheadV sd_setImageWithURL:[NSURL URLWithString:entity.message.fileId] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
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
            [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:entity.message.strIcon] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
            [cell.recommendHeadImageV sd_setImageWithURL:[NSURL URLWithString:entity.message.fileId] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
            cell.titleNameLabel.text = entity.message.pictureUrl;
//            cell.nicknameLabel.text = entity.message.strVoiceTime;
            cell.nicknameLabel.text = @"";
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRecommendImage:)];
            [cell.clickBtn addGestureRecognizer:tap];
            //            [cell.backImageV addGestureRecognizer:tap];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    cellIdentifier = [NSString stringWithFormat:@"%@%zd", @"MessageTableViewCell", indexPath.row];;
    MessageTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil]firstObject];
    }
//    entity.showTime = YES;
//    entity.showTime = NO;
    
//    cell.messageFrameUrgent = entity;//设置紧急显示的界面
//    cell.currentIndexPath = indexPath;
//    [[DWURunLoopWorkDistribution sharedRunLoopWorkDistribution] addTask:^BOOL(void) {
//        if (![cell.currentIndexPath isEqual:indexPath]) {
//            return NO;
//        }
//        cell.messageFrame = entity;//设置界面
//        return YES;
//    } withKey:indexPath];
    
    cell.messageFrame = entity;//设置界面
    cell.chatMemberId = self.singleContactEntity.friend_userid;
    //是否需要重发按钮
//    if ([entity.message.failStatus isEqualToString:@"1"]) {
        [cell.reSendBtn addTarget:self action:@selector(reSendBtnClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
//    }
    cell.meName = [NFUserEntity shareInstance].userName;
    cell.otherName = self.singleContactEntity.friend_username;
    cell.headPicpath = self.singleContactEntity.iconUrl;
    cell.selectedIndexPath = indexPath;
    cell.singleTableV = self.chatTableView;
    cell.dataArr = self.dataArr;
    cell.singleContactEntity = self.singleContactEntity;
    cell.singleViewController = self;
    __weak typeof(self)weakSelf=self;
    [cell setReturnDeleteBlock:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //删除
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
        }];
        
        if (entity.message.cachePicPath.length > 0 ) {
            [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
        }
        [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
        [strongSelf.chatTableView   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationBottom];
        [strongSelf.chatTableView reloadData];
    }];
    [cell returnLongTap:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //长按
        strongSelf -> IsFromLongTap = YES;
        //输入框收下去
        if([strongSelf.IFView_.TextViewInput isFirstResponder]){
            [self.IFView_ performSelector:@selector(hideninputView) withObject:nil afterDelay:0];
            [self.view endEditing:YES];
        }
//        if ([self.IFView_ respondsToSelector:@selector(hideninputView)]) {
//            [self.IFView_ performSelector:@selector(hideninputView) withObject:nil afterDelay:0];
//        }
//        [self.view endEditing:YES];
        
    }];
    [cell returnRegisterResponder:^{
        //放弃输入框响应者
//        [self.IFView_.TextViewInput resignFirstResponder];
        //有更多菜单 隐藏更多菜单 先让输入框称为第一响应者，再让其放弃第一响应者 用已经存在的代码实现想要的界面效果。
        //当键盘或更多按钮界面 在显示时 让其收起键盘和更多界面
        if ([weakSelf.IFView_.TextViewInput isFirstResponder] || weakSelf.IFView_.btnSendMessage.selected) {
            [weakSelf.IFView_.TextViewInput becomeFirstResponder];
            [weakSelf.IFView_.TextViewInput resignFirstResponder];
        }
    }];
    [cell returnDrow:^{
        //撤回
        
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //撤回请求
        strongSelf ->drowMessageId = entity.message.chatId;
        strongSelf ->drowMessageIndexPath = indexPath;
        [strongSelf ->socketRequest drowRequest:entity.message];
    }];
    [cell returnEdit:^{
        //更多
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [cell setSelected:YES animated:YES];
        strongSelf -> firstSelectDelete = YES;
        strongSelf -> clickMoreIndexPath = indexPath;
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
        [strongSelf.view addSubview:bottomEditView];
    }];
    
//    [cell returnCancel:^{
//        [bottomEditView removeFromSuperview];
//        needDeleteEntityArr = [[NSMutableArray alloc] initWithCapacity:2];
//        needDeleteIndexPathArr = [[NSMutableArray alloc] initWithCapacity:2];
//    }];
    
//    NSLog(@"%u",entity.message.from);
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    cell.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
    
    [cell.youImageView afterClickHeadImage:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [strongSelf showContactDetailWithZJContact:self.singleContactEntity];
    }];
    
    return cell;
}

#pragma mark - 根据ZJContact向上弹出好友详情
-(void)showContactDetailWithZJContact:(ZJContact *)contact{
    if (!self.backBtn.userInteractionEnabled || self.chatTableView.editing) {
        //如果返回按钮不可点 则正在收取数据 或 tableview正在编辑中 不可操作
        [SVProgressHUD showInfoWithStatus:@"收取中请稍后发送"];
        return;
    }
    [self.IFView_.TextViewInput resignFirstResponder];
    self.chatTableView.scrollEnabled = NO;
    self.ZJContactDetailController.view  = nil;
    self.ZJContactDetailController  = nil;
    if (self.ZJContactDetailController == nil) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
        self.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
        //设置单聊详情数据
        //            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
//        ZJContact *contact = [ZJContact new];
//        contact.friend_userid = self.singleContactEntity.friend_userid;
//        contact.friend_username = self.singleContactEntity.friend_username;
//        contact.friend_nickname  = self.singleContactEntity.friend_nickname;
//        contact.in_group_name  = self.singleContactEntity.friend_nickname?self.singleContactEntity.friend_nickname:self.singleContactEntity.friend_username;
//        contact.iconUrl = self.singleContactEntity.iconUrl;//头像
        //对于详情页面的赋值
        self.ZJContactDetailController.contant = contact;
        self.ZJContactDetailController.SourceFrom = @"1";
        [self addChildViewController:self.ZJContactDetailController];
        self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        //点击了headview上面的事件
        __weak typeof(self)weakSelf=self;
        self.ZJContactDetailController.clickWhich = ^(int index) {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (index == 0 || index == 10) {
                //移除ZJContactDetailController
                [UIView animateWithDuration:AnimationTime animations:^{
                    strongSelf.chatTableView.scrollEnabled = YES;
                    strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                    [self.ZJContactDetailController.view removeFromSuperview];
                    //当移除界面后 设置来自编辑名字为no
                    isFromEditName = NO;
                }];
                strongSelf.navigationController.navigationBarHidden = NO;
            }else if (index == 1){
                //相册
                strongSelf ->isFromEditName = YES;
                SGPhoto *temp = [[SGPhoto alloc] init];
                temp.identifier = @"";
                temp.thumbnail = [UIImage imageNamed:@"图片"];
                temp.fullResolutionImage = [UIImage imageNamed:@"图片"];
                HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
                if (contact.iconUrl.length > 10) {
                    showImageViewCtrol.imageUrlList = @[contact.iconUrl];
                }else{
                    showImageViewCtrol.imageUrlList = @[temp];
                }
                showImageViewCtrol.mainImageIndex = 0;
                showImageViewCtrol.isLuoYang = YES;
                showImageViewCtrol.isNeedNavigation = NO;
                [strongSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
            }else if (index == 2){
            }
        };
//        self.ZJContactDetailController.freeChatBtn.hidden = YES;
//        self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
        //设置编辑名字、免费聊天
        //            [weakSelf.ZJContactDetailController.nameEditBtn addTarget:weakSelf action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
        [self.ZJContactDetailController.freeChatBtn addTarget:weakSelf action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
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
        [UIView animateWithDuration:AnimationTime animations:^{
            self.navigationController.navigationBarHidden = YES;
            self.tabBarController.tabBar.hidden = YES;
            self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - 点击了转账

-(void)clicktransferImageMe:(UITapGestureRecognizer *)recognizer{
//    if (![NFUserEntity shareInstance].clientId || [[NFUserEntity shareInstance].clientId containsString:@"null"] || [NFUserEntity shareInstance].clientId.length == 0 ) {
//        [SVProgressHUD showInfoWithStatus:@"请先开户"];
//        return;
//    }
    
    CGPoint point = [recognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:point];
    //    NSLog(@"%ld",indexPath.section);
    UUMessageFrame *messageF = self.dataArr[indexPath.row];
    messageF.message.redIsTouched = @"1";
    MessageChatEntity *chatEntity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageF];
    __weak typeof(self)weakSelf=self;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:strongSelf.singleContactEntity.friend_userid dicOrModel:chatEntity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
    
    if(messageF.message.from == UUMessageFromMe){
        
        [socketRequest RedPacketDetail:@{@"redpacketId":messageF.message.redpacketString}];
        
    }else if (messageF.message.from == UUMessageFromOther){
        
        [socketRequest RedPacketDetail:@{@"redpacketId":messageF.message.redpacketString}];
    }
    
}
#pragma mark - 点击了红包
-(void)clickRedImageMe:(UITapGestureRecognizer *)recognizer{
//    if (![NFUserEntity shareInstance].clientId || [[NFUserEntity shareInstance].clientId containsString:@"null"] || [NFUserEntity shareInstance].clientId.length == 0 ) {
//        [SVProgressHUD showInfoWithStatus:@"请先开户"];
//        return;
//    }
    
    
    CGPoint point = [recognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:point];
    //    NSLog(@"%ld",indexPath.section);
    UUMessageFrame *messageF = self.dataArr[indexPath.row];
    messageF.message.redIsTouched = @"1";
    MessageChatEntity *chatEntity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageF];
    chatEntity.redIsTouched = @"1";
    __weak typeof(self)weakSelf=self;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:strongSelf.singleContactEntity.friend_userid dicOrModel:chatEntity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
    
    
    [NFUserEntity shareInstance].currentChatId = @"";
    [NFUserEntity shareInstance].isSingleChat = @"0";
    
    if(messageF.message.from == UUMessageFromMe){
        RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
        //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        //vc.thirdToken = self.thirdToken;
        //vc.userId = self.userId;
        vc.redpacketId = messageF.message.redpacketString;
        //vc.appkey = self.appkey;
        vc.groupId = @"";
        vc.isSingleMe = YES;
        if (@available(iOS 13.0, *)) {
            vc.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
        
        return;
    }
    
    //self.titleName
    [SVProgressHUD show];
    [[NTESRedPacketManager sharedManager] openRedPacket:messageF.message.redpacketString from:@{@"name":self.titleName.length>0?self.titleName:messageF.message.nickName,@"headurl":messageF.message.strIcon,@"isGroup":@"0",@"senduserid":self.conversationId} session:@""];
    
    return;
    
    RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
    vc.redpacketId = messageF.message.redpacketString;
    vc.groupId = @"0";
    
    //        NSDictionary *dict = @{@"content":[self.redDetailDict objectForKey:@"content"],
    //                               @"list":@[],
    //                               @"count":[self.redDetailDict objectForKey:@"count"],
    //                               @"senduserId":[self.redDetailDict objectForKey:@"senduserId"],
    //                               @"totalMoney":[self.redDetailDict objectForKey:@"totalMoney"]
    //                               };
    
    vc.redDetailDict = @{@"content":@"恭喜发财，大吉大利",
                         @"list":@[@{@"datetime":@"2020-01-18 11:58:11",@"gettimes":@"1579319891",@"getuserId":@"228",@"grabId":@"1",@"groupId":@"47",@"id":@"828",@"isBestLuck":@"1",@"isGroup":@"1",@"money":@"100",@"redpacketId":@"1",@"userHeadUrl":@"2019-08-24/5d60ce7447035.jpeg",@"userName":@"小白"}],
                         @"count":@"1",
                         @"senduserId":@"1",
                         @"totalMoney":@"100",
                         @"senderInfo":@{@"nickname":@"小白",@"photo":@"2019-08-24/5d60ce7447035.jpeg"}
                         };
    if (@available(iOS 13.0, *)) {
        vc.modalPresentationStyle =UIModalPresentationFullScreen;
    }
    [self presentViewController:vc animated:YES completion:^{
        NSLog(@"in--RPFRedpacketDetailVC");
        
    }];
    
    
}

#pragma mark - 红包详情
-(void)clickRedImage:(UITapGestureRecognizer *)recognizer{
    //点击的时候根据红包实体进行请求
    CGPoint point = [recognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:point];
    UUMessageFrame *message = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    //RedDetailViewController
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    RedDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RedDetailTableViewController"];
    toCtrol.redMessage = message;
    [self.navigationController pushViewController:toCtrol animated:YES];
    
}

#pragma mark - 免费聊天 正在和该人聊天
-(void)freeChatClick:(UIButton *)button event:(UIEvent *)event{
    isFromEditName = NO;
    if (selectedIndexPath) {
        NSIndexPath *indexPath = selectedIndexPath;
//        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//        MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
        //    NSInteger index = [_sectionIndexs[selectedIndexPath.section - 1] integerValue];
        //    NSArray *temp = _data[index];
        //    ZJContact *contact = (ZJContact *)temp[selectedIndexPath.row];
        //    NSLog(@"%ld",selectedIndexPath.row);
        UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
        ZJContact *contact = [ZJContact new];
        contact.friend_userid = entity.message.strId;
        contact.friend_username = entity.message.nickName;
        contact.friend_nickname  = entity.message.pictureUrl;
        contact.in_group_name  = entity.message.pictureUrl?entity.message.nickName:entity.message.userName;
        contact.iconUrl = entity.message.fileId;//
        
//        if (contact.iconUrl.length == 0) {
//            //当头像为空 取缓存头像 【当该人为好友时 才能有用】
//            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//            __block NSArray *existContactArr = [NSArray new];
//            __weak typeof(self)weakSelf=self;
//            [jqFmdb jq_inDatabase:^{
//                __strong typeof(weakSelf)strongSelf=weakSelf;
//                existContactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",@"18"];
//            }];
//
//            if (existContactArr.count == 1) {
//                ZJContact *cacheContact = [existContactArr firstObject];
//                //取需要的数据
//                contact.iconUrl = cacheContact.iconUrl;
//            }
//        }
//        if (contact.friend_nickname.length > 0) {
//            toCtrol.titleName = contact.friend_nickname;
//        }else{
//            toCtrol.titleName = contact.friend_username;
//        }
//        toCtrol.conversationId = contact.friend_userid;
//        toCtrol.chatType = @"0";
//
//        toCtrol.singleContactEntity = contact;
        
        
        UIStoryboard * sbb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        SingleChatDetailTableViewController *toCtrolll = [sbb instantiateViewControllerWithIdentifier:@"SingleChatDetailTableViewController"];
        //singleEntity
        //        toCtrol.singleEntity = self.singleEntity;
        toCtrolll.singleContactEntity = contact;
        toCtrolll.conversationId = contact.user_id;
        toCtrolll.IsFromCard = YES;
        [self.navigationController pushViewController:toCtrolll animated:YES];
        
    }else{
        //移除ZJContactDetailController
        [UIView animateWithDuration:AnimationTime animations:^{
            self.chatTableView.scrollEnabled = YES;
            self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
            [self.ZJContactDetailController.view removeFromSuperview];
            //当移除界面后 设置来自编辑名字为no
            isFromEditName = NO;
        }];
        self.navigationController.navigationBarHidden = NO;
        
    }
    
    
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

#pragma mark - 重新发送消息，发送失败的消息
- (void)reSendBtnClick:(UIButton *)button event:(UIEvent *)event
{
    if ([self.IFView_.TextViewInput isFirstResponder]) {
        [self.IFView_.TextViewInput resignFirstResponder];
    }
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.chatTableView];
//    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:currentTouchPosition];
    //根据cell中的button 获取到cell的indexpath
    GroupMessageTableViewCell *singleMessageCell = (GroupMessageTableViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [self.chatTableView indexPathForCell:singleMessageCell];
    //重新发送消息
    UUMessageFrame *reSendEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    
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
                    BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where appMsgId = '%@'",needDeleteEntity.message.appMsgId]];
                }];
                [self.dataArr removeObjectAtIndex:indexPath.row];
                [self.chatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                
                NSDictionary *dic = @{@"appMsgId":reSendEntity.message.appMsgId,@"strContent":@"",@"type":@"1",@"userName":self.singleContactEntity.friend_username,@"userNickName":[NFUserEntity shareInstance].nickName};
                
                [self addSpecifiedItem:reSendEntity AndDict:dic];
                
                
            }else if (reSendEntity.message.type == UUMessageTypeText){
                //从数据库删除这条消息
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                UUMessageFrame *needDeleteEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;//根据记录的重新发送的indexpath。取到appMsgId删除数据库的数据
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where appMsgId = '%@'",needDeleteEntity.message.appMsgId]];
                }];
                [self.dataArr removeObjectAtIndex:indexPath.row];
                [self.chatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                //重新发送 重新
                NSDate *currentDate = [NSDate date];//获取当前时间，日期
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
                NSString *dateString = [dateFormatter stringFromDate:currentDate];
                NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
                NSDictionary *dic = @{@"strContent": reSendEntity.message.strContent, @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"chatId":@"",@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": AppMessageId};
                [weakSelf dealTheFunctionData:dic IsConnected:YES];
            }else if (reSendEntity.message.type == UUMessageTypeVoice){
                //从数据库删除这条消息
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                UUMessageFrame *needDeleteEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;//根据记录的重新发送的indexpath。取到appMsgId删除数据库的数据
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL rett = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where appMsgId = '%@'",needDeleteEntity.message.appMsgId]];
                }];
                [self.dataArr removeObjectAtIndex:indexPath.row];
                [self.chatTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                NSDictionary *dic = @{@"voice": reSendEntity.message.voice, @"strVoiceTime":reSendEntity.message.strVoiceTime, @"type":@(UUMessageTypeVoice),@"chatId":@"",@"appMsgId": reSendEntity.message.appMsgId};
                [self dealTheFunctionData:dic IsConnected:YES];
                //发送图片时候 超时计算取消
                [NFUserEntity shareInstance].timeOutCountBegin = NO;
            }
        }
    }];
    [sheet show];
    
}

#pragma mark - 发送消息后展示、缓存 【只能是群聊】
- (void)addSpecifiedItem:(UUMessageFrame *)reSendEntity AndDict:(NSDictionary *)dic
{
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    ZJContact *contant = [ZJContact new];
    contant.friend_userid = self.singleContactEntity.friend_userid;
    contant.friend_username = self.singleContactEntity.friend_username;
    [self.fmdbServicee cacheChatListWithZJContact:contant AndDic:dic];
    
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
    __weak typeof(self)weakSelf=self;
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:contant.friend_userid];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:contant.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
    }];
    //重复消息 单聊
    if(lastArr.count == 1){
        MessageChatEntity *lastEntity = [lastArr firstObject];
        if ([lastEntity.message_content isEqualToString:lastEntity.message_content] && [lastEntity.localReceiveTimeString isEqualToString:lastEntity.localReceiveTimeString]) {
            //如果有相同消息 则return
            return;
        }
    }
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:contant.friend_userid dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            return;
        }
    }];
}



//当tableview进入编辑状态，是否允许进入编辑状态。
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    //当为系统通知 比如 某人拉某人进群，该消息不能够进行编辑
    if ([entity.message.chatId isEqualToString:@"x"]) {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if ([entity.message.chatId isEqualToString:@"x"]){
        
    }
    //当再次选择，取消强选中 回到正常处理
    NSArray *subviews = [[tableView cellForRowAtIndexPath:indexPath] subviews];
    MessageTableViewCell  * cell = (MessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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
    
    
    //领取红包
    if (entity.message.type == UUMessageTypeRed) {
        [[NTESRedPacketManager sharedManager] openRedPacket:@"1" from:@{} session:@"1"];
    }
    
    
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageFrame *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    entity.message.IsSelected = NO;
    //移除选中的
    [needDeleteEntityArr removeObject:entity];
    [needDeleteIndexPathArr removeObject:indexPath];
}


#pragma mark - 点击推荐好友 我的
-(void)clickRecommendImage:(UITapGestureRecognizer *)recognizer{
    
    
    CGPoint point = [recognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:point];
    selectedIndexPath = indexPath;
    //    NSLog(@"%ld",indexPath.section);
    UUMessageFrame *messageF = self.dataArr[indexPath.row];
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


#pragma mark - 取消编辑
-(void)cancelEditClick{
    [self.chatTableView setEditing:NO animated:YES];
    //for循环将选中的cell设置成未选中，如果不设置 下次编辑的时候 这些cell将是选中状态
    for (NSIndexPath *indexpath in needDeleteIndexPathArr) {
        UUMessageFrame *UMessage = self.dataArr.count>indexpath.row?self.dataArr[indexpath.row]:nil;
        UMessage.message.IsSelected = NO;//设置数据选中状态为NO
        MessageTableViewCell  * cell = (MessageTableViewCell *)[self.chatTableView cellForRowAtIndexPath:indexpath];
        [cell setSelected:NO animated:YES];
    }
    //显示输入框
    self.IFView_.hidden = NO;
    [bottomEditView removeFromSuperview];
    needDeleteEntityArr = [[NSMutableArray alloc] initWithCapacity:2];
    needDeleteIndexPathArr = [[NSMutableArray alloc] initWithCapacity:2];
    
    self.navigationItem.rightBarButtonItem.customView.hidden =NO;
    
    
//    UIButton *backBtnqq = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
//    [backBtnqq setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
//    [backBtnqq addTarget:self action:@selector(backClickeddd) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backButtonItemqq = [[UIBarButtonItem alloc]initWithCustomView:backBtnqq];
//
//    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
//    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backClickeddd) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
//    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    if (self.unreadAllCount == 0) {
        self.navigationItem.leftBarButtonItems = @[leftBackBtnItem];
    }else{
        self.navigationItem.leftBarButtonItems = @[leftBackBtnItem,leftCountBtnItem];
    }
    
    
    //    self.singleViewController.navigationItem.rightBarButtonItem
    //刷新tableview
    
}

//-(void)backClicked{
//    [self.navigationController popViewControllerAnimated:YES];
//
//}

#pragma mark - for删除数据库中选中的消息
-(void)deleteCommitClick{
    __weak typeof(self)weakSelf=self;
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"是否删除" otherButtonTitles:[NSArray arrayWithObjects:@"确定", nil] btnClickBlock:^(NSInteger buttonIndex) {
        __strong typeof(weakSelf)strongSelf=weakSelf;
        if (buttonIndex == 999) {
            return ;
        }
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        for (int i = 0; i<needDeleteEntityArr.count; i++) {
            UUMessageFrame *entity = needDeleteEntityArr[i];
            [strongSelf->jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:strongSelf.singleContactEntity.friend_userid whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.message.chatId]];
            }];
            
            if (entity.message.cachePicPath.length > 0) {
                [[SDImageCache sharedImageCache] removeImageForKey:entity.message.cachePicPath fromDisk:YES];
            }
        }
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *index in strongSelf->needDeleteIndexPathArr) {
            [indexSet addIndex:index.row];
        }
        [strongSelf.dataArr removeObjectsAtIndexes:indexSet];
        [strongSelf.chatTableView   deleteRowsAtIndexPaths:strongSelf->needDeleteIndexPathArr withRowAnimation:UITableViewRowAnimationBottom];
        //等于点击了取消的效果
        [strongSelf performSelector:@selector(cancelEditClick)];
        //删除完刷新tableview 否则下次删除会因为indexpath没变而崩溃
        [strongSelf.chatTableView reloadData];
        //                [self.singleTableV endUpdates];
    }];
    [sheet show];
}

//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleInsert;
//}

#pragma mark - 界面消失缓存会话列表
-(void)cacheConversationList{
    //结束正在输入请求
    if (IsShowEntering) {
        [self enteringEndRequest];
    }
    //会话列表在会话界面进行核实
    //查看数据库有没有该会话 有的话就return 在会话劣币哦啊界面进行核实 没有则在这里创建
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    NSArray *conversationExistArr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",self.singleContactEntity.friend_userid,@"IsSingleChat",@"1"];
    if (conversationExistArr.count == 1 || self.dataArr.count == 0) {
        //如果表里面有一条数据 则return 在会话列表界面进行核实 但是如果大于一条 需要在下面进行删除
        return;
    }
    //将会话列表的最后一条消息设置为聊天中的最后一条消息
    NSDictionary *dic = [NSDictionary new];
    //判断是否隐藏
    UUMessageFrame *lastE = [self.dataArr lastObject];
    MessageChatEntity *last = [MessageChatEntity new];
    last.yuehouYinCang = lastE.message.yuehouYinCang;
    last.localReceiveTimeString = lastE.message.localReceiveTimeString;
    last.message_content = lastE.message.strContent;
    last.chatId = lastE.message.chatId;
    last.type = [NSString stringWithFormat:@"%ld",lastE.message.type];
    if (lastE.message.type == 0) {
        last.type = @"0";
    }else if (lastE.message.type == 1){
        last.type = @"1";
    }else if (lastE.message.type == 2){
        last.type = @"2";
    }else if (lastE.message.type == 3){
        last.type = @"3";
    }else if (lastE.message.type == 4){
        last.type = @"4";
    }else if (lastE.message.type == 5){
        last.type = @"5";
    }else if (lastE.message.type == 6){
        last.type = @"6";
    }
    if (last && [last.yuehouYinCang isEqualToString:@"1"] && self.singleContactEntity.friend_username.length > 0 && last.localReceiveTimeString.length > 0) {//当这条消息是隐藏的 那么
        if (last.message_content.length == 0) {
            last.message_content = @"图片";
        }
        dic = @{@"userName":self.singleContactEntity.friend_username,@"type":@"0",@"strContent":@"",@"update_time":last.localReceiveTimeString,@"nickName":self.singleContactEntity.friend_nickname?self.singleContactEntity.friend_nickname:self.singleContactEntity.friend_username};
        [self.fmdbServicee cacheChatListWithZJContact:self.singleContactEntity AndDic:dic];
    }
    else{
        if (self.singleContactEntity.friend_username.length > 0&& last.localReceiveTimeString.length > 0) {
            if ([last.type isEqualToString:@"0"]) {//当这是条正常的消息
            }else if ([last.type isEqualToString:@"1"]){
                last.message_content = @"[图片]";
            }else if ([last.type isEqualToString:@"2"]){
                last.message_content = @"[语音]";
            }else if ([last.type isEqualToString:@"3"]){
                last.message_content = [NSString stringWithFormat:@"[多信红包]%@",last.message_content];
            }else if ([last.type isEqualToString:@"4"]){
                last.message_content = @"[名片消息]";
            }else if ([last.type isEqualToString:@"6"]){
                if ([last.isSelf isEqualToString:@"0"]) {
                    last.message_content = @"[转账]";
                }else{
                    last.message_content = @"[转账]请您确认收款";
                }
                
            }
            //3红包  4 名片    5红包领取记录
            dic = @{@"userName":self.singleContactEntity.friend_username,@"type":last.type?last.type:@"",@"strContent":last.message_content,@"last_message_id":last.chatId?last.chatId:@"",@"update_time":last.localReceiveTimeString,@"nickName":self.singleContactEntity.friend_nickname?self.singleContactEntity.friend_nickname:self.singleContactEntity.friend_username};
            [self.fmdbServicee cacheChatListWithZJContact:self.singleContactEntity AndDic:dic];
        }else{
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];//当是系统通知类
            __block NSArray *arrss = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                arrss = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.singleContactEntity.friend_userid,@"IsSingleChat",@"1"]];
            }];
//            if (arrss.count > 0) {
            if(last.type && last.message_content){
                if ([last.type isEqualToString:@"6"]){
                    if ([last.isSelf isEqualToString:@"0"]) {
                        last.message_content = @"[转账]";
                    }else{
                        last.message_content = @"[转账]请您确认收款";
                    }
                }
                dic = @{@"userName":self.singleContactEntity.friend_username,@"type":last.type,@"strContent":last.message_content,@"last_message_id":last.chatId?last.chatId:@"",@"update_time":@"",@"nickName":self.singleContactEntity.friend_nickname?self.singleContactEntity.friend_nickname:self.singleContactEntity.friend_username};
                [self.fmdbServicee cacheChatListWithZJContact:self.singleContactEntity AndDic:dic];
            }
//            }else if([last.type isEqualToString:@"3"]){
//                //当最后一条消息是我发的红包 走的9011 没有缓存会话列表
//            }
        }
    }
    [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
}

#pragma mark - //收到网络变化通知
- (void)connectBreak:(NSNotification *)notifi{
    NSDictionary *nitification = notifi.object;
    if ([[nitification objectForKey:@"connectStatus"] isEqualToString:@"1"]) {
        //收到消息为nil 显示完整标题
        NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
        titleViewLabel.text = [NSString stringWithFormat:@"%@(未连接)",title];
        dispatch_main_async_safe(^{
            self.navigationItem.titleView = titleViewLabel;
        })
    }else if ([[nitification objectForKey:@"connectStatus"] isEqualToString:@"0"]) {
        [self refresh];
        //显示完整标题
        NSString *title = titleViewLabel.text.length > 0?titleViewLabel.text:self.navigationItem.title;
        titleViewLabel.text = [NSString stringWithFormat:@"%@",title];
        dispatch_main_async_safe(^{
            self.navigationItem.titleView = titleViewLabel;
        })
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
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:_chatTableView];
}

#pragma mark - 下拉刷新委托回调

//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
//    [socketRequest getAllDataOfSingleChatWithFriendId:self.singleContactEntity.friend_userid FriendName:self.singleContactEntity.friend_username];
    [self reloadTableViewDataSource];
#pragma mark - 下拉刷新6
    if (canRefresh) {
        //记录老的cell count
        oldCount = [self.dataArr count];
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

-(int)checkIsHaveNumAndLetter:(NSString*)password{
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:password
                                                                       options:NSMatchingReportProgress
                                                                         range:NSMakeRange(0, password.length)];
    
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:password options:NSMatchingReportProgress range:NSMakeRange(0, password.length)];
    
    if (tNumMatchCount == password.length) {
        //全部符合数字，表示沒有英文
        return 1;
    } else if (tLetterMatchCount == password.length) {
        //全部符合英文，表示沒有数字
        return 2;
    } else if (tNumMatchCount + tLetterMatchCount == password.length) {
        //符合英文和符合数字条件的相加等于密码长度
        return 3;
    } else {
        return 4;
        //可能包含标点符号的情況，或是包含非英文的文字，这里再依照需求详细判断想呈现的错误
    }
}


//UIImage *originImage = [UIImage imageNamed:@"Cover.png"];
//
//NSData *data = UIImageJPEGRepresentation(originImage, 1.0f);
//
//NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//
//
//NSLog(@"encodedImageStr==%@",encodedImageStr);
//
////Base64字符串转UIImage图片：
//
//NSData *decodedImageData = [[NSData alloc]
//
//                            initWithBase64EncodedString:encodedImageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//
//UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
//
//UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 100, 200, 400)];
//
//[imgView setImage:decodedImage];
//
//[self.view addSubview:imgView];

-(void)viewDidUnload{
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
    
}

-(void)dealloc{
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}



@end
