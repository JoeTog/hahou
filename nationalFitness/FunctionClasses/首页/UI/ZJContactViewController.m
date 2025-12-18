//
//  ViewController.m
//  ZJIndexContacts
//
//  Created by ZeroJ on 16/10/10.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJContactViewController.h"
#import "ZJContact.h"
#import "ZJSearchResultController.h"
#import "ZJProgressHUD.h"
#import "ContantTableViewCell.h"
#import "MessageChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "QRCodeScanViewController.h"
#import "UITabBarItem+Badge.h"
#include <objc/runtime.h>
#import "JQFMDB.h"
#import "CCZTableButton.h"


#define rootDictionary @"result"

@interface ZJContactViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate,EGORefreshTableHeaderDelegate,ChatHandlerDelegate> {
    // 所有的indexsTitles
    NSArray *_allIndexTitles;
    // 存放索引对应的下标
    NSMutableArray *_sectionIndexs;
    // dataSource
    NSMutableArray *_data;
    BOOL reloading_;
    BOOL needReloading_;
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    
    EGORefreshTableHeaderView * refreshHeaderView_;
    
    SocketModel * socketModel;
    BOOL needCache;
    BOOL needGetCache;
    //记录下获得地列表 防止清除缓存后 群组列表没有数据
    NSDictionary *resultDicCore_;
    
//    NSInteger addFriendCount;
    
    AppDelegate *appDelegate;
    
    JQFMDB *jqFmdb;
    //记录选中的indexpath
    NSIndexPath *selectedIndexPath;
    //编辑名字、查看头像后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    //add菜单
    CCZTableButton *MenuTableV_;
    //记录删除好友的indexpath
    NSIndexPath *deleteIndexPath;
    NSMutableDictionary *rowHeightCache;
    SocketRequest *socketRequest;
    
    BOOL IsFirstTime;
    BOOL IsFirstTimeShow;//第一次进来 加载需要转圈
    BOOL IsFinished;//是否请求完成
    
    //是否允许请求，显示联系人界面的时候，一分钟内只能请求一次
    BOOL IsAllowRequest;
    
    
    //是否刷新 联系人列表，当界面willappear的时候 不能总是刷新
    BOOL IsAllowRefreshContact;
    
    
}
@property(nonatomic,strong)NSMutableArray *dataArr;

@property (weak, nonatomic) IBOutlet NFBaseTableView *tableView;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray<ZJContact *> *allData; //ZJContact类型数组
@property(nonatomic,strong)HCDTimer *timer;
@property (nonatomic,strong)AppDelegate *appdelegate;
@property (nonatomic, strong) UITextField *friendField;

@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;

@end

static CGFloat const kSearchBarHeight = 50.f;
//static CGFloat const kNavigationBarHeight = 64.f;

@implementation ZJContactViewController

//设置navigationController 基点从下面左上角算起
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    [UIView setAnimationsEnabled:YES];
    //是否来自编辑名字
    if (isFromEditName) {
        self.tabBarController.tabBar.hidden =YES;
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.tabBarController.tabBar.hidden =NO;
        self.navigationController.navigationBarHidden = NO;
    }
    
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
    //是否需要缓存
    needCache = YES;
    needGetCache = YES;
    
    //取缓存
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    
    //判断是否需要刷新 当添加好友请求后
    if ([NFUserEntity shareInstance].isNeedRefreshFriendList || self.dataArr.count == 0) {
        //[self initScoket];
        //请求完设置no
    }else{
        //if里面已经刷新了tableview，当no时候再刷新 保证只刷新一次 每次进来刷新 因为可能有申请通知
        [self.tableView reloadData];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
}

