//
//  DynamicViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/6/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "DynamicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "DynamicTopViewController.h"
#import "PublishNewCell.h"
#import "JsonModel.h"
#import "SocketModel.h"

@interface DynamicViewController ()<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,ChatHandlerDelegate,UIActionSheetDelegate,NFCommentInputViewDelegate,UIGestureRecognizerDelegate>

//个人信息详情 【点击头像后的界面】
@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;

@end

@implementation DynamicViewController{
    
    __weak IBOutlet NFBaseTableView *dynamicTableView;
    
    NFMessageFaceView *faceView;
    BOOL isCommentComment_; // 是否评论的是当前的评论
    CGFloat _previousTooViewHeight; // 输入框的高度
    CGFloat previousTextViewContentHeight; // textview的高度
    double animationDuration; //动画时间
    CGRect keyboardRect; //键盘尺寸
    BOOL reloading_;
    BOOL    isCoach_;
    BOOL needReloading_;
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    
    EGORefreshTableHeaderView * refreshHeaderView_;
    
    // 帖子列表数据
    __strong NSMutableArray *dataSourceArr_;
    // 帖子创建时间 用于分页
    NSString *creatDate_;
    // 是否是请求第一页的数据
    BOOL isFirstData_;
    // 可能认识的人
    NSArray *mayKonwArr_;
    SocketModel * socketModel;
    //最后一条数据时间
    NSString *lastDynamicTime;
    //记录需要刷新的cell 点赞相关，当、【当在详情页面点赞客 需要在这里进行刷新】
    NSIndexPath *selectedIndexPath;
    //记录一下是否评论成功
    BOOL Iscomment;
    //记录键盘是否为弹出状态 弹出状态不允许请求刷新
    BOOL IsShowKeyboard;
    //评论输入框 后面的背景
    UIView * backgroundView;
    //点击动态详情后 pop回来传回来点赞状态分三种【nil没有点击赞按钮、0最后点赞状态为NO、1最后点赞状态为YES】，没有点击赞按钮则为nil不需要任何处理，当点击了赞按钮 则传回来点赞状态，再和原来的数据中的点赞状态相比较 相同则不作处理 不相同则进行改变点赞状态和点赞人数。
    NSString *IsPraise;
    NSMutableDictionary *rowHeightCache;
    //编辑名字后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    //记录选中的indexpath 【点击头像后 需要取zjcontact】
    NSIndexPath *DynamicSelectedIndexPath;
    JQFMDB *jqFmdb;
    BOOL IsPush;//是否走了didload
    
    SocketRequest *socketRequest;
    
//    UIButton * rightBarBtn;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //每次进来 用最新一条动态id请求 看看是否有心得动态 有则刷新
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    [self doneLoadingTableViewData];
    [self.messageToolView.messageInputTextView resignFirstResponder];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    if ([NFUserEntity shareInstance].IsRequestNearestDynamic && !reloading_ && !IsPush) {
        lastDynamicTime = nil;
        [self initScoket];
    }
    IsPush = NO;
    //如果有didselected 过去的cell 再次显示刷新该cell 防止点击了赞，当IsPraise为nil时 说明用户没有点击过赞按钮
    if (selectedIndexPath && ![NFUserEntity shareInstance].isNeedDeleteDidselectedPush && IsPraise.length > 0) {
        //刷新某个cell selectedIndexPath
        NoteListEntity *entity = dataSourceArr_[selectedIndexPath.section - 2];
        if ([IsPraise isEqualToString:@"1"] && [entity.isPraise isEqualToString:@"0"]) {
            entity.isPraise = @"1";
            NSInteger praiseCount = [entity.praiseCount integerValue];
            praiseCount += 1;
            entity.praiseCount = [NSString stringWithFormat:@"%ld",praiseCount];
        }else if ([IsPraise isEqualToString:@"0"] && [entity.isPraise isEqualToString:@"1"]){
            entity.isPraise = @"0";
            NSInteger praiseCount = [entity.praiseCount integerValue];
            praiseCount -= 1;
            entity.praiseCount = [NSString stringWithFormat:@"%ld",praiseCount];
        }
        [dynamicTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        selectedIndexPath = nil;
    }else{
        //如果isNeedDeleteDidselectedPush 为yes 到这里已经在block中用完了 治理置空
        [NFUserEntity shareInstance].isNeedDeleteDidselectedPush = NO;
    }
    [self registerForKeyboardNotifications];
    //当点击某人头像时候 这里会用到
    if (isFromEditName) {
        self.navigationController.navigationBarHidden = YES;
        self.tabBarController.tabBar.hidden = YES; //在NFTableViewController中走了NO 不知道哪里的父类
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
    
//    if(rightBarBtn && [rightBarBtn isKindOfClass:[UIButton class]]){
//       [rightBarBtn setTitle:[NSString stringWithFormat:@"%ld条新消息",[NFUserEntity shareInstance].dynamicBadgeCount] forState:(UIControlStateNormal)];
//    }
    
    //为了刷新  有新消息
    [dynamicTableView reloadData];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSLog(@"%d",self.tabBarController.tabBar.hidden);
}

-(void)viewWillDisappear:(BOOL)animated{
    //界面消失 设置为可刷新
    reloading_ = NO;
    [self removeForKeyboardNotifications];
    if (reloading_) {
        [self doneLoadingTableViewData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"动态";
    self.tabBarItem.title = @"动态";
    
    rowHeightCache = [NSMutableDictionary new];
    IsPush = YES;
    [self initCommentView];
    [self initUI];
    [self initScoket];
    
}

-(void)initUI{
    dataSourceArr_ = [@[] mutableCopy];
    
    // 网络请求
//    [self getNoteList];
    [self downUpdate];
    
    UIImageView *backImageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [backImageView setImage:[UIImage imageNamed:BackgroundImageView]];
//    dynamicTableView.backgroundView=backImageView;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
//    tap.delegate = self;
//    [self.view addGestureRecognizer:tap];
    
//    rightBarBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
//    //    [rightBtn setImage:[UIImage imageNamed:@"洛阳首页-+号"] forState:UIControlStateNormal];
//    //shouye_98
////    [rightBtn setImage:[UIImage imageNamed:@"表头添加好友"] forState:UIControlStateNormal];
//    [rightBarBtn setTitle:[NSString stringWithFormat:@"%ld条新消息",[NFUserEntity shareInstance].dynamicBadgeCount] forState:(UIControlStateNormal)];
//    rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [rightBarBtn addTarget:self action:@selector(handleRightBtn) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
//    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    
    
}

-(void)handleRightBtn{
    
    [NFUserEntity shareInstance].dynamicBadgeCount = 0;
   UITabBarItem *tabBarItemWillBadge = self.navigationController.tabBarController.tabBar.items[2];
   [tabBarItemWillBadge yee_MakeBadgeTextNum:0 textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBigBadge]];
    [tabBarItemWillBadge removeBadgeView];
    
    
//    [socketRequest getCircleUnreadMsg];
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    PointListTableViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"PointListTableViewController"];
    [self.navigationController pushViewController:detailVC animated:YES];
    
    
    
    
    
}

-(void)newMessageClick{
    
        [NFUserEntity shareInstance].dynamicBadgeCount = 0;
       UITabBarItem *tabBarItemWillBadge = self.navigationController.tabBarController.tabBar.items[2];
       [tabBarItemWillBadge yee_MakeBadgeTextNum:0 textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBigBadge]];
        [tabBarItemWillBadge removeBadgeView];
        
    //    [socketRequest getCircleUnreadMsg];
        
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
        PointListTableViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"PointListTableViewController"];
        [self.navigationController pushViewController:detailVC animated:YES];
    
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    [self hideKeyBoard];
//    return NO;
//}

#pragma mark - 初始化scoket
-(void)initScoket{
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //当connect时不一定通的
    if (socketModel.isConnected) {
        [socketModel ping];
    }
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
        reloading_ = NO;
        return;
    }
    if (socketModel.isConnected) {
        [self getDynamicRequest];
        [socketRequest getCircleMsg];
    }else{
        reloading_ = NO;
    }
}

