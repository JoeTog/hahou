//
//  ApplyViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ApplyViewController.h"
#import "JQFMDB.h"

@interface ApplyViewController ()<ChatHandlerDelegate>
//懒加载
@property (strong, nonatomic) NSMutableArray *dataArr;    //懒加载

@end

@implementation ApplyViewController{
    
    
    __weak IBOutlet NFBaseTableView *ApplyTableView;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    
    JQFMDB *jqFmdb;
    
    //记录删除、忽略的实体 和选中的indexpath
    FriendAddListEntity *friendAddEntity;
    NSIndexPath *selectedIndexPath;
    
    //记录 记录有权利利用断线重连
    BOOL isCanUseReconnect;
    
    __block NSArray *friendArr;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
//    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
    [ApplyTableView deselectRowAtIndexPath:[ApplyTableView indexPathForSelectedRow] animated:NO];
    
//    ApplyTableView.backgroundView = [self setThemeBackgroundImage];
//    [ApplyTableView reloadData];
    
    //是否需要刷新申请列表
    if ([NFUserEntity shareInstance].IsNeedRefreshApply) {
        [self initScoket];
    }
    
}

//-(void)viewDidAppear:(BOOL)animated{
//    
//    
//}
//懒加载
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"申请与通知";
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        strongSelf ->friendArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    
    
    [self initScoket];
    ApplyTableView.tableFooterView = [UIView new];
    ApplyTableView.isNeed = YES;
    
    //进入申请通知界面后 立马移除角标
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[1];
    [tabBarItemWillBadge removeBadgeView];
    [NFUserEntity shareInstance].contactBadgeCount = 0;//联系人角标
    //已读请求
    [socketRequest haveReadApplyListRequest];
    [NFUserEntity shareInstance].PushQRCode = @"0";
    
    if ([[NFUserEntity shareInstance].userName isEqualToString:@"duoxinkefu"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 60, 30);
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitle:@"全部同意" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(tongyiButtonClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: button];
        self.navigationItem.rightBarButtonItem = item;
    }
    
}

//批量添加好友
-(void)tongyiButtonClick{
    for (FriendAddListEntity *entity in self.dataArr) {
        [socketRequest acceptFriendAddRequest:entity];
    }
}

#pragma mark - 申请列表请求

#pragma mark - 请求已读申请列表

//socket初始化
-(void)initScoket{
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
            [socketRequest getAddFriendList];
        }else{
            [self getDataFromFMDBData];
        }
    }else{
        [self getDataFromFMDBData];
    }
}

#pragma mark - 删除、忽略该申请
#pragma mark - 展示申请缓存
-(void)getDataFromFMDBData{
    //没有网络则展示缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arr = [strongSelf ->jqFmdb jq_lookupTable:@"shenqingtongzhi" dicOrModel:[FriendAddListEntity class] whereFormat: @""];
    }];
    self.dataArr = [[NSMutableArray alloc] initWithArray:arr];
    if (self.dataArr.count == 0) {
        [ApplyTableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"申请列表为空"];
    }else{
        [ApplyTableView removeNone];
    }
    [ApplyTableView reloadData];
}


#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_FriendAddList){
        [SVProgressHUD dismiss];
        [NFUserEntity shareInstance].IsNeedRefreshApply = NO;
        //这里进行缓存
        //检查表存在
        [self.fmdbServicee IsExistShenQingTongZhi];
        
        //不管有没有新建成功 能从服务器获取列表 就删除本地所有记录
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __weak typeof(self)weakSelf=self;
        __block BOOL deleteRet = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            deleteRet = [strongSelf ->jqFmdb jq_deleteAllDataFromTable:@"shenqingtongzhi"];
        }];
        
        //缓存请求列表 FriendAddListEntity
        NSMutableArray *getArr = [NSMutableArray arrayWithArray:chatModel];
