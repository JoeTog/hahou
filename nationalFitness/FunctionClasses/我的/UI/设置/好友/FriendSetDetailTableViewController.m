//
//  FriendSetDetailTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/8/9.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "FriendSetDetailTableViewController.h"

@interface FriendSetDetailTableViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;


@end

@implementation FriendSetDetailTableViewController{
    
    
    IBOutlet NFBaseTableView *FriendSetDetailTableView;
    
    JQFMDB *jqFmdb;
    
    __block NSArray *hidenContacts;
    
    //记录选中的indexpath 聊天用
    NSIndexPath *selectedIndexPath;
    //记录选中的indexpath 管理好友用
    NSIndexPath *selectedManageIndex;
    
    
    BOOL isFromEditName;
}

//设置navigationController 基点从下面左上角算起
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //是否来自编辑名字
    if (isFromEditName) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"隐藏的好友";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUi];
    [self initDataSource];
    
    
}

- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initUi{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    FriendSetDetailTableView.tableFooterView = [UIView new];
    FriendSetDetailTableView.isNeed = YES;
    
}

-(void)initDataSource{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        hidenContacts = [strongSelf ->jqFmdb jq_lookupTable:@"yincanglianxiren" dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    
    if (hidenContacts.count == 0) {
        [FriendSetDetailTableView showNoneWithImage:@"空白页-14-14_03" WithTitle:@"暂无隐藏好友"];
    }else{
        [FriendSetDetailTableView removeNone];
    }
    [FriendSetDetailTableView reloadData];
    
}

#pragma mark - tableViewDelegate & tableViewDateSource
//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return hidenContacts.count;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
    
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"FriendSetDetailTableViewCell";
    FriendSetDetailTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"FriendSetDetailTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ZJContact *contant = hidenContacts[indexPath.row];
    cell.nameLabel.text = contant.friend_username;
    [cell.manageBtn addTarget:self action:@selector(manageFriend:event:) forControlEvents:(UIControlEventTouchUpInside)];
    [cell.imagView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"SpecialMerchantStoryboard" bundle:nil];
//    SpActDetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SpActDetailViewController"];
//    [self.navigationController pushViewController:toCtrol animated:YES];
    ZJContact *contact = hidenContacts[indexPath.row];
    self.tableView.scrollEnabled = NO;
    selectedIndexPath = indexPath;
    //ZJContactDetailController
    self.ZJContactDetailController.view  = nil;
    self.ZJContactDetailController  = nil;
    if (self.ZJContactDetailController == nil) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
        self.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
        //        DailyAdminTableV_.date_ = @"201702";
        //将详情页需要的值传过去
        self.ZJContactDetailController.contant = contact;
        self.ZJContactDetailController.SourceFrom = @"0";
        [self addChildViewController:self.ZJContactDetailController];
        self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        __weak typeof(self)weakSelf=self;
        //点击了headview上面的事件
        self.ZJContactDetailController.clickWhich = ^(int index) {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (index == 0 || index == 10) {
                //只有当移除的时候 让下面tableview可点
//                weakSelf.tableView.scrollEnabled = YES;
                //移除ZJContactDetailController
                [UIView animateWithDuration:0.2 animations:^{
                    strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                    [strongSelf.ZJContactDetailController.view removeFromSuperview];
                    //当移除界面后 设置来自编辑名字为no
                    strongSelf ->isFromEditName = NO;
                }];
                
                strongSelf.navigationController.navigationBarHidden = NO;
//                weakSelf.tabBarController.tabBar.hidden = NO;
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
                [weakSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
            }else if (index == 2){
                //收藏
            }
        };
        //如果点击了自己 则 【不可能点击到自己】
//        if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
//            self.ZJContactDetailController.freeChatBtn.hidden = YES;
//            self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
//        }
        //设置编辑名字、免费聊天 放在 addsubview上面会为空
        [self.ZJContactDetailController.nameEditBtn addTarget:self action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
        [self.ZJContactDetailController.freeChatBtn addTarget:self action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
        
        //设置头像
        CGFloat width = 100;
        self.ZJContactDetailController.nfHeadImageV = [[NFHeadImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - width/2, -65, width, width)];
        
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
//            self.tabBarController.tabBar.hidden = YES;
            self.ZJContactDetailController.view.frame = CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
        }];
    }
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
    ZJContact *contact = hidenContacts[selectedIndexPath.row];
    toCtrol.titleName = contact.friend_username;
//    toCtrol.conversationId = contact.chatId;
    toCtrol.chatType = @"0";
//    MessageChatListEntity *entity = [MessageChatListEntity new];
//    entity.receive_user_name = contact.friend_username;
//    toCtrol.singleEntity = entity;
    toCtrol.singleContactEntity = contact;
    [self.ZJContactDetailController.view removeFromSuperview];
    self.ZJContactDetailController.view  = nil;
    self.ZJContactDetailController  = nil;
    [self.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 管理好友
-(void)manageFriend:(UIButton *)button event:(UIEvent *)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:FriendSetDetailTableView];
    NSIndexPath *indexPath = [FriendSetDetailTableView indexPathForRowAtPoint:currentTouchPosition];
    selectedManageIndex = indexPath;
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"恢复到朋友列表", nil];
    
    action.actionSheetStyle = UIActionSheetStyleDefault;
    [action showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            //恢复到好友列表 selectedManageIndex
            ZJContact *contact = hidenContacts[selectedManageIndex.row];
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//            NSArray *arrs = [jqFmdb jq_lookupTable:@"yincanglianxiren" dicOrModel:[ZJContact class] whereFormat:@""];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL ret = [strongSelf ->jqFmdb jq_deleteTable:@"yincanglianxiren" whereFormat:[NSString stringWithFormat:@"where friend_userid = '%@'",contact.friend_userid]];
                if (ret) {
                    NSLog(@"取消隐藏成功");
                    [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
                }
            }];
            [self initDataSource];
        }
            break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}


@end
