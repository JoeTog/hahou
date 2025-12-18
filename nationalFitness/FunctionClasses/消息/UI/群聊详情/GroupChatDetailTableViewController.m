//
//  GroupChatDetailTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupChatDetailTableViewController.h"
#import "NFHeadImageView.h"
#import "JQFMDB.h"


#import "PublishDynamicViewController.h"


#define qunDetail [NSString stringWithFormat:@"qunDetail%@",self.groupCreateSEntity.groupId]

@interface GroupChatDetailTableViewController ()<ChatHandlerDelegate,UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;


@end

@implementation GroupChatDetailTableViewController{
    
    IBOutlet UITableView *GroupChatDetailTableV;
    //群成员数
    __weak IBOutlet UILabel *groupMemberCount;
    //群聊名称
    __weak IBOutlet UILabel *groupNameLabel;
    //我的本群昵称
    __weak IBOutlet UILabel *mineNickNameLabel;
    //commit按钮
    __weak IBOutlet UIButton *dissolutionBtn;
    //消息免发扰按钮
    __weak IBOutlet UISwitch *messageNotDisturbSwitch;
    
    //保存群组
    __weak IBOutlet UISwitch *saveGroupSwitch;
    //顶置聊天
    __weak IBOutlet UISwitch *upSetChatSwitch;
    
    //禁言开关
    __weak IBOutlet UISwitch *forbidSwitch;
    
    //群隐私
    __weak IBOutlet UISwitch *groupSecretSwitch;
    //群验证
    __weak IBOutlet UISwitch *groupCheckSwitch;
    
    
    __weak IBOutlet UILabel *groupNoticeLabel;
    
    
    
    //记录选中的indexpath
    NSIndexPath *selectedIndexPath;
    //编辑名字后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    
    JQFMDB *jqFmdb;
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    //编辑中的类型【需要根据这个类型】
    EditType editingType;
    //是否需要刷新数据
    BOOL IsNeedRefresh;
    //请求全部群成员id的用途 为NO是添加群成员 为YES是查看全部群成员
    BOOL requesrAllmemberType;
    //功能和上面一样 但是是判断是否是 删除群成员按钮的
    BOOL requestAllmemberTypeIsReduce;
    
    //纠正添加没有缓存的群成员 已经缓存到了index，w到0后 可以跳转
    //NSInteger addedIndex;
    
    //需要请求的 成员的id数组
    NSArray *needAddUserIdArrQuanju;
    //需要请求的 所有人数量
    CGFloat needAddUserIdAllCount;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    //是否需要刷新详情
    if (IsNeedRefresh) {
        [self initSocket];
    }
    
    //设置navigationController no基点从下面左上角算起
    [[UINavigationBar appearance] setTranslucent:translucentBOOL];
    self.navigationController.navigationBar.translucent = translucentBOOL;
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    [self initColor];
    
    if (isFromEditName) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"群聊详情";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUi];
    
//    if (self.memberArr.count > 0) {
//        ZJContact *contact = [self.memberArr firstObject];
//        self.groupChatId = contact.chatId;
//    }
    needAddUserIdArrQuanju = [NSArray new];;
    //请求群聊联系人详情
    [self initSocket];
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *groupArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        groupArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.groupCreateSEntity.groupId,@"IsSingleChat",@"0",@"IsUpSet",@"1"]];
    }];
    if (groupArr.count > 0) {
        upSetChatSwitch.on = YES;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 30);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitle:@"充值" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(reChangeClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: button];
    //self.navigationItem.rightBarButtonItem = item;
    
    
}




//充值
-(void)reChangeClick{
    
    RPFMyWalletVC * wallet = [[RPFMyWalletVC alloc] init];
    wallet.groupId = @"";
    //RPFOpenPacketViewController * openVC = [[RPFOpenPacketViewController alloc] initWithNibName:@"RPFOpenPacketViewController" bundle:nil];
    
    [self.navigationController pushViewController:wallet animated:YES];
    
}

-(void)initSocket{
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    if (socketModel.isConnected) {
        [socketModel ping];
    }
    if (![ClearManager getNetStatus]) {
//        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        [self getDataFromFMDBData];
        return;
    }
    if (socketModel.isConnected) {
        [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
        //self.groupCreateSEntity = nil;//如果有网 则不取上一界面的数据展示 否则实时性太差了【某人改了头像 将会有闪一下的操作】 闪一下总比没有好
    }else{
        [self getDataFromFMDBData];
    }
}



#pragma mark - 取缓存
-(void)getDataFromFMDBData{
    //这里不需要iddata，只有缓存、查看表 需要转成iddata
    NSArray *chatDetailArr = [self.fmdbServicee getGroupDetailEntityAndMemberListWithGroupId:self.groupCreateSEntity.groupId];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf = self;
//    [jqFmdb jq_inDatabase:^{
        //展示缓存 froupId是唯一id
    __block NSArray *arrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:qunDetail dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    self.memberArr = [NSArray arrayWithArray:arrs];
//    NSArray *groupDetailArrr = [jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@""];
    __block NSArray *groupDetailArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        groupDetailArr = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",@"groupId",strongSelf.groupCreateSEntity.groupId]];
    }];
    weakSelf.groupCreateSEntity = [groupDetailArr lastObject];
        weakSelf.groupCreateSEntity.groupAllUser = arrs;
    
        [weakSelf initUIData];
        [weakSelf.tableView reloadData];
        //尝试连接
//        [socketModel initSocket];
//    }];
}

#pragma mark - 群组详情请求

#pragma mark - 设置群组信息

#pragma mark - 退出群组请求

#pragma mark - 解散群组请求



#pragma 编辑修改本群昵称 等服务器接口
-(void)requestEditLocalGroupNickName:(NSString *)newName{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"releaseGroup";
    self.parms[@"groupId"] = self.groupCreateSEntity.groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"nickName"] = newName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
//        [socketModel sendMsg:Json];
    }else{
    }
}