- (void)messageBtnClick
{
//    NFSystemMessage *messageCtrol = [[NFSystemMessage alloc] init];
//    [self.navigationController pushViewController:messageCtrol animated:YES];
}

- (void)qaCodeBtnClick
{
    //跳转扫描二维码
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
//    QRCodeScanViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"QRCodeScanViewController"];
//    [self.navigationController pushViewController:qrcodeScanVC animated:YES];
}

#pragma mark - 设置下拉刷新
- (void)downUpdate
{
    dynamicTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - dynamicTableView.bounds.size.height, dynamicTableView.frame.size.width, dynamicTableView.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        [dynamicTableView addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
}

#pragma mark - 请求动态
-(void)getDynamicRequest{
    [SVProgressHUD show];
    [rowHeightCache removeAllObjects];
    reloading_ = YES;
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getCircleList";
    if (lastDynamicTime) {
        self.parms[@"lastTime"] = lastDynamicTime;
    }else{
        self.parms[@"lastTime"] = [NFMyManage getCurrentTimeStamp];
        //这里设置为 可刷新 什么意思 【为了在 返回里面 移除所有数据】
        [NFUserEntity shareInstance].IsRequestNearestDynamic = YES;
    }
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //
        
    }
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doneLoadingTableViewData];
    });
    if (messageType == SecretLetterType_DynamicList){
//        if (Iscomment) {
//            [SVProgressHUD showSuccessWithStatus:@"评论成功"];
//            Iscomment = NO;
//        }
        reloading_ = NO;
        //进行界面赋值
        NSArray *dataArr = chatModel;
        //动态暂未开放
        [SVProgressHUD showInfoWithStatus:@"暂未开放"];
        return;
        
        
        if ([dataArr count] == 10)
        {
            canRefreshLash_ = YES;
        }
        else
        {
            canRefreshLash_ = NO;
        }
        if ([NFUserEntity shareInstance].IsRequestNearestDynamic) {
            [dataSourceArr_ removeAllObjects];
        }
        [dataSourceArr_ addObjectsFromArray:dataArr];
        //选中的cell 转成indexpath
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:self.selectCommentIndexpath.section];
        //如果不是来自评论刷新动态 则不需要滚动到某一行 直接reload tableview即可
        if (!self.selectCommentIndexpath) {
            //在这里再进行dismiss 兼容了评论的时候 评论动态count大于返回最大count10
            if (!Iscomment) {
                [SVProgressHUD dismiss];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"评论成功"];
            }
            [dynamicTableView reloadData];
        }
        if (dataSourceArr_.count > 0)
        {
            //记录最后一条动态
            NoteListEntity *listEntity = [dataSourceArr_ lastObject];
            lastDynamicTime = listEntity.createDate;
            [dynamicTableView removeNone];
        }else{
            //当数据为空 显示图片
            if (dataSourceArr_.count == 0) {
                dynamicTableView.isNeed = YES;
                //            [MessageChatListTableview showNone];
                [dynamicTableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"暂无动态"];
            }
            //到这里 所有应该出现的数据已经都出现 线reloaddata 在进行具体显示哪一行
            [dynamicTableView reloadData];
        }
        [NFUserEntity shareInstance].IsRequestNearestDynamic = NO;
        if (self.selectCommentIndexpath) {
            //滚动到评论的section
            //            /self.selectCommentIndexpath
            //当记录选中的动态cell的indexpath超过了返回的最大count，则设置滚动到最后一个cell，如果需要做到 滚动到精确的indexpath，那么需要
            if (index.section >= dataSourceArr_.count + 2 ) {
                //当在这里处理时 正在处于请求动态状态 设置为yes，否则会在returntableviewcell中调用请求动态
                isRefreshLashing_ = YES;
                [self getDynamicRequest];
                return;
                //下面代码意思是 当评论的位置动态大于10，那么就让界面滚动到10，下面的再进行请求 这样体验很不好
//                index = [NSIndexPath indexPathForRow:0 inSection:dataSourceArr_.count + 2];
            }else{
                //当确定彻底不需要请求了再进行弹出评论成功
                if (Iscomment) {
                    [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                    Iscomment = NO;
                }
                //设置为非刷新状态
                isRefreshLashing_ = NO;
            }
            //到这里 所有应该出现的数据已经都出现 线reloaddata 在进行具体显示哪一行
            [dynamicTableView reloadData];
            //滚动到评论选中的indexpath最后一行 -2因为有两个额外增加的section【发表动态和隐藏的可能认识的好友动态】
            NoteListEntity *showEntity;
            //NSLog(@"%ld\n%ld",index.section,index.row);
            showEntity = dataSourceArr_[index.section - 2];
            index = [NSIndexPath indexPathForRow:showEntity.commentArr.count-1 inSection:self.selectCommentIndexpath.section];
            //当滚动到评论的cell后 选中cell置空
            self.selectCommentIndexpath = nil;
            //[dynamicTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }else if (messageType == SecretLetterType_DynamicDianzan) {
        //点赞、取消点赞 成功返回
        if ([chatModel isKindOfClass:[NSString class]]) {
            NoteListEntity *entity = [dataSourceArr_ objectAtIndex:self.zanIndexpath.section - 2];
            entity.currentUserLike = chatModel;
        }
    }else if (messageType == SecretLetterType_DynamicSuccess){
        NSDictionary *dict = [NSDictionary new];
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            dict = chatModel;
            if ([[dict objectForKey:@"type"] isEqualToString:@"6017"]) {
                //删除动态成功
                if(dataSourceArr_.count <= self.selectCommentIndexpath.section - 2){
                    return;
                }
                NoteListEntity *entity = [dataSourceArr_ objectAtIndex:self.selectCommentIndexpath.section - 2];
                NSMutableArray *commentArr = entity.commentArr;
                NoteCommentEntity *commentEntity = commentArr[self.selectCommentIndexpath.row - 1];
                [entity.commentArr removeObject:commentEntity];
                [dynamicTableView reloadData];
                
            }
        }
    }else if (messageType == SecretLetterType_DynamicFail){
        NSDictionary *dict = [NSDictionary new];
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            dict = chatModel;
            if ([[dict objectForKey:@"type"] isEqualToString:@"6018"]) {
                //删除动态失败
                [SVProgressHUD showErrorWithStatus:@"删除失败"];
            }
        }
    }else if (messageType == SecretLetterType_DynamicReturnDict){
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDict = chatModel;
            if ([[resultDict objectForKey:@"type"] isEqualToString:@"6011"]) {
                [SVProgressHUD showInfoWithStatus:@"操作成功!"];
                //self.selectCommentIndexpath
                [dynamicTableView reloadData];
                
            }
        }
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [self doneLoadingTableViewData];
        //[SVProgressHUD showInfoWithStatus:kWrongMessage];
    }else if(messageType == SecretLetterType_receiveDynamicCount){
//        [rightBarBtn setTitle:[NSString stringWithFormat:@"%ld条新消息",[NFUserEntity shareInstance].dynamicBadgeCount] forState:(UIControlStateNormal)];
        [dynamicTableView reloadData];
    }else if(messageType == SecretLetterType_receiveDynamicCount){
        
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
        PointListTableViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"PointListTableViewController"];
        [self.navigationController pushViewController:detailVC animated:YES];
        
    }
}


