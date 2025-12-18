//
//  SingleChatDetailTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "SingleChatDetailTableViewController.h"
#import "starView.h"


#import "PublishDynamicViewController.h"

@interface SingleChatDetailTableViewController ()<ChatHandlerDelegate>

@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;


@end

@implementation SingleChatDetailTableViewController{
    //头像
    __weak IBOutlet UIButton *headImageBtn;
    //名字
    __weak IBOutlet UILabel *nameLabel;
    
    //创建群聊
    __weak IBOutlet UIButton *createGroupBtn;
    
    //备注名
    __weak IBOutlet UILabel *beizhuLabel;
    
    //星星级别
    __weak IBOutlet UIView *starView_;
    
    //消息免打扰
    __weak IBOutlet UISwitch *NotDisturbSwitch;
    //不让他看动态
    __weak IBOutlet UISwitch *limitSeeDynamicSwitch;
    
    //顶置聊天
    __weak IBOutlet UISwitch *upSetChatSwitch;
    //删除好友按钮
    __weak IBOutlet UIButton *deleteFriendBtn;
    
    
    
    //编辑名字、查看头像后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    JQFMDB *jqFmdb;
}

-(void)viewWillAppear:(BOOL)animated{
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    //是否来自编辑名字
    if (isFromEditName) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
    
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"单聊详情";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    [self initColor];
    [self initScoket];
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *singleArr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        singleArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.conversationId,@"IsSingleChat",@"1",@"IsUpSet",@"1"]];
    }];
    if ( singleArr.count > 0) {
        upSetChatSwitch.on = YES;
    }
    
    //消息免打扰
    __block NSArray *contactArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
    }];
    if (contactArr.count == 1) {
        ZJContact *contact = [contactArr firstObject];
        NotDisturbSwitch.on = contact.IsShield;
        //limitSeeDynamicSwitch 不让看动态
        limitSeeDynamicSwitch.on = contact.IsShieldDynamic;
    }
    
    if (self.IsFromCard) {
        self.title = @"详情";
        deleteFriendBtn.hidden = YES;
    }
    
}

-(void)initUI{
//    ViewRadius(headImageBtn, headImageBtn.frame.size.width/2);
    ViewRadius(headImageBtn, 3);
    ViewRadius(deleteFriendBtn, 3);
    [deleteFriendBtn setTitleColor:[UIColor colorThemeTintColor] forState:(UIControlStateNormal)];
    deleteFriendBtn.backgroundColor = [UIColor colorThemeColor];
//    if ([self.singleContactEntity.iconUrl containsString:@"head_man"]) {
//        [headImageBtn setImage:[UIImage imageNamed:self.singleContactEntity.iconUrl] forState:(UIControlStateNormal)];
//    }else{
        [headImageBtn sd_setImageWithURL:[NSURL URLWithString:self.singleContactEntity.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//    }
    [createGroupBtn setBackgroundImage:[UIImage imageNamed:@"group_participant_addHL"] forState:(UIControlStateNormal)];
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    CGFloat starValue = [self saveLevelcaculate];
    starView *starr = [[starView alloc] initWithFrame:CGRectMake(0, 1, starViewWidth(3, 15), 18) STARGAP:3 STARHW:15 TYPE:3];
    [starr setStarValue:starValue];
    //starView_为xib中的控件
    [starView_ addSubview:starr];
    //原始名
    nameLabel.text = self.singleContactEntity.friend_nickname;
    if (self.singleContactEntity.friend_nickname.length == 0) {
        nameLabel.text = self.singleContactEntity.friend_username;
    }
    nameLabel.textColor = [UIColor colorMainTextColor];
    self.tableView.tableFooterView = [UIView new];
}

-(void)initScoket{
    //取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //请求单聊详情
    if (socketModel.isConnected) {
        [socketModel ping];
    }
    if (![ClearManager getNetStatus]) {
        //        [SVProgressHUD showInfoWithStatus:kWrongNetMissing];
//        [self getDataFromFMDBData];
        return;
    }
    if (socketModel.isConnected) {
        [socketRequest getSingleDetail:self.singleContactEntity];
    }else{
//        [self getDataFromFMDBData];
    }
}





//自定义NAV返回按钮
- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    //群组创建是否成功
    if (messageType == SecretLetterType_groupCreateSuccess){
        
    }else if (messageType == SecretLetterType_FriendDeleteSuccess){
        //删除聊天记录
        BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:self.singleContactEntity.friend_userid IsDelete:YES];
        if (rett) {
            NSLog(@"");
        }
        //删除会话
        BOOL ret = [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:@"huihualiebiao" DataKind:[MessageChatListEntity class] KeyName:@"conversationId" ValueName:self.singleContactEntity.friend_userid SecondKeyName:@"IsSingleChat" SecondValueName:@"1"];
        if (ret) {
            NSLog(@"");
        }
        //刷新会话列表、可以只刷新本地数据的
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        UIViewController * viewVC = [self.navigationController.viewControllers objectAtIndex:0];
        [self.navigationController popToViewController:viewVC animated:YES];
    }else if (messageType == SecretLetterType_PullBlack){
        if ([chatModel isKindOfClass:[SingleDetailEntity class]]) {
            SingleDetailEntity *entity = chatModel;
            if (entity.IsPullBlack) {
                //拉黑返回
                if (entity.IsInBlack) {
                    NotDisturbSwitch.on = YES;
                }else{
                    NotDisturbSwitch.on = NO;
                }
            }else{
                //取消拉黑返回
                if (entity.IsInBlack) {
                    NotDisturbSwitch.on = YES;
                }else{
                    NotDisturbSwitch.on = NO;
                }
            }
        }
    }
    else if (messageType == SecretLetterType_PullBlackSuccess){
        NotDisturbSwitch.on = YES;
        
        //
        __block BOOL ret;
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:@"lianxirenliebiao" whereFormat:@"where friend_userid = '%@'",self.singleContactEntity.friend_userid];
            if (ret) {
                //删除
            }
        }];
        
        
    }else if (messageType == SecretLetterType_CancelPullBlackSuccess){
        NotDisturbSwitch.on = NO;
    }else if(messageType == SecretLetterType_friendBlackState){
        NSDictionary *dict = chatModel;
        if([[[dict objectForKey:@"status"] description] isEqualToString:@"2"]){
            NotDisturbSwitch.on = YES;
        }else{
            NotDisturbSwitch.on = NO;
        }
        
    }
    
}