#pragma 保存、取消群聊到列表

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
//    if (messageType == SecretLetterType_notifyGetgroupDetail) {
    if (messageType == SecretLetterType_GroupQRCodeInviteSuccessNotificate || messageType == SecretLetterType_GroupDetailChanged) {
        //当有人扫描二维码进群了 通知刷新详情
        [self initSocket];
    }else if (messageType == SecretLetterType_GroupDetail) {
//        [SVProgressHUD dismiss];
        self.groupCreateSEntity = chatModel;
        //如果群中还剩一个人 并且为创建者 那么请求群解散
        if (self.groupCreateSEntity.groupAllUser.count <= 1 && [self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
            [socketRequest requestGroupDissolute:self.groupCreateSEntity.groupId];
        }
        [self initUi];
        [self initUIData];
        //缓存群组详情 先删除
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //                for (ZJContact *friendEntity in arrs) {
            BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:[NSString stringWithFormat:@"qunDetail%@",strongSelf.groupCreateSEntity.groupId] whereFormat:@""];\
        }];
        if (self.groupCreateSEntity.groupAllUser.count == 0) {
            [SVProgressHUD showInfoWithStatus:@"该群已不存在..."];
            self.tableView.userInteractionEnabled = NO;
            return;
        }
        [self.fmdbServicee cacheGroupDetail:chatModel];
        //每次请求群详情， 更新这15个群成员【其中多数可能为管理员】
        for (ZJContact *contact in self.groupCreateSEntity.groupAllUser) {
            ZJContact *lastContact = [self.fmdbServicee checkContactIsHaveCommmentname:contact];
            [self.fmdbServicee cacheGroupMemberWith:lastContact AndGroupId:self.groupCreateSEntity.groupId];
        }
        if([self.groupCreateSEntity.isMsgForbidden isEqualToString:@"1"]){
            forbidSwitch.on = YES;
        }
        if([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]){
            groupSecretSwitch.on = YES;
        }
        if([self.groupCreateSEntity.allow_push isEqualToString:@"0"]){
            messageNotDisturbSwitch.on = YES;
        }
        if([self.groupCreateSEntity.needAllow isEqualToString:@"1"]){
            groupCheckSwitch.on = YES;
        }
        [self.tableView reloadData];
    }else if (messageType == SecretLetterType_GroupBreak){
        //删除本地该群组和会话
        BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:self.groupCreateSEntity.groupId SecondKeyName:@"IsSingleChat" SecondValueName:@"0"];
        
        BOOL deleteQunzuLiebiaoRet = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"qunzuliebiao" DataKind:[MessageChatListEntity class] KeyName:@"groupId" ValueName:self.groupCreateSEntity.groupId];
        if (ret&&deleteQunzuLiebiaoRet) {
            NSLog(@"删除成功");
        }
        //清除缓存
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:[NSString stringWithFormat:@"qunzu%@",self.groupCreateSEntity.groupId] IsDelete:YES];
        if (rett) {
        }
        //回去需要更新会话列表
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        [SVProgressHUD showInfoWithStatus:@"该群已解散..."];
        [self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
        
    }else if (messageType == SecretLetterType_GroupExit){
        //删除本地该群组
        BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:self.groupCreateSEntity.groupId SecondKeyName:@"IsSingleChat" SecondValueName:@"0"];
        BOOL deleteQunzuLiebiaoRet = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"qunzuliebiao" DataKind:[MessageChatListEntity class] KeyName:@"groupId" ValueName:self.groupCreateSEntity.groupId];
        if (ret&&deleteQunzuLiebiaoRet) {
            NSLog(@"删除成功");
        }
        //清除缓存
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:[NSString stringWithFormat:@"qunzu%@",self.groupCreateSEntity.groupId] IsDelete:NO];
        if (rett) {
            NSLog(@"");
        }
        
        //回去需要更新会话列表
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        [SVProgressHUD showInfoWithStatus:@"已退出..."];
        [self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
        
    }else if (messageType == SecretLetterType_GroupSaveSuccess){
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = chatModel;
            if ([[dict objectForKey:@"type"] isEqualToString:@"save"]) {
                saveGroupSwitch.on = YES;
            }else if ([[dict objectForKey:@"type"] isEqualToString:@"cancel"]){
                saveGroupSwitch.on = NO;
            }
        }
    }else if (messageType == SecretLetterType_GroupSetPersonalInfo){
        //修改群信息成功
        [SVProgressHUD dismiss];
        NSDictionary *groupInfoDict = chatModel;
        if (editingType == EditTypeGroupName) {
            //群名称
            groupNameLabel.text = [[groupInfoDict objectForKey:@"groupName"] description];
            //会话缓存改掉
            NSString *key = @"conversationId";
            NSString *keyValue = [[groupInfoDict objectForKey:@"groupId"] description];
            NSString *secondKey = @"IsSingleChat";
            NSString *secondKeyValue = @"0";
            __block NSArray *repeatArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                repeatArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",key,keyValue,secondKey,secondKeyValue]];
            }];
            if (repeatArr.count == 1) {
                MessageChatListEntity *entity = [repeatArr firstObject];
                entity.nickName = [[groupInfoDict objectForKey:@"groupName"] description];
                entity.receive_user_name = [[groupInfoDict objectForKey:@"groupName"] description];
                
                [self.myManage changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:keyValue FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:secondKeyValue TableName:@"huihualiebiao"];
            }
            //代码块返回修改名
            self.returnGroupNameBlock([[groupInfoDict objectForKey:@"groupName"] description]);
        }else if (editingType == EditTypeInGroupName){
            //群显示昵称
            mineNickNameLabel.text = @"";
        }
    }else if (messageType == SecretLetterType_zhuanrangSuccess){
        //群主转让成功
        [SVProgressHUD showInfoWithStatus:@"转让群主成功"];
        [self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
    }else if (messageType == SecretLetterType_GroupSetManageSucess){
        //设置管理员成功
        [SVProgressHUD showInfoWithStatus:@"设置成功"];
        //[self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
    }else if (messageType == SecretLetterType_GroupDelManageSucess){
        //取消管理员成功
        [SVProgressHUD showInfoWithStatus:@"取消成功"];
        //[self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
    }else if(messageType == SecretLetterType_GroupAllMemberId){
        if(![[[chatModel objectForKey:@"groupid"] description] isEqualToString:self.groupCreateSEntity.groupId]){
            return;
        }
         NSArray *arr= [NSArray arrayWithArray:[chatModel objectForKey:@"groupUser"]];
                   __weak typeof(self)weakSelf=self;
                   __block NSArray *mamberArr = [NSArray new];
                   [jqFmdb jq_inDatabase:^{
                       __strong typeof(weakSelf)strongSelf=weakSelf;
                       mamberArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"groupmemberlist%@",self.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
                   }];
                   dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                       __block NSMutableArray *needDeleteArr = [NSMutableArray new];
                       for (ZJContact *contact in mamberArr) {
                           BOOL Delte = YES;
                           for (ZJContact *backContact in arr) {
                               if ([backContact.friend_userid isEqualToString:contact.friend_userid] && [contact.iconUrl containsString:backContact.iconUrl]  && [contact.friend_username isEqualToString:backContact.friend_username] && [contact.is_creator isEqualToString:backContact.is_creator] && [contact.is_admin isEqualToString:backContact.is_admin]) {
                                   Delte = NO;
                                   break;
                               }
                           }
                           if (Delte) {
                               [needDeleteArr addObject:contact];
                           }
                       }
                       [jqFmdb jq_inDatabase:^{
                           __strong typeof(weakSelf)strongSelf=weakSelf;
                           for (ZJContact *deleteConatct in needDeleteArr) {
                               BOOL ret = [jqFmdb jq_deleteTable:[NSString stringWithFormat:@"groupmemberlist%@",strongSelf.groupCreateSEntity.groupId] whereFormat:@"where friend_userid = '%@'",deleteConatct.friend_userid];
                               NSLog(@"");
                           }
                       }];
                       // 添加成员缓存
                       NSMutableArray *needAddArr = [NSMutableArray new];
                       for (int i = arr.count - 1; i>0; i--) {
                           ZJContact *needAddConatct = arr[i];
                           BOOL Add = YES;
                           for (ZJContact *localContact in mamberArr) {
                               if ([needAddConatct.friend_userid isEqualToString:localContact.friend_userid] && [localContact.iconUrl containsString:needAddConatct.iconUrl]  && [localContact.friend_username isEqualToString:needAddConatct.friend_username] && [localContact.is_creator isEqualToString:needAddConatct.is_creator] && [localContact.is_admin isEqualToString:needAddConatct.is_admin]) {
                                   Add = NO;
                                   break;
                               }
                           }
                           if(Add){
                               [needAddArr addObject:needAddConatct];
                           }else if(arr.count == mamberArr.count ){
                               //如果倒数第一个 已经在缓存里，那么逻辑判断 所有群成员都在缓存里
                               break;
                           }
                       }
                       if (needAddArr.count>0) {
                           for (int i = 0; i<needAddArr.count-1; i++) {
                               ZJContact *contactt = needAddArr[i];
                               ZJContact *lastContact = [self.fmdbServicee checkContactIsHaveCommmentname:contactt];
                                [self.fmdbServicee cacheGroupMemberWith:contactt AndGroupId:self.groupCreateSEntity.groupId];
                                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                                     CGFloat hudProcess = (CGFloat)i/needAddArr.count;
                                     [SVProgressHUD showProgress:hudProcess status:[NSString stringWithFormat:@"正在加载群成员"]];
                                 });
                           }
                       }
                       
                       
                       //将需要缓存的群成员 插入到群成员表去