-(void)loadView{
    
    [super loadView];
    NSLog(@"loadview");
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //程序第一次运行 来自3d touch 进入扫一扫
    
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    //是否来自编辑名字
    if (isFromEditName) {
        self.tabBarController.tabBar.hidden =YES;
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.tabBarController.tabBar.hidden =NO;
        self.navigationController.navigationBarHidden = NO;
    }
    
    if ([NFUserEntity shareInstance].isNeedRefreshFriendList || self.dataArr.count == 0) {
        if(!IsFirstTime){
            [self initScoket];
        }
        //请求完设置no
    }
    IsFirstTime = NO;
    
    
    IsAllowRequest = NO;
    [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"IsAllowRequest"
    timeInterval:60
           queue:nil
         repeats:YES
    actionOption:AbandonPreviousAction
          action:^{
              IsAllowRequest = YES;
            [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsAllowRequest"];
          }];
    
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (!isFromEditName) {
        [self.ZJContactDetailController.view removeFromSuperview];
        self.ZJContactDetailController.view  = nil;
        self.ZJContactDetailController  = nil;
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    //disConnect
    [SVProgressHUD dismiss];
    if (reloading_) {
        [self doneLoadingTableViewData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //运行app 单例记录缓存的名字（可放在delegate didFinishLaunch中）
    [NFUserEntity shareInstance].contantList = [NSString stringWithFormat:@"tongxunjilu"];
    [NFUserEntity shareInstance].contantData = [NSString stringWithFormat:@"liaotianjilu"];
    [NFUserEntity shareInstance].hdnumber = @"1414058";
    self.title = @"联系人";
    self.navigationItem.title = @"联系人";
    self.tabBarItem.title = @"联系人";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
//    //当从3d touch 扫一扫进来 首页需要做的
//    if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"1"]) {
//        //跳转扫描二维码
//        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
//        QRCodeScanViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"QRCodeScanViewController"];
//        [self.navigationController pushViewController:qrcodeScanVC animated:YES];
//    }
    //下拉刷新 等界面布局
    [self initUI];
    rowHeightCache = [NSMutableDictionary new];
    self.tableView.backgroundColor = [UIColor whiteColor];
    //请求联系人列表
    IsFirstTime = YES;
    IsFirstTimeShow = YES;
    IsFinished = YES;
    IsAllowRefreshContact = YES;
    [self initScoket];
//    //如果为空 则赋值为0
//    if (![NFUserEntity shareInstance].PushQRCode) {
//        [NFUserEntity shareInstance].PushQRCode = @"0";
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendCount:) name:@"addFriendCount" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduseFriendCount:) name:@"reduseFriendCount" object:nil];
    
    
    
}




#pragma mark - 刷新函数
-(void)refresh{
//    [SVProgressHUD show];
    [socketRequest getFriendList];
}

//-(void)addFriendCount:(NSNotification *)notifi{
//    
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
//        [self.tableView reloadData];
//    });
//}
//
//-(void)reduseFriendCount:(NSNotification *)notifi{
//    
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
//        [self.tableView reloadData];
//    });
//}

#pragma mark - 请求好友列表
//[socketRequest getFriendList];

#pragma mark - 删除好友请求

#pragma mark - 收到服务器消息 9001
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doneLoadingTableViewData];
    });
    [SVProgressHUD dismiss];
    if (messageType == SecretLetterType_FriendList) {//3017
        //[SVProgressHUD show];
        if (IsFirstTimeShow) {
            [SVProgressHUD showWithStatus:@"信息展示中,请稍后..."];
        }
        IsFinished = YES;//是否请求完毕
        IsFirstTimeShow = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            //        [SVProgressHUD dismiss];
                    //确认请求到列表之后 设置不刷新
                    [NFUserEntity shareInstance].isNeedRefreshFriendList = NO;
                    //检查是否有表
                    [self.fmdbServicee IsExistLianxirenLieBiao];
                    //这里进行缓存
                    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    __weak typeof(self)weakSelf=self;
                    //取服务器返回的联系人列表
                    NSArray *friendArr = chatModel;
                    if (friendArr.count == 0) {
                        self.tableView.isNeed = YES;
                        //            [MessageChatListTableview showNone];
                        dispatch_main_async_safe(^{
                            [self.tableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"联系人列表为空"];
                        })
                    }else{
                        [self.tableView removeNone];
                    }
                    
                    //根据friendArr缓存联系人
                    [self.fmdbServicee cacheZJContactListWithArr:friendArr];
                    //取缓存中的联系人列表
                    __block NSMutableArray *contacts = [NSMutableArray new];
                    //这里重新去缓存联系人
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
                    }];
            //        NSArray *arrs = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""];
                    //取隐藏的缓存
                    NSMutableArray *lastContact = [NSMutableArray arrayWithArray:contacts];
                    __block NSArray *hidenArr = [NSArray new];
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        hidenArr = [strongSelf ->jqFmdb jq_lookupTable:@"yincanglianxiren" dicOrModel:[ZJContact class] whereFormat:@""];
                    }];
                    BOOL IsContainKefu = NO;//是否有客服好友
                    if(contacts.count == 0){
                        IsContainKefu = YES;
                    }
                    //将请求到的列表中，隐藏的好友缓存了但是不显示
                    for (ZJContact *friendEntity in contacts) {
                        if(!IsContainKefu && [friendEntity.friend_username isEqualToString:@"duoxinkefu"]){
                            IsContainKefu = YES;
                        }
                        for (ZJContact *hidenContact in hidenArr) {
                            if (![[NFUserEntity shareInstance].userId isEqualToString:friendEntity.friend_userid]) {
                                //如果是隐藏的好友 则移除
                                if (friendEntity.friend_userid == hidenContact.friend_userid) {
                                    [lastContact removeObject:friendEntity];
                                }
                            }
                        }
                    }
                    if (!IsContainKefu && ![[NFUserEntity shareInstance].userName isEqualToString:@"duoxinkefu"]) {
                        //如果没有多信客服好友 则添加好友
                        [socketRequest sendFriendAddRequest:@"duoxinkefu"];
                    }
                    //allData为ZJContact类型的实体的数组
                    self.allData = [NSArray arrayWithArray:lastContact];
                    /// 所有的indexsTitles。存放索引对应的下标_sectionIndexs dataSource _data
                    [self setupInitialAllDataArrayWithContacts:lastContact];
            sleep(0.5);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置navigation。标题
                NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)lastContact.count];
                FMLinkLabel *fmLabel = [NFMyManage createFMLinkLabelWithText:[NSString stringWithFormat:@"好友 %@",count] ColorfulText:count NormalTextColor:[UIColor whiteColor] SpecialColor:[UIColor yellowColor] Font:fontSize];
                self.navigationItem.titleView = fmLabel;
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
                
                self.view.userInteractionEnabled = YES;
                self.tabBarController.tabBar.userInteractionEnabled = YES;
                
                
            });
        });
        
        
    }
    else if (messageType == SecretLetterType_FriendAddRequest){
        [NFUserEntity shareInstance].IsApplyAndNotify = YES;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        });
    }else if (messageType == SecretLetterType_FriendAddAlreadyAgree){
        //收到好友同意通知 刷新好友列表
        [socketRequest getFriendList];
    }
    else if (messageType == SecretLetterType_FriendDeleteSuccess){
        NSInteger index = [_sectionIndexs[deleteIndexPath.section - 1] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[deleteIndexPath.row];
        // 删除
        [self removeContact:contact];
        //服务器请求 删除联系人
        // 刷新 当然数据比较大的时候可能就需要只刷新删除的对应的section了
        [self.tableView reloadData];
        //删除聊天记录
        BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:contact.friend_userid IsDelete:YES];
        if (rett) {
            NSLog(@"");
        }
        //删除会话
        BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:contact.friend_userid SecondKeyName:@"IsSingleChat" SecondValueName:@"1"];
        if (ret) {
            NSLog(@"");
        }
        //刷新会话列表、可以只刷新本地数据的
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        //[SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 初始化界面
-(void)initUI{
    unsigned int count = 0;
    Ivar *property = class_copyIvarList([UITabBarItem class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = property[i];
        const char *name = ivar_getName(var);
        const char *type = ivar_getTypeEncoding(var);
//        NSLog(@"%s =============== %s",name,type);
    }
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - _tableView.bounds.size.height, _tableView.frame.size.width, _tableView.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        [_tableView addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
//
    _tableView.sectionIndexColor = [UIColor darkGrayColor];
    // 普通状态的sectionIndexBar的背景颜色
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.searchBar;
    
#pragma mark - 设置searchbar相关
    
//    id Field = [self.searchBar valueForKey:@"_searchField"];
//    UITextField *txfSearchField;
//    if ([Field isKindOfClass:[UITextField class]]) {
//        txfSearchField = [self.searchBar valueForKey:@"_searchField"];
//    }
//    //设置searchbar textfield的placehold字体颜色
//    [txfSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [txfSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    
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
    
    //textfield背景图
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 15, 30)];
    backImage.image = [UIImage imageNamed:@"搜索栏白色"];
//    [txfSearchField addSubview:backImage];
    UIView *view = Field.superview;
    view.backgroundColor = [UIColor colorTextfieldBackBackground];
    for (UIView *view in self.searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            if (@available(iOS 13.0, *)) {
                [view.subviews objectAtIndex:0].hidden = YES;
            } else {
                [[view.subviews objectAtIndex:0] removeFromSuperview];
            }
            
            break;
        }
    }
