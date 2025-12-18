 
//
//  MessageChatListViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MessageChatListViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "CCZTableButton.h"
#import "NFUIWindow.h"

#import <AdSupport/AdSupport.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

//延迟显示 安全设置时间
#define nsTimerCount 15
//删除会话时 是否需要删除群、单聊消息记录 0不需要 1需要
#define isNeedDeleteGroupHistory @"1"

#define offSet 3

@interface MessageChatListViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate,EGORefreshTableHeaderDelegate,ChatHandlerDelegate,UIGestureRecognizerDelegate>

//会话列表
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (strong, nonatomic) NSArray<ZJContact *> *allData; //ZJContact类型数组

@property(nonatomic,strong)NSDictionary *dataDict;
@property (nonatomic,strong)AppDelegate *appdelegate;

//弹出框
@property (nonatomic, strong) MLMOptionSelectView *cellView;

@property(nonatomic,strong)NSArray *titleArr_;
@property(nonatomic,strong)NSArray *picArr_;

@property (nonatomic,assign)NSTimer *timerr;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) GroupCreateSuccessEntity *chatCreateSuccessEntity;
@property (copy, nonatomic) NSMutableArray *groupDetailAndMemberArr;
@property (copy, nonatomic) NSMutableArray *contactArr;
@property (nonatomic, strong) FMDBService  *fmdbServicee;

@property(nonatomic,strong)HCDTimer *hcdTimer;

@end

static CGFloat const kSearchBarHeight = 50.f;

@implementation MessageChatListViewController{
    __weak IBOutlet NFBaseTableView *MessageChatListTableview;
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
    NSArray *allChatListArr_;
    UIButton *clearCacheBtn;
    UIButton *quitBtn;
    JQFMDB *jqFmdb;
    //右上角添加按钮
    UIButton *AddBtn;
    //新聊天
//    CCZTableButton *newChatTableV_;
// 新建聊天按钮
    UIButton *newChatButton;
    NSArray *titleArr;
    NSArray *picArr;
    //是否能够弹出安全设置
    BOOL IsCanPopSaveSet;
    //定时器计时
    int timeCount;
    //add菜单
    CCZTableButton *MenuTableV_;
    //第一次进来
    BOOL isFirstCome;
    //记录选中cell的实体
    MessageChatListEntity *selectedChatListEntity;
    NSMutableDictionary *rowHeightCache;
    NSIndexPath *selectedEditIndexPath;//选中删除的indexpath
    //未连接到服务器弹窗
    DisconnectView *disconnectView;
    //连接状态 已经为 1已连接、2未连接、3正在连接
    NSString *connectStatus;
    //需要请求的未读个数 当全部都请求完 才能进行操作
    NSInteger requestHistoryDataCount;
    //未读消息总个数
    NSInteger unreadAllCount;
    
    //是否刷新 会话，当上一次请求没有返回 则不允许下一次请求
    BOOL IsAllowrConversationAgain;
    
    //是否刷新 会话，当界面willappear的时候 不能总是刷新
    BOOL IsAllowRefreshConversation;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    //self.title = @"多信";
    self.title = @"多信";
    if (self.fromType) {
        self.title = @"选择一个聊天";
    }
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];//设置状态栏蓝色
//    [NFUserEntity shareInstance].badgeCount = 0;
//    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;//根视图 tabbar必须显示
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
    //设置本界面需要缓存
    needCache = YES;
    needGetCache = YES;
    //单例获取聊天 当有人发消息时候 在里面进行刷新界面
    //MessageChatListTableview.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    __block NSArray *arrs = [NSArray new];
//    [jqFmdb jq_inDatabase:^{
//        arrs = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
//    }];
    
    //判断是否需要刷新 当添加好友请求后
//    if ([NFUserEntity shareInstance].isNeedRefreshChatList && !isFirstCome) {
    [self checkChatListCorrect];//这里面只核查本地会话最后一条信息是否正确 未读不进行核查 因为未读肯定是服务器给的最新的 本地还没有缓存的新消息 肯定不一样
    [self chatListShowAbout];//角标显示
    
    if ([NFUserEntity shareInstance].isNeedRefreshLocalChatList){
        //只是刷新本地缓存
        [MessageChatListTableview reloadData];
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = NO;
    }
    if ((!isFirstCome && socketModel.isConnected  && [ClearManager getNetStatus] && IsAllowrConversationAgain) || [NFUserEntity shareInstance].isNeedRefreshChatList ) {
        //当与服务器连接状态时 每次都请求会话列表 但是具体是否更新根据算法执行【这样既不影响UE 又能保证数据准确性】
        [self initScoket];
        IsAllowrConversationAgain = NO;//进来后，下一次显示的时候就不再自己刷新了，等收到请求再刷新
        
//        [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"IsAllowrConversationAgain"
//        timeInterval:20
//               queue:nil
//             repeats:YES
//        actionOption:AbandonPreviousAction
//              action:^{
//                  IsAllowrConversationAgain = YES;
//            [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsAllowrConversationAgain"];
//              }];
        
        //防止访问次数过多，当有新消息，自然会刷新会话列表的
//        if(IsAllowRefreshConversation){
//            IsAllowRefreshConversation = NO;
//
//            [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"IsAllowRefreshConversation"
//            timeInterval:30
//                   queue:nil
//                 repeats:YES
//            actionOption:AbandonPreviousAction
//                  action:^{
//                      IsAllowRefreshConversation = YES;
//                [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsAllowRefreshConversation"];
//                  }];
//        }
        
        
        
    }
//    else if ([NFUserEntity shareInstance].isNeedRefreshLocalChatList){
//        //只是刷新本地缓存
//        [MessageChatListTableview reloadData];
//        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = NO;
//    }
    else{
        //如果进来后 已经请求过数据，但是没有请求成功显示为空 那么就重新请求【并判断是否部署第一次进来，第一次进来数据也会走到这里的判断】 这个逻辑暂时不用
//        if (self.dataArr.count == 0 && !isFirstCome) {
//            [self initScoket];
//        }
        //这里需要刷新 因为可能最后一条书库发生改变 2001中如果没有新消息是不会进行刷新的
        [MessageChatListTableview reloadData];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //貌似为了让界面先进行取缓存
//    sleep(0.5);
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
//    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
//    NSLog(@"");
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    //界面消失之前 结束下拉刷新
    if (reloading_) {
        [self doneLoadingTableViewData];
    }
    isFirstCome = NO;
//    newChatButton.alpha = 0;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    IsCanPopSaveSet = YES;//能够弹出安全设置
    isFirstCome = YES;//走这里就是第一次load 设置首次加载为YES
    IsAllowRefreshConversation = YES;
    IsAllowrConversationAgain = YES;
    [self initUI];//初始化界面
    rowHeightCache = [NSMutableDictionary new];//cell高度缓存
    if (IsCheckUpdate) {
//        [self checkAppUpdate];//检查版本更新
        //检查版本更新
        [[CCAppManager sharedInstance]configureApp];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateApp:) name:kNotificationAppShouldUpdate object:nil];
    }
    //增加通知观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectBreak:) name:@"connectBreak" object:nil];
    //是否来自转发 转发则进行请求 保证转发时候 数据的及时性【防止有新的聊天出现、和增加数据准确性】
    if (!self.fromType) {
        [self initScoket];
        //首页需要做的 请求好友请求
        [socketRequest getIsExistUnReadApply];
        //首页需要做的 请求未读朋友圈消息
        [socketRequest getCircleMsg];
    }
//    else{
//        [self chatListShowAbout];
//    }
    
    //如果为空 则赋值为0
    if (![NFUserEntity shareInstance].PushQRCode) {
        [NFUserEntity shareInstance].PushQRCode = @"0";
    }
    //当从3d touch 扫一扫进来 首页进行判断
    if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"1"]) {
        //跳转扫描二维码
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
        QRCodeScanViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"QRCodeScanViewController"];
        [self.navigationController pushViewController:qrcodeScanVC animated:YES];
    }else if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"4"]){
        //申请与通知
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
        ApplyViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ApplyViewController"];
        //点击后 红点提醒设置为no
        [NFUserEntity shareInstance].IsApplyAndNotify = NO;
        [self.navigationController pushViewController:toCtrol animated:YES];
    }
    
    //定时刷新定位
//    self.hcdTimer = [HCDTimer repeatingTimerWithTimeInterval:5 block:^{
//        [[NFUserEntity shareInstance].locationManager startUpdatingLocation];
//        [self getLocationDetail:[NFUserEntity shareInstance].cityName];
//        ZJContact *contact = [ZJContact new];
//        contact.user_id = @"111";
//        [self ZJContactA:contact];
//    }];
    
    
    int count = 0;
//    Ivar *ivars = class_copyIvarList([UIView class], &count);
    
    //定位2
//    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
//        CLLocationCoordinate2D currentLocation = location.coordinate;
//    } failureBlock:^(NSError *error) {
//        NSLog(@"");
//    } geocoderBlock:^(NSArray *geocoderArray) {
//        NSLog(@"");
//        id obj = [geocoderArray firstObject];
//        CLPlacemark *mark = [geocoderArray firstObject];
//        id obxj = mark.thoroughfare;//淮海东路
//        id objjj = mark.subThoroughfare;//140号
//        id objh = mark.locality;//淮安市
//        id objjjj = mark.subLocality;//清河区
////        id obja = mark.administrativeArea;//江苏省
//        NSLog(@"%@%@%@%@%@",mark.administrativeArea,mark.locality,mark.subLocality,mark.thoroughfare,mark.subThoroughfare);
//    }];
    
//    __weak typeof(self)weakSelf=self;
//    [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"checkHeartTuikuan"
//                                                        timeInterval:60.0
//                                                               queue:nil
//                                                             repeats:YES
//                                                        actionOption:AbandonPreviousAction
//                                                              action:^{
//                                                                  __strong typeof(weakSelf)strongSelf=weakSelf;
//                                                                  [strongSelf checkHeart];
//
//                                                              }];
    
    //请求收藏的表情
    [socketRequest requestCollectEmoji];
    
    
    
    
    
}

-(void)checkHeart{
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            //定时检查 是否有退回
            NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
            //@"{'ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}"
            [socketRequest checkTuikuanWithinfo:@{@"devicee":dev_info_json}];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
}


-(void)getLocationDetail:(NSString *)area{
    
}

-(void)ZJContactA:(ZJContact *)contact{
    
    
}


#pragma mark - 申请列表请求 为了显示 是否有添加好友请求

#pragma mark - 获取会话列表请求

#pragma mark - 请求已读单聊 【左滑删除】

#pragma mark - 请求已读群聊

#pragma mark - 刷新函数  【扫的人】通过扫描【出示二维码的人】分享的二维码加入群聊
-(void)refresh{
//    [SVProgressHUD show];
    [socketRequest getConversationList];
}

#pragma mark - 初始化界面
-(void)initUI{
    clearCacheBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 36)];
    MessageChatListTableview.separatorInset = UIEdgeInsetsMake(0,15, 0, 0);
    [MessageChatListTableview setSeparatorColor:SecondGray];
//    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    if (!self.fromType) {
        AddBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [AddBtn setImage:[UIImage imageNamed:@"添加按钮按钮"] forState:UIControlStateNormal];
        [AddBtn addTarget:self action:@selector(AddClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *AddBtnItem = [[UIBarButtonItem alloc]initWithCustomView:AddBtn];
        self.navigationItem.rightBarButtonItem = AddBtnItem;
    }
    MenuTableV_ = [[CCZTableButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 157, 65, 150, 0) CellHeight:44];
    MenuTableV_.offsetXOfArrow = 50;
    MenuTableV_.wannaToClickTempToDissmiss = YES; //不选cell 界面不消失，省去了一点麻烦
    [MenuTableV_ addItems:@[@"扫一扫",@"添加朋友",@"清空列表"]];
    MenuTableV_.TitleImageArr = @[@"扫一扫图标",@"添加好友下弹图标",@"清空会话列表"];
    MenuTableV_.CellBackColor = UIColorFromRGB(0xd8e3f5);
    MenuTableV_.CellTextColor = UIColorFromRGB(0x6982bd);
    
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 65, 34)];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    //[leftBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [leftBtn setTitle:@"全部已读" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    leftBtn.titleLabel.text = @"全部已读";
    [leftBtn addTarget:self action:@selector(allReadClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    //设置边框的颜色
   // [MenuTableV_.layer setBorderColor:UIColorFromRGB(0x6982bd).CGColor];
    //[self.mainTableView.layer setBorderColor:[UIColor redColor].CGColor];
    //设置边框的粗细
   // [MenuTableV_.layer setBorderWidth:1.0];
    
    [MenuTableV_ selectedAtIndexHandle:^(NSUInteger index, NSString *itemName) {
        if (index == 0) {
            //跳转扫描二维码
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
            QRCodeScanViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"QRCodeScanViewController"];
            [self.navigationController pushViewController:qrcodeScanVC animated:YES];
        }else if (index == 1){
            //添加好友
            //添加好友 跳转controller
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
            addFrienfViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"addFrienfViewController"];
            toCtrol.addFriendType = @"1";
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (index == 2){
            [self clearCache];
        }
    }];
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - SCREEN_HEIGHT, MessageChatListTableview.frame.size.width, SCREEN_HEIGHT)];
        refreshHeader.delegate = self;
        [refreshHeader setLogo];
        reloading_ = NO;
        [MessageChatListTableview addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
// 新建聊天按钮初始化
    if (!self.fromType) {
        newChatButton = [UIButton new];
        //    newChatButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 64 - 55, 45, 45)];
        [newChatButton setImage:[UIImage imageNamed:@"新建聊天"] forState:(UIControlStateNormal)];
        [newChatButton setImage:[UIImage imageNamed:@"新建聊天选中"] forState:(UIControlStateSelected)];
        [newChatButton addTarget:self action:@selector(newChatButtonClick:) forControlEvents:(UIControlEventTouchDown)];
        
        //    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
        //    window = [NFUIWindow shareInstance];
        [self.view addSubview: newChatButton];
        //    [win addSubview: newChatButton];
    }
    
    [newChatButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        if (SCREEN_HEIGHT > 736) {
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        }else{
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-55);
        }
    }];
    
