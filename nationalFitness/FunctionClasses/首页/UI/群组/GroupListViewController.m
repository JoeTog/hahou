//
//  GroupListViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupListViewController.h"
#import "ZJContact.h"
#import "ZJSearchResultController.h"
#import "ZJProgressHUD.h"
#import "ContantTableViewCell.h"
#import "MessageChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "CCZTableButton.h"
#import "JQFMDB.h"

@interface GroupListViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate,EGORefreshTableHeaderDelegate,ChatHandlerDelegate> {
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
    SocketRequest *socketRequest;
    
    //add菜单
    CCZTableButton *addShopTableV_;
    
    JQFMDB *jqFmdb;
    
    ZJContact *selectedContact;
    
    
}

@property (weak, nonatomic) IBOutlet NFBaseTableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray<ZJContact *> *allData;
@property (nonatomic,strong)AppDelegate *appdelegate;




@end

static CGFloat const kSearchBarHeight = 50.f;

@implementation GroupListViewController

//设置navigationController 基点从下面左上角算起
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
//    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"群组";
    self.tabBarItem.title = @"群组";
    if (self.fromType) {
        self.title = @"选择一个群";
    }
    [self initUI];
//    [self initDataSource];
    [self initScoket];
    
}

-(void)initScoket{
    //取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    if (socketModel.isConnected) {
        [socketModel ping];
    }
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        [self getDataFromFMDBData];
        return;
    }
    if (socketModel.isConnected) {
        if (socketModel.isConnected) {
            [socketRequest requestGroupArr];
        }else{
            [self getDataFromFMDBData];
        }
    }else{
        [self getDataFromFMDBData];
    }
    
}

#pragma mark - 取缓存
-(void)getDataFromFMDBData{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block NSArray *arrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //展示缓存
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"qunzuliebiao" dicOrModel:[GroupListEntity class] whereFormat:@""];
        NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:10];
        for (GroupListEntity *groupEntity in arrs) {
            ZJContact *contact = [ZJContact new];
            contact.groupId = groupEntity.groupId;
            contact.groupName = groupEntity.groupName;
            contact.friend_username = groupEntity.groupName;
            contact.friend_userid = groupEntity.groupId;
            contact.iconUrl = groupEntity.groupPhoto;
            [contacts addObject:contact];
        }
        //allData为ZJContact类型的实体的数组
        strongSelf.allData = [NSArray arrayWithArray:contacts];
        //// 所有的indexsTitles。存放索引对应的下标_sectionIndexs dataSource _data
        [strongSelf setupInitialAllDataArrayWithContacts:contacts];
        if (strongSelf.allData.count == 0) {
            [strongSelf.tableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"群组列表为空"];
        }else{
            [strongSelf.tableView removeNone];
        }
        [strongSelf.tableView reloadData];
        [strongSelf ->socketModel connect];
    }];
}