//                       __weak typeof(self)weakSelf=self;
//                       [jqFmdb jq_inDatabase:^{
//                           __strong typeof(weakSelf)strongSelf=weakSelf;
//                           BOOL ret = [jqFmdb jq_insertTable:[NSString stringWithFormat:@"groupmemberlist%@",self.groupCreateSEntity.groupId] dicOrModelArray:needAddArr];
//                       }];
                       
//                       //addedIndex = needAddArr.count;
//                       NSMutableArray *needAddUserIdArr = [NSMutableArray new];
//                       for (NSDictionary *needAddD in needAddArr) {
//                           [needAddUserIdArr addObject:@{@"userId":[[needAddD objectForKey:@"user_id"] description]}];
////                           ZJContact *needCacheContact = [ZJContact new];
//                       }
                       
                       if(NO){
//                       if(needAddUserIdArr.count > 0 ){
//                           if (needAddUserIdArr.count >= RequestNumber) {
//                               needAddUserIdAllCount = needAddUserIdArr.count;
//                               NSArray *requestArr = [needAddUserIdArr subarrayWithRange:NSMakeRange(0, RequestNumber)];
//                               needAddUserIdArrQuanju = [needAddUserIdArr subarrayWithRange:NSMakeRange(RequestNumber, needAddUserIdArr.count-RequestNumber-1)];
//                               //分批次进行请求
//                               [socketRequest getUserInGroupDetail:self.groupCreateSEntity.groupId AndGroupuserArr:requestArr];
//                           }else{
//                               [socketRequest getUserInGroupDetail:self.groupCreateSEntity.groupId AndGroupuserArr:needAddUserIdArr];
//                           }
                           
                       }else{
                           [NSThread sleepForTimeInterval:0.3];
                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                               [NSThread sleepForTimeInterval:0.1];
                               [SVProgressHUD dismiss];
                               //放到返回为
                               __weak typeof(self)weakSelf=self;
                               __block NSArray *mamberArr = [NSArray new];
                               [jqFmdb jq_inDatabase:^{
                                   __strong typeof(weakSelf)strongSelf=weakSelf;
                                   mamberArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"groupmemberlist%@",self.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
                               }];
                               
                               if (requestAllmemberTypeIsReduce) {
                                   requestAllmemberTypeIsReduce = NO;
                                   UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                                   GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
//                                   if (self.memberArr.count == 15) {
//                                       toCtrol.IsNeedLoadMore = YES;
//                                   }
                                   NSMutableArray *reduceArrCopy = [NSMutableArray arrayWithArray:mamberArr];
                                   NSMutableArray *reduceArr = [NSMutableArray arrayWithArray:mamberArr];
                                   for (ZJContact *contact in reduceArrCopy) {
                                       //这么做是为了 防止群成员中有两个群主本人
                                       if ([contact.friend_userid isEqualToString:[NFUserEntity shareInstance].userId]) {
                                           [reduceArr removeObject:contact];
                                       }else if ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_creator isEqualToString:@"1"]){
                                           if([contact.is_admin isEqualToString:@"1"] || [contact.is_creator isEqualToString:@"1"]){
                                               [reduceArr removeObject:contact];
                                           }
                                       }
                                   }
                                   toCtrol.alreadlyExistMemberArr = reduceArr;
                                   toCtrol.SourceType = SourceTypeFromGroupChatReduce;
                                   toCtrol.groupCreateSEntity = self.groupCreateSEntity;
                                   [toCtrol reduceMemberSuccess:^(BOOL ret) {
                                       //删除成员成功 通知界面刷新详情
                                       [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
                                   }];
                                   [self.navigationController pushViewController:toCtrol animated:YES];
                                   return ;
                               }
                               //到这里 说明s不是删除成员
                               if(!requesrAllmemberType){
                                   [SVProgressHUD dismiss];
                                   UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                                   GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
                                   //将已经存在的人员传过去
                                   toCtrol.alreadlyExistMemberArr = mamberArr;
                                   toCtrol.SourceType = SourceTypeFromGroupChatAdd;
                                   toCtrol.groupCreateSEntity = self.groupCreateSEntity;
                                   [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
                                       //完成后在 添加成员界面进行跳转 不会再回去
                                   }];
                                   [self.navigationController pushViewController:toCtrol animated:YES];
                               }else{
                                   requesrAllmemberType = NO;
                                   [SVProgressHUD dismiss];
                                   //全体成员 GroupChatAllMemberCollectionViewController
                                   UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                                   GroupChatAllMemberCollectionViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatAllMemberCollectionViewController"];
                                   toCtrol.groupCreateSEntity = self.groupCreateSEntity;
                                   toCtrol.memberArr = [NSArray arrayWithArray:mamberArr];
                                   [self.navigationController pushViewController:toCtrol animated:YES];
                               }
                           });
                       }
                   });
        
    }else if (messageType == SecretLetterType_GrouppartMemberDetail){
        if(![[[chatModel objectForKey:@"groupid"] description] isEqualToString:self.groupCreateSEntity.groupId]){
            return;
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            for (ZJContact *contact in [chatModel objectForKey:@"groupUser"]) {
                //本地是否有备注
                ZJContact *lastContact = [self.fmdbServicee checkContactIsHaveCommmentname:contact];
                [self.fmdbServicee cacheGroupMemberWith:lastContact AndGroupId:self.groupCreateSEntity.groupId];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                CGFloat hudProcess = (needAddUserIdAllCount-needAddUserIdArrQuanju.count)/needAddUserIdAllCount;
                [SVProgressHUD showProgress:hudProcess status:[NSString stringWithFormat:@"正在加载群成员"]];
            });
            if(needAddUserIdArrQuanju.count>RequestNumber){
                NSArray *requestArr = [needAddUserIdArrQuanju subarrayWithRange:NSMakeRange(0, RequestNumber)];
                needAddUserIdArrQuanju = [needAddUserIdArrQuanju subarrayWithRange:NSMakeRange(RequestNumber, needAddUserIdArrQuanju.count-RequestNumber-1)];
                //分批次进行请求
                [socketRequest getUserInGroupDetail:self.groupCreateSEntity.groupId AndGroupuserArr:requestArr];
            }else if(needAddUserIdArrQuanju.count>0){
                NSArray *lastArr = [NSArray arrayWithArray:needAddUserIdArrQuanju];
                needAddUserIdArrQuanju = [NSArray new];
                [socketRequest getUserInGroupDetail:self.groupCreateSEntity.groupId AndGroupuserArr:lastArr];
            }else{
                [NSThread sleepForTimeInterval:0.1];
                [SVProgressHUD dismiss];
                //放到返回为
                __weak typeof(self)weakSelf=self;
                __block NSArray *mamberArr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    mamberArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"groupmemberlist%@",self.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
                }];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (requestAllmemberTypeIsReduce) {
                        requestAllmemberTypeIsReduce = NO;
                        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
    //                    if (self.memberArr.count == 15) {
    //                        toCtrol.IsNeedLoadMore = YES;
    //                    }
                        NSMutableArray *reduceArrCopy = [NSMutableArray arrayWithArray:mamberArr];
                        NSMutableArray *reduceArr = [NSMutableArray arrayWithArray:mamberArr];
                        for (ZJContact *contact in reduceArrCopy) {
                            //这么做是为了 防止群成员中有两个群主本人
                            if ([contact.friend_userid isEqualToString:[NFUserEntity shareInstance].userId]) {
                                [reduceArr removeObject:contact];
                            }else if ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_creator isEqualToString:@"1"]){
                                if([contact.is_admin isEqualToString:@"1"] || [contact.is_creator isEqualToString:@"1"]){
                                    [reduceArr removeObject:contact];
                                }
                            }
                        }
                        toCtrol.alreadlyExistMemberArr = reduceArr;
                        toCtrol.SourceType = SourceTypeFromGroupChatReduce;
                        toCtrol.groupCreateSEntity = self.groupCreateSEntity;
                        [toCtrol reduceMemberSuccess:^(BOOL ret) {
                            //删除成员成功 通知界面刷新详情
                            [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
                        }];
                        [self.navigationController pushViewController:toCtrol animated:YES];
                        return ;
                    }
                    //到这里说明 不是删除群成员
                   if(!requesrAllmemberType){
                       [SVProgressHUD dismiss];
                       
                       UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                       GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
                       //将已经存在的人员传过去
                       toCtrol.alreadlyExistMemberArr = mamberArr;
                       toCtrol.SourceType = SourceTypeFromGroupChatAdd;
                       toCtrol.groupCreateSEntity = self.groupCreateSEntity;
                       [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
                           //完成后在 添加成员界面进行跳转 不会再回去
                       }];
                       [self.navigationController pushViewController:toCtrol animated:YES];
                   }else{
                       [SVProgressHUD dismiss];
                       //全体成员 GroupChatAllMemberCollectionViewController
                       UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
                       GroupChatAllMemberCollectionViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatAllMemberCollectionViewController"];
                       toCtrol.groupCreateSEntity = self.groupCreateSEntity;
                       toCtrol.memberArr = [NSArray arrayWithArray:mamberArr];
                       
                       [self.navigationController pushViewController:toCtrol animated:YES];
                   }
                    
                });
            }
            
            
        });
    }else if (messageType == SecretLetterType_GroupDropSuccess){
        //踢人成功，dismiss
        __weak typeof(self)weakSelf=self;
        [UIView animateWithDuration:0.2 animations:^{
            GroupChatDetailTableV.scrollEnabled = YES;
            self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            [self.ZJContactDetailController.view removeFromSuperview];
            //当移除界面后 设置来自编辑名字为no
            isFromEditName = NO;
        }];
        weakSelf.navigationController.navigationBarHidden = NO;
        //请求群聊联系人详情
        [self initSocket];
    }
    
}