#pragma mark - 单聊详情

#pragma mark - 请求屏蔽朋友圈

#pragma mark - 请求拉黑或者取消拉黑

#pragma mark - 创建群聊点击
- (IBAction)createGroupBtnClick:(UIButton *)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
    toCtrol.SourceType = SourceTypeFromSingleChat;
    toCtrol.alreadlyExistMemberArr = @[self.singleContactEntity];
    [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
        //进行创建群组请求
//        [self createGroupRequest:memberArr];
//        //后面界面点击完成后 回调这里 进行一系列请求
//         //选中完 跳转到聊天
//        //在didreceive中 得到群组信息后再进行跳转
//        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//        MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
//        ZJContact *contant = [memberArr firstObject];
//        toCtrol.titleName = [NSString stringWithFormat:@"和%@等人的聊天",contant.friend_username];
//        toCtrol.IsFromAdd = YES;
//        toCtrol.chatType = @"1";
        
//        [self.navigationController pushViewController:toCtrol animated:YES];
    }];
    [self.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 创建群组请求 request

#pragma mark - 消息免打扰 拉黑
- (IBAction)DonoNoticeSwitchClick:(UISwitch *)sender {
    
    if (self.IsFromCard) {
        sender.on = NO;
        return;
    }
    
    //进行网络请求 在返回中中 如果为成功 则不改变，如果为失败 则设置为!on。
    NSLog(@"%d",sender.isOn);
    if (sender.isOn) {
        //请求拉黑
        [socketRequest pullBlackType:YES FriendId:self.singleContactEntity.friend_userid];
#warning 拉黑
        //有接口后删除
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *contactArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
        }];
        if (contactArr.count == 1) {
            ZJContact *contact = [contactArr firstObject];
            contact.IsShield = YES;
            __block BOOL ret;
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //ret = [strongSelf ->jqFmdb jq_updateTable:@"lianxirenliebiao" dicOrModel:contact whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
//                if (ret) {
//                }
            }];
        }
    }else{
        //请求取消拉黑
        [socketRequest pullBlackType:NO FriendId:self.singleContactEntity.friend_userid];
        
#warning 拉黑
        //有接口后删除
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *contactArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
        }];
        if (contactArr.count == 1) {
            ZJContact *contact = [contactArr firstObject];
            contact.IsShield = NO;
            __block BOOL ret;
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
               // ret = [strongSelf ->jqFmdb jq_updateTable:@"lianxirenliebiao" dicOrModel:contact whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
//                if (ret) {
//                }
            }];
        }
    }
}