#pragma mark - 请求群组 

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    //群组列表
    if (messageType == SecretLetterType_GroupList) {
        //检查表存在
        [self.fmdbServicee IsExistQunzuLiebiao];
        //这里进行缓存
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        //判断是否需要删除本地数据 当本地群组数大于服务器给的 说明有残余群组
        [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:@"qunzuliebiao" IsDelete:NO];
        NSArray *groupArr = chatModel;
        NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:10];
        __weak typeof(self)weakSelf=self;
        for (GroupListEntity *groupEntity in groupArr) {
            //插入数据
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:@"qunzuliebiao" dicOrModel:groupEntity];
                if (!rett) {
                    //                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
            //添加到显示
            ZJContact *contact = [ZJContact new];
            contact.groupId = groupEntity.groupId;
            contact.groupName = groupEntity.groupName;
            contact.friend_username = groupEntity.groupName;
            contact.iconUrl = groupEntity.groupPhoto;
            [contacts addObject:contact];
        }
        self.allData = [NSArray arrayWithArray:contacts];
        [self setupInitialAllDataArrayWithContacts:contacts];
        if (self.allData.count == 0) {
            [self.tableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"群组列表为空"];
        }else{
            [self.tableView removeNone];
        }
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [self.tableView reloadData];
            [self doneLoadingTableViewData];
        });
        [SVProgressHUD dismiss];
    }else if (messageType == SecretLetterType_ReceiveGroupMessage){
        //收到转发消息 已经在socketModel中缓存好 只需要pop回去就行
        //群聊消息发送回执 这里为转发后的回调
        if (self.fromType) {
            //            self.tabBarController.tabBar.hidden = NO;
            if ([selectedContact.friend_username isEqualToString:self.chatingName]) {
                [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
            }
            [SVProgressHUD showSuccessWithStatus:@"发送成功"];
            __weak typeof(self)weakSelf=self;
            [self createDispatchWithDelay:1 block:^{
                UIViewController * viewVC = [weakSelf.navigationController.viewControllers objectAtIndex:1];
                [weakSelf.navigationController popToViewController:viewVC animated:YES];
            }];
        }
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
}

#pragma mark - 初始化界面 创建群组
-(void)initUI{
    if (!self.fromType) {
        UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backBtn setImage:[UIImage imageNamed:@"添加按钮按钮"] forState:UIControlStateNormal];
        //    [backBtn setTitle:@"添加创建" forState:UIControlStateNormal];
        //    backBtn.titleLabel.font = [UIFont systemFontOfSize:14];;
        //    [backBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [backBtn addTarget:self action:@selector(addTeamClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
//        self.navigationItem.rightBarButtonItem = backButtonItem;
    }
    
    
    self.tableView.tableFooterView = [UIView new];
    
    addShopTableV_ = [[CCZTableButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 157, 65, 150, 0) CellHeight:44];
    addShopTableV_.TitleImageArr = @[@"group_joinpublicgroup",@"申请与通知"];
    addShopTableV_.offsetXOfArrow = 50;
    addShopTableV_.wannaToClickTempToDissmiss = YES;
    addShopTableV_.CellBackColor = [UIColor colorSectionHeader];
    addShopTableV_.CellTextColor = [UIColor colorMainTextColor];
//    [addShopTableV_ addItems:@[@"创建群组",@"添加群组"]];
    [addShopTableV_ addItems:@[@"创建群组"]];
    __weak typeof(self)weakSelf=self;
    [addShopTableV_ selectedAtIndexHandle:^(NSUInteger index, NSString *itemName) {
        if (index == 0) {
            //选择成员创建群聊
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
            toCtrol.SourceType = SourceTypeFromGroupCreate;
            [weakSelf.navigationController pushViewController:toCtrol animated:YES];
        }else{
            //
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
            addFrienfViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"addFrienfViewController"];
            toCtrol.addFriendType = @"2";
            [weakSelf.navigationController pushViewController:toCtrol animated:YES];
        }
    }];
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - _tableView.bounds.size.height, _tableView.frame.size.width, _tableView.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        [_tableView addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
    _tableView.sectionIndexColor = [UIColor lightGrayColor];
    // 普通状态的sectionIndexBar的背景颜色
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.searchBar;
#pragma mark - 设置searchbar相关

    id Field;
    if (@available(iOS 13.0, *)) {
        Field =self.searchBar.searchTextField;
    }else{
        Field = [self.searchBar valueForKey:@"_searchField"];
    }
    
    UITextField *txfSearchField;
    if (@available(iOS 13.0, *)) {
        txfSearchField = self.searchBar.searchTextField;
    }else{
        if ([Field isKindOfClass:[UITextField class]]) {
            txfSearchField = [self.searchBar valueForKey:@"_searchField"];

            //设置searchbar textfield的placehold字体颜色
            [txfSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
            [txfSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        }
    }
    
    txfSearchField.textColor = [UIColor colorMainTextColor];
    txfSearchField.backgroundColor = [UIColor colorTextfieldBackground];
    //放大镜
    [self.searchBar setImage:[UIImage imageNamed:@"searbar搜索"]
            forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    self.searchBar.barTintColor = [UIColor colorNavigationBackground];
    //设置cancel文字颜色
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
    
    //textfield背景图
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 30)];
    backImage.image = [UIImage imageNamed:@"搜索栏白色"];
//    [txfSearchField addSubview:backImage];
    UIView *view = txfSearchField.superview;
    view.backgroundColor = [UIColor colorTextfieldBackBackground];
    for (UIView *view in self.searchBar.subviews) {
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
}

#pragma mark - 添加群组
-(void)addTeamClick{
    //菜单
    [addShopTableV_ show];
}

#pragma mark - //准备数据
//-(void)initDataSource{
//    NSArray *testArray = @[@"444", @"中软", @"博伟峰测试群",  @"同城交友", @"124"];
//    NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:10];
//    for (NSString *name in testArray) {
//        ZJContact *test = [ZJContact new];
//        test.name = name;
//        test.icon = [UIImage imageNamed:@"图标"];
//        test.chatId = @"123";
//        [contacts addObject:test];
//    }
//    self.allData = [NSArray arrayWithArray:contacts];
//    [self setupInitialAllDataArrayWithContacts:contacts];
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
//        //        for (int i=0; i<1000; i++) {
//        //            NSLog(@"1");
//        //        }
//        [self doneLoadingTableViewData];
//    });
//}

//- (void)addBtnOnClick {
//    ZJContact *test = [ZJContact new];
//    test.name = @"新添加联系人";
//    test.icon = [UIImage imageNamed:@"icon"];
//    [self addContact:test];
//    [self.tableView reloadData];
//}

// 设置初始的所有数据
- (void)setupInitialAllDataArrayWithContacts:(NSArray<ZJContact *> *)contacts {
    // 按照 ZJContact中的name来处理
    SEL nameSelector = @selector(friend_username);
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
    NSLog(@"");
}
// 增加联系人
- (void)addContact:(ZJContact *)contact {
    if (contact == nil) return;
    
    // 按照 ZJContact中的name来处理
    SEL nameSelector = @selector(friend_username);
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
// 删除联系人
- (void)removeContact:(ZJContact *)contact {
    if (contact == nil) return;
    // 按照 ZJContact中的name来处理
    SEL nameSelector = @selector(friend_username);
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
    
}

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
    return _sectionIndexs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 20;
    NSInteger index = [_sectionIndexs[section ] integerValue];
    NSArray *temp = _data[index];
    return temp.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20.f;
}

//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"ContantTableViewCell";
    ContantTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ContantTableViewCell" owner:nil options:nil]firstObject];
    }
    ZJContact *contact;
    if (_sectionIndexs[indexPath.section]) {
        NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
        NSArray *temp = _data[index];
        contact = (ZJContact *)temp[indexPath.row];
    }
    cell.nameLabel.text = contact.groupName;
//    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//    NSURL *icon1URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-e182f6da029b3e7d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
//    NSURL *icon2URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-023e66be11a2e94b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"];
//    NSURL *icon3URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-d7ece9dba73d4953.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
//    NSURL *icon4URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-e08bf975aadbfdd4.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
//    NSURL *icon5URL = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/3816723-13271b280c0e5fd4.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/100"] ;
    //NSArray *iconItemsArr = @[icon1URL,icon2URL,icon3URL,icon4URL,icon5URL];
//    NSArray *iconItemsArr = @[icon1URL,icon2URL];
//    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//        UIImage *image = [UIImage groupIconWithURLArray:iconItemsArr bgColor:[UIColor groupTableViewBackgroundColor]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.headImageView.image = image;
//        });
//    });
//    cell.headImageView.image = [UIImage groupIconWithURLArray:iconItemsArr bgColor:[UIColor groupTableViewBackgroundColor]];
    contact.iconUrl = [contact.iconUrl stringByReplacingOccurrencesOfString:[NFUserEntity shareInstance].HeadPicpathAppendingString withString:@"http://121.43.116.159:7999/web_file/Public/uploads/"];
    [cell.headImageView ShowImageWithUrlStr:contact.iconUrl placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
    
}

//选择群组跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    if (self.fromType) {
        __block NSString *conyentString = [NSString new];
        if ([self.contentType isEqualToString:@"0"]) {
            conyentString = self.forwardContent;
        }else if ([self.contentType isEqualToString:@"1"]){
            conyentString = @"图片";
        }else if ([self.contentType isEqualToString:@"2"]){
            conyentString = @"语音";
        }
        NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
        NSArray *temp = _data[index];
        selectedContact = (ZJContact *)temp[indexPath.row];
        PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:[NSString stringWithFormat:@"发送给:%@",selectedContact.friend_username] message:conyentString isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
            if (sureBlock) {
                if (![ClearManager getNetStatus]) {
                    [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
                    return ;
                }
                [SVProgressHUD show];
                //发送消息
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                NSInteger time = interval;
                NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                //当增加转发图片功能 这里需要修改
                if (self.forwardUUMessageFrame.message.type == UUMessageTypeText) {
                    [self sendGroupMesageFrom:[NFUserEntity shareInstance].userName To:selectedContact Content:conyentString Createtime:createTime AndType:self.contentType];
                }else if (self.forwardUUMessageFrame.message.type == UUMessageTypePicture){
                    [self sendGroupPictureMesageFrom:[NFUserEntity shareInstance].userName To:selectedContact Content:conyentString Createtime:createTime AndType:self.contentType];
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
    
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//    GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
    NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
    NSArray *temp = _data[index];
    ZJContact *contact = (ZJContact *)temp[indexPath.row];
    //和某某人的聊天。根据获取到的联系人数组
//    toCtrol.titleName = contact.groupName;
//    toCtrol.groupId = contact.groupId;
    //从数据中获取到联系人数组实体
//    toCtrol.memberArr = memberArr;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *groupArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        groupArr = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@"where groupId = '%@'",contact.groupId]];
    }];
    GroupCreateSuccessEntity *groupDetailEntity = [GroupCreateSuccessEntity new];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
    if (groupArr.count > 0) {
        groupDetailEntity = [groupArr firstObject];
    }
    toCtrol.conversationId = contact.groupId;
    if (groupDetailEntity.groupId.length > 0) {
        toCtrol.groupCreateSEntity = groupDetailEntity;
        if (groupDetailEntity.groupHeadPic.length == 0) {
            toCtrol.groupCreateSEntity.groupHeadPic = contact.iconUrl;
        }
        toCtrol.groupName = groupDetailEntity.groupName;
    }else{
        //当没有详情缓存时候 手动取需要的参数
        groupDetailEntity.groupId = contact.groupId;
        groupDetailEntity.groupName = contact.groupName;
        toCtrol.groupName = contact.groupName;
        toCtrol.groupCreateSEntity = groupDetailEntity;
        toCtrol.groupCreateSEntity.groupHeadPic = contact.iconUrl;
        
    }
    
    //根据群租两个参数 设置群租会话未读为0
    [[FMDBService new] ConversationListUnReadSetZeroWithGroupId:contact.groupId AndGroupName:contact.groupName];
    
    [self.navigationController pushViewController:toCtrol animated:YES];
    
}

#pragma mark - 转发文本消息 给群聊
- (void)sendGroupMesageFrom:(NSString *)from To:(ZJContact *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    
    NSString *AppMessageId =  [ClearManager getAPPMsgId];
    //发送之前先缓存
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":content,type:type,@"userName":from,@"userNickName":[NFUserEntity shareInstance].nickName};
    
    [self addSpecifiedItem:dic];//先进行缓存
    
    
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    //当增加转发图片功能 这里需要修改
    if ([type isEqualToString:@"0"]) {
        newsDic[@"msgType"] = @"normal";
        newsDic[@"msgContent"] = content;
    }
    newsDic[@"userName"] = from;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"groupId"] = to.groupId;
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

#pragma mark - 转发图片消息 给群聊
- (void)sendGroupPictureMesageFrom:(NSString *)from To:(ZJContact *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    //发送图片之前先缓存
    
    NSString *AppMessageId =  [ClearManager getAPPMsgId];
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"nickName":[NFUserEntity shareInstance].nickName,@"imgRatio":[NSString stringWithFormat:@"%.2f",self.forwardUUMessageFrame.message.pictureScale]};
    [self addSpecifiedItem:dic];
    
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"image";
    newsDic[@"userName"] = [NFUserEntity shareInstance].userName;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"groupId"] = to.groupId;
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
    newsDic[@"fileInfo"] = @{@"fileId":self.forwardUUMessageFrame.message.fileId?self.forwardUUMessageFrame.message.fileId:@""};
    
    NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
    if (socketModel.isConnected) {
        [socketModel sendMsg:JsonStr];
    }
}