//    [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
    
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    [rightBtn setImage:[UIImage imageNamed:@"洛阳首页-+号"] forState:UIControlStateNormal];
    //shouye_98
    [rightBtn setImage:[UIImage imageNamed:@"表头添加好友"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(handleRightBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    MenuTableV_ = [[CCZTableButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 157, 65, 150, 0) CellHeight:44];
    MenuTableV_.offsetXOfArrow = 50;
    MenuTableV_.wannaToClickTempToDissmiss = YES; //不选cell 界面不消失，省去了一点麻烦
    [MenuTableV_ addItems:@[@"好友设置"]];
    MenuTableV_.TitleImageArr = @[@"我的设置设置"];
    MenuTableV_.CellBackColor = [UIColor colorSectionHeader];
    MenuTableV_.CellTextColor = [UIColor colorMainTextColor];
    [MenuTableV_ selectedAtIndexHandle:^(NSUInteger index, NSString *itemName) {
        if (index == 0) {
            //好友设置 FriendSetTableViewController
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            FriendSetTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"FriendSetTableViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }];
    self.tableView.tableFooterView = [UIView new];
    
}

#pragma mark - 跳转到搜索好友
- (void)handleRightBtn
{
    //添加好友
    //添加好友 跳转controller
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
    addFrienfViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"addFrienfViewController"];
    toCtrol.addFriendType = @"1";
    [self.navigationController pushViewController:toCtrol animated:YES];
//    [MenuTableV_ show];
}

#pragma mark - 链接scoket聊天
-(void)initScoket{
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //当从登陆界面过来 需要打开下面，这时候
    if (socketModel.isConnected) {
        [socketModel ping];
    }
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        [self getDataFromFMDBData];
        return;
    }
    if (socketModel.isConnected) {
//        [SVProgressHUD show];
        if (IsFirstTimeShow) {
            [SVProgressHUD show];
        }
        if(IsFinished){
            IsFinished = NO;
            [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsFinished"];
            [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"IsFinished"
            timeInterval:20
                   queue:nil
                 repeats:YES
            actionOption:AbandonPreviousAction
                  action:^{
                      IsFinished = YES;
                      [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsFinished"];
                    self.view.userInteractionEnabled = YES;
                    self.tabBarController.tabBar.userInteractionEnabled = YES;
            }];
            
            if(IsAllowRefreshContact || [NFUserEntity shareInstance].isNeedRefreshFriendList){
                [socketRequest getFriendList];
                IsAllowRefreshContact = NO;
                
//                [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsAllowRefreshContact"];
//                [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"IsAllowRefreshContact"
//                timeInterval:300
//                       queue:nil
//                     repeats:YES
//                actionOption:AbandonPreviousAction
//                      action:^{
//                        IsAllowRefreshContact = YES;
//                          [[GCDTimerManager sharedInstance] cancelTimerWithName:@"IsAllowRefreshContact"];
//                  }];
                
            }
            
            if(self.allData.count == 0){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(self.allData.count == 0){
                        [SVProgressHUD showWithStatus:@"信息拉取中，请稍后..."];
                    }
                });
                self.view.userInteractionEnabled = NO;
                self.tabBarController.tabBar.userInteractionEnabled = NO;
            }
            
            
            
        }
    }else{
        [self getDataFromFMDBData];
    }
    
}

#pragma mark - 取缓存
-(void)getDataFromFMDBData{
    
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
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    [jqFmdb jq_inDatabase:^{
        //展示缓存
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""];
    }];
        if (arrs.count == 0) {
            self.tableView.isNeed = YES;
            //            [MessageChatListTableview showNone];
            dispatch_main_async_safe(^{
                [self.tableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"联系人列表为空" AndHeight:0];
            })
        }else{
            [self.tableView removeNone];
        }
    __block NSArray *hidenArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        hidenArr = [strongSelf ->jqFmdb jq_lookupTable:@"yincanglianxiren" dicOrModel:[ZJContact class] whereFormat:@""];
    }];
        NSMutableArray *lastContact = [NSMutableArray arrayWithArray:arrs];
        //遍历取出非隐藏联系人
        for (ZJContact *friendEntity in arrs) {
            if (![[NFUserEntity shareInstance].userId isEqualToString:friendEntity.friend_userid]) {
                for (ZJContact *hidenContact in hidenArr) {
                    //如果不是隐藏的好友 则添加到界面数组
                    if ([friendEntity.friend_userid isEqualToString:hidenContact.friend_userid]) {
                        [lastContact removeObject:friendEntity];
                    }
                }
            }else{
                //移除自己
                [lastContact removeObject:friendEntity];
            }
        }
        //allData为ZJContact类型的实体的数组
        self.allData = [NSArray arrayWithArray:lastContact];
        //// 所有的indexsTitles。存放索引对应的下标_sectionIndexs dataSource _data
        [self setupInitialAllDataArrayWithContacts:lastContact];
        //设置navigation。标题
        NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)lastContact.count];
        FMLinkLabel *fmLabel = [NFMyManage createFMLinkLabelWithText:[NSString stringWithFormat:@"好友 %@",count] ColorfulText:count NormalTextColor:[UIColor whiteColor] SpecialColor:[UIColor yellowColor] Font:17];
        self.navigationItem.titleView = fmLabel;
        [self.tableView reloadData];
        [socketModel connect];
