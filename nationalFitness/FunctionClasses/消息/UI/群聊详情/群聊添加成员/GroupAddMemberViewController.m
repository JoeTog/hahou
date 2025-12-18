//
//  GroupAddMemberViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupAddMemberViewController.h"
#import "ZJContact.h"
#import "ZJSearchResultController.h"
#import "ZJProgressHUD.h"
#import "ContantTableViewCell.h"
#import "MessageChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "JQFMDB.h"

@interface GroupAddMemberViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate,EGORefreshTableHeaderDelegate,ChatHandlerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray<ZJContact *> *allData;
@property (nonatomic,strong)AppDelegate *appdelegate;
//群组实体
@property (strong, nonatomic) GroupCreateSuccessEntity *chatCreateSuccessEntity;


@end

@implementation GroupAddMemberViewController{
    
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
    NSMutableArray *allContantArr;
    //记录选中的联系人
    NSMutableArray *selectedMemberArr;
    
    JQFMDB *jqFmdb;
    
    UIButton *backBtn;
    //如果转发给n个人 记录转发的index【当接收到上一个发送消息的回调，再进行下次发送】根据这里的index取contact值进行缓存
    NSInteger sendForwardIndex;
    
    //记录已经存过 最大的section
    NSInteger maxSection;
    //记录已经存过 最大的row
    NSInteger maxRow;
    
    //是否需要+1，当删除人的时候 只有14个数据，因为剔除了群主
    NSInteger addCount;
    
}

static CGFloat const kSearchBarHeight = 40.f;

//设置navigationController 基点从下面左上角算起
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
//    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.SourceType == SourceTypeFromGroupChatAdd ) {
        self.title = @"添加成员";
    }else if (self.SourceType == SourceTypeFromSingleChat){
        self.title = @"新建群聊";
    }else if (self.SourceType == SourceTypeFromGroupCreate){
        self.title = @"新建群聊";
    }else if (self.SourceType == SourceTypeFromChatListRight){
        self.title = @"新建聊天";
    }else if (self.SourceType == SourceTypeFromGroupChatReduce){
        self.title = @"删除群成员";
        
    }else if (self.SourceType == SourceTypeFromGroupChatAite){
        self.title = @"选择提醒的人";
    }else if (self.SourceType == SourceTypeFromRecommendCard){
        self.title = @"选择朋友";
    }
    
    if (self.fromType) {
        self.title = @"选择联系人";
    }
    
    [self initUI];
    //    [self initDataSource];
    [self initScoket];
    
    //
    addCount = 0;
    if(self.IsNeedLoadMore){
        canRefreshLash_ = YES;
        if(self.alreadlyExistMemberArr .count < 15){
            addCount = 1;
        }
    }
    
    
}

-(void)initScoket{
    //取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    //当为群组删除成员 则
    if (self.SourceType == SourceTypeFromGroupChatReduce || self.SourceType == SourceTypeFromGroupChatAite) {
        if (self.alreadlyExistMemberArr.count > 0) {
            self.allData = [NSArray arrayWithArray:self.alreadlyExistMemberArr];
            [self setupInitialAllDataArrayWithContacts:self.allData];
            [self.tableView reloadData];
        }
        return;
    }
    
    //其他情况 为拉人、建群 从缓存取数据
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    //展示缓存
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:10];
    for (ZJContact *contact in arrs) {
        //        ZJContact *contact = [ZJContact new];
        //        if (![[NFUserEntity shareInstance].userId isEqualToString:friendEntity.user_id] || YES) {
        //            contact.friend_userid = friendEntity.friend_userid;
        //            contact.friend_username = friendEntity.friend_username;
        //            contact.iconUrl = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
        //        }
        //记录联系人是否可点 默认可点
        BOOL isCanSelect = YES;
        //判断是否有数组
        if (self.alreadlyExistMemberArr.count > 0 && self.SourceType != SourceTypeFromGroupChatReduce && self.SourceType != SourceTypeFromGroupChatAite) {
            for (ZJContact *existContact in self.alreadlyExistMemberArr) {
                if ([contact.friend_userid isEqualToString:existContact.friend_userid]) {
                    //只要有一次就修改为no
                    isCanSelect = NO;
                    break;
                }
            }
        }
        //最后判断是否能选
        if (isCanSelect) {
            contact.IsCanSelect = YES;
            if(![contact.friend_username isEqualToString:@"duoxinkefu"]){
                [contacts addObject:contact];
            }
        }else{
            contact.IsCanSelect = NO;
            if(![contact.friend_username isEqualToString:@"duoxinkefu"]){
                [contacts addObject:contact];
            }
        }
    }
    //判断联系人是否有
    if (contacts.count > 0) {
        self.allData = [NSArray arrayWithArray:contacts];
        [self setupInitialAllDataArrayWithContacts:contacts];
        [self.tableView reloadData];
    }else{
        //没有就请求
        [socketRequest getFriendList];
    }
}