#pragma mark - 根据会话列表两个参数将未读设置为0
//-(void)ConversationListUnReadSetZeroWithGroupId:(NSString *)groupId AndGroupName:(NSString *)groupName{
//}

// sectionHeader
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"";
//    NSInteger index = [_sectionIndexs[section] integerValue];
//    return _allIndexTitles[index];
//}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor colorSectionHeader];
    NSInteger index = [_sectionIndexs[section] integerValue];
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

// 这个方法是返回索引的数组, 我们需要根据之前获取到的两个数组来取到我们需要的
//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    NSMutableArray *indexTitles = [NSMutableArray arrayWithCapacity:_sectionIndexs.count];
//    // 遍历索引的下标数组, 然后根据下标取出_allIndexTitles对应的索引字符串
//    for (NSNumber *number in _sectionIndexs) {
//        NSInteger index = number.integerValue;
//        [indexTitles addObject:_allIndexTitles[index]];
//    }
//    return indexTitles;
//}

// 可以相应点击的某个索引, 也可以为索引指定其对应的特定的section, 默认是 section == index
// 返回点击索引列表上的索引时tableView应该滚动到那一个section去
// 这里我们的tableView的section和索引的个数相同, 所以直接返回索引的index即可
// 如果不相同, 则需要自己相应的返回自己需要的section
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    NSLog(@"%@---%ld", title, index);
//    // 显示正在点击的indexTitle ZJProgressHUD这个小框架是我们已经实现的
//    [ZJProgressHUD showStatus:title andAutoHideAfterTime:0.5];
//    return index;
//}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fromType) {
        return NO;
    }
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle ==UITableViewCellEditingStyleDelete){
//        [SVProgressHUD show];
        NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
        // 删除
        [self removeContact:contact];
        //删除后 判断该index
        NSArray *tempp = _data[index];
        if (tempp.count == 0) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [self.tableView   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationAutomatic]; 
        }
        //    [self.tableView   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
        // 刷新 当然数据比较大的时候可能就需要只刷新删除的对应的section了
        //日后在网络请求成功中dismiss