//    }];
    
}

#pragma mark - 创建导航栏上面 带黄色字的label
-(FMLinkLabel *)createFMLinkLabelWithText:(NSString *)text ColorfulText:(NSString *)colorText NormalTextColor:(UIColor *)normalColor SpecialColor:(UIColor *)color Font:(NSInteger)font{
    FMLinkLabel *label = [[FMLinkLabel alloc]initWithFrame:CGRectMake(0, 0, JOESIZE.width, 64)];
    label.text = text;
    label.textColor = [UIColor colorWithRed:0.17 green:0.55 blue:0.87 alpha:1.00];
    label.font = [UIFont systemFontOfSize:font];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = normalColor;
    [label addClickText:colorText attributeds:@{NSForegroundColorAttributeName : color} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
    }];
    return label;
}

// 设置初始的所有数据 布局联系人数组
- (void)setupInitialAllDataArrayWithContacts:(NSArray<ZJContact *> *)contacts {
    // 按照 ZJContact中的name来处理
//    SEL nameSelector = @selector(friend_username);
    SEL nameSelector = @selector(friend_nickname);
    // 单例对象
    UILocalizedIndexedCollation *localIndex = [UILocalizedIndexedCollation currentCollation];
    // 获得当前语言下的所有的indexTitles
    _allIndexTitles = localIndex.sectionTitles;
    // 初始化所有数据的数组
    _data = [NSMutableArray arrayWithCapacity:_allIndexTitles.count];
    // 为每一个indexTitle 生成一个可变的数组
    for (int i = 0; i<_allIndexTitles.count; i++) {
        // 初始化数组
        [_data addObject:[NSMutableArray array]];
    }
    // 初始化有效的sectionIndexs
    _sectionIndexs = [NSMutableArray arrayWithCapacity:_allIndexTitles.count];
    for (ZJContact *contact in contacts) {
        if (contact == nil) continue;
        // 获取到这个contact的name的首字母对应的indexTitle
        // 注意这里必须使用对象, 这个selector也是有要求的
        // 必须是这个对象中的selector, 并且不能有参数, 必须返回字符串
        // 所以这里直接使用 name 属性的get方法就可以
        NSInteger index = [localIndex sectionForObject:contact collationStringSelector:nameSelector];
        // 处理多音字 例如 "曾" -->> 会被当做 ceng 来处理, 其他需要处理的多音字类似
        if ([contact.friend_username hasPrefix:@"曾"] || [contact.friend_nickname hasPrefix:@"曾"]) {
            index = [_allIndexTitles indexOfObject:@"Z"];
        }
        // 将这个contact添加到对应indexTitle的数组中去
        [_data[index] addObject:contact];
    }
    for (int i=0; i<_data.count; i++) {
        NSArray *temp = _data[i];
        if (temp.count != 0) { // 取出不为空的部分对应的indexTitle
            [_sectionIndexs addObject:[NSNumber numberWithInt:i]];
        }
        // 排序每一个数组
        _data[i] = [localIndex sortedArrayFromArray:temp collationStringSelector:nameSelector];
    }
}