#pragma mark - 屏蔽动态
- (IBAction)donnotSeeHisDynamic:(UISwitch *)sender {
    
    if (self.IsFromCard) {
        sender.on = NO;
        return;
    }
    
    if (sender.isOn) {
        //网络请求
        [socketRequest limitDynamicType:YES];
#warning 限制动态
        //有接口后删除
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *contactArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
        }];
        if (contactArr.count == 1) {
            ZJContact *contact = [contactArr firstObject];
            contact.IsShieldDynamic = YES;
            __block BOOL ret;
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                ret = [strongSelf ->jqFmdb jq_updateTable:@"lianxirenliebiao" dicOrModel:contact whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
                if (ret) {
                }
            }];
        }
    }else{
        //网络请求
        [socketRequest limitDynamicType:NO];
#warning 限制动态 【屏蔽动态】
        //有接口后删除
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *contactArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
        }];
        if (contactArr.count == 1) {
            ZJContact *contact = [contactArr firstObject];
            contact.IsShieldDynamic = NO;
            __block BOOL ret;
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                ret = [strongSelf ->jqFmdb jq_updateTable:@"lianxirenliebiao" dicOrModel:contact whereFormat:@" where friend_userid = '%@'",strongSelf.singleContactEntity.friend_userid];
                if (ret) {
                }
            }];
        }
    }
}



#pragma mark - 顶置聊天
- (IBAction)OverHeadSwitchClick:(UISwitch *)sender {
    if (self.IsFromCard) {
        sender.on = NO;
        return;
    }
    
    NSLog(@"%d",sender.isOn);
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    if (sender.isOn) {
        //[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",entity.conversationId,@"IsSingleChat",IsSingleChat]
        __block NSArray *singleArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            singleArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.conversationId,@"IsSingleChat",@"1"]];
        }];
        MessageChatListEntity *chatListEntity = [singleArr firstObject];
//        chatListEntity.conversationId = self.conversationId;
//        chatListEntity.IsSingleChat = YES;
        chatListEntity.IsUpSet = YES;
        __block BOOL isSuccess;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            isSuccess = [strongSelf ->jqFmdb jq_updateTable:@"huihualiebiao" dicOrModel:chatListEntity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.conversationId,@"IsSingleChat",@"1"]];
        }];
    }else if (!sender.isOn){
        __block NSArray *singleArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            singleArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity new] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.conversationId,@"IsSingleChat",@"1"]];
        }];
        MessageChatListEntity *chatListEntity = [singleArr firstObject];
        chatListEntity.IsUpSet = NO;
        __block BOOL isSuccess;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            isSuccess = [strongSelf ->jqFmdb jq_updateTable:@"huihualiebiao" dicOrModel:chatListEntity whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",strongSelf.conversationId,@"IsSingleChat",@"1"]];
        }];
        
    }
}

#pragma mark - 单聊点击头像
- (IBAction)singleChatClick:(id)sender {
    UIImage *image = headImageBtn.imageView.image;
    SGPhoto *temp = [[SGPhoto alloc] init];
    temp.identifier = @"";
    temp.thumbnail = image;
    temp.fullResolutionImage = image;
    HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
    showImageViewCtrol.imageUrlList = @[temp];
    showImageViewCtrol.mainImageIndex = 0;
    showImageViewCtrol.isLuoYang = YES;
    showImageViewCtrol.isNeedNavigation = NO;
//    [self.navigationController pushViewController:showImageViewCtrol animated:YES];
    
    self.ZJContactDetailController.view  = nil;
    self.ZJContactDetailController  = nil;
    self.tableView.scrollEnabled = NO;
    [self showContactDetail];
    
}