//        [self createDispatchWithDelay:1 block:^{
//            [SVProgressHUD dismiss];
//        }];
        
        [tableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除群组";
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.searchBar) {
//        self.tabBarController.tabBar.hidden = YES;
        self.navigationController.navigationBar.translucent = YES;
        if (@available(iOS 13.0, *)) {
            self.searchController.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:self.searchController animated:YES completion:nil];
        return NO;
    }
    return YES;
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == _searchController.searchBar) {
        ZJSearchResultController *resultController = (ZJSearchResultController *)_searchController.searchResultsController;
        // 更新数据 并且刷新数据
        resultController.data = [ZJContact searchText:searchText inDataArray:self.allData];
        //选中后回调
        [resultController SelectContantJumpBlock:^(ZJContact *contant) {
            //跳转前移除搜索界面
            self.searchController.searchBar.text = @"";
            [self dismissViewControllerAnimated:NO completion:nil];
            selectedContact = contant;
            if (self.fromType){
                __block NSString *conyentString = [NSString new];
                if ([self.contentType isEqualToString:@"0"]) {
                    conyentString = self.forwardContent;
                }else if ([self.contentType isEqualToString:@"1"]){
                    conyentString = @"图片";
                }else if ([self.contentType isEqualToString:@"2"]){
                    conyentString = @"语音";
                }
                
                PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:[NSString stringWithFormat:@"发送给:%@",selectedContact.friend_username] message:conyentString isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
                    if (sureBlock) {
                        
                        if (![ClearManager getNetStatus]) {
                            [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
                            return ;
                        }
                        [SVProgressHUD show];
                        //发送消息
                        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                        NSInteger time = interval;
                        NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                        //当增加转发图片功能 这里需要修改
                        [self sendGroupMesageFrom:[NFUserEntity shareInstance].userName To:selectedContact Content:conyentString Createtime:createTime AndType:self.contentType];
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
            
            //进行跳转传值
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//            MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
//            //和某某人的聊天 根据获取到的联系人数组
//            toCtrol.titleName = contant.friend_username;
//            toCtrol.chatType = @"1";
//            toCtrol.conversationId = contant.friend_userid;
//            //从数据中获取到联系人数组实体
//            //    toCtrol.memberArr = memberArr;
//            [self.navigationController pushViewController:toCtrol animated:YES];
            
            
            
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *groupArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                groupArr = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@"where groupId = '%@'",contant.groupId]];
            }];
            
            GroupCreateSuccessEntity *groupDetailEntity = [GroupCreateSuccessEntity new];
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
            if (groupArr.count > 0) {
                groupDetailEntity = [groupArr firstObject];
            }
            toCtrol.conversationId = contant.groupId;
            if (groupDetailEntity.groupId.length > 0) {
                toCtrol.groupCreateSEntity = groupDetailEntity;
                if (groupDetailEntity.groupHeadPic.length == 0) {
                    toCtrol.groupCreateSEntity.groupHeadPic = contant.iconUrl;
                }
                toCtrol.groupName = groupDetailEntity.groupName;
            }else{
                //当没有详情缓存时候 手动取需要的参数
                groupDetailEntity.groupId = contant.groupId;
                groupDetailEntity.groupName = contant.groupName;
                toCtrol.groupName = contant.groupName;
                toCtrol.groupCreateSEntity = groupDetailEntity;
                toCtrol.groupCreateSEntity.groupHeadPic = contant.iconUrl;
                
            }
            
            //根据群租两个参数 设置群租会话未读为0
            [[FMDBService new] ConversationListUnReadSetZeroWithGroupId:contant.groupId AndGroupName:contant.groupName];
            
            [self.navigationController pushViewController:toCtrol animated:YES];
            
            
            
            
        }];
    }
}