//    newChatButton.layer.shadowOffset =  CGSizeMake(1, 1);
//    newChatButton.layer.shadowOpacity = 0.8;
//    newChatButton.layer.shadowColor =  [UIColor blackColor].CGColor;
    
    //新建聊天弹出框
    _cellView = [[MLMOptionSelectView alloc] initOptionView];
    MessageChatListTableview.tableFooterView = [UIView new];
    MessageChatListTableview.tableHeaderView = self.searchBar;
#pragma mark - 设置searchbar相关
    
    NSString *version = [UIDevice currentDevice].systemVersion;

    UITextField *Field;
        if (version.doubleValue >= 13.0) {// 这里是对 13.0 以上的iOS系统进行处理
            NSUInteger Views = [self.searchBar.subviews count];
            for(int i = 0; i < Views; i++) {
                if([[self.searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
                    Field = [self.searchBar.subviews objectAtIndex:i];
                }
            }
        }else {
            Field = [self.searchBar valueForKey:@"_searchField"];
        
        }
    
    //id Field = [self.searchBar valueForKey:@"_searchField"];
//    UITextField *txfSearchField;
//    if ([Field isKindOfClass:[UITextField class]]) {
//        txfSearchField = [self.searchBar valueForKey:@"_searchField"];
//    }
//    //设置searchbar textfield的placehold字体颜色
//    [txfSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [txfSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    
    Field.attributedPlaceholder=[[NSAttributedString alloc]initWithString:@"姓名/首字母" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    Field.backgroundColor = [UIColor colorTextfieldBackground];
    
    //放大镜
    [self.searchBar setImage:[UIImage imageNamed:@"searbar搜索"]
            forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    for (id searchbuttons in [[self.searchBar subviews][0]subviews]){
        if ([searchbuttons isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            // 修改文字颜色
            [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [cancelButton setTitle:@"返回" forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor colorThemeColor] forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor colorThemeColor] forState:UIControlStateHighlighted];
        }
    }
    
    self.searchBar.barTintColor = [UIColor colorNavigationBackground];
    UIView *view = Field.superview;
    view.backgroundColor = [UIColor colorTextfieldBackBackground];
    for (UIView *view in self.searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
           //
            if (@available(iOS 13.0, *)) {
                [[_searchBar.subviews objectAtIndex:0].subviews objectAtIndex:0].hidden = YES;
//                self.searchBar.searchTextField.backgroundColor = [UIColor clearColor];
               // [_searchBar.subviews objectAtIndex:0].backgroundColor = [UIColor redColor];
            } else {
                [[[_searchBar.subviews objectAtIndex:0].subviews objectAtIndex:0] removeFromSuperview];
                [_searchBar.subviews objectAtIndex:0].backgroundColor = [UIColor clearColor];
            }
            break;
        }
    }
    
    
    
    for (UIImageView *view in self.searchBar.subviews[0].subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIImageView")]) {
           //
            if (@available(iOS 13.0, *)) {
                view.backgroundColor = [UIColor clearColor];
                view.image = [UIImage imageNamed:@"QRC_scan_jixu"];
                
            }
            
            break;
        }
    }
    
    
    
//    id stateField = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    UIView *statusBar;
//    if ([stateField isKindOfClass:[UIView class]]) {
//        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    }
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        //statusBar.backgroundColor = [UIColor colorThemeColor];
//        statusBar.backgroundColor = [UIColor colorNavigationBackground];
//        statusBar.backgroundColor = [UIColor redColor];
//        //        statusBar.backgroundColor = UIColorFromRGB(0x503536);
//    }
    
}

#pragma mark - 请求到商店版本号
- (void)shouldUpdateApp:(NSNotification *)notification {
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    CCAppVersionModel *versionModel =[CCAppManager sharedInstance].versionInfo;
    if ([currentVersion floatValue] < [versionModel.version floatValue])
    {
        NSString *cancelString = @"取消";
        if (IsForceUpdate) {
            cancelString = nil;
        }
        if (IsForceUpdate) {
            //强制更新
            NotDismissAlertView *updateAlert = [[NotDismissAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",versionModel.version] delegate:self cancelButtonTitle:@"更新" otherButtonTitles:nil, nil];
            updateAlert.notDisMiss = YES;
            [updateAlert show];
        }else{
            //非强制更新
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",versionModel.version] delegate:self cancelButtonTitle:cancelString otherButtonTitles:@"更新",nil];
            [alert show];
        }
    }else{
        NSLog(@"版本号好像比商店大噢!检测到不需要更新");
    }
    //
    //[jqFmdb dropDatabase];
    //jq_columnNameArray
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *conversationArr = [jqFmdb jq_columnNameArray:@"huihualiebiao"];
    
}

#pragma mark - 检查版本更新 无效
-(void)checkAppUpdate{
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    //3从网络获取appStore版本号
    NSError *error;
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
    if ([currentVersion floatValue] < [appStoreVersion floatValue]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",appStoreVersion] delegate:self cancelButtonTitle:cancelString otherButtonTitles:@"更新",nil];
        [alert show];
    }else{
        NSLog(@"版本号好像比商店大噢!检测到不需要更新");
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

#pragma mark - 创建群组请求
//-(void)createGroupRequest:(NSArray *)memberArr{
//    NSMutableDictionary *parms = [NSMutableDictionary new];
//    parms[@"action"] = @"createGroup";
//    parms[@"userName"] = [NFUserEntity shareInstance].userName;
//    NSDate *currentDate = [NSDate date];
//    NSTimeInterval interval = [currentDate timeIntervalSince1970];
//    NSInteger time = interval;
//    parms[@"createTime"] = [NSString stringWithFormat:@"%ld",time];
//    parms[@"userId"] = [NFUserEntity shareInstance].userId;
//    ZJContact *contant = [memberArr firstObject];
//    NSString *titleName = [NSString stringWithFormat:@"和%@等人的聊天",contant.friend_username];
//    parms[@"groupName"] = titleName;
//    NSMutableArray *arr = [NSMutableArray new];
//    for (ZJContact *contact in memberArr) {
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        [dict setValue:contact.friend_username forKey:@"userName"];
//        [dict setValue:contact.friend_userid forKey:@"userId"];
//        [arr addObject:dict];
//    }
//    parms[@"groupUser"] = arr;
//    NSString *Json = [JsonModel convertToJsonData:parms];
//    if ([socketModel isConnected]) {
//        [socketModel ping];
//    }
//    if ([socketModel isConnected]) {
//        [socketModel sendMsg:Json];
//    }else{
//        [SVProgressHUD showInfoWithStatus:@"聊天系统未正常链接"];
//    }
//}

#pragma mark - 收到服务器消息
/**
 收到服务器消息
9001
 @param chatModel 收到服务器的数据
 @param messageType 接口类型
 */
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    if (![currentVC isKindOfClass:[MessageChatListViewController class]]) {
        return;
    }
    [SVProgressHUD dismiss];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doneLoadingTableViewData];
    });
    //获取会话列表2001 
    if (messageType == SecretLetterType_getChatSessionList) {
        
        self.navigationItem.title = @"多信";
//        IsAllowrConversationAgain = YES;
        //公开处理 会话列表相关 【只要走了status 2001 就会执行下面代码】【所以当请求会话劣币哦啊 不会走到这里了 在socketmodel中直接调用下面方法进行reload界面】
        if ([chatModel isKindOfClass:[NSArray class]]) {
            [self conversationListRefresh:chatModel];
//            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//            __weak typeof(self)weakSelf=self;
//            for (MessageChatListEntity *chatListEntity in chatModel) {
//                //-(void)getGroupChatData:(GroupCreateSuccessEntity *)groupCreateSEntity AndChatEntity:(MessageChatEntity *)chatEntity{
//                GroupCreateSuccessEntity *createSEntity = [GroupCreateSuccessEntity new];
//                createSEntity.groupId = chatListEntity.conversationId;
//                //取表中最后一条数据
//                __block NSArray *arr = [NSArray new];
//                [jqFmdb jq_inDatabase:^{
//                    __strong typeof(weakSelf)strongSelf=weakSelf;
//                    int allCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",chatListEntity.conversationId]];
//                    arr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",chatListEntity.conversationId] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
//                }];
//                MessageChatEntity *lastChatEntity = [arr lastObject];
//                [socketRequest getGroupChatData:createSEntity AndChatEntity:lastChatEntity];
//
//            }
        }
    }else if (messageType == SecretLetterType_notifyRefreshChatSessionList){
        //当有新消息时候 刷新会话列表
        [socketRequest getConversationList];
        
    }else if (messageType == SecretLetterType_groupCreateSuccess){
        //创建成功
        self.chatCreateSuccessEntity = chatModel;
        //选中完 跳转到聊天
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        toCtrol.memberArr = self.chatCreateSuccessEntity.groupAllUser;
        toCtrol.groupTotalNum = self.chatCreateSuccessEntity.groupTotalNum;
        toCtrol.groupCreateSEntity = self.chatCreateSuccessEntity;
    }else if (messageType == SecretLetterType_NormalReceipt){//4001
        //进行缓存 【收到4001发送成功 才进行缓存】
        //转发才走这里 当收到转发的消息，进行缓存会话列表、消息记录操作
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = chatModel;
            //防止两台设置同时登陆 一个人转发消息，另一个人在会话列表界面，没转发的那个人是没有forwardContent这个参数的，会导致崩溃【仅仅在会话列表界面】
            if (!self.forwardContent) {
                return;
            }
            //缓存更新在socketModel中已经做了
            
            //当增加转发图片功能 这里需要修改
//            if ([[dict objectForKey:@"type"] isEqualToString:@"0"]) {
//                [self addSpecifiedItem:@{@"chatId":[dict objectForKey:@"chatId"],@"strContent":self.forwardContent,@"type":@"0",@"userName":[NFUserEntity shareInstance].userName}];
//            }else if ([[dict objectForKey:@"type"] isEqualToString:@"1"]){
//                [self addSpecifiedItem:@{@"chatId":[dict objectForKey:@"chatId"],@"picture":[NFUserEntity shareInstance].forwardImage,@"type":@"1",@"userName":[NFUserEntity shareInstance].userName}];
//            }else if ([[dict objectForKey:@"type"] isEqualToString:@"2"]){
//                //语音不能转发
//            }
        }
        //单聊消息发送回执 这里为转发后的回调
        if (self.fromType || self.IsFromCard) {
            [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
            //单聊如果转发对象是正在会话的聊天人 则需要刷新
            if ([selectedChatListEntity.receive_user_name isEqualToString:self.chatingName] && selectedChatListEntity.IsSingleChat) {
                [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
            }
            [self.navigationController popViewControllerAnimated:YES];
            //要不pop到根视图 一切从缓存重新取 或则判断是否发给当前聊天中的这个人 是的话pop回去走一下取本地缓存
        }
    } else if (messageType == SecretLetterType_ReceiveGroupMessage){
        //群聊消息发送回执 这里为转发后的回调 5003
        if (self.fromType|| self.IsFromCard) {
//            self.tabBarController.tabBar.hidden = NO;
            if ([selectedChatListEntity.receive_user_name isEqualToString:self.chatingName] && !selectedChatListEntity.IsSingleChat) {
                [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }else if (messageType == SecretLetterType_ChatAlreadyRead){
        if (!selectedEditIndexPath) {
            return;
        }
        MessageChatListEntity *entity = self.dataArr.count>selectedEditIndexPath.row?self.dataArr[selectedEditIndexPath.row]:nil;
        NSString *IsSingleChat = @"0";
        if (entity.IsSingleChat) {
            IsSingleChat = @"1";
        }
        //删除群消息记录
        if (!entity.IsSingleChat && [isNeedDeleteGroupHistory isEqualToString:@"1"]) {
            BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:[NSString stringWithFormat:@"qunzu%@",entity.conversationId] IsDelete:NO];
            if (rett) {
            }
        }
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:entity.conversationId SecondKeyName:@"IsSingleChat" SecondValueName:IsSingleChat];
        if (ret) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
        [self.dataArr removeObjectAtIndex:selectedEditIndexPath.row];
        [MessageChatListTableview   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:selectedEditIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
        //减去相应的角标
        __weak typeof(self)weakSelf=self;
        __block NSArray *groupDetailArr = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            groupDetailArr = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",@"groupId",entity.conversationId]];
        }];
        GroupCreateSuccessEntity *entityyy= [groupDetailArr firstObject];
        if (![entityyy.allow_push isEqualToString:@"0"] || !entity.IsDisturb) {
            [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:NO];
        }
        
        selectedEditIndexPath = nil;
    }else if (messageType == SecretLetterType_GroupChatHistory){
        //5012 群聊历史
        if (![chatModel isKindOfClass:[NSDictionary class]]) {
            return;
        }
        chatModel = (NSDictionary *)chatModel;
        NSMutableArray *getArr = [NSMutableArray arrayWithArray:[chatModel objectForKey:@"groupArr"]];
        if (getArr.count == 0) {
            return;//会话列表界面 当收到历史消息count为0 说明是进行了下拉刷新操作 群聊所有的历史消息已经缓存了 直接return
        }
        //得到群组消息历史 进行数据缓存
        [self dealHistoryChatData:getArr GroupId:[chatModel objectForKey:@"groupId"]];
        
    }else if (messageType == SecretLetterType_ChatHistory){//4003
        if (![chatModel isKindOfClass:[NSDictionary class]] || [[chatModel objectForKey:@"singleArr"] count] == 0) {
            return;
        }
        chatModel = (NSDictionary *)chatModel;
        NSMutableArray *getArr = [NSMutableArray arrayWithArray:[chatModel objectForKey:@"singleArr"]];
        if (getArr.count > 0 && [[chatModel objectForKey:@"singleId"] length] > 0) {
            [self dealSingleHistoryChatData:getArr SingleId:[chatModel objectForKey:@"singleId"]];
        }
        
    }else if(messageType == SecretLetterType_collectPicture){ 
        NSArray *pictureArr = chatModel;
        NSString *str = [NFUserEntity shareInstance].HeadPicpathAppendingString;
        
        
        [EmotionTool initialize];
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[EmotionTool CollectImages]];
            BOOL ret = NO;
            for (NSString *path in arr) {
                if (![path containsString:[NFUserEntity shareInstance].userName]) {
                    //如果不含有username 说明不是最新版本
                    ret = YES;
                    break;
                }
            }
            if(arr.count == pictureArr.count && !ret){
                NSLog(@"本地有收藏的表情，不需要更新");
                return ;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showLoadToView:self.view title:@"数据加载中"];
            });
            
            for (NSString *strr in arr) {
                [EmotionTool delectCollectImage:strr];
            }
            if(pictureArr.count == 0){
                [MBProgressHUD hideHUDForView:self.view];
            }
            __block CGFloat count = 0;
            for (NSDictionary *picDict in pictureArr) {
                EmotionTool *tool = [EmotionTool new];
                [tool returnCollectSuccessBlock:^{
                    count ++;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view];
                        [MBProgressHUD showDownToView:self.view progressStyle:(NHHUDProgressDeterminate) title:@"数据恢复中" progress:^(MBProgressHUD *hud) {
                            CGFloat allCount = pictureArr.count;
                            CGFloat a = count/allCount;
                            hud.progress = a;
                        }];
                    });
                    
                    if (count == pictureArr.count) {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                            sleep(2);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBProgressHUD hideHUDForView:self.view];
                            });
                        });
                    }
                }];
                [tool addCollectImage:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[picDict objectForKey:@"file_path"] description]] AndfileId:[[picDict objectForKey:@"file_id"] description] AndScale:[[picDict objectForKey:@"img_ratio"] description]];
                