#pragma mark - 展示联系人详情
-(void)showContactDetail{
    if (self.ZJContactDetailController == nil) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
        self.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
        //设置单聊详情数据
        ZJContact *contact = self.singleContactEntity;
        self.ZJContactDetailController.contant = contact;
        self.ZJContactDetailController.SourceFrom = @"2";
        [self addChildViewController:self.ZJContactDetailController];
        self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        __weak typeof(self)weakSelf=self;
        //点击了headview上面的事件
        [self.ZJContactDetailController clickWhichIndex:^(int index) {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (index == 0 || index == 10) {
                //移除ZJContactDetailController
                [UIView animateWithDuration:0.2 animations:^{
                    self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    [self.ZJContactDetailController.view removeFromSuperview];
                    //当移除界面后 设置来自编辑名字为no
                    strongSelf ->isFromEditName = NO;
                }];
                weakSelf.tableView.scrollEnabled = YES;
                //当移除了详情后 界面可滑动
                weakSelf.navigationController.navigationBarHidden = NO;
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
        [self.ZJContactDetailController.nameEditBtn addTarget:self action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
        //如果点击了自己 则 【单聊不可能点击到自己】
//        if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
//            self.ZJContactDetailController.freeChatBtn.hidden = YES;
//            self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//        }
        //已经在单聊 无需继续点击单聊
//        self.ZJContactDetailController.freeChatBtn.hidden= YES;
//        self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
        [self.ZJContactDetailController.freeChatBtn addTarget:self action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
        //设置头像
        self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80/2, -65, 90, 90)];
//        ViewRadius(self.ZJContactDetailController.nfHeadImageV, self.ZJContactDetailController.nfHeadImageV.frame.size.width/2);
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
            [strongSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
        }];
        [self.ZJContactDetailController.tableView addSubview:self.ZJContactDetailController.nfHeadImageV];
        [self.view addSubview:self.ZJContactDetailController.view];
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.navigationBarHidden = YES;
            self.ZJContactDetailController.view.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
        }];
        
    }
}

#pragma mark - 免费聊天 正在和该人聊天 直接pop回去
-(void)freeChatClick:(UIButton *)button event:(UIEvent *)event{
    
    if(self.IsFromCard){
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
        toCtrol.IsFromAdd = YES;
        ZJContact *contact = self.singleContactEntity;
        if (contact.friend_nickname.length > 0) {
            toCtrol.titleName = contact.friend_nickname;
        }else{
            toCtrol.titleName = contact.friend_username;
        }
        //                    toCtrol.conversationId = contact.chatId;
        toCtrol.chatType = @"0";
        toCtrol.singleContactEntity = contact;
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
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
    //toCtrol.currentText = groupNameLabel.text;
    toCtrol.editType = EditTypeBeiZhu;
    [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
        if (type == EditNameType) {
            [self.ZJContactDetailController.nameEditBtn setTitle:info forState:(UIControlStateNormal)];
        }
    }];
    [self.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - Table view data source
//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 2) {
        cell.backgroundColor = [UIColor clearColor];
        return;
    }
//    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
    
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     if (indexPath.section == 1 && indexPath.row == 0){
         return 0.1;
     }else if (indexPath.section == 1 && indexPath.row == 99){
         return 0.1;
     }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if(self.IsFromCard){
        return;
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            //将他推荐给好友
            //转发 MessageChatListViewController
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
            MessageChatListViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatListViewController"];
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            toCtrol.forwardContent = [NSString stringWithFormat:@"[个人名片]%@",self.singleContactEntity.friend_nickname];
            toCtrol.contentType = @"4";//转发消息类型 0文字 1图片 2语音 3红包 4名片
            
            ZJContact *contact = [ZJContact new];
            contact.friend_userid = self.singleContactEntity.friend_userid;
            contact.friend_username = self.singleContactEntity.friend_username;
            contact.friend_nickname = self.singleContactEntity.friend_nickname;
            contact.iconUrl = self.singleContactEntity.iconUrl;
            toCtrol.cardContact = contact;
            toCtrol.chatingName = @"111";
            toCtrol.forwardUUMessageFrame = nil;
            toCtrol.fromType = YES;
            toCtrol.IsFromCard = YES;
            [currentVC.navigationController pushViewController:toCtrol animated:YES];
            
        }else if (indexPath.row == 5) {
            //备注
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
            toCtrol.editType = EditTypeBeiZhu;
            toCtrol.currentText = self.singleContactEntity.friend_nickname;
            [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
                if (type == EditTypeBeiZhu) {
                    beizhuLabel.text = info;
                    //网络修改
                    [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
                    [socketRequest setFriendMark:info FriendId:self.singleContactEntity.friend_userid];
                    
                    //更改会话列表
                    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    __weak typeof(self)weakSelf=self;
                    //将本地缓存取出来 用于与服务器的进行对比
                    __block NSArray *localChatListArr = [NSArray new];
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        localChatListArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where conversationId = '%@' and IsSingleChat = '1'",self.singleContactEntity.friend_userid];
                    }];
                    if(localChatListArr.count > 0){
                        MessageChatListEntity *entity = [localChatListArr firstObject];
                        entity.nickName = info;
                        self.singleContactEntity.friend_nickname = info;
                        nameLabel.text = info;
                        //更新缓存
                        [[NFMyManage new] changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:self.singleContactEntity.friend_userid FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
                    }
                    
                     
                }
            }];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            //查找聊天记录
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            VagueSearchViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"VagueSearchViewController"];
            toCtrol.fromType = @"1";
            toCtrol.conversationId = self.conversationId?self.conversationId:self.singleContactEntity.friend_userid;
            toCtrol.singleContactEntity = self.singleContactEntity;
            //            [self presentViewController:toCtrol animated:YES completion:nil];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if (indexPath.section == 3){
        if (indexPath.row == 0){
            //清空聊天记录
            [self clearCache];
        }else if (indexPath.row == 1){
            //投诉
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
            PublishDynamicViewController *pubvc = [sb instantiateViewControllerWithIdentifier:@"PublishDynamicViewController"];
            pubvc.groupid = self.singleContactEntity.friend_userid;
            __weak typeof(self)weakSelf=self;
            //没用到
            pubvc.successBlock = ^(BOOL success){
                
            };
            pubvc.shareType = ShareTypeOffjubao;
            [self.navigationController pushViewController:pubvc animated:YES];
            
            
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
//            OpinionRequestViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"OpinionRequestViewController"];
//            toCtrol.tousu = YES;
//            toCtrol.contactEntity = self.singleContactEntity;
//            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"SpecialMerchantStoryboard" bundle:nil];
//    SpActDetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SpActDetailViewController"];
//    [self.navigationController pushViewController:toCtrol animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (@available(iOS 13.0, *)) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return cell;
        }else if(indexPath.section == 3 && indexPath.row == 2){
            return cell;
        }
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
    }
    return cell;
    
}