// 增加联系人
- (void)addContact:(ZJContact *)contact {
    if (contact == nil) return;
    // 按照 ZJContact中的name来处理
    SEL nameSelector = @selector(friend_nickname);
    // 单例对象
    UILocalizedIndexedCollation *localIndex = [UILocalizedIndexedCollation currentCollation];
    NSInteger index = [localIndex sectionForObject:contact collationStringSelector:nameSelector];
    // 处理多音字 例如 "曾" -->> 会被当做 ceng 来处理, 其他需要处理的多音字类似
    if ([contact.friend_username hasPrefix:@"曾"] || [contact.friend_nickname hasPrefix:@"曾"]) {
        index = [_allIndexTitles indexOfObject:@"Z"];
    }
    // 将这个contact添加到对应indexTitle的数组中去
    NSMutableArray *tempContacts = [_data[index] mutableCopy];
    [tempContacts addObject:contact];
    _data[index] = tempContacts;
    // 移除原来的, 便于重新添加
    [_sectionIndexs removeAllObjects];
    for (int i=0; i<_data.count; i++) {
        NSArray *temp = _data[i];
        if (temp.count != 0) { // 取出不为空的部分对应的indexTitle
            [_sectionIndexs addObject:[NSNumber numberWithInt:i]];
        }
        // 排序每一个数组
        _data[i] = [localIndex sortedArrayFromArray:temp collationStringSelector:nameSelector];
    }
}

#pragma mark - 删除联系人
- (void)removeContact:(ZJContact *)contact {
    if (contact == nil) return;
    // 按照 ZJContact中的name来处理
    SEL nameSelector = @selector(friend_nickname);
    // 单例对象
    UILocalizedIndexedCollation *localIndex = [UILocalizedIndexedCollation currentCollation];
    NSInteger index = [localIndex sectionForObject:contact collationStringSelector:nameSelector];
    // 处理多音字 例如 "曾" -->> 会被当做 ceng 来处理, 其他需要处理的多音字类似
    if ([contact.friend_username hasPrefix:@"曾"] || [contact.friend_nickname hasPrefix:@"曾"]) {
        index = [_allIndexTitles indexOfObject:@"Z"];
    }
    // 将这个contact从对应indexTitle的数组中删除
    NSMutableArray *tempContacts = [_data[index] mutableCopy];
    [tempContacts removeObject:contact];
    _data[index] = tempContacts;
    // 移除原来的, 便于重新添加
    [_sectionIndexs removeAllObjects];
    for (int i=0; i<_data.count; i++) {
        NSArray *temp = _data[i];
        if (temp.count != 0) { // 取出不为空的部分对应的indexTitle
            [_sectionIndexs addObject:[NSNumber numberWithInt:i]];
        }
        // 排序每一个数组
        _data[i] = [localIndex sortedArrayFromArray:temp collationStringSelector:nameSelector];
    }
    //删除缓存
    __block BOOL ret;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:@"lianxirenliebiao" whereFormat:@"where friend_userid = '%@'",contact.friend_userid];
        if (ret) {
            NSLog(@"删除成功");
        }
    }];
}

#pragma mark - tableview Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionIndexs.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
//        return 2;
        return 3;
    }
        NSInteger index = [_sectionIndexs[section - 1] integerValue];
        NSArray *temp = _data[index];
        return temp.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]]) {
        NSNumber *cacheHeight = [rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
        return [cacheHeight floatValue];
    }
    NSNumber *cacheHeight = [[NSNumber alloc] initWithFloat:60];
    [rowHeightCache setValue:cacheHeight forKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
    return 60;
}

-(CGFloat)cellsTotalHeight:(NSDictionary *)dict{
    CGFloat totalHeight = 0;
    NSArray *heightValues = [dict allValues];
    for (NSNumber *cacheHeight in heightValues) {
        totalHeight +=[cacheHeight floatValue];
    }
    return totalHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1.5;
    }
    return 20.f;
}

//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"ContantTableViewCell";
    ContantTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ContantTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.nameLabel.textColor = [UIColor colorMainTextColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.nameLabel.text = @"申请与通知";
            cell.headImageView.image = [UIImage imageNamed:@"申请与通知"];
            //如果有添加提醒则显示红点
            if ([NFUserEntity shareInstance].IsApplyAndNotify) {
                cell.badgeCountView.hidden = NO;
                cell.badgeCountView.showBadge = YES;
                cell.badgeCountView.badge = [NFUserEntity shareInstance].contactBadgeCount;
                cell.badgeCountView.badgeSize = 15;
                cell.badgeCountView.badgeFont = [UIFont systemFontOfSize:12];
            }
//            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }else if (indexPath.row == 1){
            cell.nameLabel.text = @"群组";
            cell.headImageView.image = [UIImage imageNamed:@"我的群组"];
//            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }else if (indexPath.row == 2){
            cell.nameLabel.text = @"黑名单";
            cell.headImageView.image = [UIImage imageNamed:@"黑名单"];
            //        cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }
    if(indexPath.section - 1 > _sectionIndexs.count -1){
        return nil;
    }
    NSInteger index = [_sectionIndexs[indexPath.section - 1] integerValue];
    NSArray *temp = _data[index];
    ZJContact *contact = (ZJContact *)temp[indexPath.row];
    if (contact.friend_nickname.length > 0) {
        cell.nameLabel.text = contact.friend_nickname;
    }else{
        cell.nameLabel.text = contact.friend_username;
    }
//    cell.headImageView.image = contact.icon;
//    cell.headImageView.image = [UIImage imageNamed:@"联系人默认头像"];
    cell.headImageView.backgroundColor = [UIColor clearColor];
//    if ([contact.iconUrl containsString:@"head_man"]) {
//        cell.headImageView.image = [UIImage imageNamed:contact.iconUrl];
//    }else{
    if ([cell.headImageView isKindOfClass:[UIImageView class]]) {
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    }else{
        [cell.headImageView ShowImageWithUrlStr:contact.iconUrl placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
        }];
    }
    