#pragma mark - tableViewDelegate & tableViewDateSource
//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 0.1;
    }
    if([NFUserEntity shareInstance].dynamicBadgeCount > 0 && section == 2){
        return 50;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:UIColorFromRGB(0xd3d6db)];
    if([NFUserEntity shareInstance].dynamicBadgeCount > 0 && section == 2){
        UIButton *sureBtn = [UIButton new];
        [sureBtn setTitle:@"有新消息" forState:(UIControlStateNormal)];
        sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sureBtn setBackgroundColor:[UIColor grayColor]];
        ViewRadius(sureBtn, 3);
        [sureBtn addTarget:self action:@selector(newMessageClick) forControlEvents:(UIControlEventTouchDown)];
        [headerView addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(headerView.mas_centerX);
            make.centerY.mas_equalTo(headerView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH/4, 30));
        }];
    }
    return headerView;
}

//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (canRefreshLash_)
    {
        return dataSourceArr_.count + 3;
    }
    return dataSourceArr_.count + 2;
    return 1;
}

//返回分区行数 由于回复需要体现在动态页 所以row个数需要特殊处理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 0;
    }
    //当为可刷新的最后一条数据时 为一个cell
    if (canRefreshLash_ && section == dataSourceArr_.count + 2) {
        return 1;
    }
    NoteListEntity *entity = [NoteListEntity new];
    entity = [dataSourceArr_ objectAtIndex:section - 2];
    return entity.commentArr.count +1;