//        int applyCount = getArr.count;
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//            //删除重复添加的
//            NSMutableArray *needDelete = [NSMutableArray new];
//            for (FriendAddListEntity *addEntity in getArr) {
//                for (FriendAddListEntity *cacheentity in getArr) {
//                    if ([addEntity.addId isEqualToString:cacheentity.addId] && [addEntity.status isEqualToString:cacheentity.status]) {
//                        [needDelete addObject:cacheentity];
//                    }
//                }
//            }
//            for (FriendAddListEntity *cacheentity in needDelete) {
//                [getArr removeObject:cacheentity];
//            }
//            if (applyCount > getArr.count) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    for (FriendAddListEntity *entity in getArr) {
//                        //插入数据
//                        [jqFmdb jq_inDatabase:^{
//                            BOOL rett = [jqFmdb jq_insertTable:@"shenqingtongzhi" dicOrModel:entity];
//                            if (!rett) {
//                                //                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
//                                //缓存失败 数据库出了问题 可能是内存满了
//                                //                return;
//                            }
//                        }];
//                    }
//                    self.dataArr = [[NSMutableArray alloc] initWithArray:chatModel];
//                    [ApplyTableView reloadData];
//                });
//            }
//        });
        for (FriendAddListEntity *entity in getArr) {
            //插入数据
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:@"shenqingtongzhi" dicOrModel:entity];
                if (!rett) {
                    //                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    //缓存失败 数据库出了问题 可能是内存满了
                    //                return;
                }
            }];
        }
        self.dataArr = [[NSMutableArray alloc] initWithArray:chatModel];
        if (self.dataArr.count == 0) {
            [ApplyTableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"申请列表为空"];
        }else{
            [ApplyTableView removeNone];
        }
        [ApplyTableView reloadData];
    }else if (messageType == SecretLetterType_FriendAddIgnoreSuccess){
        //删除该条申请缓存
        [SVProgressHUD dismiss];
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block BOOL ret = NO;
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if(friendAddEntity.group_id.length == 0){
                ret = [strongSelf ->jqFmdb jq_deleteTable:@"shenqingtongzhi" whereFormat:@"where addId = '%@'",friendAddEntity.addId];
            }else{
                ret = [strongSelf ->jqFmdb jq_deleteTable:@"shenqingtongzhi" whereFormat:@"where addId = '%@' and group_id = '%@'",friendAddEntity.addId,friendAddEntity.group_id];
            }
        }];
        if (ret) {
//            [self.dataArr removeObject:friendAddEntity];
            [self.dataArr removeObjectAtIndex:selectedIndexPath.row];
            [ApplyTableView   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:selectedIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
            if (self.dataArr.count == 0) {
                [ApplyTableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"申请列表为空"];
            }else{
                [ApplyTableView removeNone];
            }
        }
    }else if (messageType == SecretLetterType_Promet){
        //接受申请成功 请求申请列表
        [socketRequest getAddFriendList];
        
        //设置刷新好友列表
        [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        
        WrongMessageAddFriendEntity *entity = chatModel;
        //先显示提示信息
        [SVProgressHUD showInfoWithStatus:entity.backMessage];
        //如果是成功 就返回 失败则留在本界面
        __weak typeof(self)weakSelf=self;
        if ([entity.messageType isEqualToString:@"1"]) {
            //发送消息 我已通过你的好友请求，我们现在可以聊天了
            NSString *currentTime = [NFMyManage getCurrentTimeStamp];
            if([[NFUserEntity shareInstance].userName isEqualToString:@"duoxinkefu"]){
                return;
            }
            [self sendMesageFrom:[NFUserEntity shareInstance].userName ToName:entity.backName ToId:entity.backId Content:@"我已通过你的好友请求，我们现在可以聊天了" Createtime:currentTime];
//            __weak UIViewController * viewVC = [weakSelf.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
//            __weak typeof(self)weakSelf=self;
//            [self createDispatchWithDelay:1 block:^{
//                [weakSelf.navigationController popToViewController:viewVC animated:YES];
//            }];
        }
    }else if (messageType == SecretLetterType_NormalReceipt){
        //receiveNickName receiveId
        //根据会话对象的id 在申请列表中查找改数据 取出头像
        NSDictionary *dic = chatModel;
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *arr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            arr = [strongSelf ->jqFmdb jq_lookupTable:@"shenqingtongzhi" dicOrModel:[FriendAddListEntity class] whereFormat: @"where send_user_id = '%@'",[dic objectForKey:@"receiveId"]];
        }];
        if (arr.count >= 1) {
            FriendAddListEntity *entity = [arr firstObject];
            ZJContact *contact = [ZJContact new];
            contact.friend_userid = entity.send_user_id;
            contact.friend_nickname = entity.send_nick_name;
            contact.friend_username = entity.send_user_name;
            contact.iconUrl = entity.photo;
            [self.fmdbServicee cacheChatListWithZJContact:contact AndDic:dic];
        }
        //插入一条消息 到单聊
        if ([[[dic objectForKey:@"strContent"] description] containsString:@"我们现在可以聊天了"]) {
            [self.fmdbServicee insertAMessageToSingleChatTable:[[dic objectForKey:@"receiveId"] description] AndDic:dic];
        }
        
    }else if(messageType == SecretLetterType_yanzhengOver){
        
        [SVProgressHUD showInfoWithStatus:@"申请已过期"];
        if (socketModel.isConnected) {
            if (socketModel.isConnected) {
                [socketRequest getAddFriendList];
            }else{
                [self getDataFromFMDBData];
            }
        }else{
            [self getDataFromFMDBData];
        }
    }else if(messageType == SecretLetterType_yanzhengAccept){
        
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"操作成功" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            
        };
        [alertView showMKPAlertView];
        
        if (socketModel.isConnected) {
            if (socketModel.isConnected) {
                [socketRequest getAddFriendList];
            }else{
                [self getDataFromFMDBData];
            }
        }else{
            [self getDataFromFMDBData];
        }
    }else if (messageType == SecretLetterType_yanzheng){
        [SVProgressHUD showInfoWithStatus:@"用户已经在群中"];
    }
    
    
}