//                [EmotionTool addCollectImage:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[picDict objectForKey:@"file_path"] description]] AndfileId:[[picDict objectForKey:@"file_id"] description] AndScale:[[picDict objectForKey:@"img_ratio"] description]];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                //[MBProgressHUD hideHUDForView:self.view];
            });
        });
        
        [@"" containsString:@""];
        
    }
        
}

#pragma mark - 9001
#pragma mark - 会话列表收到服务器消息 相关处理
-(void)conversationListRefresh:(NSArray *)chatModel{
    [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsAllowrConversationAgain"];
//    IsAllowrConversationAgain = YES;
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        [SVProgressHUD dismiss];
        MessageChatListTableview.showsVerticalScrollIndicator = YES;
    });
    //请求完设置no
    [NFUserEntity shareInstance].isNeedRefreshChatList = NO;
    //MessageChatListEntity
    [self.fmdbServicee IsExistHuihualiebiao];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    NSMutableArray *getArr = [NSMutableArray arrayWithArray:chatModel];
    //将本地缓存取出来 用于与服务器的进行对比
    __block NSArray *localChatListArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        localChatListArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    }];
#warning 看看这里的数据 有没有刚发的那个 【问题：收到消息有声音但是会话列表不更新 已解决】
    for (MessageChatListEntity *entity in getArr) {
        //将服务器给的会话列表与本地会话列表进行比对 一旦有出入则进行更新
        //记录 本地和服务器返回相同的会话entity 用于判断是否需要进行update缓存
        MessageChatListEntity *theSameChatListEntity = nil;
        for (MessageChatListEntity *localChatEntity in localChatListArr) {
            //                NSLog(@"\nlocalChatEntity.last_message_id:%@\nentity.last_message_id:%@\n",localChatEntity.last_message_id,entity.last_message_id);
            if ([localChatEntity.last_message_id isEqualToString:entity.last_message_id]) {
                //当找到本地的会话列表有某条会话喝服务器的一样 则进行下一次循环比对
                entity.IsUpSet = localChatEntity.IsUpSet;//将顶置进行赋值
                theSameChatListEntity = localChatEntity;
                break;//当找到服务器返回的会话在本地的那一条数据 则直接break跳出该for循环 进行后面操作和下次循环
            }
        }
        
        if ([entity.msgType isEqualToString:@"image"]) {
            entity.last_send_message = @"[图片]";
        }else if ([entity.msgType isEqualToString:@"audio"]){
            entity.last_send_message = @"[语音]";
        }
        //将服务器给的会话列表 从本地取 看看能不能取到
        NSString *key = @"conversationId";
        NSString *keyValue = entity.conversationId;
        NSString *secondKey = @"IsSingleChat";
        NSString *secondKeyValue = entity.IsSingleChat?@"1":@"0";
        __block NSArray *repeatArr = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            repeatArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",key,keyValue,secondKey,secondKeyValue]];
        }];
        
        
        //有新的会话产生 需要更新
#warning 在这里打断点 获取到本地会话列表和这个消息一样 的实体 看看是新建还是更改
        if (repeatArr.count > 0) {
            //有该条会话 则update 【当重复请求会话列表，这里的lastId是thesame的 则不需要进行uodate 懒缓存】
            if (![theSameChatListEntity.last_message_id isEqualToString:entity.last_message_id] || ![theSameChatListEntity.update_time isEqualToString:entity.update_time]) {
                [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:entity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:entity.IsSingleChat?@"1":@"0" TableName:@"huihualiebiao"];
            }
        }else{
            //如果没有 则为新建会话
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                if (entity.conversationId.length>0 && entity.receive_user_name.length > 0) {
                    BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"huihualiebiao" dicOrModel:entity];
                }
            }];
        }
    }
    //顶置、角标处理
    [self chatListShowAbout];
#pragma mark - 这里进行检查时候从退出程序时点击推送进来的
    if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"]) {
        //            UILabel *labell = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        //            labell.backgroundColor = [UIColor redColor];
        //            UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
        //            [win addSubview:labell];
        //跳转到单聊
        for (int i = 0; i<self.dataArr.count; i++) {
            NSLog(@"----\n\n\n\n\n准备单聊----\n\n\n\n\n");
            MessageChatListEntity *entity = self.dataArr.count>i?self.dataArr[i]:nil;
            if ([entity.conversationId isEqualToString:[NFUserEntity shareInstance].pushId] && entity.IsSingleChat) {
                //                    [self.myManage notifySet];
                NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:1];
                selectedChatListEntity = self.dataArr.count>indexP.row?self.dataArr[indexP.row]:nil;
                [self pushToSingleChat:selectedChatListEntity IndexPath:indexP];
                
                NSLog(@"----\n\n\n\n\n单聊----\n\n\n\n\n");
                break;
            }
        }
    }else if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]){
        //跳转到群聊
        NSLog(@"----\n\n\n\n\n准备群聊----\n\n\n\n\n");
        for (int i = 0; i<self.dataArr.count; i++) {
            MessageChatListEntity *entity = self.dataArr.count>i?self.dataArr[i]:nil;
            if ([entity.conversationId isEqualToString:[NFUserEntity shareInstance].pushId] && !entity.IsSingleChat) {
                NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:1];
                selectedChatListEntity = self.dataArr.count>indexP.row?self.dataArr[indexP.row]:nil;
                [self pushToGroupChat:selectedChatListEntity IndexPath:indexP];
                NSLog(@"----\n\n\n\n\n群聊----\n\n\n\n\n");
                break;
            }
        }
    }else{
        //当为 不是跳转到群聊、单聊 设置为正常 否则等跳转完成 请求到消息历史 再设置为正常
        [NFUserEntity shareInstance].PushQRCode = @"0";
    }
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        //过滤数据 将阅后隐藏的数据过滤掉
        //            [self initLegalData];
        [MessageChatListTableview reloadData];
    });
    
    //遍历会话列表 将群聊消息历史请求历史记录 进行缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        for (MessageChatListEntity *chatListEntity in chatModel) {
            if([chatListEntity.IsNotRequestHistory isEqualToString:@"1"]){
                continue;
            }
            //-(void)getGroupChatData:(GroupCreateSuccessEntity *)groupCreateSEntity AndChatEntity:(MessageChatEntity *)chatEntity{
            if (chatListEntity.IsSingleChat && ![chatListEntity.msgType isEqualToString:@"system"]) {
                //取表中最后一条数据 单聊，理论上这里是不可能走到的
                //单聊消息每次收到都会缓存，所以不会请求到4003的历史消息
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    int allCount = [strongSelf ->jqFmdb jq_tableItemCount:chatListEntity.conversationId];
                    arr = [strongSelf ->jqFmdb jq_lookupTable:chatListEntity.conversationId dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
                MessageChatEntity *lastChatEntity = [arr lastObject];
                ZJContact *friendEntity = [ZJContact new];
                friendEntity.friend_userid = chatListEntity.conversationId;
                friendEntity.friend_username = chatListEntity.receive_user_name;
                [SVProgressHUD showWithStatus:@"收取中"];
                [socketRequest getSingleChatDataWithFriendEntity:friendEntity LastChatEntity:lastChatEntity];
            }else if(!chatListEntity.IsSingleChat){
                //取表中最后一条数据 群聊
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    int allCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",chatListEntity.conversationId]];
                    arr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",chatListEntity.conversationId] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
                MessageChatEntity *lastChatEntity = [arr lastObject];
                GroupCreateSuccessEntity *createSEntity = [GroupCreateSuccessEntity new];
                createSEntity.groupId = chatListEntity.conversationId;
                [SVProgressHUD showWithStatus:@"收取中"];
                [socketRequest getGroupChatData:createSEntity AndChatEntity:lastChatEntity];
            }
        }
    }];
    
}

#pragma mark - 单聊历史缓存
//收到历史消息 缓存处理   【过滤无用数据】 【检查表在model的4003中已完成】
-(void)dealSingleHistoryChatData:(NSMutableArray *)getArr SingleId:(NSString *)singleId{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    //取数据库最后一条消息 为的是 核实给的消息历史的准确性【当收到的消息chat大于本地的最后一条消息 则都是新消息】
    __block NSArray *arr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        int allCount = [strongSelf ->jqFmdb jq_tableItemCount:singleId];
        arr = [strongSelf ->jqFmdb jq_lookupTable:singleId dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
    }];
    __block MessageChatEntity *lastChatEntity = [arr lastObject];//这里取到数据库的最后一条消息
    //如果服务器返回的 最后一条消息比本地最后一条消息 <= chatId 则说明服务器返回的消息 本地全部都已经缓存了 直接remove所有
    MessageChatEntity *serverBackEntity = [getArr lastObject];
    if ([serverBackEntity.chatId integerValue] <= [lastChatEntity.chatId integerValue]) {
        [getArr removeAllObjects];
    }
    NSArray * copyArr = [NSArray arrayWithArray:getArr];
    for (MessageChatEntity *repeatChatEntity in copyArr) {
        //从服务器返回的历史消息第0条在数据库查 如果本地有了这条数据 则从getArr中remove，一旦遇到没有的 说明后面的都没有 直接break
        //假设 给的消息历史中 某一条消息已读了 那么 这条消息之前的消息都肯定是已读的，从0开始遍历是对的
        __block NSArray *ifExistHistoryArr = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            ifExistHistoryArr = [strongSelf ->jqFmdb jq_lookupTable:singleId dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",repeatChatEntity.chatId];//取最后一条消息的chatId在本地数据库查找是否已经存在
        }];
        if (ifExistHistoryArr.count > 0) {//如果本地数据库存在该条消息 那么remove
            [getArr removeObject:repeatChatEntity];
        }else if ([repeatChatEntity.chatId integerValue] >                                                                             [lastChatEntity.chatId integerValue]){//如果从本地查不到该条数据 并且该消息id 大于等于
            break;
        }
    }
    
    __block NSArray *errorArr = [NSArray new];
    if (getArr.count > 0) {
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            NSLog(@"strongSelf====2");
            errorArr = [strongSelf ->jqFmdb jq_insertTable:singleId dicOrModelArray:getArr];
        }];
        if (errorArr.count > 0) {
            [SVProgressHUD showInfoWithStatus:@"有部分消息缓存失败"];
        }
    }
    
}

#pragma mark - 群聊历史缓存
//收到历史消息 缓存处理   【检查表存在、过滤无用数据】
-(void)dealHistoryChatData:(NSMutableArray *)getArr GroupId:(NSString *)groupId{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    //检查是否有该表
    [self.fmdbServicee IsExistGroupChatHistory:[NSString stringWithFormat:@"qunzu%@",groupId] ISNeedAppend:NO];
    //取数据库最后一条消息
    __block NSArray *arr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        int allCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",groupId]];
        arr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",groupId] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",allCount - 1,1]];//就一条
    }];
    __block MessageChatEntity *lastChatEntity = [arr lastObject];
    //如果服务器返回的 最后一条消息比本地最后一条消息 <= chatId 则说明服务器返回的消息 本地全部都已经缓存了 直接remove所有
    MessageChatEntity *serverBackEntity = [getArr lastObject];
    if ([serverBackEntity.chatId integerValue] <=[lastChatEntity.chatId integerValue]) {
        [getArr removeAllObjects];
    }
    
    NSArray * copyArr = [NSArray arrayWithArray:getArr];
//    TICK
    for (MessageChatEntity *repeatChatEntity in copyArr) {
        
        //从服务器返回的历史消息第0条在数据库查 如果本地有了这条数据 则从getArr中remove，一旦遇到没有的 说明后面的都没有 直接break
        //假设 给的消息历史中 某一条消息已读了 那么 这条消息之前的消息都肯定是已读的，从0开始遍历是对的
        __block NSArray *ifExistHistoryArr = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            ifExistHistoryArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",groupId] dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",repeatChatEntity.chatId];//取最后一条消息的chatId在本地数据库查找是否已经存在
        }];
        if (ifExistHistoryArr.count > 0) {//如果本地数据库存在该条消息 那么remove
            [getArr removeObject:repeatChatEntity];
        }else if ([repeatChatEntity.chatId integerValue] > [lastChatEntity.chatId integerValue]){//如果从本地查不到该条数据 并且该消息id 大于等于
            break;
        }
    }
    
    
    