// 这个方法在searchController 出现, 消失, 以及searchBar的text改变的时候都会被调用
// 我们只是需要在searchBar的text改变的时候才查询数据, 所以没有使用这个代理方法, 而是使用了searchBar的代理方法来处理
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //    NSLog(@"%@", searchController.searchBar.text);
    //    ZJSearchResultController *resultController = (ZJSearchResultController *)searchController.searchResultsController;
    //    resultController.data = [ZJContact searchText:searchController.searchBar.text inDataArray:_allData];
    //    [resultController.tableView reloadData];
    
}

// 这个代理方法在searchController消失的时候调用, 这里我们只是移除了searchController, 当然你可以进行其他的操作
- (void)didDismissSearchController:(UISearchController *)searchController {
    // 销毁
    self.searchController = nil;
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
        
        id Field;
        if (@available(iOS 13.0, *)) {
            Field =searchController.searchBar.searchTextField;
        }else{
            Field = [searchController.searchBar valueForKey:@"_searchField"];
        }
        UITextField *searchControllerSearchField;
        if (@available(iOS 13.0, *)) {
            searchControllerSearchField = self.searchBar.searchTextField;
        }else{
            if ([Field isKindOfClass:[UITextField class]]) {
                searchControllerSearchField = [searchController.searchBar valueForKey:@"_searchField"];
                [searchControllerSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
                [searchControllerSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
            }
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
        searchBar.placeholder = @"搜索联系人姓名/首字母缩写";
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
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}

#pragma mark - 下拉刷新委托回调

//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
#pragma mark - 下拉刷新6
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self doneLoadingTableViewData];
    });
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
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}


