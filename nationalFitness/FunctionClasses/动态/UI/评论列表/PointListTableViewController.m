//
//  PointListTableViewController.m
//  nationalFitness
//
//  Created by joe on 2021/1/8.
//  Copyright © 2021 chenglong. All rights reserved.
//

#import "PointListTableViewController.h"


#import "SocketModel.h"
#import "SocketRequest.h"
#import "EGORefreshTableHeaderView.h"

@interface PointListTableViewController ()<ChatHandlerDelegate,EGORefreshTableHeaderDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation PointListTableViewController{
    
    
    
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
    
    
    dataArr_ = [NSMutableArray new];
//    for (int i = 0; i<10; i++) {
//        commentListEntity *entity = [commentListEntity new];
//        entity.headImageUrl = @"";
//        entity.nickname = @"小白";
//        entity.commentContent = @"222222222222222222222222222222";
//        entity.dymicContent = @"1111111111111111111111111111";
//        entity.timeStr = @"1月11日 13：24";
//        entity.imageTUrl = @"";
//        [dataArr_ addObject:entity];
//    }
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.title = @"消息列表";
    
    
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
            [socketRequest getCircleUnreadMsg];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_receiveDynamicCommentList) {
        [SVProgressHUD dismiss];
//        NSDictionary *info = chatModel;
//        NSArray *arr = [info objectForKey:@"arr"];
//        NSInteger allCount = [[info objectForKey:@"allCount"] integerValue];
//        [dataArr_ addObjectsFromArray:arr];
//        if ([dataArr_ count] < allCount)
//        {
//            canRefreshLash_ = YES;
//        }
//        else
//        {
//            canRefreshLash_ = NO;
//        }
//        [self.tableView reloadData];
//        [SVProgressHUD dismiss];
        NSArray *arr = chatModel;
        dataArr_ = [NSMutableArray arrayWithArray:arr];
        [self.tableView reloadData];
        
        
    }
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr_.count;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
    
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
    
    cellIdentifier = @"BillListTableViewCell";
    PointListTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PointListTableViewCell" owner:nil options:nil]firstObject];
    }
//    BillListEntity *entity =  dataArr_[indexPath.row];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    commentListEntity *entity = dataArr_[indexPath.row];
    cell.nickNameL.textColor = UIColorFromRGB(0x566786);
    if(entity.IsDianZan){
        [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:entity.headImageUrl]];
        cell.nickNameL.text = entity.nickname;
        cell.timeL.text = entity.timeStr;
        cell.nickNameL.text = entity.nickname;
        cell.commentLabel.text = @"♡";
        cell.commentLabel.textColor = UIColorFromRGB(0x566786);
    }else{
        [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:entity.headImageUrl]];
        cell.nickNameL.text = entity.nickname;
        cell.timeL.text = entity.timeStr;
        cell.nickNameL.text = entity.nickname;
        cell.commentLabel.text = entity.commentContent;
        if (entity.imageTUrl.length > 0) {
            [cell.contentImageV sd_setImageWithURL:[NSURL URLWithString:entity.headImageUrl]];
            cell.dymicContentL.hidden = YES;
            cell.contentImageV.hidden = NO;
        }else{
            cell.dymicContentL.text = entity.dymicContent;
            cell.contentImageV.hidden = YES;
            cell.dymicContentL.hidden = NO;
        }
    }
    
    
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    commentListEntity *Entity = dataArr_[indexPath.row];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"DynamicStoryboard" bundle:nil];
    DynamicNewDetailViewController *detailVC = [sb instantiateViewControllerWithIdentifier:@"DynamicNewDetailViewController"];
    detailVC.entityid = Entity.dymicId;
    NoteListEntity *entityy = [NoteListEntity new];
    entityy.circle_id = Entity.dymicId;
    entityy.circle_content = Entity.dymicContent;
    
    detailVC.noteListEntity = entityy;
    
//    if (entity.photoList.count == 0){
//        [NFUserEntity shareInstance].isPicImageDynamic = NO;
//    }else{
//        [NFUserEntity shareInstance].isPicImageDynamic = YES;
//    }
    //是否需要删除该动态 【从详情页 返回的】
//    dynamicTableView.tableFooterView = [UIView new];
//    NSLog(@"\n%d\n%d\n",indexPath.section,indexPath.section);
//    __weak typeof(self)weakSelf=self;
//    [detailVC returnDeleteBlock:^{
//        __strong typeof(weakSelf)strongSelf=weakSelf;
//        [strongSelf ->dataSourceArr_ removeObjectAtIndex:indexPath.section - 2];
//        [strongSelf ->dynamicTableView reloadData];
//    }];
//    //返回点赞状态 当详情界面见将要消失的时候 将点赞状态传回来，在willappear中进行比对是否发生改变。
//    [detailVC setReturnPraiseBlock:^(BOOL ret) {
//        if (ret && [entity.isPraise isEqualToString:@"0"]) {
//            IsPraise = @"1";
//        }else if(!ret && [entity.isPraise isEqualToString:@"1"]){
//            IsPraise = @"0";
//        }
//    }];
    //详情数据
//    detailVC.noteListEntity = entity;
//    //每次点击cell 到详情 将标记的是否点赞初始化
//    IsPraise = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
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
            [socketRequest PointListRequestWithPage:[NSString stringWithFormat:@"%@",@(dataArr_.count / 15 + 1)]];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
    
    
}













@end