-(void)popToRootViewController{
    //pop回根视图
    UIViewController * viewVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - self.navigationController.viewControllers.count];
    [self.navigationController popToViewController:viewVC animated:YES];
}


#pragma mark - 界面初始化
-(void)initUi{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    GroupCreateSuccessEntity *sss = self.groupCreateSEntity;
    //dissolutionBtn
    if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
        [dissolutionBtn setTitle:@"解散本群" forState:(UIControlStateNormal)];
    }else if([self.groupCreateSEntity.is_creator isEqualToString:@"0"]){
        [dissolutionBtn setTitle:@"退出本群" forState:(UIControlStateNormal)];
    }else{
        [dissolutionBtn setTitle:@"退出本群" forState:(UIControlStateNormal)];
    }
    if ([self.groupCreateSEntity.save_group isEqualToString:@"1"]) {
        saveGroupSwitch.on = YES;
    }else{
        saveGroupSwitch.on = NO;
    }
    //消息免打扰
//    messageNotDisturbSwitch.on = NO;
    
    
}

-(void)initUIData{
    //群成员数设置
//    groupMemberCount.text = [NSString stringWithFormat:@"群成员数 %ld",self.groupCreateSEntity.groupAllUser.count];
    groupMemberCount.text = [NSString stringWithFormat:@"群成员数 %@",self.groupCreateSEntity.groupTotalNum];
    //群聊名称
    groupNameLabel.text = self.groupCreateSEntity.groupName;
    //我在本群的昵称
    mineNickNameLabel.text = self.groupCreateSEntity.in_group_name;
    
    if (self.groupCreateSEntity.notice.length > 0) {
        groupNoticeLabel.text = self.groupCreateSEntity.notice;
    }
    
    
}