#pragma mark - 发送消息后展示、缓存 【只能是单聊】
- (void)addSpecifiedItem:(NSDictionary *)dic
{
    //记录刷新会话列表
    
//    [self.fmdbServicee cacheChatListWithZJContact:contant AndDic:dic];
    
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    //头像
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    URLStr = @"";
    [dataDic setObject:@"1" forKey:@"from"];
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
    //先看看吗有没有该群的会话 没有则需要创建
    __block NSArray *IsExistConversationArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        IsExistConversationArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",@"conversationId",strongSelf ->selectedContact.groupId,@"IsSingleChat",@"0"]];
    }];
    if (IsExistConversationArr.count == 0) {
        //如果没有 则创建改会话
        MessageChatListEntity *entity = [MessageChatListEntity new];
        entity.IsUpSet = NO;
        entity.IsSingleChat = NO;
        entity.conversationId = selectedContact.groupId;
        entity.last_send_time = [NFMyManage getCurrentTimeStamp];
        if (message.type == UUMessageTypeText) {
            entity.last_send_message = message.strContent;
        }else if (message.type == UUMessageTypePicture){
            entity.last_send_message = @"[图片]";
        }
//        else if (message.type == UUMessageTypeVoice){
//            entity.last_send_message = @"[语音]";
//        }
        entity.last_message_id = message.chatId;
        entity.headPicpath = selectedContact.iconUrl;
        
        entity.unread_message_count = @"0";
        NSString *updateTime = message.localReceiveTimeString;
        entity.update_time = [NFMyManage timestampSwitchTime:[updateTime integerValue]];
        entity.originTimeString = message.localReceiveTimeString;
        entity.last_send_time = message.localReceiveTimeString;
        NSString *groupname = [NSString stringWithFormat:@""];
        entity.receive_user_name = selectedContact.groupName;//设置群组receive_user_name
        entity.nickName = selectedContact.groupName;//设置群组receive_user_name 群组nickname和name一样
        __block BOOL ret = NO;
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            ret = [strongSelf ->jqFmdb jq_insertTable:@"huihualiebiao" dicOrModel:entity];
        }];
    }
    [self.fmdbServicee IsExistGroupChatHistory:[NSString stringWithFormat:@"qunzu%@",selectedContact.groupId] ISNeedAppend:NO];
    
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    entity.IsSingleChat = YES;
    entity.appMsgId = messageFrame.message.appMsgId;//客户端本地数据库 缓存id【用于取服务器返回的chatid】
    
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",strongSelf ->selectedContact.groupId]];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",strongSelf ->selectedContact.groupId] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
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
        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",strongSelf ->selectedContact.groupId] dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            return;
        }
    }];
    
}


static NSString *previousTime = nil;



//懒加载 fmdbServicee
-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
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