//    if (canRefreshLash_)
//    {
//        return dataSourceArr_.count + 3;
//    }
//    return dataSourceArr_.count + 2;   // 包括一个可能认识的人和一个发布cell
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //当有上啦刷新 section最后一个就是数据个数加2个row
    if (canRefreshLash_ && indexPath.section == dataSourceArr_.count + 2)
    {
        return 44 - 10;
    }
    if (indexPath.section == 0)
    {
        return PublishNewCellHeight;
    }
    else if (indexPath.section == 1)
    {
        //可能认识的人 为0
        if (mayKonwArr_.count == 0)
        {
            return 0;
        }
        return 100;
    }
    else if (indexPath.section >= 2){
        NoteListEntity *entity = [NoteListEntity new];
        entity = [dataSourceArr_ objectAtIndex:indexPath.section - 2];
        if (indexPath.row == 0) {
            if ([entity.shareType integerValue] == 1) {// 分享的普通帖子
                if (entity.noteEntity.photoList.count == 0)
                {
                    
                    return [RelayOnlyTextCell getContentCellHeight:entity.noteContent seeingMore:entity.isExetend];
                }
                else
                {
                    return [RelayTextAndPicCell getContentCellHeight:entity.noteContent seeingMore:entity.isExetend];
                }
            }else{ // 正常的帖子 不是分享的
                if (entity.photoList.count == 0)
                {
                    if ([rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]]) {
                        NSNumber *cacheHeight = [rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
                        return [cacheHeight floatValue];
                    }
                    CGFloat height = [OnlyTextTableViewCell getContentCellHeight:entity.circle_content seeingMore:entity.isExetend];
                    NSNumber *cacheHeight = [[NSNumber alloc] initWithFloat:height];
                    [rowHeightCache setValue:cacheHeight forKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
                    return height;
                }else
                {
                    if ([rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]]) {
                        NSNumber *cacheHeight = [rowHeightCache objectForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
                        return [cacheHeight floatValue];
                    }
                    CGFloat height =  [ContentNewCell getContentCellHeight:entity.circle_content seeingMore:entity.isExetend];
                    NSNumber *cacheHeight = [[NSNumber alloc] initWithFloat:height];
                    [rowHeightCache setValue:cacheHeight forKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
                    return height;
                }
            }
        }
        NSArray *commentArr = entity.commentArr;
        NoteCommentEntity *commentEntity = commentArr[indexPath.row - 1];
        //评论高度
        CGFloat h = [dynamicTableView cellHeightForIndexPath:indexPath model:commentEntity keyPath:@"model" cellClass:[DynamicCommentTableViewCell class] contentViewWidth:SCREEN_WIDTH - 10.f];
        return h;
//        return [DynamicCommentTableViewCell getContentCellHeight:commentEntity seeingMore:YES];
    }
    return 0;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellidentifer;
    if (canRefreshLash_ && indexPath.section == dataSourceArr_.count + 2)
    {
        cellidentifer = @"moreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] init];
        }
        //判断是否为无刷新并且为键盘收起状态
        if (NO == isRefreshLashing_ && !IsShowKeyboard)
        {
            [self performSelector:@selector(getDynamicRequest) withObject:nil afterDelay:0.2];
            //当为上拉加载时，不进行滚动到某个选中的cell操作【当用户点击评论但没评论时候 会出现这个bug】
            self.selectCommentIndexpath = nil;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == 0) {
        cellidentifer = @"PublishNewCell";
        PublishNewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"PublishNewCell" owner:nil options:nil]firstObject];
        }
        [cell reloadImage];
        return cell;
    }else if (indexPath.section == 1)
    {
        if (mayKonwArr_.count > 0) // 有好友列表才展示
        {
            cellidentifer = @"MayKnowPeopleCell";
//            MayKnowPeopleCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
//            if (cell == nil) {
//                cell = [[[NSBundle mainBundle]loadNibNamed:@"MayKnowPeopleCell" owner:nil options:nil]firstObject];
//            }
//            [cell setCellWith:mayKonwArr_];
//            cell.titleLabel.text = @"可能认识的人";
//            cell.showType = ShowTypePeople;
            cellidentifer = @"cell";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifer];
            }
            return cell;
        }
    }else if (indexPath.section >= 2){
        NoteListEntity *entity = [dataSourceArr_ objectAtIndex:indexPath.section - 2];
//        if (canRefreshLash_) {
//            entity = [dataSourceArr_ objectAtIndex:indexPath.section - 3];
//        }else{
//            entity = [dataSourceArr_ objectAtIndex:indexPath.section - 3];
//        }
        //评论
        NSArray *commentArr = entity.commentArr;
        if ([entity.shareType integerValue] == 1) {// 分享的普通帖子
            if (entity.noteEntity.photoList.count == 0)
            {
                cellidentifer = @"RelayOnlyTextCell";
                RelayOnlyTextCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
                if (cell == nil)
                {
                    cell = [[[NSBundle mainBundle]loadNibNamed:@"RelayOnlyTextCell" owner:nil options:nil]firstObject];
                }
                [cell showCellWithEntity:entity
                          withDataSource:dataSourceArr_
                             commentView:nil
                           withTableView:tableView
                             atIndexPath:indexPath];
                return cell;
            }
            else
            {
                if (indexPath.row == 0) {
                    cellidentifer = @"RelayTextAndPicCell";
                    RelayTextAndPicCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle]loadNibNamed:@"RelayTextAndPicCell" owner:nil options:nil]firstObject];
                    };
                    [cell showCellWithEntity:entity
                              withDataSource:dataSourceArr_
                                 commentView:nil
                               withTableView:tableView
                                 atIndexPath:indexPath];
                    return cell;
                }
            }
        }else {
            if (entity.photoList.count == 0)
            {
                //纯文字贴
                if (indexPath.row == 0) {
                    return [self returnOnlyTextTableViewCellWithIndexPath:indexPath];
                }
            }else
            {
                if (indexPath.row == 0) {
                    return [self returnCellContentNewCellWithIndexPath:indexPath];
                }
            }
            //评论s
            NoteCommentEntity *commentEntity = commentArr[indexPath.row - 1];
            cellidentifer = @"DynamicCommentTableViewCell";
            DynamicCommentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"DynamicCommentTableViewCell" owner:nil options:nil]firstObject];
            };
            cell.commentLabel.userInteractionEnabled = NO;
            [cell setModel:commentEntity];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
            return cell;
        }
    }
    cellidentifer = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifer];
    }
    cell.textLabel.text = @"ainitWithStyle";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //当在请求动态时 不允许进行评论点击 这样会导致选中的indexpath被误用
    if ([SVProgressHUD isVisible] && Iscomment) {
        return;
    }
    if (indexPath.section == dataSourceArr_.count + 3 - 1)
    {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [SVProgressHUD showInfoWithStatus:@"暂未开放"];
    return;
    
    
    if (indexPath.section == 0)
    {
        //当选中的是发布动态 则回来不需要刷新row 因为那时候row还不存在
        selectedIndexPath = nil;
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
        PublishDynamicViewController *pubvc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
        __weak typeof(self)weakSelf=self;
        //没用到
        pubvc.successBlock = ^(BOOL success){
            // 发布成功 重新刷新
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"发布成功！"];
                [weakSelf performSelector:@selector(getNoteList) withObject:nil afterDelay:1];
            }
        };
        
        [self.navigationController pushViewController:pubvc animated:YES];
        return;
    }
    //点击动态详情 记录 indexpath 再次显示 刷新该cell
    NoteListEntity *entity = [dataSourceArr_ objectAtIndex:indexPath.section - 2];
    if (indexPath.row == 0) {
        selectedIndexPath = indexPath;
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
        DynamicNewDetailViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"DynamicNewDetailViewController"];
        detailVC.entityid = entity.circle_id;
        if (entity.photoList.count == 0){
            [NFUserEntity shareInstance].isPicImageDynamic = NO;
        }else{
            [NFUserEntity shareInstance].isPicImageDynamic = YES;
        }
        //是否需要删除该动态 【从详情页 返回的】
        dynamicTableView.tableFooterView = [UIView new];
        NSLog(@"\n%d\n%d\n",indexPath.section,indexPath.section);
        __weak typeof(self)weakSelf=self;
        [detailVC returnDeleteBlock:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            [strongSelf ->dataSourceArr_ removeObjectAtIndex:indexPath.section - 2];
            [strongSelf ->dynamicTableView reloadData];
        }];
        //返回点赞状态 当详情界面见将要消失的时候 将点赞状态传回来，在willappear中进行比对是否发生改变。
        [detailVC setReturnPraiseBlock:^(BOOL ret) {
            if (ret && [entity.isPraise isEqualToString:@"0"]) {
                IsPraise = @"1";
            }else if(!ret && [entity.isPraise isEqualToString:@"1"]){
                IsPraise = @"0";
            }
        }];
        //详情数据
        detailVC.noteListEntity = entity;
        //每次点击cell 到详情 将标记的是否点赞初始化
        IsPraise = nil;
        [self.navigationController pushViewController:detailVC animated:YES];
        return;
    }
    //点击评论为回复
    socketModel.delegate = self;
    NSArray *commentArr = entity.commentArr;
    NoteCommentEntity *commentEntity = commentArr[indexPath.row - 1];
    if ([commentEntity.user_id isEqualToString:[NFUserEntity shareInstance].userId])
    {
        //当为点击自己的回复 弹出删除时
        self.selectCommentIndexpath = indexPath;
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"删除评论", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (0 == buttonIndex)
            {
                NoteListEntity *entity = [dataSourceArr_ objectAtIndex:self.selectCommentIndexpath.section - 2];
                NSMutableArray *commentArr = entity.commentArr;
                NoteCommentEntity *commentEntity = commentArr[self.selectCommentIndexpath.row - 1];
                [commentArr removeObjectAtIndex:self.selectCommentIndexpath.row - 1];
                [self deleteComment:commentEntity];
            }
            //点击取消、点击空白部分 则将选中置空。
            self.selectCommentIndexpath = nil;
        }];
        [sheet show];
        return;
    }
    //当为评论时 记录选中的indexpath
    self.selectCommentIndexpath = indexPath;
    self.messageToolView.commentType = @"2";
    //这里和键盘将要显示 那里都要设置
    //动态id
    self.messageToolView.commentId = commentEntity.circle_id;
    //评论id 有就用
    self.messageToolView.byCommId = commentEntity.comment_id;
    self.messageToolView.isFromHome = NO;
