//
//  GroupChatAllMemberCollectionViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/8/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupChatAllMemberCollectionViewController.h"
#import "EGORefreshTableHeaderView.h"

#define headReuse @"head"

@interface GroupChatAllMemberCollectionViewController ()<ChatHandlerDelegate,UISearchBarDelegate,UISearchControllerDelegate>
//<EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) ZJContactDetailTableViewController *ZJContactDetailController;


@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSArray<ZJContact *> *allData; //ZJContact类型数组


@end

@implementation GroupChatAllMemberCollectionViewController{
    
    BOOL reloading_;
    BOOL needReloading_;
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    
    EGORefreshTableHeaderView * refreshHeaderView_;
    
    //记录选中的indexpath
    NSIndexPath *selectedIndexPath;
    //编辑名字后 回来还是隐藏navigation和tabbar
    BOOL isFromEditName;
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    BOOL IsLoading;
    
    JQFMDB *jqFmdb;
    
    CGFloat header_y;
    
    NSMutableArray *requestMemberArr;
    
    NSInteger loadingIndex;
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [SVProgressHUD dismiss];
    
}


-(void)viewWillAppear:(BOOL)animated{
    //是否来自编辑名字
    if (isFromEditName) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
    
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    socketRequest = [SocketRequest share];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _edgeInsetsToFit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群组成员";
    
    UINib * nib = [UINib nibWithNibName:@"GroupMemberCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"GroupMemberCollectionViewCell"];
    
    UINib * nibb = [UINib nibWithNibName:@"GroupEditCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nibb forCellWithReuseIdentifier:@"GroupEditCollectionViewCell"];
    
    [self.collectionView registerClass:[headCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headReuse];
    
    
    
    [self initUi];
    header_y = 50;
    [self contentInsetHeaderView];
    [self initSocket];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    
    
    
    __block BOOL IsExistYC = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        IsExistYC = [strongSelf ->jqFmdb jq_isExistTable:[NSString stringWithFormat:@"groupmemberlist%@",self.groupCreateSEntity.groupId]];
    }];
    if (!IsExistYC) {
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
             [strongSelf ->jqFmdb jq_createTable:[NSString stringWithFormat:@"groupmemberlist%@",strongSelf.groupCreateSEntity.groupId] dicOrModel:[ZJContact class]];
        }];
    }
    
    __block NSArray *mamberArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        mamberArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"groupmemberlist%@",self.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    
    if (mamberArr.count > 0) {
        self.memberArr = mamberArr;
    }else{
        self.memberArr = self.groupCreateSEntity.groupAllUser;
//        canRefreshLash_ = YES;
    }
    
    if (self.memberArr.count >= 15) {
        requestMemberArr = [NSMutableArray arrayWithArray:[self.memberArr subarrayWithRange:NSMakeRange(0, 15)]];
        canRefreshLash_ = YES;
    }
    
    
    
    if (self.memberArr.count >= 15) {

    }else{
        for (ZJContact *contact in self.memberArr) {
            ZJContact *lastContact = [self.fmdbServicee checkContactIsHaveCommmentname:contact];
            [self.fmdbServicee cacheGroupMemberWith:lastContact AndGroupId:self.groupCreateSEntity.groupId];
        }
    }
    
    
    
}

-(void)initSocket{
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
}






-(void)initUi{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 35)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
//    if (refreshHeaderView_ == nil)
//    {
//        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.collectionView.bounds.size.height, self.collectionView.frame.size.width, self.collectionView.bounds.size.height)];
//        refreshHeader.delegate = self;
//        reloading_ = NO;
//        [self.collectionView addSubview:refreshHeader];
//        refreshHeaderView_ = refreshHeader;
//    }
//    [refreshHeaderView_ refreshLastUpdatedDate];
    
    
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
        
    
    
    
}