//    TOCK
    __block NSArray *errorArr = [NSArray new];
    if (getArr.count > 0) {
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            errorArr = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",groupId] dicOrModelArray:getArr];
//            NSArray *cacheArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",groupId] dicOrModel:[MessageChatEntity class] whereFormat:@""];
            NSLog(@"");
        }];
        if (errorArr.count > 0) {
            [SVProgressHUD showInfoWithStatus:@"有部分消息缓存失败"];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"qunzuAiteBool%@",groupId]]) {
        [MessageChatListTableview reloadData];
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = NO;
    }
    
    // 群聊消息 设置已收到
    //MessageChatEntity *getGroupId = [getArr lastObject];
//    [socketRequest haveReceived:getGroupId.chatId otherPartyId:getGroupId.user_id isSingle:NO];
}

#pragma mark - 会话列表界面显示相关
-(void)chatListShowAbout{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    //排序、顶置相关处理
    BOOL IsNeedFresh = NO;
    NSArray *lastArr = [self sortAbout];
    
    if(self.dataArr.count != lastArr.count){
        IsNeedFresh = YES;
    }
    //核实显示的准确性
    if (!IsNeedFresh) {
        for (int i = 0; i<lastArr.count; i++) {
            MessageChatListEntity *entity = lastArr[i];
            MessageChatListEntity *entitySec = self.dataArr[i];
            if (![entity.conversationId isEqualToString:entitySec.conversationId] || ![entity.last_send_message isEqualToString:entitySec.last_send_message]|| ![entity.headPicpath isEqualToString:entitySec.headPicpath]) {
                IsNeedFresh = YES;
                break;
            }
        }
    }
    self.dataArr = [NSMutableArray arrayWithArray:lastArr];
    //初始化角标
    [NFUserEntity shareInstance].badgeCount = 0;
    //一旦刷新绘画列表 将重新计算未读总个数
    unreadAllCount = 0;
    //将未读加上去
    for (MessageChatListEntity *entity in self.dataArr) {
        //设置角标
//        NSLog(@"%@",entity.unread_message_count);
        if (!entity.IsDisturb) {
            [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:YES];
            unreadAllCount += [entity.unread_message_count integerValue];
        }
    }
    //当数据为空 显示 空图片
    if (self.dataArr.count == 0) {
        //当会话列表界面数据没有 则设置角标为0
        [NFUserEntity shareInstance].badgeCount = 0;
        [[NFbaseViewController new] setBadgeCountWithCount:0 AndIsAdd:YES];
        MessageChatListTableview.isNeed = YES;
        //            [MessageChatListTableview showNone];
        [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空" TableviewWidth:SCREEN_WIDTH AndHeight:0];
    }else{
        dispatch_main_async_safe(^{
            [MessageChatListTableview removeNone];
        })
    }
    if (IsNeedFresh) {
        [MessageChatListTableview reloadData];
    }
//    [MessageChatListTableview reloadData]; //不在在这里进行刷新 【2001status中本来想//当收到的会话列表为nil 则不提醒刷新 【声音是在4002中的 设置设置无效 但是4002中无法知道该消息是否已读所以无法进行判断不提示声音】
}

#pragma mark - 新建聊天、安全设置点击事件
-(void)newChatButtonClick:(UIButton *)sender{
    sender.selected = YES;
    timeCount = 0;
    if (self.timerr) {
        [self.timerr invalidate];
        self.timerr = nil;
    }
    self.timerr =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeBegin) userInfo:self repeats:YES];
//    self.titleArr_ = @[@"普通聊天"];
    self.titleArr_ = @[@"创建群聊"];
    self.picArr_ = @[@"普通聊天"];
    [self customCell];
    _cellView.edgeInsets = UIEdgeInsetsMake(0, 0, -6, 0);
//    _cellView.edgeInsets = UIEdgeInsetsMake(0, 0, 100, 0);
    [_cellView showOffSetScale:offSet viewWidth:150 targetView:newChatButton direction:MLMOptionSelectViewTop];
    //选中新建单聊后 不能弹出安全设置
    __weak typeof(self)weakSelf=self;
    _cellView.selectedOption = ^(NSIndexPath *path) {
        self -> IsCanPopSaveSet = NO;
        self -> timeCount = 0;
        if (weakSelf.timerr) {
            [weakSelf.timerr invalidate];
            weakSelf.timerr = nil;
        }
        sender.selected = NO;
        NSString *title = weakSelf.titleArr_[path.row];
        //普通聊天
        if ([title isEqualToString:@"创建群聊"]) {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
            toCtrol.SourceType = SourceTypeFromChatListRight;
            [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
                //后面界面点击完成后 回调这里 进行一系列请求 FriendListEntity
                if (memberArr.count == 1) {
                    //选中完 跳转到聊天
                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                    MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
                    toCtrol.IsFromAdd = YES;
                    ZJContact *contact = [memberArr firstObject];
                    if (contact.friend_nickname.length > 0) {
                        toCtrol.titleName = contact.friend_nickname;
                    }else{
                        toCtrol.titleName = contact.friend_username;
                    }
//                    toCtrol.conversationId = contact.chatId;
                    //toCtrol.chatType = @"0";
                    toCtrol.singleContactEntity = contact;
                    [weakSelf.navigationController pushViewController:toCtrol animated:YES];
                }else{
                }
            }];
            [weakSelf.navigationController pushViewController:toCtrol animated:YES];
        }else if ([title isEqualToString:@"安全设置"]){
            //安全设置
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            SaveSetTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SaveSetTableViewController"];
            [weakSelf.navigationController pushViewController:toCtrol animated:YES];
        }
    };
    //点击空白后 不能弹出安全设置
    _cellView.ClickCover = ^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf -> IsCanPopSaveSet = NO;
        strongSelf->timeCount = 0;
        if (strongSelf.timerr) {
            [strongSelf.timerr invalidate];
            strongSelf.timerr = nil;
        }
        sender.selected = NO;
    };
    
    //显示安全设置
    [self performSelector:@selector(newChatButtonClickSecond) withObject:nil afterDelay:nsTimerCount];
    
}

//定时器
-(void)timeBegin{
    timeCount ++;
    if (timeCount == nsTimerCount) {
        IsCanPopSaveSet = YES;
        timeCount = 0;
    }else{
        IsCanPopSaveSet = NO;
    }
}

//显示第二个cell
-(void)newChatButtonClickSecond{
    //如果为no 则不弹
    if (!IsCanPopSaveSet) {
        return;
    }
    self.titleArr_ = @[@"安全设置",@"创建群聊"];
    self.picArr_ = @[@"密语聊天设置",@"普通聊天"];
    [self customCell];
    _cellView.edgeInsets = UIEdgeInsetsMake(0, 0, -6, 0);
    [_cellView showViewCenter:self.view.center viewWidth:150];
    [_cellView showOffSetScale:offSet viewWidth:150 targetView:newChatButton direction:MLMOptionSelectViewTop];
}

//自定制cell
-(void)customCell{
    [_cellView registerNib:[UINib nibWithNibName:@"MLMOptionSelectTableViewCell" bundle:nil] forCellReuseIdentifier:@"MLMOptionSelectTableViewCell"];
    __weak typeof(self)weakSelf=self;
    _cellView.cell = ^(NSIndexPath *indexPath){
        MLMOptionSelectTableViewCell *cell = [weakSelf.cellView dequeueReusableCellWithIdentifier:@"MLMOptionSelectTableViewCell"];
        cell.titleText.text = weakSelf.titleArr_[indexPath.row];
        cell.titleText.textColor = [UIColor whiteColor];
        cell.imageV.image = [UIImage imageNamed:weakSelf.picArr_[indexPath.row]];
        return cell;
    };
    _cellView.optionCellHeight = ^{
        return 60.f;
    };
    _cellView.rowNumber = ^(){
        return (NSInteger)weakSelf.titleArr_.count;
    };
}

#pragma mark - 右侧按钮点击
- (void)AddClicked
{
    
    //[socketRequest testActionaaa];
    
    
//    [socketModel disConnect];
    //菜单
    [MenuTableV_ show];
}


#pragma mark - 左侧按钮点击
- (void)allReadClicked{
    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"确认将所有未读标为已读么" sureBtn:@"确认" cancleBtn:@"取消"];
    alertView.resultIndex = ^(NSInteger index)
    {
        if (index == 2) {
            //请求已读接口 并且将本地所有w未读 设置为已读
            
            [socketRequest allReadRequest];
            
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *arrs = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
            }];
            [NFUserEntity shareInstance].badgeCount = 0;
            //在badgeCount的基础上 进行下面的操作
            [[NFbaseViewController new] setBadgeCountWithCount:0 AndIsAdd:YES];
            for (MessageChatListEntity *entity in arrs) {
                if ([entity.unread_message_count floatValue] > 0 && entity.IsSingleChat) {
                    entity.unread_message_count = @"0";
                    [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:entity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
                }else if([entity.unread_message_count floatValue] > 0 && !entity.IsSingleChat){
                    entity.unread_message_count = @"0";
                    [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:entity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"0" TableName:@"huihualiebiao"];
                }
            }
            self.dataArr = [NSMutableArray arrayWithArray:arrs];
            if (self.dataArr.count == 0) {
                MessageChatListTableview.isNeed = YES;
                //                        [MessageChatListTableview showNone];
                [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
            }else{
                dispatch_main_async_safe(^{
                    [MessageChatListTableview removeNone];
                })
            }
            
            [MessageChatListTableview reloadData];
        }
    };
    [alertView showMKPAlertView];
    
}


#pragma mark - //清空会话列表
- (void)clearCache
{
//    [self setUserEnabledNO];
//    __weak typeof(self)weakSelf=self;
//    PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:@"清除缓存" message:@"确认清空会话列表？" isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
//            //设置可点
//            [weakSelf setUserEnabledYES];
//            if (sureBlock) {
//                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//                BOOL deleteRet = [jqFmdb jq_deleteAllDataFromTable:@"huihualiebiao"];
//                if (deleteRet) {
//                    //取缓存刷新界面
//                    NSArray *arrs = [NSArray new];
//                    arrs = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
//                    NSSortDescriptor *create_time = [NSSortDescriptor sortDescriptorWithKey:@"create_time" ascending:NO];
//                    NSArray *newArr = [arrs sortedArrayUsingDescriptors:@[create_time]];
//                    //初始化角标
//                    [NFUserEntity shareInstance].badgeCount = 0;
//                    //将未读加上去
//                    for (MessageChatListEntity *entity in newArr) {
//                        //设置角标
//                        [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:YES];
//                    }
//                    self.dataArr = [NSMutableArray arrayWithArray:newArr];
//                    
//                    if (self.dataArr.count == 0) {
//                        MessageChatListTableview.isNeed = YES;
////                        [MessageChatListTableview showNone];
//                        [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
//                    }else{
//                        [MessageChatListTableview removeNone];
//                    }
//                    [MessageChatListTableview reloadData];
//                }
//            }
//        }];
//    [popV setSecTitleBackColor:[UIColor colorThemeColor]];
//    [popV setSecSureColor:[UIColor colorThemeColor]];
//    [popV setSecMessageColor:UIColorFromRGB(0x666666)];
//    [popV setSecMessageLabelTextAlignment:@"0"];
//    [self.view addSubview:popV];
    
    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"确认清空会话列表?" sureBtn:@"确认" cancleBtn:@"取消"];
    alertView.resultIndex = ^(NSInteger index)
    {
        if(index==2){
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            BOOL deleteRet = [jqFmdb jq_deleteAllDataFromTable:@"huihualiebiao"];
            if (deleteRet) {
                //取缓存刷新界面
                __block NSArray *arrs = [NSArray new];
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
                }];
                NSSortDescriptor *create_time = [NSSortDescriptor sortDescriptorWithKey:@"create_time" ascending:NO];
                NSArray *newArr = [arrs sortedArrayUsingDescriptors:@[create_time]];
                //初始化角标
                [NFUserEntity shareInstance].badgeCount = 0;
                //将未读加上去
                for (MessageChatListEntity *entity in newArr) {
                    //设置角标
                    [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:YES];
                }
                self.dataArr = [NSMutableArray arrayWithArray:newArr];
                if (self.dataArr.count == 0) {
                    MessageChatListTableview.isNeed = YES;
                    //                        [MessageChatListTableview showNone];
                    [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
                }else{
                    dispatch_main_async_safe(^{
                        [MessageChatListTableview removeNone];
                    })
                }
                [MessageChatListTableview reloadData];
            }
        }
    };
    [alertView showMKPAlertView];
}

//懒加载
-(GroupCreateSuccessEntity *)chatCreateSuccessEntity{
    if (!_chatCreateSuccessEntity) {
        _chatCreateSuccessEntity = [[GroupCreateSuccessEntity alloc] init];
    }
    return _chatCreateSuccessEntity;
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

-(void)checkChatListCorrect{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    }];
    
    //进行核实显示的最后一条消息是否正确
    for (MessageChatListEntity *chatListEntityy in arrs) {
        if (chatListEntityy.IsSingleChat) {
            //单聊
            BOOL isNeedChangeFMDB = NO;//是否需要进行FMDB更改操作 需要时才进行changeData
            __block NSArray *existArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                int dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:chatListEntityy.conversationId];//取某单聊消息历史条数
                if (dataaCount > 0) {
                    existArr = [strongSelf ->jqFmdb jq_lookupTable:chatListEntityy.conversationId dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                }
//                if (existArr.count == 0 && dataaCount > 0) {
//                    existArr = [strongSelf ->jqFmdb jq_lookupTable:chatListEntityy.conversationId dicOrModel:[MessageChatEntity class] whereFormat:@""];
//                }
            }];
            MessageChatEntity *chatEntity = [existArr firstObject];