//    }
    
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

//选择联系人跳转
#pragma mark - 点击选择想要联系的人 跳转到聊天界面
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //申请与通知
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
            ApplyViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ApplyViewController"];
            //点击后 红点提醒设置为no
            [NFUserEntity shareInstance].IsApplyAndNotify = NO;
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//                sleep(1);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                });
//            });
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 1){
            //群组
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
            GroupListViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupListViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
            
        }else if (indexPath.row == 2){
            //黑名单
            NSMutableArray *shieldArr = [NSMutableArray new];
            for (ZJContact *contact in self.allData) {
                if (contact.IsShield) {
                    [shieldArr addObject:contact];
                }
            }
            //DarkerTableViewController
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
            DarkerTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"DarkerTableViewController"];
            toCtrol.dataArr = shieldArr;
            [self.navigationController pushViewController:toCtrol animated:YES];
            
        }
        else{
            //添加好友 跳转controller
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//            addFrienfViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"addFrienfViewController"];
//            toCtrol.addFriendType = @"1";
//            [self.navigationController pushViewController:toCtrol animated:YES];
            //弹窗
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(self)weakSelf=self;
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"好友用户名";
                weakSelf.friendField = textField;
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                //取消选中
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
                return ;
            }];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([self.friendField.text isEqualToString:[NFUserEntity shareInstance].userName]) {
                    [SVProgressHUD showInfoWithStatus:@"不可以添加自己为好友"];
                    return ;
                }
                //取消选中
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
                [self.parms removeAllObjects];
                self.parms[@"action"] = @"addFriend";
                self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
                self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
                self.parms[@"addTime"] = [NFMyManage getCurrentTimeStamp];
                self.parms[@"addUserName"] = self.friendField.text;
                if ([self.friendField.text isEqualToString:[NFUserEntity shareInstance].userName]) {
                    [SVProgressHUD showInfoWithStatus:@"不可以添加自己喔"];
                    return;
                }
                NSString *Json = [JsonModel convertToJsonData:self.parms];
                NSLog(@"发送好友请求的信息:%@",Json);
                if (socketModel.isConnected) {
                    [socketModel sendMsg:Json];
                }else{
//                    [SVProgressHUD showInfoWithStatus:kWrongMessage];
                }
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:sureAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }else{
        selectedIndexPath = indexPath;
        //ZJContactDetailController
        self.ZJContactDetailController.view  = nil;
        self.ZJContactDetailController  = nil;
        //展示联系人详情
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        [self showContactDetail:indexPath];
    }
}