//自定义NAV返回按钮
- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_edgeInsetsToFit {
    UIEdgeInsets edgeInsets = self.collectionView.contentInset;
    CGSize contentSize = self.collectionView.contentSize;
    CGSize size = self.collectionView.bounds.size;
    CGFloat heightOffset = (contentSize.height + edgeInsets.top) - size.height;
    if (heightOffset < 0) {
        edgeInsets.bottom = size.height - (contentSize.height + edgeInsets.top) + 1;
        self.collectionView.contentInset = edgeInsets;
    } else {
        edgeInsets.bottom = 0;
        self.collectionView.contentInset = edgeInsets;
    } 
}

-(void)loadMoreMember{
    if (IsLoading) {
        return;
    }else if (loadingIndex == requestMemberArr.count / 15 + 1){
        return;
    }
    IsLoading = YES;
    loadingIndex =  loadingIndex == requestMemberArr.count / 15 + 1;
    NSString *page = [NSString stringWithFormat:@"%@",@(requestMemberArr.count / 15 + 1)];
    NSString *pagesize = [NSString stringWithFormat:@"15"];
    
    [socketRequest getGroupDetail:self.groupCreateSEntity.groupId AndPage:page];
    
    
}

-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_zhuanrangSuccess){
        //群主转让成功
        [SVProgressHUD showInfoWithStatus:@"该群已解散..."];
        [self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1];
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
    }else if(messageType == SecretLetterType_GroupDetail){
        [SVProgressHUD dismiss];
        IsLoading = NO;
        GroupCreateSuccessEntity *entity = chatModel;
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.memberArr];
        if ([entity.groupAllUser count] == 15)
        {
            canRefreshLash_ = YES;
        }
        else
        {
            canRefreshLash_ = NO;
        }
        
        for (ZJContact *contact in entity.groupAllUser) {
            ZJContact *lastContact = [self.fmdbServicee checkContactIsHaveCommmentname:contact];
            [self.fmdbServicee cacheGroupMemberWith:lastContact AndGroupId:self.groupCreateSEntity.groupId];
        }
        self.collectionView.userInteractionEnabled = YES;
        [requestMemberArr addObjectsFromArray:entity.groupAllUser];
        
        if (requestMemberArr.count > self.memberArr.count) {
            [arr addObjectsFromArray:entity.groupAllUser];
            self.memberArr = [NSArray arrayWithArray:arr];
            [self.collectionView reloadData];
        }
        
    }
}



-(void)popToRootViewController{
    //pop回根视图
    UIViewController * viewVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - self.navigationController.viewControllers.count];
    [self.navigationController popToViewController:viewVC animated:YES];
}



#pragma mark - collectionview

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, -50, self.collectionView.bounds.size.width, 50)];
        searchBar.delegate = self;
        searchBar.placeholder = @"姓名/首字母";
        _searchBar = searchBar;
    }
    return _searchBar;
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.searchBar) {
        //点击搜索框 初始化可搜索的数组
        
        __block NSArray *lastArr = [NSArray new];
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"groupmemberlist%@",self.groupCreateSEntity.groupId] dicOrModel:[ZJContact class] whereFormat:@""];
        }];
//        NSMutableArray *searchResultArr = [NSMutableArray new];
//        searchResultArr = [lastArr mutableCopy];
        //初始化搜索结果的数组
        self.allData = [NSArray arrayWithArray:lastArr];
        
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
            
            [SVProgressHUD showWithStatus:@"加载中"];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                [NSThread sleepForTimeInterval:0.2];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [SVProgressHUD dismiss];
                    [self showContactDetail:contant];
                });
            });
            
            
            
            //
            
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
//    if (!self.fromType) {
//        self.tabBarController.tabBar.hidden = NO;
//    }
    
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

