//
//  RecordTableViewController.m
//  nationalFitness
//
//  Created by joe on 2019/12/10.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import "RecordTableViewController.h"

#import "SocketModel.h"
#import "SocketRequest.h"

#import "EGORefreshTableHeaderView.h"

@interface RecordTableViewController ()<ChatHandlerDelegate,EGORefreshTableHeaderDelegate>

@end

@implementation RecordTableViewController{
    
    IBOutlet UITableView *recordTableV;
    
    
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
    
    if(self.isChongzhi){
        self.title = @"充值记录";
    }else{
        self.title = @"提现记录";
    }
    
    [recordTableV registerNib:[UINib nibWithNibName:@"RecordTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellId"];
    
    recordTableV.tableFooterView = [UIView new];
    
    [self initUI];
    [self initScoket];
    
}

-(void)initUI{
#pragma mark - 下拉刷新2
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - recordTableV.bounds.size.height, recordTableV.frame.size.width, recordTableV.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        [recordTableV addSubview:refreshHeader];
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
            //记录请求
            if(self.isChongzhi){
                [socketRequest chongzhiRecordWithPage:@"1"];
            }else{
                [socketRequest recordMonryWithPage:@"1"];
            }
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
            //记录请求
            if(self.isChongzhi){
                [socketRequest chongzhiRecordWithPage:[NSString stringWithFormat:@"%@",@(dataArr_.count / 15 + 1)]];
            }else{
                [socketRequest recordMonryWithPage:[NSString stringWithFormat:@"%@",@(dataArr_.count / 15 + 1)]];
            }
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
    
}



#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_cashRecord) {
        
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
        [recordTableV reloadData];
        
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr_.count + 1;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(dataArr_.count == 0){
        
    }
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
    
    RecordTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"RecordTableViewCell" owner:nil options:nil][0];
    RecordMoneyEntity *entity = dataArr_.count>indexPath.row?dataArr_[indexPath.row]:[RecordMoneyEntity new];
    ViewRadius(cell.headV, cell.headV.frame.size.height/2);
//    [cell.headV sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    
//    [cell.headV sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"充值提现"]];
    cell.headV.image = [UIImage imageNamed:@"充值提现"];
//    [cell.headV show];
    cell.detailLabel.text = entity.detail;
    cell.timeLabel.text = entity.time;
    cell.moneyLabel.text = entity.account;
    
    
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
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:recordTableV];
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