-(void)initColor{
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secLabel.textColor = [UIColor colorMainTextColor];
    self.thirdLaberl.textColor = [UIColor colorMainTextColor];
    self.forthLabel.textColor = [UIColor colorMainTextColor];
    self.fifthLabel.textColor = [UIColor colorMainTextColor];
    beizhuLabel.textColor = [UIColor colorMainSecTextColor];
    self.sixthLabel.textColor = [UIColor colorMainTextColor];
    self.seventhLabel.textColor = [UIColor colorMainTextColor];
    self.eightLabel.textColor = [UIColor colorMainTextColor];
    self.nineLabel.textColor = [UIColor colorMainTextColor];
    
    
    self.firstLabel.font = [UIFont fontMainText];
    self.secLabel.font = [UIFont fontMainText];
    self.thirdLaberl.font = [UIFont fontMainText];
    self.forthLabel.font = [UIFont fontMainText];
    self.fifthLabel.font = [UIFont fontMainText];
    beizhuLabel.font = [UIFont fontMainText];
    self.sixthLabel.font = [UIFont fontMainText];
    self.seventhLabel.font = [UIFont fontMainText];
    self.eightLabel.font = [UIFont fontMainText];
    self.nineLabel.font = [UIFont fontMainText];
    
}

- (void)clearCache
{
//    self.tableView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf=self;
//    PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:@"清除缓存" message:@"确认清除？" isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
//        //当清除了缓存 返回需要从新请求
//        [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
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
        allMessageImageArr = [strongSelf ->jqFmdb jq_lookupTable:strongSelf.singleContactEntity.friend_userid dicOrModel:[MessageChatEntity new] whereFormat:@"where cachePicPath is not null"];
    }];
    for (MessageChatEntity *chatEntity in allMessageImageArr) {
        [[SDImageCache sharedImageCache] removeImageForKey:chatEntity.pictureUrl fromDisk:YES];
    }
    BOOL rett = [self.myManage clearTableWithDatabaseName:@"tongxun.sqlite" tableName:self.singleContactEntity.friend_userid IsDelete:NO];
    if (rett) {
        __weak typeof(self)weakSelf=self;
//        PopView *popV = [[PopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH/3*2) title:@"清除缓存" message:@"清除缓存成功" isNeedCancel:YES isSureBlock:^(BOOL sureBlock) {
//            weakSelf.tableView.userInteractionEnabled = YES;
//        }];
//        [popV setSecTitleBackColor:[UIColor colorThemeColor]];
//        [popV setSecSureColor:[UIColor colorThemeColor]];
//        [popV setSecMessageColor:UIColorFromRGB(0x666666)];
//        [popV setSecMessageLabelTextAlignment:@"0"];
//        UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
//        [win addSubview:popV];
        NSDictionary *dic = @{@"userName":self.singleContactEntity.friend_username,@"type":@"0",@"strContent":@"",@"update_time":@"",@"nickName":self.singleContactEntity.friend_nickname?self.singleContactEntity.friend_nickname:self.singleContactEntity.friend_username};
        [self.fmdbServicee cacheChatListWithZJContact:self.singleContactEntity AndDic:dic];
        [SVProgressHUD show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"清除缓存成功" sureBtn:@"确认" cancleBtn:nil];
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

#pragma mark - 被骚扰了 举报用户
- (IBAction)qubaoClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
    OpinionRequestViewController * toCtrol = [sb instantiateViewControllerWithIdentifier:@"OpinionRequestViewController"];
    toCtrol.tousu = YES;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    [currentVC.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 删除用户
- (IBAction)deleteFriendClick:(id)sender {
    LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"同时回删除对方的临时会话，不再接受此人消息" otherButtonTitles:[NSArray arrayWithObjects:@"删除好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 999) {
            return ;
        }
        if (![ClearManager getNetStatus]) {
            [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
            return;
        }
        if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
            [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
            return;
        }
        [socketRequest deleteFriendRequest:self.singleContactEntity.friend_userid];
        
        //删除缓存
        __block BOOL ret;
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:@"lianxirenliebiao" whereFormat:@"where friend_userid = '%@'",self.singleContactEntity.friend_userid];
            if (ret) {
                NSLog(@"删除成功");
            }
        }];
        
        [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
    }];
    [sheet show];
}

