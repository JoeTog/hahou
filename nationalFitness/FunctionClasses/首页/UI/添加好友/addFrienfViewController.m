//
//  addFrienfViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "addFrienfViewController.h"

@interface addFrienfViewController ()<ChatHandlerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UISearchBar *searchBar;
//懒加载
@property (copy, nonatomic) NSMutableArray *dataArr;    //懒加载

@end

@implementation addFrienfViewController{
    
    
    __weak IBOutlet UITableView *addFriendTableView;
    
    __weak IBOutlet UIView *topView_;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    //搜索的字
    NSString *searchBarString_;
    
    FriendSearchResultEntity *searchResultEntity;
    
}

-(void)viewWillAppear:(BOOL)animated{
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    addFriendTableView.backgroundView=[self setThemeBackgroundImage];
    [addFriendTableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.navigationItem.title = @"添加好友";
    [self initUI];
    [self initScoket];
    
}

-(void)initScoket{
    //取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
}

#pragma mark - 搜索好友请求
-(void)searchFriendRequest:(NSString *)keyString{
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    
    [socketRequest searchFriendRequest:keyString];
    
}

#pragma mark - 初始化界面
-(void)initUI{
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    self.searchBar.placeholder = @"搜索联系人";
    self.searchBar.delegate = self;
    
    id Field;
    if (@available(iOS 13.0, *)) {
        Field = self.searchBar.searchTextField;
    }else{
        Field = [self.searchBar valueForKey:@"_searchField"];
    }
    
    UITextField *txfSearchField;
    if ([Field isKindOfClass:[UITextField class]]) {
        if (@available(iOS 13.0, *)) {
            txfSearchField =self.searchBar.searchTextField;
        }else{
            txfSearchField = [self.searchBar valueForKey:@"_searchField"];
        }

        
    }
    UIView *view = txfSearchField.superview;
    view.backgroundColor = UIColorFromRGB(0xF5F5F5);
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
    [topView_ addSubview:self.searchBar];
    
    if ([self.addFriendType isEqualToString:@"1"]) {
        self.title = @"添加好友";
    }else if ([self.addFriendType isEqualToString:@"2"]){
        self.title = @"添加群组";
    }
    
    addFriendTableView.tableFooterView = [UIView new];
    
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_FriendSearchResult) {
        //FriendSearchResultEntity
//        [self.dataArr removeAllObjects];
        searchResultEntity = chatModel;
        [addFriendTableView reloadData];
        
    }
    
}



//隐藏键盘
- (void)hideKeyBoard
{
    //点击遮罩清空草稿和缓存数据
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    searchBarString_ = searchBar.text;
    //搜索当前选中的地区的关键字list
    [self initDataSource];
    
    //网络请求
    [self searchFriendRequest:searchBar.text];
    
    [self.view endEditing:YES];
    [self performSelector:@selector(hideKeyBoard)];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //    [self searchDataWithWord:searchText];
    if (searchText.length == 0) {
        searchBarString_ = nil;
        [self.dataArr removeAllObjects];
        [addFriendTableView reloadData];
    }
}


#pragma mark - tableViewDelegate & tableViewDateSource
//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (searchResultEntity.friendId) {
        return 1;
    }
    return 0;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}
//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"ContantTableViewCell";
    ContantTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ContantTableViewCell" owner:nil options:nil]firstObject];
    }
    
//    cell.nameLabel.text = searchResultEntity.nickname;
    cell.nameLabel.text = searchResultEntity.userAndNickName;
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:searchResultEntity.photo] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //类型 0申请与通知 1添加好友 2群组
    if ([self.addFriendType isEqualToString:@"0"]) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
        ApplyViewDetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ApplyViewDetailViewController"];
        [self.navigationController pushViewController:toCtrol animated:YES];
    }else if ([self.addFriendType isEqualToString:@"1"]){
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
        AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
        toCtrol.addFriendId = searchResultEntity.friendId;
        toCtrol.addFriendName = searchResultEntity.name;
        toCtrol.headPicpath = searchResultEntity.photo;
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }else if ([self.addFriendType isEqualToString:@"2"]){
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
        AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
        toCtrol.addFriendType = @"2";
        [self.navigationController pushViewController:toCtrol animated:YES];
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self performSelector:@selector(hideKeyBoard)];
}

#pragma mark - //准备数据
-(void)initDataSource{
    
    for (int i = 0; i < 1; i++) {
        MessageChatEntity *entity = [MessageChatEntity new];
        
        [self.dataArr addObject:entity];
    }
    [addFriendTableView reloadData];
    
}

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