-(void)loadMoreMember{
    
    NSString *page = [NSString stringWithFormat:@"%@",@(self.alreadlyExistMemberArr.count / 15 + 1 + addCount)];
    NSString *pagesize = [NSString stringWithFormat:@"15"];
    [socketRequest getGroupDetail:self.groupCreateSEntity.groupId AndPage:page];
    
    
}


#pragma mark - 代码块传出选中的人
-(void)finishAddMemberAndReturnL:(FinishAddMember)addmember{
    if (self.adddMember != addmember) {
        self.adddMember = addmember;
    }
}

#pragma mark - 删除成员成功 传出代码块
-(void)reduceMemberSuccess:(ReduceMemberSuccess )reducemember{
    if (self.redeceMember != reducemember) {
        self.redeceMember = reducemember;
    }
}


#pragma mark - 创建群组请求
-(void)createGroupRequest:(NSArray *)memberArr{
    if ([SVProgressHUD isVisible]) {
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"请勿重复操作!"];
        return;
    }
    [socketRequest createGroupRequest:memberArr GroupCreateSuccessEntity:self.groupCreateSEntity];
    
}



#pragma mark - 设置群组头像信息

#pragma mark - 群主踢人

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_groupCreateSuccess){
        [SVProgressHUD dismiss];
        self.chatCreateSuccessEntity = chatModel;//用于头像上传成功 进行跳转
        
        //设置群头像成功 更改会话群组头像缓存
        //头像上传成功 跳转到群聊 缓存更改群聊头像url
        //创建群组成功
        //        NSArray *ardrr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
        //数组详情缓存到数据库表 cacheChatList
        //点击详情再缓存
        //        [self.fmdbServicee cacheGroupDetail:self.chatCreateSuccessEntity];
        //        [self.fmdbServicee cacheChatGroupCreateList:self.chatCreateSuccessEntity];
        
        //        NSArray *groupArrr = [jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@""];
        
        //设置头像成功 更改群聊会话头像缓存
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *chatList = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            chatList = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where conversationId = '%@' and IsSingleChat = '%@'",strongSelf.chatCreateSuccessEntity.groupId,@"0"];
        }];
        MessageChatListEntity *entity = [chatList lastObject];
        if ([self.chatCreateSuccessEntity.groupHeadPic containsString:@"http"]) {
           entity.headPicpath = self.chatCreateSuccessEntity.groupHeadPic;
        }else{
            entity.headPicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,self.chatCreateSuccessEntity.groupHeadPic];
        }
        
        [[NFMyManage new] changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:self.chatCreateSuccessEntity.groupId FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"0" TableName:@"huihualiebiao"];
        
        //        NSArray *bbb = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
        
        //设置刷新本地会话列表
        [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
        //选中完 跳转到聊天
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        if (self.chatCreateSuccessEntity.groupId) {
            toCtrol.memberArr = self.chatCreateSuccessEntity.groupAllUser;
            toCtrol.groupCreateSEntity = self.chatCreateSuccessEntity;
        }else{
            toCtrol.memberArr = self.groupCreateSEntity.groupAllUser;
            toCtrol.groupCreateSEntity = self.groupCreateSEntity;
        }
        
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }else if (messageType == SecretLetterType_GroupAddMemberSuccess){
        //拉人成功
        GroupCreateSuccessEntity *entity = chatModel;
        //先更新上传头像
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        toCtrol.memberArr = self.chatCreateSuccessEntity.groupAllUser;
        toCtrol.groupCreateSEntity = self.groupCreateSEntity;//这里也可以使用 返回的entity
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }else if (messageType == SecretLetterType_FriendList){
        [self.fmdbServicee IsExistLianxirenLieBiao];
        
//        BOOL deleteRet = [jqFmdb jq_deleteAllDataFromTable:@"lianxirenliebiao"];
        NSArray *friendArr = chatModel;
        NSMutableArray *arrs = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:10];
        for (ZJContact *friendEntity in friendArr) {
            //如果联系人名 和自己名字不一样
            if (![friendEntity.friend_userid isEqualToString:[NFUserEntity shareInstance].userId] && ![friendEntity.friend_username isEqualToString:@"duoxinkefu"]) {
                [arrs addObject:friendEntity];
            }
        }
        for (ZJContact *contact in arrs) {
            //        ZJContact *contact = [ZJContact new];
            //        if (![[NFUserEntity shareInstance].userId isEqualToString:friendEntity.user_id] || YES) {
            //            contact.friend_userid = friendEntity.friend_userid;
            //            contact.friend_username = friendEntity.friend_username;
            //            contact.iconUrl = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
            //        }
            //记录联系人是否可点 默认可点
            BOOL isCanSelect = YES;
            //判断是否有数组
            if (self.alreadlyExistMemberArr.count > 0) {
                for (ZJContact *existContact in self.alreadlyExistMemberArr) {
                    if ([contact.friend_userid isEqualToString:existContact.friend_userid]) {
                        //只要有一次就修改为no
                        isCanSelect = NO;
                    }
                }
            }
            //最后判断是否能选
            if (isCanSelect) {
                contact.IsCanSelect = YES;
                [contacts addObject:contact];
            }else{
                contact.IsCanSelect = NO;
                [contacts addObject:contact];
            }
        }
        self.allData = [NSArray arrayWithArray:contacts];
        [self setupInitialAllDataArrayWithContacts:contacts];
        [self.tableView reloadData];
    }else if (messageType == SecretLetterType_GroupCreateRepeat){
        self.chatCreateSuccessEntity = chatModel;
        //选中完 跳转到聊天
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        toCtrol.groupCreateSEntity = self.chatCreateSuccessEntity;
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }else if (messageType == SecretLetterType_NormalReceipt){
        if (self.fromType) {
            //进行缓存 【收到4001发送成功 才进行缓存】
            //如果没有self.forwardContent 说明存在咯ing太台设备同时登陆，return 避免崩溃
            if ([chatModel isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = chatModel;
                if (!self.forwardContent) {
                    return;
                }
                //统一回去都刷新
                [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
                //当转发完最后一个人 return
                if (sendForwardIndex >= selectedMemberArr.count-1) {
                    //在选中的数组中找 是J否有正在聊天的单人 有则需要在pop回去后刷新聊天
                    for (ZJContact *contact in selectedMemberArr) {
                        if ([contact.friend_username isEqualToString:self.chatingName]) {
                            [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
                            break;
                        }
                    }
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                    __weak typeof(self)weakSelf=self;
                    [self createDispatchWithDelay:1 block:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        UIViewController * viewVC = [strongSelf.navigationController.viewControllers objectAtIndex:1];
                        [strongSelf.navigationController popToViewController:viewVC animated:YES];
                    }];
                    return;
                }
                sendForwardIndex ++;
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                NSInteger time = interval;
                NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                __block NSString *conyentString = [NSString new];
                if ([self.contentType isEqualToString:@"0"]) {
                    conyentString = self.forwardContent;
                }else if ([self.contentType isEqualToString:@"1"]){
                    conyentString = @"图片";
                }else if ([self.contentType isEqualToString:@"2"]){
                    conyentString = @"语音";
                }
                if (self.forwardUUMessageFrame.message.type == UUMessageTypeText) {
                    //发送文字消息给单聊
                    [self sendMesageFrom:[NFUserEntity shareInstance].userName To:selectedMemberArr[sendForwardIndex] Content:conyentString Createtime:createTime AndType:self.contentType];
                }else if (self.forwardUUMessageFrame.message.type == UUMessageTypePicture){
                    //发送图片消息给单聊
                    [self sendPictureMesageFrom:[NFUserEntity shareInstance].userName To:selectedMemberArr[sendForwardIndex] Content:@"图片" Createtime:createTime AndType:self.contentType];
                }
                
            }
        }else if(self.SourceType == SourceTypeFromRecommendCard || self.SourceType == SourceTypeFromRecommendGroupCard){
            NSDictionary *dict = chatModel;
            if([[dict objectForKey:@"messageContent"] isKindOfClass:[NSDictionary class]]){
                [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }else if (messageType == SecretLetterType_GroupSetPersonalInfo){
        //暂未用
    }else if (messageType == SecretLetterType_GroupDropSuccess){
        //成功后 通知刷新详情
        self.redeceMember(YES);
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(messageType == SecretLetterType_yanzheng){
        
        [SVProgressHUD showInfoWithStatus:@"已提交管理员审核"];
        
        __weak typeof(self)weakSelf=self;
        [self createDispatchWithDelay:1 block:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            UIViewController * viewVC = [strongSelf.navigationController.viewControllers objectAtIndex:1];
            [strongSelf.navigationController popToViewController:viewVC animated:YES];
        }];
        
    }else if (messageType == SecretLetterType_ReceiveGroupMessage){
        //群聊消息发送回执 这里为转发后的回调 5003
        if (self.SourceType == SourceTypeFromRecommendGroupCard) {
            //            self.tabBarController.tabBar.hidden = NO;
            
            [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if(messageType == SecretLetterType_GroupDetail){
        [SVProgressHUD dismiss];
        GroupCreateSuccessEntity *entity = chatModel;
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.alreadlyExistMemberArr];
        if ([entity.groupAllUser count] == 15)
        {
            canRefreshLash_ = YES;
        }
        else
        {
            canRefreshLash_ = NO;
        }
        
        [arr addObjectsFromArray:entity.groupAllUser];
        self.alreadlyExistMemberArr = [NSArray arrayWithArray:arr];
        if (self.alreadlyExistMemberArr.count > 15) {
            addCount = 0;
        }
        self.allData = [NSArray arrayWithArray:self.alreadlyExistMemberArr];
        [self setupInitialAllDataArrayWithContacts:self.allData];
        [self.tableView reloadData];
    }
    
}




//-(void)headPicPathUpLoad:(UIImage *)image{
//    [SVProgressHUD show];
//    //上传头像
//    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
//    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
//    //    imageData = UIImagePNGRepresentation(image);
//    
//    NSString *type = [LoginManager typeForImageData:imageData];
//    [sendDic setObject:type forKey:@"imgaeType"];
//    [LoginManager execute:@selector(changeHeadPicpathManager) target:self callback:@selector(changeHeadPicpathManagerCallBack:) args:sendDic,imageData,nil];
//}
//
//- (void)changeHeadPicpathManagerCallBack:(id)data
//{
//    if (data)
//    {
//        if ([data objectForKey:@"error"]) {
//            [SVProgressHUD showInfoWithStatus:[data objectForKey:@"error"]];
//            return;
//        }else{
//            
//            //图片上传成功 设置群组头像信息
//            [socketRequest setGroupInfoWithDict:@{@"photo":[data objectForKey:@"filePath"]} WithGroupId:self.groupCreateSEntity.groupId?self.groupCreateSEntity.groupId:[self.chatCreateSuccessEntity.groupId description]];
//            
//        }
//    }
//    else
//    {
//        [SVProgressHUD showInfoWithStatus:@"上传失败"];
//    }
//}



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

-(GroupCreateSuccessEntity *)chatCreateSuccessEntity{
    if (!_chatCreateSuccessEntity) {
        _chatCreateSuccessEntity = [[GroupCreateSuccessEntity alloc] init];
    }
    return _chatCreateSuccessEntity;
}

#pragma mark - 请求好友列表


#pragma mark - 取缓存 @{@"status":1001,@"result":@{@"7f0000010b560000000c":@[],@"7f0000010b560000000d":@[]}} data 为result为key的字典
-(NSDictionary *)getFMDBDataWithCacheName{
    // @{@"rootDict":@[@{@"contant":text}]}
    NSString *dataStr = [NFDatabaseQueue selectManagerCache:[NFUserEntity shareInstance].contantList];
    NSData *strData = [NFPacketHandler hexStringToNSData:dataStr];
    //解密
    //    strData = [strData AES256DecryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,[SystemInfo shareSystemInfo].deviceId] keyEncoding:NSUTF8StringEncoding];
    NSString *aStr = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *parserDict = [parser objectWithString:aStr];
    
    return parserDict;
}

#pragma mark - 初始化界面
-(void)initUI{
    selectedMemberArr = [NSMutableArray new];
    allContantArr = [NSMutableArray new];
    backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 34)];
    //    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    backBtn.enabled = NO;
    [backBtn setTitle:@"完成" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [backBtn setTitleColor:UIColorFromRGB(0xaa9c9c) forState:(UIControlStateDisabled)];
    [backBtn addTarget:self action:@selector(addTeamClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    self.navigationItem.rightBarButtonItem = backButtonItem;
    
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
    
    txfSearchField.backgroundColor = [UIColor colorTextfieldBackground];
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
    
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - 完成添加按钮
-(void)addTeamClick:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
    //当为群组添加成员时 必须需要选人 判断是否已选联系人
//    if (selectedMemberArr.count == 0 && self.SourceType == 1) {
//        [SVProgressHUD showInfoWithStatus:@"请选择联系人"];
//        return;
//    }
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    if (selectedMemberArr.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"请选择联系人"];
        return;
    }
    if (self.fromType) {
        //来自转发
        //群发给单人 下面需要在didreceive中做
        __block NSString *conyentString = [NSString new];
        if ([self.contentType isEqualToString:@"0"]) {
            conyentString = self.forwardContent;
        }else if ([self.contentType isEqualToString:@"1"]){
            conyentString = @"图片";
        }else if ([self.contentType isEqualToString:@"2"]){
            conyentString = @"语音";
        }
        NSMutableString *receiveMemberName = [NSMutableString new];
        for (ZJContact *contact in selectedMemberArr) {
            [receiveMemberName appendString:[NSString stringWithFormat:@"%@、",contact.friend_username]];
        }
        PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:[NSString stringWithFormat:@"发送给:%@",receiveMemberName] message:conyentString isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
            if (sureBlock) {
                if (![ClearManager getNetStatus]) {
                    [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
                    return ;
                }
                [SVProgressHUD show];
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                NSInteger time = interval;
                NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                sendForwardIndex = 0;
                //当增加转发图片功能 这里需要修改 UUMessageTypeText UUMessageTypePicture
                if (self.forwardUUMessageFrame.message.type == UUMessageTypeText) {
                    [self sendMesageFrom:[NFUserEntity shareInstance].userName To:selectedMemberArr[0] Content:conyentString Createtime:createTime AndType:self.contentType];
                }else if (self.forwardUUMessageFrame.message.type == UUMessageTypePicture){
                    [self sendPictureMesageFrom:[NFUserEntity shareInstance].userName To:selectedMemberArr[0] Content:@"图片" Createtime:createTime AndType:self.contentType];
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
    
    if (self.SourceType == SourceTypeFromGroupChatAite) {
        self.adddMember(selectedMemberArr);
        __weak typeof(self)weakSelf=self;
        [self createDispatchWithDelay:0.3 block:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            UIViewController * viewVC = [strongSelf.navigationController.viewControllers objectAtIndex:1];
            [strongSelf.navigationController popToViewController:viewVC animated:YES];
        }];
        return;
    }
    
    //点击完成 久不能退回上一次的聊天了 所以不需要再刷新
    [NFUserEntity shareInstance].isNeedRefreshChatData = NO;
    
    if (self.SourceType == SourceTypeFromGroupChatReduce) {
        //来自删除群成员
        //删除群成员请求
        if (selectedMemberArr.count == 0) {
            [SVProgressHUD showInfoWithStatus:@"请选择被踢对象"];
            return;
        }
        NSString *ShowString ;
        ZJContact *WillDeleteContact = [selectedMemberArr firstObject];
        if(selectedMemberArr.count == 1){
            ShowString = [NSString stringWithFormat:@"是否确认将 %@ 踢出群聊",WillDeleteContact.friend_comment_name&&WillDeleteContact.friend_comment_name.length>0?WillDeleteContact.friend_comment_name:WillDeleteContact.friend_nickname];
        }else{
            ShowString = [NSString stringWithFormat:@"是否确认将 %@ 等人踢出群聊",WillDeleteContact.friend_comment_name&&WillDeleteContact.friend_comment_name.length>0?WillDeleteContact.friend_comment_name:WillDeleteContact.friend_nickname];
        }
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:ShowString sureBtn:@"确认" cancleBtn:@"取消"];
        alertView.resultIndex = ^(NSInteger index)
        {
            if(index==2){
                ZJContact *contact = [selectedMemberArr firstObject];
                [SVProgressHUD show];
                [socketRequest groupOwnerOutMember:selectedMemberArr GroupId:self.groupCreateSEntity.groupId?self.groupCreateSEntity.groupId:self.existGroupId];
            }
        };
        [alertView showMKPAlertView];
        
        return;
    }
    
    //
    if (selectedMemberArr.count + self.alreadlyExistMemberArr.count == 1){
    //选一个人 默认进行单聊 但是当为创建群组时 都创建群聊
        if (self.SourceType == 0) {
            //当来自单聊add 则连单聊对象一起加入到建立群聊
            if (self.SourceType == SourceTypeFromSingleChat) {
                [selectedMemberArr addObjectsFromArray:self.alreadlyExistMemberArr];
            }
            [self createGroupRequest:selectedMemberArr];
        }
        //当新建聊天之友一个人 则为单聊【返回单聊对象】
        if (self.SourceType != 2) {
            self.adddMember(selectedMemberArr);
            return;
        }
    }
    //选中人数大于1 则进行群聊创建
    if (sender.enabled) {
        //进行创建群组请求
        //当从单聊过来时候 需要将单聊中哪个人一并添加到创建群聊
        if(self.alreadlyExistMemberArr.count + selectedMemberArr.count >= 1500){
            [SVProgressHUD showInfoWithStatus:@"群人数最多1500人"];
            return;
        }
        if (self.SourceType == SourceTypeFromSingleChat) {
            [selectedMemberArr addObjectsFromArray:self.alreadlyExistMemberArr];
        }
        [self createGroupRequest:selectedMemberArr];
        
    }
}

#pragma mark - 转发文本消息 给单聊 【如果有多个人 那么在4001中进行f循环发送】
- (void)sendMesageFrom:(NSString *)from To:(ZJContact *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    //发送之前先缓存
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":content,type:type,@"userName":from,@"userNickName":[NFUserEntity shareInstance].nickName};
//    for (ZJContact *contact in selectedMemberArr) {
        [self addSpecifiedItem:dic AndContact:to];//先进行缓存
//    }
    
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
    newsDic[@"toName"] = to.friend_username;
    newsDic[@"toId"] = to.friend_userid;
    newsDic[@"createTime"] = createtime;
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
    newsDic[@"action"] = @"sendMessage";
    newsDic[@"msgClient"] = @"app";
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
}


#pragma mark - 转发图片消息 给单聊
- (void)sendPictureMesageFrom:(NSString *)from To:(ZJContact *)to Content:(NSString *)content Createtime:(NSString *)createtime AndType:(NSString *)type
{
    //发送图片之前先缓存
    
    NSString *AppMessageId = [ClearManager getAPPMsgId];
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[图片J]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"imgRatio":[NSString stringWithFormat:@"%.2f",self.forwardUUMessageFrame.message.pictureScale]};
    [self addSpecifiedItem:dic AndContact:to];//先进行缓存
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"image";
    newsDic[@"fromName"] = [NFUserEntity shareInstance].userName;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"toName"] = to.friend_username;
    newsDic[@"toId"] = to.friend_userid;
    newsDic[@"content"] = @"[图片]";
    newsDic[@"contentType"] = @"1";
    newsDic[@"createTime"] = createtime;
    newsDic[@"action"] = @"sendMessage";
    newsDic[@"appMsgId"] = AppMessageId;//本地messageId
    newsDic[@"msgClient"] = @"app";
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
    newsDic[@"fileId"] = @{@"fileId":self.forwardUUMessageFrame.message.fileId};
    NSString *JsonStr = [JsonModel convertToJsonData:newsDic];
    if (socketModel.isConnected) {
        [socketModel sendMsg:JsonStr];
    }
}

#pragma mark - 发送名片消息 给单聊
- (void)sendCardToSingleChatWithContact:(ZJContact *)contact Createtime:(NSString *)createtime
{
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *AppMessageId = [NSString stringWithFormat:@"%@%@",dateString,[NFUserEntity shareInstance].userName];
    NSDictionary *dic = @{@"appMsgId":AppMessageId,@"chatId":@"",@"strContent":@"[名片消息]",@"type":self.contentType,@"userName":[NFUserEntity shareInstance].userName,@"userNickName":[NFUserEntity shareInstance].nickName,@"strId":contact.friend_userid,@"strVoiceTime":contact.friend_username,@"pictureUrl":contact.friend_nickname,@"fileId":contact.iconUrl,@"nickName":contact.friend_nickname};
    [self addSpecifiedItem:dic];//dic 中主要是是消息的发出者的
    NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
    newsDic[@"msgType"] = @"card";
    newsDic[@"fromName"] = [NFUserEntity shareInstance].userName;
    newsDic[@"fromId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"toName"] = self.chatContact.friend_username;
    newsDic[@"toId"]  = self.chatContact.friend_userid;
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
- (void)sendCardToGroupChatWithContact:(ZJContact *)contact Createtime:(NSString *)createtime
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
    newsDic[@"groupId"] = self.groupCreateSEntity.groupId;
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


//
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
        contact.IsSelect = NO;// 每次初始化数据 设置选中为NO
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
    
    NSInteger index = 0;
    for (int i=0; i<_data.count; i++) {
        NSArray *temp = _data[i];
        if (temp.count != 0) { // 取出不为空的部分对应的indexTitle
            [_sectionIndexs addObject:[NSNumber numberWithInt:i]];
        }
        // 排序每一个数组
        _data[i] = [localIndex sortedArrayFromArray:temp collationStringSelector:nameSelector];
        if(temp.count > 0){
            maxSection = index;
            maxRow = temp.count - 1;
            index ++;
        }
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

// 删除联系人
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
}

#pragma mark - tableview Delegate
//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.fromType) {
        return _sectionIndexs.count + 1;
    }
    return _sectionIndexs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.fromType) {
        if (section == 0) {
            return 1;
        }else{
            NSInteger index = [_sectionIndexs[section - 1] integerValue];
            NSArray *temp = _data[index];
            return temp.count;
        }
    }
    NSInteger index = [_sectionIndexs[section] integerValue];
    NSArray *temp = _data[index];
    
    return temp.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.fromType) {
        if (section == 0) {
            return 0.1;
        }
    }
    return 20.f;
}

//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if(self.SourceType == SourceTypeFromGroupChatReduce && canRefreshLash_ && maxSection == indexPath.section && maxRow == indexPath.row){
//        [SVProgressHUD showWithStatus:@"加载中"];
//        [self loadMoreMember];
//    }
    
    static NSString* cellIdentifier;
    if (self.fromType){ //来自转发
        if (indexPath.section == 0) {
            cellIdentifier = @"ContantTableViewCell";
            ContantTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ContantTableViewCell" owner:nil options:nil]firstObject];
            }
            cell.nameLabel.textColor = [UIColor colorMainTextColor];
            cell.nameLabel.text = @"群组";
            cell.headImageView.image = [UIImage imageNamed:@"我的群组"];
            return cell;
        }
        cellIdentifier = @"GroupAddMemberTableViewCell";
        GroupAddMemberTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupAddMemberTableViewCell" owner:nil options:nil]firstObject];
        }
        NSInteger index = [_sectionIndexs[indexPath.section - 1] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
        if (contact.friend_nickname.length > 0) {
            cell.nickNameLabel.text = contact.friend_nickname;
        }else{
            cell.nickNameLabel.text = contact.friend_username;
        }
//        if ([contact.iconUrl containsString:@"head_man"]) {
//            cell.headImageView.image = [UIImage imageNamed:contact.iconUrl];
//        }else{
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (cell.selectBtn.selected) {
            cell.selectBtn.selected = YES;
        }
        //如果为不可点 则设置为不可点
        if (!contact.IsCanSelect) {
            cell.selectBtn.enabled = NO;
        }
        //搜索点击后 这里需要作出标记 【这里为转发】
        if (contact.IsSelect) {
            cell.selectBtn.selected = YES;
        }
        return cell;
    }else if (self.SourceType == SourceTypeFromRecommendCard){
        cellIdentifier = @"GroupAddMemberTableViewCell";
        GroupAddMemberTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupAddMemberTableViewCell" owner:nil options:nil]firstObject];
        }
        NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
        if (contact.friend_nickname.length > 0) {
            cell.nickNameLabel.text = contact.friend_nickname;
        }else{
            cell.nickNameLabel.text = contact.friend_username;
        }
        //    if ([contact.iconUrl containsString:@"head_man"]) {
        //        cell.headImageView.image = [UIImage imageNamed:contact.iconUrl];
        //    }else{
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
        //    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectBtn.hidden = YES;
        return cell;
    }
    cellIdentifier = @"GroupAddMemberTableViewCell";
    GroupAddMemberTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupAddMemberTableViewCell" owner:nil options:nil]firstObject];
    }
        NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
    if (contact.friend_nickname.length > 0) {
        cell.nickNameLabel.text = contact.friend_nickname;
    }else{
        cell.nickNameLabel.text = contact.friend_username;
    }
//    if ([contact.iconUrl containsString:@"head_man"]) {
//        cell.headImageView.image = [UIImage imageNamed:contact.iconUrl];
//    }else{
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell.selectBtn.selected) {
        cell.selectBtn.selected = YES;
    }
    //如果为不可点 则设置为不可点
    if (!contact.IsCanSelect && self.SourceType != SourceTypeFromGroupChatReduce && self.SourceType != SourceTypeFromGroupChatAite) {
        cell.selectBtn.enabled = NO;
    }
    //搜索点击后 这里需要作出标记 //或为群主踢人 能够选中
    if (contact.IsSelect) {
        cell.selectBtn.selected = YES;
    }
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.fromType){
        if (indexPath.section == 0) {
            //选择群聊
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
            GroupListViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupListViewController"];
            toCtrol.fromType = YES;
            toCtrol.contentType = self.contentType;
            toCtrol.forwardContent = self.forwardContent;
            toCtrol.chatingName = self.chatingName;
            toCtrol.forwardUUMessageFrame = self.forwardUUMessageFrame;
            [self.navigationController pushViewController:toCtrol animated:YES];
            return;
        }
        //记录选中的
        GroupAddMemberTableViewCell *cell = (GroupAddMemberTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        //是否可点
        if (cell.selectBtn.enabled) {
            NSInteger index = [_sectionIndexs[indexPath.section - 1] integerValue];
            NSArray *temp = _data[index];
            ZJContact *contact = (ZJContact *)temp[indexPath.row];
            cell.selectBtn.selected = !cell.selectBtn.selected;
            if (cell.selectBtn.selected) {
                [selectedMemberArr addObject:contact];
                contact.IsSelect = YES;
            }else{
                [selectedMemberArr removeObject:contact];
                contact.IsSelect = NO;
            }
        }
    }else if (self.SourceType == SourceTypeFromRecommendCard || self.SourceType == SourceTypeFromRecommendGroupCard){
        NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
        NSArray *temp = _data[index];
        ZJContact *contact = (ZJContact *)temp[indexPath.row];
        NSString *receiveName = self.SourceType == SourceTypeFromRecommendCard?self.chatContact.friend_nickname:self.groupCreateSEntity.groupName;
        PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:[NSString stringWithFormat:@"发送给:%@",receiveName] message:[NSString stringWithFormat:@"[个人名片]:%@",contact.friend_nickname] isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
            if (sureBlock) {
                if (![ClearManager getNetStatus]) {
                    [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
                    return ;
                }
                [SVProgressHUD show];
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                NSInteger time = interval;
                NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                sendForwardIndex = 0;
                //当增加转发图片功能 这里需要修改 UUMessageTypeText UUMessageTypePicture
                
                if (self.SourceType == SourceTypeFromRecommendCard) {
                    //单聊发送名片
                    [self sendCardToSingleChatWithContact:contact Createtime:createTime];
                }else if (self.SourceType == SourceTypeFromRecommendGroupCard){
                    //群聊发送名片
                    [self sendCardToGroupChatWithContact:contact Createtime:createTime];
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
        
    }else{
        //记录选中的
        GroupAddMemberTableViewCell *cell = (GroupAddMemberTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        //是否可点
        if (cell.selectBtn.enabled) {
            NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
            NSArray *temp = _data[index];
            ZJContact *contact = (ZJContact *)temp[indexPath.row];
            cell.selectBtn.selected = !cell.selectBtn.selected;
            if (cell.selectBtn.selected) {
                [selectedMemberArr addObject:contact];
                            contact.IsSelect = YES;
            }else{
                [selectedMemberArr removeObject:contact];
                            contact.IsSelect = NO;
            }
        }
    }
}

// sectionHeader
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.fromType){
        if (section == 0) {
            return @"";
        }
        NSInteger index = [_sectionIndexs[section - 1] integerValue];
        return _allIndexTitles[index];
    }
    NSInteger index = [_sectionIndexs[section] integerValue];
    return _allIndexTitles[index];
}

//section头视图
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.fromType ){
        if (section == 0) {
            UIView *view = [UIView new];
            return view;
        }
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        headerView.backgroundColor = [UIColor colorSectionHeader];
        NSInteger index = [_sectionIndexs[section - 1] integerValue];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        titleLabel.text = _allIndexTitles[index];
        titleLabel.textColor = [UIColor colorMainTextColor];
        titleLabel.font = [UIFont fontSectionHeader];
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(headerView.mas_centerY);
            make.leading.mas_equalTo(headerView.mas_leading).offset(10);
        }];
        return headerView;
    }else{
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        headerView.backgroundColor = [UIColor colorSectionHeader];
        NSInteger index = [_sectionIndexs[section] integerValue];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        titleLabel.text = _allIndexTitles[index];
        titleLabel.textColor = [UIColor colorMainTextColor];
        titleLabel.font = [UIFont fontSectionHeader];
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(headerView.mas_centerY);
            make.leading.mas_equalTo(headerView.mas_leading).offset(10);
        }];
        return headerView;
    }
    
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
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSLog(@"%@---%ld", title, index);
    // 显示正在点击的indexTitle ZJProgressHUD这个小框架是我们已经实现的
    [ZJProgressHUD showStatus:title andAutoHideAfterTime:0.5];
    return index;
    
}