//            if (chatListEntityy.last_message_id.length>0 && chatEntity.chatId.length>0 && ![chatEntity.chatId isEqualToString:chatListEntityy.last_message_id] && [chatListEntityy.unread_message_count integerValue] == 0) {
//            if (![chatListEntityy.last_send_message isEqualToString:chatEntity.message_content] && [chatListEntityy.unread_message_count integerValue] == 0 && chatEntity.message_content.length > 0) {
            if (![chatListEntityy.last_send_message isEqualToString:chatEntity.message_content] && chatEntity.message_content.length > 0) {
                isNeedChangeFMDB = YES;
                //如果最后一条消息不准确 则进行更改
//                chatListEntityy.last_message_id = chatEntity.chatId;
                chatListEntityy.last_send_message = chatEntity.message_content;
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }
            if ([chatEntity.msgType isEqualToString:@"image"] && ![chatListEntityy.last_send_message isEqualToString:@"[图片]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"[图片]";;
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"audio"] && ![chatListEntityy.last_send_message isEqualToString:@"[语音]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"[语音]";;
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"red"] && ![chatListEntityy.last_send_message containsString:@"[多信红包]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = [NSString stringWithFormat:@"[多信红包]%@",chatEntity.message_content];
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"card"] && ![chatListEntityy.last_send_message containsString:@"[名片消息]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"[名片消息]";
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"transfer"] && ![chatListEntityy.last_send_message containsString:@"[转账]"]){
                isNeedChangeFMDB = YES;
                if ([chatEntity.isSelf isEqualToString:@"0"]) {
                    chatListEntityy.last_send_message = @"[转账]";
                }else{
                    chatListEntityy.last_send_message = @"[转账]请您确认收款";
                }
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }
            if (isNeedChangeFMDB) {
                [self.myManage changeFMDBData:chatListEntityy KeyWordKey:@"conversationId" KeyWordValue:chatListEntityy.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
            }
        }else{
            //群聊
            BOOL isNeedChangeFMDB = NO;//是否需要进行FMDB更改操作 需要时才进行changeData
            __block NSArray *existArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                int dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString  stringWithFormat:@"qunzu%@",chatListEntityy.conversationId]];//取某群聊消息历史条数
                if (dataaCount > 0) {
                    existArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",chatListEntityy.conversationId] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                }
                
            }];
            MessageChatEntity *chatEntity = [existArr lastObject];
            //群聊收到web自己发的消息 下面这个走也没事 因为在2001接口中会进行核实
            if (![chatListEntityy.last_send_message isEqualToString:chatEntity.message_content] && [chatListEntityy.unread_message_count integerValue] == 0 && chatEntity.message_content.length > 0) {
                isNeedChangeFMDB = YES;
                //如果最后一条消息不准确 则进行更改
//                chatListEntityy.last_message_id = chatEntity.chatId;
                chatListEntityy.last_send_message = chatEntity.message_content;
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }
            if ([chatEntity.msgType isEqualToString:@"image"] && ![chatListEntityy.last_send_message isEqualToString:@"[图片]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"[图片]";
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"audio"] && ![chatListEntityy.last_send_message isEqualToString:@"[语音]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"[语音]";
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"redRecord"] && ![chatListEntityy.last_send_message isEqualToString:@"红包被领取"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"红包被领取";;
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if(chatEntity.pullType.length > 0){
                isNeedChangeFMDB = YES;
                //这里为系统的一些提示消息 例如某人进群
                if ([chatEntity.pullType isEqualToString:@"1"]) {
                    chatListEntityy.last_send_message = [NSString stringWithFormat:@"  %@通过扫描%@的分享的二维码加入群聊  ",chatEntity.pulledMemberString,chatEntity.invitor];
                }else if([chatEntity.pullType isEqualToString:@"9"]){
                    //系统通知
                    
                }else{
                    chatListEntityy.last_send_message = [NSString stringWithFormat:@"  %@邀请了%@进入群聊  ",chatEntity.invitor,chatEntity.pulledMemberString];
                }
            }else if ([chatEntity.msgType isEqualToString:@"red"] && ![chatListEntityy.last_send_message containsString:@"[多信红包]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = [NSString stringWithFormat:@"[多信红包]%@",chatEntity.message_content];
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"card"] && ![chatListEntityy.last_send_message containsString:@"[名片消息]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"[名片消息]";
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }else if ([chatEntity.msgType isEqualToString:@"system"] && ![chatListEntityy.last_send_message containsString:@"[系统消息]"]){
                isNeedChangeFMDB = YES;
                chatListEntityy.last_send_message = @"[系统消息]";
                chatListEntityy.update_time = [NFMyManage timestampSwitchTime:chatEntity.localReceiveTime?chatEntity.localReceiveTime:[chatEntity.localReceiveTimeString integerValue]];
                chatListEntityy.last_send_time = chatEntity.localReceiveTimeString;
            }
            if (isNeedChangeFMDB) {
                [self.myManage changeFMDBData:chatListEntityy KeyWordKey:@"conversationId" KeyWordValue:chatListEntityy.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"0" TableName:@"huihualiebiao"];
            }
        }
    }
    
}

//排序、顶置相关具体实现
-(NSMutableArray *)sortAbout{
    //取缓存刷新界面
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arrs = [NSArray new];
    NSArray *newArr;
    
    __block NSArray *arrss = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrss = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",@"IsUpSet",@"1"]];
    }];
   //如果没有顶置的列表
    if (arrss.count == 0) {
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            int count = [jqFmdb jq_tableItemCount:@"huihualiebiao"];
            if (count > 0) {
                arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
            }
        }];
        NSSortDescriptor *originTimeString = [NSSortDescriptor sortDescriptorWithKey:@"last_send_time" ascending:NO];
//        NSSortDescriptor *originTimeString = [NSSortDescriptor sortDescriptorWithKey:@"originTimeString" ascending:YES];
        newArr = [arrs sortedArrayUsingDescriptors:@[originTimeString]];
        NSMutableArray *returnArrs = [NSMutableArray arrayWithArray:newArr];
        return returnArrs;
    }
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    }];
    
    NSSortDescriptor *originTimeString = [NSSortDescriptor sortDescriptorWithKey:@"last_send_time" ascending:NO];
    newArr = [arrs sortedArrayUsingDescriptors:@[originTimeString]];
    
    NSMutableArray *lastArr = [NSMutableArray new];
    NSMutableArray *appendArr = [NSMutableArray new];
    for (MessageChatListEntity *entity in newArr) {
        if (entity.IsUpSet) {
            [lastArr addObject:entity];
        }else{
            [appendArr addObject:entity];
        }
    }
    [lastArr addObjectsFromArray:appendArr];
    return lastArr;
}

#pragma mark - 初始化socket
-(void)initScoket{
    [NFUserEntity shareInstance].isNeedRefreshChatList = NO;
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    [socketModel ping];
    if ([socketModel isConnected] && [ClearManager getNetStatus]) {
        
        [socketRequest getConversationList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneLoadingTableViewData];
        });
        //首页需要做的 请求好友请求
//        [socketRequest getIsExistUnReadApply];
    }else{
//        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//            statusBar.backgroundColor = [UIColor clearColor];
//        }
        
        NSString *version = [UIDevice currentDevice].systemVersion;
        
        UIView *statusBar;
        if (version.doubleValue >= 13.0) {
            //        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
            //        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
            //            UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
            //            if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
            //                statusBar = [_localStatusBar performSelector:@selector(statusBar)];
            //            }
            //        }
        }else{
            __block id Field;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
            });
            if ([Field isKindOfClass:[UIView class]]) {
                statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
            }
        }
        
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        //取缓存刷新界面
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *arrs = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
        }];
        
//        for (MessageChatListEntity *dd in arrs) {
//            NSLog(@"%@",dd.create_time);
//        }
        NSSortDescriptor *update_time = [NSSortDescriptor sortDescriptorWithKey:@"update_time" ascending:NO];
        NSArray *newArr = [arrs sortedArrayUsingDescriptors:@[update_time]];
        for (MessageChatListEntity *dd in newArr) {
//            NSLog(@"%@",dd.create_time);
        }
        //初始化角标
        [NFUserEntity shareInstance].badgeCount = 0;
        //将未读加上去
        if (newArr.count > 0) {
            for (MessageChatListEntity *entity in newArr) {
                //设置角标
                if (!entity.IsDisturb) {
                    [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:YES];
                }
            }
        }else{
            //设置角标
            [[NFbaseViewController new] setBadgeCountWithCount:0 AndIsAdd:YES];
        }
        //搜索结果的数组
        NSMutableArray *searchResultArr = [NSMutableArray new];
        for (MessageChatListEntity *entity in newArr) {
            ZJContact *contact = [ZJContact new];
            contact.friend_userid = entity.receive_user_id;
            contact.friend_username = entity.receive_user_name;
            [searchResultArr addObject:contact];
        }
        //初始化搜索结果的数组
        self.allData = [NSArray arrayWithArray:searchResultArr];
        self.dataArr = [NSMutableArray arrayWithArray:newArr];
        if (self.dataArr.count == 0) {
            MessageChatListTableview.isNeed = YES;
//            [MessageChatListTableview showNone];
            [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
        }else{
            dispatch_main_async_safe(^{
                [MessageChatListTableview removeNone];
            })
        }
        [MessageChatListTableview reloadData];
//        [socketModel initSocket];
    }
}

-(void)refreshLocalData{
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    UIView *statusBar;
    if (version.doubleValue >= 13.0) {
        //        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        //        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
        //            UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
        //            if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
        //                statusBar = [_localStatusBar performSelector:@selector(statusBar)];
        //            }
        //        }
    }else{
        __block id Field;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        });
        if ([Field isKindOfClass:[UIView class]]) {
            statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        }
    }
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor clearColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //取缓存刷新界面
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    }];
    
    //        for (MessageChatListEntity *dd in arrs) {
    //            NSLog(@"%@",dd.create_time);
    //        }
    NSSortDescriptor *update_time = [NSSortDescriptor sortDescriptorWithKey:@"update_time" ascending:NO];
    NSArray *newArr = [arrs sortedArrayUsingDescriptors:@[update_time]];
    for (MessageChatListEntity *dd in newArr) {
        //            NSLog(@"%@",dd.create_time);
    }
    //初始化角标
    [NFUserEntity shareInstance].badgeCount = 0;
    //将未读加上去
    if (newArr.count > 0) {
        for (MessageChatListEntity *entity in newArr) {
            //设置角标
            if (!entity.IsDisturb) {
                [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:YES];
           }
            
        }
    }else{
        //设置角标
        [[NFbaseViewController new] setBadgeCountWithCount:0 AndIsAdd:YES];
    }
    //搜索结果的数组
    NSMutableArray *searchResultArr = [NSMutableArray new];
    for (MessageChatListEntity *entity in newArr) {
        ZJContact *contact = [ZJContact new];
        contact.friend_userid = entity.receive_user_id;
        contact.friend_username = entity.receive_user_name;
        [searchResultArr addObject:contact];
    }
    //初始化搜索结果的数组
    self.allData = [NSArray arrayWithArray:searchResultArr];
    self.dataArr = [NSMutableArray arrayWithArray:newArr];
    if (self.dataArr.count == 0) {
        MessageChatListTableview.isNeed = YES;
        //            [MessageChatListTableview showNone];
        [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
    }else{
        dispatch_main_async_safe(^{
            [MessageChatListTableview removeNone];
        })
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [MessageChatListTableview reloadData];
    });
}


#pragma mark - //准备数据
-(void)initDataSource{
}

#pragma mark - tableViewDelegate & tableViewDateSource
//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.fromType?1:0;;
    }
    return self.dataArr.count;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]]) {
        NSNumber *cacheHeight = [rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
        return [cacheHeight floatValue];
    }
    NSNumber *cacheHeight = [[NSNumber alloc] initWithFloat:75];
    [rowHeightCache setValue:cacheHeight forKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
    return [cacheHeight floatValue];
}

//脚高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        //判断是否与服务器断开连接
        if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"] && [connectStatus isEqualToString:@"2"]) {
//            if ( [connectStatus isEqualToString:@"2"]) {
            return 40;
        }
        return self.fromType?8:0.1;
    }
    return self.fromType?20:0.1;
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        //判断是否与服务器断开连接
        if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"] && [connectStatus isEqualToString:@"2"]) {
//            if ( [connectStatus isEqualToString:@"2"]) {
            return [self showBreakAtView];
        }
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 8)];
        [headerView setBackgroundColor:[UIColor colorSectionHeader]];
        return headerView;
    }
//    if (!self.fromType) {
//        //是否为断线状态
//        //判断是否与服务器断开连接
//        if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
//            return [self showBreakAtView];
//        }
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
//        [headerView setBackgroundColor:[UIColor colorSectionHeader]];
//        return headerView;
//    }
    if (self.fromType) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
        [headerView setBackgroundColor:[UIColor colorSectionHeader]];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        titleLabel.text = @"最近聊天";
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:titleLabel];
        return headerView;
    }
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 8)];
//    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return nil;
}