//    self.messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",commentEntity.user_name];
    self.messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",commentEntity.user_nickName?commentEntity.user_nickName:commentEntity.user_name];
    backgroundView.backgroundColor = [UIColor colorWithHue:0
                                                saturation:0
                                                brightness:0 alpha:0.1]; //好看的灰色背景
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    backgroundView = [[UIView alloc] initWithFrame:win.bounds];
    [win addSubview:backgroundView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClickk)];
    [backgroundView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClickk)];
    [backgroundView addGestureRecognizer:pan];
    [self.messageToolView.messageInputTextView becomeFirstResponder];
    
}

#pragma mark - return 纯文字Cell
-(OnlyTextTableViewCell *)returnOnlyTextTableViewCellWithIndexPath:(NSIndexPath *)indexPath{
    //纯文字贴
    static NSString * cellidentifer;
    NoteListEntity *entity = [dataSourceArr_ objectAtIndex:indexPath.section - 2];
    NSArray *commentArr = entity.commentArr;
    if (indexPath.row == 0) {
        cellidentifer = @"OnlyTextTableViewCell";
        OnlyTextTableViewCell * cell = [dynamicTableView dequeueReusableCellWithIdentifier:cellidentifer];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"OnlyTextTableViewCell" owner:nil options:nil]firstObject];
        }
        [cell showCellWithEntity:entity
                  withDataSource:dataSourceArr_ CacheHeightDict:rowHeightCache
                     commentView:nil
                   withTableView:dynamicTableView
                     atIndexPath:indexPath];
        
        if (commentArr.count > 0) {
            cell.middleLineLabel.hidden = YES;
            cell.bottomLineHeightConstaint.constant = 1;
        }else{
            cell.middleLineLabel.hidden = NO;
            cell.bottomLineHeightConstaint.constant = 0;
            
        }
        //点击头像后
        __weak typeof(self)weakSelf=self;
        [cell.headImageView afterClickHeadImage:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            DynamicSelectedIndexPath = indexPath;
            dynamicTableView.scrollEnabled = NO;
            strongSelf.ZJContactDetailController.view  = nil;
            strongSelf.ZJContactDetailController  = nil;
            if (strongSelf.ZJContactDetailController == nil) {
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
                strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
                //设置单聊详情数据
                //            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
                ZJContact *contact = [ZJContact new];
                contact.friend_userid = entity.user_id;
                contact.friend_username = entity.user_name;
                contact.friend_nickname  = entity.nickname;
                //contact.friend_originalnickname  = entity.ori;
                contact.in_group_name  = entity.nickname?entity.nickname:entity.user_name;;
                contact.iconUrl = entity.photo;;//头像
                //对于详情页面的赋值
                strongSelf.ZJContactDetailController.contant = contact;
                strongSelf.ZJContactDetailController.SourceFrom = @"1";
                [weakSelf addChildViewController:strongSelf.ZJContactDetailController];
                strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                //点击了headview上面的事件
                strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
                    if (index == 0 || index == 10) {
                        //移除ZJContactDetailController
                        [UIView animateWithDuration:0.2 animations:^{
                            dynamicTableView.scrollEnabled = YES;
                            weakSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                        } completion:^(BOOL finished) {
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            [weakSelf.ZJContactDetailController.view removeFromSuperview];
                            //当移除界面后 设置来自编辑名字为no
                            strongSelf ->isFromEditName = NO;
                        }];
                        
                        weakSelf.navigationController.navigationBarHidden = NO;//显示出导航栏和tabbar
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
//                ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
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
                    weakSelf.navigationController.navigationBarHidden = YES;
                    weakSelf.tabBarController.tabBar.hidden = YES;
                    weakSelf.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                }];
            }
        }];
        [cell useCellFrameCacheWithIndexPath:indexPath tableView:dynamicTableView];
        return cell;
    }
    return nil;//不可能到这里的
}

