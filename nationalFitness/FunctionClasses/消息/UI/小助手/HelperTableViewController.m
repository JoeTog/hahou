//
//  HelperTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/11/30.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "HelperTableViewController.h"


#import "SocketModel.h"
#import "SocketRequest.h"
#import "EGORefreshTableHeaderView.h"


@interface HelperTableViewController ()<ChatHandlerDelegate,EGORefreshTableHeaderDelegate>

@end

@implementation HelperTableViewController{
    
    
    
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
    
    
    self.title = @"多信小助手";
     
     self.tableView.tableFooterView = [UIView new];
     
    // [self initUI];
     
     [self initScoket];
    
    
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
//            [socketRequest BillListWithPage:@"1" IsSystem:self.IsSystem];
            [socketRequest helperMessageList];
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
//            [socketRequest BillListWithPage:[NSString stringWithFormat:@"%@",@(dataArr_.count / 15 + 1)] IsSystem:self.IsSystem];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
    
}

#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_HelperMessageList) {
        [SVProgressHUD dismiss];
        NSDictionary *info = chatModel;
        NSArray *arr = [info objectForKey:@"arr"];
        NSInteger allCount = [[info objectForKey:@"allCount"] integerValue];
        [dataArr_ addObjectsFromArray:arr];
//        if ([dataArr_ count] < allCount)
//        {
//            canRefreshLash_ = YES;
//        }
//        else
//        {
//            canRefreshLash_ = NO;
//        }
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [NSThread sleepForTimeInterval:0.2];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArr_.count-1 inSection:0] atScrollPosition:(UITableViewScrollPositionNone) animated:NO];
            });
        });
        
        
    }
    
}




#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
    
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:BGCOLOR_GRAY];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    label.text = @"  多信小助手";
//    label.textColor = [UIColor blackColor];
//    label.textAlignment = NSTextAlignmentLeft;
//    [headerView addSubview:label];
    return headerView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr_.count;
//    return dataArr_.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BillListEntity *entity =  dataArr_[indexPath.row];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGFloat height = [entity.detail boundingRectWithSize:CGSizeMake(JOESIZE.width, 20000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
    if(height < 50){
        return 100;
    }
    return height + 100;
    
//    return 100;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"NoMoreCellTableViewCell";
//    if (dataArr_.count == indexPath.row) {
//        static NSString* cellIdentifier = nil;
//        //分页相关
//        cellIdentifier = @"cell_more";
//        NoMoreCellTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (cell == nil) {
//            cell = [[[NSBundle mainBundle]loadNibNamed:@"NoMoreCellTableViewCell" owner:nil options:nil]firstObject];
//        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//        //分页请求数据
//        if (canRefreshLash_ && !isRefreshLashing_)
//        {
//            cell.titleLabel.text = @"加载更多...";
//            [self performSelector:@selector(refreshFromLast) withObject:nil afterDelay:0.2f];
//        }
//        else if (!canRefreshLash_)
//        {
//            cell.titleLabel.text = @"没有更多了";
//        }
//        return cell;
//    }
    
    cellIdentifier = @"HelperTableViewCell";
    HelperTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"HelperTableViewCell" owner:nil options:nil]firstObject];
    }
    BillListEntity *entity =  dataArr_[indexPath.row];
    cell.detailllTextLabel.text = entity.detail;
    cell.detailllTextLabel.numberOfLines = 0;
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
    
//    if([entity.amount containsString:@"+"]){
//        cell.amountLabel.textColor = UIColorFromRGB(0xEAAA3C);
//    }
//    cell.badgeView.hidden = YES;
//    if([entity.status isEqualToString:@"unread"] && self.IsSystem){
//        cell.badgeView.hidden = NO;
//        cell.badgeView.showBadge = YES;
//    }
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    //
    BillListEntity *entity = dataArr_[indexPath.row];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    HelperDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"HelperDetailTableViewController"];
    toCtrol.detailText = entity.detail;
    toCtrol.timeText = entity.datetime;
   // [self.navigationController pushViewController:toCtrol animated:YES];
    
}







@end