-(UIView *)showBreakAtView{
//    if (!disconnectView) {
        disconnectView = [[[NSBundle mainBundle]loadNibNamed:@"DisconnectView" owner:nil options:nil] firstObject];
        disconnectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        return disconnectView;
//    }
    
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier;
    if (indexPath.section == 0) {
        cellIdentifier = @"CreateNewTableViewCell";
        CreateNewTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"CreateNewTableViewCell" owner:nil options:nil]firstObject];
        }
        return cell;
    }
    cellIdentifier = @"MessageChatListTableViewCell";
    MessageChatListTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageChatListTableViewCell" owner:nil options:nil]firstObject];
    }
    if (self.dataArr.count > 0) {
        MessageChatListEntity *entity = self.dataArr.count > indexPath.row?self.dataArr[indexPath.row]:nil;
        cell.chatListEntity = entity;
        //当来自转发 隐藏未读、最后一条消息
        if (self.fromType) {
            cell.unReadMessageCount.hidden = YES;
            cell.MessageLabel.hidden = YES;//
        }
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MessageChatListTableview deselectRowAtIndexPath:[MessageChatListTableview indexPathForSelectedRow] animated:NO];
    
    MessageChatListEntity *entityyy = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if(self.IsFromCard){
        if (!entityyy.IsSingleChat) {
           // [SVProgressHUD showInfoWithStatus:@"暂不支持发送到群组"];
            //return;
        }else if (indexPath.section == 0){
            [SVProgressHUD showInfoWithStatus:@"暂不支持选择新聊天"];
            return;
        }
    }else if([entityyy.msgType isEqualToString:@"system"] && [entityyy.conversationId isEqualToString:@"00"]){
        //小助手消息
        [self pushToSmallSystemMessage:entityyy IndexPath:indexPath];
        return;
    }else if([entityyy.msgType isEqualToString:@"system"]){
        //系统消息
        [self pushToSystemMessage:entityyy IndexPath:indexPath];
        return;
    }
    if (indexPath.section == 0) {
        //转发消息去联系人列表
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        toCtrol.fromType = YES;
        if (self.contentType) {
            toCtrol.contentType = self.contentType;
        }
        toCtrol.forwardContent = self.forwardContent;
        toCtrol.chatingName = self.chatingName;
        toCtrol.fromType = YES;
        toCtrol.forwardUUMessageFrame = self.forwardUUMessageFrame;
        [currentVC.navigationController pushViewController:toCtrol animated:YES];
    }
    if (indexPath.section == 1) {
        if (self.fromType) {
            self.tabBarController.tabBar.hidden = YES;
            AddBtn.userInteractionEnabled = NO;
            __block NSString *conyentString = [NSString new];
            if ([self.contentType isEqualToString:@"0"]) {
                conyentString = self.forwardContent;
            }else if ([self.contentType isEqualToString:@"1"]){
                conyentString = @"图片";
            }else if ([self.contentType isEqualToString:@"2"]){
                conyentString = @"语音";
            }else if ([self.contentType isEqualToString:@"4"]){
                conyentString = self.forwardContent;//名片
            }
            selectedChatListEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
            PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:[NSString stringWithFormat:@"发送给:%@",selectedChatListEntity.nickName?selectedChatListEntity.nickName:selectedChatListEntity.receive_user_name] message:conyentString isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
//                self.tabBarController.tabBar.hidden = NO;
                AddBtn.userInteractionEnabled = YES;
                if (sureBlock) {
                    if (![ClearManager getNetStatus]) {
                        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
                        return ;
                    }
//                    [SVProgressHUD show];
                    //发送消息
                    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                    NSInteger time = interval;
                    NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                    //当增加转发图片功能 这里需要修改
                    if (selectedChatListEntity.IsSingleChat) {
                        if ([self.contentType isEqualToString:@"4"]) {
                            //发送名片
                            if([selectedChatListEntity.receive_user_name isEqualToString:@"duoxinkefu"]){
                                [SVProgressHUD showInfoWithStatus:@"不允许推送名片给客服"];
                                return ;
                            }
                            [self sendCardToSingleChatWithContact:self.cardContact To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                        }else{
                            if (self.forwardUUMessageFrame.message.type == UUMessageTypePicture) {
                                //转发图片到单聊
                                [self sendPictureMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                                
                            }else if (self.forwardUUMessageFrame.message.type == UUMessageTypeText){
                                //转发文字到单聊
                                [self sendMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                            }
                        }
                        
                    }else{
                        if ([self.contentType isEqualToString:@"4"]) {
                            //发送名片
                            [self sendCardToGroupChatWithContact:self.cardContact To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                        }else{
                            //转发图片到群聊
                            if (self.forwardUUMessageFrame.message.type == UUMessageTypePicture) {
                                [self sendGroupPictureMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                            }else if (self.forwardUUMessageFrame.message.type == UUMessageTypeText){
                                //转发文字到群聊
                                [self sendGroupMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                            }
                        }
                        
                        
                    }
                }
                
            }];
            [popV setBackValpha:0.5];
            [popV setSecTitleBackColor:[UIColor whiteColor]];
            [popV setSecSureColor:UIColorFromRGB(0x28a829)];
            [popV setSecMessageColor:UIColorFromRGB(0x666666)];
            //setSecTitleColor
            [popV setSecTitleColor:[UIColor blackColor]];
            [popV setSecTitleAlient:NSTextAlignmentCenter];
            [popV setSecSureBtnText:@"发送"];
            [self.view addSubview:popV];
        }else{
            selectedChatListEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
            //进入聊天界面 减去未读
            if(!selectedChatListEntity.IsDisturb){
                unreadAllCount -= [selectedChatListEntity.unread_message_count integerValue];
            }
            if (selectedChatListEntity.IsSingleChat) {
                [self pushToSingleChat:selectedChatListEntity IndexPath:indexPath];
            }else{
                [self pushToGroupChat:selectedChatListEntity IndexPath:indexPath];
            }
        }
    }
}

#pragma mark - 转发文本消息 给单聊
- (void)sendMesageFrom:(NSString *)from To:(MessageChatListEntity *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    
    NSString *AppMessageId = [ClearManager getAPPMsgId];
    //发送之前先缓存
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":content,@"type":type,@"userName":from,@"userNickName":[NFUserEntity shareInstance].nickName};
    [self addSpecifiedItem:dic];//先进行缓存
    
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    //当增加转发图片功能 这里需要修改
    if ([type isEqualToString:@"0"]) {
        newsDic[@"msgType"] = @"normal";
        newsDic[@"content"] = content;
//        if ([content isKindOfClass:[NSString class]]) {
//            content = [EmojiShift emojiShiftstring:content];
//        }
    }
    newsDic[@"fromName"] = from;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"toName"] = to.receive_user_name;
    newsDic[@"toId"] = to.conversationId;
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
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

#pragma mark - 发送名片消息 给单聊
- (void)sendCardToSingleChatWithContact:(ZJContact *)contact To:(MessageChatListEntity *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[图片]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"strId":contact.friend_userid,@"strVoiceTime":contact.friend_username,@"pictureUrl":contact.friend_nickname,@"fileId":contact.iconUrl};
    [self addSpecifiedItem:dic];//dic 中主要是是消息的发出者的
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"card";
    newsDic[@"fromName"] = [NFUserEntity shareInstance].userName;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"toName"] = to.receive_user_name;
    newsDic[@"toId"] = to.conversationId;
    newsDic[@"content"] = contact.friend_userid;
    newsDic[@"contentType"] = @"4";
    newsDic[@"createTime"] = createtime;
    newsDic[@"action"] = @"sendMessage";
    newsDic[@"msgClient"] = @"app";
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
    NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
    if (socketModel.isConnected) {
        [socketModel sendMsg:JsonStr];
    }
    
}

#pragma mark - 发送名片消息 给群聊
- (void)sendCardToGroupChatWithContact:(ZJContact *)contact To:(MessageChatListEntity *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[个人名片]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName};
    dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[图片]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"strId":contact.friend_userid,@"strVoiceTime":contact.friend_username,@"pictureUrl":contact.friend_nickname,@"fileId":contact.iconUrl};
    [self addSpecifiedItemToGroup:dic];//dic 中主要是是消息的发出者的
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"card";
    newsDic[@"userName"] = [NFUserEntity shareInstance].userName;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    //newsDic[@"toName"] = to.receive_user_name;
    newsDic[@"groupId"] = to.conversationId;
    newsDic[@"msgContent"] = contact.friend_userid;
    newsDic[@"contentType"] = @"4";
    newsDic[@"msgTime"] = createtime;
    newsDic[@"action"] = @"sendGroupMsg";
    newsDic[@"groupMsgClient"] = @"app";
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
    NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
    if (socketModel.isConnected) {
        [socketModel sendMsg:JsonStr];
    }
}

#pragma mark - 转发文本消息 给群聊
- (void)sendGroupMesageFrom:(NSString *)from To:(MessageChatListEntity *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    //发送之前先缓存
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":content,@"type":type,@"userName":from,@"userNickName":[NFUserEntity shareInstance].nickName};
    [self addSpecifiedItemToGroup:dic];//先进行缓存
    
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    if ([type isEqualToString:@"0"]) {
        newsDic[@"msgType"] = @"normal";
        newsDic[@"contentType"] = @"0";
        newsDic[@"msgContent"] = content;
    }
    newsDic[@"userName"] = from;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"groupId"] = to.conversationId;
    newsDic[@"msgTime"] = createtime;
    newsDic[@"action"] = @"sendGroupMsg";
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
    newsDic[@"groupMsgClient"] = @"app";
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
}

#pragma mark - 转发图片消息 给单聊
- (void)sendPictureMesageFrom:(NSString *)from To:(MessageChatListEntity *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    //发送图片之前先缓存
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[图片]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"imgRatio":[NSString stringWithFormat:@"%.2f",self.forwardUUMessageFrame.message.pictureScale]};
    [self addSpecifiedItem:dic];//dic 中主要是是消息的发出者的
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"image";
    newsDic[@"fromName"] = [NFUserEntity shareInstance].userName;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"toName"] = to.receive_user_name;
    newsDic[@"toId"] = to.conversationId;
    newsDic[@"content"] = @"[图片]";
    newsDic[@"contentType"] = @"1";
    newsDic[@"createTime"] = createtime;
    newsDic[@"action"] = @"sendMessage";
    newsDic[@"msgClient"] = @"app";
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
    //图片信息
//    NSMutableDictionary *pictureInfo = [NSMutableDictionary new];
//    pictureInfo[@"fileExt"] = @"";
//    pictureInfo[@"fileMime"] = @"";
//    pictureInfo[@"fileName"] = @"";
//    NSString *picPath =[self.forwardUUMessageFrame.message.pictureUrl
//                        stringByReplacingOccurrencesOfString:[NFUserEntity shareInstance].HeadPicpathAppendingString withString:@""];
//    pictureInfo[@"filePath"] = picPath;
//    pictureInfo[@"fileSize"] = @"";
//    pictureInfo[@"fileUniqueName"] = @"";
//    pictureInfo[@"imgHeight"] = @"";
//    pictureInfo[@"imgRatio"] = [NSString stringWithFormat:@"%f",self.forwardUUMessageFrame.message.pictureScale];
//    pictureInfo[@"imgWidth"] = @"";
//    newsDic[@"fileInfo"] = pictureInfo;
//    newsDic[@"fileId"] = self.forwardUUMessageFrame.message.fileId;
    newsDic[@"fileInfo"] = @{@"fileId":self.forwardUUMessageFrame.message.fileId};
    NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
    if (socketModel.isConnected) {
        [socketModel sendMsg:JsonStr];
    }
}

#pragma mark - 转发图片消息 给群聊
- (void)sendGroupPictureMesageFrom:(NSString *)from To:(MessageChatListEntity *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    NSString *AppMessageId = [ClearManager getAPPMsgId];
    //发送图片之前先缓存
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[图片]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"nickName":[NFUserEntity shareInstance].nickName,@"imgRatio":[NSString stringWithFormat:@"%.2f",self.forwardUUMessageFrame.message.pictureScale],@"fileId":self.forwardUUMessageFrame.message.fileId};
    [self addSpecifiedItemToGroup:dic];
    
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"image";
    newsDic[@"userName"] = [NFUserEntity shareInstance].userName;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
//    newsDic[@"toName"] = to.receive_user_name;
    newsDic[@"groupId"] = to.conversationId;
    newsDic[@"msgContent"] = @"[图片]";
    newsDic[@"msgTime"] = createtime;
    newsDic[@"action"] = @"sendGroupMsg";
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
    newsDic[@"groupMsgClient"] = @"app";
    //图片信息
//    NSMutableDictionary *pictureInfo = [NSMutableDictionary new];
//    pictureInfo[@"fileExt"] = @"";
//    pictureInfo[@"fileMime"] = @"";
//    pictureInfo[@"fileName"] = @"";
//    NSString *picPath =[self.forwardUUMessageFrame.message.pictureUrl
//                        stringByReplacingOccurrencesOfString:[NFUserEntity shareInstance].HeadPicpathAppendingString withString:@""];
//    pictureInfo[@"filePath"] = picPath;
//    pictureInfo[@"fileSize"] = @"";
//    pictureInfo[@"fileUniqueName"] = @"";
//    pictureInfo[@"imgHeight"] = @"";
//    pictureInfo[@"imgRatio"] = [NSString stringWithFormat:@"%f",self.forwardUUMessageFrame.message.pictureScale];
//    pictureInfo[@"imgWidth"] = @"";
//    newsDic[@"fileInfo"] = pictureInfo;
//    newsDic[@"fileId"] = self.forwardUUMessageFrame.message.fileId;
    newsDic[@"fileInfo"] = @{@"fileId":self.forwardUUMessageFrame.message.fileId};
    NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
    if (socketModel.isConnected) {
        [socketModel sendMsg:JsonStr];
    }
}



static NSString *previousTime = nil;