#pragma mark - return 带图片的
-(ContentNewCell *)returnCellContentNewCellWithIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellidentifer;
    NoteListEntity *entity = [dataSourceArr_ objectAtIndex:indexPath.section - 2];
    NSArray *commentArr = entity.commentArr;
    //图片帖
    cellidentifer = @"ContentNewCell";
    ContentNewCell * cell = [dynamicTableView dequeueReusableCellWithIdentifier:cellidentifer];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ContentNewCell" owner:nil options:nil]firstObject];
    }
    cell.tag = 1000;
    cell.isVideo = NO;
    [cell showCellWithEntity:entity
              withDataSource:dataSourceArr_ CacheHeightDict:rowHeightCache
                 commentView:nil
               withTableView:dynamicTableView
                 atIndexPath:indexPath];
    if (commentArr.count > 0) {
        cell.bottomLineHeightConstaint.constant = 1;
        cell.middleLineLabel.hidden = YES;
    }else{
        cell.bottomLineHeightConstaint.constant = 0;
        cell.middleLineLabel.hidden = NO;
    }
    
    //点击头像后
    __weak typeof(self)weakSelf=self;
    [cell.headImageView afterClickHeadImage:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        DynamicSelectedIndexPath = indexPath;
        dynamicTableView.scrollEnabled = NO;
        strongSelf.ZJContactDetailController.view  = nil;
        strongSelf.ZJContactDetailController  = nil;
        if (strongSelf.ZJContactDetailController == nil) {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
            strongSelf.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
            //设置单聊详情数据
            //            ZJContact *contact = weakSelf.groupCreateSEntity.groupAllUser[index.item];
            ZJContact *contact = [ZJContact new];
            contact.friend_userid = entity.user_id;
            contact.friend_username = entity.user_name;
            contact.friend_nickname  = entity.nickname;
            //contact.friend_originalnickname  = entity.message.originalNickName;
            contact.in_group_name  = entity.nickname?entity.nickname:entity.user_name;;
            contact.iconUrl = entity.photo;;//头像
            //对于详情页面的赋值
            strongSelf.ZJContactDetailController.contant = contact;
            strongSelf.ZJContactDetailController.SourceFrom = @"1";
            [weakSelf addChildViewController:strongSelf.ZJContactDetailController];
            strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
            //点击了headview上面的事件
            strongSelf.ZJContactDetailController.clickWhich = ^(int index) {
                if (index == 0 || index == 10) {
                    //移除ZJContactDetailController
                    [UIView animateWithDuration:0.2 animations:^{
                        dynamicTableView.scrollEnabled = YES;
                        weakSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                    } completion:^(BOOL finished) {
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        [weakSelf.ZJContactDetailController.view removeFromSuperview];
                        //当移除界面后 设置来自编辑名字为no
                        strongSelf ->isFromEditName = NO;
                    }];
                    
                    weakSelf.navigationController.navigationBarHidden = NO;//显示出导航栏和tabbar
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
                weakSelf.navigationController.navigationBarHidden = YES;
                weakSelf.tabBarController.tabBar.hidden = YES;
                weakSelf.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            } completion:^(BOOL finished) {
            }];
        }
    }];
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:dynamicTableView];
    return cell;
}
#pragma mark - ***************

#pragma mark - 免费聊天
-(void)freeChatClick:(UIButton *)button event:(UIEvent *)event{
    isFromEditName = YES;//由于动态已经为根视图 所以pop回来需要设置为yes
    //    self.navigationController.navigationBarHidden = NO;
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:dynamicTableView];
//    NSIndexPath *indexPath = [dynamicTableView indexPathForRowAtPoint:currentTouchPosition];
    NSIndexPath *indexPath = DynamicSelectedIndexPath;
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
    //    NSInteger index = [_sectionIndexs[selectedIndexPath.section - 1] integerValue];
    //    NSArray *temp = _data[index];
    //    ZJContact *contact = (ZJContact *)temp[selectedIndexPath.row];