//自定义NAV返回按钮
- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}



#pragma mark - 保存群组到列表
- (IBAction)saveGroupToGroupList:(UISwitch *)sender {
    //请求
    if (sender.on) {
        [socketRequest saveGroupToList:@"save" GroupId:self.groupCreateSEntity.groupId];
    }else{
        [socketRequest saveGroupToList:@"cancel" GroupId:self.groupCreateSEntity.groupId];
    }
    //不让其改变按钮zhuangtai 看返回
//        sender.on = ! sender.on;
}

#pragma mark - 消息免打扰
- (IBAction)DonoNoticeSwitchClick:(UISwitch *)sender {
    //
    if (sender.on) {
        [socketRequest manageGroupnotpush:YES GroupId:self.groupCreateSEntity.groupId];
        self.groupCreateSEntity.allow_push = @"0";
        [self.fmdbServicee cacheGroupDetail:self.groupCreateSEntity];
        
    }else{
        [socketRequest manageGroupnotpush:NO GroupId:self.groupCreateSEntity.groupId];
        self.groupCreateSEntity.allow_push = @"1";
        [self.fmdbServicee cacheGroupDetail:self.groupCreateSEntity];
        
    }
    
    
    
}

#pragma mark - 顶置聊天
- (IBAction)OverHeadSwitchClick:(UISwitch *)sender {
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    if (sender.isOn) {
        __block NSArray *singleArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            singleArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.groupCreateSEntity.groupId,@"IsSingleChat",@"0"]];
        }];
        MessageChatListEntity *chatListEntity = [singleArr firstObject];
        chatListEntity.IsUpSet = YES;
        __block BOOL isSuccess;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            isSuccess = [strongSelf ->jqFmdb jq_updateTable:@"huihualiebiao" dicOrModel:chatListEntity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.groupCreateSEntity.groupId,@"IsSingleChat",@"0"]];
        }];
    }else if (!sender.isOn){
        __block NSArray *singleArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            singleArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.groupCreateSEntity.groupId,@"IsSingleChat",@"0"]];
        }];
        MessageChatListEntity *chatListEntity = [singleArr firstObject];
        chatListEntity.IsUpSet = NO;
        __block BOOL isSuccess;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            isSuccess = [strongSelf ->jqFmdb jq_updateTable:@"huihualiebiao" dicOrModel:chatListEntity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.groupCreateSEntity.groupId,@"IsSingleChat",@"0"]];
        }];
    }
}

//禁言
- (IBAction)forbidClick:(UISwitch *)sender {
    if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
        return;
    }
    if (sender.on) {
        [socketRequest forbiddenGroup:YES GroupId:self.groupCreateSEntity.groupId];
    }else{
        [socketRequest forbiddenGroup:NO GroupId:self.groupCreateSEntity.groupId];
    }
}

//设置隐私
- (IBAction)groupSetSecretClick:(UISwitch *)sender {
    if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
        return;
    }
    if (sender.on) {
        [socketRequest manageGroupSectet:YES GroupId:self.groupCreateSEntity.groupId];
    }else{
        [socketRequest manageGroupSectet:NO GroupId:self.groupCreateSEntity.groupId];
    }
}

//进群验证
- (IBAction)enterGroupCheckClick:(UISwitch *)sender {
    if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
        return;
    }
    if (sender.on) {
        [socketRequest manageGroupEnterCheck:YES GroupId:self.groupCreateSEntity.groupId];
    }else{
        [socketRequest manageGroupEnterCheck:NO GroupId:self.groupCreateSEntity.groupId];
    }
}



//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5) {
        return;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
//            NSLog(@"%f",[GroupDetailHeadTableViewCell heightForCellWithData:@[@"",@"",@"",@"",@"",@"",@"",@"",@"",@""]]);
            //20是collectionview 距离tableviewcell的约束距离
            NSLog(@"%d",self.groupCreateSEntity.groupAllUser.count);
            if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"] || [self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
                return [GroupDetailHeadTableViewCell heightForCellWithData:self.groupCreateSEntity.groupAllUser IsCreator:YES] + 20;
            }else{
                return [GroupDetailHeadTableViewCell heightForCellWithData:self.groupCreateSEntity.groupAllUser IsCreator:NO] + 20;
            }
        }
    }
//    else if(indexPath.section == 1){
//        if (indexPath.row == 3){
//            return 0.1;
//        }
//    }
    else if (indexPath.section == 2){
        if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3) {
            if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"] || [self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
                return [super tableView:GroupChatDetailTableV heightForRowAtIndexPath:indexPath];
            }
            return 0.1;
        }else if (indexPath.row == 4){
            return 0.1;
        }
    }else if(indexPath.section == 3){
        //查看聊天记录
    }
    return [super tableView:GroupChatDetailTableV heightForRowAtIndexPath:indexPath];
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
    
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
    
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (@available(iOS 13.0, *)) {
        UITableViewCell *celllll = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        if (indexPath.section == 0 && indexPath.row == 0) {
//            return cell;
        }else if(indexPath.section == 1 && (indexPath.row == 4 || indexPath.row == 5)){
            
        }else if(indexPath.section == 2 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2|| indexPath.row == 3)){
            
        }else if(indexPath.section == 5 && indexPath.row == 0){
            NSLog(@"");
        }
        else{
            celllll.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
        }
        
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString* cellIdentifier = @"GroupDetailHeadTableViewCell";
            GroupDetailHeadTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupDetailHeadTableViewCell" owner:nil options:nil]firstObject];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //如果是新建的群组 则可以拿到所有的联系人