//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}
//
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger index = [_sectionIndexs[indexPath.section] integerValue];
//    NSArray *temp = _data[index];
//    ZJContact *contact = (ZJContact *)temp[indexPath.row];
//    // 删除
//    [self removeContact:contact];
//    // 刷新 当然数据比较大的时候可能就需要只刷新删除的对应的section了
//    [tableView reloadData];
//}

//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"删除联系人";
//}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.searchBar) {
        self.navigationController.navigationBar.translucent = YES;
//        [self presentViewController:self.searchController animated:YES completion:nil];
        if (@available(iOS 13.0, *)) {
            self.searchController.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:self.searchController animated:YES completion:^{
//            self.navigationController.navigationBar.translucent = NO;
//            [self loadViewIfNeeded]; //无用
        }];
        return NO;
    }
    return YES;
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == _searchController.searchBar) {
        ZJSearchResultController *resultController = (ZJSearchResultController *)_searchController.searchResultsController;
        // 更新数据 并且刷新数据
        resultController.data = [ZJContact searchText:searchText inDataArray:self.allData];
        [resultController SelectContantJumpBlock:^(ZJContact *contant) {
            //跳转前移除搜索界面
//            NSIndexPath *selectedIndex;
            self.searchController.searchBar.text = @"";
            [self dismissViewControllerAnimated:NO completion:nil];
            //逻辑记录选中联系人的section
            NSInteger sectionindex = 0;
            //将搜索道的联系人与数据数组里面的所有联系人比对 获取indexpath获取cell
            for (int i = 0; i<_data.count; i++) {
                NSArray *arr = _data[i];
//                if (arr.count > 0 && i != 0) {
//                    sectionindex++;
//                }
                if (arr.count > 0) {
                    sectionindex++;
                }
                for (int j = 0; j<arr.count; j++) {
                    ZJContact *contact = arr[j];
                    if ([contact.friend_userid isEqualToString:contant.friend_userid]) {
                        //由于section 从0开始 这里找到后需要-1
                        NSIndexPath *indexPath;
                        if (self.fromType) {
                            indexPath=[NSIndexPath indexPathForRow:j inSection:sectionindex];
                        }else{
                            indexPath=[NSIndexPath indexPathForRow:j inSection:sectionindex-1];
                        }
                        GroupAddMemberTableViewCell *cell = (GroupAddMemberTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                        //获取到cell后 判断是否允许点击【是否不是已经存在的群聊联系人，不是则修改】
                        if (cell.selectBtn.enabled) {
                            if (!cell.selectBtn.selected) {
                                cell.selectBtn.selected = YES;
                                [selectedMemberArr addObject:contant];
                            }
                        }else{
                            //到这里 可能是因为cell数量太多 需要手动进行设置
                            
                            [selectedMemberArr addObject:contant];
                            
                        }
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
UITextField *searchControllerSearchField;
        if (@available(iOS 13.0, *)) {
            searchControllerSearchField =searchController.searchBar.searchTextField;
        }else{
            if ([searchControllerSearchField isKindOfClass:[UITextField class]]) {
                searchControllerSearchField = [searchController.searchBar valueForKey:@"_searchField"];
                [searchControllerSearchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
                [searchControllerSearchField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
            }
        }
        
        searchControllerSearchField.textColor = [UIColor colorMainTextColor];
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

#pragma mark - 发送消息后展示、缓存 【只能是单聊】
- (void)addSpecifiedItem:(NSDictionary *)dic AndContact:(ZJContact *)contant
{
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
//    ZJContact *contant = [ZJContact new];
//    contant.friend_userid = selectedChatListEntity.conversationId;
//    contant.friend_username = selectedChatListEntity.receive_user_name;
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
    //检查会话是否存在
    [self.fmdbServicee IsExistSingleChatHistory:contant.friend_userid];
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    entity.IsSingleChat = YES;
    entity.appMsgId = messageFrame.message.appMsgId;//客户端本地数据库 缓存id【用于取服务器返回的chatid】
    __weak typeof(self)weakSelf=self;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
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


#pragma mark - 发送名片消息后展示、缓存 【只能是单聊】
- (void)addSpecifiedItem:(NSDictionary *)dic
{
    //
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    ZJContact *contant = [ZJContact new];
    contant.friend_userid = self.chatContact.friend_userid;
    contant.friend_username = self.chatContact.friend_username;
    contant.friend_nickname = self.chatContact.friend_nickname;
    contant.iconUrl = self.chatContact.iconUrl;
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
    contant.friend_nickname = self.groupCreateSEntity.groupName;
    contant.friend_username = self.groupCreateSEntity.groupName;
    contant.groupId = self.groupCreateSEntity.groupId;
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
    entity.IsSingleChat = NO;
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




static NSString *previousTime = nil;



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}



@end