//    NSLog(@"%ld",DynamicSelectedIndexPath.row);
    //
    NoteListEntity *entity = [dataSourceArr_ objectAtIndex:indexPath.section - 2];
    ZJContact *contact = [ZJContact new];
    contact.friend_userid = entity.user_id;
    contact.friend_username = entity.user_name;
    contact.friend_nickname  = entity.nickname;
    contact.in_group_name  = entity.nickname?entity.nickname:entity.user_name;;
    contact.iconUrl = entity.photo;;//头像
    
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
    toCtrol.chatType = @"0";
    
    toCtrol.singleContactEntity = contact;
    [self.navigationController pushViewController:toCtrol animated:YES];
}


-(void)tapBackgroundClickk{
    [backgroundView removeFromSuperview];
    [self hideKeyBoard];
}

// 点击删除自己发表的评论
- (void)deleteComment:(NoteCommentEntity *)entity
{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"delCircleComment";
    self.parms[@"commentId"] = entity.comment_id;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

- (void)initCommentView
{
    self.messageToolView = [[NFCommentInputView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT - 45,SCREEN_WIDTH , 45)];
    self.messageToolView.delegate = self;
    self.messageToolView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:254.0/255 alpha:1];
    [self.view addSubview:self.messageToolView];
    
}

//注册键盘弹起隐藏通知
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

//移除键盘通知
- (void)removeForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//键盘将要弹起
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    // 注意不要用UIKeyboardFrameBeginUserInfoKey，第三方键盘可能会存在高度不准，相差40高度的问题
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    // 修改滚动天和tableView的contentInset
    //将tableview下方内缩键盘高度
    dynamicTableView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    dynamicTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    // 跳转到当前点击的输入框所在的cell
//    NSLog(@"\n%d\n%d\n",self.selectCommentIndexpath.section,self.selectCommentIndexpath.row);
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //将选中的cell 动画scroll到最底端
        [strongSelf ->dynamicTableView scrollToRowAtIndexPath:weakSelf.selectCommentIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    
    dynamicTableView.contentInset = UIEdgeInsetsZero;
    dynamicTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark - ZBMessageDelegate
// 键盘将要显示
- (void)keyBoardWillShow:(CGRect)rect animationDuration:(CGFloat)duration
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    if (![currentVC isKindOfClass:[self class]]) {
        return;
    }
    socketModel.delegate = self;
    NoteListEntity *entity = [NoteListEntity new];
    //一半都是有selectCommentIndexpath的
    if (self.selectCommentIndexpath) {
        entity = [dataSourceArr_ objectAtIndex:self.selectCommentIndexpath.section - 2];
    }
    //评论
    NoteCommentEntity *commentEntity = [NoteCommentEntity new];
    if (entity.commentArr.count > 0) {
        NSArray *commentArr = entity.commentArr;
        NSLog(@"\nrow:%d\n",self.selectCommentIndexpath.row);
        if (self.selectCommentIndexpath.row >= 1) {
            commentEntity = commentArr[self.selectCommentIndexpath.row - 1];
        }
    }
    if (commentEntity.comment_id) {
        //回复别人
        self.messageToolView.commentType = @"2";
        self.messageToolView.commentId = commentEntity.circle_id;
        self.messageToolView.byCommId = commentEntity.comment_id;
        self.messageToolView.isFromHome = NO;
//        self.messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",commentEntity.user_name];
        self.messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",commentEntity.user_nickName?commentEntity.user_nickName:commentEntity.user_name];
    }else{
        //评论动态
        self.messageToolView.commentType = @"2";
        self.messageToolView.commentId = entity.circle_id;
        self.messageToolView.byCommId = nil;
        self.messageToolView.isFromHome = NO;
//        self.messageToolView.messageInputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",entity.user_name];
        self.messageToolView.messageInputTextView.placeHolder = @"评论";
    }
//    }
    keyboardRect = rect;
    animationDuration = duration;
    [self messageViewAnimationWithMessageRect:rect withMessageInputViewRect:self.messageToolView.frame andDuration:duration andState:ZBMessageViewStateShowNone];
    
}

#pragma mark - NFCommentInputView中评论成功 block回调这里刷新动态
// 评论成功
- (void)commentSuccess
{
    //上面需要传过来一个评论实体 在NFCommentInputView中dideceive中生成
    //生成评论直接插入到数据
//    NoteListEntity *entity = [dataSourceArr_ objectAtIndex:self.selectCommentIndexpath - 2];
//    [entity.commentArr addObject:@""];
//    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:self.selectCommentIndexpath];
//    [dynamicTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // 评论成功 重新获取评论列表
    [SVProgressHUD showSuccessWithStatus:@"评论成功"];
    //记录一下评论成功
    Iscomment = YES;
    socketModel.delegate = self;
    lastDynamicTime = nil;
    [self getDynamicRequest];
}

// 键盘将要消失
- (void)keyBoardWillHidden:(CGRect)rect animationDuration:(CGFloat)duration
{
    isCommentComment_ = NO;
    keyboardRect = rect;
    animationDuration = duration;
    [self hideKeyBoard];
    //键盘消失 允许刷新界面
    IsShowKeyboard = NO;
    //键盘将要消失 选中indexpath 置空 【不可以这么做，当评论成功 键盘也会消失，但是刷新评论后需要滚动到评论的这个cell的最后一个row，在这里置空了，那么if (self.selectCommentIndexpath) 这个在didreceive返回的判断将永远不会执行，逻辑和下拉刷新一样了 只是多了iscomment为YES，显示评论成功。】
//    self.selectCommentIndexpath = nil;
    
}