#pragma mark - tableViewDelegate & tableViewDateSource
//cell设置成透明
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.backgroundColor = [UIColor clearColor];
//}

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
    return 60;
}

//脚高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"ContantTableViewCell";
    FriendAddListEntity *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if (entity.group_id.length == 0) {
        ContantTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ContantTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.statusLabel.hidden = NO;
        cell.timeLabel.hidden = NO;
        cell.agreeBtn.hidden = NO;//
        
        cell.nameLabel.text = entity.send_nick_name;
        cell.timeLabel.text = entity.finished_time;
        //    cell.backgroundColor = UIColorFromRGB(0xfef9ea);
        //判断是否为今年
        NSDate *date;
        if (entity.finished_time.length > 0) {
            date = [NSDate dateWithTimeIntervalSince1970:[entity.finished_time integerValue]];
        }else{
            date = [NSDate dateWithTimeIntervalSince1970:[entity.send_time integerValue]];
        }
        if ([date isThisYear]) {
            NSString *aa = [[NFbaseViewController new] timestampSwitchTime:[entity.finished_time.length > 0?entity.finished_time:entity.send_time integerValue] anddFormatter:@"M月d日"];
            cell.timeLabel.text = aa;
            
        }else{
            if (entity.finished_time.length > 0) {
                cell.timeLabel.text = [[NFbaseViewController new] timestampSwitchTime:[entity.finished_time integerValue] anddFormatter:@"yyyy年M月d日"];
            }else{
                cell.timeLabel.text = [[NFbaseViewController new] timestampSwitchTime:[entity.send_time integerValue] anddFormatter:@"yyyy年M月d日"];
            }
        }
        cell.badgeCountView.hidden = YES;
        if ([entity.status isEqualToString:@"wait"]) {
            cell.statusLabel.text = @"   添加   ";
            cell.statusLabel.textColor = UIColorFromRGB(0x101010);
            cell.statusLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.statusLabel.backgroundColor = UIColorFromRGB(0xf8f8f8);
            ViewBorderRadius(cell.statusLabel, 3, 1, UIColorFromRGB(0xe9e9e9));
            BOOL showRed = YES;
            for (ZJContact *contact in friendArr) {
                if ([contact.user_id isEqualToString:entity.send_user_id]) {
                    showRed = NO;
                    break;
                }
            }
            if (showRed) {
                cell.badgeCountView.hidden = NO;
                cell.badgeCountView.showBadge = YES;
            }
            //同意按钮
            [cell.agreeBtn addTarget:self action:@selector(agreeClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
            cell.agreeBtn.hidden = NO;
        }else if ([entity.status isEqualToString:@"accept"]){
            cell.statusLabel.text = @"已添加";
        }else if ([entity.status isEqualToString:@"reject"]){
            cell.statusLabel.text = @"已拒绝";
        }else{
            cell.statusLabel.text = @"其他";
        }
        if ([[entity.photo description] containsString:@"http"]) {
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:entity.photo] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
        }
        //    else if ([[entity.photo description] containsString:@"head_man"]){
        //        cell.headImageView.image = [UIImage imageNamed:entity.photo];
        //    }
        else{
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,entity.photo]] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
        }
        return cell;
    }
    
    //GroupApplyTableViewCell
    GroupApplyTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"GroupApplyTableViewCell" owner:nil options:nil]firstObject];
    }
    [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,entity.photo]] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    
    cell.applyDetailLabel.text = [NSString stringWithFormat:@"%@邀请%@加入%@",entity.who_invite_user_nickname,entity.user_nickname,entity.group_name];
    [cell.applyDetailLabel sizeToFit];
    //判断是否为今年
    NSDate *date;
    if (entity.finished_time.length > 0) {
        date = [NSDate dateWithTimeIntervalSince1970:[entity.finished_time integerValue]];
    }else{
        date = [NSDate dateWithTimeIntervalSince1970:[entity.send_time integerValue]];
    }
    if ([date isThisYear]) {
        NSString *aa = [[NFbaseViewController new] timestampSwitchTime:[entity.finished_time.length > 0?entity.finished_time:entity.send_time integerValue] anddFormatter:@"M月d日"];
        cell.timeLabel.text = aa;
        cell.timeLabel.textColor = [UIColor colorMainSecTextColor];
    }else{
        if (entity.finished_time.length > 0) {
            cell.timeLabel.text = [[NFbaseViewController new] timestampSwitchTime:[entity.finished_time integerValue] anddFormatter:@"yyyy年M月d日"];
        }else{
            cell.timeLabel.text = [[NFbaseViewController new] timestampSwitchTime:[entity.send_time integerValue] anddFormatter:@"yyyy年M月d日"];
        }
    }
    
    cell.badgeImageV.hidden = YES;
    
    if ([entity.status isEqualToString:@"wait"]) {
        cell.stateLabel.text = @"   添加   ";
        cell.stateLabel.textColor = UIColorFromRGB(0x101010);
        cell.stateLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.stateLabel.backgroundColor = UIColorFromRGB(0xf8f8f8);
        ViewBorderRadius(cell.stateLabel, 3, 1, UIColorFromRGB(0xe9e9e9));
        if ([entity.isRead isEqualToString:@"0"]) {
            cell.badgeImageV.hidden = NO;
            cell.badgeImageV.showBadge = YES;
        }
        //同意按钮
        [cell.agreeBtn addTarget:self action:@selector(agreeClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
        cell.agreeBtn.hidden = NO;
    }else if ([entity.status isEqualToString:@"accept"]){
        cell.stateLabel.text = @"已添加";
    }else if ([entity.status isEqualToString:@"reject"]){
        cell.stateLabel.text = @"已拒绝";
    }else{
        cell.stateLabel.text = @"其他";
    }
    //同意按钮
    [cell.agreeBtn addTarget:self action:@selector(agreeClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    return cell;





}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendAddListEntity *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    //if (entity.group_id.length == 0) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
        ApplyViewDetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ApplyViewDetailViewController"];
        [toCtrol ReturnAddFriendBlockk:^(NSString *addFriend) {
        }];
        toCtrol.entity = entity;
    if (entity.group_id.length > 0) {
        toCtrol.IsGroup = YES;
    }
        [self.navigationController pushViewController:toCtrol animated:YES];
    //}
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*删除用到的函数*/
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    friendAddEntity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
        if(friendAddEntity.group_id.length > 0){
            [socketRequest ignoreGroupApply:friendAddEntity];
        }else{
            [socketRequest ignoreApply:friendAddEntity];
        }
        selectedIndexPath = indexPath;
    }
    ApplyTableView.editing = NO;
}


- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

#pragma mark - 同意按钮点击
- (void)agreeClick:(UIButton *)button event:(UIEvent *)event{
    button.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.userInteractionEnabled = YES;
    });
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:ApplyTableView];
    NSIndexPath *indexPath = [ApplyTableView indexPathForRowAtPoint:currentTouchPosition];
    FriendAddListEntity *entity = self.dataArr.count>indexPath.row?self.dataArr[indexPath.row]:nil;
    
    if (entity.group_id.length > 0) {
        [socketRequest acceptGroupJoinAddRequest:entity];
    }else{
        [socketRequest acceptFriendAddRequest:entity];
    }
    
    
    NSLog(@"");
}