- (void)contentInsetHeaderView {
//    CGFloat header_y = 50;
    // CGFloat top, left, bottom, right;
    self.collectionView.contentInset = UIEdgeInsetsMake(header_y, 0, 0, 0);
    //_tvHeaderView.frame = CGRectMake(0, -header_y, [UIScreen mainScreen].bounds.size.width, header_y);
    [self.collectionView addSubview:self.searchBar];
    [self.collectionView setContentOffset:CGPointMake(0, -header_y)];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.memberArr.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (requestMemberArr.count <= indexPath.item+1  && canRefreshLash_) {
//        [SVProgressHUD showWithStatus:@"加载中"];
////        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
////            sleep(1);
////            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                [self loadMoreMember];
//            [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
//        //self.collectionView.userInteractionEnabled = NO;
////            });
////        });
//
//    }
    GroupMemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupMemberCollectionViewCell" forIndexPath:indexPath];
    [UIImage imageNamed:defaultHeadImaghe];
    ZJContact *contact = self.memberArr[indexPath.item];
//    if ([contact.iconUrl containsString:@"head_man"]) {
//        cell.headImageV.image = [UIImage imageNamed:contact.iconUrl];
//    }else{
        [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:contact.iconUrl] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//    }
    cell.headImageV.userInteractionEnabled= NO;
    if(contact.in_group_name && contact.in_group_name.length > 0){
        cell.nickNamelabel.text = contact.in_group_name;
    }else{
        cell.nickNamelabel.text = contact.friend_nickname;
    }
    cell.badgeimageV.hidden = YES;
    if ([contact.is_admin isEqualToString:@"1"]) {
        cell.badgeimageV.hidden = NO;
    }
    return cell;
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(30, 20, 8, 20);
    
}

//列之间最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

//行之间最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(50, 70);
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 10);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        headCollectionReusableView *head = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headReuse forIndexPath:indexPath];
        head.titleLable.backgroundColor = [UIColor colorSectionHeader];
        return head;
    }
    return nil;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item != self.memberArr.count && indexPath.item != self.memberArr.count+1) {
        
        
        //弹出管理 设置管理员
        ZJContact *contactTTT = self.memberArr[indexPath.item];
        
        if ([self.groupCreateSEntity.is_creator isEqualToString:@"1"]) {
            if ([contactTTT.is_creator isEqualToString:@"1"]) {
                [self jumpPersonalDetailIndexPath:indexPath];
            }else if ([contactTTT.is_admin isEqualToString:@"1"]){
                LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料",@"转让群主",@"取消管理员",@"加好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 999) {
                        return ;
                    }else if(buttonIndex == 0){
                        [self jumpPersonalDetailIndexPath:indexPath];
                    }else if(buttonIndex == 1){

                        //转让群主
                        //groupZhuanrang
                        SocketRequest *socketRequest = [SocketRequest share];
                        [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"您确定转让群主么？" sureBtn:@"确认" cancleBtn:@"取消"];
//                        alertView.resultIndex = ^(NSInteger index)
//                        {
//                            if(index == 2){
//
//                                //转让群主
//                                //groupZhuanrang
//                                SocketRequest *socketRequest = [SocketRequest share];
//                                [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                            }
//                        };
//                        [alertView showMKPAlertView];
                        
                    }else if(buttonIndex == 2){
                        [socketRequest manageGroup:NO GroupId:self.groupCreateSEntity.groupId AndContact:contactTTT];
                        contactTTT.is_admin = @"0";
                        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }else if (buttonIndex == 3){
                        //加好友
                        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                        AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                        toCtrol.addFriendId = contactTTT.friend_userid;
                        toCtrol.addFriendName = contactTTT.friend_username;
                        toCtrol.headPicpath = contactTTT.iconUrl;
                        [self.navigationController pushViewController:toCtrol animated:YES];
                    }
                }];
                [sheet show];
            }else{
                LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料",@"转让群主",@"设置管理员",@"加好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 999) {
                        return ;
                    }else if(buttonIndex == 0){
                        [self jumpPersonalDetailIndexPath:indexPath];
                    }else if(buttonIndex == 1){
                        

                        //转让群主
                        //groupZhuanrang
                        SocketRequest *socketRequest = [SocketRequest share];
                        [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"您确定转让群主么？" sureBtn:@"确认" cancleBtn:@"取消"];
//                        alertView.resultIndex = ^(NSInteger index)
//                        {
//                            if(index == 2){
//
//                                //转让群主
//                                //groupZhuanrang
//                                SocketRequest *socketRequest = [SocketRequest share];
//                                [socketRequest groupZhuanrang:contactTTT.friend_userid groupId:self.groupCreateSEntity.groupId];
//                            }
//                        };
//                        [alertView showMKPAlertView];
                        
                    }else if(buttonIndex == 2){
                        [socketRequest manageGroup:YES GroupId:self.groupCreateSEntity.groupId AndContact:contactTTT];
                        contactTTT.is_admin = @"1";
                        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }else if (buttonIndex == 3){
                        //加好友
                        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                        AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                        toCtrol.addFriendId = contactTTT.friend_userid;
                        toCtrol.addFriendName = contactTTT.friend_username;
                        toCtrol.headPicpath = contactTTT.iconUrl;
                        [self.navigationController pushViewController:toCtrol animated:YES];
                    }
                    
                }];
                [sheet show];
            }
        }else if ([self.groupCreateSEntity.is_admin isEqualToString:@"1"] || [self.groupCreateSEntity.groupSecret isEqualToString:@"0"]){
            LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料",@"加好友", nil] btnClickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 999) {
                    return ;
                }else if(buttonIndex == 0){
                    [self jumpPersonalDetailIndexPath:indexPath];
                }else if(buttonIndex == 1){
                    //加好友
                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                    AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                    toCtrol.addFriendId = contactTTT.friend_userid;
                    toCtrol.addFriendName = contactTTT.friend_username;
                    toCtrol.headPicpath = contactTTT.iconUrl;
                    [self.navigationController pushViewController:toCtrol animated:YES];
                }
                
            }];
            [sheet show];
        }else{
            LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"查看资料", nil] btnClickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 999) {
                    return ;
                }else if(buttonIndex == 0){
                    [self jumpPersonalDetailIndexPath:indexPath];
                }
                
            }];
            [sheet show];
        }
        
    }