#pragma mark - 展示联系人详情
-(void)showContactDetail:(NSIndexPath *)indexPath{
    if (self.ZJContactDetailController == nil) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
        self.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
        //设置单聊详情数据
        NSInteger index = [_sectionIndexs[indexPath.section - 1] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
        self.ZJContactDetailController.contant = contact;
        self.ZJContactDetailController.SourceFrom = @"0";
        [self addChildViewController:self.ZJContactDetailController];
        self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        __weak typeof(self)weakSelf=self;
        //点击了headview上面的事件
        [self.ZJContactDetailController clickWhichIndex:^(int index) {
            if (index == 0 || index == 10) {
                //移除ZJContactDetailController
                [UIView animateWithDuration:0.2 animations:^{
                    self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                    [self.ZJContactDetailController.view removeFromSuperview];
                    //当移除界面后 设置来自编辑名字为no
                    isFromEditName = NO;
                }];
                weakSelf.navigationController.navigationBarHidden = NO;
                weakSelf.tabBarController.tabBar.hidden = NO;
            }else if (index == 1){
                //相册
                isFromEditName = YES;
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
                [self.navigationController pushViewController:showImageViewCtrol animated:YES];
            }else if (index == 2){
                //2收藏
            }
        }];
        //设置编辑名字、免费聊天
//        [self.ZJContactDetailController.nameEditBtn addTarget:self action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
        [self.ZJContactDetailController.freeChatBtn addTarget:self action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
        //设置头像
        //头像宽度
        CGFloat width = 100;
        self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - width/2, -65, width, width)];
        
//        ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
        ViewRadius(self.ZJContactDetailController.nfHeadImageV, 3);
        self.ZJContactDetailController.nfHeadImageV.image = [UIImage imageNamed:@"联系人默认头像"];
        [self.ZJContactDetailController.nfHeadImageV ShowHeadImageWithUrlStr:contact.iconUrl withUerId:nil completion:^(BOOL success, UIImage *image) {
            
        }];
        //点击头像后
        [self.ZJContactDetailController.nfHeadImageV afterClickHeadImage:^{
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
            [weakSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
        }];
        //将头像add到tableview上面
        [self.ZJContactDetailController.tableView addSubview:self.ZJContactDetailController.nfHeadImageV];
        [self.view addSubview:self.ZJContactDetailController.view];
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.navigationBarHidden = YES;
            self.tabBarController.tabBar.hidden = YES;
            self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - 点击头像
-(void)headviewClick{
    isFromEditName = YES;
    SGPhoto *temp = [[SGPhoto alloc] init];
    temp.identifier = @"";
    temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
    temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
    HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
    showImageViewCtrol.imageUrlList = @[temp];
    showImageViewCtrol.mainImageIndex = 0;
    showImageViewCtrol.isLuoYang = YES;
    showImageViewCtrol.isNeedNavigation = NO;
    [self.navigationController pushViewController:showImageViewCtrol animated:YES
     ];
}

#pragma mark - 编辑名字
-(void)EditNameClick{
//    self.navigationController.navigationBarHidden = NO;
    //名字
    isFromEditName = YES;
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
    PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
    toCtrol.editType = EditNameType;
    [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
        if (type == EditNameType) {
            [self.ZJContactDetailController.nameEditBtn setTitle:info forState:(UIControlStateNormal)];
        }
    }];
    [self.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 免费聊天
-(void)freeChatClick:(UIButton *)button event:(UIEvent *)event{
    isFromEditName = NO;
//    self.navigationController.navigationBarHidden = NO;
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
//    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
    NSInteger index = [_sectionIndexs[selectedIndexPath.section - 1] integerValue];
    NSArray *temp = _data[index];
    ZJContact *contact = (ZJContact *)temp[selectedIndexPath.row];
    toCtrol.titleName = contact.friend_nickname;
    toCtrol.conversationId = contact.friend_userid;
    toCtrol.chatType = @"0";
    
    toCtrol.singleContactEntity = contact;
    [self.navigationController pushViewController:toCtrol animated:YES];
}

// sectionHeader
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return @"";
//    }
//    NSInteger index = [_sectionIndexs[section - 1] integerValue];
//    return _allIndexTitles[index];
//}
//section头视图
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    if (_sectionIndexs.count > 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        headerView.backgroundColor = [UIColor colorSectionHeader];
        NSInteger index = [_sectionIndexs[section - 1] integerValue];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        titleLabel.text = _allIndexTitles[index];
        titleLabel.textColor = [UIColor colorSectionTitleColor];
        titleLabel.font = [UIFont fontSectionHeader];
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(headerView.mas_centerY);
            make.leading.mas_equalTo(headerView.mas_leading).offset(10);
        }];
        return headerView;
    }
    return nil;
}

// 这个方法是返回索引的数组, 我们需要根据之前获取到的两个数组来取到我们需要的
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *indexTitles = [NSMutableArray arrayWithCapacity:_sectionIndexs.count];
    // 遍历索引的下标数组, 然后根据下标取出_allIndexTitles对应的索引字符串
    for (NSNumber *number in _sectionIndexs) {
        NSInteger index = number.integerValue;
        [indexTitles addObject:_allIndexTitles[index]];
    }
    return indexTitles;
}
// 可以相应点击的某个索引, 也可以为索引指定其对应的特定的section, 默认是 section == index
// 返回点击索引列表上的索引时tableView应该滚动到那一个section去
// 这里我们的tableView的section和索引的个数相同, 所以直接返回索引的index即可
// 如果不相同, 则需要自己相应的返回自己需要的section
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSLog(@"%@---%ld", title, index);
    // 显示正在点击的indexTitle ZJProgressHUD这个小框架是我们已经实现的
    [ZJProgressHUD showStatus:title andAutoHideAfterTime:0.5];
    return index;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger index = [_sectionIndexs[indexPath.section - 1] integerValue];
//    NSArray *temp = _data[index];
//    ZJContact *contact = (ZJContact *)temp[indexPath.row];
//    // 删除
//    [self removeContact:contact];
//    //服务器请求 删除联系人
//    // 刷新 当然数据比较大的时候可能就需要只刷新删除的对应的section了
//    [tableView reloadData];
}

//左滑多个选项
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction * deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"删除");
        deleteIndexPath = indexPath;
        NSInteger index = [_sectionIndexs[indexPath.section - 1] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"同时回删除对方的临时会话，不再接受此人消息" otherButtonTitles:[NSArray arrayWithObjects:@"删除好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                //删除缓存中的联系人
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                __block BOOL ret = NO;
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    ret = [strongSelf ->jqFmdb jq_deleteTable:@"lianxirenliebiao" whereFormat:@"where friend_userid = '%@' and friend_username = '%@'",contact.friend_userid,contact.friend_username];
                }];
                if (ret) {
                    [socketRequest deleteFriendRequest:contact.friend_userid];
                }
            }
        }];
        [sheet show];
        self.tableView.editing = NO;
        
    }];
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction * topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"隐藏" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"隐藏");
        [self.tableView setEditing:NO animated:YES];
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        //检查表存在
        [self.fmdbServicee IsExistYinCangLianxirenLieBiao];
        NSInteger index = [_sectionIndexs[indexPath.section - 1] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
        __block BOOL rett = NO;
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            rett = [strongSelf ->jqFmdb jq_insertTable:@"yincanglianxiren" dicOrModel:contact];
        }];
        if (rett) {
            //隐藏成功 刷新界面上数据
            [self getDataFromFMDBData];
        }
    }];
    topRowAction.backgroundColor = [UIColor lightGrayColor];
    return @[deleteRowAction,topRowAction];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除联系人";
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.searchBar) {
        self.tabBarController.tabBar.hidden = YES;
        self.navigationController.navigationBar.translucent = YES;

        if (@available(iOS 13.0, *)) {
//            self.searchController.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:self.searchController animated:YES completion:^{
        }];
        return NO;
    }
    return YES;
}