// 键盘已经弹出
- (void)keyBoardChange:(CGRect)rect animationDuration:(CGFloat)duration
{
    NSLog(@"");
}

// 开始编辑
- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView
{
    [self messageViewAnimationWithMessageRect:keyboardRect
                     withMessageInputViewRect:self.messageToolView.frame
                                  andDuration:animationDuration
                                     andState:ZBMessageViewStateShowNone];
    if (!previousTextViewContentHeight)
    {
        previousTextViewContentHeight = messageInputTextView.contentSize.height;
    }
}

//将要开始编辑
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView
{
    //键盘弹出来的时候 不允许刷新 ，因为当评论第10条数据时 会触发刷新界面
    IsShowKeyboard = YES;
}

// 正在编辑
- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView
{
    CGFloat maxHeight = [NFCommentInputView maxHeight];
    CGSize size = [messageInputTextView sizeThatFits:CGSizeMake(CGRectGetWidth(messageInputTextView.frame), maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    BOOL isShrinking = textViewContentHeight < previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - previousTextViewContentHeight;
    if(!isShrinking && previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - previousTextViewContentHeight);
    }
    if(changeInHeight != 0.0f) {
        __weak typeof(self)weakSelf=self;
        [UIView animateWithDuration:0.01f
                         animations:^{
                             [messageInputTextView scrollRectToVisible:CGRectMake(0, messageInputTextView.contentSize.height-10, 50, 10) animated:YES];
                             if(isShrinking)
                             {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [weakSelf.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                             CGRect inputViewFrame = weakSelf.messageToolView.frame;
                             weakSelf.messageToolView.frame = CGRectMake(0.0f,
                                                                inputViewFrame.origin.y - changeInHeight,
                                                                inputViewFrame.size.width,
                                                                inputViewFrame.size.height + changeInHeight);
                             if(!isShrinking)
                             {
                                 [weakSelf.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
}

- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:duration animations:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        weakSelf.messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(weakSelf.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(weakSelf.view.frame),CGRectGetHeight(inputViewRect));
        switch (state)
        {
            case ZBMessageViewStateShowFace:
            {
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(weakSelf.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(weakSelf.view.frame),CGRectGetHeight(rect));
            }
                break;
            case ZBMessageViewStateShowVoice:
            {
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(weakSelf.view.frame),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(strongSelf ->faceView.frame));
            }
                break;
            case ZBMessageViewStateShowNone:
            {
                if (rect.size.width == 0.0)
                {
                    //收到最底部
                    weakSelf.messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(weakSelf.view.frame) - 45,CGRectGetWidth(weakSelf.view.frame),45);
                }
                else
                {
                    if (_previousTooViewHeight != 0)
                    {
                        //显示在键盘上面
                        strongSelf.messageToolView.frame = CGRectMake(inputViewRect.origin.x, inputViewRect.origin.y, inputViewRect.size.width, strongSelf ->_previousTooViewHeight);
                        strongSelf ->_previousTooViewHeight = 0.0;
                    }
                }
                strongSelf ->faceView.frame = CGRectMake(0.0f,CGRectGetHeight(strongSelf.view.frame),CGRectGetWidth(strongSelf.view.frame),CGRectGetHeight(strongSelf ->faceView.frame));
            }
                break;
            default:
                break;
        }
    } completion:^(BOOL finished) {
    }];
}

-(void)hideKeyBoard
{
    self.messageToolView.messageInputTextView.placeHolder = @"";
    [self.messageToolView.messageInputTextView resignFirstResponder];
    CGFloat inputViewHeight;
    if (UIDeviceCurrentDevice >= 7)
    {
        inputViewHeight = 45.0f;
    }
    else{
        inputViewHeight = 40.0f;
    }
    self.messageToolView.frame = CGRectMake(0.0f,self.view.frame.size.height - self.messageToolView.frame.size.height,self.view.frame.size.width,self.messageToolView.frame.size.height);
    faceView.frame = CGRectMake(0.0f,
                                CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 196);
}

//发送文本
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView
{
    NSLog(@"sendmessage");
}

#pragma mark - 下拉刷新4
#pragma mark - scrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyBoard];
}

// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView_ egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    socketModel.delegate = self;
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
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:dynamicTableView];
}

#pragma mark - 下拉刷新委托回调
//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
#pragma mark - 下拉刷新6
    //下拉后 选中的indexpath取消
    self.selectCommentIndexpath = nil;
    Iscomment = NO;
    [rowHeightCache removeAllObjects];
    [socketModel ping];
    if (![ClearManager getNetStatus]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneLoadingTableViewData];
        });
    }else{
        if ([socketModel isConnected]) {
            //刷新请求联系人列表
            lastDynamicTime = nil;
            [self initScoket];
        }else{
            [socketModel initSocket];
            __weak typeof(self)weakSelf=self;
            [socketModel returnConnectSuccedd:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                    if (![currentVC isKindOfClass:[DynamicViewController class]]) {
                        return ;
                    }
                    [weakSelf reloadTableViewDataSource];
                    //此处刷新接口数据
                    strongSelf ->lastDynamicTime = nil;
                    [weakSelf getDynamicRequest];
                });
            }];
        }
    }

    //设置动态小圆点
    UITabBarItem *tabBarItemWillBadge = self.navigationController.tabBarController.tabBar.items[2];
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
//        [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
//    });
    
    //如果没有新的动态评论消息 就移除提醒
    if ([NFUserEntity shareInstance].dynamicBadgeCount == 0) {
        [tabBarItemWillBadge removeBadgeView];
    }
    
//    [socketRequest getCircleMsg];
    
    
    
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

- (void)dealloc
{
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

#pragma mark- 屏幕接收触碰事件监控
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"\ntouch touch touch\n");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}











@end