#pragma mark - 同意添加好友请求
//[socketRequest acceptFriendAddRequest:entity];

#pragma mark - 发送消息
- (void)sendMesageFrom:(NSString *)from ToName:(NSString *)toName ToId:(NSString *)toId Content:(NSString *)content Createtime:(NSString *)createtime{
    [self.parms removeAllObjects];
    self.parms[@"msgType"] = @"normal";
    self.parms[@"fromName"] = from;
    self.parms[@"fromId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"toName"] = toName;
    self.parms[@"toId"] = toId;
    self.parms[@"content"] = content;
    self.parms[@"createTime"] = createtime;
    self.parms[@"action"] = @"sendMessage";
    self.parms[@"msgClient"] = @"app";
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:self.parms];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
}

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
 
 浮漂随便放一个大概的位置 铅找底
 然后将浮漂下挪 水漫 浮漂最长子线长度并继续向下 五厘米以上 二十厘米包饵料漂浮
 //如果挂鱼饵操作的
 剪铅皮一直到露出目 这时候 鱼饵就距离水底 5或20厘米+目露出水面的高度
 //如果没挂鱼饵操作 则
 然后挂鱼饵 沉底后 修剪铅皮 到露出水面 这时候 鱼饵就距离水底 5或20厘米+目露出水面的高度
 
 //总结 找低后再挂吊钩
 
 
 */