//            if (existMemberIdArr) {
//                cell.existMemberArr = existMemberIdArr;
//            }else{
//                cell.existMemberArr = nil;
//            }
            if(self.groupCreateSEntity.groupAllUser.count > 0){
                cell.memberArr = [NSArray arrayWithArray:self.groupCreateSEntity.groupAllUser];
            }else{

                cell.memberArr = [NSArray arrayWithArray:self.memberArr];
            }
            cell.groupCreateSEntity = self.groupCreateSEntity;
            __weak typeof(self)weakSelf=self;
            //删除成员成功 刷新详情数据
            [cell reduceMemberSuccess:^(BOOL ret) {
                //请求详情
                [socketRequest getGroupDetail:self.groupCreateSEntity.groupId];
            }];
            //点击了 添加成员按钮，请求所有群成员id，和本地id作比较
            [cell ReturnClickAddMemberBlock:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                [SVProgressHUD showWithStatus:@"加载中"];
                //获取群成员id
                strongSelf -> requesrAllmemberType = NO;
                [socketRequest requestGroupAllMemberIdWithGroup:self.groupCreateSEntity.groupId];
            }];
            //点击了 删除群成员按钮 请求所有群成员id，和本地id作比较
            [cell ReturnClickReduceMemberBlock:^{
                
                __strong typeof(weakSelf)strongSelf=weakSelf;
                [SVProgressHUD showWithStatus:@"加载中"];
                //获取群成员id
                strongSelf -> requestAllmemberTypeIsReduce = YES;
                [socketRequest requestGroupAllMemberIdWithGroup:self.groupCreateSEntity.groupId];
            }];
            
            //点击了群成员 【点击了增加、删除 不会走这里】
            [cell returnMemberGroupClick:^(NSIndexPath* index) {
                __strong typeof(weakSelf)strongSelf=weakSelf;
                
                [GroupChatDetailTableV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
                
                selectedIndexPath = index;
                //ZJContactDetailController
                weakSelf.tableView.scrollEnabled = NO;
                strongSelf.ZJContactDetailController.view  = nil;
                strongSelf.ZJContactDetailController  = nil;
                if (strongSelf.ZJContactDetailController == nil) {
                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
                    strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
                    //设置单聊详情数据
                    ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
                    //缓存查 是否为联系人
                    NSArray *arr=  [self.fmdbServicee checkContactWithId:contact.friend_userid];
                    if(arr.count > 0){
                        contact = [arr lastObject];
                    }
                    //对于详情页面的赋值
                    strongSelf.ZJContactDetailController.contant = contact;
                    strongSelf.ZJContactDetailController.SourceFrom = @"1";
                    [weakSelf addChildViewController:strongSelf.ZJContactDetailController];
                    strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                    if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
                        if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![contact.is_admin isEqualToString:@"1"] && ![contact.is_creator isEqualToString:@"1"]) {
                            strongSelf.ZJContactDetailController.userNameLabel.hidden = YES;
                            strongSelf.ZJContactDetailController.freeChatBtn.hidden = YES;
                            strongSelf.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                        }
                    }
                    //点击了headview上面的事件
                    strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
                        if (index == 0 || index == 10) {
                            //移除ZJContactDetailController
                            [UIView animateWithDuration:0.2 animations:^{
                                self.tableView.scrollEnabled = YES;
                                self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                            } completion:^(BOOL finished) {
                                __strong typeof(weakSelf)strongSelf=weakSelf;
                                [self.ZJContactDetailController.view removeFromSuperview];
                                //当移除界面后 设置来自编辑名字为no
                                isFromEditName = NO;
                            }];
                            weakSelf.navigationController.navigationBarHidden = NO;
                        }else if (index == 1){
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            [strongSelf showMoreClickWithContact:contact];
                            
//                            //相册
//                            isFromEditName = YES;
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
//                            [self.navigationController pushViewController:showImageViewCtrol animated:YES];
                        }else if (index == 2){
                            
                        }
                    };
                    //如果点击了自己 则
                    if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
                        self.ZJContactDetailController.freeChatBtn.hidden = YES;
                        self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                    }
                    //设置编辑名字、免费聊天
//                    [weakSelf.ZJContactDetailController.nameEditBtn addTarget:weakSelf action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
                    [weakSelf.ZJContactDetailController.freeChatBtn addTarget:weakSelf action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
                    //设置头像
                    self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80/2, -65, 90, 90)];