#pragma mark - 删除好友请求

#pragma mark - 代码块传值相关
-(void)returnDelete:(ReturnIsDeleteBlock)block{
    self.returnDeleteBlock = block;
}

//修改昵称回
-(void)returnEditedName:(ReturnSingleNameEditBlock)block{
    if (self.returnSingleNameBlock != block) {
        self.returnSingleNameBlock = block;
    }
}

#pragma mark - 计算安全等级
-(CGFloat)saveLevelcaculate{
    CGFloat starValue = 0;
    //关机清空
    NSString *guanjiQingkong = [KeepAppBox checkValueForkey:@"guanjiQingkongCount"];
    NSInteger guanjiQingkongCount = [guanjiQingkong integerValue];
    //设置了关机清空 则加1
    //    if (guanjiQingkongCount <= 36*3600) {
    //        starValue += 2;
    //    }
    if (guanjiQingkongCount <= 3*3600 &&guanjiQingkongCount != 0) {
        starValue += 4;
    }else if (guanjiQingkongCount <= 6*3600&&guanjiQingkongCount != 0){
        starValue += 3.5;
    }else if (guanjiQingkongCount <= 12*3600&&guanjiQingkongCount != 0){
        starValue += 3;
    }else if (guanjiQingkongCount <= 36*3600&&guanjiQingkongCount != 0){
        starValue += 2.5;
    }else{
        starValue += 1;
    }
    
    //阅后隐藏
    NSString *yuehouYincangString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
    NSInteger yuehouYincangStringCount = [yuehouYincangString integerValue];
    if (yuehouYincangStringCount <= 60 && yuehouYincangStringCount != 0) {
        starValue += 6;
    }else if (yuehouYincangStringCount <= 5*60 && yuehouYincangStringCount != 0){
        starValue += 5;
    }else if (yuehouYincangStringCount <= 10*60 && yuehouYincangStringCount != 0){
        starValue += 4.5;
    }else if (yuehouYincangStringCount <= 20*60 && yuehouYincangStringCount != 0){
        starValue += 4;
    }else if (yuehouYincangStringCount <= 30*60 && yuehouYincangStringCount != 0){
        starValue += 3.5;
    }else{
        starValue += 2;
    }
    return starValue;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}


@end