//1 1 3 1 1


/*
 客厅卫生间
 不要浴缸
 镜子左边放常用杯子牙膏 镜子后柜子放备用
 卫生间用塑钢或者钢门 不能用木门
 坐便器做墙排水 15公分半墙 就是马桶后面
 卫生间n字型止水敦
 卫生间墙砖压地砖
 看看楼上是否有存水弯 深水封地漏
 卫生间装排风机 和止逆阀
 恒温花洒
 坐便器是否能围起来
 倒水线
 厕所灯 自动亮 需要灯头
 排水亵渎要足够
 
 厨房
 可移动插座
 地柜拉篮、 转角拉篮 L型
 可伸缩水龙头
 厨房台面 身高/2加5 大概 85到90
 烟道口装止逆阀
 水池子下装存水弯 防臭
 厨房吧台 做在外面 中间推拉门四开门 3c认证
洗手池管子接口处装防臭阀
净水器
 橱柜安装前 要清洗一下厨房
 
 客厅
 酒柜之类 带玻璃窗
 不要吊灯
 门口玄关 弄个放雨伞的 很窄就行 鞋柜底部留一个鞋子高度 放常用鞋，穿鞋凳 高45宽60 下面两层放常用鞋
 门窗合叶用304不锈钢
 鞋柜至少30公分、鞋柜上面是镜子
 电视柜要有藏线功能
 装一套嵌入式音响 声音电线要预埋在客厅下面
 沙发上安装插头
 
 
 
 
 卧室
 柜体 活动式层板 方便调整高度
 北次卧接入两个网线口
 无线网加强器
 床头装多点插座
 
 
 阳台
 洗衣伴侣
 高鞋柜 当季不穿的鞋
 两边留插座
 
 
 
 通用
 转角暗格 放体育用品 装个架子
 门要隔音 内部桥洞力学结构 t型结构加隔音条
 指纹锁要B级
 移动门用吊滑门 地上没有槽 四片门
  橱柜做无把手按压们
 客厅要耐磨砖 抛光砖 厨房墙壁用全抛釉砖 卫生间300防滑砖 要吸水率低的 阳台仿古石 不怕雨耐滑防腐蚀
 墙顶 墙壁 隔音棉
 太阳能 怎么处理的
 鞋柜护理机 鞋柜分区 每层隔板不要到头 留一点空隙落灰到最下面
 鞋柜上装插头
 地下室要贴瓷砖
 衣服伸缩架上面加个透明挡板
 各个房间要有一两网线接口通到多媒体箱
 插座有没有间隔大的 有的
 工具柜、药箱放哪
 
 
 
 验收
 留百分之五的保修金
 卫生间地面瓷片贴好后就试水，如果流水比较缓慢就立即返工，不然到时候洗澡时就会积水
 
 
 */




@end