#pragma mark - 发送消息后展示、缓存 【只能是单聊】
- (void)addSpecifiedItem:(NSDictionary *)dic
{
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    ZJContact *contant = [ZJContact new];
    contant.friend_userid = selectedChatListEntity.conversationId;
    contant.friend_username = selectedChatListEntity.receive_user_name;
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
    if (message.type == UUMessageTypePicture && self.fromType) {
        message.pictureUrl = self.forwardUUMessageFrame.message.pictureUrl;
        message.pictureScale = self.forwardUUMessageFrame.message.pictureScale;
        message.fileId = self.forwardUUMessageFrame.message.fileId;
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
    //entity.redpacketString = @"";
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
        if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
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

#pragma mark - 发送消息后展示、缓存 【只能是群聊】
- (void)addSpecifiedItemToGroup:(NSDictionary *)dic
{
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    ZJContact *contant = [ZJContact new];
    contant.friend_username = selectedChatListEntity.receive_user_name;
    contant.groupId = selectedChatListEntity.conversationId;
    [self.fmdbServicee cacheChatListWithZJContact:contant AndDic:dic];//这后面的dic 需要传的和单聊一样才能改成功【因为走的代码是更改单聊绘画的 只是价格groupId存在与否的判断 】
    
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
    if (message.type == UUMessageTypePicture && self.fromType) {
        message.pictureUrl = self.forwardUUMessageFrame.message.pictureUrl;
        message.pictureScale = self.forwardUUMessageFrame.message.pictureScale;
        message.fileId = self.forwardUUMessageFrame.message.fileId;
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
}

#pragma mark - 跳转到单聊
-(void)pushToSingleChat:(MessageChatListEntity *)entity IndexPath:(NSIndexPath *)indexpath{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
    if (entity.nickName.length > 0) {
        toCtrol.titleName = entity.nickName;
    }else{
        toCtrol.titleName = entity.receive_user_name;
    }
    //会话id 用于顶置等用
    toCtrol.conversationId = entity.conversationId;
    toCtrol.chatType = @"0";
    ZJContact *contact = [ZJContact new];
//    contact.chatId = @"";
    contact.friend_username = entity.receive_user_name;
    contact.friend_userid = entity.conversationId;
    contact.friend_nickname = entity.nickName;
    contact.iconUrl = entity.headPicpath;
    
    toCtrol.singleContactEntity = contact;
//    toCtrol.singleContactEntity.friend_userid = entity.conversationId;
    if ([entity.unread_message_count integerValue] > 0) {
        //如果未读大于0 则告诉下个界面 强制请求已读
        toCtrol.IsHaveNotRead = YES;
        toCtrol.unreadCount = [entity.unread_message_count integerValue];
    }
    //先设置去除角标
    [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:NO];
    //再去除未读标记 判断需不需要请求消息历史 不需要则只展示本地消息
    [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory = [entity.unread_message_count integerValue] ==0?NO:YES;
    entity.unread_message_count = @"0";
    MessageChatListTableViewCell *cell = (MessageChatListTableViewCell *)[MessageChatListTableview cellForRowAtIndexPath:indexpath];
    cell.unReadMessageCount.hidden = YES;
    
    //修改会话列表
    [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:entity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
    
    //    NSArray *yincangArrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    //设置对方头像
    [NFUserEntity shareInstance].isNeedRefreshChatData = NO;
    toCtrol.unreadAllCount = unreadAllCount;
    [self.navigationController pushViewController:toCtrol animated:YES];
    
}


#pragma mark - 跳转到群聊
-(void)pushToGroupChat:(MessageChatListEntity *)entity IndexPath:(NSIndexPath *)indexpath{
//    [SVProgressHUD show];
    //  群聊 线根据id 在 群组表中取到数据 然后进行跳转
    //以会话列表id在缓存的群组详情表里面找某条数据，这里的groupId是对的
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *groupArr = [jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@"where groupId = '%@'",entity.conversationId]];
//    NSLog(@"\n\ngroupArr.count:%d\n\n",groupArr.count);
    //正常只有一条数据
    GroupCreateSuccessEntity *groupDetailEntity;
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
    
    //会话id 用于顶置等用
    toCtrol.conversationId = entity.conversationId;
    NSArray *nextEntityArr = [self.fmdbServicee getGroupDetailEntityAndMemberListWithGroupId:entity.conversationId];
    toCtrol.groupCreateSEntity = nextEntityArr[0];
    if (entity.headPicpath.length > 0) {
        toCtrol.groupCreateSEntity.groupHeadPic = entity.headPicpath;
        toCtrol.groupCreateSEntity.groupName = entity.nickName?entity.nickName:entity.receive_user_name;
    }
    if (!toCtrol.groupCreateSEntity.groupId) {
        //如果grouId为nil 因为用户清空了缓存 群组详情和成员都没有了 这里从会话列表取id 还有其他一些参数
        toCtrol.groupCreateSEntity.groupId = entity.conversationId;
        toCtrol.groupCreateSEntity.groupHeadPic = entity.headPicpath;
    }
    if ([entity.unread_message_count integerValue] > 0) {
        //如果未读大于0 则告诉下个界面 强制请求已读
        toCtrol.IsHaveNotRead = YES;
        toCtrol.unreadCount = [entity.unread_message_count integerValue];
    }
    toCtrol.memberArr  = nextEntityArr[1];
    if (indexpath) {
        //先设置去除角标
        if (!entity.IsDisturb) {
            [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:NO];
       }
        
        MessageChatListTableViewCell *cell = (MessageChatListTableViewCell *)[MessageChatListTableview cellForRowAtIndexPath:indexpath];
        [NFUserEntity shareInstance].isNeedRefreshGroupChatHistory = [entity.unread_message_count integerValue] ==0?NO:YES;
        cell.unReadMessageCount.hidden = YES;
        //再去除未读标记
        entity.unread_message_count = @"0";
        [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:entity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"0" TableName:@"huihualiebiao"];
        
    }
    //    NSArray *yincangArrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
    [NFUserEntity shareInstance].isNeedRefreshChatList = NO;
    toCtrol.unreadAllCount = unreadAllCount;
    [self.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 跳转到系统消息
-(void)pushToSystemMessage:(MessageChatListEntity *)entity IndexPath:(NSIndexPath *)indexpath{
    //先设置去除角标
    [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:NO];
    //再去除未读标记 判断需不需要请求消息历史 不需要则只展示本地消息
    [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory = [entity.unread_message_count integerValue] ==0?NO:YES;
    entity.unread_message_count = @"0";
    MessageChatListTableViewCell *cell = (MessageChatListTableViewCell *)[MessageChatListTableview cellForRowAtIndexPath:indexpath];
    cell.unReadMessageCount.hidden = YES;
    
    //修改会话列表
    [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:entity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
    
    //    NSArray *yincangArrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    //设置对方头像
    [NFUserEntity shareInstance].isNeedRefreshChatData = NO;
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
    BillListTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BillListTableViewController"];
    toCtrol.IsSystem = YES;
    entity.unread_message_count = @"0";
    [self.navigationController pushViewController:toCtrol animated:YES];
    
}

#pragma mark - 跳转到小助手消息
-(void)pushToSmallSystemMessage:(MessageChatListEntity *)entity IndexPath:(NSIndexPath *)indexpath{
    //先设置去除角标
    [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:NO];
    //再去除未读标记 判断需不需要请求消息历史 不需要则只展示本地消息
    [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory = [entity.unread_message_count integerValue] ==0?NO:YES;
    entity.unread_message_count = @"0";
    MessageChatListTableViewCell *cell = (MessageChatListTableViewCell *)[MessageChatListTableview cellForRowAtIndexPath:indexpath];
    cell.unReadMessageCount.hidden = YES;
    //修改会话列表
    [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:entity.conversationId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
    
    //    NSArray *yincangArrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
    //设置对方头像
    [NFUserEntity shareInstance].isNeedRefreshChatData = NO;
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    HelperTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"HelperTableViewController"];
    entity.unread_message_count = @"0";
    [self.navigationController pushViewController:toCtrol animated:YES];
    
}

#pragma mark - 删除相关
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除会话";
}

//左滑多个选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.fromType) {
        return @[];
    }
    MessageChatListEntity *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    UITableViewRowAction * deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"删除后未读消息将不再提示!" sureBtn:@"确认" cancleBtn:@"取消"];
        alertView.resultIndex = ^(NSInteger index)
        {
            //取消或则删除都结束编辑状态
            [MessageChatListTableview setEditing:NO animated:YES];
            if (index == 1) {
                //取消
            }else if (index == 2){
                //确认
                selectedEditIndexPath = indexPath;
                //        NSLog(@"删除");
                CGFloat animationTime = 0.5;
                //是右滑tableview需要的动画
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [UIView animateWithDuration:animationTime animations:^{
                        newChatButton.alpha = 1;
                    }];
                });
                MessageChatListEntity *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
                if (entity.last_message_id.length > 0 && [entity.unread_message_count floatValue]>=1) {
                    if (entity.IsSingleChat) {
                        //请求单聊已读
                        [socketRequest readedRequest:entity.last_message_id receiveName:entity.receive_user_name];
                    }else{
                        //请求群聊已读
                        [socketRequest readedRequest:entity.last_message_id GroupId:entity.conversationId];
                    }
                    //已读成功后进行删除本地缓存
                }else{
                    //直接删除没有未读的会话
                    MessageChatListEntity *entity = self.dataArr.count>selectedEditIndexPath.row?self.dataArr[selectedEditIndexPath.row]:nil;
                    NSString *IsSingleChat = @"0";
                    if (entity.IsSingleChat) {
                        IsSingleChat = @"1";
                    }
                    //删除群消息记录
                    if (!entity.IsSingleChat && [isNeedDeleteGroupHistory isEqualToString:@"1"]) {
                        BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:[NSString stringWithFormat:@"qunzu%@",entity.conversationId] IsDelete:NO];
                        if (rett) {
                        }
                    }else if(entity.IsSingleChat && [isNeedDeleteGroupHistory isEqualToString:@"1"]){
                        BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:entity.conversationId IsDelete:NO];
                        if (rett) {
                        }
                    }
                    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:entity.conversationId SecondKeyName:@"IsSingleChat" SecondValueName:IsSingleChat];
                    if (ret) {
                        NSLog(@"删除成功");
                    }else{
                        NSLog(@"删除失败");
                    }
                    [self.dataArr removeObjectAtIndex:selectedEditIndexPath.row];
                    [MessageChatListTableview   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:selectedEditIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
                    //减去相应的角标
                    if (!entity.IsDisturb) {
                        [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:NO];
                   }
                    selectedEditIndexPath = nil;
                }
            }
        };
        [alertView showMKPAlertView];
        
    }];
    deleteRowAction.backgroundColor = [UIColor redColor];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    UITableViewRowAction * topRowAction;
    if (!entity.IsUpSet) {
        topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"顶置" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            CGFloat animationTime = 0.5;
            //是右滑tableview需要的动画
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [UIView animateWithDuration:animationTime animations:^{
//                    NSLog(@"alpha:%f",newChatButton.alpha);
                    newChatButton.alpha = 1;
                    
                }];
            });
            __block NSArray *needDingzhiArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                needDingzhiArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",entity.conversationId,@"IsSingleChat",entity.IsSingleChat?@"1":@"0"]];
            }];
            if (needDingzhiArr.count > 0) {
                MessageChatListEntity *chatListEntity = [needDingzhiArr firstObject];
                chatListEntity.IsUpSet = YES;
                __block BOOL isSuccess;
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    isSuccess = [strongSelf ->jqFmdb jq_updateTable:@"huihualiebiao" dicOrModel:chatListEntity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",entity.conversationId,@"IsSingleChat",entity.IsSingleChat?@"1":@"0"]];
                }];
                if (isSuccess) {
                    //排序、顶置相关处理
                    NSArray *lastArr = [self sortAbout];
                    self.dataArr = [NSMutableArray arrayWithArray:lastArr];
                    //当数据为空 显示图片
                    if (self.dataArr.count == 0) {
                        MessageChatListTableview.isNeed = YES;
                        //                    [MessageChatListTableview showNone];
                        [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
                    }else{
                        dispatch_main_async_safe(^{
                            [MessageChatListTableview removeNone];
                        })
                    }
                    [MessageChatListTableview reloadData];
                }
            }
        }];
    }else{
        topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消顶置" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            __block NSArray *needDingzhiArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                needDingzhiArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",entity.conversationId,@"IsSingleChat",entity.IsSingleChat?@"1":@"0"]];
                
            }];