//                    ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
                    ViewRadius(self.ZJContactDetailController.nfHeadImageV, 3);
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
                        [self.navigationController pushViewController:showImageViewCtrol animated:YES];
                    }];
                    [weakSelf.ZJContactDetailController.tableView addSubview:weakSelf.ZJContactDetailController.nfHeadImageV];
                    [weakSelf.view addSubview:weakSelf.ZJContactDetailController.view];
                    [UIView animateWithDuration:0.2 animations:^{
                        self.navigationController.navigationBarHidden = YES;
                        self.tabBarController.tabBar.hidden = YES;
                        self.ZJContactDetailController.view.frame = CGRectMake(0, GroupChatDetailTableV.contentOffset.y, SCREEN_WIDTH, SCREEN_HEIGHT);
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                }
            }];
            return cell;
        }
    }
    
    return [super tableView:GroupChatDetailTableV cellForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if (indexPath.section == 0) {
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {

            requesrAllmemberType = YES;
            [SVProgressHUD showWithStatus:@"加载中"];
            //获取群成员id
            [socketRequest requestGroupAllMemberIdWithGroup:self.groupCreateSEntity.groupId];
            
            
            
        }else if (indexPath.row == 1) {
            //群聊备注
            if(![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_creator isEqualToString:@"1"]){
                [SVProgressHUD showInfoWithStatus:@"只有群主或者管理员可以修改群名称"];
                return;
            }
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
            toCtrol.editType = EditTypeGroupName;
            toCtrol.currentText = groupNameLabel. text;
            
            [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
                if (type == EditTypeGroupName) {
                    if (![ClearManager getNetStatus]) {
                        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
                        return;
                    }
//                    groupNameLabel.text = info;
                    //修改群名称
                    
                    editingType = EditTypeGroupName;
                    [socketRequest setGroupInfoWithDict:@{@"name":info} WithGroupId:self.groupCreateSEntity.groupId];
                }
            }];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 2){
            //群二维码
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
            QRGroupCodeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"QRGroupCodeViewController"];
            toCtrol.groupId = self.groupCreateSEntity.groupId;
            toCtrol.nickname = self.groupCreateSEntity.in_group_name;
            toCtrol.groupName =  self.groupCreateSEntity.groupName;
            toCtrol.groupIconUrl = self.groupCreateSEntity.groupHeadPic;
            [toCtrol setReturnRefreshBlock:^(BOOL refresh) {
                IsNeedRefresh = YES;
            }];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 3){
            //群公告
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
            toCtrol.editType = EditTypeGroupMessage;
            if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
                toCtrol.ISNotCanEdit = YES;
            }
            toCtrol.currentText = self.groupCreateSEntity.notice.length > 0?self.groupCreateSEntity.notice:@"";
            __weak typeof(self)weakSelf=self;
            [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
                if (type == EditTypeGroupMessage) {
                    //personalSignatureLabel.text = info;
                    //[weakSelf personalInfoSet:EditTypePersonalSingature AndValue:info];
                    //发消息到群聊
                    [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
                    
                    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                    NSInteger time = interval;
                    NSString *createTime = [NSString stringWithFormat:@"%ld",time];
                    [weakSelf sendGroupMesageFrom:[NFUserEntity shareInstance].userName To:nil Content:[NSString stringWithFormat:@"@所有人\n%@",info] Createtime:createTime AndType:@"0"];
                    
                    
                }
            }];
            [self.navigationController pushViewController:toCtrol animated:YES];
            
            
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 4) {
            //setInGroup
            //我的本群昵称
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
//            PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
//            toCtrol.editType = EditTypeGroupMineName;
//            toCtrol.currentText = self.groupCreateSEntity.in_group_name;
//            [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
//                if (type == EditTypeGroupMineName) {
//                    if(info.length == 0){
//                        info = [NFUserEntity shareInstance].nickName;
//                    }
//                    mineNickNameLabel.text = info;
//                    [socketRequest setInGroup:info groupId:self.groupCreateSEntity.groupId];
//                }
//            }];
//            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if (indexPath.section == 3){
        if (indexPath.row == 0) {
            //查找聊天记录
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            VagueSearchViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"VagueSearchViewController"];
            toCtrol.fromType = @"2";
            toCtrol.groupCreateSEntity = self.groupCreateSEntity;
            //            [self presentViewController:toCtrol animated:YES completion:nil];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if (indexPath.section == 4){
        if (indexPath.row == 0) {
            //清空聊天记录
            [self clearCache];
        }else if (indexPath.row == 1){
            //投诉
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
            PublishDynamicViewController *pubvc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
            pubvc.groupid = self.groupCreateSEntity.groupId;
            __weak typeof(self)weakSelf=self;
            //没用到
            pubvc.successBlock = ^(BOOL success){

            };
            pubvc.shareType = ShareTypeOffjubao;
            [self.navigationController pushViewController:pubvc animated:YES];
            
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
//            OpinionRequestViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"OpinionRequestViewController"];
//            toCtrol.tousu = YES;
//            toCtrol.groupCreateSEntity = self.groupCreateSEntity;
//            [self.navigationController pushViewController:toCtrol animated:YES];
            
        }
    }
}

-(void)initColor{
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secLabel.textColor = [UIColor colorMainTextColor];
    self.thirdLaberl.textColor = [UIColor colorMainTextColor];
    groupMemberCount.textColor = [UIColor colorMainSecTextColor];
    mineNickNameLabel.textColor = [UIColor colorMainSecTextColor];
    groupNameLabel.textColor = [UIColor colorMainSecTextColor];
    groupNoticeLabel.textColor = [UIColor colorMainSecTextColor];
    self.fifthLabel.textColor = [UIColor colorMainTextColor];
    self.sixthLabel.textColor = [UIColor colorMainTextColor];
    self.seventhLabel.textColor = [UIColor colorMainTextColor];
    self.eightLabel.textColor = [UIColor colorMainTextColor];
    self.ninthLabel.textColor = [UIColor colorMainTextColor];
    self.tenthLabel.textColor = [UIColor colorMainTextColor];
    self.elevenyhLabel.textColor = [UIColor colorMainTextColor];
    self.twelveLabel.textColor = [UIColor colorMainTextColor];
    self.thirteenLabel.textColor = [UIColor colorMainTextColor];
    self.forteenLabel.textColor = [UIColor colorMainTextColor];
    self.fifteenlabel.textColor = [UIColor colorMainTextColor];
    self.sixteenLabel.textColor = [UIColor colorMainTextColor];
    self.seventeenthLabel.textColor = [UIColor colorMainTextColor];
    self.eightteenthLabel.textColor = [UIColor colorMainTextColor];
    
    
    [dissolutionBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
    dissolutionBtn.backgroundColor = [UIColor colorThemeColor];
    ViewRadius(dissolutionBtn, 3);
    
    self.firstLabel.font = [UIFont fontMainText];
    self.secLabel.font = [UIFont fontMainText];
    self.thirdLaberl.font = [UIFont fontMainText];
    groupMemberCount.font = [UIFont fontMainText];
    self.fifthLabel.font = [UIFont fontMainText];
    self.sixthLabel.font = [UIFont fontMainText];
    self.seventhLabel.font = [UIFont fontMainText];
    mineNickNameLabel.font = [UIFont fontMainText];
    groupNameLabel.font = [UIFont fontMainText];
    groupNoticeLabel.font = [UIFont fontMainText];
    self.eightLabel.font = [UIFont fontMainText];
    self.ninthLabel.font = [UIFont fontMainText];
    self.tenthLabel.font = [UIFont fontMainText];
    self.elevenyhLabel.font = [UIFont fontMainText];
    self.twelveLabel.font = [UIFont fontMainText];
    self.thirteenLabel.font = [UIFont fontMainText];
    self.forteenLabel.font = [UIFont fontMainText];
    self.fifteenlabel.font = [UIFont fontMainText];
    self.sixteenLabel.font = [UIFont fontMainText];
    self.seventeenthLabel.font = [UIFont fontMainText];
    self.eightteenthLabel.font = [UIFont fontMainText];
    
    
}

- (void)clearCache
{
//    self.tableView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf=self;
//    PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:@"清除缓存" message:@"确认清除？" isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
//        //设置可点
//        if (sureBlock) {
//            [weakSelf performSelector:@selector(NFDatabaseQueueClearCache) withObject:nil afterDelay:0.3];
//        }else{
//            self.tableView.userInteractionEnabled = YES;
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
            //删除了缓存
            self.returnDeleteBlock(YES);
            [weakSelf performSelector:@selector(NFDatabaseQueueClearCache) withObject:nil afterDelay:0.3];
        }
    };
    [alertView showMKPAlertView];
}