//    if (indexPath.item == self.memberArr.count) {
//        //add
//        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
//        [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
//            //后面界面点击完成后 回调这里 进行一系列请求  FriendListEntity
//            
//        }];
//        [self.navigationController pushViewController:toCtrol animated:YES];
//    }else if(indexPath.item == self.memberArr.count + 1){
//        //reduce
//        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
//        GroupAddMemberViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupAddMemberViewController"];
//        [toCtrol finishAddMemberAndReturnL:^(NSArray *memberArr) {
//            //后面界面点击完成后 回调这里 进行一系列请求 FriendListEntity
//            
//        }];
//        [self.navigationController pushViewController:toCtrol animated:YES];
//    }
}

-(void)jumpPersonalDetailIndexPath:(NSIndexPath *)indexPath{
    
    //将点击时间传出去
    selectedIndexPath = indexPath;
    //ZJContactDetailController
    self.ZJContactDetailController.view  = nil;
    self.ZJContactDetailController  = nil;
    if (self.ZJContactDetailController == nil) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
        self.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
        //设置单聊详情数据
        ZJContact *contact = self.memberArr[indexPath.item];
        self.ZJContactDetailController.contant = contact;
        self.ZJContactDetailController.SourceFrom = @"1";
        [self addChildViewController:self.ZJContactDetailController];
        self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
            if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
                self.ZJContactDetailController.userNameLabel.hidden = YES;
                self.ZJContactDetailController.freeChatBtn.hidden = YES;
                self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
            }
        }
        __weak typeof(self)weakSelf=self;
        //点击了headview上面的事件
        self.ZJContactDetailController.clickWhich = ^(int index) {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            if (index == 0 || index == 10) {
                //移除ZJContactDetailController
                [UIView animateWithDuration:0.2 animations:^{
                    self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    [self.ZJContactDetailController.view removeFromSuperview];
                    //当移除界面后 设置来自编辑名字为no
                    isFromEditName = NO;
                }];
                strongSelf.navigationController.navigationBarHidden = NO;
            }else if (index == 1){
                __strong typeof(weakSelf)strongSelf=weakSelf;
                [strongSelf showMoreClickWithContact:contact];
            }else if (index == 2){
                
            }
        };
        //如果点击了自己 则
        if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
            self.ZJContactDetailController.freeChatBtn.hidden = YES;
            self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
        }
        //设置编辑名字、免费聊天
        [self.ZJContactDetailController.nameEditBtn addTarget:self action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
        [self.ZJContactDetailController.freeChatBtn addTarget:self action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
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
            [weakSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
        }];
        
        self.ZJContactDetailController.nfHeadImageV.backgroundColor = [UIColor lightGrayColor];
        [self.ZJContactDetailController.tableView addSubview:self.ZJContactDetailController.nfHeadImageV];
        [self.view addSubview:self.ZJContactDetailController.view];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.navigationBarHidden = YES;
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
    ZJContact *contact = self.memberArr[selectedIndexPath.item];
    toCtrol.titleName = contact.friend_username;
//    toCtrol.conversationId = contact.chatId;
    toCtrol.chatType = @"0";
    
    toCtrol.singleContactEntity = contact;
    [self.navigationController pushViewController:toCtrol animated:YES];
}