//            NSArray *arr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:@""];
            if (needDingzhiArr.count > 0) {
                MessageChatListEntity *chatListEntity = [needDingzhiArr firstObject];
                chatListEntity.IsUpSet = NO;
                __block BOOL isSuccess;
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    isSuccess = [strongSelf ->jqFmdb jq_updateTable:@"huihualiebiao" dicOrModel:chatListEntity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",entity.conversationId,@"IsSingleChat",entity.IsSingleChat?@"1":@"0"]];
                }];
                
                if (isSuccess) {
                    //排序、顶置相关处理
                    NSArray *lastArr = [self sortAbout];
                    self.dataArr = [NSMutableArray arrayWithArray:lastArr];
                    //当数据为空 显示图片
                    if (self.dataArr.count == 0) {
                        MessageChatListTableview.isNeed = YES;
                        //                    [MessageChatListTableview showNone];
                        [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
                    }else{
                        dispatch_main_async_safe(^{
                            [MessageChatListTableview removeNone];
                        })
                    }
                    [MessageChatListTableview reloadData];
//                    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
//                    [MessageChatListTableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }];
    }
    topRowAction.backgroundColor = [UIColor lightGrayColor];
    return @[deleteRowAction,topRowAction];
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"editingStyle:%d",MessageChatListTableview.editing);
    if (MessageChatListTableview.editing) {
        
    }
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"");
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED{
    
    NSLog(@"BeginEditing:%d",MessageChatListTableview.editing);
    NSLog(@"");
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath __TVOS_PROHIBITED{
    
    NSLog(@"BeginEditing:%d",MessageChatListTableview.editing);
    NSLog(@"");
}

#pragma mark - 监听tableview的状态 判断新建按钮的显示与隐藏
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //如果tableview为编辑模式 则隐藏新建聊天
    if (MessageChatListTableview.editing) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [UIView animateWithDuration:0.3 animations:^{
                newChatButton.alpha = 0;
            }];
        });
    }else{
        CGFloat animationTime = 0.5;
        //是右滑tableview需要的动画
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [UIView animateWithDuration:animationTime animations:^{
//                NSLog(@"alpha:%f",newChatButton.alpha);
                newChatButton.alpha = 1;
                
            }];
        });
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    if (editingStyle ==UITableViewCellEditingStyleDelete)
//    {
//        MessageChatListEntity *entity = self.dataArr[indexPath.row];
//        BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:entity.conversationId];
//        if (ret) {
//            NSLog(@"删除成功");
//        }else{
//            NSLog(@"删除失败");
//        }
//        [self.dataArr removeObjectAtIndex:indexPath.row];
//        NSLog(@"%ld",[NFUserEntity shareInstance].badgeCount);
//        NSLog(@"%@",entity.unread_message_count);
//        [MessageChatListTableview   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
//        //减去相应的角标
//        [[NFbaseViewController new] setBadgeCountWithCount:[entity.unread_message_count integerValue] AndIsAdd:NO];
//        
//        //当数据为空 显示图片
//        if (self.dataArr.count == 0) {
//            MessageChatListTableview.isNeed = YES;
//            //            [MessageChatListTableview showNone];
//            [MessageChatListTableview showNoneWithImage:@"空白页-14-14_03" WithTitle:@"会话列表为空"];
//            
//        }else{
//            [MessageChatListTableview removeNone];
//        }
//        
//    }
//}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.searchBar) {
        //点击搜索框 初始化可搜索的数组
        
        __block NSArray *lastArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            lastArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
        }];
        NSMutableArray *searchResultArr = [NSMutableArray new];
        for (MessageChatListEntity *entity in lastArr) {
            ZJContact *contact = [ZJContact new];
            contact.friend_userid = entity.conversationId;
            contact.groupId = entity.conversationId;
            contact.friend_username = entity.receive_user_name;
            contact.friend_nickname = entity.nickName;
            contact.IsCanSelect = entity.IsSingleChat;
            contact.iconUrl = entity.headPicpath;
            [searchResultArr addObject:contact];
        }
        //初始化搜索结果的数组
        self.allData = [NSArray arrayWithArray:searchResultArr];
        
        self.tabBarController.tabBar.hidden = YES;
        self.navigationController.navigationBar.translucent = YES;
         if (@available(iOS 13.0, *)) {
//            self.searchController.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:self.searchController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - searchbar 相关 后面考虑群聊
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == _searchController.searchBar) {
        ZJSearchResultController *resultController = (ZJSearchResultController *)_searchController.searchResultsController;
        // 更新数据 并且刷新数据
        resultController.data = [ZJContact searchText:searchText inDataArray:self.allData];
        [resultController SelectContantJumpBlock:^(ZJContact *contant) {
            //跳转前移除搜索界面
            self.searchController.searchBar.text = @"";
            [self dismissViewControllerAnimated:NO completion:nil];
            //
            MessageChatListEntity *entity = [MessageChatListEntity new];
            if (!contant.IsCanSelect){//群组
                entity.conversationId = contant.groupId;
                entity.receive_user_name = contant.groupName.length > 0?contant.groupName:contant.friend_username;
            }else{//单聊
                entity.conversationId = contant.friend_userid;
                entity.receive_user_name = contant.friend_username;
                entity.nickName = contant.friend_nickname;
            }
            if (self.fromType){
                __block NSString *conyentString = [NSString new];
                if ([self.contentType isEqualToString:@"0"]) {
                    conyentString = self.forwardContent;
                }else if ([self.contentType isEqualToString:@"1"]){
                    conyentString = @"图片";
                }else if ([self.contentType isEqualToString:@"2"]){
                    conyentString = @"语音";
                }
                selectedChatListEntity = entity;
                selectedChatListEntity.IsSingleChat = contant.IsCanSelect;
                PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:[NSString stringWithFormat:@"发送给:%@",selectedChatListEntity.nickName?selectedChatListEntity.nickName:selectedChatListEntity.receive_user_name] message:conyentString isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
                    //                self.tabBarController.tabBar.hidden = NO;
                    AddBtn.userInteractionEnabled = YES;
                    if (sureBlock) {
                        if (![ClearManager getNetStatus]) {
                            [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
                            return ;
                        }
                        //发送消息
                        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                        NSInteger time = interval;
                        NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                        if (selectedChatListEntity.IsSingleChat) {
                            if (self.forwardUUMessageFrame.message.type == UUMessageTypePicture) {
                                
                                [self sendPictureMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                                
                            }else if (self.forwardUUMessageFrame.message.type == UUMessageTypeText){
                                [self sendMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                            }
                        }else{
                            if (self.forwardUUMessageFrame.message.type == UUMessageTypePicture) {
                                [self sendGroupPictureMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                            }else if (self.forwardUUMessageFrame.message.type == UUMessageTypeText){
                                [self sendGroupMesageFrom:[NFUserEntity shareInstance].userName To:selectedChatListEntity Content:conyentString Createtime:createTime AndType:self.contentType];
                            }
                        }
                    }
                }];
                [popV setBackValpha:0.5];
                [popV setSecTitleBackColor:[UIColor whiteColor]];
                [popV setSecSureColor:UIColorFromRGB(0x28a829)];
                [popV setSecMessageColor:UIColorFromRGB(0x666666)];
                //setSecTitleColor
                [popV setSecTitleColor:[UIColor blackColor]];
                [popV setSecTitleAlient:NSTextAlignmentCenter];
                [popV setSecSureBtnText:@"发送"];
                [self.view addSubview:popV];
                return;
            }
            
            for (MessageChatListEntity *chatListEntity in self.dataArr) {
                if ([chatListEntity.conversationId isEqualToString:entity.conversationId]  && [chatListEntity.receive_user_name isEqualToString:entity.receive_user_name]) {
                    if (chatListEntity.IsSingleChat) {
                        [self pushToSingleChat:chatListEntity IndexPath:nil];
                    }else{
                        [self pushToGroupChat:chatListEntity IndexPath:nil];
                    }
                }
            }
        }];
    }
}

// 这个方法在searchController 出现, 消失, 以及searchBar的text改变的时候都会被调用
// 我们只是需要在searchBar的text改变的时候才查询数据, 所以没有使用这个代理方法, 而是使用了searchBar的代理方法来处理
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //    NSLog(@"%@", searchController.searchBar.text);
    ZJSearchResultController *resultController = (ZJSearchResultController *)searchController.searchResultsController;
    resultController.data = [ZJContact searchText:searchController.searchBar.text inDataArray:_allData];
    [resultController.tableView reloadData];
    
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // 销毁
    self.searchController = nil;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    //当为转发时进行搜索后退出搜索时，tabbar不进行显示
    if (!self.fromType) {
        self.tabBarController.tabBar.hidden = NO;
    }
    
}


- (UISearchController *)searchController {
    if (!_searchController) {
        // ios8+才可用 否则使用 UISearchDisplayController
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:[ZJSearchResultController new]];
        searchController.delegate = self;
        //        searchController.searchResultsUpdater = self;
        searchController.searchBar.delegate = self;
        searchController.searchBar.placeholder = @"搜索姓名、首字母";
        //隐藏取消按钮
        searchController.searchBar.showsCancelButton = YES;
#pragma mark - 设置searchbarController
        UITextField *searchControllerSearchField;
        if (@available(iOS 13.0, *)) {
            searchControllerSearchField = searchController.searchBar.searchTextField;
        }else{
            searchControllerSearchField= [searchController.searchBar valueForKey:@"_searchField"];
            [searchControllerSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
            [searchControllerSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        }
            
        searchControllerSearchField.textColor = MainTextColor;
        searchControllerSearchField.backgroundColor = [UIColor colorTextfieldBackground];
        //放大镜
        [searchController.searchBar setImage:[UIImage imageNamed:@"searchbar放大镜"]
                            forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        
        for (id searchbuttons in [[searchController.searchBar subviews][0]subviews]){
            if ([searchbuttons isKindOfClass:[UIButton class]]) {
                UIButton *cancelButton = (UIButton*)searchbuttons;
                // 修改文字颜色
                [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
                [cancelButton setTitle:@"返回" forState:UIControlStateNormal];
                [cancelButton setTitleColor:[UIColor colorThemeColor] forState:UIControlStateNormal];
                [cancelButton setTitleColor:[UIColor colorThemeColor] forState:UIControlStateHighlighted];
            }
        }
        //貌似没用
        searchController.searchBar.barTintColor = [UIColor colorNavigationBackground];
        //textfield背景图
        //设置图片宽度减少55
        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 78, 30)];
        //        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 30)];
        backImage.image = [UIImage imageNamed:@"搜索栏白色"];
        //        [searchControllerSearchField addSubview:backImage];
        UIView *searchControllerView = searchControllerSearchField.superview;
        searchControllerView.backgroundColor = [UIColor colorSectionHeader];
        for (UIView *view in searchController.searchBar.subviews) {
            // for later iOS7.0(include)
            if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
                if (@available(iOS 13.0, *)) {

                    [view.subviews objectAtIndex:0].hidden = YES;
                }else{
                    [[view.subviews objectAtIndex:0] removeFromSuperview];
                }
                break;
            }
        }
        _searchController = searchController;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    label.backgroundColor = [UIColor colorNavigationBackground];
    [_searchController.view addSubview:label];
    return _searchController;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, kSearchBarHeight)];
        searchBar.delegate = self;
        searchBar.placeholder = @"姓名/首字母";
        _searchBar = searchBar;
    }
    return _searchBar;
}

#pragma mark - 下拉刷新4
#pragma mark - scrollView Delegate
// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView_ egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshHeaderView_ egoRefreshScrollViewDidScroll:scrollView];
    
    
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
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:MessageChatListTableview];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat height = [self cellsTotalHeight:rowHeightCache]+ 50;
    if (MessageChatListTableview.contentOffset.y > 0 && height <= SCREEN_HEIGHT - kTopHeight - kTabBarHeight) {
        [UIView animateWithDuration:0.2 animations:^{
            MessageChatListTableview.contentOffset = CGPointMake(0, 0);
        }];
    }
}
//计算总高度
-(CGFloat)cellsTotalHeight:(NSDictionary *)dict{
    CGFloat totalHeight = 0;
    NSArray *heightValues = [dict allValues];
    for (NSNumber *cacheHeight in heightValues) {
        totalHeight +=[cacheHeight floatValue];
    }
    return totalHeight;
}

#pragma mark - 下拉刷新委托回调
//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
    
    //当没有推送id、有网 则进行设置推送id
//    if ([JPUSHService registrationID] && [NFUserEntity shareInstance].JPushId.length == 0 && [ClearManager getNetStatus]) {
    //每次下拉刷新 只要有网 有reg_id 则进行注册 【是否有注册id 在请求中判断了】 并且没有手动关过推送
    if ([JPUSHService registrationID] &&[ClearManager getNetStatus] && ![NFUserEntity shareInstance].IsCloseJPush) {
        [socketRequest setJPUSHServiceId];
    }
#pragma mark - 下拉刷新6
    MessageChatListTableview.showsVerticalScrollIndicator = NO;
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneLoadingTableViewData];
        });
    }else{
        if ([socketModel isConnected]) {
            //刷新请求联系人列表
            [self initScoket];
            
            //延迟1秒后 取消刷新
            [self createDispatchWithDelay:1 block:^{
                [self doneLoadingTableViewData];
            }];
            
            
        }else{
            if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self doneLoadingTableViewData];
                });
                return;
            }
            //重连
            [SVProgressHUD showWithStatus:@"正在重连"];
            [socketModel initSocket];
             [socketModel returnConnectSuccedd:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                    if (![currentVC isKindOfClass:[MessageChatListViewController class]]) {
                        return ;
                    }
                    [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                    //刷新请求联系人列表
                    [self initScoket];
                });
            }];
        }
    }
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

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    cell.backgroundColor = [UIColor clearColor];
}

-(void)setUserEnabledYES{
    quitBtn.userInteractionEnabled = YES;
    clearCacheBtn.userInteractionEnabled = YES;
    self.tabBarController.tabBar.hidden = NO;
}

-(void)setUserEnabledNO{
    quitBtn.userInteractionEnabled = NO;
    clearCacheBtn.userInteractionEnabled = NO;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - 过滤数据 将阅后隐藏的数据过滤掉
-(void)initLegalData{
    NSMutableArray *arr =[NSMutableArray new];
    for (MessageChatListEntity *entity in self.dataArr) {
        //如果不是1 则add 是1则不管
        if (![entity.yuehouYinCang isEqualToString:@"1"]) {
            [arr addObject:entity];
        }
    }
    self.dataArr = [NSMutableArray arrayWithArray:arr];
}

#pragma mark - //根据 groupid 取出群组详情、成员缓存
-(NSArray *)getGroupDetailEntityAndMemberListWithGroupId:(NSString *)groupId{
    //    groupId = [self.myManage NumToString:groupId];
    //下面一般为一条数据
//    NSArray *groupsArrs = [jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@""];
//
//    NSArray *memdberArrs = [jqFmdb jq_lookupTable:@"groupMemberliebiao" dicOrModel:[FriendListEntity class] whereFormat:@""];
    __block NSArray *groupArrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        groupArrs = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@"where groupId = '%@'",groupId];
    }];
    __block NSArray *memberArrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        memberArrs = [strongSelf ->jqFmdb jq_lookupTable:@"groupMemberliebiao" dicOrModel:[FriendListEntity class] whereFormat:@"where group_id = '%@'",groupId];
        
    }];
    for (FriendListEntity *frientEntity in memberArrs) {
        ZJContact *contact = [ZJContact new];
        contact.friend_username = frientEntity.friend_username;
        contact.friend_userid = frientEntity.friend_userid;
//        contact.createTime = frientEntity.createtime;
        contact.iconUrl = frientEntity.headImage;
        [self.contactArr addObject:contact];
    }
    [self.groupDetailAndMemberArr addObject:[groupArrs firstObject]];
    [self.groupDetailAndMemberArr addObject:self.contactArr];
    return self.groupDetailAndMemberArr;
    
}

//收到网络变化通知
- (void)connectBreak:(NSNotification *)notifi{
    NSDictionary *nitification = notifi.object;
    if ([[nitification objectForKey:@"connectStatus"] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"] && ![connectStatus isEqualToString:@"1"]) {
                connectStatus = @"2";
                self.navigationItem.title = @"多信(未连接)";
                [MessageChatListTableview reloadData];
            }
        });
    }else if ([[nitification objectForKey:@"connectStatus"] isEqualToString:@"0"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"0"]) {
                connectStatus = @"1";
                self.navigationItem.title = @"多信";
                [MessageChatListTableview reloadData];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
                    //连接成功如果为当前界面那么进行请求会话。列表
                    [disconnectView removeFromSuperview];
                    disconnectView = nil;
                    [socketRequest getConversationList];
                    [SVProgressHUD dismiss];//静默刷新
                }else{ //记录到会话列表刷新会话列表
                    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
                }
            }
        });
    }else if ([[nitification objectForKey:@"connectStatus"] isEqualToString:@"2"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"] && ![connectStatus isEqualToString:@"2"]) {
                connectStatus = @"3";
                self.navigationItem.title = @"多信(连接中)";
                [disconnectView removeFromSuperview];
                disconnectView = nil;
            }
        });
    }
}

//懒加载
-(NSMutableArray *)contactArr{
    if (!_contactArr) {
        _contactArr = [[NSMutableArray alloc] init];
    }
    return _contactArr;
}

-(NSMutableArray *)groupDetailAndMemberArr{
    if (!_groupDetailAndMemberArr) {
        _groupDetailAndMemberArr = [[NSMutableArray alloc] init];
    }
    return _groupDetailAndMemberArr;
}

//懒加载 fmdbServicee
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

#pragma mark - 获取设备当前网络IP地址
- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
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