-(void)NFDatabaseQueueClearCache{
    //清除缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *allMessageImageArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        allMessageImageArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",strongSelf.groupCreateSEntity.groupId] dicOrModel:[MessageChatEntity new] whereFormat:@"where cachePicPath is not null"];
    }];
    for (MessageChatEntity *chatEntity in allMessageImageArr) {
        [[SDImageCache sharedImageCache] removeImageForKey:chatEntity.pictureUrl fromDisk:YES];
    }
    BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:[NSString stringWithFormat:@"qunzu%@",self.groupCreateSEntity.groupId] IsDelete:NO];
    if (rett) {
        __weak typeof(self)weakSelf=self;
//        PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:@"清除缓存" message:@"清除缓存成功!" isNeedCancel:NO isSureBlock:^(BOOL sureBlock) {
//            weakSelf.tableView.userInteractionEnabled = YES;
//            [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
//        }];
//        [popV setSecTitleBackColor:[UIColor colorThemeColor]];
//        [popV setSecSureColor:[UIColor colorThemeColor]];
//        [popV setSecMessageColor:UIColorFromRGB(0x666666)];
//        [popV setSecMessageLabelTextAlignment:@"0"];
//        UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
//        [win addSubview:popV];
        //更改会话列表
        NSDictionary *dic = @{@"group_id":self.groupCreateSEntity.groupId,@"group_msg_content":@"",@"last_message_id":@"",@"group_msg_time":@"",@"group_name":self.groupCreateSEntity.groupName,@"group_msg_type":@"normal",@"photo":self.groupCreateSEntity.groupHeadPic?self.groupCreateSEntity.groupHeadPic:@""};
        [self.fmdbServicee receiveGroupMessageChangeChatListCache:dic];
        [SVProgressHUD show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"清除缓存成功!" sureBtn:@"确认" cancleBtn:nil];
            alertView.resultIndex = ^(NSInteger index)
            {
                [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
                
            };
            [alertView showMKPAlertView];
        });
        
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"暂无记录"];
    }
}

#pragma mark - 点击头像
//-(void)headviewClick{
//    isFromEditName = YES;
//    SGPhoto *temp = [[SGPhoto alloc] init];
//    temp.identifier = @"";
//    temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
//    temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
//    HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//    showImageViewCtrol.imageUrlList = @[temp];
//    showImageViewCtrol.mainImageIndex = 0;
//    showImageViewCtrol.isLuoYang = YES;
//    showImageViewCtrol.isNeedNavigation = NO;
//    [self.navigationController pushViewController:showImageViewCtrol animated:YES
//     ];
//}

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
//    NSInteger index = [_sectionIndexs[selectedIndexPath.section - 1] integerValue];
//    NSArray *temp = _data[index];
//    ZJContact *contact = (ZJContact *)temp[selectedIndexPath.row];
    
    ZJContact *contact = self.groupCreateSEntity.groupAllUser[selectedIndexPath.row];
    if (contact.friend_nickname.length > 0) {
        toCtrol.titleName = contact.friend_nickname;
    }else{
        toCtrol.titleName = contact.friend_username;
    }
    toCtrol.conversationId = contact.friend_userid;
    toCtrol.chatType = @"0";
    
    toCtrol.singleContactEntity = contact;
    [self.navigationController pushViewController:toCtrol animated:YES];
}

-(void)returnEditedName:(ReturnGroupNameEditBlock)block{
    if (self.returnGroupNameBlock != block) {
        self.returnGroupNameBlock = block;
    }
}

#pragma mark - 代码块传值相关
-(void)returnDelete:(ReturnIsDeleteBlock)block{
    self.returnDeleteBlock = block;
}

#pragma mark - 解散本群 需要网络请求
- (IBAction)dissolutionClick:(id)sender {
    NSString *commitString = [[NSString alloc] init];
    if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
        commitString = @"解散";
    }else if([self.groupCreateSEntity.is_creator isEqualToString:@"0"]){
        commitString = @"退出";
    }else{
        commitString = @"退出";
    }
    
    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@后，将不再接收此群聊消息",commitString] sureBtn:@"确认" cancleBtn:@"取消"];
    alertView.resultIndex = ^(NSInteger index)
    {
        if (index == 2) {
            if (![ClearManager getNetStatus]) {
                [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
                return;
            }
            //进行网络请求
            if ([commitString isEqualToString:@"解散"]) {
                [socketRequest requestGroupDissolute:self.groupCreateSEntity.groupId];
            }else if ([commitString isEqualToString:@"退出"]){
                [socketRequest requestExitGroup:self.groupCreateSEntity.groupId];
            }
        }
    };
    [alertView showMKPAlertView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"");
}


#pragma mark - 群公告消息 给群聊
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
        newsDic[@"msgType"] = @"notice";
        newsDic[@"contentType"] = @"0";
        newsDic[@"msgContent"] = content;
    }
    newsDic[@"userName"] = from;
    newsDic[@"userId"] = [NFUserEntity shareInstance].userId;
    newsDic[@"groupId"] = self.groupCreateSEntity.groupId;
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

#pragma mark - 发送消息后展示、缓存 【只能是群聊】
- (void)addSpecifiedItemToGroup:(NSDictionary *)dic
{
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    ZJContact *contant = [ZJContact new];
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
//    if (message.type == UUMessageTypePicture && self.fromType) {
//        message.pictureUrl = self.forwardUUMessageFrame.message.pictureUrl;
//        message.pictureScale = self.forwardUUMessageFrame.message.pictureScale;
//        message.fileId = self.forwardUUMessageFrame.message.fileId;
//    }
//    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
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
//        previousTime = dataDic[@"strTime"];
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
                        GroupChatDetailTableV.scrollEnabled = YES;
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
                        GroupChatDetailTableV.scrollEnabled = YES;
                        
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
                    GroupChatDetailTableV.scrollEnabled = YES;
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


//懒加载 fmdbServicee
-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}



@end