#pragma mark - 展示联系人详情
-(void)showContactDetail:(ZJContact *)contact{
    self.ZJContactDetailController.view  = nil;
    self.ZJContactDetailController  = nil;
    if (self.ZJContactDetailController == nil) {
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
                self.ZJContactDetailController = [sb instantiateViewControllerWithIdentifier:@"ZJContactDetailTableViewController"];
                //设置单聊详情数据
//                ZJContact *contact = self.memberArr[indexPath.item];
                self.ZJContactDetailController.contant = contact;
                self.ZJContactDetailController.SourceFrom = @"1";
                [self addChildViewController:self.ZJContactDetailController];
                self.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                if ([self.groupCreateSEntity.groupSecret isEqualToString:@"1"]) {
                    if (![self.groupCreateSEntity.is_admin isEqualToString:@"1"] && ![self.groupCreateSEntity.is_admin isEqualToString:@"1"]) {
                        self.ZJContactDetailController.userNameLabel.hidden = YES;
                        self.ZJContactDetailController.freeChatBtn.hidden = YES;
                        self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                    }
                }
                __weak typeof(self)weakSelf=self;
                //点击了headview上面的事件
                self.ZJContactDetailController.clickWhich = ^(int index) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    if (index == 0 || index == 10) {
                        //移除ZJContactDetailController
                        [UIView animateWithDuration:0.2 animations:^{
                            strongSelf.ZJContactDetailController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                        } completion:^(BOOL finished) {
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            [strongSelf.ZJContactDetailController.view removeFromSuperview];
                            //当移除界面后 设置来自编辑名字为no
                            isFromEditName = NO;
                        }];
                        strongSelf.navigationController.navigationBarHidden = NO;
                    }else if (index == 1){
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        [strongSelf showMoreClickWithContact:contact];
                    }else if (index == 2){
                        
                    }
                };
                //如果点击了自己 则
                if ([contact.friend_username isEqualToString:[NFUserEntity shareInstance].userName]) {
                    self.ZJContactDetailController.freeChatBtn.hidden = YES;
                    self.ZJContactDetailController.freeChatTextLabel.hidden = YES;
                }
                //设置编辑名字、免费聊天
                [self.ZJContactDetailController.nameEditBtn addTarget:self action:@selector(EditNameClick) forControlEvents:(UIControlEventTouchUpInside)];
                [self.ZJContactDetailController.freeChatBtn addTarget:self action:@selector(freeChatClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
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
                    [weakSelf.navigationController pushViewController:showImageViewCtrol animated:YES];
                }];
                
                self.ZJContactDetailController.nfHeadImageV.backgroundColor = [UIColor lightGrayColor];
                [self.ZJContactDetailController.tableView addSubview:self.ZJContactDetailController.nfHeadImageV];
                [self.view addSubview:self.ZJContactDetailController.view];
        
                [UIView animateWithDuration:0.2 animations:^{
                    self.navigationController.navigationBarHidden = YES;
                    self.ZJContactDetailController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                } completion:^(BOOL finished) {
                }];
                
            }
            
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
                        self.collectionView.scrollEnabled = YES;
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
                        self.collectionView.scrollEnabled = YES;
                        
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
                    self.collectionView.scrollEnabled = YES;
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





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}


@end