#pragma mark - searchbar 相关
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == _searchController.searchBar) {
        ZJSearchResultController *resultController = (ZJSearchResultController *)_searchController.searchResultsController;
        // 更新数据 并且刷新数据
        resultController.data = [ZJContact searchText:searchText inDataArray:self.allData];
        [resultController SelectContantJumpBlock:^(ZJContact *contant) {
            //跳转前移除搜索界面
            self.searchController.searchBar.text = @"";
            [self dismissViewControllerAnimated:NO completion:nil];
            //进行跳转传值
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
            toCtrol.titleName = contant.friend_nickname?contant.friend_nickname:contant.friend_username;
            toCtrol.conversationId = contant.friend_userid;
            toCtrol.chatType = @"0";
//            MessageChatListEntity *entity = [MessageChatListEntity new];
//            entity.user_name = contant.friend_username;
//            entity.nickName = contant.friend_nickname?contant.friend_nickname:contant.friend_username;
//            toCtrol.singleEntity = entity;
            toCtrol.singleContactEntity = contant;
            [self.navigationController pushViewController:toCtrol animated:YES];
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

// 这个代理方法在searchController消失的时候调用, 这里我们只是移除了searchController, 当然你可以进行其他的操作
- (void)didDismissSearchController:(UISearchController *)searchController {
    // 销毁
    self.searchController = nil;
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        // ios8+才可用 否则使用 UISearchDisplayController
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:[ZJSearchResultController new]];
        searchController.delegate = self;
//        searchController.searchResultsUpdater = self;
        searchController.searchBar.delegate = self;
        searchController.searchBar.placeholder = @"搜索姓名/首字母";
        //隐藏取消按钮
        searchController.searchBar.showsCancelButton = YES;
#pragma mark - 设置searchbarController
UITextField *searchControllerSearchField;
        if (@available(iOS 13.0, *)) {
            searchControllerSearchField =searchController.searchBar.searchTextField;
        }else{
            searchControllerSearchField = [searchController.searchBar valueForKey:@"_searchField"];
            [searchControllerSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
            [searchControllerSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        }
//        if ([Field isKindOfClass:[UITextField class]]) {
//            searchControllerSearchField = [searchController.searchBar valueForKey:@"_searchField"];
//        }
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

//-(NSArray<ZJContact *> *)allData {
//    NSMutableArray<ZJContact *> *allData = [NSMutableArray array];
//    for (NSArray *contacts in _data) {// 获取所有的contact
//        if (contacts.count != 0) {
//            for (ZJContact *contact in contacts) {
//                [allData addObject:contact];
//            }
//        }
//    }
//    return allData;
//}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, kSearchBarHeight)];
        searchBar.delegate = self;
        searchBar.placeholder = @"姓名/首字母";
        _searchBar = searchBar;
    }
    return _searchBar;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat height = 0;
    if (_sectionIndexs.count >0) {
        height = [self cellsTotalHeight:rowHeightCache] + (_sectionIndexs.count - 1)*20 + 50;
    }else{
        height = 0;
    }
    if (self.tableView.contentOffset.y > 0 && height <= SCREEN_HEIGHT - kTopHeight - kTabBarHeight) {
        [UIView animateWithDuration:0.1 animations:^{
        self.tableView.contentOffset = CGPointMake(0, 0);
        }];
    }
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
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}

#pragma mark - 下拉刷新委托回调
//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
#pragma mark - 下拉刷新6
    //此处刷新接口数据
//    [self initDataSource];
    
    [socketModel ping];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doneLoadingTableViewData];
    });
    
    if (![ClearManager getNetStatus]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneLoadingTableViewData];
        });
    }else{
        if ([socketModel isConnected]) {
            //刷新请求联系人列表
            IsAllowRefreshContact = YES;//手动刷新 强制为YES
            [self initScoket];
        }else{
            //重连
            [socketModel initSocket];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doneLoadingTableViewData];
            });
            __weak typeof(self)weakSelf=self;
            [socketModel returnConnectSuccedd:^{
//                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//                if (![currentVC isKindOfClass:[LoginViewController class]]) {
//                    return ;
//                }
                //刷新请求联系人列表
                [weakSelf initScoket];
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

//懒加载
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

//懒加载 fmdbServicee
-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
}

//-(SocketRequest *)socketRequest{
//    if (!_socketRequest) {
//        _socketRequest = [[SocketRequest alloc] init];
//    }
//    return _socketRequest;
//}



@end
