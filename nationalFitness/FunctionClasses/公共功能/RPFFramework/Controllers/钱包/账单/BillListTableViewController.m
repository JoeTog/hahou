




//
//  BillListTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/1/19.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "BillListTableViewController.h"

#import "SocketModel.h"
#import "SocketRequest.h"
#import "EGORefreshTableHeaderView.h"

@interface BillListTableViewController ()<ChatHandlerDelegate,EGORefreshTableHeaderDelegate>

@end

@implementation BillListTableViewController{
    
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    
    BOOL reloading_;
    BOOL needReloading_;
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    
    EGORefreshTableHeaderView * refreshHeaderView_;
    
    NSMutableArray *dataArr_;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.IsSystem){
        self.title = @"系统通知";
    }else{
        self.title = @"我的账单";
    }
    
    self.tableView.tableFooterView = [UIView new];
    
   // [self initUI];
    
    [self initScoket];
    
}


-(void)initUI{
#pragma mark - 下拉刷新2
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        [self.tableView addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
    
    //下面再创建其他例如tableview，topview等，不然刷新将会无效
    
}

//初始化请求 记录
-(void)initScoket{
    dataArr_ = [NSMutableArray new];
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //当从登陆界面过来 需要打开下面，这时候
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [SVProgressHUD show];
            [socketRequest BillListWithPage:@"1" IsSystem:self.IsSystem];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

-(void)refreshFromLast{
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //当从登陆界面过来 需要打开下面，这时候
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            [SVProgressHUD show];
            [socketRequest BillListWithPage:[NSString stringWithFormat:@"%@",@(dataArr_.count / 15 + 1)] IsSystem:self.IsSystem];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
    
}

#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_BillList) {
        
        NSDictionary *info = chatModel;
        NSArray *arr = [info objectForKey:@"arr"];
        NSInteger allCount = [[info objectForKey:@"allCount"] integerValue];
        [dataArr_ addObjectsFromArray:arr];
        if ([dataArr_ count] < allCount)
        {
            canRefreshLash_ = YES;
        }
        else
        {
            canRefreshLash_ = NO;
        }
        [self.tableView reloadData];
        
    }
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr_.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"NoMoreCellTableViewCell";
    if (dataArr_.count == indexPath.row) {
        static NSString* cellIdentifier = nil;
        //分页相关
        cellIdentifier = @"cell_more";
        NoMoreCellTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"NoMoreCellTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //分页请求数据
        if (canRefreshLash_ && !isRefreshLashing_)
        {
            cell.titleLabel.text = @"加载更多...";
            [self performSelector:@selector(refreshFromLast) withObject:nil afterDelay:0.2f];
        }
        else if (!canRefreshLash_)
        {
            cell.titleLabel.text = @"没有更多了";
        }
        return cell;
    }
    
    cellIdentifier = @"BillListTableViewCell";
    BillListTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BillListTableViewCell" owner:nil options:nil]firstObject];
    }
    BillListEntity *entity =  dataArr_[indexPath.row];
    if ([entity.type isEqualToString:@"1"] || [entity.type isEqualToString:@"2"]) {
        [cell.headImageV ShowImageWithUrlStr:@"充值提现" placeHoldName:@"" completion:^(BOOL success, UIImage *image) {
        }];
    }else if ([entity.type isEqualToString:@"3"] || [entity.type isEqualToString:@"4"] || [entity.type isEqualToString:@"5"]){
        [cell.headImageV ShowImageWithUrlStr:@"多信红包" placeHoldName:@"" completion:^(BOOL success, UIImage *image) {
        }];
    }else if ([entity.type isEqualToString:@"6"] || [entity.type isEqualToString:@"7"]){
        [cell.headImageV ShowImageWithUrlStr:@"转账账单" placeHoldName:@"" completion:^(BOOL success, UIImage *image) {
        }];
    }
    cell.titleDetailLabel.text = entity.detail;
    cell.amountLabel.text = entity.amount;
    
    if (entity.time && entity.time.length > 0) {
        NSDate *date;
        if (entity.time.length > 0) {
            date = [NSDate dateWithTimeIntervalSince1970:[entity.time integerValue]];
        }
        if ([date isThisYear]) {
            NSString *aa = [[NFbaseViewController new] timestampSwitchTime:[entity.time integerValue] anddFormatter:@"M月d日 HH:ss"];
            cell.timeLabel.text = aa;
            
        }else{
            cell.timeLabel.text = [[NFbaseViewController new] timestampSwitchTime:[entity.time integerValue] anddFormatter:@"yyyy年M月d日 HH:ss"];
        }
        
    }else if(entity.datetime && entity.datetime.length > 0){
        cell.timeLabel.text = entity.datetime;
    }else{
        cell.timeLabel.text = @"未知";
    }
    
    if([entity.amount containsString:@"+"]){
        cell.amountLabel.textColor = UIColorFromRGB(0xEAAA3C);
    }
    cell.badgeView.hidden = YES;
    if([entity.status isEqualToString:@"unread"] && self.IsSystem){
        cell.badgeView.hidden = NO;
        cell.badgeView.showBadge = YES;
    }
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
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
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - 下拉刷新委托回调

//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
#pragma mark - 下拉刷新6
    //此处刷新接口数据
    
    [self initScoket];
    
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












@end
